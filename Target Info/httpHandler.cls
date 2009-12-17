VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "httpHandler"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit
Option Compare Text

Private httpReq As New XMLHTTP40
Attribute httpReq.VB_VarHelpID = -1

Private MyURL As String

Event onSuccess(ByRef sResponse As String)
Event onFailure(ByVal sErrorMessage As String)

Public Property Get URL() As String
3676      URL = MyURL
End Property

Public Property Get isRunning() As Boolean
3678      isRunning = Not (httpReq.readyState = 0 Or httpReq.readyState = 4)
End Property

Public Sub Abort()
3680      httpReq.Abort
End Sub

Public Sub GetXML(URL As String)
3682      On Error GoTo erh
3684      MyURL = URL
3686      httpReq.Open "GET", URL, True
3688      httpReq.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
3690      httpReq.send "random=" & str(Rnd)
3692      Exit Sub
erh:
3694      handleErr "httpHandler.GetXML"
End Sub

'******************************************************************************
'**  Private Routines  ********************************************************
'******************************************************************************

Private Sub Class_Initialize()
3696      httpReq.onreadystatechange = Me
End Sub

Private Sub Class_Terminate()
3698      Abort
3700      Set httpReq = Nothing
End Sub

Public Sub ReadyStateChange()
Attribute ReadyStateChange.VB_UserMemId = 0
3702      On Error GoTo erh
          'wtcwDebug "ReadyState: " & httpReq.readyState
3704      If httpReq.readyState = 4 Then
3706          If httpReq.Status = 200 Then 'Success
                  'wtcwDebug Left(httpReq.responseText, 1000)
3708              RaiseEvent onSuccess(httpReq.responseText)
3710          ElseIf httpReq.Status = 12007 Then
3712              RaiseEvent onFailure("The server name could not be resolved")
3714          ElseIf httpReq.Status = 12029 Then
3716              RaiseEvent onFailure("The attempt to connect to the server failed")
3718          ElseIf httpReq.Status = 404 Then
3720              RaiseEvent onFailure("404 Not Found")
3722          Else
3724              RaiseEvent onFailure("HTTP code " & httpReq.Status & ": " & httpReq.statusText)
3726          End If
3728      End If
3730      Exit Sub
erh:
3732      handleErr "httpHandler.ReadyStateChange"
End Sub

Private Function URLEncode(ByVal str As String) As String
3734      On Error GoTo erh
3736      URLEncode = Replace(str, "%", "%25")
3738      URLEncode = Replace(URLEncode, " ", "%20")
3740      URLEncode = Replace(URLEncode, "+", "%2B")
3742      URLEncode = Replace(URLEncode, "&", "%26")
3744      URLEncode = Replace(URLEncode, "=", "%3D")
3746      URLEncode = Replace(URLEncode, "?", "%3F")
3748      Exit Function
erh:
3750      handleErr "httpHandler.URLEncode"
End Function
