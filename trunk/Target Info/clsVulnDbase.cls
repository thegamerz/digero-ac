VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVulnDbase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public dctCreatures As New Dictionary
Public dctSpecies As New Dictionary
Public dctIDedCache As New Dictionary

Public Property Get Item(sCreatureName As String, sSpeciesID As String) As clsVulnInfo
Attribute Item.VB_UserMemId = 0
2988      On Error GoTo erh
          
2990      If dctCreatures.Exists(sCreatureName) Then
2992          Set Item = dctCreatures(sCreatureName)
2994      ElseIf dctSpecies.Exists(sSpeciesID) Then
2996          Set Item = dctSpecies(sSpeciesID)
2998      ElseIf dctIDedCache.Exists(sCreatureName) Then
3000          Set Item = dctIDedCache(sCreatureName)
3002      Else
3004          Set Item = New clsVulnInfo
3006      End If
          
3008      Exit Property
erh:
3010      handleErr "Item"
End Property

Public Sub Load()
3012      On Error GoTo erh
          Dim xmlDoc As New DOMDocument40, xmlNode As IXMLDOMElement
          Dim VulnInfo As clsVulnInfo
          Dim Vuln
          
3014      dctCreatures.removeAll
3016      dctSpecies.removeAll
3018      dctIDedCache.removeAll
          
3020      If xmlDoc.Load(App.Path & "\vuln_idcache.xml") Then
3022          For Each xmlNode In xmlDoc.selectNodes("//resists/creature")
3024              Set VulnInfo = New clsVulnInfo
3026              For Each Vuln In Data.arrDbVulnNames
3028                  If Vuln <> "" Then
3030                      VulnInfo.VulnRating(DbStrToVuln(Vuln)) = DbStrToRating(xmlNode.selectSingleNode(Vuln).Text)
3032                  End If
3034              Next
3036              VulnInfo.AttackHeight = xmlNode.getAttribute("attack_height")
3038              VulnInfo.CreatureID = xmlNode.getAttribute("id")
3040              VulnInfo.CreatureName = xmlNode.getAttribute("name")
3042              VulnInfo.IsSpeciesData = True
3044              Set dctIDedCache(VulnInfo.CreatureName) = VulnInfo
3046          Next
3048          If dctIDedCache.Exists("") Then dctIDedCache.remove ""
3050      End If
          
3052      If xmlDoc.Load(App.Path & "\vuln_database.xml") Then
              
3054          For Each xmlNode In xmlDoc.selectNodes("//resists/species")
3056              Set VulnInfo = New clsVulnInfo
3058              For Each Vuln In Data.arrDbVulnNames
3060                  If Vuln <> "" Then
3062                      VulnInfo.VulnRating(DbStrToVuln(Vuln)) = DbStrToRating(xmlNode.selectSingleNode(Vuln).Text)
3064                  End If
3066              Next
3068              VulnInfo.SpeciesID = xmlNode.getAttribute("id")
3070              VulnInfo.SpeciesName = xmlNode.getAttribute("name")
3072              VulnInfo.IsSpeciesData = True
3074              Set dctSpecies(VulnInfo.SpeciesID) = VulnInfo
3076          Next
              
3078          For Each xmlNode In xmlDoc.selectNodes("//resists/species/creature")
3080              Set VulnInfo = New clsVulnInfo
3082              For Each Vuln In Data.arrDbVulnNames
3084                  If Vuln <> "" Then
3086                      VulnInfo.VulnRating(DbStrToVuln(Vuln)) = DbStrToRating(xmlNode.selectSingleNode(Vuln).Text)
3088                  End If
3090              Next
3092              VulnInfo.AttackHeight = xmlNode.getAttribute("attack_height")
3094              VulnInfo.CreatureID = xmlNode.getAttribute("id")
3096              VulnInfo.CreatureName = xmlNode.getAttribute("name")
3098              VulnInfo.SpeciesID = xmlNode.parentNode.Attributes.getNamedItem("id").Text
3100              VulnInfo.SpeciesName = xmlNode.parentNode.Attributes.getNamedItem("name").Text
3102              VulnInfo.IsSpeciesData = False
3104              Set dctCreatures(VulnInfo.CreatureName) = VulnInfo
3106          Next
              
3108          If dctSpecies.Exists("") Then dctSpecies.remove ""
3110          If dctCreatures.Exists("") Then dctCreatures.remove ""
              
3112      Else
3114          wtcwError "Failed to load vuln database: «2»" & App.Path & "\vuln_database.xml"
3116      End If
          
3118      UpdateCtText
          
3120      Set xmlDoc = Nothing
3122      Set xmlNode = Nothing
3124      Set VulnInfo = Nothing
          
3126      Exit Sub
erh:
3128      handleErr "Load"
End Sub

Public Sub UpdateCtText()
3130      On Error GoTo erh
3132      If Not txtVulnDbaseCount Is Nothing Then
3134          If dctCreatures.Count < 1000 Then
3136              txtVulnDbaseCount.Text = Format(dctCreatures.Count, "##0")
3138          Else
3140              txtVulnDbaseCount.Text = Format(dctCreatures.Count, "#,##0")
3142          End If
3144      End If
3146      Exit Sub
erh:
3148      handleErr "UpdateCtText"
End Sub

Public Sub SaveCache()
3150      On Error GoTo erh
          Dim xmlDoc As DOMDocument40, xmlNode As IXMLDOMElement, xmlNode2 As IXMLDOMElement
          Dim i As Long, tmpVul As clsVulnInfo
          Dim Vuln As Variant

3152      If dctIDedCache.Count > 0 Then
3154          Set xmlDoc = New DOMDocument40
3156          Set xmlDoc.documentElement = xmlDoc.createElement("resists")

3158          For i = LBound(dctIDedCache.Items) To UBound(dctIDedCache.Items)
3160              Set tmpVul = dctIDedCache.Items(i)
3162              Set xmlNode = xmlDoc.documentElement.appendChild(xmlDoc.createElement("creature"))
3164              xmlNode.setAttribute "name", dctIDedCache.Keys(i)
3166              xmlNode.setAttribute "id", tmpVul.CreatureID
3168              xmlNode.setAttribute "attack_height", tmpVul.AttackHeight
3170              For Each Vuln In Data.arrDbVulnNames
3172                  If Vuln <> "" Then
3174                      Set xmlNode2 = xmlNode.appendChild(xmlDoc.createElement(Vuln))
3176                      xmlNode2.Text = RatingToDbStr(tmpVul.VulnRating(DbStrToVuln(Vuln)))
3178                  End If
3180              Next
3182          Next
              
3184          writeXML xmlDoc, App.Path & "\vuln_idcache.xml"
3186      End If
3188      Exit Sub
erh:
3190      handleErr "SaveCache"
End Sub

Private Sub Class_Initialize()
3192      On Error GoTo erh
3194      dctCreatures.CompareMode = TextCompare
3196      dctSpecies.CompareMode = TextCompare
3198      dctIDedCache.CompareMode = TextCompare
3200      Load
3202      Exit Sub
erh:
3204      handleErr "Class_Initialize"
End Sub

Private Sub Class_Terminate()
3206      Set dctCreatures = Nothing
3208      Set dctSpecies = Nothing
3210      Set dctIDedCache = Nothing
End Sub
