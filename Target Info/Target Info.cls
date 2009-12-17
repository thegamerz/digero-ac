VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "TargetInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements Decal.IPlugin2
Implements DecalPlugins.IWindowsMessageSink

Private MainView As View

Private WithEvents NetEcho As DecalFilters.EchoFilter
Attribute NetEcho.VB_VarHelpID = -1
Private WithEvents WorldFilter As DecalFilters.World
Attribute WorldFilter.VB_VarHelpID = -1
Private WithEvents Hooks As Decal.ACHooks
Attribute Hooks.VB_VarHelpID = -1
Private WithEvents CharStats As DecalFilters.CharacterStats
Attribute CharStats.VB_VarHelpID = -1

Private WithEvents dh As DHS.HotkeySystem
Attribute dh.VB_VarHelpID = -1

Private WithEvents tm As DecalInput.Timer
Attribute tm.VB_VarHelpID = -1
Private WithEvents TimeLeft As DecalInput.Timer
Attribute TimeLeft.VB_VarHelpID = -1
Private WithEvents tmParseDelay As DecalInput.Timer
Attribute tmParseDelay.VB_VarHelpID = -1

Private nbkMain As DecalControls.Notebook
Private nbkHUD As DecalControls.Notebook
Private Const mainTabCount = 4, hudTabCount = 4

Private WithEvents chkShowTargetHUD As DecalControls.CheckBox
Attribute chkShowTargetHUD.VB_VarHelpID = -1
Private WithEvents chkTargetRightAlign As DecalControls.CheckBox
Attribute chkTargetRightAlign.VB_VarHelpID = -1
Private WithEvents chkTargetIconsOnly As DecalControls.CheckBox
Attribute chkTargetIconsOnly.VB_VarHelpID = -1
Private WithEvents chkTargetTextOnly As DecalControls.CheckBox
Attribute chkTargetTextOnly.VB_VarHelpID = -1
Private WithEvents chkTargetLifeOnly As DecalControls.CheckBox
Attribute chkTargetLifeOnly.VB_VarHelpID = -1
Private WithEvents chkTargetAttackHeight As DecalControls.CheckBox
Attribute chkTargetAttackHeight.VB_VarHelpID = -1
Private WithEvents chkTargetVulnsInline As DecalControls.CheckBox
Attribute chkTargetVulnsInline.VB_VarHelpID = -1
Private WithEvents TextColor As DecalControls.Choice
Attribute TextColor.VB_VarHelpID = -1
Private WithEvents TextColorLow As DecalControls.Choice
Attribute TextColorLow.VB_VarHelpID = -1
Private WithEvents BackgroundColor As DecalControls.Choice
Attribute BackgroundColor.VB_VarHelpID = -1

Private WithEvents chkShowVulnsHUD As DecalControls.CheckBox
Attribute chkShowVulnsHUD.VB_VarHelpID = -1
Private WithEvents chkVulnsRightAlign As DecalControls.CheckBox
Attribute chkVulnsRightAlign.VB_VarHelpID = -1
Private WithEvents chkVulnsIconsOnly As DecalControls.CheckBox
Attribute chkVulnsIconsOnly.VB_VarHelpID = -1
Private WithEvents chkVulnsTextOnly As DecalControls.CheckBox
Attribute chkVulnsTextOnly.VB_VarHelpID = -1
Private WithEvents chkVulnsAttach As DecalControls.CheckBox
Attribute chkVulnsAttach.VB_VarHelpID = -1
Private WithEvents chkVulnsAttackHeight As DecalControls.CheckBox
Attribute chkVulnsAttackHeight.VB_VarHelpID = -1
Private WithEvents chkVulnsBestOnly As DecalControls.CheckBox
Attribute chkVulnsBestOnly.VB_VarHelpID = -1
Private WithEvents chkVulnsColorCode As DecalControls.CheckBox
Attribute chkVulnsColorCode.VB_VarHelpID = -1
Private WithEvents textColorVulns As DecalControls.Choice
Attribute textColorVulns.VB_VarHelpID = -1
Private WithEvents backgroundColorVulns As DecalControls.Choice
Attribute backgroundColorVulns.VB_VarHelpID = -1

Private WithEvents chkShowSelfHUD As DecalControls.CheckBox
Attribute chkShowSelfHUD.VB_VarHelpID = -1
Private WithEvents chkSelfRightAlign As DecalControls.CheckBox
Attribute chkSelfRightAlign.VB_VarHelpID = -1
Private WithEvents chkSelfIconsOnly As DecalControls.CheckBox
Attribute chkSelfIconsOnly.VB_VarHelpID = -1
Private WithEvents chkSelfTextOnly As DecalControls.CheckBox
Attribute chkSelfTextOnly.VB_VarHelpID = -1
Private WithEvents chkSelfLifeOnly As DecalControls.CheckBox
Attribute chkSelfLifeOnly.VB_VarHelpID = -1
Private WithEvents chkSelfDebuffOnly As DecalControls.CheckBox
Attribute chkSelfDebuffOnly.VB_VarHelpID = -1
Private WithEvents textColorSelf As DecalControls.Choice
Attribute textColorSelf.VB_VarHelpID = -1
Private WithEvents backgroundColorSelf As DecalControls.Choice
Attribute backgroundColorSelf.VB_VarHelpID = -1

Private WithEvents dispTimerCheck As DecalControls.CheckBox
Attribute dispTimerCheck.VB_VarHelpID = -1
Private WithEvents edtLowBuffThresh As DecalControls.Edit
Attribute edtLowBuffThresh.VB_VarHelpID = -1

Private txtDHS As DecalControls.StaticText
Private WithEvents edtOutdoorRange As DecalControls.Edit
Attribute edtOutdoorRange.VB_VarHelpID = -1
Private WithEvents edtIndoorRange As DecalControls.Edit
Attribute edtIndoorRange.VB_VarHelpID = -1
Private WithEvents btnRangeHelp As DecalControls.PushButton
Attribute btnRangeHelp.VB_VarHelpID = -1
Private WithEvents selectStateChoice As DecalControls.Choice
Attribute selectStateChoice.VB_VarHelpID = -1
Private WithEvents selectNonStateChoice As DecalControls.Choice
Attribute selectNonStateChoice.VB_VarHelpID = -1

Private WithEvents btnUpdateDatabase As DecalControls.PushButton
Attribute btnUpdateDatabase.VB_VarHelpID = -1

Private WithEvents choDecorationType As DecalControls.Choice
Attribute choDecorationType.VB_VarHelpID = -1
Private WithEvents choDecorationColor As DecalControls.Choice
Attribute choDecorationColor.VB_VarHelpID = -1
Private WithEvents edtFontSize As DecalControls.Edit
Attribute edtFontSize.VB_VarHelpID = -1
Private WithEvents btnRelocate As DecalControls.PushButton
Attribute btnRelocate.VB_VarHelpID = -1
Private WithEvents btnClearSel As DecalControls.PushButton
Attribute btnClearSel.VB_VarHelpID = -1
Private txtVersionInfo As DecalControls.StaticText

Private loggedIn As Boolean

Private hudTarget As HUD
Private hudVulns As HUD
Private hudSelf As HUD

Private Const WM_LBUTTONUP = &H202
Private Const WM_LBUTTONDOWN = &H201
Private Const WM_LBUTTONDBLCLK = &H203
Private Const WM_MOUSEMOVE = &H200
Private Const WM_KEYDOWN = &H100
Private Const WM_KEYUP = &H101
Private Const MK_CONTROL = &H8

Private mouseDownPos As POINTAPI
Private originalPos As tagPOINT
Private moveToPos As POINTAPI
Private checkPos As POINTAPI

Private dctVulMonsters As Dictionary
Private dctNonVulMonsters As Dictionary

Private WithEvents httpDatabase As httpHandler
Attribute httpDatabase.VB_VarHelpID = -1
Private WithEvents DataParser As clsDataParser
Attribute DataParser.VB_VarHelpID = -1

Private sDatabaseURL As String

Public Type SpellWord
    iTime As Single
    iSpell As Long
End Type

Private colSpellWords As New Collection

Private Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long
Private Declare Function ScreenToClient Lib "user32" (ByVal HWND As Long, lpPoint As POINTAPI) As Long

Private Sub IPlugin2_Initialize(ByVal Site As Decal.IPluginSite2)
2         On Error GoTo erh
4         bLoadingSettings = False
6         loggedIn = False
          
8         Set PluginSite2 = Site
10        Set PluginSite = PluginSite2.PluginSite
          
12        Data.InitData
          
          ' Hook up windows message events
14        PluginSite2.RegisterSinks Me
          
16        Set NetEcho = PluginSite2.object("services\DecalNet.NetService\DecalFilters.EchoFilter")
18        Set WorldFilter = PluginSite2.object("services\DecalNet.NetService\DecalFilters.World")
20        Set Hub.WorldFilter = WorldFilter
22        Set CharStats = PluginSite2.object("services\DecalNet.NetService\DecalFilters.CharacterStats")
24        Set Hub.CharStats = CharStats
26        Set Hub.SpellF = PluginSite2.object("services\DecalNet.NetService\SpellFilter.Spells")
          
28        Set Hooks = PluginSite2.Hooks
          
30        Set tm = New DecalInput.Timer
32        Set TimeLeft = New DecalInput.Timer
34        Set tmParseDelay = New DecalInput.Timer
          
36        Set MainView = PluginSite.LoadView(FSO.OpenTextFile(App.Path & "\" & sPluginName & ".xml").ReadAll)
          
        
38        Set nbkMain = MainView.Control("nbkMain")
40        Set nbkHUD = MainView.Control("nbkHUD")
          
42        Set chkShowTargetHUD = MainView.Control("chkShowTargetHUD")
44        Set chkTargetRightAlign = MainView.Control("chkTargetRightAlign")
46        Set chkTargetIconsOnly = MainView.Control("chkTargetIconsOnly")
48        Set chkTargetTextOnly = MainView.Control("chkTargetTextOnly")
50        Set chkTargetLifeOnly = MainView.Control("chkTargetLifeOnly")
52        Set chkTargetAttackHeight = MainView.Control("chkTargetAttackHeight")
54        Set chkTargetVulnsInline = MainView.Control("chkTargetVulnsInline")
56        Set TextColor = MainView.Control("textColor")
58        Set TextColorLow = MainView.Control("textColorLow")
60        Set BackgroundColor = MainView.Control("backgroundColor")
          
62        Set chkShowVulnsHUD = MainView.Control("chkShowVulnsHUD")
64        Set chkVulnsRightAlign = MainView.Control("chkVulnsRightAlign")
66        Set chkVulnsIconsOnly = MainView.Control("chkVulnsIconsOnly")
68        Set chkVulnsTextOnly = MainView.Control("chkVulnsTextOnly")
70        Set chkVulnsAttach = MainView.Control("chkVulnsAttach")
72        Set chkVulnsAttackHeight = MainView.Control("chkVulnsAttackHeight")
74        Set chkVulnsBestOnly = MainView.Control("chkVulnsBestOnly")
76        Set chkVulnsColorCode = MainView.Control("chkVulnsColorCode")
78        Set textColorVulns = MainView.Control("textColorVulns")
80        Set backgroundColorVulns = MainView.Control("backgroundColorVulns")
          
82        Set chkShowSelfHUD = MainView.Control("chkShowSelfHUD")
84        Set chkSelfRightAlign = MainView.Control("chkSelfRightAlign")
86        Set chkSelfIconsOnly = MainView.Control("chkSelfIconsOnly")
88        Set chkSelfTextOnly = MainView.Control("chkSelfTextOnly")
90        Set chkSelfLifeOnly = MainView.Control("chkSelfLifeOnly")
92        Set chkSelfDebuffOnly = MainView.Control("chkSelfDebuffOnly")
94        Set textColorSelf = MainView.Control("textColorSelf")
96        Set backgroundColorSelf = MainView.Control("backgroundColorSelf")
          
98        Set lifeSpellLevel = MainView.Control("lifeSpellLevel")
100       Set creatureSpellLevel = MainView.Control("creatureSpellLevel")
102       Set dispTimerCheck = MainView.Control("dispTimerCheck")
104       Set edtLowBuffThresh = MainView.Control("edtLowBuffThresh")
          
106       Set txtDHS = MainView.Control("txtDHS")
108       Set edtOutdoorRange = MainView.Control("edtOutdoorRange")
110       Set edtIndoorRange = MainView.Control("edtIndoorRange")
112       Set btnRangeHelp = MainView.Control("btnRangeHelp")
114       Set selectStateChoice = MainView.Control("selectStateChoice")
116       Set selectNonStateChoice = MainView.Control("selectNonStateChoice")
          
118       Set txtVulnDbaseCount = MainView.Control("txtVulnDbaseCount")
120       VulnDbase.UpdateCtText
122       Set btnUpdateDatabase = MainView.Control("btnUpdateDatabase")
          
124       Set choDecorationType = MainView.Control("choDecorationType")
126       Set Hub.DecorationType = MainView.Control("choDecorationType")
128       Set choDecorationColor = MainView.Control("choDecorationColor")
130       Set Hub.DecorationColor = MainView.Control("choDecorationColor")
132       Set edtFontSize = MainView.Control("edtFontSize")
134       Set btnRelocate = MainView.Control("btnRelocate")
136       Set btnClearSel = MainView.Control("btnClearSel")
138       Set txtVersionInfo = MainView.Control("txtVersionInfo")
140       txtVersionInfo.Text = sPluginNameVer
          
142       Set dctVulMonsters = New Dictionary
144       dctVulMonsters.CompareMode = BinaryCompare
          
146       Set dctNonVulMonsters = New Dictionary
148       dctNonVulMonsters.CompareMode = BinaryCompare
          
150       Set hudTarget = New HUD
152       Set hudVulns = New HUD
154       Set hudSelf = New HUD
          
156       hudTarget.Pos = makePoint(100, 50)
158       hudSelf.Pos = makePoint(100, 150)
160       hudVulns.Pos = makePoint(100, 250)
162       sDatabaseURL = "http://ac.warcry.com/compendium/creature/creature_xml.php"
164       LoadSettings
          
166       Set httpDatabase = New httpHandler
168       Set DataParser = New clsDataParser
          
170       Exit Sub
erh:
172       handleErr "IPlugin2_Initialize"
174       Resume Next
End Sub

Private Sub CharStats_Login(ByVal Character As Long)
176       On Error GoTo erh
178       LoadSettings
          
180       hudTarget.Disable
182       hudVulns.Disable
184       hudSelf.Disable
          
186       tm.Start 1000
188       TimeLeft.Start 1000
          
190       On Error Resume Next
192       Set dh = PluginSite.Plugin("{6B6B9FA8-37DE-4FA3-8C60-52BD6A2F9855}") 'Decal Hotkey System
194       On Error GoTo erh
196       If dh Is Nothing Then
198           txtDHS.Text = "DHS Required for Hotkeys!"
200           txtDHS.TextColor = RGB(&HAA&, 0, 0)
202       Else
204           CheckHotKey "TInfo:NearestVul", "Target Info: Select nearest vulned creature"
206           CheckHotKey "TInfo:NearestNVul", "Target Info: Select nearest non-vulned creature"
208           CheckHotKey "TInfo:NextVul", "Target Info: Select next vulned creature"
210           CheckHotKey "TInfo:NextNVul", "Target Info: Select next non-vulned creature"
212           CheckHotKey "TInfo:PrevVul", "Target Info: Select previous vulned creature"
214           CheckHotKey "TInfo:PrevNVul", "Target Info: Select previous non-vulned creature"
216           CheckHotKey "TInfo:ClearSel", "Target Info: Clear debuffs for selected creature"
218           txtDHS.Text = "Use DHS to set up hotkeys"
220       End If
          
222       loggedIn = True
          
224       Exit Sub
erh:
226       handleErr "CharStats_Login"
End Sub

Private Sub CharStats_Logoff(ByVal LogoffType As DecalFilters.PlayerLogoffType)
228       On Error GoTo erh
230       If loggedIn Then
232           loggedIn = False
234           SaveSettings
236           Data.TerminateData
              
238           If Not hudTarget Is Nothing Then hudTarget.Dispose
240           If Not hudSelf Is Nothing Then hudSelf.Dispose
242           If Not hudVulns Is Nothing Then hudVulns.Dispose
244           Set hudTarget = Nothing
246           Set hudSelf = Nothing
248           Set hudVulns = Nothing
250       End If
252       Exit Sub
erh:
254       handleErr "CharStats_Logoff"
End Sub

Private Sub IPlugin2_Terminate()
256       On Error GoTo erh
258       loggedIn = False
260       Data.TerminateData
              
262       If Not hudTarget Is Nothing Then hudTarget.Dispose
264       If Not hudSelf Is Nothing Then hudSelf.Dispose
266       If Not hudVulns Is Nothing Then hudVulns.Dispose
268       Set hudTarget = Nothing
270       Set hudSelf = Nothing
272       Set hudVulns = Nothing
274       Set tmParseDelay = Nothing
276       Set httpDatabase = Nothing
278       Set DataParser = Nothing
280       Set MainView = Nothing
282       Set NetEcho = Nothing
284       Set SpellF = Nothing
286       Set dctVulMonsters = Nothing
288       Set dctNonVulMonsters = Nothing
290       Set tm = Nothing
292       Set TimeLeft = Nothing
294       Set Hooks = Nothing
296       Set dh = Nothing
298       Set WorldFilter = Nothing
300       Set CharStats = Nothing
302       Set PluginSite = Nothing
304       Exit Sub
erh:
306       handleErr "IPlugin2_Terminate"
End Sub

Private Function ColorMenu(ByRef iMenu As DecalControls.Choice) As Long
308       Select Case iMenu.Selected
              'ARGB
              Case 0: ColorMenu = 0 'Clear/vbCyan
310           Case 1: ColorMenu = &HFFFFFFFF 'vbWhite
312           Case 2: ColorMenu = &HFF000000 'vbBlack
314           Case 3: ColorMenu = &HFFFF4A4A 'vbRed
316           Case 4: ColorMenu = &HFF0000FF 'vbBlue
318           Case 5: ColorMenu = &HFF00FF00 'vbGreen
320           Case 6: ColorMenu = &HFFFF00FF 'vbMagenta
322           Case 7: ColorMenu = &HFFFFFF00 'vbYellow
324       End Select
End Function

Private Function BackgroundColorMenu(ByRef iMenu As DecalControls.Choice) As Long
326       BackgroundColorMenu = ColorMenu(iMenu)
328       If (BackgroundColorMenu And &HFF000000) = &HFF000000 Then
330           BackgroundColorMenu = &H44FFFFFF And BackgroundColorMenu
332       End If
End Function

'******************************************************************************
'** Control Event Handlers ****************************************************
'******************************************************************************

'** HUD -> Target *************************************************************

Private Sub chkShowTargetHUD_Change(ByVal nID As Long, ByVal bChecked As Boolean)
334       On Error GoTo erh
336       If bChecked Then
338           wtcwMessage "Target Debuff HUD Enabled"
340       Else
342           hudTarget.Disable
344           wtcwMessage "Target Debuff HUD Disabled"
346       End If
          'SaveSettings
348       RenderHUDs Hooks.CurrentSelection
350       Exit Sub
erh:
352       handleErr "chkShowTargetHUD_Change"
End Sub

Private Sub chkTargetRightAlign_Change(ByVal nID As Long, ByVal bChecked As Boolean)
354       On Error GoTo erh
356       hudTarget.SetAlignRight bChecked
358       SetVulnsAttach
          'SaveSettings
360       RenderHUDs Hooks.CurrentSelection
362       Exit Sub
erh:
364       handleErr "chkTargetRightAlign_Change"
End Sub

Private Sub chkTargetIconsOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
366       On Error GoTo erh
368       If bChecked Then
370           chkTargetTextOnly.Checked = False
372           hudTarget.TextOnly = False
374       End If
376       hudTarget.IconsOnly = bChecked
          'SaveSettings
378       RenderHUDs Hooks.CurrentSelection
380       Exit Sub
erh:
382       handleErr "chkTargetIconsOnly_Change"
End Sub

Private Sub chkTargetTextOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
384       On Error GoTo erh
386       If bChecked Then
388           chkTargetIconsOnly.Checked = False
390           hudTarget.IconsOnly = False
392       End If
394       hudTarget.TextOnly = bChecked
          'SaveSettings
396       RenderHUDs Hooks.CurrentSelection
398       Exit Sub
erh:
400       handleErr "chkTargetTextOnly_Change"
End Sub

Private Sub chkTargetLifeOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
402       On Error GoTo erh
404       hudTarget.LifeOnly = bChecked
          'SaveSettings
406       RenderHUDs Hooks.CurrentSelection
408       Exit Sub
erh:
410       handleErr "chkTargetLifeOnly_Change"
End Sub

Private Sub chkTargetAttackHeight_Change(ByVal nID As Long, ByVal bChecked As Boolean)
412       On Error GoTo erh
414       hudTarget.ShowBestAttackHeight = bChecked
          'SaveSettings
416       RenderHUDs Hooks.CurrentSelection
418       Exit Sub
erh:
420       handleErr "chkTargetAttackHeight_Change"
End Sub

Private Sub chkTargetVulnsInline_Change(ByVal nID As Long, ByVal bChecked As Boolean)
422       On Error GoTo erh
424       hudTarget.RecommendVulns = bChecked
          'SaveSettings
426       RenderHUDs Hooks.CurrentSelection
428       Exit Sub
erh:
430       handleErr "chkTargetVulnsInline_Change"
End Sub

Private Sub textColor_Change(ByVal nID As Long, ByVal nIndex As Long)
432       On Error GoTo erh
434       hudTarget.TextColor = ColorMenu(TextColor)
          'SaveSettings
436       RenderHUDs Hooks.CurrentSelection
438       Exit Sub
erh:
440       handleErr "textColor_Change"
End Sub

Private Sub textColorLow_Change(ByVal nID As Long, ByVal nIndex As Long)
442       On Error GoTo erh
444       hudTarget.LowTextColor = ColorMenu(TextColorLow)
          'SaveSettings
446       RenderHUDs Hooks.CurrentSelection
448       Exit Sub
erh:
450       handleErr "textColorLow_Change"
End Sub

Private Sub backgroundColor_Change(ByVal nID As Long, ByVal nIndex As Long)
452       On Error GoTo erh
454       hudTarget.BackgroundColor = BackgroundColorMenu(BackgroundColor)
          'SaveSettings
456       RenderHUDs Hooks.CurrentSelection
458       Exit Sub
erh:
460       handleErr "backgroundColor_Change"
End Sub

'** HUD -> Vulns **************************************************************

Private Sub chkShowVulnsHUD_Change(ByVal nID As Long, ByVal bChecked As Boolean)
462       On Error GoTo erh
464       If bChecked Then
466           wtcwMessage "Vulns Debuff HUD Enabled"
468       Else
470           wtcwMessage "Vulns Debuff HUD Disabled"
472       End If
          'SaveSettings
474       RenderHUDs Hooks.CurrentSelection
476       Exit Sub
erh:
478       handleErr "chkShowVulnsHUD_Change"
End Sub

Private Sub chkVulnsRightAlign_Change(ByVal nID As Long, ByVal bChecked As Boolean)
480       On Error GoTo erh
482       hudVulns.AlignRight = bChecked
484       SetVulnsAttach
          'SaveSettings
486       RenderHUDs Hooks.CurrentSelection
488       Exit Sub
erh:
490       handleErr "chkVulnsRightAlign_Change"
End Sub

Private Sub chkVulnsIconsOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
492       On Error GoTo erh
494       If bChecked Then
496           chkVulnsTextOnly.Checked = False
498           hudVulns.TextOnly = False
500       End If
502       hudVulns.IconsOnly = bChecked
          'SaveSettings
504       RenderHUDs Hooks.CurrentSelection
506       Exit Sub
erh:
508       handleErr "chkVulnsIconsOnly_Change"
End Sub

Private Sub chkVulnsTextOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
510       On Error GoTo erh
512       If bChecked Then
514           chkVulnsIconsOnly.Checked = False
516           hudVulns.IconsOnly = False
518       End If
520       hudVulns.TextOnly = bChecked
          'SaveSettings
522       RenderHUDs Hooks.CurrentSelection
524       Exit Sub
erh:
526       handleErr "chkVulnsTextOnly_Change"
End Sub

Private Sub chkVulnsAttach_Change(ByVal nID As Long, ByVal bChecked As Boolean)
528       On Error GoTo erh
530       SetVulnsAttach
          'SaveSettings
532       If Not bChecked Then hudVulns.SetPos makePoint(hudVulns.Pos.x, hudVulns.Pos.y + 18)
534       RenderHUDs Hooks.CurrentSelection
536       Exit Sub
erh:
538       handleErr "chkVulnsAttach_Change"
End Sub

Private Sub SetVulnsAttach()
540       On Error GoTo erh
542       If chkVulnsAttach.Checked Then
544           If chkTargetRightAlign.Checked Then
546               hudVulns.AlignRight = False
548               hudVulns.Pos = makePoint(hudTarget.RightEdge + 2, hudTarget.Pos.y - 18)
550           Else
552               hudVulns.AlignRight = True
554               hudVulns.RightEdge = hudTarget.Pos.x - 2
556               hudVulns.Pos = makePoint(hudVulns.Pos.x, hudTarget.Pos.y - 18)
558           End If
560           hudVulns.ShowName = False
562       Else
564           hudVulns.SetAlignRight chkVulnsRightAlign.Checked
566           hudVulns.ShowName = True
568       End If
570       Exit Sub
erh:
572       handleErr "SetVulnsAttach"
End Sub

Private Sub chkVulnsAttackHeight_Change(ByVal nID As Long, ByVal bChecked As Boolean)
574       On Error GoTo erh
576       hudVulns.ShowBestAttackHeight = bChecked
          'SaveSettings
578       RenderHUDs Hooks.CurrentSelection
580       Exit Sub
erh:
582       handleErr "chkVulnsAttackHeight_Change"
End Sub

Private Sub chkVulnsBestOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
584       On Error GoTo erh
586       hudVulns.OnlyBestVulns = bChecked
588       hudTarget.OnlyBestVulns = bChecked
          'SaveSettings
590       RenderHUDs Hooks.CurrentSelection
592       Exit Sub
erh:
594       handleErr "chkVulnsBestOnly_Change"
End Sub

Private Sub chkVulnsColorCode_Change(ByVal nID As Long, ByVal bChecked As Boolean)
596       On Error GoTo erh
598       hudVulns.ColorCodeVulns = bChecked
600       hudTarget.ColorCodeVulns = bChecked
          'SaveSettings
602       RenderHUDs Hooks.CurrentSelection
604       Exit Sub
erh:
606       handleErr "chkVulnsColorCode_Change"
End Sub

Private Sub textColorVulns_Change(ByVal nID As Long, ByVal nIndex As Long)
608       On Error GoTo erh
610       hudVulns.TextColor = ColorMenu(textColorVulns)
612       hudVulns.LowTextColor = ColorMenu(textColorVulns)
          'SaveSettings
614       RenderHUDs Hooks.CurrentSelection
616       Exit Sub
erh:
618       handleErr "textColorVulns_Change"
End Sub

Private Sub backgroundColorVulns_Change(ByVal nID As Long, ByVal nIndex As Long)
620       On Error GoTo erh
622       hudVulns.BackgroundColor = BackgroundColorMenu(backgroundColorVulns)
          'SaveSettings
624       RenderHUDs Hooks.CurrentSelection
626       Exit Sub
erh:
628       handleErr "backgroundColorVulns_Change"
End Sub

'** HUD -> Self **************************************************************

Private Sub chkShowSelfHUD_Change(ByVal nID As Long, ByVal bChecked As Boolean)
630       On Error GoTo erh
632       If bChecked Then
634           wtcwMessage "Self Debuff HUD Enabled"
636       Else
638           wtcwMessage "Self Debuff HUD Disabled"
640       End If
          'SaveSettings
642       RenderHUDs Hooks.CurrentSelection
644       Exit Sub
erh:
646       handleErr "chkShowSelfHUD_Change"
End Sub

Private Sub chkSelfRightAlign_Change(ByVal nID As Long, ByVal bChecked As Boolean)
648       On Error GoTo erh
650       hudSelf.SetAlignRight bChecked
          'SaveSettings
652       RenderHUDs Hooks.CurrentSelection
654       Exit Sub
erh:
656       handleErr "chkSelfRightAlign_Change"
End Sub

Private Sub chkSelfIconsOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
658       On Error GoTo erh
660       If bChecked Then
662           chkSelfTextOnly.Checked = False
664           hudSelf.TextOnly = False
666       End If
668       hudSelf.IconsOnly = bChecked
          'SaveSettings
670       RenderHUDs Hooks.CurrentSelection
672       Exit Sub
erh:
674       handleErr "chkSelfIconsOnly_Change"
End Sub

Private Sub chkSelfTextOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
676       On Error GoTo erh
678       If bChecked Then
680           chkSelfIconsOnly.Checked = False
682           hudSelf.IconsOnly = False
684       End If
686       hudSelf.TextOnly = bChecked
          'SaveSettings
688       RenderHUDs Hooks.CurrentSelection
690       Exit Sub
erh:
692       handleErr "chkSelfTextOnly_Change"
End Sub

Private Sub chkSelfLifeOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
694       On Error GoTo erh
696       hudSelf.LifeOnly = bChecked
          'SaveSettings
698       RenderHUDs Hooks.CurrentSelection
700       Exit Sub
erh:
702       handleErr "chkSelfLifeOnly_Change"
End Sub

Private Sub chkSelfDebuffOnly_Change(ByVal nID As Long, ByVal bChecked As Boolean)
704       On Error GoTo erh
          'SaveSettings
706       RenderHUDs Hooks.CurrentSelection
708       Exit Sub
erh:
710       handleErr "chkSelfDebuffOnly_Change"
End Sub

Private Sub textColorSelf_Change(ByVal nID As Long, ByVal nIndex As Long)
712       On Error GoTo erh
714       hudSelf.TextColor = ColorMenu(textColorSelf)
716       hudSelf.LowTextColor = ColorMenu(textColorSelf)
          'SaveSettings
718       RenderHUDs Hooks.CurrentSelection
720       Exit Sub
erh:
722       handleErr "textColorSelf_Change"
End Sub

Private Sub backgroundColorSelf_Change(ByVal nID As Long, ByVal nIndex As Long)
724       On Error GoTo erh
726       hudSelf.BackgroundColor = BackgroundColorMenu(backgroundColorSelf)
          'SaveSettings
728       RenderHUDs Hooks.CurrentSelection
730       Exit Sub
erh:
732       handleErr "backgroundColorSelf_Change"
End Sub

'** HUD -> Timers *************************************************************

Private Sub dispTimerCheck_Change(ByVal nID As Long, ByVal bChecked As Boolean)
734       On Error GoTo erh
736       hudTarget.ShowTimer = bChecked
738       hudSelf.ShowTimer = bChecked
          'SaveSettings
740       RenderHUDs Hooks.CurrentSelection
742       Exit Sub
erh:
744       handleErr "dispTimerCheck_Change"
End Sub

Private Sub edtLowBuffThresh_End(ByVal nID As Long, ByVal bSuccess As Boolean)
746       On Error GoTo erh
748       LowBuffThresh = Int(Val(edtLowBuffThresh.Text))
750       edtLowBuffThresh.Text = LowBuffThresh
          'SaveSettings
752       Exit Sub
erh:
754       handleErr "edtLowBuffThresh_End"
End Sub

'** Cycle *********************************************************************

Private Sub edtOutdoorRange_End(ByVal nID As Long, ByVal bSuccess As Boolean)
756       On Error GoTo erh
758       edtOutdoorRange.Text = Int(Val(edtOutdoorRange.Text))
760       If Val(edtOutdoorRange.Text) < 1 Or Val(edtOutdoorRange.Text) > 150 Then
762           wtcwWarning "Please enter a range between 񣴅�8� and 񣴅50�8� (default is 񣴋5�8�)"
764           edtOutdoorRange.Text = "75"
766       End If
          'SaveSettings
768       Exit Sub
erh:
770       handleErr "edtOutdoorRange_End"
End Sub

Private Sub edtIndoorRange_End(ByVal nID As Long, ByVal bSuccess As Boolean)
772       On Error GoTo erh
774       edtIndoorRange.Text = Int(Val(edtIndoorRange.Text))
776       If Val(edtIndoorRange.Text) < 1 Or Val(edtIndoorRange.Text) > 150 Then
778           wtcwWarning "Please enter a range between 񣴅�8� and 񣴅50�8� (default is 񣴆5�8�)"
780           edtIndoorRange.Text = "25"
782       End If
          'SaveSettings
784       Exit Sub
erh:
786       handleErr "edtIndoorRange_End"
End Sub

Private Sub btnRangeHelp_Accepted(ByVal nID As Long)
788       On Error GoTo erh
790       wtcwMessage "This option lets you customize the maximum distance that cycling vulned/nonvulned creatures will select a creature"
792       wtcwMessage "The edge of the outdoor radar is 񣴋5�14� and the edge of the indoor radar is 񣴆5"
794       Exit Sub
erh:
796       handleErr "btnRangeHelp_Accepted"
End Sub

Private Sub selectNonStateChoice_Change(ByVal nID As Long, ByVal nIndex As Long)
    'SaveSettings
End Sub

Private Sub selectStateChoice_Change(ByVal nID As Long, ByVal nIndex As Long)
    'SaveSettings
End Sub

'** Misc **********************************************************************

Private Sub choDecorationType_Change(ByVal nID As Long, ByVal nIndex As Long)
798       On Error GoTo erh
          'SaveSettings
800       RenderHUDs Hooks.CurrentSelection
802       Exit Sub
erh:
804       handleErr "choDecorationType_Change"
End Sub

Private Sub choDecorationColor_Change(ByVal nID As Long, ByVal nIndex As Long)
806       On Error GoTo erh
          'SaveSettings
808       RenderHUDs Hooks.CurrentSelection
810       Exit Sub
erh:
812       handleErr "choDecorationColor_Change"
End Sub

Private Sub edtFontSize_End(ByVal nID As Long, ByVal bSuccess As Boolean)
814       On Error GoTo erh
          Dim lSize As Long
816       lSize = Val(edtFontSize.Text)
818       If lSize < 8 Or lSize > 24 Then
820           lSize = 12
822           wtcwWarning "Please enter a size between 8 and 24"
824       End If
826       edtFontSize.Text = lSize
828       hudTarget.FontSize = lSize
830       hudVulns.FontSize = lSize
832       hudSelf.FontSize = lSize
          'SaveSettings
834       RenderHUDs Hooks.CurrentSelection
836       Exit Sub
erh:
838       handleErr "edtFontSize_End"
End Sub

Private Sub btnClearSel_Accepted(ByVal nID As Long)
840       On Error GoTo erh
842       ClearMonsterInfo Hooks.CurrentSelection
844       Exit Sub
erh:
846       handleErr "btnClearSel_Accepted"
End Sub

Private Sub btnRelocate_Accepted(ByVal nID As Long)
848       Relocate
End Sub

Private Sub Relocate()
850       On Error GoTo erh

852       hudTarget.Pos = makePoint(100, 100)
854       hudSelf.Pos = makePoint(100, 200)
856       hudVulns.Pos = makePoint(100, 300)
858       SetVulnsAttach
          'SaveSettings
860       RenderHUDs Hooks.CurrentSelection
862       wtcwMessage "The HUD(s) should now be in a visible area of the screen"
864       If Not chkShowTargetHUD.Checked Then
866           wtcwMessage "(Note: The Target HUD is currently disabled, type �2�/tinfo show�14� to enable the HUD)"
868       ElseIf Hooks.CurrentSelection = 0 Then
870           wtcwMessage "(Note: You don't have anything selected, and the Target HUD only displays when you have a person or creature selected)"
872       End If
874       Exit Sub
erh:
876       handleErr "Relocate"
End Sub

'******************************************************************************
'** Vuln/NonVuln Dictionary Functions *****************************************
'******************************************************************************

Private Sub addVulned(GUID As Long, ParticleEffect As Long)
878       On Error GoTo erh
          Dim tmpMonster As New clsMonster, wObj As WorldObject
          
880       Set wObj = WorldFilter(GUID)
882       If Not tmpMonster.ValidEffect(ParticleEffect) Or wObj Is Nothing Then
884           Set tmpMonster = Nothing
886           Exit Sub
888       End If
          
890       If dctVulMonsters.Exists(GUID) Then
892           Set tmpMonster = dctVulMonsters(GUID)
894       Else
896           tmpMonster.Init wObj
898       End If
          
900       tmpMonster.DebuffTime(ParticleEffect) = Now
902       Set dctVulMonsters(GUID) = tmpMonster
904       Set tmpMonster = Nothing
906       Set wObj = Nothing
          
908       removeNonVulned GUID
910       Exit Sub
erh:
912       handleErr "addVulned"
End Sub

Private Sub addNonVulned(GUID As Long)
914       On Error GoTo erh
          Dim tmpMonster As New clsMonster, wObj As WorldObject
          
916       Set wObj = WorldFilter(GUID)
918       If Not (dctNonVulMonsters.Exists(GUID) Or wObj Is Nothing) Then
920           Set tmpMonster = New clsMonster
922           tmpMonster.Init wObj
924           dctNonVulMonsters.add GUID, tmpMonster
926       End If
928       Set tmpMonster = Nothing
930       Set wObj = Nothing
932       Exit Sub
erh:
934       handleErr "addNonVulned"
End Sub

Private Sub removeVulned(GUID As Long)
936       On Error GoTo erh
938       If dctVulMonsters.Exists(GUID) Then dctVulMonsters.remove GUID
940       Exit Sub
erh:
942       handleErr "removeVulned"
End Sub

Private Sub removeNonVulned(GUID As Long)
944       On Error GoTo erh
946       If dctNonVulMonsters.Exists(GUID) Then dctNonVulMonsters.remove GUID
948       Exit Sub
erh:
950       handleErr "removeNonVulned"
End Sub

Private Sub ClearMonsterInfo(GUID As Long)
952       On Error GoTo erh
          
          Dim wObj As WorldObject
954       Set wObj = WorldFilter(GUID)
          
956       If dctVulMonsters.Exists(GUID) Then
958           removeVulned GUID
960           If Not wObj Is Nothing Then
962               addNonVulned GUID
964               wtcwMessage "Debuffs cleared for �2�" & wObj.name
966           Else
968               wtcwMessage "Debuffs cleared for �2�<Unrecognized Monster>"
970           End If
972           RenderHUDs Hooks.CurrentSelection
974       ElseIf Not wObj Is Nothing Then
976           If wObj.ObjectClass = ePlayer Or wObj.ObjectClass = eMonster Then _
                      wtcwWarning "�2�" & wObj.name & "�8� doesn't have any debuffs to clear!"
978       End If
980       Exit Sub
erh:
982       handleErr "ClearMonsterInfo"
End Sub

Private Sub WorldFilter_CreateObject(ByVal pObject As DecalFilters.IWorldObject)
984       On Error GoTo erh
986       If pObject.ObjectClass = eMonster Or pObject.ObjectClass = ePlayer Then addNonVulned pObject.GUID
988       Exit Sub
erh:
990       handleErr "WorldFilter_CreateObject"
End Sub

Private Sub WorldFilter_ReleaseObject(ByVal pObject As DecalFilters.IWorldObject)
992       On Error GoTo erh
994       removeNonVulned pObject.GUID
996       Exit Sub
erh:
998       handleErr "WorldFilter_ReleaseObject"
End Sub

Private Sub TimeLeft_Timeout(ByVal Source As DecalInput.IDecalTimer)
1000      On Error GoTo erh
          Dim Monster
1002      For Each Monster In dctVulMonsters.Items
1004          If Monster.debuffs.Count > 0 Then
1006              Set dctVulMonsters(Monster.MonsterGUID) = Monster
1008          Else
1010              dctVulMonsters.remove Monster.MonsterGUID
1012              addNonVulned Monster.MonsterGUID
1014          End If
1016      Next Monster
          
          'Clean up colSpellWords
          Dim i As Long, swSpellWord As SpellWord
1018      i = 1
1020      Do While i <= colSpellWords.Count
1022          swSpellWord = colSpellWords(i)
1024          If Timer - swSpellWord.iTime > 6 Or Timer - swSpellWord.iTime < 0 Then
1026              colSpellWords.remove i
1028          End If
1030          i = i + 1
1032      Loop
1034      Exit Sub
erh:
1036      handleErr "TimeLeft_Timeout"
End Sub

Private Sub NetEcho_EchoMessage(ByVal pMsg As DecalNet.IMessage)
1038      On Error GoTo erh
          Dim swSpellWord As SpellWord, swClosestMatch As SpellWord, Effect As Long
1040      Select Case pMsg.Type
              Case &H2BB& 'Creature Message (Local Chat)
1042              If pMsg.value("type") = 17 Then 'Spell words
1044                  Effect = SpellWordsToParEff(pMsg.value("text"))
1046                  If Effect <> 0 Then
1048                      swSpellWord.iSpell = Effect
1050                      swSpellWord.iTime = Timer
1052                      colSpellWords.add swSpellWord
1054                  End If
1056              End If
          
1058          Case &HF755& 'Apply Visual/Sound Effect
                  Dim arrSpellWords() As String, i As Long, j As Long, iClosestMatch As Long, bUpdateEffect As Boolean, dCastTime As Single
                  
1060              Effect = pMsg.value("effect")
1062              arrSpellWords = Split(DebuffInfo(Effect).SpellWords, ",")
1064              If UBound(arrSpellWords) > 0 And colSpellWords.Count > 0 Then
1066                  bUpdateEffect = False
1068                  For j = 0 To UBound(arrSpellWords)
                          Dim parEff As Long
1070                      parEff = SpellWordsToParEff(arrSpellWords(j))
1072                      For i = 1 To colSpellWords.Count
1074                          If colSpellWords(i).iSpell = parEff Then
1076                              bUpdateEffect = True
1078                              Exit For
1080                          End If
1082                      Next
1084                      If bUpdateEffect Then Exit For
1086                  Next
                      
1088                  If bUpdateEffect Then
1090                      swClosestMatch = colSpellWords(i)
1092                      iClosestMatch = i
1094                      For i = iClosestMatch + 1 To colSpellWords.Count
1096                          For j = 0 To UBound(arrSpellWords)
1098                              If colSpellWords(i).iSpell = SpellWordsToParEff(arrSpellWords(j)) Then
1100                                  swSpellWord = colSpellWords(i)
1102                                  Select Case DebuffInfo(swSpellWord.iSpell).Type
                                          Case dbfCrit: dCastTime = 2#
1104                                      Case dbfLife: dCastTime = 2.75
1106                                  End Select
1108                                  If Abs(Timer - swSpellWord.iTime - dCastTime) < Abs(Timer - swClosestMatch.iTime - dCastTime) Then
1110                                      swClosestMatch = swSpellWord
1112                                      iClosestMatch = i
1114                                  End If
1116                                  Exit For
1118                              End If
1120                          Next
1122                      Next
1124                      Effect = swClosestMatch.iSpell
1126                      colSpellWords.remove iClosestMatch
1128                  End If
1130              End If
1132              addVulned pMsg.value("object"), Effect
                  
1134      End Select
1136      Exit Sub
erh:
1138      handleErr "NetEcho_EchoMessage"
End Sub

'******************************************************************************
'** HUD-Related Functions *****************************************************
'******************************************************************************

Private Function IWindowsMessageSink_WindowMessage(ByVal HWND As Long, ByVal uMsg As Integer, ByVal wParam As Long, ByVal lParam As Long) As Boolean
1140      On Error GoTo erh
1142      If loggedIn Then
1144          Select Case uMsg
                  Case WM_LBUTTONDOWN
1146                  Call GetCursorPos(checkPos)
1148                  ScreenToClient PluginSite.HWND, checkPos
1150                  If hudSelf.HitCheck(checkPos.x, checkPos.y) And chkShowSelfHUD.Checked Then
1152                      hudSelf.MouseOnHUD = True
1154                      hudTarget.MouseOnHUD = False
1156                      hudVulns.MouseOnHUD = False
1158                      mouseDownPos = checkPos
1160                      originalPos = hudSelf.Pos
1162                  ElseIf hudTarget.HitCheck(checkPos.x, checkPos.y) And chkShowTargetHUD.Checked Then
1164                      hudTarget.MouseOnHUD = True
1166                      hudSelf.MouseOnHUD = False
1168                      hudVulns.MouseOnHUD = False
1170                      mouseDownPos = checkPos
1172                      originalPos = hudTarget.Pos
1174                  ElseIf hudVulns.HitCheck(checkPos.x, checkPos.y) And chkShowVulnsHUD.Checked And Not chkVulnsAttach.Checked Then
1176                      hudVulns.MouseOnHUD = True
1178                      hudTarget.MouseOnHUD = False
1180                      hudSelf.MouseOnHUD = False
1182                      mouseDownPos = checkPos
1184                      originalPos = hudVulns.Pos
1186                  End If
              
1188              Case WM_MOUSEMOVE
1190                  If hudSelf.MouseOnHUD Or hudTarget.MouseOnHUD Or hudVulns.MouseOnHUD Then
1192                      Call GetCursorPos(moveToPos)
1194                      ScreenToClient PluginSite.HWND, moveToPos
                          Dim newPos As DecalPlugins.tagPOINT
1196                      newPos.x = originalPos.x + (moveToPos.x - mouseDownPos.x)
1198                      newPos.y = originalPos.y + (moveToPos.y - mouseDownPos.y)
1200                      If hudSelf.MouseOnHUD Then
1202                          hudSelf.SetPos newPos
1204                      ElseIf hudTarget.MouseOnHUD Then
1206                          hudTarget.SetPos newPos
1208                          SetVulnsAttach
1210                      Else
1212                          hudVulns.SetPos newPos
1214                      End If
1216                  End If
              
1218              Case WM_LBUTTONUP
1220                  If hudSelf.MouseOnHUD Or hudTarget.MouseOnHUD Or hudVulns.MouseOnHUD Then
1222                      hudTarget.MouseOnHUD = False
1224                      hudSelf.MouseOnHUD = False
1226                      hudVulns.MouseOnHUD = False
                          'SaveSettings
1228                  End If
              
1230          End Select
1232      End If
1234      Exit Function
erh:
1236      handleErr "IWindowsMessageSink_WindowMessage"
End Function

Private Sub IWindowsMessageSink_WindowMessageEnd()
    'This space intentionally left blank
End Sub

Private Sub tm_Timeout(ByVal Source As DecalInput.IDecalTimer)
1238      On Error GoTo erh
1240      RenderHUDs Hooks.CurrentSelection
1242      Exit Sub
erh:
1244      handleErr "tm_Timeout"
End Sub

Private Sub Hooks_ObjectSelected(ByVal lGUID As Long)
1246      On Error GoTo erh
1248      RenderHUDs lGUID
1250      Exit Sub
erh:
1252      handleErr "Hooks_ObjectSelected"
End Sub

'Private Sub CharStats_ChangeEnchantments(ByVal Change As DecalFilters.PlayerAddRemoveType, ByVal Enchantment As DecalFilters.IEnchantment)
'    On Error GoTo erh
'    If Change = pevtAdd Then
'        'msgbox "Add enchantment"
'        Dim Spell As Spell
'        Set Spell = SpellF.SpellByID(Enchantment.SpellID)
'        If Not Spell Is Nothing Then
'            If CBool(Spell.Flags And &H10) Then 'Debuff
'                debuffs.add Enchantment, Spell
'            End If
'        End If
'    Else
'        debuffs.remove Enchantment
'    End If
'    Exit Sub
'erh:
'    handleErr "CharStats_ChangeEnchantments"
'End Sub

Private Sub RenderHUDs(targetGUID As Long)
1254      On Error GoTo erh
1256      If loggedIn Then
              Dim tmpMonster As clsMonster
              
1258          If dctVulMonsters.Exists(targetGUID) Then
1260              Set tmpMonster = dctVulMonsters(targetGUID)
1262          ElseIf dctNonVulMonsters.Exists(targetGUID) Then
1264              Set tmpMonster = dctNonVulMonsters(targetGUID)
1266          Else
1268              Set tmpMonster = Nothing
1270          End If
              
              'Target HUD
1272          If chkShowTargetHUD.Checked And Not tmpMonster Is Nothing Then
1274              hudTarget.Render tmpMonster
1276          Else
1278              hudTarget.Disable
1280          End If
              
              'Vulns HUD
1282          If chkShowVulnsHUD.Checked And Not tmpMonster Is Nothing And _
                      (chkShowTargetHUD.Checked Or Not chkVulnsAttach.Checked) Then
1284              If tmpMonster.MonsterType = eMonster Then
1286                  hudVulns.Render tmpMonster
1288              Else
1290                  hudVulns.Disable
1292              End If
1294          Else
1296              hudVulns.Disable
1298          End If
              
              'Self HUD
      '        If chkShowSelfHUD.Checked Then
      '            Dim ench As Enchantment, Ench2 As Enchantment
      '            Dim Spell As Spell, sTimeLeft As String, sSpellName As String
      '
      '    '        Dim colActiveDebuffs As New Collection, bAdded As Boolean, bActive As Boolean
      '    '
      '    ''        Dim activeSpells As New Dictionary
      '    '
      '    '        Dim i As Long, j As Long
      '    '        For i = 0 To CharStats.EnchantmentCount - 1
      '    '            Set ench = CharStats.Enchantment(i)
      '    '            Set Spell = SpellF.SpellByID(ench.SpellID)
      '    '            If Not Spell Is Nothing And ench.TimeRemaining >= 0 Then
      '    '                If (Spell.SpellSchool = 2 Or Not chkSelfLifeOnly.Checked) And CBool(Spell.Flags And &H10) Then
      '    '                    'Negative Spell
      '    '
      '    ''                    If activeSpells.Exists(Ench.Family) Then
      '    ''                        ' Spell from the same family already exists
      '    ''                        Set Ench2 = activeSpells(Ench.Family)
      '    ''                        If Ench.Adjustment > Ench2.Adjustment Or (Ench.Adjustment = Ench2.Adjustment And Ench.Layer > Ench2.Layer) Then
      '    ''                            Set activeSpells(Ench.Family) = Ench
      '    ''                        End If
      '    ''                    Else
      '    ''                        Set activeSpells(Ench.Family) = Ench
      '    ''                    End If
      '    '
      '    '
      '    '
      '    '                    bAdded = False
      '    '
      '    '                    'wtcwDebug Spell.name & ": (F:" & Ench.Family & ") (Adj:" & Ench.Adjustment & ") (Aff:" & Ench.Affected & ") (AM:" & Hex(Ench.AffectedMask) & ") (L:" & Ench.Layer & ") [" & Format(Ench.TimeRemaining \ 60, "#0") & ":" & Format(Ench.TimeRemaining Mod 60, "00") & "]"
      '    '                    ' TODO find the active spell
      '    '                    If ench.Active Then
      '    '                        For Each Ench2 In colActiveDebuffs
      '    '                            If ench.family > Ench2.family Then
      '    '                                colActiveDebuffs.add ench, CStr(ench.family), before:=CStr(Ench2.family)
      '    '                                bAdded = True
      '    '                                Exit For
      '    '                            End If
      '    '                        Next
      '    '                        If Not bAdded Then colActiveDebuffs.add ench, CStr(ench.family)
      '    '                    End If
      '    '                End If
      '    '
      '    '            End If
      '    '        Next
      '
      '
      '            Dim i As Long
      '            Dim debuffs As debuffList
      '            Set debuffs = New debuffList
      '
      ''    wtcwDebug "(" & CharStats.EnchantmentCount & ")"
      ''    For i = 0 To CharStats.EnchantmentCount - 1
      ''        Set Spell = SpellF.SpellByID(CharStats.Enchantment(i).SpellID)
      ''        If Not Spell Is Nothing Then
      ''            wtcwDebug Spell.name
      ''            If CBool(Spell.Flags And &H10) Then 'Debuff
      ''                debuffs.add CharStats.Enchantment(i), Spell
      ''            End If
      ''        Else
      ''            wtcwDebug CharStats.Enchantment(i).SpellID
      ''        End If
      ''    Next
      '
      '            Dim num As Long
      '            If chkSelfLifeOnly.Checked Then
      '                num = debuffs.ActiveLifeCount
      '            Else
      '                num = debuffs.ActiveCount
      '            End If
      '
      '            If Not chkSelfDebuffOnly.Checked Or num > 0 Then
      '    '            ReDim sortedSpells(activeSpells.Count) As Enchantment
      '    '
      '    '            If activeSpells.Count > 0 Then
      '    '                Dim toRemove As Long
      '    '                For i = LBound(sortedSpells) To UBound(sortedSpells)
      '    '                    For Each Ench In activeSpells
      '    '                        If sortedSpells(i) Is Nothing Then
      '    '                            Set sortedSpells(i) = Ench
      '    '                            toRemove = Ench.Family
      '    '                        ElseIf sortedSpells(i).Family < sortedSpells(i).Family Then
      '    '                            Set sortedSpells(i) = Ench
      '    '                            toRemove = Ench.Family
      '    '                        End If
      '    '                    Next
      '    '                    activeSpells.Remove toRemove
      '    '                Next
      '    '            End If
      '
      '                Set tmpMonster = New clsMonster
      '                tmpMonster.MonsterName = CharStats.name
      '                tmpMonster.MonsterGUID = CharStats.Character
      '                tmpMonster.MonsterType = ePlayer
      '
      '                hudSelf.Render tmpMonster, num, True
      '
      '                For i = 0 To debuffs.Count - 1
      '                    If debuffs.Active(i) And (debuffs.isLife(i) Or Not chkSelfLifeOnly.Checked) Then
      '                        Set ench = debuffs.Enchantment(i)
      '                        Set Spell = debuffs.Spell(i)
      '                        'msgbox "Adding: " & Spell.name
      '                        If dispTimerCheck.Checked Then
      '                            sTimeLeft = "(" & Format(ench.TimeRemaining \ 60, "#0") & ":" & Format(ench.TimeRemaining Mod 60, "00") & ")"
      '                        Else
      '                            sTimeLeft = ""
      '                        End If
      '                        If Spell.SpellSchool = 2 Then
      '                            sSpellName = Replace(Spell.name, "Vulnerability", "Vuln")
      '                        Else
      '                            sSpellName = Replace(Spell.name, "Ineptitude", "Inept")
      '                        End If
      '                        sSpellName = Replace(sSpellName, " Other", "")
      '                        hudSelf.AddLine sSpellName, Spell.Icon, aTimeLeft:=sTimeLeft
      '                    End If
      '                Next
      '
      '                hudSelf.EndRender
      '            Else
      '                hudSelf.Disable
      '            End If
      '
      '            Set Spell = Nothing
      '            Set debuffs = Nothing
      '            Set ench = Nothing
      '            Set Ench2 = Nothing
      '        Else
      '            hudSelf.Disable
      '        End If
              
1300          Set tmpMonster = Nothing
1302      End If
1304      Exit Sub
erh:
1306      handleErr "RenderHUDs"
End Sub

'******************************************************************************
'** Chat Command Functions ****************************************************
'******************************************************************************

Private Sub Hooks_ChatParserIntercept(ByVal bstrText As String, bEat As Boolean)
1308      On Error GoTo erh
          
1310      bstrText = Trim(LCase(bstrText))
1312      If Left(bstrText, 11) = "/targetinfo" Or Left(bstrText, 11) = "@targetinfo" Then
1314          bstrText = "/tinfo " & Trim(Right(bstrText, Len(bstrText) - 11))
1316      End If
1318      If Left(bstrText, 6) = "/tinfo" Or Left(bstrText, 6) = "@tinfo" Then
1320          bEat = True
1322          bstrText = Trim(Right(bstrText, Len(bstrText) - 6))
1324          Select Case bstrText
                  Case ""
1326                  ShowHelp
1328              Case "help"
1330                  ShowHelp
1332              Case "show"
1334                  chkShowTargetHUD.Checked = True
                      'SaveSettings
1336                  wtcwMessage "HUD enabled"
1338              Case "hide"
1340                  chkShowTargetHUD.Checked = False
1342                  chkShowSelfHUD.Checked = False
1344                  hudSelf.Disable
1346                  hudTarget.Disable
                      'SaveSettings
1348                  wtcwMessage "HUDs disabled"
1350              Case "relocate"
1352                  Relocate
1354              Case "clearsel"
1356                  ClearMonsterInfo Hooks.CurrentSelection
1358              Case "dist2d"
1360                  wtcwMessage WorldFilter.Distance2D(CharStats.Character, Hooks.CurrentSelection)
1362              Case Else
1364                  wtcwWarning "Invalid command specified"
1366                  wtcwWarning "Type �2籃tinfo help�8� for a list of commands"
1368          End Select
1370      End If
          
1372      Exit Sub
erh:
1374      handleErr "Hooks_ChatParserIntercept"
End Sub

Private Sub ShowHelp()
1376      wtcwMessage "The following is a list of all chat commands available:"
1378      wtcwCmdInfo "help", "Displays this help message"
1380      wtcwCmdInfo "show", "Displays the HUD"
1382      wtcwCmdInfo "hide", "Hides the HUD"
1384      wtcwCmdInfo "clearsel", "Clears the vulns for the selected monster/player"
1386      wtcwCmdInfo "relocate", "Relocates the HUD in case it was moved outside the viewable region"
End Sub


'******************************************************************************
'** Vuln Database Functions ***************************************************
'******************************************************************************

Private Sub WorldFilter_ChangeObject(ByVal pObject As DecalFilters.IWorldObject, ByVal Change As DecalFilters.WorldChangeType)
1388      On Error GoTo erh
1390      If Change = wevtIdentReceived Then
              Dim wObj As WorldObject, tmpMonster As clsMonster
1392          Set wObj = pObject
              
1394          If dctVulMonsters.Exists(wObj.GUID) Then
1396              Set tmpMonster = dctVulMonsters(wObj.GUID)
1398          ElseIf dctNonVulMonsters.Exists(wObj.GUID) Then
1400              Set tmpMonster = dctNonVulMonsters(wObj.GUID)
1402          End If
              
1404          If Not tmpMonster Is Nothing Then
1406              If Not tmpMonster.VulnInfo.HasVulnInfo And tmpMonster.MonsterType = eMonster Then
1408                  If Not VulnDbase.dctIDedCache.Exists(tmpMonster.MonsterName) Then
1410                      Set tmpMonster.VulnInfo = VulnDbase(wObj.name, wObj.Longs(keySpecies))
1412                      Set VulnDbase.dctIDedCache(tmpMonster.MonsterName) = tmpMonster.VulnInfo
1414                      If tmpMonster.VulnInfo.HasVulnInfo Then
1416                          wtcwMessage "Species vuln info used for: �2�" & wObj.name
1418                      Else
                              'wtcwWarning "No vuln info available for: �2�" & wObj.Name
1420                      End If
1422                      VulnDbase.SaveCache
1424                  End If
1426              End If
1428          End If
              
1430          Set tmpMonster = Nothing
          
1432      End If
1434      Exit Sub
erh:
1436      handleErr "WorldFilter_ChangeObject"
End Sub

Private Sub btnUpdateDatabase_Accepted(ByVal nID As Long)
1438      On Error GoTo erh
1440      wtcwMessage "Downloading database...  This may take a while.  You will be alerted when the download is complete."
1442      httpDatabase.GetXML sDatabaseURL
1444      Exit Sub
erh:
1446      handleErr "btnUpdateDatabase_Accepted"
End Sub

Private Sub httpDatabase_onFailure(ByVal sErrorMessage As String)
1448      On Error GoTo erh
1450      wtcwError "Failed to download database file from �7�" & httpDatabase.URL & " �2�" & sErrorMessage
1452      Exit Sub
erh:
1454      handleErr "httpDatabase_onFailure"
End Sub

Private Sub httpDatabase_onSuccess(sResponse As String)
1456      On Error GoTo erh
1458      wtcwMessage "Finished downloading database.  Parsing data..."
          Dim ts As TextStream
1460      Set ts = FSO.CreateTextFile(App.Path & "\unparsed_database.xml", True)
1462      ts.Write sResponse
1464      ts.Close
1466      Set ts = Nothing
          
1468      DataParser.Start
          
1470      Exit Sub
erh:
1472      handleErr "httpDatabase_onSuccess"
End Sub

Private Sub DataParser_Done()
1474      On Error GoTo erh
1476      If FSO.FileExists(App.Path & "\vuln_idcache.xml") Then
1478          FSO.DeleteFile App.Path & "\vuln_idcache.xml"
1480      End If
1482      VulnDbase.Load
1484      wtcwMessage "Finished parsing data.  Database updated successfully."
1486      Exit Sub
erh:
1488      handleErr "DataParser_Done"
End Sub

Private Sub DataParser_AbortError()
1490      On Error GoTo erh
1492      wtcwError "Failed to parse database!"
1494      Exit Sub
erh:
1496      handleErr "DataParser_AbortError"
End Sub

'******************************************************************************
'** Hotkey/Cycling Functions **************************************************
'******************************************************************************

Private Function isValidSelection(ByRef Monster, SelectType As Long) As Boolean
1498      isValidSelection = Not WorldFilter(Monster.MonsterGUID) Is Nothing And ( _
                  SelectType = scMonster And Monster.MonsterType = eMonster Or _
                  SelectType = scPlayer And Monster.MonsterType = ePlayer Or _
                  SelectType = scBoth And (Monster.MonsterType = eMonster Or Monster.MonsterType = ePlayer))
End Function

Private Sub SelNextMonster(mDict As Dictionary, SelectType As Long, dMaxRange As Single)
1500      On Error GoTo erh
          Dim dCurDist As Single, dThisDist As Single, dNextDist As Single, foundGUID As Long, curMonster
1502      foundGUID = 0
1504      dCurDist = WorldFilter.Distance2D(Hooks.CurrentSelection, CharStats.Character)
1506      dNextDist = dMaxRange
1508      For Each curMonster In mDict.Items
1510          If isValidSelection(curMonster, SelectType) Then
1512              dThisDist = WorldFilter.Distance2D(curMonster.MonsterGUID, CharStats.Character)
                  'Finding the next farthest monster from the current selection
1514              If dThisDist > dCurDist And dThisDist < dNextDist Then
1516                  dNextDist = dThisDist
1518                  foundGUID = curMonster.MonsterGUID
1520              End If
1522          End If
1524      Next
1526      If foundGUID = 0 Then
              'Loop to the closest monster since there wasn't one farther
1528          SelNearMonster mDict, SelectType, dMaxRange
1530      Else
1532          Hooks.SelectItem foundGUID
1534      End If
1536      Exit Sub
erh:
1538      handleErr "SelNextMonster"
End Sub

Private Sub SelPrevMonster(mDict As Dictionary, SelectType As Long, dMaxRange As Single)
1540      On Error GoTo erh
          Dim dCurDist As Single, dThisDist As Single, dPrevDist As Single, foundGUID As Long, curMonster
1542      foundGUID = 0
1544      dCurDist = WorldFilter.Distance2D(Hooks.CurrentSelection, CharStats.Character)
1546      If dCurDist > dMaxRange Then dCurDist = dMaxRange
1548      dPrevDist = 0
1550      For Each curMonster In mDict.Items
1552          If isValidSelection(curMonster, SelectType) Then
1554              dThisDist = WorldFilter.Distance2D(curMonster.MonsterGUID, CharStats.Character)
                  'Finding the next closest monster than the current selection
1556              If dThisDist < dCurDist And dThisDist > dPrevDist Then
1558                  dPrevDist = dThisDist
1560                  foundGUID = curMonster.MonsterGUID
1562              End If
1564          End If
1566      Next
1568      If foundGUID = 0 Then
              'Loop to the farthest monster since there wasn't one closer
1570          SelFarMonster mDict, SelectType, dMaxRange
1572      Else
1574          Hooks.SelectItem foundGUID
1576      End If
1578      Exit Sub
erh:
1580      handleErr "SelPrevMonster"
End Sub

Private Sub SelNearMonster(mDict As Dictionary, SelectType As Long, dMaxRange As Single)
1582      On Error GoTo erh
          Dim dThisDist As Single, dMinDist As Single, foundGUID As Long, curMonster
1584      foundGUID = 0
1586      dMinDist = dMaxRange
1588      For Each curMonster In mDict.Items
1590          If isValidSelection(curMonster, SelectType) Then
1592              dThisDist = WorldFilter.Distance2D(curMonster.MonsterGUID, CharStats.Character)
1594              If dThisDist < dMinDist Then
1596                  dMinDist = dThisDist
1598                  foundGUID = curMonster.MonsterGUID
1600              End If
1602          End If
1604      Next
1606      If foundGUID <> 0 Then Hooks.SelectItem foundGUID
1608      Exit Sub
erh:
1610      handleErr "SelNearMonster"
End Sub

Private Sub SelFarMonster(mDict As Dictionary, SelectType As Long, dMaxRange As Single)
1612      On Error GoTo erh
          Dim dThisDist As Single, dMaxDist As Single, foundGUID As Long, curMonster
1614      foundGUID = 0
1616      dMaxDist = 0
1618      For Each curMonster In mDict.Items
1620          If isValidSelection(curMonster, SelectType) Then
1622              dThisDist = WorldFilter.Distance2D(curMonster.MonsterGUID, CharStats.Character)
1624              If dThisDist > dMaxDist And dThisDist < dMaxRange Then
1626                  dMaxDist = dThisDist
1628                  foundGUID = curMonster.MonsterGUID
1630              End If
1632          End If
1634      Next
1636      If foundGUID <> 0 Then Hooks.SelectItem foundGUID
1638      Exit Sub
erh:
1640      handleErr "SelFarMonster"
End Sub

Private Sub dh_HotkeyEvent(ByVal szEvent As String, pbEat As Boolean)
1642      On Error GoTo erh
          Dim dRange As Single
1644      dRange = IIf(PluginSite2.Hooks.Landcell And &HFF00&, Val(edtIndoorRange.Text), Val(edtOutdoorRange.Text)) / 250

1646      Select Case szEvent
              Case "TInfo:NearestVul"
1648              SelNearMonster dctVulMonsters, selectStateChoice.Selected, dRange
1650              pbEat = True
1652          Case "TInfo:NearestNVul"
1654              SelNearMonster dctNonVulMonsters, selectNonStateChoice.Selected, dRange
1656              pbEat = True
1658          Case "TInfo:NextVul"
1660              SelNextMonster dctVulMonsters, selectStateChoice.Selected, dRange
1662              pbEat = True
1664          Case "TInfo:NextNVul"
1666              SelNextMonster dctNonVulMonsters, selectNonStateChoice.Selected, dRange
1668              pbEat = True
1670          Case "TInfo:PrevVul"
1672              SelPrevMonster dctVulMonsters, selectStateChoice.Selected, dRange
1674              pbEat = True
1676          Case "TInfo:PrevNVul"
1678              SelPrevMonster dctNonVulMonsters, selectNonStateChoice.Selected, dRange
1680              pbEat = True
1682          Case "TInfo:ClearSel"
1684              ClearMonsterInfo Hooks.CurrentSelection
1686              pbEat = True
1688      End Select
1690      Exit Sub
erh:
1692      handleErr "dh_HotkeyEvent"
End Sub

Private Sub CheckHotKey(hkTitle As String, hkDesc As String)
1694      If Not dh.QueryHotkey(hkTitle) Then
              Dim newHotKey As New DHS.Hotkey
1696          newHotKey.EventDescription = hkDesc
1698          newHotKey.EventTitle = hkTitle
1700          dh.AddHotkey "TInfo", newHotKey
1702      End If
End Sub

'******************************************************************************
'** Settings Functions ********************************************************
'******************************************************************************

Private Sub LoadSettings()
1704      On Error GoTo erh
1706      bLoadingSettings = True
          Dim xmlDoc As New DOMDocument40, xmlEle As IXMLDOMElement
          Dim value As String, lValue As Long, coords As Variant, viewRect As tagRECT
          
1708      If Not xmlDoc.Load(App.Path & "\settings.xml") Then
1710          bLoadingSettings = False
1712          SaveSettings
1714      Else
1716          For Each xmlEle In xmlDoc.documentElement.getElementsByTagName("setting")
1718              value = xmlEle.getAttribute("value")
1720              Select Case xmlEle.getAttribute("name")
                      Case "MainViewPos": coords = Split(value, ",")
1722                      viewRect = MainView.Position
1724                      setRectPos viewRect, Val(coords(0)), Val(coords(1))
1726                      MainView.Position = viewRect
1728                  Case "nbkMain": lValue = Val(value)
1730                      If lValue >= 0 And lValue < mainTabCount Then nbkMain.ActiveTab = lValue
1732                  Case "nbkHUD": lValue = Val(value)
1734                      If lValue >= 0 And lValue < hudTabCount Then nbkHUD.ActiveTab = lValue
                  
1736                  Case "TargetPos": coords = Split(value, ",")
1738                      hudTarget.Pos = makePoint(Val(coords(0)), Val(coords(1)))
1740                  Case "chkShowTargetHUD": chkShowTargetHUD.Checked = value
1742                  Case "chkTargetRightAlign": chkTargetRightAlign.Checked = value
1744                  Case "chkTargetIconsOnly": chkTargetIconsOnly.Checked = value
1746                  Case "chkTargetTextOnly": chkTargetTextOnly.Checked = value
1748                  Case "chkTargetLifeOnly": chkTargetLifeOnly.Checked = value
1750                  Case "chkTargetAttackHeight": chkTargetAttackHeight.Checked = value
1752                  Case "chkTargetVulnsInline": chkTargetVulnsInline.Checked = value
1754                  Case "textColor": TextColor.Selected = Val(value)
1756                  Case "textColorLow": TextColorLow.Selected = Val(value)
1758                  Case "backgroundColor": BackgroundColor.Selected = Val(value)
                      
1760                  Case "VulnsPos": coords = Split(value, ",")
1762                      hudVulns.Pos = makePoint(Val(coords(0)), Val(coords(1)))
1764                  Case "chkShowVulnsHUD": chkShowVulnsHUD.Checked = value
1766                  Case "chkVulnsRightAlign": chkVulnsRightAlign.Checked = value
1768                  Case "chkVulnsIconsOnly": chkVulnsIconsOnly.Checked = value
1770                  Case "chkVulnsTextOnly": chkVulnsTextOnly.Checked = value
1772                  Case "chkVulnsAttach": chkVulnsAttach.Checked = value
1774                  Case "chkVulnsAttackHeight": chkVulnsAttackHeight.Checked = value
1776                  Case "chkVulnsBestOnly": chkVulnsBestOnly.Checked = value
1778                  Case "chkVulnsColorCode": chkVulnsColorCode.Checked = value
1780                  Case "textColorVulns": textColorVulns.Selected = Val(value)
1782                  Case "backgroundColorVulns": backgroundColorVulns.Selected = Val(value)
                      
1784                  Case "SelfPos": coords = Split(value, ",")
1786                      hudSelf.Pos = makePoint(Val(coords(0)), Val(coords(1)))
1788                  Case "chkShowSelfHUD": chkShowSelfHUD.Checked = value
1790                  Case "chkSelfRightAlign": chkSelfRightAlign.Checked = value
1792                  Case "chkSelfIconsOnly": chkSelfIconsOnly.Checked = value
1794                  Case "chkSelfTextOnly": chkSelfTextOnly.Checked = value
1796                  Case "chkSelfLifeOnly": chkSelfLifeOnly.Checked = value
1798                  Case "chkSelfDebuffOnly": chkSelfDebuffOnly.Checked = value
1800                  Case "textColorSelf": textColorSelf.Selected = Val(value)
1802                  Case "backgroundColorSelf": backgroundColorSelf.Selected = Val(value)
                      
1804                  Case "lifeSpellLevel": lifeSpellLevel.Selected = Val(value)
1806                  Case "creatureSpellLevel": creatureSpellLevel.Selected = Val(value)
1808                  Case "dispTimer": dispTimerCheck.Checked = value
1810                  Case "edtLowBuffThresh": edtLowBuffThresh.Text = Int(Val(value))
1812                      LowBuffThresh = Int(Val(value))
                      
1814                  Case "edtOutdoorRange": edtOutdoorRange.Text = value
1816                  Case "edtIndoorRange": edtIndoorRange.Text = value
1818                  Case "selectState": selectStateChoice.Selected = value
1820                  Case "selectNonState": selectNonStateChoice.Selected = value
                      
1822                  Case "choDecorationType": choDecorationType.Selected = value
1824                  Case "choDecorationColor": choDecorationColor.Selected = value
1826                  Case "edtFontSize": edtFontSize.Text = value
                      
1828                  Case "DATABASE_URL": sDatabaseURL = value
1830              End Select
1832          Next xmlEle
1834      End If
          
1836      hudTarget.TextColor = ColorMenu(TextColor)
1838      hudTarget.LowTextColor = ColorMenu(TextColorLow)
1840      hudTarget.BackgroundColor = BackgroundColorMenu(BackgroundColor)
1842      hudTarget.AlignRight = chkTargetRightAlign.Checked
1844      hudTarget.RecommendVulns = chkTargetVulnsInline.Checked
1846      hudTarget.ShowBestAttackHeight = chkTargetAttackHeight.Checked
1848      hudTarget.IconsOnly = chkTargetIconsOnly.Checked
1850      hudTarget.TextOnly = chkTargetTextOnly.Checked
1852      hudTarget.LifeOnly = chkTargetLifeOnly.Checked
1854      hudTarget.ShowTimer = dispTimerCheck.Checked
1856      hudTarget.ShowDebuffs = True
1858      hudTarget.ShowName = True
1860      hudTarget.OnlyBestVulns = chkVulnsBestOnly.Checked
1862      hudTarget.ColorCodeVulns = chkVulnsColorCode.Checked
1864      hudTarget.FontSize = Val(edtFontSize.Text)
          
1866      hudVulns.TextColor = ColorMenu(textColorVulns)
1868      hudVulns.LowTextColor = ColorMenu(textColorVulns)
1870      hudVulns.BackgroundColor = BackgroundColorMenu(backgroundColorVulns)
1872      hudVulns.AlignRight = chkVulnsRightAlign.Checked
1874      hudVulns.RecommendVulns = True
1876      hudVulns.ShowBestAttackHeight = chkVulnsAttackHeight.Checked
1878      hudVulns.IconsOnly = chkVulnsIconsOnly.Checked
1880      hudVulns.TextOnly = chkVulnsTextOnly.Checked
1882      hudVulns.LifeOnly = False
1884      hudVulns.ShowTimer = False
1886      hudVulns.ShowDebuffs = False
1888      hudVulns.ShowName = Not chkVulnsAttach.Checked
1890      hudVulns.OnlyBestVulns = chkVulnsBestOnly.Checked
1892      hudVulns.ColorCodeVulns = chkVulnsColorCode.Checked
1894      hudVulns.FontSize = Val(edtFontSize.Text)
          
1896      hudSelf.TextColor = ColorMenu(textColorSelf)
1898      hudSelf.LowTextColor = ColorMenu(textColorSelf)
1900      hudSelf.BackgroundColor = BackgroundColorMenu(backgroundColorSelf)
1902      hudSelf.AlignRight = chkSelfRightAlign.Checked
1904      hudSelf.RecommendVulns = False
1906      hudSelf.ShowBestAttackHeight = False
1908      hudSelf.IconsOnly = chkSelfIconsOnly.Checked
1910      hudSelf.TextOnly = chkSelfTextOnly.Checked
1912      hudSelf.LifeOnly = chkSelfLifeOnly.Checked
1914      hudSelf.ShowTimer = dispTimerCheck.Checked
1916      hudSelf.ShowDebuffs = False
1918      hudSelf.ShowName = True
1920      hudSelf.ColorCodeVulns = False
1922      hudSelf.FontSize = Val(edtFontSize.Text)
          
1924      SetVulnsAttach
          
1926      bLoadingSettings = False
1928      Exit Sub
erh:
1930      handleErr "LoadSettings"
1932      bLoadingSettings = False
End Sub

Private Function AddSetting(ByRef DOMDoc As DOMDocument40, name As String, ByVal value As String) As IXMLDOMElement
          Dim node As IXMLDOMElement
1934      Set node = DOMDoc.documentElement.appendChild(DOMDoc.createElement("setting"))
1936      node.setAttribute "name", name
1938      node.setAttribute "value", value
End Function

Private Sub SaveSettings()
1940      On Error GoTo erh
1942      If bLoadingSettings Then Exit Sub
          
          Dim xmlDoc As New DOMDocument40
1944      xmlDoc.appendChild xmlDoc.createProcessingInstruction("xml", "version='1.0'")
1946      xmlDoc.appendChild xmlDoc.createElement("settings")
          
1948      AddSetting xmlDoc, "MainViewPos", MainView.Position.Left & "," & MainView.Position.Top
1950      AddSetting xmlDoc, "nbkMain", nbkMain.ActiveTab
1952      AddSetting xmlDoc, "nbkHUD", nbkHUD.ActiveTab
          
1954      AddSetting xmlDoc, "TargetPos", hudTarget.Pos.x & "," & hudTarget.Pos.y
1956      AddSetting xmlDoc, "chkShowTargetHUD", chkShowTargetHUD.Checked
1958      AddSetting xmlDoc, "chkTargetRightAlign", chkTargetRightAlign.Checked
1960      AddSetting xmlDoc, "chkTargetIconsOnly", chkTargetIconsOnly.Checked
1962      AddSetting xmlDoc, "chkTargetTextOnly", chkTargetTextOnly.Checked
1964      AddSetting xmlDoc, "chkTargetLifeOnly", chkTargetLifeOnly.Checked
1966      AddSetting xmlDoc, "chkTargetAttackHeight", chkTargetAttackHeight.Checked
1968      AddSetting xmlDoc, "chkTargetVulnsInline", chkTargetVulnsInline.Checked
1970      AddSetting xmlDoc, "textColor", TextColor.Selected
1972      AddSetting xmlDoc, "textColorLow", TextColorLow.Selected
1974      AddSetting xmlDoc, "backgroundColor", BackgroundColor.Selected
          
1976      AddSetting xmlDoc, "VulnsPos", hudVulns.Pos.x & "," & hudVulns.Pos.y
1978      AddSetting xmlDoc, "chkShowVulnsHUD", chkShowVulnsHUD.Checked
1980      AddSetting xmlDoc, "chkVulnsRightAlign", chkVulnsRightAlign.Checked
1982      AddSetting xmlDoc, "chkVulnsIconsOnly", chkVulnsIconsOnly.Checked
1984      AddSetting xmlDoc, "chkVulnsTextOnly", chkVulnsTextOnly.Checked
1986      AddSetting xmlDoc, "chkVulnsAttach", chkVulnsAttach.Checked
1988      AddSetting xmlDoc, "chkVulnsAttackHeight", chkVulnsAttackHeight.Checked
1990      AddSetting xmlDoc, "chkVulnsBestOnly", chkVulnsBestOnly.Checked
1992      AddSetting xmlDoc, "chkVulnsColorCode", chkVulnsColorCode.Checked
1994      AddSetting xmlDoc, "textColorVulns", textColorVulns.Selected
1996      AddSetting xmlDoc, "backgroundColorVulns", backgroundColorVulns.Selected
          
1998      AddSetting xmlDoc, "SelfPos", hudSelf.Pos.x & "," & hudSelf.Pos.y
2000      AddSetting xmlDoc, "chkShowSelfHUD", chkShowSelfHUD.Checked
2002      AddSetting xmlDoc, "chkSelfRightAlign", chkSelfRightAlign.Checked
2004      AddSetting xmlDoc, "chkSelfIconsOnly", chkSelfIconsOnly.Checked
2006      AddSetting xmlDoc, "chkSelfTextOnly", chkSelfTextOnly.Checked
2008      AddSetting xmlDoc, "chkSelfLifeOnly", chkSelfLifeOnly.Checked
2010      AddSetting xmlDoc, "chkSelfDebuffOnly", chkSelfDebuffOnly.Checked
2012      AddSetting xmlDoc, "textColorSelf", textColorSelf.Selected
2014      AddSetting xmlDoc, "backgroundColorSelf", backgroundColorSelf.Selected
          
2016      AddSetting xmlDoc, "lifeSpellLevel", lifeSpellLevel.Selected
2018      AddSetting xmlDoc, "creatureSpellLevel", creatureSpellLevel.Selected
2020      AddSetting xmlDoc, "dispTimer", dispTimerCheck.Checked
2022      AddSetting xmlDoc, "edtLowBuffThresh", edtLowBuffThresh.Text
          
2024      AddSetting xmlDoc, "edtOutdoorRange", edtOutdoorRange.Text
2026      AddSetting xmlDoc, "edtIndoorRange", edtIndoorRange.Text
2028      AddSetting xmlDoc, "selectState", selectStateChoice.Selected
2030      AddSetting xmlDoc, "selectNonState", selectNonStateChoice.Selected
          
2032      AddSetting xmlDoc, "choDecorationType", choDecorationType.Selected
2034      AddSetting xmlDoc, "choDecorationColor", choDecorationColor.Selected
2036      AddSetting xmlDoc, "edtFontSize", edtFontSize.Text

2038      AddSetting xmlDoc, "DATABASE_URL", sDatabaseURL
          
2040      writeXML xmlDoc, App.Path & "\settings.xml"
2042      Exit Sub
erh:
2044      handleErr "SaveSettings"
End Sub
