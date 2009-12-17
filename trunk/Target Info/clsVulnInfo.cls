VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsVulnInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public CreatureName As String
Public SpeciesName As String

Public CreatureID As String
Public SpeciesID As String

Public Enum eVulnType
    eNoVuln = 0
    eAcid
    eBludge
    eCold
    eFire
    eLight
    ePierce
    eSlash
End Enum

Public Enum eRating
    eUnknown = 0
    eVeryLow
    eLow
    eBelowAverage
    eAverage
    eAboveAverage
    eHigh
    eVeryHigh
End Enum

Private myVulns(eAcid To eSlash) As eRating
Private myBestVulns As Collection
Private bHasFoundBestVulns As Boolean
Private mySortedVulns(eAcid To eSlash) As eVulnType
Private bHasSortedVulns As Boolean

Public AttackHeight As String
Public IsSpeciesData As Boolean

Public Property Let VulnRating(ByVal aVulnType As eVulnType, newValue As eRating)
3212      myVulns(aVulnType) = newValue
3214      bHasFoundBestVulns = False
3216      bHasSortedVulns = False
End Property

Public Property Get VulnRating(ByVal aVulnType As eVulnType) As eRating
3218      VulnRating = myVulns(aVulnType)
End Property

Public Function VulnRatingStr(ByVal aVulnType As eVulnType) As String
3220      VulnRatingStr = RatingToStr(myVulns(aVulnType))
End Function

Public Function BestVulns() As Collection
3222      On Error GoTo erh
          
3224      If Not bHasFoundBestVulns Then
              Dim i As Long, iBest As Long
              
3226          Set myBestVulns = New Collection
              
3228          If HasVulnInfo Then
3230              iBest = LBound(myVulns)
3232              myBestVulns.add iBest
3234              For i = LBound(myVulns) + 1 To UBound(myVulns)
3236                  If myVulns(i) < myVulns(iBest) Then
3238                      iBest = i
3240                      Set myBestVulns = New Collection
3242                      myBestVulns.add i
3244                  ElseIf myVulns(i) = myVulns(iBest) Then
3246                      myBestVulns.add i
3248                  End If
3250              Next
3252          End If
3254      End If
          
3256      Set BestVulns = myBestVulns
          
3258      Exit Function
erh:
3260      handleErr "BestVulns"
End Function

Public Function SortedVulns() As eVulnType()
3262      On Error GoTo erh
          
3264      If Not bHasSortedVulns Then
              Dim iBest As eVulnType, i As eVulnType, j As eVulnType, tmpMyVulns() As eRating
3266          bHasSortedVulns = True
              
3268          tmpMyVulns = myVulns
              
3270          For i = LBound(mySortedVulns) To UBound(mySortedVulns)
3272              iBest = i
3274              For j = LBound(mySortedVulns) To UBound(myVulns)
3276                  If (tmpMyVulns(j) < tmpMyVulns(iBest) Or tmpMyVulns(iBest) = eUnknown) And _
                              tmpMyVulns(j) <> eUnknown Then
3278                      iBest = j
3280                  End If
3282              Next
3284              mySortedVulns(i) = iBest
3286              tmpMyVulns(iBest) = eUnknown
3288          Next
3290      End If
          
3292      SortedVulns = mySortedVulns
          
3294      Exit Function
erh:
3296      handleErr "SortedVulns"
End Function

Public Function HasVulnInfo() As Boolean
          'False if all vulns are NULL
          Dim i As Long
3298      HasVulnInfo = False
3300      For i = LBound(myVulns) To UBound(myVulns)
3302          If myVulns(i) <> eUnknown Then
3304              HasVulnInfo = True
3306              Exit Function
3308          End If
3310      Next
End Function

Private Sub Class_Initialize()
3312      On Error GoTo erh
          Dim i As Long
3314      For i = LBound(myVulns) To UBound(myVulns)
3316          myVulns(i) = eUnknown
3318      Next
3320      AttackHeight = ""
3322      IsSpeciesData = False
3324      bHasFoundBestVulns = False
3326      bHasSortedVulns = False
3328      Exit Sub
erh:
3330      handleErr "Class_Initialize"
End Sub
