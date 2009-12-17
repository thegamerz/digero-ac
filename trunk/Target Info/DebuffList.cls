VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "debuffList"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private num As Long, capacity As Long
Private debuffs() As Enchantment
Private spells() As Spell
Private actives() As Boolean
Private numActive As Long, numActiveLife  As Long

Public Property Get Count() As Long
4026      Count = num
End Property

' Default property
Public Property Get Enchantment(index As Long) As Enchantment
4028      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4030      Set Enchantment = debuffs(index)
End Property

Public Property Get Spell(index As Long) As Spell
4032      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4034      Set Spell = spells(index)
End Property

Public Property Get ActiveCount() As Long
4036      ActiveCount = numActive
End Property

Public Property Get ActiveLifeCount() As Long
4038      ActiveLifeCount = numActiveLife
End Property

Public Property Get Active(index As Long) As Boolean
4040      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4042      Active = actives(index)
End Property

Public Property Get ActiveLife(index As Long) As Boolean
4044      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4046      ActiveLife = actives(index) And isLife(index)
End Property

Public Function isLife(index As Long) As Boolean
4048      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4050      On Error GoTo erh
4052      isLife = spells(index).SpellSchool = 2
4054      Exit Function
erh:
4056      handleErr "isLife"
End Function

Public Function add(ench As Enchantment, Optional Spell As Spell = Nothing) As Boolean
4058      On Error GoTo erh
4060      add = False
4062      If ench Is Nothing Then Exit Function
          
4064      If Spell Is Nothing Then
4066          Set Spell = SpellF.SpellByID(ench.SpellID)
4068          If Spell Is Nothing Then Exit Function
4070      End If
          
4072      ensureCapacity num + 1
          
          'msgbox "Add " & Spell.name & vbNewLine & "Current num: " & num
          
          Dim i As Long, j As Long, cmp As Long
4074      For i = 0 To num - 1
4076          cmp = compareEnch(debuffs(i), ench)
4078          If cmp = 0 Then
4080              add = True
4082              Set debuffs(i) = ench
4084              Set spells(i) = Spell
4086              Exit For
4088          ElseIf cmp < 0 Then
                  ' Belongs before current one
4090              add = True
                  ' Shift rest one over
4092              For j = num - 1 To i Step -1
4094                  Set debuffs(j + 1) = debuffs(j)
4096                  Set spells(j + 1) = spells(j)
4098                  actives(j + 1) = actives(j)
4100              Next
4102              Set debuffs(i) = ench
4104              Set spells(i) = Spell
4106              num = num + 1
4108              Exit For
4110          End If
4112      Next
          
          ' Add to end
4114      If Not add Then
4116          Set debuffs(num) = ench
4118          Set spells(num) = Spell
4120          num = num + 1
4122          add = True
4124      End If
          
          'msgbox "Before update actives"
4126      updateActives ench.family
          'msgbox "After update actives"
          
4128      Exit Function
erh:
4130      handleErr "DebuffList.add"
End Function

Public Function indexOf(ByRef ench As Enchantment) As Long
4132      On Error GoTo erh
4134      indexOf = -1
4136      If ench Is Nothing Then Exit Function
          
      '    indexOf = indexOfBinarySearch(ench, 0, num - 1)
          
          Dim i As Long
4138      For i = 0 To num - 1
4140          If compareEnch(debuffs(i), ench) = 0 Then
4142              indexOf = i
4144              Exit For
4146          End If
4148      Next
4150      Exit Function
erh:
4152      handleErr "DebuffList.indexOf"
End Function

Private Function indexOfBinarySearch(ByRef ench As Enchantment, ByVal min As Long, ByVal max As Long) As Long
4154      On Error GoTo erh
4156      If max < min Then
4158          indexOfBinarySearch = -1
4160      ElseIf max = min Then
4162          indexOfBinarySearch = IIf(compareEnch(ench, debuffs(max)) = 0, max, -1)
4164      Else
              Dim i As Long, cmp As Long
4166          i = (min + max) \ 2
4168          cmp = compareEnch(ench, debuffs(i))
4170          If cmp = 0 Then
4172              indexOfBinarySearch = i
4174          ElseIf cmp < 0 Then
4176              indexOfBinarySearch = indexOfBinarySearch(ench, min, i - 1)
4178          Else
4180              indexOfBinarySearch = indexOfBinarySearch(ench, i + 1, max)
4182          End If
4184      End If
4186      Exit Function
erh:
4188      handleErr "DebuffList.indexOfBinarySearch"
End Function

Public Function remove(ench As Enchantment) As Boolean
4190      On Error GoTo erh
4192      remove = False
4194      If ench Is Nothing Then Exit Function
          
          Dim i As Long
4196      i = indexOf(ench)
4198      If i >= 0 Then
4200          remove = True
4202          removeIndex i
4204      End If
          
4206      Exit Function
erh:
4208      handleErr "DebuffList.remove"
End Function

Public Sub removeExpired()
4210      On Error GoTo erh
          Dim i As Long
4212      i = 0
4214      Do While i < num
4216          If debuffs(i).TimeRemaining < 0 Then
4218              removeIndex i
4220          End If
4222          i = i + 1
4224      Loop
4226      Exit Sub
erh:
4228      handleErr "DebuffList.removeExpired"
End Sub

Public Sub removeIndex(index As Long)
4230      If index >= num Or index < 0 Then Err.Raise 9 'subscript out of range
4232      On Error GoTo erh
          Dim i As Long, ench As Enchantment
4234      Set ench = debuffs(index)
4236      For i = index To num - 1
4238          Set debuffs(i) = debuffs(i + 1)
4240          Set spells(i) = spells(i + 1)
4242          actives(i) = actives(i + 1)
4244      Next
4246      num = num - 1
          
4248      updateActives ench.family
4250      Set ench = Nothing
4252      Exit Sub
erh:
4254      handleErr "DebuffList.removeIndex"
End Sub

Private Sub updateActives(family As Long)
4256      On Error GoTo erh
          Dim activeIndex As Long, i As Long
4258      activeIndex = -1
4260      For i = 0 To num - 1
4262          If debuffs(i).family = family Then
4264              If actives(i) Then
4266                  actives(i) = False
4268                  numActive = numActive - 1
4270                  If isLife(i) Then numActiveLife = numActiveLife - 1
4272              End If
4274              If activeIndex = -1 Then
4276                  activeIndex = i
4278              ElseIf debuffs(i).Adjustment > debuffs(activeIndex).Adjustment Or _
                          (debuffs(i).Adjustment = debuffs(activeIndex).Adjustment And _
                          debuffs(i).Layer > debuffs(activeIndex).Layer) Then
4280                  activeIndex = i
4282              End If
4284          End If
4286      Next
          
4288      If activeIndex >= 0 Then
4290          actives(activeIndex) = True
4292          numActive = numActive + 1
4294          If isLife(activeIndex) Then numActiveLife = numActiveLife + 1
4296      End If
          
4298      Exit Sub
erh:
4300      handleErr "DebuffList.updateActives"
End Sub

Private Function compareEnch(a As Enchantment, b As Enchantment) As Long
4302      On Error GoTo erh
4304      If a Is Nothing And b Is Nothing Then
4306          compareEnch = 0
4308      ElseIf a Is Nothing Or b Is Nothing Then
4310          compareEnch = IIf(a Is Nothing, -1, 1)
4312      ElseIf a.family = b.family And a.Layer = b.Layer Then
4314          compareEnch = 0 ' Equal
4316      ElseIf a.family = b.family Then
4318          compareEnch = IIf(a.Layer < b.Layer, -1, 1)
4320      Else
4322          compareEnch = IIf(a.family < b.family, -1, 1)
4324      End If
4326      Exit Function
erh:
4328      handleErr "DebuffList.compareEnch"
End Function

Private Sub ensureCapacity(cap As Long)
4330      On Error GoTo erh
4332      If cap > capacity Then
4334          capacity = cap * 2
4336          ReDim Preserve debuffs(0 To capacity)
4338          ReDim Preserve spells(0 To capacity)
4340          ReDim Preserve actives(0 To capacity)
4342      End If
4344      Exit Sub
erh:
4346      handleErr "DebuffList.ensureCapacity"
End Sub

Private Sub Class_Initialize()
4348      On Error GoTo erh
4350      num = 0
4352      numActive = 0
4354      capacity = 10
4356      ReDim debuffs(0 To capacity)
4358      ReDim spells(0 To capacity)
4360      ReDim actives(0 To capacity)
4362      Exit Sub
erh:
4364      handleErr "DebuffList.Class_Initialize"
End Sub

Private Sub Class_Terminate()
4366      On Error GoTo erh
          Dim i As Long
4368      For i = 0 To num - 1
4370          Set debuffs(i) = Nothing
4372          Set spells(i) = Nothing
4374      Next
4376      Exit Sub
erh:
4378      handleErr "DebuffList.Class_Initialize"
End Sub
