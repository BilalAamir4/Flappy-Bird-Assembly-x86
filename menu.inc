printColored PROC
    MOV AH, 02h
    MOV BH, 0
    INT 10h          
colorLoop:
    MOV AL, [SI]
    CMP AL, '$'
    JE doneColored
    MOV AH, 09h
    MOV BH, 0
    MOV CX, 1
    INT 10h          
    INC DL
    MOV AH, 02h
    MOV BH, 0
    INT 10h          
    INC SI
    JMP colorLoop
doneColored:
    RET
printColored ENDP


mainMenu PROC
    ; Print Title
    mov dh,2        
    mov dl,27       
    mov ah,02h      
    mov bh,0        
    int 10h         
    Print "Welcome To Flappy Bird"   

    ; Print all options in white initially
    mov dh,5
    mov dl,31
    LEA SI, stroption1
    mov bl, 07h
    call printColored
    mov dh,7
    mov dl,30
    LEA SI, stroption2
    mov bl, 07h
    call printColored
    mov dh,9
    mov dl,33
    LEA SI, stroption3
    mov bl, 07h
    call printColored
    mov dh,11
    mov dl,33
    LEA SI, stroption4
    mov bl, 07h
    call printColored 

    ; Hide The Cursor
    mov ah,01h
    mov ch,32
    mov cl,0
    int 10h 

UpdateColor: 
    ; Reprint all in white
    mov dh,5
    mov dl,31
    LEA SI, stroption1
    mov bl, 07h
    call printColored
    mov dh,7
    mov dl,30
    LEA SI, stroption2
    mov bl, 07h
    call printColored
    mov dh,9
    mov dl,33
    LEA SI, stroption3
    mov bl, 07h
    call printColored
    mov dh,11
    mov dl,33
    LEA SI, stroption4
    mov bl, 07h
    call printColored

    CMP counter,1
    JE Option1
    CMP counter,2
    JE Option2
    CMP counter,3
    JE Option3

Option4:
    mov dh,11          
    mov dl,33          
    LEA SI, stroption4  
    mov bl, 0Bh        
    call printColored
    jmp menuInput

Option3: 
    mov dh,9           
    mov dl,33          
    LEA SI, stroption3  
    mov bl, 0Bh        
    call printColored
    jmp menuInput

Option2:
    mov dh,7            
    mov dl,30           
    LEA SI, stroption2  
    mov bl, 0Bh        
    call printColored
    jmp menuInput

Option1:
    mov dh,5            
    mov dl,31           
    LEA SI, stroption1  
    mov bl, 0Bh        
    call printColored

menuInput:
    MOV AH, 00h
    INT 16h 
    CMP ah, 72      ; Up
    JE MenuUp
    CMP ah, 80      ; Down
    JE MenuDown
    CMP ah, 1Ch     ; Enter
    JE MenuSelect
    jmp menuInput

MenuUp:
    CMP counter,1   
    JE menuInput
    DEC counter     
    jmp UpdateColor 

MenuDown:
    CMP counter,4   
    JE menuInput
    INC counter     
    jmp UpdateColor

MenuSelect:
    CMP counter,1
    JE startGame
    CMP counter,2
    JE leaderboard
    CMP counter,3
    JE helpScreen
    ; counter = 4, Quit
    jmp programEnd

startGame:
    call game        ; will be in game.inc later
    ret

leaderboard:
    call showLeaderboard   ; will be in leaderboard.inc later
    ret

helpScreen:
    call showHelp          ; will be in help.inc later
    ret

mainMenu ENDP