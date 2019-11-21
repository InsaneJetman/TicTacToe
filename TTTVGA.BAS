' Tic-Tac-Toe
'
' A simple implementation of the game with VGA graphics.
' Compatible with QuickBasic
'
' Syntax: TTTVGA [search depth]
' Computer plays optimally (i.e. no mistakes, it cannot lose) for search depth >= 6

DefInt A-Z

Declare Sub CheckFinish (player$)
Declare Sub DrawCaps (x1, y1, x2, y2, delta)
Declare Sub DrawBoard ()
Declare Sub DrawBackground ()
Declare Sub DrawCapVertical (x, y, delta, colour)
Declare Sub DrawCapHorizontal (x, y, delta, colour)
Declare Sub DrawCross (delta, colour)
Declare Sub DrawLineDiagonal (x, y, dx, dy, edge, fill)
Declare Sub DrawLineHorizontal (x, y, length, shift, edge, fill)
Declare Sub DrawLineVertical (x, y, length, shift, edge, fill)
Declare Sub DrawSymbol (player, kval)
Declare Sub DrawWin (win)
Declare Sub Finish (message$)
Declare Sub Initialize ()
Declare Sub PlayAI (delay#)
Declare Sub SetPalette ()
Declare Function CheckDraw (stateX, stateO)
Declare Function CheckWin (statePlayer)
Declare Function Evaluate (statePlayer, stateOpponent, depth)

Const SLANT = 24
Const FULLSLANT = 2 * SLANT
Const SHIFTSYMBOL = FULLSLANT \ 3
Const SHIFTLINE = SLANT \ 3
Const THICKNESS = 8
Const FULLTHICKNESS = 2 * THICKNESS
Const UPDATEDELAY = .4

Randomize Timer
Dim Shared brick(0 To 128) As Long
Dim Shared symbol(0 To 512, 0 To 1) As Long
Dim Shared triple(0 To 7), state(0 To 1), player, difficulty
triple(0) = &o7: triple(1) = &o70: triple(2) = &o700
triple(3) = &o111: triple(4) = &o222: triple(5) = &o444
triple(6) = &o124: triple(7) = &o421
If Command$ = "" Then difficulty = 6 Else difficulty = Val(Command$)
If difficulty > 9 Then difficulty = 9

Initialize
DrawBackground
DrawBoard
SetPalette

Do
    Do: k$ = Inkey$: Loop While k$ = ""
    kval = Asc(k$)
    Select Case kval
    Case 27:    ' Esc
        Finish "Game Aborted"
    Case 8:     ' Backspace
        SkipAI = 1
    Case 13:    ' Enter
        PlayAI 0
    Case Asc("1") To Asc("9"):
        kval = kval - Asc("1")
        mask = 2 ^ kval
        If ((state(0) Or state(1)) And mask) = 0 Then
            state(player) = state(player) Or mask
            DrawSymbol player, kval
            CheckFinish "Player"
            player = 1 - player
            If SkipAI = 0 Then PlayAI UPDATEDELAY
            SkipAI = 0
        End If
    End Select
Loop

Data          0, &hfeffffff, &hd86f6e65, &h24000182, &h9c29a53d, &h60d258c0, &h80ad2c29, &h1c129186, &hc440bf53, &h289800a4
Data &h387aaf5b, &h840140a4, &h5485353c, &h80280282, &h64fdf44f, &h18020980, &h8c493e39, &h50a00086, &h60daed2f, &h8c0510c0
Data &hf01fc02a, &h08602790, &h5c35952c, &h008a2091, &h3cb04767, &hc00a9088, &hb4ede909, &h000204a2, 0, &h80, 0, 0

Function CheckDraw (stateX, stateO)
    CheckDraw = (((stateX Or stateO) And &o777) = &o777)
End Function

Sub CheckFinish (player$)
    t# = Timer + UPDATEDELAY
    statePlayer = state(player)
    For win = 0 To 7
        If (statePlayer And triple(win)) = triple(win) Then
            While Timer < t#: Wend
            DrawWin win
            Result$ = player$ + " Wins"
        End If
    Next win
    If Result$ = "" And CheckDraw(state(0), state(1)) Then Result$ = "Drawn Game"
    If Result$ <> "" Then
        While Inkey$ = "": Wend
        Finish Result$
    End If
End Sub

Function CheckWin (statePlayer)
    CheckWin = 1
    For win = 0 To 7
        If (statePlayer And triple(win)) = triple(win) Then Exit Function
    Next win
    CheckWin = 0
End Function

Sub DrawBackground
    Cls

    ' draw 5x5 panel
    ReDim bigbrick(0 To 3600) As Long
    For y = 0 To 159 Step 32
    For x = 0 To 159 Step 32
        Put (x, y), brick, Xor
    Next x, y
    Get (0, 0)-Step(159, 159), bigbrick

    ' draw background
    For y = 0 To 479 Step 160
    For x = 0 To 639 Step 160
        If x <> 0 Or y <> 0 Then Put (x, y), bigbrick, Xor
    Next x, y
End Sub

Sub DrawBoard
    DrawLineHorizontal 128 + SHIFTLINE, 176, 383, 0, 4, 8
    DrawLineHorizontal 128 - SHIFTLINE, 304, 383, 0, 4, 8
    DrawLineVertical 256 + SLANT, 48, 383, -FULLSLANT, 4, 8
    DrawLineVertical 384 + SLANT, 48, 383, -FULLSLANT, 4, 8

    Line (382 + SHIFTLINE - THICKNESS, 176 - THICKNESS)-Step(FULLTHICKNESS + 3, FULLTHICKNESS - 1), 4, BF
    Line (382 + SHIFTLINE - THICKNESS, 178 - THICKNESS)-Step(FULLTHICKNESS + 3, FULLTHICKNESS - 5), 8, BF
    Line (254 - SHIFTLINE - THICKNESS, 304 - THICKNESS)-Step(FULLTHICKNESS + 3, FULLTHICKNESS - 1), 4, BF
    Line (254 - SHIFTLINE - THICKNESS, 306 - THICKNESS)-Step(FULLTHICKNESS + 3, FULLTHICKNESS - 5), 8, BF
End Sub

Sub DrawCapHorizontal (x, y, delta, colour)
    Line (x + delta, y - THICKNESS)-Step(0, FULLTHICKNESS - 1), colour
    Line (x + 2 * delta, y - THICKNESS + 1)-Step(0, FULLTHICKNESS - 3), colour
End Sub

Sub DrawCapVertical (x, y, delta, colour)
    Line (x - THICKNESS, y + delta)-Step(FULLTHICKNESS - 1, 0), colour
    Line (x - THICKNESS + 1, y + 2 * delta)-Step(FULLTHICKNESS - 3, 0), colour
End Sub

Sub DrawCross (delta, colour)
    Line (128 + SHIFTLINE, 176 + delta)-Step(383, 0), colour
    Line (128 - SHIFTLINE, 304 + delta)-Step(383, 0), colour
    Line (256 + SLANT + delta, 48)-Step(-FULLSLANT, 383), colour
    Line (384 + SLANT + delta, 48)-Step(-FULLSLANT, 383), colour
End Sub

Sub DrawLineDiagonal (x, y, dx, dy, edge, fill)
    direction = Sgn(dy)
    dx2 = dx - THICKNESS
    dy2 = dy - direction * THICKNESS

    Line (x + THICKNESS, y)-Step(dx2, dy2), edge
    Line (x + THICKNESS, y + direction)-Step(dx2, dy2), edge
    Line (x, y + direction * THICKNESS)-Step(dx2, dy2), edge
    Line (x + 1, y + direction * THICKNESS)-Step(dx2, dy2), edge

    For i = 2 - THICKNESS To THICKNESS - 2
        d = (THICKNESS - i + 1) \ 2
        Line (x + d + i, y + direction * d)-Step(dx2, dy2), fill
    Next i

    Line (x, y + direction * THICKNESS)-(x + THICKNESS, y), edge
    Line (x, y + direction * (THICKNESS - 1))-(x + THICKNESS - 1, y), edge
    Line (x + dx, y + dy - direction * THICKNESS)-(x + dx - THICKNESS, y + dy), edge
    Line (x + dx, y + dy - direction * (THICKNESS - 1))-(x + dx - THICKNESS + 1, y + dy), edge
End Sub

Sub DrawLineHorizontal (x, y, length, shift, edge, fill)
    x0 = x + 2
    dx = length - 4

    Line (x0, y - THICKNESS)-Step(dx, shift), edge
    Line (x0, y - THICKNESS + 1)-Step(dx, shift), edge
    Line (x0, y + THICKNESS - 2)-Step(dx, shift), edge
    Line (x0, y + THICKNESS - 1)-Step(dx, shift), edge

    DrawCapHorizontal x0, y, -1, edge
    DrawCapHorizontal x0 + dx, y + shift, 1, edge

    For delta = 2 - THICKNESS To THICKNESS - 3
        Line (x0, y + delta)-Step(dx, shift), fill
    Next delta
End Sub

Sub DrawLineVertical (x, y, length, shift, edge, fill)
    y0 = y + 2
    dy = length - 4

    Line (x - THICKNESS, y0)-Step(shift, dy), edge
    Line (x - THICKNESS + 1, y0)-Step(shift, dy), edge
    Line (x + THICKNESS - 2, y0)-Step(shift, dy), edge
    Line (x + THICKNESS - 1, y0)-Step(shift, dy), edge

    DrawCapVertical x, y0, -1, edge
    DrawCapVertical x + shift, y0 + dy, 1, edge

    For delta = 2 - THICKNESS To THICKNESS - 3
        Line (x + delta, y0)-Step(shift, dy), fill
    Next delta
End Sub

Sub DrawSymbol (player, kval)
    row = kval \ 3
    x = 128 + 32 + 128 * (kval Mod 3) + (row - 1) * SHIFTSYMBOL
    y = 48 + 32 + 128 * (2 - row)
    Put (x, y), symbol(0, player), Or
End Sub

Sub DrawWin (win)
    If win < 3 Then
        row = win - 1
        DrawLineHorizontal 128 + row * SHIFTSYMBOL, 240 - row * 128, 383, 0, 13, 14
    ElseIf win < 6 Then
        col = win - 4
        DrawLineVertical 320 + col * 128 + SLANT, 48, 383, -FULLSLANT, 13, 14
    ElseIf win = 6 Then
        DrawLineDiagonal 128 + SLANT, 48, 383 - FULLSLANT, 383, 13, 14
    ElseIf win = 7 Then
        DrawLineDiagonal 128 - SLANT, 432, 383 + FULLSLANT, -383, 13, 14
    End If
End Sub

Function Evaluate (statePlayer, stateOpponent, depth)
    If depth <= 0 Then
        Evaluate = 0
    ElseIf CheckWin(statePlayer) Then
        Evaluate = depth
    ElseIf CheckDraw(statePlayer, stateOpponent) Then
        Evaluate = 0
    Else
        score = -10
        For mask = 1 To &o400 Step 0
            If ((statePlayer Or stateOpponent) And mask) = 0 Then
                eval = Evaluate(mask Or stateOpponent, statePlayer, depth - 1)
                If eval > score Then score = eval
            End If
            mask = mask * 2
        Next mask
        Evaluate = -score
    End If
End Function

Sub Finish (message$)
    Screen 0
    Print message$
    End
End Sub

Sub Initialize
    ' load brick data
    brick(0) = &h100020
    For i = 1 To 64 Step 4
        Read brick(i)
        Read brick(i + 1)
    Next i

    ' switch to VGA graphics mode
    Screen 12
    For i = 0 To 15
        Palette i, 0
    Next i

    ' construct brick image
    Put (16, 0), brick, Xor
    Put (0, 16), brick, Xor
    Put (32, 16), brick, Xor
    Get (16, 0)-Step(31, 31), brick

    'draw X
    DrawLineDiagonal 0, 32, 63, 63, 3, 7
    DrawLineDiagonal 0, 95, 63, -63, 3, 7
    Line (25, 57)-(38, 70), 7, BF
    Get (0, 32)-Step(63, 63), symbol(0, 0)

    'draw O
    For y = -63 To 63 Step 2
    For x = -63 To 63 Step 2
        r = x * x + y * y
        If r <= 40 * 40 Then
        ElseIf r <= 44 * 44 Then
            PSet ((x + 63) \ 2, 96 + (y + 63) \ 2), 11
        ElseIf r <= 60 * 60 Then
            PSet ((x + 63) \ 2, 96 + (y + 63) \ 2), 15
        ElseIf r <= 64 * 64 Then
            PSet ((x + 63) \ 2, 96 + (y + 63) \ 2), 11
        End If
    Next x, y
    Get (0, 96)-Step(63, 63), symbol(0, 1)
End Sub

Sub PlayAI (delay#)
    t# = Timer + delay#
    score = -10
    For mask = 1 To &o400 Step 0
        If ((state(0) Or state(1)) And mask) = 0 Then
            eval = Evaluate(state(player) Or mask, state(1 - player), difficulty)
            If eval > score Then
                score = eval
                moves = mask
                n = 1
            ElseIf eval = score Then
                moves = moves Or mask
                n = n + 1
            End If
        End If
        mask = mask * 2
    Next mask

    n = Int(Rnd * n)
    mask = 1
    For move = 0 To 8
        If (moves And mask) <> 0 Then
            If n = 0 Then
                While Timer < t#: Wend
                state(player) = state(player) Or mask
                DrawSymbol player, move
                CheckFinish "Computer"
                player = 1 - player
                Exit For
            End If
            n = n - 1
        End If
        mask = mask * 2
    Next move
End Sub

Sub SetPalette
Palette 1, &h201000
Palette 2, &h2a1500
Palette 4, &h1c2a
Palette 8, &h2a3f
Palette 3, &h15
Palette 7, &h2a
Palette 11, &h1500
Palette 15, &h2a00
Palette 13, &h2a001c
Palette 14, &h3f002a
End Sub

