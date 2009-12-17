VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "QuestTimer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Implements IPlugin2

Private MainView As View
Private PluginID As Long
Attribute PluginID.VB_VarHelpID = -1
Private WithEvents NetEcho As EchoFilter
Attribute NetEcho.VB_VarHelpID = -1
Private WithEvents WorldFilter As DecalFilters.World
Attribute WorldFilter.VB_VarHelpID = -1
Private WithEvents Hooks As Decal.ACHooks
Attribute Hooks.VB_VarHelpID = -1
Private WithEvents CharStats As DecalFilters.CharacterStats
Attribute CharStats.VB_VarHelpID = -1
'Private WithEvents Inventory As ImpFilterV2.Filter
Private WithEvents tm As DecalInput.Timer
Attribute tm.VB_VarHelpID = -1
Private WithEvents tm10 As DecalInput.Timer
Attribute tm10.VB_VarHelpID = -1

Private bLoadingSettings As Boolean
Private bCheckNowClicked As Boolean, bDownloadNowClicked As Boolean
Private firstQuest As Boolean
Private dMyGMTOffset As Date 'for determining if the system timezone (or DST) has changed
Private dLastModify As Date 'for determining if the quests.xml file was edited externally
Private dLastModifyGMT As Date 'for only downloading quests.xml if the one on the server is newer (checked by server)
Private lUploadCt As Long 'for only uploading quests.xml if your file is newer than on the server (checked by server)
Private dLastDnldNewGMT As Date 'gets updated every time a download is completed
Private dDnldNewGMT As Date 'gets set to dLastDnldNewGMT only at startup (not updated)
Private lPickingUp As Long 'Stores quest index of a quest that requires a pickup from specific corpse
Private bWarnedUploadEditSelf As Boolean

Const icnDelete = &H600606E
'Const icnAdd = &H6005E6B
Const icnAdd = &H60011F9
Private WithEvents nbkMain As DecalControls.Notebook
Attribute nbkMain.VB_VarHelpID = -1
Private Enum tabMain
    tQuests = 0: tNotes: tAddEdit: tOtherChars: tInternet: tSettings
End Enum
Private WithEvents nbkInternet As DecalControls.Notebook
Attribute nbkInternet.VB_VarHelpID = -1
Private Enum tabInternet
    tAvailable = 0: tSubmit: tInternetSettings
End Enum
Private WithEvents QuestsList As DecalControls.List
Attribute QuestsList.VB_VarHelpID = -1
Private Enum colQuest
    cName = 0: cTimeLeft: cNotes: cEdit: cDelete
End Enum

Private WithEvents lstNotes As DecalControls.List
Attribute lstNotes.VB_VarHelpID = -1
Private Enum colNote
    cText = 0: cCopy: cSay: cFellow: cDelete
End Enum
Private WithEvents choQuestNotes As DecalControls.Choice
Attribute choQuestNotes.VB_VarHelpID = -1
Private WithEvents btnAddNote As DecalControls.PushButton
Attribute btnAddNote.VB_VarHelpID = -1
Private edtNote As DecalControls.Edit

Private WithEvents QuestNameEdit As DecalControls.Edit
Attribute QuestNameEdit.VB_VarHelpID = -1
Private WithEvents DaysEdit As DecalControls.Edit
Attribute DaysEdit.VB_VarHelpID = -1
Private WithEvents HoursEdit As DecalControls.Edit
Attribute HoursEdit.VB_VarHelpID = -1
Private WithEvents MinutesEdit As DecalControls.Edit
Attribute MinutesEdit.VB_VarHelpID = -1
Private WithEvents btnSpecificCorpseHelp As DecalControls.PushButton
Attribute btnSpecificCorpseHelp.VB_VarHelpID = -1
Private TextEdit As DecalControls.Edit
Private ItemEdit As DecalControls.Edit
Private Droppable As DecalControls.CheckBox
Private ChestEdit As DecalControls.Edit
Private WithEvents NowBtn As DecalControls.PushButton
Attribute NowBtn.VB_VarHelpID = -1
Private CompletedCheck As DecalControls.CheckBox
Private WithEvents AddQuestBtn As DecalControls.PushButton
Attribute AddQuestBtn.VB_VarHelpID = -1
Private WithEvents edtDate As DecalControls.Edit
Attribute edtDate.VB_VarHelpID = -1
Private WithEvents edtTime As DecalControls.Edit
Attribute edtTime.VB_VarHelpID = -1
Private WithEvents btnWildCardHelp As DecalControls.PushButton
Attribute btnWildCardHelp.VB_VarHelpID = -1
Private WithEvents btnPickupSelected As DecalControls.PushButton
Attribute btnPickupSelected.VB_VarHelpID = -1
Private WithEvents btnChestSelected As DecalControls.PushButton
Attribute btnChestSelected.VB_VarHelpID = -1
Private WithEvents btnClearAddEdit As DecalControls.PushButton
Attribute btnClearAddEdit.VB_VarHelpID = -1
Private WithEvents DaysLeft As DecalControls.Edit
Attribute DaysLeft.VB_VarHelpID = -1
Private WithEvents HoursLeft As DecalControls.Edit
Attribute HoursLeft.VB_VarHelpID = -1
Private WithEvents MinutesLeft As DecalControls.Edit
Attribute MinutesLeft.VB_VarHelpID = -1
Private WithEvents SecondsLeft As DecalControls.Edit
Attribute SecondsLeft.VB_VarHelpID = -1
Private WithEvents CalcTimeLeft As DecalControls.PushButton
Attribute CalcTimeLeft.VB_VarHelpID = -1

Private WithEvents choOChar As DecalControls.Choice
Attribute choOChar.VB_VarHelpID = -1
Private WithEvents lstOChar As DecalControls.List
Attribute lstOChar.VB_VarHelpID = -1
Private Enum colOChar
    cOQuestName = 0: cOQuestTimeLeft: cOExprTime
End Enum

Private bRefreshInternetLists As Boolean
Private WithEvents lstDnldQuests As DecalControls.List
Attribute lstDnldQuests.VB_VarHelpID = -1
Private Enum colDnld
    cChk = 0: cQuestName: cDuration: cDateAdded: cAdd: cView 'Visible
    cNew = colDnld.cView + 1: cDays: cHours: cMinutes: cText: cItem: cChest: cDroppable 'Hidden
End Enum
Private cDnldFilterBy As colDnld
Private WithEvents edtDnldFilter As DecalControls.Edit
Attribute edtDnldFilter.VB_VarHelpID = -1
Private WithEvents txtDnldFilterMatches As DecalControls.StaticText
Attribute txtDnldFilterMatches.VB_VarHelpID = -1
Private WithEvents tmrDnldFilter As DecalInput.Timer
Attribute tmrDnldFilter.VB_VarHelpID = -1
Private WithEvents btnDnldShowSelected As DecalControls.PushButton
Attribute btnDnldShowSelected.VB_VarHelpID = -1
Private WithEvents btnDnldShowUpdated As DecalControls.PushButton
Attribute btnDnldShowUpdated.VB_VarHelpID = -1
Private WithEvents btnDnldSelNew As DecalControls.PushButton
Attribute btnDnldSelNew.VB_VarHelpID = -1
Private WithEvents btnDnldAddSel As DecalControls.PushButton
Attribute btnDnldAddSel.VB_VarHelpID = -1
Private WithEvents btnDnldSelUpdated As DecalControls.PushButton
Attribute btnDnldSelUpdated.VB_VarHelpID = -1
Private WithEvents btnDnldSelAll As DecalControls.PushButton
Attribute btnDnldSelAll.VB_VarHelpID = -1
Private WithEvents btnDnldSelNone As DecalControls.PushButton
Attribute btnDnldSelNone.VB_VarHelpID = -1

Private WithEvents edtSubmittedBy As DecalControls.Edit
Attribute edtSubmittedBy.VB_VarHelpID = -1
Private WithEvents btnSubmitSelQuests As DecalControls.PushButton
Attribute btnSubmitSelQuests.VB_VarHelpID = -1
Private WithEvents lstSubmitQuests As DecalControls.List
Attribute lstSubmitQuests.VB_VarHelpID = -1
Private Enum colSubmit
    cSubChk = 0: cSubName: cSubInfo
End Enum

Private WithEvents chkShowTimeUp As DecalControls.CheckBox
Attribute chkShowTimeUp.VB_VarHelpID = -1
Private WithEvents chkCheckFileTime As DecalControls.CheckBox
Attribute chkCheckFileTime.VB_VarHelpID = -1
Private WithEvents chkAutoResetQuests As DecalControls.CheckBox
Attribute chkAutoResetQuests.VB_VarHelpID = -1
Private WithEvents edtAutoResetQuests As DecalControls.Edit
Attribute edtAutoResetQuests.VB_VarHelpID = -1
Private WithEvents chkWebNewVersion As DecalControls.CheckBox
Attribute chkWebNewVersion.VB_VarHelpID = -1
Private WithEvents chkWebNews As DecalControls.CheckBox
Attribute chkWebNews.VB_VarHelpID = -1
Private WithEvents chkWebNewQuests As DecalControls.CheckBox
Attribute chkWebNewQuests.VB_VarHelpID = -1
Private QuestDatabaseURL As String
Private TreestatsURL As String
Private WithEvents btnWebCheckNow As DecalControls.PushButton
Attribute btnWebCheckNow.VB_VarHelpID = -1
Private WithEvents chkWebUpload As DecalControls.CheckBox
Attribute chkWebUpload.VB_VarHelpID = -1
Private WithEvents edtWebUploadURL As DecalControls.Edit
Attribute edtWebUploadURL.VB_VarHelpID = -1
Private WithEvents chkWebOnlyUploadNew As DecalControls.CheckBox
Attribute chkWebOnlyUploadNew.VB_VarHelpID = -1
Private WithEvents choWebMismatch As DecalControls.Choice
Attribute choWebMismatch.VB_VarHelpID = -1
Private Enum optMismatch
    optNone = 0: optCompare: optMerge
End Enum
Private WithEvents btnWebHelpMismatch As DecalControls.PushButton
Attribute btnWebHelpMismatch.VB_VarHelpID = -1
Private WithEvents btnWebUploadNow As DecalControls.PushButton
Attribute btnWebUploadNow.VB_VarHelpID = -1
Private WithEvents chkWebDownload As DecalControls.CheckBox
Attribute chkWebDownload.VB_VarHelpID = -1
Private WithEvents edtWebDownloadURL As DecalControls.Edit
Attribute edtWebDownloadURL.VB_VarHelpID = -1
Private WithEvents btnWebDownloadNow As DecalControls.PushButton
Attribute btnWebDownloadNow.VB_VarHelpID = -1
Private WithEvents chkWebOnlyUpdateNew As DecalControls.CheckBox
Attribute chkWebOnlyUpdateNew.VB_VarHelpID = -1
Private WithEvents chkWebSaveBackups As DecalControls.CheckBox
Attribute chkWebSaveBackups.VB_VarHelpID = -1
Private WithEvents edtWebBackupCt As DecalControls.Edit
Attribute edtWebBackupCt.VB_VarHelpID = -1
Private WithEvents edtWebUsername As DecalControls.Edit
Attribute edtWebUsername.VB_VarHelpID = -1
Private WithEvents edtWebPassword As DecalControls.Edit
Attribute edtWebPassword.VB_VarHelpID = -1
Private WithEvents btnWebUserHelp As DecalControls.PushButton
Attribute btnWebUserHelp.VB_VarHelpID = -1
Private WithEvents btnWebDefaultURLs As DecalControls.PushButton
Attribute btnWebDefaultURLs.VB_VarHelpID = -1
Private WithEvents chkWebTreestats As DecalControls.CheckBox
Attribute chkWebTreestats.VB_VarHelpID = -1
Private bFirstRunTS As Boolean
Private WithEvents lnkInternetSettings As DecalControls.CheckBox
Attribute lnkInternetSettings.VB_VarHelpID = -1

Private imgLogo As DecalControls.FixedLayout
Private txtPluginNameVer As DecalControls.StaticText

Private WithEvents webPluginInfo As httpHandler
Attribute webPluginInfo.VB_VarHelpID = -1
Private WithEvents webNewQuests As httpHandler
Attribute webNewQuests.VB_VarHelpID = -1
Private WithEvents webSubmitQuests As httpHandler
Attribute webSubmitQuests.VB_VarHelpID = -1
Private WithEvents webGetQuestXML As httpHandler
Attribute webGetQuestXML.VB_VarHelpID = -1
Private WithEvents webSendQuestXML As httpHandler
Attribute webSendQuestXML.VB_VarHelpID = -1
Private WithEvents webSendTreestats As httpHandler
Attribute webSendTreestats.VB_VarHelpID = -1
Private colAddtlURLs As New Collection, ctSendURL As Long, ctSendURLSuccess As Long
Type URL_User_Pass
    URL As String
    Username As String
    Password As String
End Type

Private Const clrView = &H88CCFF, clrError = &H8080FF, clrSelected = &HFF9999, clrNew = &H80FF80, _
    clrUpdated = &H2FFFE0, clrLightGreen = &HCCFFCC, clrOld = &H9494FF, clrFound = &H4FA2DF

Private Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer

'******************************************************************************
'**  Plugin Initialization  ***************************************************
'******************************************************************************

Private Sub IPlugin2_Initialize(ByVal Site As Decal.IPluginSite2)
2         On Error GoTo erh
4         sPluginNameVer = sPluginName & " v" & App.Major & "." & App.Minor & ".0." & App.Revision
6         bLoadingSettings = False
8         dLastModifyGMT = #1/1/1990#
10        dLastDnldNewGMT = #1/1/1990#
12        lUploadCt = 0
14        dMyGMTOffset = GMTOffsetD
16        dDnldNewGMT = dLastDnldNewGMT
18        QuestDatabaseURL = sWebURL
20        TreestatsURL = TREESTATS_URL
          
22        Set PluginSite2 = Site
24        Set PluginSite = PluginSite2.PluginSite
26        Set MainView = PluginSite.LoadView(FSO.OpenTextFile(App.Path & "\QuestTimer.xml").ReadAll)
          
28        Set NetEcho = PluginSite2.object("services\DecalNet.NetService\DecalFilters.EchoFilter")
30        Set WorldFilter = PluginSite2.object("services\DecalNet.NetService\DecalFilters.World")
32        Set CharStats = PluginSite2.object("services\DecalNet.NetService\DecalFilters.CharacterStats")
34        Set Hooks = PluginSite2.Hooks
36        Set Hub.Hooks2 = PluginSite2.Hooks
          'Set Inventory = PluginSite2.object("ImpFilterV2.Filter")
          
38        Set tm = New DecalInput.Timer
40        Set tm10 = New DecalInput.Timer
42        Set tmrDnldFilter = New DecalInput.Timer
          
44        With MainView
46            Set nbkMain = .Control("nbkMain")
48            Set nbkInternet = .Control("nbkInternet")
50            Set QuestsList = .Control("QuestsList")
              
52            Set choQuestNotes = .Control("choQuestNotes")
54            Set lstNotes = .Control("lstNotes")
56            Set btnAddNote = .Control("btnAddNote")
58            Set edtNote = .Control("edtNote")
              
60            Set QuestNameEdit = .Control("QuestNameEdit")
62            Set DaysEdit = .Control("DaysEdit")
64            Set HoursEdit = .Control("HoursEdit")
66            Set MinutesEdit = .Control("MinutesEdit")
68            Set btnSpecificCorpseHelp = .Control("btnSpecificCorpseHelp")
70            Set TextEdit = .Control("TextEdit")
72            Set ItemEdit = .Control("ItemEdit")
74            Set btnPickupSelected = .Control("btnPickupSelected")
76            Set Droppable = .Control("droppable")
78            Set ChestEdit = .Control("ChestEdit")
80            Set btnChestSelected = .Control("btnChestSelected")
82            Set btnWildCardHelp = .Control("btnWildCardHelp")
84            Set CompletedCheck = .Control("CompletedCheck")
86            Set edtDate = .Control("edtDate")
88            Set edtTime = .Control("edtTime")
90            Set NowBtn = .Control("NowBtn")
92            Set DaysLeft = .Control("DaysLeft")
94            Set HoursLeft = .Control("HoursLeft")
96            Set MinutesLeft = .Control("MinutesLeft")
98            Set SecondsLeft = .Control("SecondsLeft")
100           Set CalcTimeLeft = .Control("CalcTimeLeft")
102           Set AddQuestBtn = .Control("AddQuestBtn")
104           Set btnClearAddEdit = .Control("btnClearAddEdit")
              
106           Set choOChar = .Control("choOChar")
108           Set lstOChar = .Control("lstOChar")
              
110           bRefreshInternetLists = True
112           Set lstDnldQuests = .Control("lstDnldQuests")
114           Set edtDnldFilter = .Control("edtDnldFilter")
116           Set txtDnldFilterMatches = .Control("txtDnldFilterMatches")
118           Set btnDnldShowSelected = .Control("btnDnldShowSelected")
120           Set btnDnldShowUpdated = .Control("btnDnldShowUpdated")
122           Set btnDnldSelNew = .Control("btnDnldSelNew")
124           Set btnDnldSelUpdated = .Control("btnDnldSelUpdated")
126           Set btnDnldAddSel = .Control("btnDnldAddSel")
128           Set btnDnldSelAll = .Control("btnDnldSelAll")
130           Set btnDnldSelNone = .Control("btnDnldSelNone")
              
132           Set edtSubmittedBy = .Control("edtSubmittedBy")
134           Set btnSubmitSelQuests = .Control("btnSubmitSelQuests")
136           Set lstSubmitQuests = .Control("lstSubmitQuests")

138           Set chkAutoResetQuests = .Control("chkAutoResetQuests")
140           Set edtAutoResetQuests = .Control("edtAutoResetQuests")
142           Set chkWebNewVersion = .Control("chkWebNewVersion")
144           Set chkWebNews = .Control("chkWebNews")
146           Set chkWebNewQuests = .Control("chkWebNewQuests")
148           Set btnWebCheckNow = .Control("btnWebCheckNow")
150           Set chkWebUpload = .Control("chkWebUpload")
152           Set edtWebUploadURL = .Control("edtWebUploadURL")
154           Set chkWebOnlyUploadNew = .Control("chkWebOnlyUploadNew")
156           Set choWebMismatch = .Control("choWebMismatch")
158           Set btnWebHelpMismatch = .Control("btnWebHelpMismatch")
160           Set btnWebUploadNow = .Control("btnWebUploadNow")
162           Set chkWebDownload = .Control("chkWebDownload")
164           Set edtWebDownloadURL = .Control("edtWebDownloadURL")
166           Set btnWebDownloadNow = .Control("btnWebDownloadNow")
168           Set chkWebOnlyUpdateNew = .Control("chkWebOnlyUpdateNew")
170           Set chkWebSaveBackups = .Control("chkWebSaveBackups")
172           Set edtWebBackupCt = .Control("edtWebBackupCt")
174           Set edtWebUsername = .Control("edtWebUsername")
176           Set edtWebPassword = .Control("edtWebPassword")
178           Set btnWebUserHelp = .Control("btnWebUserHelp")
180           Set btnWebDefaultURLs = .Control("btnWebDefaultURLs")
182           Set chkWebTreestats = .Control("chkWebTreestats")
184           Set lnkInternetSettings = .Control("lnkInternetSettings")
              
186           Set chkShowTimeUp = .Control("chkShowTimeUp")
188           Set chkCheckFileTime = .Control("chkCheckFileTime")
              
190           Set imgLogo = .Control("imgLogo")
192           Set txtPluginNameVer = .Control("txtPluginNameVer")
194       End With
          
196       SetRandomLogo
          
198       txtPluginNameVer.text = sPluginNameVer
          
200       Set webPluginInfo = New httpHandler
202       Set webNewQuests = New httpHandler
204       Set webSubmitQuests = New httpHandler
206       Set webGetQuestXML = New httpHandler
208       Set webSendQuestXML = New httpHandler
210       Set webSendTreestats = New httpHandler
          
212       dLastModify = Now
214       bLoggedIn = False
216       ClearQuests
          
218       bWarnedUploadEditSelf = False
220       Exit Sub
erh:
222       HandleErr "IPlugin2_Initialize"
224       Resume Next
End Sub

Private Sub IPlugin2_Terminate()
226       On Error Resume Next
228       tm.Stop
230       tm10.Stop
232       If tmrDnldFilter.Running Then tmrDnldFilter.Stop
234       Set tm = Nothing
236       Set tm10 = Nothing
238       Set tmrDnldFilter = Nothing
240       Set webPluginInfo = Nothing
242       Set webNewQuests = Nothing
244       Set webGetQuestXML = Nothing
246       Set webSendQuestXML = Nothing
248       Set webSendTreestats = Nothing
250       Set MainView = Nothing
252       Set CharStats = Nothing
254       Set PluginSite = Nothing
256       Set PluginSite2 = Nothing
258       Set NetEcho = Nothing
End Sub

Private Sub CharStats_Login(ByVal Character As Long)
260       On Error GoTo erh
262       bLoggedIn = True
264       bFirstRunTS = True
266       LoadSettings
268       sCharName = CharStats.Name
270       sWorld = CharStats.Server
272       lPlayerGUID = CharStats.Character
274       edtSubmittedBy.text = sCharName
          
276       If Not FSO.FileExists(App.Path & "\quests.xml") And FSO.FileExists(App.Path & "\default_quests.xml") Then
              Dim XMLDoc As New DOMDocument40, XMLNode As IXMLDOMNode
278           If XMLDoc.Load(App.Path & "\default_quests.xml") Then
280               For Each XMLNode In XMLDoc.childNodes
                      'Remove the "Do not edit this.." comment
282                   If XMLNode.nodeType = NODE_COMMENT Then XMLDoc.removeChild XMLNode
284               Next XMLNode
286               XMLDoc.save App.Path & "\quests.xml"
                  'DO NOT CALL JustSavedQuestsXML HERE! This may cause a new install to overwrite a quest timer on the server
288               wtcwMessage "This appears to be your first time running «2»" & sPluginNameVer & "«d»!"
290               wtcwMessage "Go to the Internet tab to set up quest file uploading/downloading."
292           End If
294       End If
296       If FSO.FileExists(App.Path & "\merge_quests.xml") Then
298           wtcwMessage "There is a merge file available that may contain new quest information."
300           wtcwMessage "If you want to load the quests into your quest file, type «14»/" & sCmdName & " merge import"
302           wtcwMessage "To delete the merge file without importing and stop getting this message, type «14»/" & sCmdName & " merge delete"
304       End If
          
306       If bFirstRunTS Then
              'See if Treestats is installed
              Dim TS As Object
308           On Error Resume Next
310           Set TS = PluginSite2.object("{9847B2B7-C7C7-42ba-9361-021D01715E8F}")
312           On Error GoTo erh
314           If Not TS Is Nothing Then
316               wtcwMessage "Treestats detected... Quest Timer will upload your quest timers to Treestats"
318               wtcwMessage "You can disable this on the Internet > Settings tab"
320               chkWebTreestats.Checked = True
322               SaveSettings
324           End If
326       End If
          
328       wtcwDebug "DEBUG MODE ENABLED"
330       Exit Sub
erh:
332       HandleErr "CharStats_Login"
End Sub

Private Sub CharStats_LoginComplete()
334       On Error GoTo erh
336       LoadQuests
          
338       If chkWebNewVersion.Checked Or chkWebNews.Checked Then
340           webPluginInfo.PostRequest sWebURL, "plugininfo"
342       End If
344       If chkWebNewQuests.Checked Then CheckNewQuests
346       If chkWebDownload.Checked Then DownloadQuests
          
348       tm.Start 1000
350       tm10.Start 10000
352       Exit Sub
erh:
354       HandleErr "CharStats_LoginComplete"
End Sub

Private Sub SetRandomLogo()
356       On Error GoTo erh
          Dim TheImage As IImageCache
358       Set TheImage = PluginSite.LoadBitmapPortal(Choose(Int(2 * Rnd + 1), &H6002299, &H600229B))
       'Call PluginSite.LoadBitmapPortal(Choose(Int(4 * Rnd + 1), &H600115D, &H6001172, &H6001181, &H6001184), TheImage)
360       Set imgLogo.Background = TheImage
362       Set TheImage = Nothing
364       Exit Sub
erh:
366       HandleErr "SetLogo"
End Sub

Private Sub tm_Timeout(ByVal Source As DecalInput.IDecalTimer)
368       On Error GoTo erh
          Dim i As Long
370       i = 0
372       For i = 0 To UBound(Quests)
374           QuestsList.Data(colQuest.cTimeLeft, i) = GetTimeLeft(i)
376           If QuestsList.Data(colQuest.cTimeLeft, i) = "Time Up" And Quests(i).Told = False Then
378               If chkShowTimeUp.Checked Then wtcwMessage "Timer Up For Quest: «2»" & Quests(i).QuestName & "«d»!"
380               Quests(i).Told = True
382           End If
384       Next
          
386       If nbkMain.ActiveTab = tabMain.tOtherChars Then
              Dim dTimeLeft As Date
388           For i = 0 To lstOChar.Count - 1
390               If lstOChar.Data(colOChar.cOExprTime, i) <> "1990-1-1" And _
                          lstOChar.Color(colOChar.cOQuestName, i) <> clrSelected Then
392                   dTimeLeft = CDate(lstOChar.Data(colOChar.cOExprTime, i)) - Now
394                   If dTimeLeft < 0 Then
396                       lstOChar.Data(colOChar.cOQuestTimeLeft, i) = "Time Up"
398                   Else
400                       lstOChar.Data(colOChar.cOQuestTimeLeft, i) = DateDiff("d", 0, dTimeLeft) & "D " & _
                              Format(dTimeLeft, "hh""H"" nn""M"" ss""S""")
402                   End If
404               End If
406           Next i
408       End If
410       Exit Sub
erh:
412       HandleErr "tm_Timeout"
End Sub

Private Sub tm10_Timeout(ByVal Source As DecalInput.IDecalTimer)
414       On Error GoTo erh
          
416       If dMyGMTOffset <> GMTOffsetD Then 'GMT Offset has changed
              Dim QuestsXML As New DOMDocument40
418           If QuestsXML.Load(App.Path & "\quests.xml") Then
420               If FixTimezone(QuestsXML) Then
422                   WriteXML QuestsXML, App.Path & "\quests.xml"
424                   JustSavedQuestsXML True
426                   LoadQuests
428               End If
430           End If
432           dMyGMTOffset = GMTOffsetD
434       ElseIf chkCheckFileTime.Checked Then
436           On Error GoTo erh2
438           If dLastModify < FSO.GetFile(App.Path & "\quests.xml").DateLastModified Then
440               wtcwWarning "The Quests file was modified outside of this session of AC. This is most likely caused by dual logging."
442               wtcwWarning "Loading updated version of the Quests file...."
444               LoadQuests
446           End If
448       End If
          
450       Exit Sub
erh:
452       HandleErr "tm10_Timeout"
erh2:
End Sub

'******************************************************************************
'**  Chat Text Commands  ******************************************************
'******************************************************************************

Private Sub Hooks_ChatParserIntercept(ByVal bstrText As String, bEat As Boolean)
454       On Error GoTo erh
456       If bstrText Like "[/@]quest timer*" Then bstrText = Replace(bstrText, "quest timer", sCmdName, 1, 1, vbTextCompare)
458       If bstrText Like "[/@]" & sCmdName & "*" Then
460           bEat = True
462           bstrText = LCase(Trim(Mid(bstrText, Len(sCmdName) + 2)))
464           If Left(bstrText, 5) = "notes" Then
466               bstrText = Trim(Mid(bstrText, 6))
                  Dim index As Long
468               If bstrText <> "" Then
470                   index = QuestIndex(bstrText)
472                   If index < 0 Then
474                       wtcwWarning "«2»" & bstrText & "«d» is not a quest in your list, make sure you typed it correctly"
476                   Else
478                       choQuestNotes.Selected = index
480                   End If
482               End If
484               nbkMain.ActiveTab = tabMain.tNotes
486               MainView.Activate
488           ElseIf Left(bstrText, 5) = "merge" Then
490               bstrText = Trim(Mid(bstrText, 6))
492               Select Case bstrText
                      Case "import": MergeQuests
494                   Case "export": ExportMergeFile
496                   Case "create": ExportMergeFile
498                   Case "delete": DeleteMergeFile
500                   Case Else: wtcwError "Please specify «2»import«d», «2»create«d», or «2»delete"
502               End Select
504           ElseIf Left(bstrText, 6) = "expire" Then
506               bstrText = Trim(Mid(bstrText, 7))
                  Dim i As Long
508               i = QuestIndex(bstrText)
510               If i < 0 Then
512                   wtcwError "Quest does not exist: «2»" & bstrText
514               ElseIf Quests(i).Completed Then
516                   If Now - ExpireTime(i) > 0 Then
518                       wtcwMessage "«2»" & Quests(i).QuestName & "«d» expired «2»" & Format(Now - ExpireTime(i), "0.0#") & "«d» days ago"
520                   Else
522                       wtcwMessage "«2»" & Quests(i).QuestName & "«d» expires in «2»" & Format(ExpireTime(i) - Now, "0.0#") & "«d» days"
524                   End If
526               Else
528                   wtcwWarning "«2»" & Quests(i).QuestName & "«d» Not Completed"
530               End If
532           Else
534               Select Case bstrText
                      Case "up": AlertTimerUp
536                   Case "checknew": btnWebCheckNow_Accepted 0
538                   Case "checknew reset"
540                       If FSO.FileExists(App.Path & "\downloaded_quests.xml") Then FSO.DeleteFile App.Path & "\downloaded_quests.xml"
542                       dLastDnldNewGMT = #1/1/1990#
544                       SaveSettings
546                       btnWebCheckNow_Accepted 0
548                   Case "upload": btnWebUploadNow_Accepted 0
550                   Case "download": btnWebDownloadNow_Accepted 0
552                   Case "help": ShowHelp
554                   Case "": ShowHelp
556                   Case Else: wtcwError "Invalid command: «2»" & bstrText & "«d». Type «14»/" & sCmdName & " help«d» for a command list."
558               End Select
560           End If
562       End If
564       Exit Sub
erh:
566       HandleErr "Hooks_ChatParserIntercept"
End Sub

Private Sub ShowHelp()
568       wtcwMessage "You're using «2»" & sPluginNameVer & "«d»  Here are the commands available:"
570       wtcwMessage "«14»/" & sCmdName & " up«13» - Show the quests that have expired"
572       wtcwMessage "«14»/" & sCmdName & " upload«13» - Upload your quests file to the server"
574       wtcwMessage "«14»/" & sCmdName & " download«13» - Download your quests file from the server"
576       wtcwMessage "«14»/" & sCmdName & " checknew [reset]«13» - Check for any new quests available and downloads them. If «2»reset«13» is specified, redownload ALL of the quest definitions"
578       wtcwMessage "«14»/" & sCmdName & " notes [<quest name>]«13» - Open Quest Timer to the Notes tab.  If a «2»quest name«13» is specified, it'll show the notes for that quest"
580       wtcwMessage "«14»/" & sCmdName & " expire <quest name>«13» - Tells you how long ago a quest expired, or how long until it expires"
582       wtcwMessage "«14»/" & sCmdName & " merge import|export|delete«13» - «2»import«13» a mergefile; «2»export«13» a new mergefile from your quests; or «2»delete«13» a mergefile if one exists"
End Sub

Private Sub AlertTimerUp()
584       On Error GoTo erh
          Dim i As Long, questFound As Boolean
586       questFound = False
588       For i = 0 To UBound(Quests)
590           If GetTimeLeft(i) = "Time Up" Then
592               wtcwMessage "Timer Up For Quest: «2»" & Quests(i).QuestName & "«d»!"
594               questFound = True
596           End If
598       Next i
600       If Not questFound Then wtcwMessage "You have no expired quest timers."
602       Exit Sub
erh:
604       HandleErr "AlertTimerUp"
End Sub

'******************************************************************************
'**  Monitoring Timers  *******************************************************
'******************************************************************************

Private Function isLike(ByVal Check As String, ByVal Pattern As String)
          'Patterns are multiple wildcard patterns separated by pipes |
          'e.g. *Gem of Enlightenment|*Gem of Forgetfulness
606       On Error GoTo erh
608       isLike = False
610       If Check = "" Or Pattern = "" Then Exit Function
          Dim sPattern
612       For Each sPattern In Split(Pattern, "|")
614           If Check Like sPattern Then
616               isLike = True
618               Exit Function
620           End If
622       Next sPattern
624       Exit Function
erh:
626       HandleErr "isLike"
End Function

Private Function isOwned(wObj As WorldObject) As Boolean
628       On Error GoTo erh
630       isOwned = False
          
632       If wObj.Longs(keyContainer) = CharStats.Character And wObj.Longs(keyHouseOwner, 0) = 0 Then
              'HouseOwner is nonzero for hooked items
634           isOwned = True
636       Else
              Dim wObj2 As WorldObject
638           Set wObj2 = WorldFilter(wObj.Longs(keyContainer))
640           If Not wObj2 Is Nothing Then
642               If wObj2.Longs(keyContainer) = CharStats.Character And wObj2.Longs(keyHouseOwner, 0) = 0 Then
644                   isOwned = True 'In a side pack
646               End If
648           End If
650       End If
652       Exit Function
erh:
654       HandleErr "isOwned"
End Function

Private Sub WorldFilter_ChangeObject(ByVal pObject As DecalFilters.IWorldObject, ByVal Change As DecalFilters.WorldChangeType)
656       On Error GoTo erh
          
658       If Not bLoggedIn Then Exit Sub
          
          Dim i As Long
          'Dim debugMessage As String
          
660       If Change = wevtStorageChange Then
              'debugMessage = "WF Storage Change: "
662           If isOwned(pObject) Then
                  'debugMessage = debugMessage & " OWNED"
664               For i = 0 To UBound(Quests)
666                   If isLike(pObject.Strings(keyName), Quests(i).Item) Then
                          'debugMessage = debugMessage & " - matches Quest: " & Quests(i).QuestName
668                       If Quests(i).chest <> "" Then
                              'debugMessage = debugMessage & " | Requires chest"
                              'This is a timer that requires an item from a specific chest/corpse
                              Dim wObj As WorldObject
670                           Set wObj = WorldFilter(Hooks.OpenedContainer)
672                           If Not wObj Is Nothing Then
674                               If isLike(wObj.Strings(keyName), Quests(i).chest) Then
676                                   QuestCompleted i
678                               End If
680                           End If
682                       ElseIf Quests(i).Droppable Then
684                           If Quests(i).Completed Then
686                               If (ExpireTime(i) - Now) < 0 Then QuestCompleted i
688                           Else
690                               QuestCompleted i
692                           End If
694                       Else
                              Dim ownGUID, bOwned As Boolean
696                           bOwned = False
698                           For Each ownGUID In Quests(i).IOwn
700                               If ownGUID = pObject.Guid Then
                                      'debugMessage = debugMessage & " | Already Owned"
702                                   bOwned = True
704                                   Exit For
706                               End If
708                           Next
710                           If Not bOwned Then
                                  'debugMessage = debugMessage & " | Not Owned"
712                               Quests(i).IOwn.Add pObject.Guid
714                               QuestCompleted i
716                           End If
718                       End If
720                   End If
722               Next i
724           End If
              'wtcwDebug debugMessage
726       End If
          
728       Exit Sub
erh:
730       HandleErr "WorldFilter_ChangeObject"
End Sub

Private Sub Hooks_ContainerOpened(ByVal lGUID As Long)
732       On Error GoTo erh
          
734       If Not bLoggedIn Then Exit Sub
          
          Dim wObj As WorldObject, i As Long
              
736       Set wObj = WorldFilter(lGUID)
738       If Not wObj Is Nothing Then
740           For i = 0 To UBound(Quests)
742               If isLike(wObj.Strings(keyName), Quests(i).chest) And Quests(i).Item = "" Then QuestCompleted i
744           Next i
746       End If
748       Exit Sub
erh:
750       HandleErr "Hooks_ContainerOpened"
End Sub

Private Sub Hooks_ChatTextIntercept(ByVal bstrText As String, ByVal lColor As Long, ByVal lTarget As Long, bEat As Boolean)
752       On Error GoTo erh
754       If (lColor = 3 Or lColor = 0) And bLoggedIn Then
756           If Right(bstrText, 1) = vbLf Then bstrText = Left(bstrText, Len(bstrText) - 1)
758           If Right(bstrText, 1) = vbCr Then bstrText = Left(bstrText, Len(bstrText) - 1)
              'bstrText = StripTellTags(bstrText)
              Dim i As Long
760           For i = 0 To UBound(Quests)
762               If isLike(bstrText, Quests(i).text) Then QuestCompleted i
764           Next i
766       End If
768       Exit Sub
erh:
770       HandleErr "Hooks_ChatTextIntercept"
End Sub

Private Function StripTellTags(text As String) As String
772       On Error GoTo erh
          Dim i As Long, gt As Long, closeTag As Long
          
774       i = InStr(text, "<Tell:IIDString:")
776       Do While i > 0
778           gt = InStr(i + 16, text, ">")
780           If gt <> 0 Then
782               closeTag = InStr(gt, text, "<\Tell>")
784               If closeTag <> 0 Then
786                   text = Left(text, i - 1) & Mid(text, gt + 1, closeTag - gt - 1) & Mid(text, closeTag + 7)
788               Else
790                   Exit Do
792               End If
794           Else
796               Exit Do
798           End If
800           i = VBA.InStr(text, "<Tell:IIDString:")
802       Loop
          
804       StripTellTags = text
          
806       Exit Function
erh:
808       HandleErr "StripTellTags"
End Function

Private Sub QuestCompleted(index As Long)
810       On Error GoTo erh
812       Quests(index).Completed = Now
814       Quests(index).Told = False
816       wtcwMessage "Quest timer started: «2»" & Quests(index).QuestName
818       SaveQuests
820       Exit Sub
erh:
822       HandleErr "QuestCompleted"
End Sub

Private Sub checkIOwn()
824       On Error GoTo erh
          
          Dim i As Long, wObj As WorldObject
826       For Each wObj In WorldFilter.Inventory
828           For i = 0 To UBound(Quests)
830               If isOwned(wObj) Then If isLike(wObj.Strings(keyName), Quests(i).Item) Then Quests(i).IOwn.Add wObj.Guid
832           Next
834       Next
          
836       Set wObj = Nothing
838       Exit Sub
erh:
840       HandleErr "checkIOwn"
End Sub

Private Sub checkIOwn2(index As Long)
842       On Error GoTo erh
          
844       If Quests(index).Item = "" Then Exit Sub
          
          Dim wObj As WorldObject
846       For Each wObj In WorldFilter.Inventory
848           If isOwned(wObj) Then If isLike(wObj.Strings(keyName), Quests(index).Item) Then Quests(index).IOwn.Add wObj.Guid
850       Next
          
852       Set wObj = Nothing
854       Exit Sub
erh:
856       HandleErr "checkIOwn2"
End Sub

'******************************************************************************
'**  Control Event Handlers  **************************************************
'******************************************************************************

Private Sub nbkMain_Change(ByVal nID As Long, ByVal nNewPage As Long)
858       On Error GoTo erh
860       If nNewPage = tabMain.tInternet And bRefreshInternetLists Then RefreshInternetLists
862       If nNewPage = tabMain.tOtherChars And choOChar.Selected < 0 Then choOChar.Selected = 0
864       If nNewPage = tabMain.tSettings Then SetRandomLogo
866       Exit Sub
erh:
868       HandleErr "nbkMain_Change"
End Sub

'**  Quests Tab  **************************************************************
Private Sub QuestsList_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
    On Error GoTo erh:
          Dim tmpQuestName As String
870       Select Case nX
              Case colQuest.cName: ArrangeByName
872           Case colQuest.cTimeLeft:
874               If CBool(GetAsyncKeyState(vbKeyControl) And &H8000&) Then 'CTRL down
876                   If QuestsList.Data(nX, nY) = "Time Up" Then
878                       Quests(nY).Completed = False
880                       SaveQuests
882                       tm_Timeout Nothing
884                       wtcwMessage "Quest timer cleared for «2»" & QuestsList.Data(colQuest.cName, nY)
886                   Else
888                       wtcwMessage "Hold «2»Ctrl«d» and click on a quest timer that says «2»Time Up«d» to clear the timer"
890                   End If
892               Else
894                   ArrangeByTimeLeft
896               End If
898           Case colQuest.cNotes
900               choQuestNotes.Selected = nY
902               nbkMain.ActiveTab = tabMain.tNotes
904           Case colQuest.cEdit: QuestEdit Quests(nY)
906           Case colQuest.cDelete
908               If GetAsyncKeyState(vbKeyControl) And &H8000& Then 'CTRL down
910                   tmpQuestName = Quests(nY).QuestName
912                   RemoveQuest tmpQuestName
914                   QuestsList.DeleteRow nY
916                   If QuestsList.Count = 0 Then
918                       QuestsList.AddRow
920                       QuestsList.Data(colQuest.cName, 0) = "No Quests"
922                   End If
924                   wtcwMessage "Quest Deleted: «2»" & tmpQuestName
926                   SaveQuests
928               Else
930                   wtcwMessage "Please hold down the «2»Ctrl«d» key while clicking to delete a quest"
932               End If
934       End Select
          
936       Exit Sub
erh:
938       HandleErr "QuestsList_Change"
End Sub

'**  Notes Tab  ***************************************************************
Private Sub lstNotes_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
940       On Error GoTo erh
942       Select Case nX
              Case colNote.cText: wtcwMessage "Note for «2»" & choQuestNotes.text(choQuestNotes.Selected) & "«d»: «14»" & lstNotes.Data(colNote.cText, nY)
944           Case colNote.cCopy
946               Clipboard.Clear
948               Call Clipboard.SetText(lstNotes.Data(colNote.cText, nY))
950           Case colNote.cSay: Call Hooks.InvokeChatParser("/say " & lstNotes.Data(colNote.cText, nY))
952           Case colNote.cFellow: Call Hooks.InvokeChatParser("/f " & lstNotes.Data(colNote.cText, nY))
954           Case colNote.cDelete
956               If GetAsyncKeyState(vbKeyControl) And &H8000& Then
958                   wtcwMessage "Deleting Note: «14»" & lstNotes.Data(colNote.cText, nY)
960                   RemoveNote nY
962               Else
964                   wtcwMessage "Please hold down the «2»Ctrl«d» key while clicking to delete a note"
966               End If
968       End Select
970       Exit Sub
erh:
972       HandleErr "lstNotes_Change"
End Sub

Private Sub btnAddNote_Accepted(ByVal nID As Long)
974       On Error GoTo erh
976       If choQuestNotes.Selected < 0 Then
978           wtcwWarning "Please select a quest"
980       ElseIf edtNote.text = "" Then
982           wtcwWarning "Please type a note to add"
984       Else
986           AddNote edtNote.text, choQuestNotes.text(choQuestNotes.Selected)
988           edtNote.text = ""
990       End If
992       Exit Sub
erh:
994       HandleErr "btnAddNote_Accepted"
End Sub

'**  Add/Edit Tab  ************************************************************
Private Sub btnWildCardHelp_Accepted(ByVal nID As Long)
996       wtcwMessage "The wildcard «2»*«d» matches zero or more letters/digits, «2»?«d» matches exactly one, and «2»#«d» matches a digit."
998       wtcwMessage "The pipe «2»|«d» can be used as an OR to match multiple separate names. Don't include a space between names."
1000      wtcwMessage "For example, to match any of the gems for the Skill Change Quest, enter «14»*Gem of Enlightenment|*Gem of Forgetfulness"
End Sub

Private Sub btnSpecificCorpseHelp_Accepted(ByVal nID As Long)
1002      wtcwMessage "When you specify both an item to pick up and a chest/corpse (including ""Corpse of""), " & _
              "Quest Timer will only start the timer if you pick up the item from the specified chest/corpse."
End Sub

Private Function isBlank(str As String) As Boolean
1004      isBlank = (str = "" Or str = "0")
End Function

Private Sub QuestNameEdit_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1006      On Error GoTo erh
1008      QuestNameEdit.text = Trim(QuestNameEdit.text)
          Dim i As Long
1010      i = QuestIndex(QuestNameEdit.text)
1012      If i >= 0 Then 'If the quest exists
1014          If isBlank(DaysEdit.text) And isBlank(HoursEdit.text) And isBlank(MinutesEdit.text) And isBlank(TextEdit.text) And _
              isBlank(ItemEdit.text) And isBlank(ChestEdit.text) And isBlank(edtDate.text) And isBlank(edtTime.text) Then
                  'If it is blank, add the quest data for editing
1016              QuestEdit Quests(i)
1018          Else 'If it's not blank, just change the button text
1020              AddQuestBtn.text = "Edit Quest"
1022          End If
1024      Else 'The quest doesn't exist...
1026          AddQuestBtn.text = "Add Quest"
1028      End If
1030      Exit Sub
erh:
1032      HandleErr "QuestNameEdit_End"
End Sub

Private Sub DaysEdit_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1034      On Error GoTo erh
1036      DaysEdit.text = Int(Val(DaysEdit.text))
1038      If Val(DaysEdit.text) < 0 Then
1040          wtcwWarning "Days length cannot be less than 0"
1042          DaysEdit.text = "0"
1044      End If
1046      Exit Sub
erh:
1048      HandleErr "DaysEdit_End"
End Sub

Private Sub HoursEdit_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1050      On Error GoTo erh
1052      HoursEdit.text = Int(Val(HoursEdit.text))
1054      If Val(HoursEdit.text) < 0 Or Val(HoursEdit.text) > 23 Then
1056          wtcwWarning "Hours length must be between 0 and 23"
1058          HoursEdit.text = "0"
1060      End If
1062      Exit Sub
erh:
1064      HandleErr "HoursEdit_End"
End Sub

Private Sub MinutesEdit_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1066      On Error GoTo erh
1068      MinutesEdit.text = Int(Val(MinutesEdit.text))
1070      If Val(MinutesEdit.text) < 0 Or Val(MinutesEdit.text) > 59 Then
1072          wtcwWarning "Minutes length must be between 0 and 59"
1074          MinutesEdit.text = "0"
1076      End If
1078      Exit Sub
erh:
1080      HandleErr "MinutesEdit_End"
End Sub

Private Sub edtDate_Begin(ByVal nID As Long)
1082      edtDate.TextColor = vbWhite
End Sub

Private Sub edtDate_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1084      On Error GoTo erh
1086      If Not IsDate(edtDate.text) Or edtDate.text = "" Then
1088          edtDate.TextColor = clrError 'light red
1090          If edtTime.text = "" And edtDate.text = "" Then CompletedCheck.Checked = False
1092      Else
1094          edtDate.text = Format(CDate(edtDate.text), "dd-mmm-yyyy")
1096          If IsDate(edtTime.text) Then CompletedCheck.Checked = True
1098      End If
1100      Exit Sub
erh:
1102      HandleErr "edtDate_End"
End Sub

Private Sub edtTime_Begin(ByVal nID As Long)
1104      edtTime.TextColor = vbWhite
End Sub

Private Sub edtTime_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1106      On Error GoTo erh
1108      If Not IsDate(edtTime.text) Or edtTime.text = "" Then
1110          edtTime.TextColor = clrError 'light red
1112          If edtTime.text = "" And edtDate.text = "" Then CompletedCheck.Checked = False
1114      Else
1116          edtTime.text = Format(CDate(edtTime.text), "Long Time")
1118          If IsDate(edtDate.text) Then CompletedCheck.Checked = True
1120      End If
1122      Exit Sub
erh:
1124      HandleErr "edtTime_End"
End Sub

Private Sub AddQuestBtn_Accepted(ByVal nID As Long)
1126      On Error GoTo erh
          Dim dCompleted As Date, i As Long
          
1128      If QuestNameEdit.text = "" Then
1130          wtcwWarning "Invalid Quest Name!"
1132          Exit Sub
1134      End If
          
1136      If Val(DaysEdit.text) + Val(HoursEdit.text) + Val(MinutesEdit.text) <= 0 Then
1138          wtcwWarning "Please enter a length for the quest"
1140          Exit Sub
1142      End If
1144      If ItemEdit.text = "" And ChestEdit.text = "" And TextEdit.text = "" Then
1146          wtcwWarning "Please enter a trigger method"
1148          Exit Sub
1150      End If
          
1152      If CompletedCheck.Checked Then
1154          If edtDate.text = "" Or edtTime.text = "" Then
1156              wtcwWarning "Please enter when you last completed this quest or uncheck Already Completed"
1158              Exit Sub
1160          ElseIf Not (IsDate(edtDate.text) And IsDate(edtTime.text)) Then
1162              wtcwWarning "The Date/Time you entered is invalid, click «2»Now«d» for an example"
1164              If Not IsDate(edtDate.text) Then edtDate.TextColor = clrError 'light red
1166              If Not IsDate(edtTime.text) Then edtTime.TextColor = clrError 'light red
1168              Exit Sub
1170          End If
1172          dCompleted = CDate(Format(CDate(edtDate.text), "Short Date")) 'Format it as a date only, in case there was a time component somehow
1174          dCompleted = dCompleted + CDate(Format(CDate(edtTime.text), "Long Time")) 'Likewise, in case there was a date component
1176      Else
1178          dCompleted = False
1180      End If
          
1182      i = QuestIndex(QuestNameEdit.text)
          
1184      AddEditQuest QuestNameEdit.text, DaysEdit.text, HoursEdit.text, MinutesEdit.text, Trim(TextEdit.text), _
              Trim(ItemEdit.text), Trim(ChestEdit.text), Droppable.Checked, dCompleted, i
1186      wtcwMessage "Quest " & IIf(i < 0, "Added", "Edited") & ": «2»" & QuestNameEdit.text
          
1188      ArrangeByTimeLeft
1190      SaveQuests
          
1192      nbkMain.ActiveTab = tabMain.tQuests
1194      i = QuestIndex(QuestNameEdit.text)
1196      If i >= 0 Then QuestsList.JumpToPosition i
1198      btnClearAddEdit_Accepted btnClearAddEdit.id
1200      Exit Sub
erh:
1202      HandleErr "AddQuestBtn_Accepted"
End Sub

Private Sub btnClearAddEdit_Accepted(ByVal nID As Long)
1204      On Error GoTo erh
1206      DaysEdit.text = "0"
1208      HoursEdit.text = "0"
1210      MinutesEdit.text = "0"
1212      QuestNameEdit.text = ""
1214      TextEdit.text = ""
1216      ItemEdit.text = ""
1218      ChestEdit.text = ""
1220      CompletedCheck.Checked = False
1222      Droppable.Checked = False
1224      edtDate.TextColor = vbWhite
1226      edtDate.text = ""
1228      edtTime.TextColor = vbWhite
1230      edtTime.text = ""
1232      DaysLeft.text = "0"
1234      HoursLeft.text = "0"
1236      MinutesLeft.text = "0"
1238      SecondsLeft.text = "0"
1240      AddQuestBtn.text = "Add Quest"
1242      Exit Sub
erh:
1244      HandleErr "btnClearAddEdit_Accepted"
End Sub

Private Sub DaysLeft_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1246      On Error GoTo erh
1248      DaysLeft.text = Int(Val(DaysLeft.text))
1250      If Val(DaysLeft.text) < 0 Then
1252          wtcwWarning "Days left cannot be less than 0"
1254          DaysLeft.text = "0"
1256      End If
1258      Exit Sub
erh:
1260      HandleErr "DaysLeft_End"
End Sub

Private Sub HoursLeft_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1262      On Error GoTo erh
1264      HoursLeft.text = Int(Val(HoursLeft.text))
1266      If Val(HoursLeft.text) < 0 Or Val(HoursLeft.text) > 23 Then
1268          wtcwWarning "Hours left must be between 0 and 23"
1270          HoursLeft.text = "0"
1272      End If
1274      Exit Sub
erh:
1276      HandleErr "HoursLeft_End"
End Sub

Private Sub MinutesLeft_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1278      On Error GoTo erh
1280      MinutesLeft.text = Int(Val(MinutesLeft.text))
1282      If Val(MinutesLeft.text) < 0 Or Val(MinutesLeft.text) > 59 Then
1284          wtcwWarning "Minutes left must be between 0 and 59"
1286          MinutesLeft.text = "0"
1288      End If
1290      Exit Sub
erh:
1292      HandleErr "MinutesLeft_End"
End Sub

Private Sub SecondsLeft_End(ByVal nID As Long, ByVal bSuccess As Boolean)
1294      On Error GoTo erh
1296      SecondsLeft.text = Int(Val(SecondsLeft.text))
1298      If Val(SecondsLeft.text) < 0 Or Val(SecondsLeft.text) > 59 Then
1300          wtcwWarning "Seconds left must be between 0 and 59"
1302          SecondsLeft.text = "0"
1304      End If
1306      Exit Sub
erh:
1308      HandleErr "SecondsLeft_End"
End Sub

Private Sub CalcTimeLeft_Accepted(ByVal nID As Long)
1310      On Error GoTo erh
          Dim dCompleted As Date
1312      dCompleted = DateAdd("d", Val(DaysLeft.text), Now)
1314      dCompleted = DateAdd("h", Val(HoursLeft.text), dCompleted)
1316      dCompleted = DateAdd("n", Val(MinutesLeft.text), dCompleted)
1318      dCompleted = DateAdd("s", Val(SecondsLeft.text), dCompleted)
          
1320      dCompleted = DateAdd("d", Val(DaysEdit.text) * -1, dCompleted)
1322      dCompleted = DateAdd("h", Val(HoursEdit.text) * -1, dCompleted)
1324      dCompleted = DateAdd("n", Val(MinutesEdit.text) * -1, dCompleted)
          
1326      edtDate.TextColor = vbWhite
1328      edtDate.text = Format(dCompleted, "dd-mmm-yyyy")
1330      edtTime.TextColor = vbWhite
1332      edtTime.text = Format(dCompleted, "Long Time")
1334      CompletedCheck.Checked = True
1336      Exit Sub
erh:
1338      HandleErr "CalcTimeLeft_Accepted"
End Sub

Private Sub NowBtn_Accepted(ByVal nID As Long)
1340      On Error GoTo erh
1342      edtDate.TextColor = vbWhite
1344      edtDate.text = Format(Now, "Short Date")
1346      edtTime.TextColor = vbWhite
1348      edtTime.text = Format(Now, "Long Time")
1350      CompletedCheck.Checked = True
1352      Exit Sub
erh:
1354      HandleErr "NowBtn_Accepted"
End Sub

Private Sub btnPickupSelected_Accepted(ByVal nID As Long)
1356      On Error GoTo erh
1358      If WorldFilter(Hooks.CurrentSelection) Is Nothing Then
1360          wtcwMessage "Please select something..."
1362      Else
1364          ItemEdit.text = WorldFilter(Hooks.CurrentSelection).Strings(keyName)
1366      End If
1368      Exit Sub
erh:
1370      HandleErr "btnPickupSelected_Accepted"
End Sub

Private Sub btnChestSelected_Accepted(ByVal nID As Long)
1372      On Error GoTo erh
1374      If WorldFilter(Hooks.CurrentSelection) Is Nothing Then
1376          wtcwMessage "Please select something..."
1378      Else
1380          ChestEdit.text = WorldFilter(Hooks.CurrentSelection).Strings(keyName)
1382      End If
1384      Exit Sub
erh:
1386      HandleErr "btnChestSelected_Accepted"
End Sub

Private Sub choQuestNotes_Change(ByVal nID As Long, ByVal nIndex As Long)
1388      On Error GoTo erh
1390      If nIndex >= 0 Then
1392          LoadNotes choQuestNotes.text(nIndex)
1394      Else
1396          lstNotes.Clear
1398      End If
1400      Exit Sub
erh:
1402      HandleErr "choQuestNotes_Change"
End Sub

'**  Other Character Tab  *****************************************************
Private Sub choOChar_Change(ByVal nID As Long, ByVal nIndex As Long)
1404      On Error GoTo erh
1406      lstOChar.Clear
1408      If nIndex >= 0 Then
              Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, CharacterNode As IXMLDOMElement
              Dim row As Long, quest_row As Long, dExprTime As Date, dTimeLeft As Date, bInserted As Boolean
              
1410          If Not QuestsXML.Load(App.Path & "\quests.xml") Then
1412              wtcwError "Failed to load the «2»quests.xml«d» file. You should reinstall «2»" & sPluginName
1414          Else
1416              If nIndex = 0 Then
1418                  For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
1420                      If QuestNode.getElementsByTagName("Character").length > 0 Then
1422                          bInserted = False
1424                          For row = 0 To lstOChar.Count - 1
1426                              If lstOChar.Data(cOExprTime, row) = "Not Completed" Or _
                                          (Left(lstOChar.Data(cOQuestName, row), 4) <> "    " And _
                                          QuestNode.getAttribute("QuestName") < lstOChar.Data(cOQuestName, row)) Then
1428                                  lstOChar.InsertRow row
1430                                  bInserted = True
1432                                  Exit For
1434                              End If
1436                          Next
1438                          If Not bInserted Then row = lstOChar.AddRow
                              
1440                          lstOChar.Data(cOQuestName, row) = QuestNode.getAttribute("QuestName")
1442                          lstOChar.Data(cOQuestTimeLeft, row) = QuestNode.getAttribute("Days") & "D " & _
                                  QuestNode.getAttribute("Hours") & "H " & QuestNode.getAttribute("Minutes") & "M"
1444                          lstOChar.Color(cOQuestName, row) = clrSelected
1446                          lstOChar.Color(cOQuestTimeLeft, row) = clrSelected
1448                          lstOChar.Data(cOExprTime, row) = "Completed" 'Just for internal use -- not displayed
                              
1450                          quest_row = row
1452                          For Each CharacterNode In QuestNode.getElementsByTagName("Character")
1454                              row = quest_row + 1
1456                              bInserted = False
1458                              Do While row < lstOChar.Count
1460                                  If lstOChar.Color(cOQuestName, row) = clrSelected Or _
                                              LTrim(lstOChar.Data(cOQuestName, row)) > CharacterNode.getAttribute("Name") & " [" & CharacterNode.getAttribute("Server") & "]" Then
1462                                      lstOChar.InsertRow row
1464                                      bInserted = True
1466                                      Exit Do
1468                                  End If
1470                                  row = row + 1
1472                              Loop
1474                              If Not bInserted Then row = lstOChar.AddRow
                                  
1476                              lstOChar.Data(cOQuestName, row) = "    " & _
                                      CharacterNode.getAttribute("Name") & " [" & CharacterNode.getAttribute("Server") & "]"
1478                              dExprTime = DateAdd("d", QuestNode.getAttribute("Days"), CharacterNode.getAttribute("Completed"))
1480                              dExprTime = DateAdd("h", QuestNode.getAttribute("Hours"), dExprTime)
1482                              dExprTime = DateAdd("n", QuestNode.getAttribute("Minutes"), dExprTime)
1484                              lstOChar.Data(colOChar.cOExprTime, row) = dExprTime
1486                              dTimeLeft = dExprTime - Now
1488                              If dTimeLeft < 0 Then
1490                                  lstOChar.Data(colOChar.cOQuestTimeLeft, row) = "Time Up"
1492                              Else
1494                                  lstOChar.Data(colOChar.cOQuestTimeLeft, row) = DateDiff("d", 0, dTimeLeft) & "D " & _
                                          Format(dTimeLeft, "hh""H"" nn""M"" ss""S""")
1496                              End If
1498                          Next
1500                      Else
1502                          row = lstOChar.AddRow
                              
1504                          lstOChar.Data(cOQuestName, row) = QuestNode.getAttribute("QuestName")
1506                          lstOChar.Data(cOQuestTimeLeft, row) = QuestNode.getAttribute("Days") & "D " & _
                                  QuestNode.getAttribute("Hours") & "H " & QuestNode.getAttribute("Minutes") & "M"
1508                          lstOChar.Color(cOQuestName, row) = clrSelected
1510                          lstOChar.Color(cOQuestTimeLeft, row) = clrSelected
1512                          lstOChar.Data(cOExprTime, row) = "Not Completed" 'Just for internal use -- not displayed
1514                      End If
1516                  Next
1518              Else
1520                  For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
1522                      row = lstOChar.AddRow
1524                      lstOChar.Data(colOChar.cOQuestName, row) = QuestNode.getAttribute("QuestName")
1526                      lstOChar.Data(colOChar.cOQuestTimeLeft, row) = "Not Completed"
1528                      lstOChar.Data(colOChar.cOExprTime, row) = "1990-1-1"
1530                      For Each CharacterNode In QuestNode.getElementsByTagName("Character")
1532                          If CharacterNode.getAttribute("Name") & " [" & CharacterNode.getAttribute("Server") & "]" = choOChar.text(nIndex) Then
1534                              dExprTime = DateAdd("d", QuestNode.getAttribute("Days"), CharacterNode.getAttribute("Completed"))
1536                              dExprTime = DateAdd("h", QuestNode.getAttribute("Hours"), dExprTime)
1538                              dExprTime = DateAdd("n", QuestNode.getAttribute("Minutes"), dExprTime)
1540                              lstOChar.Data(colOChar.cOExprTime, row) = dExprTime
1542                              dTimeLeft = dExprTime - Now
1544                              If dTimeLeft < 0 Then
1546                                  lstOChar.Data(colOChar.cOQuestTimeLeft, row) = "Time Up"
1548                              Else
1550                                  lstOChar.Data(colOChar.cOQuestTimeLeft, row) = DateDiff("d", 0, dTimeLeft) & "D " & _
                                          Format(dTimeLeft, "hh""H"" nn""M"" ss""S""")
1552                              End If
1554                              Exit For
1556                          End If
1558                      Next CharacterNode
1560                  Next QuestNode
1562                  lstOChar_Change 0, colOChar.cOQuestTimeLeft, 0 'sort by time left
1564              End If
1566          End If
1568      End If
1570      Exit Sub
erh:
1572      HandleErr "choOChar_Change"
End Sub

Private Sub lstOChar_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
1574      On Error GoTo erh
          Dim i As Long, j As Long, min As Long
1576      If choOChar.Selected = 0 Then Exit Sub 'Displaying all characters -- can't sort
1578      With lstOChar
1580          If nX = colOChar.cOQuestName Or nX = colOChar.cOQuestTimeLeft Then
1582              For i = 0 To .Count - 1
1584                  min = i
1586                  For j = i + 1 To .Count - 1
1588                      If nX = colOChar.cOQuestName Then
1590                          If .Data(nX, j) < .Data(nX, min) Then min = j
1592                      ElseIf (CDate(.Data(colOChar.cOExprTime, j)) < CDate(.Data(colOChar.cOExprTime, min)) Or _
                                  .Data(colOChar.cOExprTime, min) = "1990-1-1") And .Data(colOChar.cOExprTime, j) <> "1990-1-1" Or _
                                  .Data(colOChar.cOExprTime, j) = .Data(colOChar.cOExprTime, min) And _
                                  .Data(colOChar.cOQuestName, j) < .Data(colOChar.cOQuestName, min) Then
1594                          min = j
1596                      End If
1598                  Next j
1600                  If min <> i Then
1602                      .InsertRow i
1604                      min = min + 1 'index gets pushed up one by inserting a row
1606                      .Data(colOChar.cOQuestName, i) = .Data(colOChar.cOQuestName, min)
1608                      .Data(colOChar.cOQuestTimeLeft, i) = .Data(colOChar.cOQuestTimeLeft, min)
1610                      .Data(colOChar.cOExprTime, i) = .Data(colOChar.cOExprTime, min)
1612                      .DeleteRow min
1614                  End If
1616              Next i
1618          End If
1620      End With
1622      Exit Sub
erh:
1624      HandleErr "lstOChar_Change"
End Sub

'**  Internet Tab -> Available Quests  ****************************************
Private Sub lstDnldQuests_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
1626      On Error GoTo erh
          Dim newQuest As Quest, dCmpl As Date, qi As Long, bIsNew As Boolean
1628      With lstDnldQuests
1630          Select Case nX
                  Case colDnld.cChk: SetDnldColor nY
1632              Case colDnld.cQuestName: SortDnldQuestList cQuestName
1634              Case colDnld.cDuration:  SortDnldQuestList cDays
1636              Case colDnld.cDateAdded: SortDnldQuestList cDateAdded
1638              Case colDnld.cAdd
1640                  wtcwMessage "Quest Added: «2»" & .Data(colDnld.cQuestName, nY)
1642                  qi = QuestIndex(.Data(colDnld.cQuestName, nY))
1644                  If qi >= 0 Then dCmpl = Quests(qi).Completed Else dCmpl = False
1646                  AddEditQuest .Data(colDnld.cQuestName, nY), _
                          .Data(colDnld.cDays, nY), .Data(colDnld.cHours, nY), .Data(colDnld.cMinutes, nY), _
                          .Data(colDnld.cText, nY), .Data(colDnld.cItem, nY), .Data(colDnld.cChest, nY), _
                          .Data(colDnld.cDroppable, nY), dCmpl, qi
1648                  ArrangeByTimeLeft
1650                  SaveQuests
1652              Case colDnld.cView
1654                  qi = QuestIndex(.Data(colDnld.cQuestName, nY))
1656                  bIsNew = qi < 0
                      
1658                  newQuest.QuestName = .Data(colDnld.cQuestName, nY)
1660                  newQuest.Days = .Data(colDnld.cDays, nY)
1662                  newQuest.Hours = .Data(colDnld.cHours, nY)
1664                  newQuest.Minutes = .Data(colDnld.cMinutes, nY)
1666                  newQuest.text = .Data(colDnld.cText, nY)
1668                  newQuest.Item = .Data(colDnld.cItem, nY)
1670                  newQuest.chest = .Data(colDnld.cChest, nY)
1672                  newQuest.Droppable = .Data(colDnld.cDroppable, nY)
1674                  If bIsNew Then newQuest.Completed = False Else newQuest.Completed = Quests(qi).Completed
1676                  QuestEdit newQuest, bIsNew
1678          End Select
1680      End With
1682      Exit Sub
erh:
1684      HandleErr "lstDnldQuests_Change"
End Sub

Private Sub edtDnldFilter_Change(ByVal nID As Long, ByVal strText As String)
1686      On Error GoTo erh
1688      If tmrDnldFilter.Running Then tmrDnldFilter.Stop
1690      cDnldFilterBy = cQuestName
1692      tmrDnldFilter.Start 750
1694      Exit Sub
erh:
1696      HandleErr "edtDnldFilter_Change"
End Sub

Private Sub tmrDnldFilter_Timeout(ByVal Source As DecalInput.IDecalTimer)
1698      On Error GoTo erh
          
1700      If tmrDnldFilter.Running Then tmrDnldFilter.Stop
          
          Dim i As Long, j As Long, bMove As Boolean
          Static FilterLen As Long
          
1702      With lstDnldQuests
1704          If Not (cDnldFilterBy = cQuestName And edtDnldFilter.text = "") Then
1706                  Do While i < .Count
1708                      bMove = False
1710                      Select Case cDnldFilterBy
                              Case cQuestName
1712                              If edtDnldFilter.text = "" Then
1714                                  SetDnldColor i
1716                              Else
1718                                  bMove = InStr(.Data(cQuestName, i), edtDnldFilter.text)
1720                                  If bMove Then
1722                                      SetDnldColor i, clrFound
1724                                  Else
1726                                      SetDnldColor i
1728                                  End If
1730                              End If
1732                          Case cChk 'Selected
1734                              bMove = .Data(cChk, i)
1736                          Case cNew 'Updated
1738                              bMove = (.Color(cNew, i) = clrUpdated)
1740                      End Select
                          
1742                      If bMove Then
1744                          .InsertRow j
1746                          i = i + 1 'Row gets pushed up by inserting
1748                          CopyDnldQuestRow i, j
1750                          .DeleteRow i
1752                          j = j + 1
1754                      Else
1756                          i = i + 1
1758                      End If
1760                  Loop
1762          Else
                  'Reset the colors
1764              For i = 0 To .Count - 1
1766                  SetDnldColor i
1768              Next
1770          End If
1772      End With

1774      SortDnldQuestList cQuestName, j + 1
          
1776      txtDnldFilterMatches.text = j
1778      lstDnldQuests.JumpToPosition 0
          
1780      Exit Sub
erh:
1782      HandleErr "tmrDnldFilter_Timeout"
End Sub

Private Sub SetDnldColor(row As Long, Optional lColor)
1784      On Error GoTo erh
1786      With lstDnldQuests
1788          If IsMissing(lColor) Then
1790              If .Data(cChk, row) Then
1792                  lColor = clrSelected
1794              Else
1796                  lColor = .Color(cNew, row)
1798              End If
1800          End If
1802          .Color(cQuestName, row) = lColor
1804          .Color(cDateAdded, row) = lColor
1806          .Color(cDuration, row) = lColor
1808      End With
1810      Exit Sub
erh:
1812      HandleErr "SetDnldColor"
End Sub

Private Sub btnDnldShowSelected_Accepted(ByVal nID As Long)
1814      On Error GoTo erh
1816      cDnldFilterBy = cChk
1818      tmrDnldFilter_Timeout tmrDnldFilter
1820      Exit Sub
erh:
1822      HandleErr "btnDnldShowSelected_Accepted"
End Sub

Private Sub btnDnldShowUpdated_Accepted(ByVal nID As Long)
1824      On Error GoTo erh
1826      cDnldFilterBy = cNew
1828      tmrDnldFilter_Timeout tmrDnldFilter
1830      Exit Sub
erh:
1832      HandleErr "btnDnldShowUpdated_Accepted"
End Sub

Private Sub btnDnldSelNew_Accepted(ByVal nID As Long)
1834      On Error GoTo erh
          Dim i As Long
1836      With lstDnldQuests
1838          For i = 0 To .Count - 1
1840              If .Color(colDnld.cNew, i) = clrNew Then
1842                  .Data(colDnld.cChk, i) = True
1844                  Call lstDnldQuests_Change(lstDnldQuests.id, colDnld.cChk, i)
1846              End If
1848          Next
1850      End With
1852      Exit Sub
erh:
1854      HandleErr "btnDnldSelNew_Accepted"
End Sub

Private Sub btnDnldSelUpdated_Accepted(ByVal nID As Long)
1856      On Error GoTo erh
          Dim i As Long
1858      With lstDnldQuests
1860          For i = 0 To .Count - 1
1862              If .Color(colDnld.cNew, i) = clrUpdated Then
1864                  .Data(colDnld.cChk, i) = True
1866                  Call lstDnldQuests_Change(lstDnldQuests.id, colDnld.cChk, i)
1868              End If
1870          Next
1872      End With
1874      Exit Sub
erh:
1876      HandleErr "btnDnldSelUpdated_Accepted"
End Sub

Private Sub btnDnldSelAll_Accepted(ByVal nID As Long)
1878      On Error GoTo erh
          Dim i As Long
1880      With lstDnldQuests
1882          For i = 0 To .Count - 1
1884              .Data(colDnld.cChk, i) = True
1886              Call lstDnldQuests_Change(lstDnldQuests.id, colDnld.cChk, i)
1888          Next
1890      End With
1892      Exit Sub
erh:
1894      HandleErr "btnDnldSelAll_Accepted"
End Sub

Private Sub btnDnldSelNone_Accepted(ByVal nID As Long)
1896      On Error GoTo erh
          Dim i As Long
1898      With lstDnldQuests
1900          For i = 0 To .Count - 1
1902              .Data(colDnld.cChk, i) = False
1904              Call lstDnldQuests_Change(lstDnldQuests.id, colDnld.cChk, i)
1906          Next
1908      End With
1910      Exit Sub
erh:
1912      HandleErr "btnDnldSelNone_Accepted"
End Sub

Private Sub btnDnldAddSel_Accepted(ByVal nID As Long)
1914      On Error GoTo erh
          Dim i As Long, ct As Long, dCmpl As Date, qi As Long
1916      With lstDnldQuests
1918          Do While i < .Count
1920              If .Data(colDnld.cChk, i) = True Then
1922                  qi = QuestIndex(.Data(colDnld.cQuestName, i))
1924                  If qi >= 0 Then dCmpl = Quests(qi).Completed Else dCmpl = False
1926                  AddEditQuest .Data(colDnld.cQuestName, i), _
                          .Data(colDnld.cDays, i), .Data(colDnld.cHours, i), .Data(colDnld.cMinutes, i), _
                          .Data(colDnld.cText, i), .Data(colDnld.cItem, i), .Data(colDnld.cChest, i), _
                          .Data(colDnld.cDroppable, i), dCmpl, qi
                      '^ This removes the row so no need to increment i
1928                  ct = ct + 1
1930              Else
1932                  i = i + 1
1934              End If
1936          Loop
1938          RefreshInternetLists
1940          ArrangeByTimeLeft
1942          SaveQuests
1944          wtcwMessage IIf(ct > 0, "«2»" & ct, "No") & "«d» quest" & IIf(ct <> 1, "s", "") & " added"
              '"No quests added" / "1 quest added" / "4 quests added" ...
1946      End With
1948      Exit Sub
erh:
1950      HandleErr "btnDnldAddSel_Accepted"
End Sub

'**  Internet Tab -> Submit Quests  *******************************************
Private Sub lstSubmitQuests_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
1952      On Error GoTo erh
1954      With lstSubmitQuests
1956          If nX = colSubmit.cSubName Then .Data(colSubmit.cSubChk, nY) = Not .Data(colSubmit.cSubChk, nY)
1958          If .Data(colSubmit.cSubChk, nY) Then
1960              If .Color(colSubmit.cSubInfo, nY) = clrUpdated And Not bWarnedUploadEditSelf Then
1962                  bWarnedUploadEditSelf = True
1964                  wtcwWarning "Please only upload quest definitions that «2»you«d» have edited yourself.  " & _
                          "Otherwise, it's likely that the version on the «2»Available«d» tab is newer than yours."
1966              End If
1968              .Color(colSubmit.cSubName, nY) = clrSelected
1970          Else
1972              .Color(colSubmit.cSubName, nY) = .Color(colSubmit.cSubInfo, nY)
1974          End If
1976      End With
1978      Exit Sub
erh:
1980      HandleErr "lstSubmitQuests_Change"
End Sub

Private Sub btnSubmitSelQuests_Accepted(ByVal nID As Long)
1982      On Error GoTo erh
1984      If webSubmitQuests.isRunning Then
1986          wtcwWarning "There is already a submit in progress"
1988      Else
1990          wtcwMessage "Submtting quests..."
1992          SubmitQuests
1994      End If
1996      Exit Sub
erh:
1998      HandleErr "btnSubmitSelQuests_Accepted"
End Sub

'**  Settings Tab  ************************************************
Private Sub chkWebNewQuests_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2000      SaveSettings
End Sub
Private Sub chkWebNewVersion_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2002      SaveSettings
End Sub
Private Sub chkWebNews_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2004      SaveSettings
End Sub
Private Sub chkWebOnlyUpdateNew_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2006      SaveSettings
End Sub
Private Sub chkWebSaveBackups_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2008      SaveSettings
End Sub
Private Sub chkWebTreestats_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2010      SaveSettings
End Sub
Private Sub edtWebDownloadURL_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2012      SaveSettings
End Sub
Private Sub chkWebOnlyUploadNew_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2014      SaveSettings
End Sub
Private Sub choWebMismatch_Change(ByVal nID As Long, ByVal nIndex As Long)
2016      SaveSettings
End Sub
Private Sub edtWebUploadURL_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2018      SaveSettings
End Sub
Private Sub edtWebPassword_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2020      SaveSettings
End Sub
Private Sub chkCheckFileTime_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2022      SaveSettings
End Sub
Private Sub chkShowTimeUp_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2024      SaveSettings
End Sub
Private Sub edtWebUsername_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2026      SaveSettings
End Sub

Private Sub chkWebUpload_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2028      On Error GoTo erh
2030      If bChecked And Not chkWebDownload.Checked Then
2032          wtcwWarning "«3»Warning! «d»You currently have Auto Uploading ENabled and Auto Downloading DISabled.  " & _
                  "This could cause loss of quest information.  It's recommended to have either both on or both off."
2034      End If
2036      SaveSettings
2038      Exit Sub
erh:
2040      HandleErr "chkWebUpload_Change"
End Sub
Private Sub chkWebDownload_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2042      On Error GoTo erh
2044      If Not bChecked And chkWebUpload.Checked Then
2046          wtcwWarning "«3»Warning! «d»You currently have Auto Uploading ENabled and Auto Downloading DISabled.  " & _
                  "This could cause loss of quest information.  It's recommended to have either both on or both off."
2048      End If
2050      SaveSettings
2052      Exit Sub
erh:
2054      HandleErr "chkWebDownload_Change"
End Sub

Private Sub edtWebBackupCt_Begin(ByVal nID As Long)
2056      On Error GoTo erh
2058      chkWebSaveBackups.Checked = True
2060      SaveSettings
2062      Exit Sub
erh:
2064      HandleErr "edtWebBackupCt_Begin"
End Sub

Private Sub edtWebBackupCt_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2066      On Error GoTo erh
2068      If Int(Val(edtWebBackupCt.text)) < 1 Then
2070          edtWebBackupCt.text = "1"
2072      Else
2074          edtWebBackupCt.text = Int(Val(edtWebBackupCt.text))
2076      End If
2078      SaveSettings
2080      Exit Sub
erh:
2082      HandleErr "edtWebBackupCt_End"
End Sub

Private Sub chkAutoResetQuests_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2084      On Error GoTo erh
2086      If bChecked Then wtcwMessage "Quest Timer will automatically reset quests that expired more than «2»" & _
              Int(Val(edtAutoResetQuests.text)) & "«d» days ago next time you log in."
          
2088      If nID <> -1 Then SaveSettings
          
2090      Exit Sub
erh:
2092      HandleErr "chkAutoResetQuests_Change"
End Sub

Private Sub edtAutoResetQuests_End(ByVal nID As Long, ByVal bSuccess As Boolean)
2094      On Error GoTo erh
2096      If Int(Val(edtAutoResetQuests.text)) < 1 Then
2098          edtAutoResetQuests.text = "1"
2100      Else
2102          edtAutoResetQuests.text = Int(Val(edtAutoResetQuests.text))
2104      End If
          
2106      If Not chkAutoResetQuests.Checked Then
2108          chkAutoResetQuests.Checked = True
2110          chkAutoResetQuests_Change -1, True
2112      End If
          
2114      SaveSettings
2116      Exit Sub
erh:
2118      HandleErr "edtAutoResetQuests_End"
End Sub

Private Sub btnWebCheckNow_Accepted(ByVal nID As Long)
2120      On Error GoTo erh
2122      If webNewQuests.isRunning Then
2124          wtcwWarning "There is already a check in progress"
2126      Else
2128          wtcwMessage "Checking for new quests..."
2130          CheckNewQuests
2132          bCheckNowClicked = True
2134      End If
2136      Exit Sub
erh:
2138      HandleErr "btnWebCheckNow_Accepted"
End Sub

Private Sub btnWebDownloadNow_Accepted(ByVal nID As Long)
2140      On Error GoTo erh
2142      If webGetQuestXML.isRunning Then
2144          wtcwWarning "There is already a download in progress"
2146      Else
2148          wtcwMessage "Downloading quests..."
2150          DownloadQuests
2152          bDownloadNowClicked = True
2154      End If
2156      Exit Sub
erh:
2158      HandleErr "btnWebDownloadNow_Accepted"
End Sub

Private Sub btnWebUploadNow_Accepted(ByVal nID As Long)
2160      On Error GoTo erh
2162      If webSendQuestXML.isRunning Then
2164          wtcwWarning "There is already an upload in progress"
2166      Else
2168          wtcwMessage "Uploading quests..."
2170          UploadQuests
2172      End If
2174      Exit Sub
erh:
2176      HandleErr "btnWebUploadNow_Accepted"
End Sub

Private Sub btnWebUserHelp_Accepted(ByVal nID As Long)
2178      On Error GoTo erh
2180      wtcwMessage "You «2»may«d» need to have a user name and password so that the server can uniquely identify you"
2182      wtcwMessage "The password is sent in clear text; «6»do not use your AC password or any other sensitive password!"
2184      wtcwMessage "If your user name doesn't exist, it will be created"
2186      Exit Sub
erh:
2188      HandleErr "btnWebUserHelp_Accepted"
End Sub

Private Sub btnWebHelpMismatch_Accepted(ByVal nID As Long)
2190      On Error GoTo erh
2192      wtcwMessage "This determines what happens if other characters' timer data on the server doesn't match what you uploaded"
2194      wtcwMessage "«2»Overwrite«d» - Don't check at all -- this was the behavior in previous versions of Quest Timer"
2196      wtcwMessage "«2»Alert me«d» - If there's a mismatch, abort uploading the file (no changes made to the file on the server)"
2198      wtcwMessage "«2»Merge«d» - If there's a mismatch, add the info from the server's file to the uploaded file (both the server's file and your local file are changed)"
2200      wtcwMessage "The «2»Alert me«d» and «2»Merge«d» settings can lessen the chance of accidentally losing quest info when uploading"
2202      Exit Sub
erh:
2204      HandleErr "btnWebHelpMismatch_Accepted"
End Sub

Private Sub btnWebDefaultURLs_Accepted(ByVal nID As Long)
2206      On Error GoTo erh
2208      QuestDatabaseURL = sWebURL
2210      edtWebUploadURL.text = sWebURL
2212      edtWebDownloadURL.text = sWebURL
2214      TreestatsURL = TREESTATS_URL
2216      SaveSettings
2218      Exit Sub
erh:
2220      HandleErr "btnWebDefaultURLs_Accepted"
End Sub

Private Sub lnkInternetSettings_Change(ByVal nID As Long, ByVal bChecked As Boolean)
2222      On Error GoTo erh
2224      nbkMain.ActiveTab = tabMain.tInternet
2226      nbkInternet.ActiveTab = tabInternet.tInternetSettings
2228      Exit Sub
erh:
2230      HandleErr "lnkInternetSettings_Change"
End Sub


'******************************************************************************
'**  Quest Functions  *********************************************************
'******************************************************************************

Private Sub UpdateList()
2232      On Error GoTo erh
          Dim i As Long, tmpQuestName As String
2234      If choQuestNotes.Selected >= 0 Then tmpQuestName = choQuestNotes.text(choQuestNotes.Selected)
2236      QuestsList.Clear
2238      choQuestNotes.Clear
2240      For i = 0 To UBound(Quests)
2242          QuestsList.AddRow
2244          QuestsList.Data(colQuest.cName, i) = Quests(i).QuestName
2246          QuestsList.Data(colQuest.cTimeLeft, i) = GetTimeLeft(i)
2248          QuestsList.Data(colQuest.cNotes, i) = "Notes"
2250          QuestsList.Color(colQuest.cNotes, i) = clrLightGreen 'Light Green
2252          QuestsList.Data(colQuest.cEdit, i) = "Edit"
2254          QuestsList.Color(colQuest.cEdit, i) = clrView 'Light Orange
2256          QuestsList.Data(colQuest.cDelete, i, 1) = icnDelete
2258          choQuestNotes.AddChoice Quests(i).QuestName
2260          If Quests(i).QuestName = tmpQuestName Then choQuestNotes.Selected = choQuestNotes.ChoiceCount - 1
2262      Next i
2264      Exit Sub
erh:
2266      HandleErr "UpdateList"
End Sub

Private Sub AddEditQuest(QuestName As String, Days As Long, Hours As Long, Minutes As Long, text As String, _
        Item As String, chest As String, Droppable As Boolean, CompDate As Date, Optional ByVal editIndex As Long = -1)
2268      On Error GoTo erh
          Dim i As Long, bFound As Boolean, bFound2 As Boolean
2270      If editIndex < 0 Or editIndex > UBound(Quests) Then
2272          If Not firstQuest Then ReDim Preserve Quests(UBound(Quests) + 1) Else ReDim Quests(0)
2274          firstQuest = False
2276          editIndex = UBound(Quests)
2278      End If
2280      Quests(editIndex).QuestName = QuestName
2282      Quests(editIndex).Days = Days
2284      Quests(editIndex).Hours = Hours
2286      Quests(editIndex).Minutes = Minutes
2288      Quests(editIndex).text = text
2290      Quests(editIndex).Item = Item
2292      Quests(editIndex).chest = chest
2294      Quests(editIndex).Droppable = Droppable
2296      Quests(editIndex).Completed = CompDate
2298      Quests(editIndex).Told = False
2300      Set Quests(editIndex).IOwn = New Collection
2302      checkIOwn2 editIndex
          
2304      With lstDnldQuests
2306          For i = 0 To .Count - 1 'Remove from list of available downloaded quests
2308              If .Data(colDnld.cQuestName, i) = QuestName And _
                          .Data(colDnld.cDays, i) = Days And _
                          .Data(colDnld.cHours, i) = Hours And _
                          .Data(colDnld.cMinutes, i) = Minutes And _
                          .Data(colDnld.cText, i) = text And _
                          .Data(colDnld.cItem, i) = Item And _
                          .Data(colDnld.cChest, i) = chest And _
                          .Data(colDnld.cDroppable, i) = Droppable And _
                          .Color(colDnld.cQuestName, i) <> clrUpdated Then
2310                  .DeleteRow i
2312                  bFound = True
2314                  Exit For
2316              End If
2318          Next i
2320      End With
2322      If Not bFound Then RefreshInternetLists
2324      Exit Sub
erh:
2326      HandleErr "AddEditQuest"
End Sub

Private Sub RemoveQuest(tmpQuestName As String)
2328      On Error GoTo erh
          Dim i As Long, j As Long
2330      For i = 0 To UBound(Quests)
2332          If Quests(i).QuestName = tmpQuestName Then
2334              For j = i To UBound(Quests) - 1
2336                  Quests(j) = Quests(j + 1)
2338              Next j
2340              If UBound(Quests) = 0 Then ClearQuests Else ReDim Preserve Quests(UBound(Quests) - 1)
2342              Exit For
2344          End If
2346      Next i
2348      For i = 0 To choQuestNotes.ChoiceCount - 1
2350          If choQuestNotes.text(i) = tmpQuestName Then
2352              choQuestNotes.RemoveChoice i
2354              Exit For
2356          End If
2358      Next i
2360      RefreshInternetLists
2362      Exit Sub
erh:
2364      HandleErr "RemoveQuest"
End Sub

Private Sub ClearQuests()
2366      On Error GoTo erh
2368      ReDim Quests(0)
2370      Quests(0).QuestName = "No Quests"
2372      Quests(0).Days = 0
2374      Quests(0).Hours = 0
2376      Quests(0).Minutes = 0
2378      Quests(0).text = ""
2380      Quests(0).Item = ""
2382      Quests(0).chest = ""
2384      Quests(0).Completed = False
2386      firstQuest = True
2388      QuestsList.Clear
2390      QuestsList.AddRow
2392      QuestsList.Data(colQuest.cName, 0) = "No Quests"
2394      Exit Sub
erh:
2396      HandleErr "clearQuests"
End Sub

Private Sub QuestEdit(theQuest As Quest, Optional bIsNew As Boolean = False)
2398      On Error GoTo erh
2400      QuestNameEdit.text = theQuest.QuestName
2402      DaysEdit.text = theQuest.Days
2404      HoursEdit.text = theQuest.Hours
2406      MinutesEdit.text = theQuest.Minutes
2408      TextEdit.text = theQuest.text
2410      ItemEdit.text = theQuest.Item
2412      Droppable.Checked = theQuest.Droppable
2414      ChestEdit.text = theQuest.chest
2416      If theQuest.Completed Then
2418          CompletedCheck.Checked = True
2420          edtDate.TextColor = vbWhite
2422          edtDate.text = Format(theQuest.Completed, "dd-mmm-yyyy")
2424          edtTime.TextColor = vbWhite
2426          edtTime.text = Format(theQuest.Completed, "Long Time")
2428      Else
2430          CompletedCheck.Checked = False
2432          edtDate.text = ""
2434          edtTime.text = ""
2436      End If
2438      AddQuestBtn.text = IIf(bIsNew, "Add Quest", "Edit Quest")
2440      nbkMain.ActiveTab = tabMain.tAddEdit
2442      Exit Sub
erh:
2444      HandleErr "QuestEdit"
End Sub

Private Function QuestIndex(sQuestName As String) As Long
2446      On Error GoTo erh
2448      For QuestIndex = 0 To UBound(Quests)
2450          If sQuestName = Quests(QuestIndex).QuestName Then Exit Function
2452      Next QuestIndex
2454      QuestIndex = -1 'Returns -1 if not found
2456      Exit Function
erh:
2458      HandleErr "QuestIndex"
End Function

Private Function GetTimeLeft(i As Long) As String
2460      On Error GoTo erh
2462      If Quests(i).Completed Then
              Dim dTimeLeft As Date
2464          dTimeLeft = ExpireTime(i) - Now
2466          If dTimeLeft < 0 Then
2468              GetTimeLeft = "Time Up"
2470          Else
2472              GetTimeLeft = DateDiff("d", 0, dTimeLeft) & "D " & Format(dTimeLeft, "hh""H"" nn""M"" ss""S""")
2474          End If
2476      Else
2478          GetTimeLeft = "Not Completed"
2480      End If
2482      Exit Function
erh:
2484      HandleErr "GetTimeLeft"
End Function

Private Function ExpireTime(i As Long) As Date
2486      On Error GoTo erh
2488      If Quests(i).Completed Then
2490          ExpireTime = DateAdd("d", Quests(i).Days, Quests(i).Completed)
2492          ExpireTime = DateAdd("h", Quests(i).Hours, ExpireTime)
2494          ExpireTime = DateAdd("n", Quests(i).Minutes, ExpireTime)
2496      Else
2498          ExpireTime = False
2500      End If
2502      Exit Function
erh:
2504      HandleErr "ExpireTime"
End Function

Private Sub ArrangeByTimeLeft()
2506      On Error GoTo erh
2508      If bLoggedIn Then
              Dim i As Long, j As Long, tmpQuest As Quest, dExpI As Date, dExpJ As Date
2510          For i = 0 To UBound(Quests)
2512              For j = 0 To UBound(Quests)
2514                  dExpI = ExpireTime(i)
2516                  dExpJ = ExpireTime(j)
2518                  If dExpI < dExpJ And CBool(dExpI And dExpJ) Or _
                      dExpI > dExpJ And Not CBool(dExpI And dExpJ) Or _
                      dExpI = dExpJ And Quests(i).QuestName < Quests(j).QuestName Then
2520                      tmpQuest = Quests(j)
2522                      Quests(j) = Quests(i)
2524                      Quests(i) = tmpQuest
2526                  End If
2528              Next j
2530          Next i
2532          UpdateList
2534      End If
2536      Exit Sub
erh:
2538      HandleErr "ArrangeByTimeLeft"
End Sub

Private Sub ArrangeByName()
2540      On Error GoTo erh
2542      If bLoggedIn Then
              Dim i As Long, j As Long, tmpQuest As Quest
2544          For i = 0 To UBound(Quests)
2546              For j = 0 To UBound(Quests)
2548                  If Quests(i).QuestName < Quests(j).QuestName Then
2550                      tmpQuest = Quests(j)
2552                      Quests(j) = Quests(i)
2554                      Quests(i) = tmpQuest
2556                  End If
2558              Next j
2560          Next i
2562          UpdateList
2564      End If
2566      Exit Sub
erh:
2568      HandleErr "ArrangeByName"
End Sub

'******************************************************************************
'**  Other Character's Quests Functions  **************************************
'******************************************************************************


'******************************************************************************
'**  Merging Functions  *******************************************************
'******************************************************************************
Private Sub MergeQuests()
2570      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement
          Dim IQuestsXML As New DOMDocument40, IQuestNode As IXMLDOMElement
          Dim bFoundQuest As Boolean, bQuestsAdded As Boolean
2572      If Not FSO.FileExists(App.Path & "\merge_quests.xml") Then
2574          wtcwWarning "Merge file does not exist. Unable to merge!"
2576      ElseIf Not QuestsXML.Load(App.Path & "\quests.xml") Then
2578          wtcwError "Failed to load «2»quests.xml"
2580      ElseIf Not IQuestsXML.Load(App.Path & "\merge_quests.xml") Then
2582          wtcwError "Failed to load «2»merge_quests.xml"
2584      Else
2586          bQuestsAdded = False
2588          For Each IQuestNode In IQuestsXML.documentElement.getElementsByTagName("Quest")
2590              bFoundQuest = False
2592              For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
2594                  If IQuestNode.getAttribute("QuestName") = QuestNode.getAttribute("QuestName") Then
2596                      bFoundQuest = True
2598                      Exit For
2600                  End If
2602              Next QuestNode
2604              If Not bFoundQuest Then
2606                  QuestsXML.documentElement.appendChild IQuestNode
2608                  wtcwMessage "Adding quest: «14»" & IQuestNode.getAttribute("QuestName")
2610                  bQuestsAdded = True
2612              End If
2614          Next IQuestNode
              
2616          FSO.DeleteFile App.Path & "\merge_quests.xml"
              
2618          If bQuestsAdded Then
2620              WriteXML QuestsXML, App.Path & "\quests.xml"
2622              JustSavedQuestsXML True
2624              LoadQuests
                  
2626              wtcwMessage "New quests merged successfully! Merge file deleted."
2628          Else
2630              wtcwMessage "No new quests to add. Merge file deleted."
2632          End If
2634      End If
erh:
2636      If Err.Number <> 0 Then HandleErr "MergeQuests"
2638      Set QuestsXML = Nothing
2640      Set QuestNode = Nothing
2642      Set IQuestsXML = Nothing
2644      Set IQuestNode = Nothing
End Sub

Private Sub DeleteMergeFile()
2646      On Error GoTo erh
2648      If FSO.FileExists(App.Path & "\merge_quests.xml") Then
2650          FSO.DeleteFile (App.Path & "\merge_quests.xml")
2652          wtcwMessage "Merge file successfully deleted. You won't receive any more messages at startup."
2654      Else
2656          wtcwWarning "No merge file exists to delete!"
2658      End If
2660      Exit Sub
erh:
2662      HandleErr "DeleteMergeFile"
End Sub

Private Sub ExportMergeFile()
2664      On Error GoTo erh
          Dim EQuestsXML As New DOMDocument40, EQuestNode As IXMLDOMElement, ECharNode As IXMLDOMElement
2666      If Not EQuestsXML.Load(App.Path & "\quests.xml") Then
2668          wtcwError "Failed to load the «2»quests.xml«d» file."
2670      Else
2672          For Each EQuestNode In EQuestsXML.documentElement.getElementsByTagName("Quest")
2674              For Each ECharNode In EQuestNode.getElementsByTagName("Character")
2676                  EQuestNode.removeChild ECharNode
2678              Next ECharNode
2680          Next EQuestNode
2682          EQuestsXML.insertBefore _
                  EQuestsXML.createComment(" This merge file was automatically created by " & sPluginNameVer & _
                      " for " & CharStats.Name & " of " & CharStats.Server & vbNewLine & _
                      "Put this file in the Quest Timer installation folder and run Quest Timer to merge it with your quests. "), _
                  EQuestsXML.documentElement
2684          EQuestsXML.save App.Path & "\merge_quests.xml"
              
2686          wtcwMessage "Merge file successfully saved to «14»" & App.Path & "\«2»merge_quests.xml"
2688          wtcwMessage "You should move it to another location to avoid getting messages upon login, or deleting it by merging it"
2690      End If
erh:
2692      If Err.Number <> 0 Then HandleErr "ExportMergeFile"
2694      Set EQuestsXML = Nothing
2696      Set EQuestNode = Nothing
2698      Set ECharNode = Nothing
End Sub

'******************************************************************************
'**  Note Functions  **********************************************************
'******************************************************************************

Private Sub AddNote(sText As String, sQuestName As String)
2700      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, NoteNode As IXMLDOMElement
          
2702      If Not QuestsXML.Load(App.Path & "\quests.xml") Then
2704          wtcwError "Failed to load «2»quests.xml"
2706      Else
2708          For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
2710              If QuestNode.getAttribute("QuestName") = sQuestName Then
2712                  Set NoteNode = QuestNode.appendChild(QuestsXML.createElement("Note"))
2714                  NoteNode.text = sText
2716                  Exit For
2718              End If
2720          Next QuestNode
2722          WriteXML QuestsXML, App.Path & "\quests.xml"
2724          JustSavedQuestsXML True
              
2726          If choQuestNotes.Selected >= 0 Then _
                  If sQuestName = choQuestNotes.text(choQuestNotes.Selected) Then AddNoteList sText
2728      End If
2730      GoTo EndSub
erh:
2732      HandleErr "AddNote"
EndSub:
2734      Set NoteNode = Nothing
2736      Set QuestNode = Nothing
2738      Set QuestsXML = Nothing
End Sub

Private Sub LoadNotes(sQuestName As String)
2740      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, NoteNode As IXMLDOMElement
2742      If Not QuestsXML.Load(App.Path & "\quests.xml") Then
2744          wtcwError "Failed to load «2»quests.xml"
2746      Else
2748          lstNotes.Clear
2750          For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
2752              If QuestNode.getAttribute("QuestName") = sQuestName Then
2754                  For Each NoteNode In QuestNode.getElementsByTagName("Note")
2756                      AddNoteList NoteNode.text
2758                  Next NoteNode
2760                  Exit For
2762              End If
2764          Next QuestNode
2766      End If
2768      GoTo EndSub
erh:
2770      HandleErr "LoadNotes"
EndSub:
2772      Set NoteNode = Nothing
2774      Set QuestNode = Nothing
2776      Set QuestsXML = Nothing
End Sub

Private Sub AddNoteList(sText As String)
2778      On Error GoTo erh
          Dim row As Long
2780      row = lstNotes.AddRow
2782      lstNotes.Data(colNote.cText, row) = sText
2784      lstNotes.Data(colNote.cCopy, row) = "Copy"
2786      lstNotes.Color(colNote.cCopy, row) = clrLightGreen 'Light Green
2788      lstNotes.Data(colNote.cSay, row) = "/say"
2790      lstNotes.Data(colNote.cFellow, row) = "/f"
2792      lstNotes.Color(colNote.cFellow, row) = &H39FFFF 'Bright yellow
2794      lstNotes.Data(colNote.cDelete, row, 1) = icnDelete
2796      Exit Sub
erh:
2798      HandleErr "AddNoteList"
End Sub

Private Sub RemoveNote(nIndex As Long)
          'ASSUMES the list and XML have the same indicies, which should be
          'true if the provided functions were used when loading/adding notes
2800      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, NoteNode As IXMLDOMElement
          
2802      If Not QuestsXML.Load(App.Path & "\quests.xml") Then
2804          wtcwError "Failed to load «2»quests.xml"
2806      Else
2808          For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
2810              If QuestNode.getAttribute("QuestName") = choQuestNotes.text(choQuestNotes.Selected) Then
2812                  QuestNode.removeChild QuestNode.getElementsByTagName("Note").Item(nIndex)
2814                  Exit For
2816              End If
2818          Next QuestNode
2820          QuestsXML.save App.Path & "\quests.xml"
2822          JustSavedQuestsXML True
              
2824          lstNotes.DeleteRow nIndex
2826      End If
2828      GoTo EndSub
erh:
2830      HandleErr "RemoveNote"
EndSub:
2832      Set QuestNode = Nothing
2834      Set QuestsXML = Nothing
End Sub

'******************************************************************************
'**  Quest Loading/Saving  ****************************************************
'******************************************************************************

' Fixes the times in the QuestsXML file if the timezone has changed
' Returns TRUE if it made changes to the XML
Private Function FixTimezone(ByRef QuestsXML As DOMDocument40) As Boolean
2836      On Error GoTo erh
          Dim sOffset As String, dTmp As Date, dOffset As Date, CharacterNode As IXMLDOMElement
          
2838      FixTimezone = False
          
2840      If IsNumeric(QuestsXML.documentElement.getAttribute("GMTOffset")) Then
2842          sOffset = QuestsXML.documentElement.getAttribute("GMTOffset")
              'If the Time Zone has changed (either changed TZ in Windows, or DST)
              'Update the completed date/times
2844          If sOffset <> GMTOffset Then
2846              wtcwWarning "Either your Daylight Savings Time (DST) or Time Zone settings have changed. Updating Quest file..."
2848              dTmp = TimeSerial(Left(sOffset, 3), Mid(sOffset, 4), 0)
2850              dOffset = GMTOffsetD - dTmp
2852              For Each CharacterNode In QuestsXML.selectNodes("//Quest/Character")
2854                  dTmp = CharacterNode.getAttribute("Completed")
2856                  CharacterNode.setAttribute "Completed", ISODate(dTmp + dOffset)
2858              Next
2860              QuestsXML.documentElement.setAttribute "GMTOffset", GMTOffset
2862              FixTimezone = True
2864          End If
2866      End If
          
2868      Exit Function
erh:
2870      HandleErr "FixTimezone"
End Function

Private Sub LoadQuests()
2872      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, CharacterNode As IXMLDOMElement
          Dim i As Long, j As Long, bOtherCharFound As Boolean, sTmpCharName As String
2874      ReDim Quests(0)
2876      choOChar.Clear
2878      choOChar.AddChoice "** All Characters **"
2880      lstOChar.Clear
2882      sAcctChars = ""
          
2884      If Not QuestsXML.Load(App.Path & "\quests.xml") Then
2886          wtcwError "Failed to load the «2»quests.xml«d» file. You should reinstall «2»" & sPluginName
2888      Else
          
2890          If FixTimezone(QuestsXML) Then
2892              WriteXML QuestsXML, App.Path & "\quests.xml"
2894              JustSavedQuestsXML False
2896          End If
          
2898          firstQuest = True
2900          i = 0
2902          ReDim Quests(QuestsXML.documentElement.getElementsByTagName("Quest").length - 1)
2904          For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
2906              firstQuest = False
2908              Quests(i).QuestName = QuestNode.getAttribute("QuestName")
2910              Quests(i).Days = QuestNode.getAttribute("Days")
2912              Quests(i).Hours = QuestNode.getAttribute("Hours")
2914              Quests(i).Minutes = QuestNode.getAttribute("Minutes")
2916              Quests(i).text = QuestNode.getAttribute("Text")
2918              Quests(i).Item = QuestNode.getAttribute("Item")
2920              Quests(i).chest = QuestNode.getAttribute("Chest")
2922              Quests(i).Droppable = QuestNode.getAttribute("Droppable")
2924              Quests(i).Told = False
2926              Set Quests(i).IOwn = New Collection
2928              Quests(i).Completed = False
2930              For Each CharacterNode In QuestNode.getElementsByTagName("Character")
2932                  If CharacterNode.getAttribute("Name") = CharStats.Name And _
                              CharacterNode.getAttribute("Server") = CharStats.Server Then
2934                      Quests(i).Completed = CharacterNode.getAttribute("Completed")
2936                  Else
2938                      bOtherCharFound = False
2940                      sTmpCharName = CharacterNode.getAttribute("Name") & " [" & CharacterNode.getAttribute("Server") & "]"
2942                      For j = 1 To choOChar.ChoiceCount - 1 'Start at 1 because the 0 index is "** All Characters **"
2944                          If choOChar.text(j) = sTmpCharName Then
2946                              bOtherCharFound = True
2948                              Exit For
2950                          End If
2952                      Next j
2954                      If Not bOtherCharFound Then
2956                          choOChar.AddChoice sTmpCharName
2958                          sAcctChars = sAcctChars & sTmpCharName & ","
2960                      End If
2962                  End If
2964              Next CharacterNode
2966              i = i + 1
2968          Next QuestNode
2970      End If
          
2972      If chkAutoResetQuests.Checked Then
              Dim sReset As String, bPlural As Boolean
2974          sReset = ""
2976          bPlural = False
2978          For i = 0 To UBound(Quests)
2980              If CBool(Quests(i).Completed) And Now - ExpireTime(i) > Val(edtAutoResetQuests.text) Then
2982                  Quests(i).Completed = False
2984                  If sReset <> "" Then bPlural = True
2986                  sReset = sReset & "«2»" & Quests(i).QuestName & "«d», "
2988              End If
2990          Next
2992          If Len(sReset) > 0 Then
2994              sReset = Left(sReset, Len(sReset) - 6)
2996              If bPlural Then
2998                  wtcwMessage "The following quests were completed more than «2»" & Val(edtAutoResetQuests.text) & _
                          "«d» days ago and had their timers reset: " & sReset
3000              Else
3002                  wtcwMessage "The following quest was completed more than «2»" & Val(edtAutoResetQuests.text) & _
                          "«d» days ago and had its timer reset: " & sReset
3004              End If
3006              SaveQuests
3008          End If
3010      End If
          
3012      sAcctChars = sAcctChars & CharStats.Name & " [" & CharStats.Server & "]"
3014      checkIOwn
3016      ArrangeByTimeLeft
3018      dLastModify = Now
3020      RefreshInternetLists

          'Update the file if it's old
3022      If Not IsNumeric(QuestsXML.documentElement.getAttribute("FileVer")) Or _
                  Not IsNumeric(QuestsXML.documentElement.getAttribute("GMTOffset")) Then
3024          SaveQuests
3026      ElseIf QuestsXML.documentElement.getAttribute("FileVer") < QuestFileVer Then
3028          SaveQuests
3030      End If
erh:
3032      If Err.Number <> 0 Then HandleErr "LoadQuests"
3034      Set QuestNode = Nothing
3036      Set CharacterNode = Nothing
3038      Set QuestsXML = Nothing
End Sub

Private Sub SaveQuests()
3040      On Error GoTo erh
          Dim QuestsXML As New DOMDocument40, QuestNode As IXMLDOMElement, CharacterNode As IXMLDOMElement
          Dim i As Long, bQuestFound As Boolean, bCharacterFound As Boolean, lFileVer As Long
              
3042      If Not QuestsXML.Load(App.Path & "\quests.xml") Then
3044          wtcwWarning "Failed to load the «2»quests.xml«d» file while saving. Creating new file..."
3046          If FSO.FileExists(App.Path & "\quests.xml") Then
3048              wtcwWarning "This is probably caused by incorrectly editing the file manually.  Creating backup: «2»quests_invalid.xml"
3050              FSO.CopyFile App.Path & "\quests.xml", App.Path & "\quests_invalid.xml"
3052          End If
3054          Set QuestsXML = New DOMDocument40
3056          Set QuestsXML.documentElement = QuestsXML.createElement("Quests")
3058      ElseIf chkCheckFileTime.Checked And dLastModify < FSO.GetFile(App.Path & "\quests.xml").DateLastModified Then
3060          wtcwError "The Quests file was modified outside of this session of AC. This is most likely caused by dual logging."
3062          wtcwError "If you have made changes outside of this session, those changes may be lost."
3064      End If
          
          'Update the file if it's old
3066      If IsNumeric(QuestsXML.documentElement.getAttribute("FileVer")) Then
3068          lFileVer = QuestsXML.documentElement.getAttribute("FileVer")
3070      Else
3072          lFileVer = 0
3074      End If
3076      If lFileVer < 4 Then
3078          For Each CharacterNode In QuestsXML.selectNodes("//Quest/Character")
3080              CharacterNode.setAttribute "Completed", ISODate(CharacterNode.getAttribute("Completed"))
3082          Next CharacterNode
3084          lFileVer = 4
3086      End If
3088      FixTimezone QuestsXML
3090      QuestsXML.documentElement.setAttribute "GMTOffset", GMTOffset
3092      QuestsXML.documentElement.setAttribute "FileVer", QuestFileVer
          
          'Remove any quests that were deleted from the array
3094      For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
3096          bQuestFound = False
3098          For i = 0 To UBound(Quests)
3100              If Quests(i).QuestName = QuestNode.getAttribute("QuestName") Then
3102                  bQuestFound = True
3104                  Exit For
3106              End If
3108          Next i
3110          If Not bQuestFound Then QuestsXML.documentElement.removeChild QuestNode
3112      Next QuestNode
          'Then update/add any quests that were changed/added in the array
3114      For i = 0 To UBound(Quests)
3116          bQuestFound = False
3118          For Each QuestNode In QuestsXML.documentElement.getElementsByTagName("Quest")
                  'Quest alreay exists, update the information in the XML
3120              If Quests(i).QuestName = QuestNode.getAttribute("QuestName") Then
3122                  QuestNode.setAttribute "Days", Quests(i).Days
3124                  QuestNode.setAttribute "Hours", Quests(i).Hours
3126                  QuestNode.setAttribute "Minutes", Quests(i).Minutes
3128                  QuestNode.setAttribute "Text", Quests(i).text
3130                  QuestNode.setAttribute "Item", Quests(i).Item
3132                  QuestNode.setAttribute "Chest", Quests(i).chest
3134                  QuestNode.setAttribute "Droppable", CStr(Quests(i).Droppable)
3136                  bCharacterFound = False
3138                  For Each CharacterNode In QuestNode.getElementsByTagName("Character")
3140                      If CharacterNode.getAttribute("Name") = CharStats.Name And _
                                  CharacterNode.getAttribute("Server") = CharStats.Server Then
3142                          If Quests(i).Completed Then
3144                              CharacterNode.setAttribute "Completed", ISODate(Quests(i).Completed)
3146                              CharacterNode.setAttribute "GUID", CharStats.Character
3148                          Else
3150                              QuestNode.removeChild CharacterNode
3152                          End If
3154                          bCharacterFound = True
3156                          Exit For
3158                      End If
3160                  Next CharacterNode
3162                  If Not bCharacterFound And Quests(i).Completed Then
3164                      Set CharacterNode = QuestsXML.createElement("Character")
3166                      CharacterNode.setAttribute "Name", CharStats.Name
3168                      CharacterNode.setAttribute "Server", CharStats.Server
3170                      CharacterNode.setAttribute "GUID", CharStats.Character
3172                      CharacterNode.setAttribute "Completed", ISODate(Quests(i).Completed)
3174                      QuestNode.appendChild CharacterNode
3176                  End If
3178              bQuestFound = True
3180              Exit For
3182              End If
3184          Next QuestNode
3186          If Not bQuestFound Then
                  'Quest doesn't exist, add it
3188              Set QuestNode = QuestsXML.createElement("Quest")
3190              QuestNode.setAttribute "QuestName", Quests(i).QuestName
3192              QuestNode.setAttribute "Days", Quests(i).Days
3194              QuestNode.setAttribute "Hours", Quests(i).Hours
3196              QuestNode.setAttribute "Minutes", Quests(i).Minutes
3198              QuestNode.setAttribute "Text", Quests(i).text
3200              QuestNode.setAttribute "Item", Quests(i).Item
3202              QuestNode.setAttribute "Chest", Quests(i).chest
3204              QuestNode.setAttribute "Droppable", CStr(Quests(i).Droppable)
3206              If Quests(i).Completed Then
3208                  Set CharacterNode = QuestsXML.createElement("Character")
3210                  CharacterNode.setAttribute "Name", CharStats.Name
3212                  CharacterNode.setAttribute "Server", CharStats.Server
3214                  CharacterNode.setAttribute "GUID", CharStats.Character
3216                  CharacterNode.setAttribute "Completed", ISODate(Quests(i).Completed)
3218                  QuestNode.appendChild CharacterNode
3220              End If
3222              QuestsXML.documentElement.appendChild QuestNode
3224          End If
3226      Next i
3228      WriteXML QuestsXML, App.Path & "\quests.xml"
3230      JustSavedQuestsXML True
3232      GoTo EndSub
erh:
3234      HandleErr "SaveQuests"
EndSub:
3236      Set QuestNode = Nothing
3238      Set CharacterNode = Nothing
3240      Set QuestsXML = Nothing
End Sub

Private Sub JustSavedQuestsXML(bUpload As Boolean)
3242      On Error GoTo erh
3244      If FSO.FileExists(App.Path & "\quests.xml") Then
3246          dLastModify = FSO.GetFile(App.Path & "\quests.xml").DateLastModified
3248      Else
3250          dLastModify = Now
3252      End If
3254      dLastModifyGMT = dLastModify + GMTOffsetD
3256      SaveSettings
3258      If choOChar.Selected <> 0 Then
3260          choOChar.Selected = 0
3262      Else
3264          choOChar_Change 0, 0
3266      End If
3268      If bUpload And chkWebUpload.Checked Then UploadQuests
3270      Exit Sub
erh:
3272      HandleErr "JustSavedQuestsXML"
End Sub

Private Sub BackupQuestFile()
3274      On Error GoTo erh
          Dim Folder As Folder, File As File, ctFiles As Long, FileToDelete As File
3276      If Not FSO.FolderExists(App.Path & "\quest backups") Then
3278          Set Folder = FSO.CreateFolder(App.Path & "\quest backups")
3280      Else
3282          Set Folder = FSO.GetFolder(App.Path & "\quest backups")
3284      End If
          
3286      ctFiles = 0
3288      For Each File In Folder.Files
3290          If File.Name Like "quests *.xml" Then
3292              ctFiles = ctFiles + 1
3294              If FileToDelete Is Nothing Then
3296                  Set FileToDelete = File
3298              ElseIf File.DateLastModified < FileToDelete.DateLastModified Then
3300                  Set FileToDelete = File
3302              End If
3304          End If
3306      Next
          
3308      If ctFiles >= Val(edtWebBackupCt.text) Then
3310          FSO.DeleteFile FileToDelete.Path
3312      End If
          
3314      Set File = FSO.GetFile(App.Path & "\quests.xml")
3316      File.Copy FSO.BuildPath(Folder.Path, "quests " & Replace(ISODate(File.DateLastModified), ":", "-") & ".xml")
          
3318      Set Folder = Nothing
3320      Set File = Nothing
3322      Set FileToDelete = Nothing
3324      Exit Sub
erh:
3326      HandleErr "BackupQuestFile"
End Sub

'******************************************************************************
'**  Settings Loading/Saving  *************************************************
'******************************************************************************

Private Sub LoadSettings()
3328      On Error GoTo erh
          Dim XMLDoc As New DOMDocument40, XMLEle As IXMLDOMElement

3330      If Not XMLDoc.Load(App.Path & "\settings.xml") Then
3332          SaveSettings
3334      ElseIf IsNull(XMLDoc.documentElement.getAttribute("FileVer")) Then 'Old file version, overwrite it
3336          SaveSettings
3338      Else
3340          bLoadingSettings = True
3342          For Each XMLEle In XMLDoc.documentElement.getElementsByTagName("setting")
3344              Select Case XMLEle.getAttribute("Name")
                      Case "chkAutoResetQuests": chkAutoResetQuests.Checked = XMLEle.getAttribute("Value")
3346                  Case "edtAutoResetQuests": edtAutoResetQuests.text = XMLEle.getAttribute("Value")
3348                  Case "chkWebNewVersion": chkWebNewVersion.Checked = XMLEle.getAttribute("Value")
3350                  Case "chkWebNews": chkWebNews.Checked = XMLEle.getAttribute("Value")
3352                  Case "chkWebNewQuests": chkWebNewQuests.Checked = XMLEle.getAttribute("Value")
3354                  Case "QuestDatabaseURL": QuestDatabaseURL = XMLEle.getAttribute("Value")
3356                  Case "TreestatsURL": TreestatsURL = XMLEle.getAttribute("Value")
3358                  Case "edtWebNewQuestsURL": QuestDatabaseURL = XMLEle.getAttribute("Value") 'For compatibility with old files
3360                  Case "chkWebUpload": chkWebUpload.Checked = XMLEle.getAttribute("Value")
3362                  Case "edtWebUploadURL": edtWebUploadURL.text = XMLEle.getAttribute("Value")
3364                  Case "chkWebOnlyUploadNew": chkWebOnlyUploadNew.Checked = XMLEle.getAttribute("Value")
3366                  Case "choWebMismatch": choWebMismatch.Selected = XMLEle.getAttribute("Value")
3368                  Case "chkWebDownload":  chkWebDownload.Checked = XMLEle.getAttribute("Value")
3370                  Case "edtWebDownloadURL": edtWebDownloadURL.text = XMLEle.getAttribute("Value")
3372                  Case "chkWebOnlyUpdateNew": chkWebOnlyUpdateNew.Checked = XMLEle.getAttribute("Value")
3374                  Case "chkWebSaveBackups": chkWebSaveBackups.Checked = XMLEle.getAttribute("Value")
3376                  Case "edtWebBackupCt": edtWebBackupCt.text = XMLEle.getAttribute("Value")
3378                  Case "edtWebUsername": edtWebUsername.text = XMLEle.getAttribute("Value")
3380                  Case "edtWebPassword": edtWebPassword.text = XMLEle.getAttribute("Value")
3382                  Case "chkWebTreestats":
3384                      chkWebTreestats.Checked = XMLEle.getAttribute("Value")
3386                      bFirstRunTS = False
3388                  Case "dLastModifyGMT": dLastModifyGMT = XMLEle.getAttribute("Value")
3390                  Case "lUploadCt": lUploadCt = XMLEle.getAttribute("Value")
3392                  Case "dLastDnldNewGMT": dLastDnldNewGMT = XMLEle.getAttribute("Value"): dDnldNewGMT = dLastDnldNewGMT
3394                  Case "chkShowTimeUp": chkShowTimeUp.Checked = XMLEle.getAttribute("Value")
3396                  Case "chkCheckFileTime": chkCheckFileTime.Checked = XMLEle.getAttribute("Value")
3398              End Select
3400          Next XMLEle
3402          Set colAddtlURLs = New Collection
              Dim tmpUUP As URL_User_Pass
3404          Set XMLEle = XMLDoc.documentElement.selectSingleNode("AdditionalUploadURLs")
3406          If Not XMLEle Is Nothing Then
3408              For Each XMLEle In XMLEle.selectNodes("url")
3410                  If IsNull(XMLEle.getAttribute("username")) Then
3412                      tmpUUP.Username = ""
3414                  Else
3416                      tmpUUP.Username = XMLEle.getAttribute("username")
3418                  End If
3420                  If IsNull(XMLEle.getAttribute("password")) Then
3422                      tmpUUP.Password = ""
3424                  Else
3426                      tmpUUP.Password = XMLEle.getAttribute("password")
3428                  End If
3430                  tmpUUP.URL = XMLEle.text
3432                  colAddtlURLs.Add tmpUUP
3434              Next XMLEle
3436          End If
3438      End If
3440      GoTo EndSub
erh:
3442      HandleErr "LoadSettings"
EndSub:
3444      bLoadingSettings = False
3446      Set XMLDoc = Nothing
3448      Set XMLEle = Nothing
End Sub

Private Sub SaveSettings()
3450      On Error GoTo erh
3452      If bLoadingSettings Then Exit Sub
          Dim XMLDoc As New DOMDocument40, XMLRoot As IXMLDOMElement, XMLNode1 As IXMLDOMElement, XMLNode2 As IXMLDOMElement, tmpUUP

3454      XMLDoc.appendChild XMLDoc.createProcessingInstruction("xml", "version=""1.0""")
3456      Set XMLDoc.documentElement = XMLDoc.createElement("settings")
3458      XMLDoc.documentElement.setAttribute "FileVer", SettingsFileVer
3460      XMLDoc.documentElement.appendChild XMLDoc.createTextNode(vbNewLine)
3462      AddSetting XMLDoc, "chkAutoResetQuests", chkAutoResetQuests.Checked
3464      AddSetting XMLDoc, "edtAutoResetQuests", edtAutoResetQuests.text
3466      AddSetting XMLDoc, "chkWebNewVersion", chkWebNewVersion.Checked
3468      AddSetting XMLDoc, "chkWebNews", chkWebNews.Checked
3470      AddSetting XMLDoc, "chkWebNewQuests", chkWebNewQuests.Checked
3472      AddSetting XMLDoc, "chkWebUpload", chkWebUpload.Checked
3474      AddSetting XMLDoc, "edtWebUploadURL", edtWebUploadURL.text
3476      AddSetting XMLDoc, "chkWebOnlyUploadNew", chkWebOnlyUploadNew.Checked
3478      AddSetting XMLDoc, "choWebMismatch", choWebMismatch.Selected
3480      AddSetting XMLDoc, "QuestDatabaseURL", QuestDatabaseURL
3482      AddSetting XMLDoc, "TreestatsURL", TreestatsURL
3484      XMLDoc.documentElement.appendChild XMLDoc.createTextNode(vbTab)
3486      Set XMLNode1 = XMLDoc.documentElement.appendChild(XMLDoc.createElement("AdditionalUploadURLs"))
3488      For Each tmpUUP In colAddtlURLs
3490          Set XMLNode2 = XMLNode1.appendChild(XMLDoc.createElement("url"))
3492          If tmpUUP.Username <> "" Then XMLNode2.setAttribute "username", tmpUUP.Username
3494          If tmpUUP.Password <> "" Then XMLNode2.setAttribute "password", tmpUUP.Password
3496          XMLNode2.text = tmpUUP.URL
3498      Next tmpUUP
3500      If colAddtlURLs.Count = 0 Then
3502          XMLNode1.appendChild XMLDoc.createTextNode(vbNewLine & vbTab)
3504          XMLNode1.appendChild XMLDoc.createComment( _
                  vbNewLine & vbTab & vbTab & " Use the following syntax (username and password are optional; " & _
                  "if not provided or blank, the username and password in-game will be used)" & _
                  vbNewLine & vbTab & vbTab & "<url username=""Digero"" password=""passw3rd"">http://www.yoursitehere.com/quest_timer.php</url>" & _
                  vbNewLine & vbTab & vbTab & "<url>http://www.uses_default_password.com/quest_timer.php</url>" & vbNewLine & vbTab)
3506          XMLNode1.appendChild XMLDoc.createTextNode(vbNewLine & vbTab)
3508      End If
3510      XMLDoc.documentElement.appendChild XMLDoc.createTextNode(vbNewLine)
3512      AddSetting XMLDoc, "chkWebDownload", chkWebDownload.Checked
3514      AddSetting XMLDoc, "edtWebDownloadURL", edtWebDownloadURL.text
3516      AddSetting XMLDoc, "chkWebOnlyUpdateNew", chkWebOnlyUpdateNew.Checked
3518      AddSetting XMLDoc, "chkWebSaveBackups", chkWebSaveBackups.Checked
3520      AddSetting XMLDoc, "edtWebBackupCt", edtWebBackupCt.text
3522      AddSetting XMLDoc, "edtWebUsername", edtWebUsername.text
3524      AddSetting XMLDoc, "edtWebPassword", edtWebPassword.text
3526      AddSetting XMLDoc, "chkWebTreestats", chkWebTreestats.Checked
3528      AddSetting XMLDoc, "dLastModifyGMT", ISODate(dLastModifyGMT)
3530      AddSetting XMLDoc, "lUploadCt", lUploadCt
3532      AddSetting XMLDoc, "dLastDnldNewGMT", ISODate(dLastDnldNewGMT)
3534      AddSetting XMLDoc, "chkShowTimeUp", chkShowTimeUp.Checked
3536      AddSetting XMLDoc, "chkCheckFileTime", chkCheckFileTime.Checked

3538      XMLDoc.save App.Path & "\settings.xml"
          'WriteXML XMLDoc, App.Path & "\settings.xml"
3540      Exit Sub
erh:
3542      HandleErr "SaveSettings"
End Sub

Private Sub AddSetting(ByRef XMLDoc As DOMDocument40, ByVal settingName As String, ByVal settingVal As String)
          Dim Setting As IXMLDOMElement
3544      Set Setting = XMLDoc.createElement("setting")
3546      Setting.setAttribute "Name", settingName
3548      Setting.setAttribute "Value", settingVal
3550      XMLDoc.documentElement.appendChild XMLDoc.createTextNode(vbTab)
3552      XMLDoc.documentElement.appendChild Setting
3554      XMLDoc.documentElement.appendChild XMLDoc.createTextNode(vbNewLine)
End Sub

'******************************************************************************
'**  Web Functions  ***********************************************************
'******************************************************************************

Private Sub SortDnldQuestList(cSortBy As colDnld, Optional lMinIndex As Long, Optional lMaxIndex As Long)
3556      On Error GoTo erh
3558      If lMaxIndex = 0 Then lMaxIndex = lstDnldQuests.Count - 1
3560      If lMinIndex < 0 Then lMinIndex = 0
3562      If lMaxIndex > lstDnldQuests.Count - 1 Then lMaxIndex = lstDnldQuests.Count - 1
3564      If lMinIndex >= lMaxIndex Then Exit Sub
          Dim i As Long, j As Long, max As Long
3566      With lstDnldQuests
3568          For i = lMinIndex To lMaxIndex
3570              max = i
3572              For j = i + 1 To lMaxIndex
3574                  If cSortBy = cDateAdded Then
3576                      If CDate(.Data(cSortBy, j)) > CDate(.Data(cSortBy, max)) Then max = j
3578                  Else
3580                      If .Data(cSortBy, j) < .Data(cSortBy, max) Then max = j
3582                  End If
3584              Next j
3586              If max <> i Then
3588                  .InsertRow i
3590                  max = max + 1 'index gets pushed up one by inserting a row
3592                  CopyDnldQuestRow max, i
3594                  .DeleteRow max
3596              End If
3598          Next i
3600      End With
3602      Exit Sub
erh:
3604      HandleErr "SortDnldQuestList"
End Sub

Private Sub CopyDnldQuestRow(CopyFrom As Long, CopyTo As Long)
3606      On Error GoTo erh
3608      With lstDnldQuests
3610          .Data(colDnld.cChk, CopyTo) = .Data(colDnld.cChk, CopyFrom)
3612          .Data(colDnld.cQuestName, CopyTo) = .Data(colDnld.cQuestName, CopyFrom)
3614          .Data(colDnld.cDuration, CopyTo) = .Data(colDnld.cDuration, CopyFrom)
3616          .Data(colDnld.cDateAdded, CopyTo) = .Data(colDnld.cDateAdded, CopyFrom)
3618          .Data(colDnld.cAdd, CopyTo, 1) = .Data(colDnld.cAdd, CopyFrom, 1)
3620          .Data(colDnld.cView, CopyTo) = .Data(colDnld.cView, CopyFrom)
3622          .Color(colDnld.cQuestName, CopyTo) = .Color(colDnld.cQuestName, CopyFrom)
3624          .Color(colDnld.cDuration, CopyTo) = .Color(colDnld.cDuration, CopyFrom)
3626          .Color(colDnld.cDateAdded, CopyTo) = .Color(colDnld.cDateAdded, CopyFrom)
3628          .Color(colDnld.cView, CopyTo) = .Color(colDnld.cView, CopyFrom)
              
3630          .Data(colDnld.cNew, CopyTo) = .Data(colDnld.cNew, CopyFrom)
3632          .Color(colDnld.cNew, CopyTo) = .Color(colDnld.cNew, CopyFrom)
3634          .Data(colDnld.cDays, CopyTo) = .Data(colDnld.cDays, CopyFrom)
3636          .Data(colDnld.cHours, CopyTo) = .Data(colDnld.cHours, CopyFrom)
3638          .Data(colDnld.cMinutes, CopyTo) = .Data(colDnld.cMinutes, CopyFrom)
3640          .Data(colDnld.cText, CopyTo) = .Data(colDnld.cText, CopyFrom)
3642          .Data(colDnld.cItem, CopyTo) = .Data(colDnld.cItem, CopyFrom)
3644          .Data(colDnld.cChest, CopyTo) = .Data(colDnld.cChest, CopyFrom)
3646          .Data(colDnld.cDroppable, CopyTo) = .Data(colDnld.cDroppable, CopyFrom)
3648      End With
3650      Exit Sub
erh:
3652      HandleErr "CopyDnldQuestRow"
End Sub

Private Sub RefreshInternetLists()
      'Save processing power -- only update the list if it's active
      'Otherwise it's refreshed in nbkMain_Change when the tab changes to Internet
3654      On Error GoTo erh
3656      If nbkMain.ActiveTab = tabMain.tInternet Then
3658          UpdateInternetLists
3660          bRefreshInternetLists = False
3662      Else
3664          bRefreshInternetLists = True
3666      End If
3668      Exit Sub
erh:
3670      HandleErr "RefreshInternetLists"
End Sub

Private Function UpdateInternetLists() As Boolean 'True if there are new quests
3672      On Error GoTo erh
3674      UpdateInternetLists = False
          Dim DQuestsXML As New DOMDocument40, DQuestNode As IXMLDOMElement, dDateAdded As Date
          Dim RowClr As Long, Days As Long, Hours As Long, Minutes As Long, row As Long
          Dim iQuestIndex As Long, i As Long, SubmitListColor() As Long, bShow As Boolean, sTmpQuestName As String
          'SubmitListColor for Submit Quest list -- stores the color of the row
          '(clrNew - doesnt exist; clrOld - exists w/ same info; clrUpdated - exists w/ diff info)
          
3676      lstDnldQuests.Clear
3678      lstSubmitQuests.Clear
          
3680      If DQuestsXML.Load(App.Path & "\downloaded_quests.xml") Then
3682          ReDim SubmitListColor(UBound(Quests))
3684          For Each DQuestNode In DQuestsXML.documentElement.getElementsByTagName("Quest")
3686              iQuestIndex = QuestIndex(DQuestNode.getAttribute("QuestName"))
3688              sTmpQuestName = DQuestNode.getAttribute("QuestName")
3690              iQuestIndex = -1
3692              bShow = True
3694              For i = 0 To UBound(Quests)
3696                  If Quests(i).QuestName = sTmpQuestName Then
3698                      iQuestIndex = i
3700                      bShow = Not (Quests(iQuestIndex).text = DQuestNode.getAttribute("Text") And _
                              Quests(iQuestIndex).Item = DQuestNode.getAttribute("Item") And _
                              Quests(iQuestIndex).Droppable = DQuestNode.getAttribute("Droppable") And _
                              Quests(iQuestIndex).chest = DQuestNode.getAttribute("Chest") And _
                              Quests(iQuestIndex).Days = DQuestNode.getAttribute("Days") And _
                              Quests(iQuestIndex).Hours = DQuestNode.getAttribute("Hours") And _
                              Quests(iQuestIndex).Minutes = DQuestNode.getAttribute("Minutes"))
3702                      SubmitListColor(i) = IIf(bShow, clrUpdated, clrOld)
3704                      Exit For
3706                  End If
3708              Next i
3710              If bShow Then
3712                  With lstDnldQuests
3714                      If IsDate(DQuestNode.getAttribute("DateAdded")) Then dDateAdded = DQuestNode.getAttribute("DateAdded") Else dDateAdded = False
                          
3716                      If dDateAdded > dDnldNewGMT Then UpdateInternetLists = True
                          
3718                      If iQuestIndex >= 0 Then
3720                          RowClr = clrUpdated
3722                      ElseIf dDateAdded > dDnldNewGMT Then
3724                          RowClr = clrNew
3726                      Else
3728                          RowClr = vbWhite
3730                      End If
                          
3732                      row = .AddRow
3734                      .Data(colDnld.cQuestName, row) = DQuestNode.getAttribute("QuestName")
3736                      Days = DQuestNode.getAttribute("Days")
3738                      Hours = DQuestNode.getAttribute("Hours")
3740                      Minutes = DQuestNode.getAttribute("Minutes")
3742                      .Data(colDnld.cDuration, row) = Days & "D " & Hours & "H " & Minutes & "M"
3744                      If dDateAdded Then
3746                          .Data(colDnld.cDateAdded, row) = Format(dDateAdded, "Short Date")
3748                      Else
3750                          .Data(colDnld.cDateAdded, row) = "Unknown"
3752                      End If
3754                      .Data(colDnld.cAdd, row, 1) = icnAdd
3756                      .Data(colDnld.cView, row) = "View"
3758                      .Color(colDnld.cQuestName, row) = RowClr
3760                      .Color(colDnld.cDuration, row) = RowClr
3762                      .Color(colDnld.cDateAdded, row) = RowClr
3764                      .Color(colDnld.cView, row) = clrView
                          
                          'Hidden columns
3766                      .Color(colDnld.cNew, row) = RowClr
3768                      .Data(colDnld.cDays, row) = Days
3770                      .Data(colDnld.cHours, row) = Hours
3772                      .Data(colDnld.cMinutes, row) = Minutes
3774                      .Data(colDnld.cText, row) = DQuestNode.getAttribute("Text")
3776                      .Data(colDnld.cItem, row) = DQuestNode.getAttribute("Item")
3778                      .Data(colDnld.cChest, row) = DQuestNode.getAttribute("Chest")
3780                      .Data(colDnld.cDroppable, row) = DQuestNode.getAttribute("Droppable")
3782                  End With
3784              End If
3786          Next DQuestNode
              
3788          With lstSubmitQuests
                  Dim SortOrder1 As Long, SortOrder2 As Long, bInserted As Boolean, sInfo As String
3790              For i = 0 To UBound(SubmitListColor)
3792                  bInserted = False
3794                  Select Case SubmitListColor(i)
                          Case clrUpdated: SortOrder1 = 2
3796                          sInfo = "Has Different Info"
3798                      Case clrOld: SortOrder1 = 3
3800                          sInfo = "Already Exists"
3802                      Case Else: SortOrder1 = 1
3804                          sInfo = "New Quest Name"
3806                          SubmitListColor(i) = clrNew
3808                  End Select
3810                  For row = 0 To .Count - 1
3812                      Select Case .Color(colSubmit.cSubName, row)
                              Case clrNew: SortOrder2 = 1
3814                          Case clrUpdated: SortOrder2 = 2
3816                          Case clrOld: SortOrder2 = 3
3818                      End Select
3820                      If SortOrder1 < SortOrder2 Or SortOrder1 = SortOrder2 And _
                                  Quests(i).QuestName < .Data(colSubmit.cSubName, row) Then
3822                          .InsertRow row
3824                          bInserted = True
3826                          Exit For
3828                      End If
3830                  Next row
3832                  If Not bInserted Then row = .AddRow
3834                  .Data(colSubmit.cSubName, row) = Quests(i).QuestName
3836                  .Color(colSubmit.cSubName, row) = SubmitListColor(i)
3838                  .Data(colSubmit.cSubInfo, row) = sInfo
3840                  .Color(colSubmit.cSubInfo, row) = SubmitListColor(i)
3842              Next i
3844          End With
3846      End If
3848      GoTo EndFN
erh:
3850      HandleErr "UpdateInternetLists"
EndFN:
3852      Set DQuestNode = Nothing
3854      Set DQuestsXML = Nothing
End Function

Private Sub CheckNewQuests()
3856      On Error GoTo erh
3858      webNewQuests.Abort
3860      If Not FSO.FileExists(App.Path & "\downloaded_quests.xml") Then dLastDnldNewGMT = #1/1/1990#
3862      webNewQuests.PostRequest QuestDatabaseURL, "newquests", _
              Array("lastcheckdate"), Array(ISODate(dLastDnldNewGMT))
3864      Exit Sub
erh:
3866      HandleErr "CheckNewQuests"
End Sub

Private Sub SubmitQuests()
3868      On Error GoTo erh
          Dim i As Long, colToSubmit As New Collection, Names_() As String, Values() As String
3870      With lstSubmitQuests
3872          For i = 0 To .Count - 1
3874              If .Data(colSubmit.cSubChk, i) Then
3876                  .Data(colSubmit.cSubChk, i) = False
3878                  .Color(colSubmit.cSubName, i) = .Color(colSubmit.cSubInfo, i)
3880                  colToSubmit.Add QuestIndex(.Data(colSubmit.cSubName, i))
3882              End If
3884          Next
3886          If colToSubmit.Count = 0 Then
3888              wtcwWarning "You need to select quest(s) to submit!"
3890          Else
3892              ReDim Names_(colToSubmit.Count * 8 + 1)
3894              ReDim Values(colToSubmit.Count * 8 + 1)
3896              Names_(0) = "total"
3898              Values(0) = colToSubmit.Count
3900              Names_(UBound(Names_)) = "SubmittedBy"
3902              Values(UBound(Values)) = edtSubmittedBy.text
3904              For i = 0 To colToSubmit.Count - 1
3906                  Names_(i * 8 + 1) = "QuestName" & i
3908                  Values(i * 8 + 1) = Quests(colToSubmit(i + 1)).QuestName
3910                  Names_(i * 8 + 2) = "Days" & i
3912                  Values(i * 8 + 2) = Quests(colToSubmit(i + 1)).Days
3914                  Names_(i * 8 + 3) = "Hours" & i
3916                  Values(i * 8 + 3) = Quests(colToSubmit(i + 1)).Hours
3918                  Names_(i * 8 + 4) = "Minutes" & i
3920                  Values(i * 8 + 4) = Quests(colToSubmit(i + 1)).Minutes
3922                  Names_(i * 8 + 5) = "Text" & i
3924                  Values(i * 8 + 5) = Quests(colToSubmit(i + 1)).text
3926                  Names_(i * 8 + 6) = "Item" & i
3928                  Values(i * 8 + 6) = Quests(colToSubmit(i + 1)).Item
3930                  Names_(i * 8 + 7) = "Chest" & i
3932                  Values(i * 8 + 7) = Quests(colToSubmit(i + 1)).chest
3934                  Names_(i * 8 + 8) = "Droppable" & i
3936                  Values(i * 8 + 8) = IIf(Quests(colToSubmit(i + 1)).Droppable, 1, 0)
3938              Next
3940              webSubmitQuests.PostRequest QuestDatabaseURL, "submitquests", Names_, Values
3942          End If
3944      End With
3946      Exit Sub
erh:
3948      HandleErr "SubmitQuests"
End Sub

Private Sub UploadQuests(Optional bFirst As Boolean = True)
3950      On Error GoTo erh
3952      If bFirst Then
3954          ctSendURL = 0
3956          ctSendURLSuccess = 0
3958      End If
          
3960      webSendQuestXML.Abort
3962      webSendTreestats.Abort
          Dim sQuestXML As String, sUploadURL As String, sUsername As String, sPassword As String, tmpUUP As URL_User_Pass
3964      sQuestXML = FSO.OpenTextFile(App.Path & "\quests.xml").ReadAll
3966      If ctSendURL = 0 Then
3968          sUploadURL = edtWebUploadURL.text
3970          sUsername = edtWebUsername.text
3972          sPassword = edtWebPassword.text
3974      Else
3976          tmpUUP = colAddtlURLs(ctSendURL)
3978          sUploadURL = tmpUUP.URL
3980          If tmpUUP.Username = "" Then sUsername = edtWebUsername.text Else sUsername = tmpUUP.Username
3982          If tmpUUP.Password = "" Then sPassword = edtWebPassword.text Else sPassword = tmpUUP.Password
3984      End If
          
          Dim sCompareMerge As String
3986      Select Case choWebMismatch.Selected
              Case optNone:    sCompareMerge = "NONE"
3988          Case optCompare: sCompareMerge = "COMPARE"
3990          Case optMerge:   sCompareMerge = "MERGE"
3992      End Select
          
3994      webSendQuestXML.PostRequest sUploadURL, "savequests", _
              Array("username", "password", "questxml", "lastmodified", "uploadct", "compare_merge"), _
              Array(sUsername, sPassword, sQuestXML, ISODate(dLastModifyGMT), _
                  IIf(chkWebOnlyUploadNew.Checked, lUploadCt, -1), sCompareMerge)
          
3996      If bFirst And chkWebTreestats.Checked Then
              Dim i As Long, j As Long, Names_() As String, Values() As String
              Dim dQuestDuration As Date, lSecLeft As Long
3998          j = 0
4000          For i = LBound(Quests) To UBound(Quests)
4002              If Quests(i).Completed Then
4004                  j = j + 1
4006              End If
4008          Next
4010          ReDim Names_(j * 2)
4012          ReDim Values(j * 2)
4014          Names_(0) = "quest_count"
4016          Values(0) = j
4018          If j > 0 Then
4020              j = 0
4022              For i = LBound(Quests) To UBound(Quests)
4024                  If Quests(i).Completed Then
4026                      Names_(j * 2 + 1) = "quests[" & j & "]"
4028                      Values(j * 2 + 1) = Quests(i).QuestName
4030                      Names_(j * 2 + 2) = "timeleft[" & j & "]"
4032                      dQuestDuration = Quests(i).Days + TimeSerial(Quests(i).Hours, Quests(i).Minutes, 0)
4034                      lSecLeft = (Quests(i).Completed + dQuestDuration - Now) * 24 * 60 * 60
4036                      Values(j * 2 + 2) = lSecLeft
4038                      j = j + 1
4040                  End If
4042              Next
4044          End If
4046          webSendTreestats.PostRequest TreestatsURL, "updatetimers", Names_, Values
4048      End If
          
4050      Exit Sub
erh:
4052      HandleErr "UploadQuests"
End Sub

Private Sub DownloadQuests()
4054      On Error GoTo erh
4056      webGetQuestXML.Abort
          Dim sLastModified As String
4058      sLastModified = ISODate(IIf(chkWebOnlyUpdateNew.Checked, dLastModifyGMT, #1/1/1990#))
          
4060      webGetQuestXML.PostRequest edtWebDownloadURL.text, "loadquests", _
              Array("username", "password", "lastmodified"), _
              Array(edtWebUsername.text, edtWebPassword.text, sLastModified)
4062      Exit Sub
erh:
4064      HandleErr "DownloadQuests"
End Sub

Private Sub webPluginInfo_onFailure(ByVal sErrorMessage As String)
          'Only display an error message if debugging is on
4066      wtcwDebug "Error getting plugin info: «2»" & sErrorMessage
End Sub

Private Sub webPluginInfo_onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
4068      On Error GoTo erh
4070      With ResponseXML.documentElement
4072          If .tagName = "PluginInfo" Then
4074              If .getElementsByTagName("ver").length > 0 And chkWebNewVersion.Checked Then
                      Dim Ver
4076                  Ver = Split(.getElementsByTagName("ver").Item(0).text, ".") 'Index of Major = 0, Minor = 1, Rev = 3
4078                  If Val(Ver(0)) > App.Major Or Val(Ver(0)) = App.Major And (Val(Ver(1)) > App.Minor Or _
                              Val(Ver(1)) = App.Minor And Val(Ver(3)) > App.Revision) Then
4080                      wtcwMessage "There is a new version available: «2»Quest Timer v" & Join(Ver, ".") & "«d». Get it at «17»http://decal.acasylum.com"
4082                      If .getElementsByTagName("whatsnew").length > 0 Then
4084                          wtcwMessage "«2»What's New in v" & Join(Ver, ".") & ":«d» " & .getElementsByTagName("whatsnew").Item(0).text
4086                      End If
4088                  End If
4090              End If
4092              If .getElementsByTagName("motd").length > 0 And chkWebNews.Checked Then
4094                  wtcwMessage .getElementsByTagName("motd").Item(0).text
4096              End If
4098          End If
4100      End With
4102      Exit Sub
erh:
4104      HandleErr "webPluginInfo_onSuccess"
End Sub

Private Sub webNewQuests_onFailure(ByVal sErrorMessage As String)
4106      wtcwError "Error downloading new quests: «2»" & sErrorMessage
4108      bCheckNowClicked = False
End Sub

Private Sub webNewQuests_onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
4110      On Error GoTo erh
          'Server should only return new quests
4112      With ResponseXML.documentElement
4114          If .tagName = "NewQuests" Then
4116              If .childNodes.length > 0 Then 'There are new quests
                      Dim DQuestsXML As New DOMDocument40, DQuestNode As IXMLDOMElement, RQuestNode As IXMLDOMElement
4118                  If Not DQuestsXML.Load(App.Path & "\downloaded_quests.xml") Then
4120                      Set DQuestsXML = New DOMDocument40
4122                      Set DQuestsXML.documentElement = DQuestsXML.createElement("Quests")
4124                      DQuestsXML.documentElement.setAttribute "FileVer", QuestFileVer
4126                  End If
4128                  For Each RQuestNode In .getElementsByTagName("Quest")
                          'Remove quests that are being updated
4130                      For Each DQuestNode In DQuestsXML.documentElement.getElementsByTagName("Quest")
4132                          If DQuestNode.getAttribute("QuestName") = RQuestNode.getAttribute("QuestName") Then
4134                              DQuestsXML.documentElement.removeChild DQuestNode
4136                              Exit For
4138                          End If
4140                      Next DQuestNode
                          'Add new/updated quests to beginning of file
4142                      DQuestsXML.documentElement.insertBefore RQuestNode, DQuestsXML.documentElement.firstChild
4144                  Next RQuestNode
4146                  WriteXML DQuestsXML, App.Path & "\downloaded_quests.xml"
4148                  If UpdateInternetLists Then 'True if new quests were added (i.e., they didn't already exist)
4150                      wtcwMessage "There are new/updated quests available.  Check the Internet tab to see them"
                          Dim Note
4152                      For Each Note In Notes
4154                          wtcwMessage "[Note from server] «2»" & Note
4156                      Next Note
4158                  ElseIf bCheckNowClicked Then
4160                      wtcwMessage "There are no new quests"
4162                  End If
4164              ElseIf bCheckNowClicked Then
4166                  wtcwMessage "There are no new quests"
4168              End If
4170              dLastDnldNewGMT = NowGMT
4172              SaveSettings
4174          Else
4176              wtcwError "Error downloading new quests: «2»The server response appears to be invalid"
4178          End If
4180      End With
4182      bCheckNowClicked = False
4184      Exit Sub
erh:
4186      HandleErr "webNewQuests_onSuccess"
End Sub

Private Sub webSubmitQuests_onFailure(ByVal sErrorMessage As String)
4188      wtcwError "Error submitting Quests: «2»" & sErrorMessage
End Sub

Private Sub webSubmitQuests_onSuccess(ResponseXML As MSXML2.DOMDocument40, Notes As Collection)
4190      On Error GoTo erh
4192      With ResponseXML.documentElement
4194          If .tagName = "Success" Then
4196              If .getAttribute("added") <> "" Then wtcwMessage "Quests submitted: «0»" & .getAttribute("added")
4198              If .getAttribute("updated") <> "" Then wtcwMessage "Quests updated: «3»" & .getAttribute("updated")
4200              If .getAttribute("alreadyexist") <> "" Then wtcwMessage "Quests already exist: «8»" & .getAttribute("alreadyexist")
                  Dim Note
4202              For Each Note In Notes
4204                  wtcwMessage "[Note from server] «2»" & Note
4206              Next Note
                  
4208          Else
4210              wtcwError "Error submitting Quests: «2»The server response appears to be invalid"
4212          End If
4214      End With
4216      Exit Sub
erh:
4218      HandleErr "webSubmitQuests_onSuccess"
End Sub

Private Sub webGetQuestXML_onFailure(ByVal sErrorMessage As String)
4220      wtcwError "Error downloading Quests XML: «2»" & sErrorMessage
4222      bDownloadNowClicked = False
End Sub

Private Sub webGetQuestXML_onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
4224      On Error GoTo erh
          Dim NodeComment As IXMLDOMNode, sCmt As String
4226      With ResponseXML.documentElement
4228          If .tagName = "Quests" And IsNumeric(.getAttribute("FileVer")) Then
              
4230              If chkWebSaveBackups.Checked Then BackupQuestFile
4232              For Each NodeComment In ResponseXML.childNodes
4234                  If NodeComment.nodeType = NODE_COMMENT Then
4236                      sCmt = Replace(NodeComment.text, " ", "")
4238                      If Left(sCmt, 9) = "uploadct=" Then
4240                          lUploadCt = Val(Mid(sCmt, 10))
4242                          Exit For
4244                      End If
4246                  End If
4248              Next
4250              WriteXML ResponseXML, App.Path & "\quests.xml"
4252              JustSavedQuestsXML False
4254              wtcwMessage "Successfully downloaded Quests XML"
4256              LoadQuests
                  Dim Note
4258              For Each Note In Notes
4260                  wtcwMessage "[Note from server] «2»" & Note
4262              Next Note
4264          ElseIf .tagName = "OldFile" Then
4266              If bDownloadNowClicked Then wtcwMessage "The server doesn't have a newer Quests file to download"
4268          Else
4270              wtcwError "Error downloading Quests XML: «2»The file appears to be invalid"
4272          End If
4274      End With
4276      bDownloadNowClicked = False
4278      Exit Sub
erh:
4280      HandleErr "webGetQuestXML_onSuccess"
End Sub

Private Sub webSendQuestXML_onFailure(ByVal sErrorMessage As String)
4282      On Error GoTo erh
4284      wtcwError "Error uploading Quests XML" & _
              IIf(colAddtlURLs.Count > 0, " to «7»" & webSendQuestXML.URL & "«d»", "") & ": «2»" & sErrorMessage
4286      ctSendURL = ctSendURL + 1
4288      If ctSendURL <= colAddtlURLs.Count Then
4290          UploadQuests False
4292      End If
4294      Exit Sub
erh:
4296      HandleErr "webSendQuestXML_onFailure"
End Sub

Private Sub webSendQuestXML_onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
4298      On Error GoTo erh
4300      ctSendURL = ctSendURL + 1
4302      With ResponseXML.documentElement
4304          Select Case .tagName
                  Case "Success", "Merged"
                      'Check for validity
4306                  If .tagName = "Merged" And ResponseXML.selectSingleNode("//Merged/Quests") Is Nothing Then
4308                      wtcwError "Error uploading Quests XML" & _
                              IIf(colAddtlURLs.Count > 0, " to «7»" & webSendQuestXML.URL & "«d»", "") & _
                              ": «2»The server merged the Quest file, but did not return the updated file"
4310                  Else
4312                      ctSendURLSuccess = ctSendURLSuccess + 1
4314                      If Not IsNull(.getAttribute("uploadct")) Then
4316                          lUploadCt = Val(.getAttribute("uploadct"))
4318                          SaveSettings
4320                      End If
4322                      If ctSendURL > colAddtlURLs.Count Then wtcwMessage "Quests uploaded successfully" & _
                              IIf(ctSendURL > 1, " to " & ctSendURLSuccess & IIf(ctSendURLSuccess = 1, " site", " sites"), "")
                              
4324                      If .tagName = "Merged" Then
4326                          If chkWebSaveBackups.Checked Then BackupQuestFile
                              
                              Dim QuestXML As New DOMDocument40
4328                          Set QuestXML.documentElement = ResponseXML.selectSingleNode("//Merged/Quests")
4330                          WriteXML QuestXML, App.Path & "/quests.xml"
4332                          Set QuestXML = Nothing
4334                          JustSavedQuestsXML False
                              
4336                          wtcwWarning "The server merged existing character info into your quests file.  " & _
                                  "You can disable this on the Internet > Settings tab."
4338                          If Not IsNull(.getAttribute("restoredquests")) Then
4340                              If .getAttribute("restoredquests") <> "" Then
4342                                  wtcwWarning "Some quests had active timers for other chars and were restored: «2»" & _
                                          .getAttribute("restoredquests")
4344                              End If
4346                          End If
4348                          LoadQuests
4350                      End If
4352                  End If
                      
4354              Case "OldFile"
4356                  wtcwWarning "The quest file on the server is newer than yours.  For your " & _
                          "saftey, the data was not uploaded."
4358                  wtcwWarning "To upload anyways, go to the Internet > Settings tab and uncheck " & _
                          """«2»" & chkWebOnlyUploadNew.text & "«d»"""
                  
4360              Case "OtherCharMismatch"
4362                  wtcwWarning "The quest file on the server has different info about the other " & _
                          "characters in your quests file.  For your saftey, the data was not uploaded."
4364                  wtcwWarning "To upload anyways, go to the Internet > Settings tab and change the " & _
                          "setting to «2»Overwrite«d» or «2»Merge"
                  
4366              Case Else
4368                  wtcwError "Error uploading Quests XML" & _
                          IIf(colAddtlURLs.Count > 0, " to «7»" & webSendQuestXML.URL & "«d»", "") & _
                          ": «2»The server response appears to be invalid"
4370          End Select
              
              Dim Note
4372          For Each Note In Notes
4374              wtcwMessage "[Note from server] «2»" & Note
4376          Next Note
4378      End With
4380      If ctSendURL <= colAddtlURLs.Count Then
4382          UploadQuests False
4384      End If
4386      Exit Sub
erh:
4388      HandleErr "webSendQuestXML_onSuccess"
End Sub

Private Sub webSendTreestats_onFailure(ByVal sErrorMessage As String)
4390      On Error GoTo erh
4392      wtcwError "Error uploading to «0»Treestats«d»: «2»" & sErrorMessage
4394      Exit Sub
erh:
4396      HandleErr "webSendTreestats_onFailure"
End Sub

Private Sub webSendTreestats_onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
4398      On Error GoTo erh
          
          Dim Note
4400      For Each Note In Notes
4402          wtcwMessage "[Note from «0»Treestats«d» server] «2»" & Note
4404      Next Note
          
4406      Exit Sub
erh:
4408      HandleErr "webSendTreestats_onSuccess"
End Sub
