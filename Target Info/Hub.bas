Attribute VB_Name = "Hub"
Option Explicit

Global Const sPluginName As String = "Target Info"
Private Const chatWindow = 1

'Installer upgrade code {35DB7F86-9BB2-4668-8FFB-8A75227D55DC}

Public LowBuffThresh As Long
Global Const scMonster = 0, scPlayer = 1, scBoth = 2
Public bLoadingSettings As Boolean

Public lifeSpellLevel As DecalControls.Choice
Public creatureSpellLevel As DecalControls.Choice

Public txtVulnDbaseCount As DecalControls.StaticText

Public VulnDbase As New clsVulnDbase

Public FSO As New FileSystemObject
Public PluginSite As DecalPlugins.PluginSite, PluginSite2 As Decal.PluginSite2
Public SpellF As SpellFilter.spells
Public CharStats As DecalFilters.CharacterStats
Public WorldFilter As DecalFilters.World

Public DecorationType As DecalControls.Choice
Public Enum eDecorationType
    eNoDecoration = 0: eOutline: eShortShadow: eLongShadow
End Enum
Public DecorationColor As DecalControls.Choice
Public Enum eDecorationColor
    eClrAuto = 0: eClrBlack: eClrDrkGray: eClrLtGray: eClrWhite
End Enum

Public Type POINTAPI
    x As Long
    y As Long
End Type

Private ErrorLog As TextStream

Public Sub writeXML(ByRef xmlDoc As DOMDocument40, sFilePath As String)
2154      On Error GoTo erh
          Dim xmlWriter As New MXXMLWriter40, xmlReader As New SAXXMLReader40
2156      xmlWriter.encoding = "UTF-8"
2158      xmlWriter.indent = True
2160      Set xmlReader.contentHandler = xmlWriter
2162      Set xmlReader.dtdHandler = xmlWriter
2164      Set xmlReader.errorHandler = xmlWriter
          
2166      xmlReader.parse xmlDoc
2168      FSO.CreateTextFile(sFilePath).Write xmlWriter.output
2170      GoTo EndSub
erh:
2172      handleErr "WriteXML"
EndSub:
2174      Set xmlWriter = Nothing
2176      Set xmlReader = Nothing
End Sub

Public Function SpellTime(SpellType As eDebuffType) As Date
2178      Select Case SpellType
              Case dbfCrit: SpellTime = TimeSerial(0, 0, creatureSpellLevel.Data(creatureSpellLevel.Selected))
2180          Case dbfLife: SpellTime = TimeSerial(0, 0, lifeSpellLevel.Data(lifeSpellLevel.Selected))
2182      End Select
End Function

Public Function max(a, b)
2184      If b > a Then max = b Else max = a
End Function

Public Function min(a, b)
2186      If b < a Then min = b Else min = a
End Function

Public Function makeRect(x1 As Long, y1 As Long, x2 As Long, y2 As Long) As Decal.tagRECT
2188      setRect makeRect, x1, y1, x2, y2
End Function

Public Function makeRect2(x As Long, y As Long, width As Long, height As Long) As Decal.tagRECT
2190      setRect2 makeRect2, x, y, width, height
End Function

Public Sub setRect(ByRef rect As Decal.tagRECT, x1 As Long, y1 As Long, x2 As Long, y2 As Long)
2192      rect.Left = x1
2194      rect.Top = y1
2196      rect.Right = x2
2198      rect.Bottom = y2
End Sub

Public Sub setRect2(ByRef rect As Decal.tagRECT, x As Long, y As Long, width As Long, height As Long)
2200      rect.Left = x
2202      rect.Top = y
2204      rect.Right = x + width
2206      rect.Bottom = y + height
End Sub

Public Sub moveRect(ByRef rect As Decal.tagRECT, x As Long, y As Long)
2208      rect.Left = rect.Left + x
2210      rect.Top = rect.Top + y
2212      rect.Right = rect.Right + x
2214      rect.Bottom = rect.Bottom + y
End Sub

Public Sub setRectPos(ByRef rect As Decal.tagRECT, x As Long, y As Long)
          Dim w As Long, h As Long
2216      w = rect.Right - rect.Left
2218      h = rect.Bottom - rect.Top
2220      rect.Left = x
2222      rect.Top = y
2224      rect.Right = x + w
2226      rect.Bottom = y + h
End Sub

Public Function rectEqual(a As tagRECT, b As tagRECT) As Boolean
2228      rectEqual = a.Left = b.Left And a.Top = b.Top And a.Right = b.Right And a.Bottom = b.Bottom
End Function

Public Function rectDebugString(rect As tagRECT) As String
2230      rectDebugString = "[" & rect.Left & ", " & rect.Top & ", " & rect.Right & ", " & rect.Bottom & "] (" & _
              rect.Right - rect.Left & " x " & rect.Bottom - rect.Top & ")"
End Function

Public Function makePoint(aX As Long, aY As Long) As DecalPlugins.tagPOINT
2232      makePoint.x = aX
2234      makePoint.y = aY
End Function

Public Function makeSize(aCx As Long, aCy As Long) As DecalPlugins.tagSIZE
2236      makeSize.cx = aCx
2238      makeSize.cy = aCy
End Function

Public Function sPluginNameVer() As String
2240      sPluginNameVer = sPluginName & " v" & App.Major & "." & App.Minor & ".0." & App.Revision
End Function

'******************************************************************************
'**  Chat Window Functions  ***************************************************
'******************************************************************************

Public Sub wtcwMessage(ByVal sMsg As String)
2242      wtcw sPluginName, sMsg, 14, 17
End Sub

Public Sub wtcwWarning(ByVal sMsg As String)
2244      wtcw sPluginName, sMsg, 4, 3
End Sub

Public Sub wtcwError(ByVal sMsg As String)
2246      wtcw sPluginNameVer, sMsg, 8, 6
          
2248      If ErrorLog Is Nothing Then
2250          Set ErrorLog = FSO.OpenTextFile(App.Path & "\errors.txt", ForAppending, True)
2252          ErrorLog.WriteBlankLines 2
2254          ErrorLog.WriteLine String(80, "-")
2256          ErrorLog.WriteLine "** Error logging started on " & Format(Now, "Long Date") & " at " & Format(Now, "H:MM AMPM")
2258      End If
2260      ErrorLog.WriteLine "[" & Format(Now, "H:MM AMPM") & "] " & stripColorTags(sMsg)
End Sub

Public Sub wtcwCmdInfo(cmdName As String, cmdInfo As String)
2262      wtcwMessage "«5»/tinfo " & cmdName & " «17»- " & cmdInfo
End Sub

Public Sub handleErr(ByVal sFunctionName As String)
          Dim sErrMsg As String
2264      sErrMsg = "Error"
2266      If Err.Number <> 0 Then sErrMsg = sErrMsg & " #«2»" & Err.Number & "«d»"
2268      sErrMsg = sErrMsg & " occurred in " & sFunctionName & ": «2»" & Err.Description
2270      If Erl > 0 Then sErrMsg = sErrMsg & "«d» @ line «2»" & Erl
2272      wtcwError sErrMsg
End Sub

Public Sub wtcwDebug(ByVal sMsg As String)
2274      wtcw sPluginName & " Debug", sMsg, 12, 17
End Sub

Private Sub wtcw(pluginName As String, sMsg As String, defaultColor As Long, secondaryColor As Long)
2276      If Not PluginSite2 Is Nothing Then
              'WriteToChatWindow "«" & secondaryColor & "»<{ «2»" & sPluginName & "«" & secondaryColor & "» }> «d»" & sMsg, defaultColor
2278          PluginSite2.Hooks.AddChatText "<{ " & pluginName & " }> " & stripColorTags(sMsg), defaultColor, chatWindow
2280      End If
End Sub

Private Function stripColorTags(msg As String) As String
2282      stripColorTags = msg
2284      Do While InStr(stripColorTags, "«")
2286          stripColorTags = Left(stripColorTags, InStr(stripColorTags, "«") - 1) & _
                  Mid(stripColorTags, InStr(stripColorTags, "»") + 1)
2288      Loop
End Function

'WriteToChatWindow taken from Solandra's plugin framework
Private Sub WriteToChatWindow(ByVal sMsg As String, lDefaultColor As Long)
2290      sMsg = Replace(sMsg, "«d»", "«" & lDefaultColor & "»")
          
          Dim iColor As Long, sText As String, Delimiter As String
2292      Delimiter = Left(sMsg, 1)
2294      If Right(sMsg, 1) <> vbLf Then sMsg = sMsg & vbLf
2296      If (Left(sMsg, 1) = Delimiter) Then
2298          Do
2300              sMsg = Right(sMsg, Len(sMsg) - 1)
2302              iColor = Val(sMsg)
2304              sMsg = Right(sMsg, Len(sMsg) - Len(Format(iColor)) - 1)
2306              If (InStr(sMsg, Delimiter)) Then
2308                  sText = Left(sMsg, InStr(sMsg, Delimiter) - 1)
2310                  PluginSite2.Hooks.AddChatTextRaw sText, iColor, chatWindow
2312                  sMsg = Right(sMsg, Len(sMsg) - Len(sText))
2314              Else
2316                  PluginSite2.Hooks.AddChatTextRaw sMsg, iColor, chatWindow
2318                  sMsg = ""
2320              End If
2322          Loop While Len(sMsg) > 0
2324      End If
End Sub

