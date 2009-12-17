VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "HUD"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Private Const CanvasWidth As Long = 300
Private Const CanvasHeight As Long = 800
Private Const IconSize As Long = 16
Private Const IconSpace As Long = 18
Private IconsOnlyHorizontalSpace As Long
Private IconsPerLine As Long

Private WithEvents renderSvc As DecalRender.RenderService
Attribute renderSvc.VB_VarHelpID = -1
Private HUDView As DecalRender.HUDView
Private HUDBackground As DecalRender.HUDBackground

Private myPos As tagPOINT
Private bkgdRect As tagRECT
Private myHitRect As tagRECT

Private ptPoint As tagPOINT
Private iIconCol As Long

Private TimesNewRoman As DecalPlugins.IFontCache
Private Arial As DecalPlugins.IFontCache

Public AlignRight As Boolean
Public TextColor As Long
Public LowTextColor As Long
Private myBackgroundColor As Long
Public ShowTimer As Boolean
Public RecommendVulns As Boolean
Public ShowBestAttackHeight As Boolean
Public IconsOnly As Boolean
Public LifeOnly As Boolean
Public ShowDebuffs As Boolean
Public ShowName As Boolean
Public OnlyBestVulns As Boolean
Public ColorCodeVulns As Boolean
Public TextOnly As Boolean
Private myFontSize As Long
    
Public MouseOnHUD As Boolean

Private bBackgroundEnabled As Boolean
Private bRenderBegun As Boolean, bTextBegun As Boolean

Public Sub BeginRender()
2326      If Not bRenderBegun And Not HUDView Is Nothing Then
2328          bRenderBegun = True
2330          HUDView.BeginRender
2332      End If
End Sub

Private Sub BeginText(FontName As String, lHeight As Long, lWeight As Long, Optional bItalic As Boolean = False)
2334      BeginRender
2336      If bTextBegun Then HUDView.EndText
2338      bTextBegun = True
2340      HUDView.BeginText FontName, lHeight, lWeight, bItalic
End Sub

Public Sub EndRender()
2342      If Not Enabled Then Exit Sub
2344      If bTextBegun Then HUDView.EndText
2346      If bRenderBegun Then
2348          HUDView.EndRender
2350          If bBackgroundEnabled Then
2352              If bkgdRect.Left < 0 Then bkgdRect.Left = 0
2354              If bkgdRect.Top < 0 Then bkgdRect.Top = 0
2356              If bkgdRect.Right > CanvasWidth Then bkgdRect.Right = CanvasWidth
2358              If bkgdRect.Bottom > CanvasHeight Then bkgdRect.Bottom = CanvasHeight
                  
2360              If bkgdRect.Right - bkgdRect.Left < 125 Then
2362                  If AlignRight Then
2364                      bkgdRect.Left = bkgdRect.Right - 125
2366                  Else
2368                      bkgdRect.Right = bkgdRect.Left + 125
2370                  End If
2372              End If

                  Dim relativeRect As Decal.tagRECT
2374              relativeRect = HUDBackground.Region
2376              setRectPos relativeRect, 0, 0

2378              HUDBackground.BeginRender
2380              HUDBackground.Clear relativeRect
2382              HUDBackground.Fill bkgdRect, BackgroundColor
2384              HUDBackground.EndRender
2386          End If
2388      End If
2390      bRenderBegun = False
2392      bTextBegun = False
End Sub

Public Sub SetAlignRight(bAlignRight As Boolean)
2394      If Not AlignRight = bAlignRight Then
2396          AlignRight = bAlignRight
2398          myPos.x = myPos.x + IIf(AlignRight, -1, 1) * (CanvasWidth \ 2)
2400          SetPos myPos 'Validate new position
2402      End If
End Sub

Private Function LineHeight() As Long
2404      If TextOnly Then
2406          LineHeight = FontSize + 2
2408      Else
2410          LineHeight = max(IconSpace, FontSize + 2)
2412      End If
End Function

Public Property Get FontSize() As Long
2414      FontSize = myFontSize
End Property

Public Property Let FontSize(ByVal lFontSize As Long)
2416      On Error GoTo erh
2418      myFontSize = lFontSize
2420      Set TimesNewRoman = PluginSite.DecalCreateFont("Times New Roman", max(myFontSize + 2, 16), 1)
2422      Set Arial = PluginSite.DecalCreateFont("Arial", myFontSize, 1)
2424      Exit Property
erh:
2426      handleErr "FontSize.Let"
End Property

Public Property Get Enabled() As Boolean
2428      If HUDView Is Nothing Then
2430          Enabled = False
2432      Else
2434          Enabled = HUDView.Enabled
2436      End If
End Property

Public Sub Disable()
2438      If Not HUDView Is Nothing Then
2440          HUDView.Enabled = False
2442      End If
2444      myHitRect = makeRect(0, 0, 0, 0)
End Sub

Public Sub Dispose()
2446      Disable
2448      Set HUDView = Nothing
End Sub

' Note: enables the HUD if it is disabled
Public Sub Render(aMonster As clsMonster, Optional aAddtlLines As Long = 0, Optional bLeaveRenderEnabled As Boolean = False)
2450      On Error GoTo erh
          
          Dim SrtVuls() As eVulnType, Vuln, FirstVuln
          Dim colDebuffs As Collection, Debuff
2452      Set colDebuffs = aMonster.debuffs
          
          Dim displayHeight As Long
2454      displayHeight = (LineHeight + 2) * (1 + aAddtlLines + _
              IIf(ShowDebuffs, colDebuffs.Count, 0) + _
              IIf(ShowBestAttackHeight And aMonster.MonsterType = eMonster, 1, 0) + _
              IIf(RecommendVulns And aMonster.MonsterType = eMonster, 8, 0))
          
          Dim absoluteRect As Decal.tagRECT, relativeRect As Decal.tagRECT
2456      absoluteRect = makeRect2(myPos.x, myPos.y, CanvasWidth, CanvasHeight)
2458      relativeRect = absoluteRect
2460      setRectPos relativeRect, 0, 0
          
          Dim bCreate As Boolean
2462      bCreate = False
2464      If HUDView Is Nothing Then
2466          bCreate = True
2468      ElseIf HUDView.Lost Then
2470          bCreate = True
2472      End If
          
2474      If bCreate Then
2476          Set HUDView = renderSvc.CreateHUD(absoluteRect)
2478          Set HUDBackground = renderSvc.CreateBackground(absoluteRect)
2480          HUDView.SetBackground HUDBackground
2482          HUDBackground.BeginRender
2484          HUDBackground.Clear relativeRect
2486          HUDBackground.EndRender
2488      End If
2490      HUDView.Enabled = True
          
          ' Set the HUD's position
2492      HUDView.Region = absoluteRect
          
          'HUDBackground.BeginRender
          'HUDBackground.Clear relativeRect
          'HUDBackground.Fill makeRect2(IIf(AlignRight, canvasWidth / 2, 0), 0, canvasWidth / 2, displayHeight), BackgroundColor
          'HUDBackground.EndRender
          
2494      BeginRender
          
          ' Clear the HUD
2496      HUDView.Clear relativeRect
          
2498      bkgdRect = makeRect(-1, -1, -1, -1)
          
          '' Title
2500      BeginText "Times New Roman Bold", max(FontSize + 2, 16), 0
          
          Dim szTitle As tagSIZE
2502      szTitle = TimesNewRoman.MeasureText(aMonster.MonsterName)
2504      If AlignRight Then
2506          myHitRect = makeRect2(myPos.x + CanvasWidth - szTitle.cx - 2, myPos.y, szTitle.cx + 2, 20)
2508          ptPoint = makePoint(CanvasWidth - szTitle.cx - 2, 0)
2510      Else
2512          myHitRect = makeRect2(myPos.x, myPos.y, szTitle.cx + 2, 20)
2514          ptPoint = makePoint(2, 0)
2516      End If
          
2518      If ShowName Then WriteText aMonster.MonsterName, TextColor, szTitle
          
          '' Vuln info
2520      BeginText "Arial Bold", FontSize, 0
          
2522      If TextOnly Then ptPoint.y = ptPoint.y + 2
          
2524      With aMonster.VulnInfo
2526          If ShowBestAttackHeight And aMonster.MonsterType = eMonster Then
2528              AddLine "Attack: " & IIf(.AttackHeight <> "", .AttackHeight, "Unknown")
2530          End If
              
2532          If RecommendVulns And aMonster.MonsterType = eMonster Then
2534              If .HasVulnInfo Then
2536                  SrtVuls = .SortedVulns
2538                  FirstVuln = SrtVuls(LBound(SrtVuls))
                      
                      'Setting ShowTimer temporarily to True so that it'll show
                      '   the vuln ratings (AA), (VH), etc in Icons Only Mode
                      'A hack -- but too lazy to do it some other way
                      Dim tmpShowTimer As Boolean
2540                  tmpShowTimer = ShowTimer
2542                  ShowTimer = True
                      
2544                  IconsPerLine = 4
2546                  IconsOnlyHorizontalSpace = 25
2548                  iIconCol = 0
2550                  For Each Vuln In SrtVuls
2552                      If OnlyBestVulns And .VulnRating(Vuln) <> .VulnRating(FirstVuln) Then
2554                          Exit For
2556                      Else
2558                          AddLine VulnToStr(Vuln), VulnIcons(Vuln), _
                                  IIf(ColorCodeVulns, RatingColors(.VulnRating(Vuln)), TextColor), True, _
                                  "(" & .VulnRatingStr(Vuln) & ")" 'Putting the Rating in as the Timer text...
2560                      End If
2562                  Next
                      
                      'Restore original show timer value
2564                  ShowTimer = tmpShowTimer
                      
2566                  If .IsSpeciesData Then AddLine "(Species Data)"
2568              Else
2570                  AddLine VulnToStr(eVulnType.eNoVuln), VulnIcons(eVulnType.eNoVuln), bCanShowOnlyIcons:=False
2572              End If
2574          End If
2576      End With
          
2578      IconsPerLine = 3
2580      IconsOnlyHorizontalSpace = 40
2582      iIconCol = 0
2584      If ShowDebuffs Then
2586          For Each Debuff In colDebuffs
2588              If Not LifeOnly Or Debuff.Type = dbfLife Then
2590                  AddLine Debuff.name, Debuff.Icon, IIf(aMonster.IsLowBuff(Debuff.Effect), LowTextColor, TextColor), _
                          aTimeLeft:="(" & aMonster.TimeLeftString(Debuff.Effect) & ")"
2592              End If
2594          Next
2596      End If
          
2598      If Not bLeaveRenderEnabled Then EndRender
          
2600      Exit Sub
erh:
2602      handleErr "HUD.Render"
End Sub

Public Sub AddLine(aText As String, Optional aIcon As Long = 0, Optional lTextColor, Optional bCanShowOnlyIcons As Boolean = True, Optional aTimeLeft As String = "")
2604      If Not bRenderBegun Then Err.Raise 999, Description:="HUD.AddLine called without BeginRender first being called"
2606      If Not bTextBegun Then Err.Raise 998, Description:="HUD.AddLine called without Render first being called"
          
2608      On Error GoTo erh
2610      If IsMissing(lTextColor) Then
2612          lTextColor = TextColor
2614      End If
2616      If aIcon = 0 Then bCanShowOnlyIcons = False
2618      If ShowTimer And aTimeLeft <> "" Then aText = aText & " " & aTimeLeft
          
          Dim szText As tagSIZE
          
2620      If bCanShowOnlyIcons And (IconsOnly Or myPos.y + ptPoint.y + LineHeight > PluginSite2.Hooks.AC3DRegionRect.Bottom) Then
2622          If iIconCol Mod IIf(ShowTimer, IconsPerLine, 10) = 0 Then
2624              If AlignRight Then
2626                  ptPoint = makePoint(CanvasWidth - IconSpace, ptPoint.y + LineHeight)
2628              Else
2630                  ptPoint = makePoint(2, ptPoint.y + LineHeight)
2632              End If
2634          Else
2636              ptPoint.x = ptPoint.x + IIf(AlignRight, -1, 1) * IconSpace
2638          End If
2640          DrawIcon ptPoint, aIcon
2642          If ShowTimer Then
                  Dim ptTmp As DecalPlugins.tagPOINT
2644              ptTmp = ptPoint
2646              szText = Arial.MeasureText(aTimeLeft)
2648              If AlignRight Then
2650                  ptPoint.x = ptPoint.x - szText.cx - 2
2652              Else
2654                  ptPoint.x = ptPoint.x + IconSpace
2656              End If
2658              WriteText aTimeLeft, lTextColor, szText
2660              ptPoint.x = ptTmp.x + IIf(AlignRight, -1, 1) * IconsOnlyHorizontalSpace
2662          End If
2664          iIconCol = iIconCol + 1
2666      Else
2668          iIconCol = 0
2670          ptPoint.y = ptPoint.y + LineHeight
2672          If Not TextOnly And aIcon <> 0 Then
2674              If AlignRight Then ptPoint.x = CanvasWidth - IconSpace Else ptPoint.x = 2
2676              DrawIcon ptPoint, aIcon
2678          End If
              
              Dim xOffset As Long
2680          If TextOnly Or aIcon = 0 Then xOffset = 2 Else xOffset = 20
              
2682          szText = Arial.MeasureText(aText)
2684          If AlignRight Then
2686              ptPoint = makePoint(CanvasWidth - szText.cx - xOffset, ptPoint.y + 2)
2688          Else
2690              ptPoint = makePoint(xOffset, ptPoint.y + 2)
2692          End If
2694          WriteText aText, lTextColor, szText
2696      End If
          
      '    bkgdSize.cy = ptPoint.y + LineHeight
          
2698      Exit Sub
erh:
2700      handleErr "HUD.AddLine"
End Sub

Private Sub DrawIcon(ptLoc As DecalPlugins.tagPOINT, aIcon As Long)
2702      On Error GoTo erh
          
          Dim rectIcon As tagRECT
2704      rectIcon = makeRect2(ptLoc.x + 1, ptLoc.y + 1, IconSize, IconSize)
2706      If aIcon < &H6000000 Then
              ' TODO draw icon from dll
              'Icons.DrawIcon ptLoc, aIcon, App.hInstance, myCanvas
2708      Else
2710          HUDView.DrawPortalImage aIcon, rectIcon
2712      End If
          
2714      If bBackgroundEnabled Then adjustBkgdRect rectIcon.Left - 2, rectIcon.Top - 2, rectIcon.Right + 2, rectIcon.Bottom + 2
          
2716      Exit Sub
erh:
2718      handleErr "HUD.DrawIcon"
End Sub

Private Sub WriteText(sText As String, ByVal lColor As Long, szText As tagSIZE)
2720      If Not bRenderBegun Then Err.Raise 999, Description:="HUD.WriteText called without BeginRender first being called"
2722      If Not bTextBegun Then Err.Raise 998, Description:="HUD.WriteText called without Render first being called"
          
2724      On Error GoTo erh
          
          Dim shade As Long, alpha As Long
2726      Select Case DecorationColor.Selected
              Case eDecorationColor.eClrAuto
2728              If Luminance(lColor) < 0.5 Then
2730                  shade = &HFFFFFF
2732              Else
2734                  shade = 0
2736              End If
                  
2738          Case eDecorationColor.eClrBlack
2740              shade = 0
                  
2742          Case eDecorationColor.eClrDrkGray
2744              shade = &H444444
                  
2746          Case eDecorationColor.eClrLtGray
2748              shade = &HCCCCCC
                  
2750          Case eDecorationColor.eClrWhite
2752              shade = &HFFFFFF
                  
2754      End Select
          
2756      alpha = &HDD000000
          Dim height As Long, width As Long
2758      height = LineHeight
2760      width = CanvasWidth - ptPoint.x - 3
          
2762      Select Case DecorationType.Selected
              Case eDecorationType.eOutline
2764              HUDView.WriteText makeRect2(ptPoint.x + 1, ptPoint.y + 2, width, height), shade Or alpha, 0, sText
2766              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 1, width, height), shade Or alpha, 0, sText
2768              HUDView.WriteText makeRect2(ptPoint.x + 1, ptPoint.y + 0, width, height), shade Or alpha, 0, sText
2770              HUDView.WriteText makeRect2(ptPoint.x + 0, ptPoint.y + 1, width, height), shade Or alpha, 0, sText
2772              alpha = (alpha \ 2) And &HFF000000
2774              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 2, width, height), shade Or alpha, 0, sText
2776              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 0, width, height), shade Or alpha, 0, sText
2778              HUDView.WriteText makeRect2(ptPoint.x + 0, ptPoint.y + 2, width, height), shade Or alpha, 0, sText
2780              HUDView.WriteText makeRect2(ptPoint.x + 0, ptPoint.y + 0, width, height), shade Or alpha, 0, sText

2782          Case eDecorationType.eShortShadow
2784              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 2, width, height), shade Or alpha, 0, sText

2786          Case eDecorationType.eLongShadow
2788              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 2, width, height), shade Or alpha, 0, sText
2790              alpha = (alpha \ 2) And &HFF000000
2792              HUDView.WriteText makeRect2(ptPoint.x + 2, ptPoint.y + 3, width, height), shade Or alpha, 0, sText
2794              HUDView.WriteText makeRect2(ptPoint.x + 3, ptPoint.y + 2, width, height), shade Or alpha, 0, sText
2796              HUDView.WriteText makeRect2(ptPoint.x + 3, ptPoint.y + 3, width, height), shade Or alpha, 0, sText

2798      End Select

2800      HUDView.WriteText makeRect2(ptPoint.x + 1, ptPoint.y + 1, width, height), lColor, 0, sText
          
2802      If bBackgroundEnabled Then adjustBkgdRect ptPoint.x - 2, ptPoint.y - 2, ptPoint.x + szText.cx + 2, ptPoint.y + height
          
2804      Exit Sub
erh:
2806      handleErr "HUD.WriteText"
End Sub

Private Function Luminance(lColor As Long) As Single
2808      On Error GoTo erh
          'ARGB
2810      Luminance = ((lColor And &HFF&) / &HFF&) * 0.11 + _
              ((lColor And &HFF00&) / &HFF00&) * 0.59 + _
              ((lColor And &HFF0000) / &HFF0000) * 0.3
2812      Exit Function
erh:
2814      handleErr "HUD.Luminance"
End Function

Private Sub adjustBkgdRect(Left As Long, Top As Long, Right As Long, Bottom As Long)
2816      If bkgdRect.Left = -1 Then
2818          setRect bkgdRect, Left, Top, Right, Bottom
2820      Else
2822          If Left < bkgdRect.Left Then bkgdRect.Left = Left
2824          If Top < bkgdRect.Top Then bkgdRect.Top = Top
2826          If Right > bkgdRect.Right Then bkgdRect.Right = Right
2828          If Bottom > bkgdRect.Bottom Then bkgdRect.Bottom = Bottom
2830      End If
End Sub

Public Function HitCheck(ByVal checkPosX As Integer, ByVal checkPosY As Integer) As Boolean
2832      On Error GoTo erh
2834      HitCheck = checkPosX >= myHitRect.Left And checkPosX <= myHitRect.Right And _
              checkPosY >= myHitRect.Top And checkPosY <= myHitRect.Bottom
2836      Exit Function
erh:
2838      handleErr "HUD.HitCheck"
End Function

Friend Sub SetPos(ByRef newPos As DecalPlugins.tagPOINT)
2840      On Error GoTo erh
          Dim ACWidth As Long, ACHeight As Long
2842      ACWidth = PluginSite2.Hooks.AC3DRegionRect.Right
2844      ACHeight = PluginSite2.Hooks.AC3DRegionRect.Bottom
          
2846      If AlignRight Then
2848          If newPos.x < -CanvasWidth \ 2 Then newPos.x = -CanvasWidth \ 2
2850          If newPos.x > ACWidth - CanvasWidth Then newPos.x = ACWidth - CanvasWidth
2852      Else
2854          If newPos.x < 0 Then newPos.x = 0
2856          If newPos.x > ACWidth - CanvasWidth \ 2 Then newPos.x = ACWidth - CanvasWidth \ 2
2858      End If
          
2860      If newPos.y < 20 Then newPos.y = 20
2862      If newPos.y > ACHeight + 20 Then newPos.y = ACHeight + 20
              
2864      myPos = newPos
          
2866      If Not HUDView Is Nothing Then
              Dim tmpRect As tagRECT
2868          tmpRect = HUDView.Region
2870          setRectPos tmpRect, myPos.x, myPos.y
2872          HUDView.Region = tmpRect
2874      End If
2876      Exit Sub
erh:
2878      handleErr "HUD.SetPos"
End Sub

Friend Property Get Pos() As DecalPlugins.tagPOINT
2880      Pos = myPos
End Property

Friend Property Let Pos(newPos As DecalPlugins.tagPOINT)
2882      myPos = newPos
2884      If Not HUDView Is Nothing Then
              Dim tmpRect As tagRECT
2886          tmpRect = HUDView.Region
2888          setRectPos tmpRect, myPos.x, myPos.y
2890          HUDView.Region = tmpRect
2892      End If
End Property

Public Property Get RightEdge() As Long
2894      RightEdge = myPos.x + CanvasWidth
End Property

Public Property Let RightEdge(newVal As Long)
2896      myPos.x = newVal - CanvasWidth
End Property

Private Sub Class_Initialize()
2898      On Error GoTo erh
2900      Set renderSvc = PluginSite2.object("services\DecalRender.RenderService")
2902      Set HUDView = Nothing
2904      Set HUDBackground = Nothing
          
2906      AlignRight = False
2908      ShowTimer = True
2910      RecommendVulns = False
2912      ShowBestAttackHeight = False
2914      IconsOnly = False
2916      LifeOnly = False
2918      ShowDebuffs = True
2920      ShowName = True
2922      OnlyBestVulns = False
2924      ColorCodeVulns = False
2926      TextOnly = False
2928      IconsPerLine = 3
2930      IconsOnlyHorizontalSpace = 40
2932      FontSize = 12
2934      iIconCol = 0
          
2936      bRenderBegun = False
2938      bTextBegun = False
          
2940      Exit Sub
erh:
2942      handleErr "HUD.Class_Initialize"
End Sub

Private Sub Class_Terminate()
2944      On Error GoTo erh
2946      If Not HUDView Is Nothing Then EndRender
2948      Set HUDView = Nothing
2950      Set HUDBackground = Nothing
2952      Set renderSvc = Nothing
2954      Set TimesNewRoman = Nothing
2956      Set Arial = Nothing
2958      Exit Sub
erh:
2960      handleErr "HUD.Class_Terminate"
End Sub

Public Property Get BackgroundColor() As Long
2962      BackgroundColor = myBackgroundColor
End Property

Public Property Let BackgroundColor(ByVal lBackgroundColor As Long)
2964      On Error GoTo erh
2966      myBackgroundColor = lBackgroundColor
2968      bBackgroundEnabled = (lBackgroundColor And &HFF000000) <> 0
2970      If Not bBackgroundEnabled And Not HUDBackground Is Nothing Then
              Dim relativeRect As Decal.tagRECT
2972          relativeRect = HUDBackground.Region
2974          setRectPos relativeRect, 0, 0

2976          HUDBackground.BeginRender
2978          HUDBackground.Clear relativeRect
2980          HUDBackground.EndRender
2982      End If
2984      Exit Property
erh:
2986      handleErr "HUD.BackgroundColor.Let"
End Property
