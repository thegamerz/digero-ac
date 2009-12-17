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
Private WithEvents NoResponseTimer As DecalInput.Timer
Attribute NoResponseTimer.VB_VarHelpID = -1

Private MyURL As String

Event onSuccess(ResponseXML As DOMDocument40, Notes As Collection)
Event onFailure(ByVal sErrorMessage As String)

Public Property Get URL() As String
4538      URL = MyURL
End Property

Public Property Get isRunning() As Boolean
4540      isRunning = Not (httpReq.readyState = 0 Or httpReq.readyState = 4)
End Property

Public Sub Abort()
4542      If NoResponseTimer.Running Then NoResponseTimer.Stop
4544      httpReq.Abort
End Sub

Public Sub PostRequest(URL As String, Mode As String, Optional ArgsArr, Optional ValuesArr, Optional msTimeOut As Long = 240000)
4546      On Error GoTo erh
          Dim i As Integer, strPOST As String
4548      If IsMissing(ArgsArr) Then ArgsArr = Array()
4550      If IsMissing(ValuesArr) Then ValuesArr = Array()
4552      MyURL = URL
4554      httpReq.Open "POST", URL, True
4556      httpReq.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
4558      httpReq.setRequestHeader "X-Plugin-Name", sPluginName
4560      httpReq.setRequestHeader "X-Plugin-Version", App.Major & "." & App.Minor & "." & App.Revision
          
4562      For i = LBound(ArgsArr) To UBound(ArgsArr)
4564          strPOST = strPOST & ArgsArr(i) & "=" & URLEncode(ValuesArr(i)) & "&"
4566      Next i
4568      strPOST = strPOST & "mode=" & Mode & _
              "&currentcharacter=" & URLEncode(sCharName) & _
              "&currentworld=" & URLEncode(sWorld) & _
              "&currentguid=" & lPlayerGUID & _
              "&acctchars=" & URLEncode(sAcctChars) & _
              "&currenttime=" & URLEncode(ISODate(NowGMT)) & _
              "&gmtoffset=" & URLEncode(GMTOffset) & _
              "&plugin=" & URLEncode(sPluginName) & _
              "&plugin_ver=" & App.Major & "." & App.Minor & "." & App.Revision & _
              "&random=" & str(Rnd) 'Random number to prevent caching
4570      httpReq.send strPOST
4572      NoResponseTimer.Start msTimeOut
4574      Exit Sub
erh:
4576      HandleErr "httpHandler.PostRequest"
End Sub

Public Sub GetXML(URL As String, Optional msTimeOut As Long = 60000)
4578      On Error GoTo erh
4580      MyURL = URL
4582      httpReq.Open "GET", URL, True
4584      httpReq.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
4586      httpReq.send
4588      NoResponseTimer.Start msTimeOut
4590      Exit Sub
erh:
4592      HandleErr "httpHandler.GetXML"
End Sub

'******************************************************************************
'**  Private Routines  ********************************************************
'******************************************************************************

Private Sub Class_Initialize()
4594      Set NoResponseTimer = New DecalInput.Timer
4596      httpReq.onreadystatechange = Me
End Sub

Private Sub Class_Terminate()
4598      Abort
4600      Set NoResponseTimer = Nothing
4602      Set httpReq = Nothing
End Sub

Public Sub ReadyStateChange()
Attribute ReadyStateChange.VB_UserMemId = 0
4604      On Error GoTo erh
4606      If httpReq.readyState = 4 Then
4608          If NoResponseTimer.Running Then NoResponseTimer.Stop
              
4610          If httpReq.Status = 200 Then 'Success
                  'wtcwDebug Left(httpReq.responseText, 1000)
                  Dim ResponseXML As New DOMDocument40
4612              If ResponseXML.loadXML(httpReq.responseText) Then
4614                  If ResponseXML.documentElement.tagName <> "error" Then
                          Dim Notes As Collection, ChildNode As IXMLDOMNode
4616                      Set Notes = New Collection
4618                      For Each ChildNode In ResponseXML.childNodes
4620                          If ChildNode.nodeType = NODE_COMMENT Then
4622                              If Left(Trim(ChildNode.text), 5) = "Note:" Then
4624                                  If Notes.Count < 10 Then Notes.Add Left(Mid(Trim(ChildNode.text), 6), 200)
4626                                  ResponseXML.removeChild ChildNode
4628                              End If
4630                          End If
4632                      Next ChildNode
4634                      RaiseEvent onSuccess(ResponseXML, Notes)
4636                      Set Notes = Nothing
4638                      Set ChildNode = Nothing
4640                  Else
4642                      If IsNull(ResponseXML.documentElement.getAttribute("reason")) Then
4644                          RaiseEvent onFailure("The server responded with an error but no reason")
4646                      Else
4648                          RaiseEvent onFailure("[Server Error] " & Left(ResponseXML.documentElement.getAttribute("reason"), 150))
4650                      End If
4652                  End If
4654              Else
4656                  If InStr(1, httpReq.responseText, "Error:", vbTextCompare) Then
4658                      RaiseEvent onFailure("[Server Response] " & Mid(httpReq.responseText, InStr(1, httpReq.responseText, "Error:", vbTextCompare), 150))
4660                  Else
4662                      RaiseEvent onFailure("There was an error parsing the server's response, it must be in XML format. Response:" & vbLf & _
                          "«12»" & Left(httpReq.responseText, 300))
4664                  End If
4666              End If
4668              Set ResponseXML = Nothing
4670          ElseIf httpReq.Status = 12007 Then
4672              RaiseEvent onFailure("The server name could not be resolved")
4674          ElseIf httpReq.Status = 12029 Then
4676              RaiseEvent onFailure("The attempt to connect to the server failed")
4678          ElseIf httpReq.Status = 404 Then
4680              RaiseEvent onFailure("404 Not Found")
4682          Else
4684              RaiseEvent onFailure("HTTP code " & httpReq.Status & ": " & httpReq.statusText)
4686          End If
4688      End If
4690      Exit Sub
erh:
4692      HandleErr "httpHandler.ReadyStateChange"
End Sub

Private Sub NoResponseTimer_Timeout(ByVal Source As DecalInput.IDecalTimer)
4694      On Error GoTo erh
4696      wtcwDebug "Timeout -- Current ready state: " & httpReq.readyState
4698      httpReq.Abort
4700      NoResponseTimer.Stop
4702      RaiseEvent onFailure("The server did not respond")
4704      Exit Sub
erh:
4706      HandleErr "httpHandler.NoResponseTimer_Timeout"
End Sub

Private Function URLEncode(ByVal str As String) As String
4708      On Error GoTo erh
4710      URLEncode = Replace(str, "%", "%25")
4712      URLEncode = Replace(URLEncode, " ", "%20")
4714      URLEncode = Replace(URLEncode, "+", "%2B")
4716      URLEncode = Replace(URLEncode, "&", "%26")
4718      URLEncode = Replace(URLEncode, "=", "%3D")
4720      URLEncode = Replace(URLEncode, "?", "%3F")
4722      Exit Function
erh:
4724      HandleErr "httpHandler.URLEncode"
End Function
