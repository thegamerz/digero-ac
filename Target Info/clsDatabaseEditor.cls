VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDatabaseEditor"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private WithEvents DataView As View
Attribute DataView.VB_VarHelpID = -1

Private WithEvents lstCritters As DecalControls.List
Attribute lstCritters.VB_VarHelpID = -1
Private Enum cCritters
    colPlusIcon
    colName
    colAcid
    colBludge
    colCold
    colFire
    colLight
    colPierce
    colSlash
    colDelIcon
End Enum
Private WithEvents btnOK As DecalControls.PushButton
Attribute btnOK.VB_VarHelpID = -1
Private WithEvents btnCancel As DecalControls.PushButton
Attribute btnCancel.VB_VarHelpID = -1
Private WithEvents btnApply As DecalControls.PushButton
Attribute btnApply.VB_VarHelpID = -1

Public Event Done(bSuccess As Boolean)

Private Sub btnApply_Accepted(ByVal nID As Long)
    On Error GoTo erh
    
    
    
    Exit Sub
erh:
    HandleErr "btnApply_Accepted"
End Sub

Private Sub btnCancel_Accepted(ByVal nID As Long)
    On Error GoTo erh
    
    
    RaiseEvent Done(False)
    
    Exit Sub
erh:
    HandleErr "btnCancel_Accepted"
End Sub

Private Sub btnOK_Accepted(ByVal nID As Long)
    On Error GoTo erh
    
    
    RaiseEvent Done(True)
    
    Exit Sub
erh:
    HandleErr "btnOK_Accepted"
End Sub

Private Sub lstCritters_Change(ByVal nID As Long, ByVal nX As Long, ByVal nY As Long)
    On Error GoTo erh
    
    Exit Sub
erh:
    HandleErr "lstCritters_Change"
End Sub

Private Sub Class_Initialize()

    Set DataView = PluginSite.LoadView(App.Path & "\Database View.xml")
    With DataView
        Set lstCritters = .Control("lstCritters")
        Set btnOK = .Control("btnOK")
        Set btnCancel = .Control("btnCancel")
        Set btnApply = .Control("btnApply")
    End With
    
    
    
End Sub

Private Sub Class_Terminate()
    
    Set DataView = Nothing
    Set lstCritters = Nothing
    Set btnOK = Nothing
    Set btnCancel = Nothing
    Set btnApply = Nothing
    
End Sub
