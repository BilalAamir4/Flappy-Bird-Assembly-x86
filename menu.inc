;----------------------------------
; CLEAR_SCREEN PROC
;----------------------------------
clear_screen PROC
    mov ah, 06h
    mov al, 0
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov bh, 07h
    int 10h

    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h

    ret
clear_screen ENDP


;----------------------------------
; PRINTCOLORED PROC
;----------------------------------
printColored PROC

colorLoop:
    MOV AL, [SI]
    CMP AL, '$'
    JE  doneColored

    MOV AH, 09h
    MOV BH, 0
    mov cx, 1
    INT 10h

    INC SI
    INC DL
    MOV AH, 02h
    MOV BH, 0
    INT 10h

    JMP colorLoop

doneColored:
    RET

printColored ENDP


;----------------------------------
; PRINTMENU PROC
;----------------------------------
printMenu PROC

    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 31
    int 10h
    lea dx, stroption1
    mov ah, 09h
    int 21h

    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 30
    int 10h
    lea dx, stroption2
    mov ah, 09h
    int 21h

    mov ah, 02h
    mov bh, 0
    mov dh, 9
    mov dl, 33
    int 10h
    lea dx, stroption3
    mov ah, 09h
    int 21h

    mov ah, 02h
    mov bh, 0
    mov dh, 11
    mov dl, 33
    int 10h
    lea dx, stroption4
    mov ah, 09h
    int 21h

    ret

printMenu ENDP


;----------------------------------
; HIGHLIGHTSELECTION PROC
;----------------------------------
highlightSelection PROC

    CMP counter, 1
    JE  Highlight1

    CMP counter, 2
    JE  Highlight2

    CMP counter, 3
    JE  Highlight3

    JMP Highlight4

Highlight1:
    mov ah, 02h
    mov bh, 0
    mov dh, 5
    mov dl, 31
    int 10h
    LEA SI, stroption1
    mov bl, 0Bh
    call printColored
    ret

Highlight2:
    mov ah, 02h
    mov bh, 0
    mov dh, 7
    mov dl, 30
    int 10h
    LEA SI, stroption2
    mov bl, 0Bh
    call printColored
    ret

Highlight3:
    mov ah, 02h
    mov bh, 0
    mov dh, 9
    mov dl, 33
    int 10h
    LEA SI, stroption3
    mov bl, 0Bh
    call printColored
    ret

Highlight4:
    mov ah, 02h
    mov bh, 0
    mov dh, 11
    mov dl, 33
    int 10h
    LEA SI, stroption4
    mov bl, 0Bh
    call printColored
    ret

highlightSelection ENDP


;----------------------------------
; NAMEINPUT PROC
;----------------------------------
NameInput PROC

    mov counter, 0
    mov si, 0

    gotoxy 25, 5
    Print "Enter Your Name : "

inputt:
    mov ah, 0
    int 16h

    cmp al, 13
    je  Done

    cmp ah, 14
    je  BackSp

    mov username[si], al
    inc si
    inc counter

    mov ah, 02h
    mov dl, al
    int 21h

    jmp inputt

BackSp:
    cmp counter, 0
    je  inputt

    dec si
    dec counter
    mov username[si], 0

    putc 8
    putc 32
    putc 8

    jmp inputt

Done:
    mov username[si], '$'
    RET

NameInput ENDP
