include emu8086.inc
include menu.inc

.model small
.stack 100h

.data
    counter db 1
    stroption1 db "Start Game$" 
    stroption2 db "Leaderboard$"
    stroption3 db "Help$"
    stroption4 db "Quit$" 

.code

main:
    mov ax, @data
    mov ds, ax

    ; Clear screen
    mov ah, 06h
    mov al, 0
    mov cx, 0
    mov dh, 24
    mov dl, 79
    mov bh, 07h
    int 10h

    call mainMenu

programEnd:
    mov ah, 4ch
    int 21h

end main