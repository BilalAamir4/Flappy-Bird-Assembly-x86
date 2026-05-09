include emu8086.inc

.model small
.stack 100h
.data

username    db 30 dup(?)
counter     db 0

stroption1  db "Start Game$"
stroption2  db "Leaderboard$"
stroption3  db "Help$"
stroption4  db "Quit$"
strwelcome  db "Welcome To Flappy Bird$"

.code

include menu.inc        ; clear_screen, printColored, printMenu, highlightSelection, NameInput


;----------------------------------
; GAME PROC - Placeholder
;----------------------------------
Game PROC
    mov ah, 0
    int 16h
    ret
Game ENDP


;----------------------------------
; LEADERBOARD PROC - Placeholder
;----------------------------------
Leaderboard PROC
    call clear_screen
    gotoxy 30, 12
    Print "Leaderboard - Coming Soon!"
    mov ah, 0
    int 16h
    ret
Leaderboard ENDP


;----------------------------------
; HELP PROC
;----------------------------------
Help PROC
    call clear_screen

    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 28
    int 10h
    Print "--- How To Play ---"

    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 25
    int 10h
    Print "Press SPACE to make the bird fly up"

    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 25
    int 10h
    Print "Gravity pulls the bird down"

    mov ah, 02h
    mov bh, 0
    mov dh, 9
    mov dl, 25
    int 10h
    Print "Avoid hitting the pipes"

    mov ah, 02h
    mov bh, 0
    mov dh, 11
    mov dl, 25
    int 10h
    Print "Avoid hitting the top and bottom walls"

    mov ah, 02h
    mov bh, 0
    mov dh, 13
    mov dl, 25
    int 10h
    Print "Each pipe you pass = +1 Score"

    mov ah, 02h
    mov bh, 0
    mov dh, 15
    mov dl, 25
    int 10h
    Print "How long can you survive?"

    mov ah, 02h
    mov bh, 0
    mov dh, 20
    mov dl, 25
    int 10h
    Print "Press any key to go back..."

    mov ah, 0
    int 16h
    ret
Help ENDP


;----------------------------------
; MAINMENU PROC
;----------------------------------
MainMenu PROC

    mov counter, 1

    mov ah, 01h
    mov ch, 32
    mov cl, 0
    int 10h

MenuLoop:
    call clear_screen

    mov ah, 02h
    mov bh, 0
    mov dh, 2
    mov dl, 27
    int 10h
    lea dx, strwelcome
    mov ah, 09h
    int 21h

    call printMenu
    call highlightSelection

GetInput:
    MOV AH, 00h
    INT 16h

    CMP ah, 72
    JE  MenuUp

    CMP ah, 80
    JE  MenuDown

    CMP al, 13
    JE  CheckOpt

    jmp GetInput

MenuUp:
    CMP counter, 1
    JE  GetInput
    DEC counter
    jmp MenuLoop

MenuDown:
    CMP counter, 4
    JE  GetInput
    INC counter
    jmp MenuLoop

CheckOpt:
    CMP counter, 1
    JE  DoGame

    CMP counter, 2
    JE  DoLeaderboard

    CMP counter, 3
    JE  DoHelp

    JMP DoQuit

DoGame:
    call Game
    jmp MenuLoop

DoLeaderboard:
    call Leaderboard
    jmp MenuLoop

DoHelp:
    call Help
    jmp MenuLoop

DoQuit:
    ret

MainMenu ENDP


;----------------------------------
; MAIN - Entry point
;----------------------------------
main:
    mov ax, @data
    mov ds, ax

    call clear_screen
    gotoxy 27, 2
    Print "Welcome To Flappy Bird"

    call NameInput          ; defined in menu.inc
    call MainMenu           ; defined above

    call clear_screen
    gotoxy 28, 12
    Print "Thanks For Playing!"

    mov ah, 4ch
    int 21h

end main
