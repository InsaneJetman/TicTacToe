' Tic-Tac-Toe
'
' A simple implementation of the game with 32-bit graphics.
' Designed for FreeBASIC
'
' Syntax: TicTacToe [search depth]
' Computer plays optimally (i.e. no mistakes, it cannot lose) for search depth >= 6

#include "fbgfx.bi"

Enum EAction
    SQUARE_ONE, SQUARE_TWO, SQUARE_THREE, SQUARE_FOUR, SQUARE_FIVE, SQUARE_SIX, SQUARE_SEVEN, SQUARE_EIGHT, SQUARE_NINE
    INCREASE_LEVEL, DECREASE_LEVEL, WAIT_AFTER_MOVE, PLAY_NOW, RESET_FINISHED
End Enum

Declare Sub Initialize ()
Declare Sub LoadImage ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer )
Declare Sub LoadImageAlpha ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer )
Declare Sub LoadImageSlant ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer, reverse As Boolean )
Declare Function LoadMark ( srcImage As Any Ptr, x As Integer, y As Integer, xAlpha As Integer, yAlpha As Integer ) As Any Ptr
Declare Function SetAlpha ( ByVal srcPixel As UInteger, ByVal dstPixel As UInteger, ByVal unused As Any Ptr ) As UInteger
Declare Function AlphaBlend ( ByVal srcPixel As UInteger, ByVal dstPixel As UInteger, ByVal unused As Any Ptr ) As UInteger
Declare Sub DoAction ( action As EAction )
Declare Function PlaySquare ( square As Integer ) As Boolean
Declare Function AI () As Integer
Declare Sub CheckFinish ()
Declare Sub DrawWin ( win As Integer )
Declare Function CheckDraw ( stateX As Integer, stateO As Integer ) As Boolean
Declare Function CheckWin ( statePlayer As Integer ) As Boolean
Declare Function Evaluate ( statePlayer As Integer, stateOpponent As Integer, depth As Integer ) As Integer

Type BaseButton Extends Object
    Declare Sub Init ( wide As Integer, high As Integer, x As Integer, y As Integer, action As EAction )
    Declare Sub MouseMove ( x As Integer, y As Integer )
    Declare Sub MouseUp ( x As Integer, y As Integer )
    Declare Sub MouseDown ( x As Integer, y As Integer )
    Declare Virtual Sub SetStatus ( newStatus As Integer )
    Declare Function InButton ( x As Integer, y As Integer ) As Boolean

    As Integer xMin, xMax
    As Integer yMin, yMax
    status As Integer
    action As EAction
End Type

Type Button Extends BaseButton
    Declare Sub Init ( srcImage As Any Ptr, wide As Integer, high As Integer, xUp As Integer, yUp As Integer, xDown As Integer, yDown As Integer, action As EAction )
    Declare Sub Draw ()
    Declare Sub SetStatus ( newStatus As Integer )

    imgUp As Any Ptr
    imgDown As Any Ptr
End Type

Type ToggleButton Extends Button
    Declare Sub Toggle ()
    Declare Function IsPressed () As Boolean
    imgNormal As Any Ptr
End Type

Dim Shared imgBackground As Any Ptr
Dim Shared imgStatusBar As Any Ptr
Dim Shared imgLevels As Any Ptr
Dim Shared Squares(SQUARE_ONE To SQUARE_NINE) As BaseButton
Dim Shared btnReset As BaseButton
Dim Shared btnPlus As Button
Dim Shared btnMinus As Button
Dim Shared btnWait As ToggleButton
Dim Shared btnPlay As Button
Dim Shared imgHLine As Any Ptr
Dim Shared imgVLine As Any Ptr
Dim Shared imgUpLine As Any Ptr
Dim Shared imgDownLine As Any Ptr
Dim Shared imgX(3) As Any Ptr
Dim Shared imgO(3) As Any Ptr

Const As Double UPDATE_DELAY = .4
Const As Integer MAX_LEVEL = 6
Dim Shared As Integer triple(7) = { &o7, &o70, &o700, &o111, &o222, &o444, &o124, &o421 }
Dim Shared As Integer state(1), player, difficulty, gameOver

Initialize

Do
    Dim k As String = Inkey
    Select Case Len(k)
    Case 0:
        Static As Integer xOld, yOld, leftButtonOld
        Dim As Integer x, y, leftButton
        GetMouse x, y, , leftButton
        leftButton And= 1

        If leftButton <> leftButtonOld Then
            If leftButton Then
                btnPlus.MouseDown x, y
                btnMinus.MouseDown x, y
                btnWait.MouseDown x, y
                btnPlay.MouseDown x, y
                For i As Integer = SQUARE_ONE To SQUARE_NINE
                    Squares(i).MouseDown x, y
                Next i
                btnReset.MouseDown x, y
            Else
                btnPlus.MouseUp x, y
                btnMinus.MouseUp x, y
                btnWait.MouseUp x, y
                btnPlay.MouseUp x, y
                For i As Integer = SQUARE_ONE To SQUARE_NINE
                    Squares(i).MouseUp x, y
                Next i
                btnReset.MouseUp x, y
            End If
        ElseIf x <> xOld OrElse y <> yOld Then
            btnPlus.MouseMove x, y
            btnMinus.MouseMove x, y
            btnWait.MouseMove x, y
            btnPlay.MouseMove x, y
            For i As Integer = SQUARE_ONE To SQUARE_NINE
                Squares(i).MouseMove x, y
            Next i
            btnReset.MouseMove x, y
        End If

        xOld = x
        yOld = y
        leftButtonOld = leftButton
        Sleep 8
    Case 1:
        Select Case Asc(k)
        Case 27:    ' Esc
            End
        Case 8:     ' Backspace
            DoAction WAIT_AFTER_MOVE
            btnWait.Draw
        Case 13:    ' Enter
            DoAction PLAY_NOW
        Case 43:    ' Plus
            DoAction INCREASE_LEVEL
        Case 45:    ' Minus
            DoAction DECREASE_LEVEL
        Case Asc("1") To Asc("9"):
            DoAction Asc(k) - Asc("1") + SQUARE_ONE
        End Select
    Case 2:
        Select Case Asc(Mid(k, 2, 1))
        Case 107:   ' Alt+F4 = "X" clicked
            End
        End Select
    End Select
    If MultiKey(FB.SC_ALT) And MultiKey(FB.SC_F4) Then End  ' Actual Alt+F4 not detected by Inkey
    If gameOver = 1 Then
        Dim As Double t = Timer + UPDATE_DELAY
        gameOver = 2
        While Timer < t: Sleep 1: Wend
    End If
Loop

Sub BaseButton.Init ( wide As Integer, high As Integer, x As Integer, y As Integer, action As EAction )
    xMin = x
    xMax = x + wide
    yMin = y
    yMax = y + high
    This.action = action
End Sub

Sub BaseButton.MouseMove ( x As Integer, y As Integer )
    If status = 0 Then Exit Sub
    SetStatus IIf(InButton(x, y), 1, 2)
End Sub

Sub BaseButton.MouseUp ( x As Integer, y As Integer )
    If status = 0 Then Exit Sub
    If InButton(x, y) Then DoAction action
    SetStatus 0
End Sub

Sub BaseButton.MouseDown ( x As Integer, y As Integer )
    SetStatus IIf(InButton(x, y), 1, 0)
End Sub

Sub BaseButton.SetStatus ( newStatus As Integer )
    status = newStatus
End Sub

Function BaseButton.InButton ( x As Integer, y As Integer ) As Boolean
    Return x >= xMin AndAlso x < xMax AndAlso y >= yMin AndAlso y < yMax
End Function

Sub Button.Init ( srcImage As Any Ptr, wide As Integer, high As Integer, xUp As Integer, yUp As Integer, xDown As Integer, yDown As Integer, action As EAction )
    Base.Init wide, high, xUp, yUp, action
    imgUp = ImageCreate(wide, high)
    imgDown = ImageCreate(wide, high)
    LoadImage srcImage, imgUp, xUp, yUp
    LoadImage srcImage, imgDown, xDown, yDown
End Sub

Sub Button.Draw
    Put (xMin,yMin), IIf(status And 1, imgDown, imgUp), PSet
End Sub

Sub Button.SetStatus ( newStatus As Integer )
    Dim As Boolean changed = (status Xor newStatus) And 1
    Base.SetStatus newStatus
    If changed Then Draw
End Sub

Sub ToggleButton.Toggle
    imgUp = IIf(IsPressed(), imgNormal, imgDown)
End Sub

Function ToggleButton.IsPressed () As Boolean
    Return imgUp = imgDown
End Function

Sub Initialize
    Randomize Timer

    If Command = "" Then
        difficulty = 2
    ElseIf UCase(Command) = "MAX" Then
        difficulty = MAX_LEVEL
    Else
        difficulty = ValInt(Command)
        If difficulty < 0 Then difficulty = 0
        If difficulty > MAX_LEVEL Then difficulty = MAX_LEVEL
    End If

    ScreenRes 576, 648, 32
    Width 72, 40
    WindowTitle "Tic-Tac-Toe"
    Dim allGfx As Any Ptr = ImageCreate(1224, 1008)
    If BLoad("TicTacToe.bmp", allGfx) <> 0 Then
        Locate 19, 17
        Print "Graphics file (TicTacToe.bmp) not found"
        While Inkey = "": Wend
        End
    End If

    imgBackground = ImageCreate(576, 576)
    LoadImage allGfx, imgBackground, 0, 0
    Put (0,0), imgBackground, PSet
    imgStatusBar = ImageCreate(576, 72)
    LoadImage allGfx, imgStatusBar, 0, 576
    Put (0,576), imgStatusBar, PSet
    imgLevels = ImageCreate(224, 32)
    LoadImage allGfx, imgLevels, 20, 668
    Put (164,596), imgLevels, (difficulty * 32, 0)-Step(31,31), PSet

    For i As Integer = SQUARE_ONE To SQUARE_NINE
        Squares(i).Init 144, 144, 72 + 144 * ((i - SQUARE_ONE) Mod 3), 360 - 144 * ((i - SQUARE_ONE) \ 3), i
    Next i
    btnReset.Init 576, 576, 0, 0, RESET_FINISHED

    btnPlus.Init allGfx, 20, 20, 206, 590, 254, 662, INCREASE_LEVEL
    btnMinus.Init allGfx, 20, 20, 206, 614, 254, 686, DECREASE_LEVEL
    btnWait.Init allGfx, 108, 48, 324, 588, 324, 660, WAIT_AFTER_MOVE
    btnWait.imgNormal = btnWait.imgUp
    btnPlay.Init allGfx, 108, 48, 456, 588, 456, 660, PLAY_NOW

    imgHLine = ImageCreate(504, 72)
    LoadImage allGfx, imgHLine, 36, 720
    LoadImageAlpha allGfx, imgHLine, 36, 792
    imgVLine = ImageCreate(72, 504)
    LoadImage allGfx, imgVLine, 576, 0
    LoadImageAlpha allGfx, imgVLine, 576, 504
    imgUpLine = ImageCreate(504, 504, RGBA(0,0,0,255))
    LoadImageSlant allGfx, imgUpLine, 648, 0, True
    imgDownLine = ImageCreate(504, 504, RGBA(0,0,0,255))
    LoadImageSlant allGfx, imgDownLine, 648, 504, False

    imgX(0) = LoadMark( allGfx, 0, 864, 144, 864 )
    imgX(1) = LoadMark( allGfx, 648, 0, 648, 864 )
    imgX(2) = LoadMark( allGfx, 792, 0, 792, 864 )
    imgX(3) = LoadMark( allGfx, 648, 144, 648, 720 )
    imgO(0) = LoadMark( allGfx, 288, 864, 432, 864 )
    imgO(1) = LoadMark( allGfx, 1080, 216, 1080, 648 )
    imgO(2) = LoadMark( allGfx, 936, 360, 936, 504 )
    imgO(3) = LoadMark( allGfx, 1080, 360, 1080, 504 )

    ImageDestroy( allGfx )
End Sub

Sub LoadImage ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer )
    Dim As Integer wide, high
    ImageInfo dstImage, wide, high
    Put dstImage, (0, 0), srcImage, (x, y)-Step(wide - 1, high - 1), PSet
End Sub

Sub LoadImageAlpha ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer )
    Dim As Integer wide, high
    ImageInfo dstImage, wide, high
    Put dstImage, (0, 0), srcImage, (x, y)-Step(wide - 1, high - 1), Custom, @SetAlpha
End Sub

Sub LoadImageSlant ( srcImage As Any Ptr, dstImage As Any Ptr, x As Integer, y As Integer, reverse As Boolean )
    Dim As Integer wide, high, srcPitch, dstPitch
    Dim As ULong Ptr srcPixelData, srcRow, srcRowAlpha, dstPixelData, dstRow

    ImageInfo srcImage, , , , srcPitch, srcPixelData
    ImageInfo dstImage, wide, high, , dstPitch, dstPixelData

    high -= 1: wide -= 1
    srcRow = srcPixelData + x
    srcRow = CPtr(Any Ptr, srcRow) + y * srcPitch
    srcRowAlpha = srcRow + 72
    dstRow = dstPixelData

    For row As Integer = 0 To high
        Dim As Integer min = IIf(reverse, high - row, row) - 36
        Dim As Integer max = min + 71
        If min < 0 Then min = 0
        If max > wide Then max = wide
        For col As Integer = min To max
            dstRow[col] = SetAlpha(srcRowAlpha[col], srcRow[col], 0)
        Next col
        srcRow = CPtr(Any Ptr, srcRow) + srcPitch
        srcRowAlpha = CPtr(Any Ptr, srcRowAlpha) + srcPitch
        dstRow = CPtr(Any Ptr, dstRow) + dstPitch
    Next row
End Sub

Function LoadMark ( srcImage As Any Ptr, x As Integer, y As Integer, xAlpha As Integer, yAlpha As Integer ) As Any Ptr
    Dim As Any Ptr mark = ImageCreate(144, 144)
    LoadImage srcImage, mark, x, y
    LoadImageAlpha srcImage, mark, xAlpha, yAlpha
    Return mark
End Function

Function SetAlpha ( ByVal srcPixel As UInteger, ByVal dstPixel As UInteger, ByVal unused As Any Ptr ) As UInteger
    Return (&hffffff And dstPixel) Or ((255 - (&hff And srcPixel)) Shl 24)
End Function

#define GET_RED(pixel) (255 And (pixel Shr 16))
#define GET_GREEN(pixel) (255 And (pixel Shr 8))
#define GET_BLUE(pixel) (255 And pixel)
#define GET_ALPHA(pixel) (pixel Shr 24)

Function AlphaBlend ( ByVal srcPixel As UInteger, ByVal dstPixel As UInteger, ByVal unused As Any Ptr ) As UInteger
    Dim As UInteger Alpha, red, green, blue
    Alpha = GET_ALPHA(srcPixel)
    red   = ((GET_RED(dstPixel)   * Alpha + 127) \ 255) + GET_RED(srcPixel)
    green = ((GET_GREEN(dstPixel) * Alpha + 127) \ 255) + GET_GREEN(srcPixel)
    blue  = ((GET_BLUE(dstPixel)  * Alpha + 127) \ 255) + GET_BLUE(srcPixel)
    Return RGB(red, green, blue)
End Function

Sub DoAction ( action As EAction )
    Select Case action
    Case SQUARE_ONE To SQUARE_NINE:
        If gameOver Then Exit Sub
        Dim As Integer square = action - SQUARE_ONE
        If PlaySquare(square) Then
            If gameOver <> 0 OrElse btnWait.IsPressed() Then Exit Sub
            Dim As Double t = Timer + UPDATE_DELAY
            square = AI()
            While Timer < t: Sleep 1: Wend
            PlaySquare square
        End If
    Case INCREASE_LEVEL:
        If difficulty < MAX_LEVEL Then
            difficulty += 1
            Put (164,596), imgLevels, (difficulty * 32, 0)-Step(31,31), PSet
        End If
    Case DECREASE_LEVEL:
        If difficulty > 0 Then
            difficulty -= 1
            Put (164,596), imgLevels, (difficulty * 32, 0)-Step(31,31), PSet
        End If
    Case WAIT_AFTER_MOVE:
        btnWait.Toggle
    Case PLAY_NOW:
        If gameOver Then
            DoAction RESET_FINISHED
        Else
            If btnWait.IsPressed() Then btnWait.Toggle: btnWait.Draw
            PlaySquare AI()
        End If
    Case RESET_FINISHED:
        If gameOver > 1 Then
            Put (0,0), imgBackground, PSet
            state(0) = 0
            state(1) = 0
            player = 0
            gameOver = 0
        End If
    End Select
End Sub

Function PlaySquare ( square As Integer ) As Boolean
    Dim As Integer mask = 1 Shl square
    If (state(0) Or state(1)) And mask Then Return False
    If player = 0 Then
        Static whichX As Integer
        Put (72 + 144 * (square Mod 3), 360 - 144 * (square \ 3)), imgX(whichX), Custom, @AlphaBlend
        whichX = (whichX + 1) And 3
    Else
        Static whichY As Integer
        Put (72 + 144 * (square Mod 3), 360 - 144 * (square \ 3)), imgO(whichY), Custom, @AlphaBlend
        whichY = (whichY + 1) And 3
    End If
    state(player) Or= mask
    CheckFinish
    player = 1 - player
    Return True
End Function

Function AI () As Integer
    Dim As Integer stateBoard = state(0) Or state(1)
    Dim As Integer score = -10
    Dim As Integer n, moves, mask, eval
    For mask = 1 To &o400 Step 0
        If (stateBoard And mask) = 0 Then
            eval = Evaluate(state(player) Or mask, state(1 - player), difficulty)
            If eval > score Then
                score = eval
                moves = mask
                n = 1
            ElseIf eval = score Then
                moves Or= mask
                n += 1
            End If
        End If
        mask Shl= 1
    Next mask

    n = Int(Rnd * n)
    mask = 1
    For move As Integer = 0 To 8
        If (moves And mask) <> 0 Then
            If n = 0 Then Return move
            n -= 1
        End If
        mask Shl= 1
    Next move
    Return 0
End Function

Sub CheckFinish
    Dim As Double t = Timer + UPDATE_DELAY
    Dim As Integer statePlayer = state(player)
    For win As Integer = 0 To 7
        If (statePlayer And triple(win)) = triple(win) Then
            gameOver = 1
            While Timer < t: Sleep 1: Wend
            DrawWin win
        End If
    Next win
    If gameOver Then Exit Sub
    If CheckDraw(state(0), state(1)) Then gameOver = 1
End Sub

Sub DrawWin ( win As Integer )
    If win < 3 Then
        Put (36, 396 - 144 * win), imgHLine, Custom, @AlphaBlend
    ElseIf win < 6 Then
        Put (108 + 144 * (win - 3), 36), imgVLine, Custom, @AlphaBlend
    ElseIf win = 6 Then
        Put (36, 36), imgDownLine, Custom, @AlphaBlend
    ElseIf win = 7 Then
        Put (36, 36), imgUpLine, Custom, @AlphaBlend
    End If
End Sub

Function CheckDraw ( stateX As Integer, stateO As Integer ) As Boolean
    Return ((stateX Or stateO) And &o777) = &o777
End Function

Function CheckWin ( statePlayer As Integer ) As Boolean
    For win As Integer = 0 To 7
        If (statePlayer And triple(win)) = triple(win) Then Return True
    Next win
    Return False
End Function

Function Evaluate ( statePlayer As Integer, stateOpponent As Integer, depth As Integer ) As Integer
    If depth <= 0 Then Return 0
    If CheckWin(statePlayer) Then Return depth
    If CheckDraw(statePlayer, stateOpponent) Then Return 0
    Dim As Integer stateBoard = statePlayer Or stateOpponent
    Dim As Integer score = -10
    For mask As Integer = 1 To &o400 Step 0
        If (stateBoard And mask) = 0 Then
            Dim As Integer eval = Evaluate(mask Or stateOpponent, statePlayer, depth - 1)
            If eval > score Then score = eval
        End If
        mask Shl= 1
    Next mask
    Return -score
End Function
