' Tic-Tac-Toe
'
' A simple implementation of the game.
' Compatible with QuickBASIC and FreeBASIC
'
' Syntax: TTT [search depth]
' Computer plays optimally (i.e. no mistakes, it cannot lose) for search depth >= 6

'$lang: "qb"
DefInt A-Z

Declare Sub DrawSymbol (player, kval)
Declare Sub Finish (message$)
Declare Sub PlayAI ()
Declare Function CheckDraw (stateX, stateO)
Declare Function CheckWin (statePlayer)
Declare Function Evaluate (statePlayer, stateOpponent, depth)

Randomize Timer
Dim Shared triple(0 To 7), bias(0 To 8), state(0 To 1), player, difficulty
triple(0) = &o7: triple(1) = &o70: triple(2) = &o700
triple(3) = &o111: triple(4) = &o222: triple(5) = &o444
triple(6) = &o124: triple(7) = &o421
bias(0) = 3: bias(1) = 2: bias(2) = 3
bias(3) = 2: bias(4) = 4: bias(5) = 2
bias(6) = 3: bias(7) = 2: bias(8) = 3
If Command$ = "" Then difficulty = 6 Else difficulty = Val(Command$)
If difficulty > 9 Then difficulty = 9

Print
Print "     |   |   "
Print "  ---+---+---"
Print "     |   |   "
Print "  ---+---+---"
Print "     |   |   "
Print
Locate , , 1

Do
    Do: k$ = Inkey$: Loop While k$ = ""
    kval = Asc(k$)
    Select Case kval
    Case 27:    ' Esc
        Finish "Game Aborted"
    Case 8:     ' Backspace
        SkipAI = 1
    Case 13:    ' Enter
        PlayAI
    Case Asc("1") To Asc("9"):
        kval = kval - Asc("1")
        mask = 2 ^ kval
        If ((state(0) Or state(1)) And mask) = 0 Then
            state(player) = state(player) Or mask
            DrawSymbol player, kval
            If CheckWin(state(player)) Then Finish "Player Wins"
            If CheckDraw(state(0), state(1)) Then Finish "Drawn Game"
            player = 1 - player
            If SkipAI = 0 Then PlayAI
            SkipAI = 0
        End If
    End Select
Loop

Function CheckDraw (stateX, stateO)
    CheckDraw = (((stateX Or stateO) And &o777) = &o777)
End Function

Function CheckWin (statePlayer)
    CheckWin = 1
    For win = 0 To 7
        If (statePlayer And triple(win)) = triple(win) Then Exit Function
    Next win
    CheckWin = 0
End Function

Sub DrawSymbol (player, kval)
    cursor = CsrLin
    row = cursor - 2 - 2 * (kval \ 3)
    col = 4 + 4 * (kval Mod 3)
    Locate row, col
    If player = 0 Then Print "X" Else Print "O"
    Locate cursor, 1
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
    Print message$
    End
End Sub

Sub PlayAI
    score = -10
    mask = 1
    For move = 0 To 8
        If ((state(0) Or state(1)) And mask) = 0 Then
            eval = Evaluate(state(player) Or mask, state(1 - player), difficulty)
            If eval > score Then
                score = eval
                moves = mask
                n = bias(move)
            ElseIf eval = score Then
                moves = moves Or mask
                n = n + bias(move)
            End If
        End If
        mask = mask * 2
    Next move

    n = Int(Rnd * n)
    mask = 1
    For move = 0 To 8
        If (moves And mask) <> 0 Then
            If n < bias(move) Then
                state(player) = state(player) Or mask
                DrawSymbol player, move
                If CheckWin(state(player)) Then Finish "Computer Wins"
                If CheckDraw(state(0), state(1)) Then Finish "Drawn Game"
                player = 1 - player
                Exit For
            End If
            n = n - bias(move)
        End If
        mask = mask * 2
    Next move
End Sub

