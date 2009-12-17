Attribute VB_Name = "Hub"
Option Explicit

Global Const sPluginName As String = "Media Control"
Private Const chatWindow = 1

Public FSO As New FileSystemObject
Public PluginSite As DecalPlugins.PluginSite, PluginSite2 As Decal.PluginSite2

Private ErrorLog As TextStream

Public Function sPluginNameVer() As String
192       sPluginNameVer = sPluginName & " v" & App.Major & "." & App.Minor & ".0." & App.Revision
End Function

'******************************************************************************
'**  Chat Window Functions  ***************************************************
'******************************************************************************

Public Sub wtcwMessage(ByVal sMsg As String)
194       wtcw sPluginName, sMsg, 14, 17
End Sub

Public Sub wtcwWarning(ByVal sMsg As String)
196       wtcw sPluginName, sMsg, 4, 3
End Sub

Public Sub wtcwError(ByVal sMsg As String)
198       wtcw sPluginNameVer, sMsg, 8, 6
          
200       If ErrorLog Is Nothing Then
202           Set ErrorLog = FSO.OpenTextFile(App.Path & "\errors.txt", ForAppending, True)
204           ErrorLog.WriteBlankLines 2
206           ErrorLog.WriteLine String(80, "-")
208           ErrorLog.WriteLine "** Error logging started on " & Format(Now, "Long Date") & " at " & Format(Now, "H:MM AMPM")
210       End If
212       ErrorLog.WriteLine "[" & Format(Now, "H:MM AMPM") & "] " & stripColorTags(sMsg)
End Sub

Public Sub handleErr(ByVal sFunctionName As String)
          Dim sErrMsg As String
214       sErrMsg = "Error"
216       If Err.Number <> 0 Then sErrMsg = sErrMsg & " #«2»" & Err.Number & "«d»"
218       sErrMsg = sErrMsg & " occurred in " & sFunctionName & ": «2»" & Err.Description
220       If Erl > 0 Then sErrMsg = sErrMsg & "«d» @ line «2»" & Erl
222       wtcwError sErrMsg
End Sub

Public Sub wtcwDebug(ByVal sMsg As String)
224       wtcw sPluginName & " Debug", sMsg, 12, 17
End Sub

Private Sub wtcw(pluginName As String, sMsg As String, defaultColor As Long, secondaryColor As Long)
226       If Not PluginSite2 Is Nothing Then
              'WriteToChatWindow "«" & secondaryColor & "»<{ «2»" & sPluginName & "«" & secondaryColor & "» }> «d»" & sMsg, defaultColor
228           PluginSite2.Hooks.AddChatText "<{ " & pluginName & " }> " & stripColorTags(sMsg), defaultColor, chatWindow
230       End If
End Sub

Private Function stripColorTags(msg As String) As String
232       stripColorTags = msg
234       Do While InStr(stripColorTags, "«")
236           stripColorTags = Left(stripColorTags, InStr(stripColorTags, "«") - 1) & _
                  Mid(stripColorTags, InStr(stripColorTags, "»") + 1)
238       Loop
End Function

'WriteToChatWindow taken from Solandra's plugin framework
Private Sub WriteToChatWindow(ByVal sMsg As String, lDefaultColor As Long)
240       sMsg = Replace(sMsg, "«d»", "«" & lDefaultColor & "»")
          
          Dim iColor As Long, sText As String, Delimiter As String
242       Delimiter = Left(sMsg, 1)
244       If Right(sMsg, 1) <> vbLf Then sMsg = sMsg & vbLf
246       If (Left(sMsg, 1) = Delimiter) Then
248           Do
250               sMsg = Right(sMsg, Len(sMsg) - 1)
252               iColor = Val(sMsg)
254               sMsg = Right(sMsg, Len(sMsg) - Len(Format(iColor)) - 1)
256               If (InStr(sMsg, Delimiter)) Then
258                   sText = Left(sMsg, InStr(sMsg, Delimiter) - 1)
260                   PluginSite2.Hooks.AddChatTextRaw sText, iColor, chatWindow
262                   sMsg = Right(sMsg, Len(sMsg) - Len(sText))
264               Else
266                   PluginSite2.Hooks.AddChatTextRaw sMsg, iColor, chatWindow
268                   sMsg = ""
270               End If
272           Loop While Len(sMsg) > 0
274       End If
End Sub
