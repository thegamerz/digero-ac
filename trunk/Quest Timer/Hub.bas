Attribute VB_Name = "Hub"
Option Explicit
Option Compare Text

#Const DEBUG__ = False

Global Const sPluginName As String = "Quest Timer"
Public sPluginNameVer As String
Global Const sCmdName As String = "qtimer"
Global Const QuestFileVer As Long = 5
Global Const SettingsFileVer As Long = 3
#If DEBUG__ Then
    Global Const sWebURL As String = "http://localhost/decal/quest_timer.php"
#Else
    Global Const sWebURL As String = "http://decal.acasylum.com/quest_timer.php"
#End If
Global Const TREESTATS_URL = "http://www.treestats.com/quest_timer.php"

Public FSO As New FileSystemObject, ErrorLog As TextStream
Public PluginSite As DecalPlugins.PluginSite, PluginSite2 As Decal.PluginSite2
Public Hooks2 As Decal.ACHooks
Public Quests() As Quest

Type Quest
    QuestName As String
    Days As Long
    Hours As Long
    Minutes As Long
    text As String
    Item As String
    Droppable As Boolean
    chest As String
    Completed As Date
    Told As Boolean
    IOwn As New Collection
End Type

Type SYSTEMTIME
    wYear As Integer
    wMonth As Integer
    wDayOfWeek As Integer
    wDay As Integer
    wHour As Integer
    wMinute As Integer
    wSecond As Integer
    wMillisecond As Integer
End Type

Public Declare Sub GetSystemTime Lib "kernel32.dll" (st As SYSTEMTIME)

Public sCharName As String, sWorld As String, lPlayerGUID As Long, sAcctChars As String
Public bLoggedIn As Boolean

Public Sub WriteXML(ByRef XMLDoc As DOMDocument40, sFilePath As String)
4410      On Error GoTo erh
          Dim XMLWriter As New MXXMLWriter40, XMLReader As New SAXXMLReader40
4412      XMLWriter.encoding = "UTF-8"
4414      XMLWriter.indent = True
4416      Set XMLReader.contentHandler = XMLWriter
4418      Set XMLReader.dtdHandler = XMLWriter
4420      Set XMLReader.errorHandler = XMLWriter
          
4422      XMLReader.parse XMLDoc
4424      FSO.CreateTextFile(sFilePath).Write XMLWriter.output
4426      GoTo EndSub
erh:
4428      HandleErr "WriteXML"
EndSub:
4430      Set XMLWriter = Nothing
4432      Set XMLReader = Nothing
End Sub

'******************************************************************************
'**  Time Functions  **********************************************************
'******************************************************************************

Public Function ISODate(ByVal dDate As Date) As String 'Date/Time in the ISO 8601 format
4434      ISODate = Format(dDate, "yyyy-mm-dd hh:mm:ss")
End Function

Public Function NowGMT() As Date 'GMT Date/Time
          Dim gmt As SYSTEMTIME
4436      GetSystemTime gmt
4438      NowGMT = DateSerial(gmt.wYear, gmt.wMonth, gmt.wDay) + TimeSerial(gmt.wHour, gmt.wMinute, gmt.wSecond)
End Function

Public Function GMTOffset() As String
          Dim d As Date
4440      d = Now - NowGMT
4442      GMTOffset = IIf(d < 0, "-", "+") & Format(Hour(d), "00") & Format(Minute(d), "00")
End Function

Public Function GMTOffsetD() As Date
4444      GMTOffsetD = Now - NowGMT
End Function

'******************************************************************************
'**  Chat Window Functions  ***************************************************
'******************************************************************************

Public Sub wtcwMessage(ByVal sMsg As String)
          'WriteToChatWindow "«17»<{ «2»" & sPluginName & "«17» }> «d»" & sMsg, 14
4446      PluginSite2.Hooks.AddChatText "<{ " & sPluginName & " }> " & StripColorTags(sMsg), 14, 1
End Sub

Public Sub wtcwWarning(ByVal sMsg As String)
          'WriteToChatWindow "«3»<{ «2»" & sPluginName & "«3» }> «d»" & sMsg, 4
4448      PluginSite2.Hooks.AddChatText "<{ " & sPluginName & " }> " & StripColorTags(sMsg), 4, 1
End Sub

Public Sub wtcwError(ByVal sMsg As String)
4450      sMsg = sMsg & " [v" & App.Major & "." & App.Minor & ".0." & App.Revision & "]"
          'WriteToChatWindow "«6»<{ «2»" & sPluginName & "«6» }> «d»" & sMsg, 8
4452      PluginSite2.Hooks.AddChatText "<{ " & sPluginName & " }> " & StripColorTags(sMsg), 8, 1
          
4454      If ErrorLog Is Nothing Then
4456          Set ErrorLog = FSO.OpenTextFile(App.Path & "\errors.txt", ForAppending, True)
4458          ErrorLog.WriteBlankLines 2
4460          ErrorLog.WriteLine String(80, "-")
4462          ErrorLog.WriteLine "** Error logging started on " & Format(Now, "Long Date") & " at " & Format(Now, "H:MM AMPM")
4464      End If
4466      Do While InStr(sMsg, "«")
4468          sMsg = Left(sMsg, InStr(sMsg, "«") - 1) & Mid(sMsg, InStr(sMsg, "»") + 1)
4470      Loop
4472      ErrorLog.WriteLine "[" & Format(Now, "H:MM AMPM") & "] " & sMsg
End Sub

Public Sub wtcwCmdInfo(ByVal cmdName As String, ByVal cmdInfo As String)
4474      wtcwMessage "«d»/" & sCmdName & " " & cmdName & " «17»- " & cmdInfo
End Sub

#If DEBUG__ Then
    Public Sub wtcwDebug(ByVal sMsg As String)
              'WriteToChatWindow "«17»<{ «2»" & sPluginName & "«17»  }> «d»" & sMsg, 12
4478          PluginSite2.Hooks.AddChatText "<{ " & sPluginName & " Debug }> " & StripColorTags(sMsg), 12, 1
    End Sub
#Else
    Public Sub wtcwDebug(ByVal sMsg As String)
        'Do Nothing
    End Sub
#End If

Public Sub HandleErr(ByVal sFunctionName As String)
          Dim sErrMsg As String
4480      sErrMsg = "Error"
4482      If Err.Number <> 0 Then sErrMsg = sErrMsg & " #«2»" & Err.Number & "«d»"
4484      sErrMsg = sErrMsg & " occurred in " & sFunctionName & ": «2»" & Err.Description
4486      If Erl > 0 Then sErrMsg = sErrMsg & "«d» @ line «2»" & Erl
4488      wtcwError sErrMsg
End Sub

'WriteToChatWindow taken from Solandra's plugin framework
Private Sub WriteToChatWindow(ByVal sMsg As String, lDefaultColor As Long)
4490      sMsg = Replace(sMsg, "«d»", "«" & lDefaultColor & "»")
4492      If bLoggedIn And Not Hooks2 Is Nothing Then
              Dim iColor As Long, sText As String, Delimiter As String
4494          Delimiter = Left(sMsg, 1)
4496          If Right(sMsg, 1) <> vbLf Then sMsg = sMsg & vbLf
4498          If (Left(sMsg, 1) = Delimiter) Then
4500              Do
4502                  sMsg = Right(sMsg, Len(sMsg) - 1)
4504                  iColor = Val(sMsg)
4506                  sMsg = Right(sMsg, Len(sMsg) - Len(Format(iColor)) - 1)
4508                  If (InStr(sMsg, Delimiter)) Then
4510                      sText = Left(sMsg, InStr(sMsg, Delimiter) - 1)
4512                      Hooks2.AddChatTextRaw sText, iColor, 0
4514                      sMsg = Right(sMsg, Len(sMsg) - Len(sText))
4516                  Else
4518                      Hooks2.AddChatTextRaw sMsg, iColor, 0
4520                      sMsg = ""
4522                  End If
4524              Loop While Len(sMsg) > 0
4526          End If
4528      End If
End Sub

Private Function StripColorTags(msg As String) As String
4530      StripColorTags = msg
4532      Do While InStr(StripColorTags, "«")
4534          StripColorTags = Left(StripColorTags, InStr(StripColorTags, "«") - 1) & _
                  Mid(StripColorTags, InStr(StripColorTags, "»") + 1)
4536      Loop
End Function

