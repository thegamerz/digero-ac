VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMonster"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public MonsterName As String
Public MonsterGUID As Long
Public MonsterType As DecalFilters.eObjectClass
Public VulnInfo As clsVulnInfo

Private MyDebuffTime As New Dictionary

Public Enum eDebuffType
    dbfCrit
    dbfLife
End Enum

Public Type tDebuff
    Effect As Long
    name As String
    Icon As Long
    Type As eDebuffType
    SpellWords As String
End Type

Private Sub Class_Initialize()
2046      On Error GoTo erh
          
          'Set up order and valid effects
          Dim Effect
2048      For Each Effect In Data.EffectsArray
2050          MyDebuffTime(Effect) = False
2052      Next
2054      Set VulnInfo = New clsVulnInfo
          
2056      Exit Sub
erh:
2058      handleErr "clsMonster.Class_Initialize"
End Sub

Public Sub Init(ByRef wObj As WorldObject)
2060      On Error GoTo erh
2062      MonsterGUID = wObj.GUID
2064      MonsterType = wObj.ObjectClass
2066      MonsterName = wObj.name
          
2068      If MonsterType <> eMonster Then
2070          Set VulnInfo = New clsVulnInfo
2072      Else
2074          Set VulnInfo = VulnDbase(MonsterName, wObj.Longs(keySpecies, -1))
2076          If Not VulnInfo.HasVulnInfo And Not wObj.HasIdData Then
                  'Try to get species data
2078              PluginSite2.Hooks.RequestID MonsterGUID
2080          End If
2082      End If
          
2084      Exit Sub
erh:
2086      handleErr "clsMonster.Init"
End Sub

Private Sub Class_Terminate()
2088      Set MyDebuffTime = Nothing
End Sub

Public Function IsDebuffActive(ByVal ParticleEffect As Long) As Boolean
2090      If ValidEffect(ParticleEffect) Then
2092          If CBool(MyDebuffTime(ParticleEffect)) Then
2094              IsDebuffActive = ExpireTime(ParticleEffect) > Now
2096          Else
2098              IsDebuffActive = False
2100          End If
2102      End If
End Function

Public Sub ClearDebuff(ByVal ParticleEffect As Long)
2104      If ValidEffect(ParticleEffect) Then MyDebuffTime(ParticleEffect) = False
End Sub

Public Property Get DebuffTime(ParticleEffect As Long) As Date
2106      If ValidEffect(ParticleEffect) Then DebuffTime = MyDebuffTime(ParticleEffect)
End Property

Public Property Let DebuffTime(ParticleEffect As Long, Val As Date)
2108      If ValidEffect(ParticleEffect) Then MyDebuffTime(ParticleEffect) = Val
End Property

Public Function ValidEffect(ByVal ParticleEffect As Long) As Boolean
2110      ValidEffect = MyDebuffTime.Exists(ParticleEffect)
End Function

'A collection of only the debuffs that are enabled
Public Property Get debuffs() As Collection
2112      On Error GoTo erh
2114      Set debuffs = New Collection
          Dim ParticleEffect
2116      For Each ParticleEffect In MyDebuffTime.Keys
2118          If IsDebuffActive(ParticleEffect) Then debuffs.add DebuffInfo(ParticleEffect)
2120      Next
2122      Exit Property
erh:
2124      handleErr "clsMonster.Debuffs"
End Property

Public Function TimeLeftString(ByVal ParticleEffect As Long) As String
2126      On Error GoTo erh
          
          Dim TimeLeft As Date
2128      TimeLeft = MyDebuffTime(ParticleEffect) + SpellTime(DebuffInfo(ParticleEffect).Type) - Now
2130      TimeLeftString = Format(TimeLeft, "n:ss")
          
2132      Exit Function
erh:
2134      handleErr "clsMonster.TimeLeftString"
End Function

Public Function IsLowBuff(ByVal ParticleEffect As Long) As Boolean
2136      On Error GoTo erh
          
          Dim TimeLeft As Date
2138      TimeLeft = MyDebuffTime(ParticleEffect) + SpellTime(DebuffInfo(ParticleEffect).Type) - Now
2140      IsLowBuff = 60 * Minute(TimeLeft) + Second(TimeLeft) <= LowBuffThresh
          
2142      Exit Function
erh:
2144      handleErr "clsMonster.IsLowBuff"
End Function

Public Function ExpireTime(ByVal ParticleEffect As Long) As Date
2146      On Error GoTo erh
          
2148      ExpireTime = MyDebuffTime(ParticleEffect) + SpellTime(DebuffInfo(ParticleEffect).Type)
          
2150      Exit Function
erh:
2152      handleErr "clsMonster.ExpireTime"
End Function
