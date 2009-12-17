VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Main"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements IPlugin2

Const WM_APPCOMMAND = &H319
Const HWND_BROADCAST = &HFFFF
Const APPCOMMAND_VOLUME_MUTE = &H80000
Const APPCOMMAND_VOLUME_DOWN = &H90000
Const APPCOMMAND_VOLUME_UP = &HA0000
Const APPCOMMAND_MEDIA_NEXTTRACK = &HB0000
Const APPCOMMAND_MEDIA_PREVIOUSTRACK = &HC0000
Const APPCOMMAND_MEDIA_STOP = &HD0000
Const APPCOMMAND_MEDIA_PLAY_PAUSE = &HEFFFF

Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long
Private Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long

Private MainView As View
Attribute MainView.VB_VarHelpID = -1
Private WithEvents CharStats As DecalFilters.CharacterStats
Attribute CharStats.VB_VarHelpID = -1
Private WithEvents DHS As DHS.HotkeySystem
Attribute DHS.VB_VarHelpID = -1

Private WithEvents btnPlayPause As DecalControls.PushButton
Attribute btnPlayPause.VB_VarHelpID = -1
Private WithEvents btnStop As DecalControls.PushButton
Attribute btnStop.VB_VarHelpID = -1
Private WithEvents btnNext As DecalControls.PushButton
Attribute btnNext.VB_VarHelpID = -1
Private WithEvents btnPrev As DecalControls.PushButton
Attribute btnPrev.VB_VarHelpID = -1
Private WithEvents btnVolUp As DecalControls.PushButton
Attribute btnVolUp.VB_VarHelpID = -1
Private WithEvents btnVolDn As DecalControls.PushButton
Attribute btnVolDn.VB_VarHelpID = -1
Private WithEvents btnMute As DecalControls.PushButton
Attribute btnMute.VB_VarHelpID = -1
Private txtVol As DecalControls.StaticText

Private MediaPlayers As New Collection

Private Sub IPlugin2_Initialize(ByVal Site As Decal.IPluginSite2)
2         On Error GoTo erh
4         Set PluginSite2 = Site
6         Set PluginSite = PluginSite2.PluginSite
          
8         Set CharStats = PluginSite2.object("services\DecalNet.NetService\DecalFilters.CharacterStats")
          
10        Set MainView = PluginSite.LoadView(FSO.OpenTextFile(App.Path & "\" & sPluginName & ".xml").ReadAll)
          
12        MainView.SetIcon 101, App.hInstance
          
14        Set btnPlayPause = MainView.Control("btnPlayPause")
16        Set btnStop = MainView.Control("btnStop")
18        Set btnNext = MainView.Control("btnNext")
20        Set btnPrev = MainView.Control("btnPrev")
22        Set btnVolUp = MainView.Control("btnVolUp")
24        Set btnVolDn = MainView.Control("btnVolDn")
26        Set btnMute = MainView.Control("btnMute")
28        Set txtVol = MainView.Control("txtVol")
          
          Dim MediaFile As TextStream, sTmp As String, sComment
30        Set MediaFile = FSO.OpenTextFile(App.Path & "\PlayerApps.ini")
32        Do While Not MediaFile.AtEndOfStream
34            sTmp = MediaFile.ReadLine
36            For Each sComment In Array("//", "#")
38                If InStr(sTmp, sComment) Then sTmp = Left(sTmp, InStr(sTmp, sComment) - 1)
40            Next
42            sTmp = Trim(sTmp)
44            If sTmp <> "" Then MediaPlayers.Add sTmp
46        Loop
48        MediaFile.Close
50        Set MediaFile = Nothing
          
52        Exit Sub
erh:
54        handleErr "IPlugin2_Initialize"
56        Resume Next
End Sub

Private Sub IPlugin2_Terminate()
58        On Error Resume Next
60        Set CharStats = Nothing
62        Set MainView = Nothing
64        Set DHS = Nothing
66        Set PluginSite = Nothing
End Sub

Private Sub Command(lCommand As Long)
68        On Error GoTo erh
          Dim MediaPlayer, hwnd As Long
70        For Each MediaPlayer In MediaPlayers
72            hwnd = FindWindow(MediaPlayer, vbNullString)
74            If hwnd <> 0 Then
76                SendMessage hwnd, WM_APPCOMMAND, hwnd, ByVal lCommand
78                Exit Sub
80            End If
82        Next MediaPlayer
84        wtcwError "Unable to locate a media player"
86        Exit Sub
erh:
88        handleErr "Command"
End Sub

Private Sub btnNext_Accepted(ByVal nID As Long)
90        Command APPCOMMAND_MEDIA_NEXTTRACK
End Sub

Private Sub btnPlayPause_Accepted(ByVal nID As Long)
92        Command APPCOMMAND_MEDIA_PLAY_PAUSE
End Sub

Private Sub btnPrev_Accepted(ByVal nID As Long)
94        Command APPCOMMAND_MEDIA_PREVIOUSTRACK
End Sub

Private Sub btnStop_Accepted(ByVal nID As Long)
96        Command APPCOMMAND_MEDIA_STOP
End Sub

Private Sub btnVolUp_Accepted(ByVal nID As Long)
98        Command APPCOMMAND_VOLUME_UP
End Sub

Private Sub btnVolDn_Accepted(ByVal nID As Long)
100       Command APPCOMMAND_VOLUME_DOWN
End Sub

Private Sub btnMute_Accepted(ByVal nID As Long)
102       Command APPCOMMAND_VOLUME_MUTE
End Sub

Private Sub DHS_HotkeyEvent(ByVal szEvent As String, pbEat As Boolean)
104       On Error GoTo erh
106       Select Case szEvent
              Case "MCtrl:PlayPause"
108               Command APPCOMMAND_MEDIA_PLAY_PAUSE
110               pbEat = True
112           Case "MCtrl:Stop"
114               Command APPCOMMAND_MEDIA_STOP
116               pbEat = True
118           Case "MCtrl:Prev"
120               Command APPCOMMAND_MEDIA_PREVIOUSTRACK
122               pbEat = True
124           Case "MCtrl:Next"
126               Command APPCOMMAND_MEDIA_NEXTTRACK
128               pbEat = True
130           Case "MCtrl:VolUp"
132               Command APPCOMMAND_VOLUME_UP
134               pbEat = True
136           Case "MCtrl:VolDn"
138               Command APPCOMMAND_VOLUME_DOWN
140               pbEat = True
142           Case "MCtrl:Mute"
144               Command APPCOMMAND_VOLUME_MUTE
146               pbEat = True
148       End Select
150       Exit Sub
erh:
152       handleErr "DHS_HotkeyEvent"
End Sub

Private Sub CheckHotKey(hkTitle As String, hkDesc As String)
154       If Not DHS.QueryHotkey(hkTitle) Then
              Dim newHotKey As New DHS.Hotkey
156           newHotKey.EventDescription = hkDesc
158           newHotKey.EventTitle = hkTitle
160           DHS.AddHotkey "MCtrl", newHotKey
162       End If
End Sub

Private Sub CharStats_Login(ByVal Character As Long)
164       On Error Resume Next
166       Set DHS = PluginSite.Plugin("{6B6B9FA8-37DE-4FA3-8C60-52BD6A2F9855}") 'Decal Hotkey System
168       On Error GoTo erh
170       If Not DHS Is Nothing Then
172           CheckHotKey "MCtrl:PlayPause", "Media Control: Play or Pause"
174           CheckHotKey "MCtrl:Stop", "Media Control: Stop"
176           CheckHotKey "MCtrl:Prev", "Media Control: Play previous song"
178           CheckHotKey "MCtrl:Next", "Media Control: Play next song"
180           CheckHotKey "MCtrl:VolUp", "Media Control: Increase Volume"
182           CheckHotKey "MCtrl:VolDn", "Media Control: Decrease Volume"
184           CheckHotKey "MCtrl:Mute", "Media Control: Mute"
186       End If
188       Exit Sub
erh:
190       handleErr "CharStats_Login"
End Sub
