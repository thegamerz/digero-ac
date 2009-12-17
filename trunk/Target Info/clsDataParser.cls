VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsDataParser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'Poor Man's asynch data processing

Public Event Done()
Public Event AbortError()

Private WithEvents tmFauna As DecalInput.Timer
Attribute tmFauna.VB_VarHelpID = -1
Private WithEvents tmSpecies As DecalInput.Timer
Attribute tmSpecies.VB_VarHelpID = -1
    
Private xmlIn As New DOMDocument40, nodeFauna As IXMLDOMElement
Private xmlOut As New DOMDocument40, nodeCreature As IXMLDOMElement, nodeSpecies As IXMLDOMElement, nodeProt As IXMLDOMElement
Private i As Long, j As Long, lRating As Long, bFound As Boolean, sSpeciesName As String, sCreatureName As String

Private nodeItrFauna As IXMLDOMNodeList, nodeItrSpecies As IXMLDOMNodeList
Private colSpecies As IXMLDOMNodeList
Private Vuln
Private arrRatings(0 To 7) As Long, lBestRating As Long, sRating As String
    
Public Sub Start()
3752      On Error GoTo erh
3754      Set xmlOut.documentElement = xmlOut.createElement("resists")
3756      If xmlIn.Load(App.Path & "\unparsed_database.xml") Then
3758          Set nodeItrFauna = xmlIn.selectNodes("//creatures/fauna")
3760          If nodeItrFauna.length = 0 Then
3762              wtcwError "The downloaded database does not have the expected format.  Aborting..."
3764              DoAbortError
3766              Exit Sub
3768          End If
3770          tmFauna.Start 25
3772      Else
3774          If FSO.FileExists(App.Path & "\unparsed_database.xml") Then
                  Dim ts As TextStream
3776              Set ts = FSO.OpenTextFile(App.Path & "\unparsed_database.xml")
3778              If ts.AtEndOfStream Then
3780                  wtcwError "The downloaded file is blank.  Some firewalls (such as Norton Firewall) can cause this to happen.  You may need to disable Norton Firewall."
3782              Else
3784                  wtcwError "There was an error parsing the downloaded file. It must be in XML format."
3786                  wtcwError "Displaying first 250 characters of response (the rest is stored in «2»unparsed_database.xml«8»):«12»" & _
                          vbLf & ts.Read(250)
3788              End If
3790              ts.Close
3792              Set ts = Nothing
3794          Else
3796              wtcwError "Failed to load downloaded file.  File does not exist."
3798          End If
3800          DoAbortError
3802      End If
3804      Exit Sub
erh:
3806      handleErr "DataParser.Start"
3808      DoAbortError
End Sub

Private Sub Class_Initialize()
3810      On Error GoTo erh
3812      Set tmFauna = New DecalInput.Timer
3814      Set tmSpecies = New DecalInput.Timer
3816      Exit Sub
erh:
3818      handleErr "DataParser.Class_Initialize"
3820      DoAbortError
End Sub

Private Sub Class_Terminate()
3822      tmFauna.Stop
3824      tmSpecies.Stop
3826      Set tmFauna = Nothing
3828      Set tmSpecies = Nothing
          
3830      Set xmlIn = Nothing
3832      Set xmlOut = Nothing
3834      Set nodeFauna = Nothing
3836      Set nodeCreature = Nothing
3838      Set nodeSpecies = Nothing
3840      Set nodeProt = Nothing
3842      Set nodeItrFauna = Nothing
3844      Set nodeItrSpecies = Nothing
3846      Set colSpecies = Nothing
End Sub

Private Sub tmFauna_Timeout(ByVal Source As DecalInput.IDecalTimer)
3848      On Error GoTo erh
          
3850      For j = 1 To 75 '75 at a time
3852          Set nodeFauna = nodeItrFauna.nextNode
              
3854          If nodeFauna Is Nothing Then
3856              tmFauna.Stop
3858              SpeciesLoop
3860              Exit Sub
3862          End If
              
3864          sCreatureName = nodeFauna.selectSingleNode("name").Text
3866          sSpeciesName = nodeFauna.selectSingleNode("type").Text
              
3868          If Right(sCreatureName, 5) = "(NPC)" Or sSpeciesName = "Player" Then Exit Sub
              
3870          bFound = False
3872          Set colSpecies = xmlOut.selectNodes("//resists/species")
3874          For i = colSpecies.length - 1 To 0 Step -1
3876              Set nodeSpecies = colSpecies(i)
3878              If nodeSpecies.getAttribute("name") = sSpeciesName Then
3880                  bFound = True
3882                  Exit For
3884              End If
3886          Next
3888          If Not bFound Then
3890              Set nodeSpecies = xmlOut.documentElement.appendChild(xmlOut.createElement("species"))
3892              nodeSpecies.setAttribute "name", sSpeciesName
3894              nodeSpecies.setAttribute "id", SpeciesNameToID(sSpeciesName)
3896          End If
              
3898          Set nodeCreature = nodeSpecies.appendChild(xmlOut.createElement("creature"))
              
3900          sCreatureName = Trim(Replace(Replace(Replace(sCreatureName, " (low)", ""), " (mid)", ""), " (high)", ""))
3902          nodeCreature.setAttribute "name", sCreatureName
3904          nodeCreature.setAttribute "id", nodeFauna.selectSingleNode("id").Text
3906          nodeCreature.setAttribute "attack_height", nodeFauna.selectSingleNode("attack_height").Text
              
              Dim VulnNode As IXMLDOMElement
3908          For Each Vuln In Data.arrDbVulnNames
3910              If Vuln <> "" Then
3912                  Set VulnNode = nodeCreature.appendChild(nodeFauna.selectSingleNode(Vuln))
3914                  If LCase(VulnNode.Text) = "av." Then VulnNode.Text = "Average"
3916              End If
3918          Next
3920          Set VulnNode = Nothing
3922      Next
          
3924      Exit Sub
erh:
3926      handleErr "DataParser.tmFauna_Timeout"
3928      DoAbortError
End Sub

Private Sub SpeciesLoop()
3930      On Error GoTo erh
3932      Set nodeItrSpecies = xmlOut.selectNodes("//resists/species")
3934      tmSpecies.Start 50
3936      Exit Sub
erh:
3938      handleErr "DataParser.SpeciesLoop"
3940      DoAbortError
End Sub

Private Sub tmSpecies_Timeout(ByVal Source As DecalInput.IDecalTimer)
3942      On Error GoTo erh
          
3944      For j = 1 To 10
              
3946          Set nodeSpecies = nodeItrSpecies.nextNode
              
3948          If nodeSpecies Is Nothing Then
3950              tmSpecies.Stop
3952              Finish
3954              Exit Sub
3956          End If
          
3958          For Each Vuln In Data.arrDbVulnNames
3960              If Vuln <> "" Then
3962                  For i = 0 To 7
3964                      arrRatings(i) = 0
3966                  Next
3968                  For Each nodeCreature In nodeSpecies.selectNodes("creature")
3970                      lRating = DbStrToRating(nodeCreature.selectSingleNode(Vuln).Text)
3972                      arrRatings(lRating) = arrRatings(lRating) + 1
3974                  Next
3976                  lBestRating = 1
3978                  For i = 2 To 7
3980                      If arrRatings(i) > arrRatings(lBestRating) Then lBestRating = i
3982                  Next
3984                  If arrRatings(lBestRating) = 0 Then lBestRating = 0
3986                  Set nodeProt = nodeSpecies.insertBefore(xmlOut.createElement(Vuln), _
                                                              nodeSpecies.selectSingleNode("creature"))
3988                  nodeProt.Text = RatingToDbStr(lBestRating)
3990              End If
3992          Next
              
3994      Next
          
3996      Exit Sub
erh:
3998      handleErr "DataParser.tmSpecies_Timeout"
4000      DoAbortError
End Sub

Private Sub Finish()
4002      On Error GoTo erh
          
4004      writeXML xmlOut, App.Path & "\vuln_database.xml"
4006      RaiseEvent Done
          
4008      Exit Sub
erh:
4010      handleErr "DataParser.Finish"
4012      DoAbortError
End Sub

Private Sub DoAbortError()
4014      On Error GoTo erh
          
4016      tmFauna.Stop
4018      tmSpecies.Stop
4020      RaiseEvent AbortError
          
4022      Exit Sub
erh:
4024      handleErr "DoAbortError"
End Sub
