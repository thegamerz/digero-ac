Attribute VB_Name = "Data"
Option Explicit

Private dctEffects As New Dictionary
Private dctSpellWords As New Dictionary
Private dctSpecies As New Dictionary

Public arrRatingNames() As String
Public arrDbRatingNames() As String
Public RatingColors() As Long

Public arrVulnNames() As String
Public arrDbVulnNames() As String
Public VulnIcons() As Long

Public Function SpellWordsToParEff(ByVal sSpellWords As String) As Long
3332      On Error GoTo erh
3334      If dctSpellWords.Exists(sSpellWords) Then
3336          SpellWordsToParEff = dctSpellWords(sSpellWords)
3338      Else
3340          SpellWordsToParEff = 0
3342      End If
3344      Exit Function
erh:
3346      handleErr "SpellWordsToParEff"
End Function

Public Function DebuffInfo(ByVal parEff As Long) As tDebuff
3348      On Error GoTo erh
3350      If dctEffects.Exists(parEff) Then
3352          DebuffInfo = dctEffects(parEff)
3354      End If
3356      Exit Function
erh:
3358      handleErr "DebuffInfo"
End Function

Public Function SpeciesNameToID(sName As String) As Long
3360      On Error GoTo erh
3362      If dctSpecies.Exists(sName) Then
3364          SpeciesNameToID = dctSpecies(sName)
3366      Else
3368          SpeciesNameToID = 0
3370      End If
3372      Exit Function
erh:
3374      handleErr "SpeciesNameToID"
End Function

Public Function EffectsArray()
3376      On Error GoTo erh
3378      EffectsArray = dctEffects.Keys
3380      Exit Function
erh:
3382      handleErr "EffectsArray"
End Function

Public Function DbStrToRating(ByVal sDescr As String) As eRating
3384      On Error GoTo erh
          
          Dim i As Long
3386      sDescr = LCase(sDescr)
3388      For i = LBound(arrDbRatingNames) To UBound(arrDbRatingNames)
3390          If sDescr = LCase(arrDbRatingNames(i)) Then
3392              DbStrToRating = i
3394              Exit Function
3396          End If
3398      Next
          
3400      DbStrToRating = eUnknown
          
3402      Exit Function
erh:
3404      handleErr "DbStrToRating"
End Function

Public Function RatingToDbStr(ByVal lRating As eRating) As String
3406      On Error GoTo erh
3408      If lRating >= LBound(arrDbRatingNames) And lRating <= UBound(arrDbRatingNames) Then
3410          RatingToDbStr = arrDbRatingNames(lRating)
3412      Else
3414          RatingToDbStr = ""
3416      End If
3418      Exit Function
erh:
3420      handleErr "RatingToDbStr"
End Function

Public Function StrToRating(ByVal sDescr As String) As eRating
3422      On Error GoTo erh
          
          Dim i As Long
3424      sDescr = LCase(sDescr)
3426      For i = LBound(arrRatingNames) To UBound(arrRatingNames)
3428          If sDescr = LCase(arrRatingNames(i)) Then
3430              StrToRating = i
3432              Exit Function
3434          End If
3436      Next
          
3438      StrToRating = eUnknown
          
3440      Exit Function
erh:
3442      handleErr "StrToRating"
End Function

Public Function RatingToStr(ByVal lRating As eRating) As String
3444      On Error GoTo erh
3446      If lRating >= LBound(arrRatingNames) And lRating <= UBound(arrRatingNames) Then
3448          RatingToStr = arrRatingNames(lRating)
3450      Else
3452          RatingToStr = ""
3454      End If
3456      Exit Function
erh:
3458      handleErr "RatingToStr"
End Function

Public Function DbStrToVuln(ByVal sDescr As String) As eVulnType
3460      On Error GoTo erh
          
          Dim i As Long
3462      sDescr = LCase(sDescr)
3464      For i = LBound(arrDbVulnNames) To UBound(arrDbVulnNames)
3466          If sDescr = LCase(arrDbVulnNames(i)) Then
3468              DbStrToVuln = i
3470              Exit Function
3472          End If
3474      Next
          
3476      DbStrToVuln = eNoVuln
          
3478      Exit Function
erh:
3480      handleErr "DbStrToVuln"
End Function

Public Function VulnToDbStr(ByVal lVuln As eVulnType) As String
3482      On Error GoTo erh
3484      If lVuln >= LBound(arrDbVulnNames) And lVuln <= UBound(arrDbVulnNames) Then
3486          VulnToDbStr = arrDbVulnNames(lVuln)
3488      Else
3490          VulnToDbStr = ""
3492      End If
3494      Exit Function
erh:
3496      handleErr "VulnToDbStr"
End Function

Public Function StrToVuln(ByVal sDescr As String) As eVulnType
3498      On Error GoTo erh
          
          Dim i As Long
3500      sDescr = LCase(sDescr)
3502      For i = LBound(arrVulnNames) To UBound(arrVulnNames)
3504          If sDescr = LCase(arrVulnNames(i)) Then
3506              StrToVuln = i
3508              Exit Function
3510          End If
3512      Next
          
3514      StrToVuln = eNoVuln
          
3516      Exit Function
erh:
3518      handleErr "StrToVuln"
End Function

Public Function VulnToStr(ByVal lVuln As eVulnType) As String
3520      On Error GoTo erh
3522      If lVuln >= LBound(arrVulnNames) And lVuln <= UBound(arrVulnNames) Then
3524          VulnToStr = arrVulnNames(lVuln)
3526      Else
3528          VulnToStr = ""
3530      End If
3532      Exit Function
erh:
3534      handleErr "VulnToStr"
End Function

Public Sub InitData()
3536      On Error GoTo erh
          
          Dim xmlDoc As New DOMDocument40, xmlNode As IXMLDOMElement, xmlNodeList As IXMLDOMNodeList
          Dim nodeEffect As IXMLDOMElement, nodeDebuff As IXMLDOMElement
          Dim Effect As tDebuff, Debuff As tDebuff
          Dim i As Long
          
3538      If xmlDoc.Load(App.Path & "\debuff_data.xml") Then
3540          For Each nodeEffect In xmlDoc.selectNodes("//debuff_data/effect")
3542              Effect.Effect = nodeEffect.getAttribute("id")
3544              Effect.name = nodeEffect.getAttribute("name")
3546              Effect.Icon = nodeEffect.getAttribute("icon")
3548              Select Case nodeEffect.getAttribute("type")
                      Case "Crit": Effect.Type = dbfCrit
3550                  Case "Life": Effect.Type = dbfLife
3552              End Select
3554              Effect.SpellWords = ""
                  
3556              Debuff.Effect = Effect.Effect * &H10000
3558              Debuff.Type = Effect.Type
3560              For Each nodeDebuff In nodeEffect.selectNodes("debuff")
3562                  Debuff.Effect = Debuff.Effect + 1
3564                  Debuff.name = nodeDebuff.getAttribute("name")
3566                  Debuff.Icon = nodeDebuff.getAttribute("icon")
3568                  Debuff.SpellWords = nodeDebuff.getAttribute("spellwords")
                      
3570                  dctSpellWords(Debuff.SpellWords) = Debuff.Effect
                      
3572                  Effect.SpellWords = Effect.SpellWords & Debuff.SpellWords & "," 'Comma-delimited list of spell words
                      
3574                  dctEffects(Debuff.Effect) = Debuff
3576              Next
                  
3578              If Len(Effect.SpellWords) > 0 Then 'Remove trailing comma
3580                  Effect.SpellWords = Left(Effect.SpellWords, Len(Effect.SpellWords) - 1)
3582              End If
                  
3584              dctEffects(Effect.Effect) = Effect
3586          Next
3588      Else
3590          Err.Raise 666, Description:="FATAL ERROR! Failed to load debuff_data.xml"
3592      End If
          
3594      If xmlDoc.Load(App.Path & "\language.xml") Then
3596          Set xmlNodeList = xmlDoc.selectNodes("//language/rating")
3598          ReDim arrRatingNames(0 To xmlNodeList.length - 1)
3600          ReDim arrDbRatingNames(0 To xmlNodeList.length - 1)
3602          ReDim RatingColors(0 To xmlNodeList.length - 1)
3604          For i = 0 To xmlNodeList.length - 1
3606              Set xmlNode = xmlNodeList(i)
3608              arrRatingNames(i) = xmlNode.getAttribute("name")
3610              arrDbRatingNames(i) = xmlNode.getAttribute("dbname")
3612              RatingColors(i) = xmlNode.getAttribute("color")
3614          Next
              
3616          Set xmlNodeList = xmlDoc.selectNodes("//language/vuln")
3618          ReDim arrVulnNames(0 To xmlNodeList.length - 1)
3620          ReDim arrDbVulnNames(0 To xmlNodeList.length - 1)
3622          ReDim VulnIcons(0 To xmlNodeList.length - 1)
3624          For i = 0 To xmlNodeList.length - 1
3626              Set xmlNode = xmlNodeList(i)
3628              arrVulnNames(i) = xmlNode.getAttribute("name")
3630              arrDbVulnNames(i) = xmlNode.getAttribute("dbname")
3632              VulnIcons(i) = xmlNode.getAttribute("icon")
3634          Next
3636      Else
3638          wtcwError "Failed to load «2»language.xml"
3640      End If
          
3642      If xmlDoc.Load(App.Path & "\species_ids.xml") Then
3644          For Each xmlNode In xmlDoc.selectNodes("//species_ids/species")
3646              dctSpecies(xmlNode.getAttribute("name")) = xmlNode.getAttribute("id")
3648          Next
3650      Else
3652          wtcwError "Failed to load «2»species_ids.xml"
3654      End If
          
3656      Set xmlDoc = Nothing
3658      Set xmlNode = Nothing
3660      Set xmlNodeList = Nothing
3662      Set nodeEffect = Nothing
3664      Set nodeDebuff = Nothing
              
3666      Exit Sub
erh:
3668      handleErr "InitData"
End Sub

Public Sub TerminateData()
3670      Set dctSpellWords = Nothing
3672      Set dctEffects = Nothing
3674      Set dctSpecies = Nothing
End Sub
