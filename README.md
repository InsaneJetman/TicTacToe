# Tic-Tac-Toe

Here is a set of simple tic-tac-toe games implemented in BASIC:

## Console Game

This version of the game has a simple text-based interface for console use.

__Syntax__: `TTT [search depth]`

`[search depth]` determines the difficulty:

0. all moves are random
1. will win if a winning move is available
2. wil block a player threatening to win on the next move
3. will make a double threat if possible
4. will try to prevent a double threat from being made on the next move
5. optimal offence, will force a win whenever possible
6. fully optimal play, cannot be beaten (default if not specified)

__Controls__:
* `1-9`: play in the corresponding square (numeric keypad layout)
* `Enter`: swap sides, the computer plays now
* `Backspace`: the computer will not play after your next move
* `Escape`: exit the game

__Notes__:

* This version is compatible with both QuickBASIC and FreeBASIC, so binaries are included in both the 16 and 32-bit packages.
* A windows shortcut is also provided in the 32-bit package which sets the difficulty and prevents the console window from closing immediatly after the game.
  Edit this shortcut to change the difficulty, and change the _Start in_ folder if the shortcut is copied to a different location than the executable.

## VGA Game

This version of the game provides a graphical interface using VGA graphics.
The game is drawn over a blue brick background.
It operates in 640x480 mode with 16 colours (11 used).

Syntax: `TTTVGA [search depth]`

Aside from the graphical interface, this game works exactly like the console game.

__Notes__:

* This version is compatible with QuickBASIC but not FreeBASIC, so a binary is only included in the 16-bit package.
* A 32 or 64-bit binary for Windows can be compiled using [QB64](https://www.portal.qb64.org/).

## Windowed Game

This version of the game runs in a window with full 32-bit graphics.
It features mouse support, button controls, and live difficulty adjutment.

Syntax: `TicTacToe [search depth]`

`[search depth]` see console game; specifies initial value; default is 2

__Interface__:

* Depth: adjust the search depth (difficulty)
* Wait: when active, the computer will not play
* Play: swap sides, the computer plays now

After a game, hit _Play_ or click anywhere in the play area to start a new game.

__Keyboard Controls__:

* `1-9`: play in the corresponding square (numeric keypad layout)
* `+/-`: increase/decrease the search depth (difficulty)
* `Enter`: swap sides, the computer plays now
* `Backspace`: toggle the _Wait_ (computer does not play) state
* `Escape` or `Alt+F4`: exit the game

__Notes__:

* This version is written specifically in FreeBASIC, so a binary is only included in the 32-bit package.
* The graphics file (`TicTacToe.bmp`) must be present alongside the executable.
* 'Backspace` works a little differently here, the wait state does not reset after you play.

--------------------------------------------------------------------------------

| Links            | URL                                                         |
| ---------------- | ----------------------------------------------------------- |
| Project Homepage | https://github.com/InsaneJetman/tic-tac-toe                 |
| Downloads        | https://github.com/InsaneJetman/tic-tac-toe/releases/latest |
