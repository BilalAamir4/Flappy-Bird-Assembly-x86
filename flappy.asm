; ============================================================
; FLAPPY BIRD - Complete Game
; NASM flat binary .COM file
; Assemble: nasm flappy.asm -f bin -o flappy.com
; ============================================================

org 100h

; ============================================================
; ENTRY POINT
; ============================================================
start:
    mov ax, cs
    mov ds, ax
    mov es, ax

    ; Hide cursor
    mov ah, 01h
    mov ch, 32
    mov cl, 0
    int 10h

    call clear_screen
    call name_input
    call main_menu

    ; Restore cursor and exit
    mov ah, 01h
    mov ch, 06h
    mov cl, 07h
    int 10h
    call clear_screen

    ; Goodbye message
    mov dh, 12
    mov dl, 28
    mov si, str_thanks
    mov bl, 0Eh
    call print_str

    mov ah, 4ch
    int 21h

; ============================================================
; CLEAR SCREEN
; ============================================================
clear_screen:
    mov ah, 06h
    mov al, 0
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov bh, 17h
    int 10h
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 10h
    ret

; ============================================================
; GOTOXY — DH=row, DL=col
; ============================================================
gotoxy:
    mov ah, 02h
    mov bh, 0
    int 10h
    ret

; ============================================================
; PRINT_STR — SI=string, BL=color, DH=row, DL=col
; ============================================================
print_str:
    call gotoxy
.loop:
    mov al, [si]
    cmp al, '$'
    je  .done
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    inc si
    inc dl
    call gotoxy
    jmp .loop
.done:
    ret

; ============================================================
; PRINT_CHAR — AL=char, BL=color, DH=row, DL=col
; ============================================================
print_char:
    call gotoxy
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    ret

; ============================================================
; DRAW TITLE
; ============================================================
draw_title:
    mov bl, 0Eh
    mov dh, 1
    mov dl, 4
    mov si, title_l1
    call print_str
    mov dh, 2
    mov dl, 4
    mov si, title_l2
    call print_str
    mov dh, 3
    mov dl, 4
    mov si, title_l3
    call print_str
    mov dh, 4
    mov dl, 4
    mov si, title_l4
    call print_str
    mov dh, 5
    mov dl, 4
    mov si, title_l5
    call print_str
    mov dh, 6
    mov dl, 4
    mov si, title_line
    mov bl, 0Bh
    call print_str
    ret

; ============================================================
; DRAW MENU OPTIONS
; ============================================================
draw_menu:
    call clear_screen
    call draw_title

    mov dh, 9
    mov dl, 30
    mov si, opt1
    cmp byte [selected], 1
    je  .hi1
    mov bl, 0Fh
    call print_str
    jmp .opt2
.hi1:
    mov bl, 0Ah
    call print_str
    mov dh, 9
    mov dl, 28
    mov al, 10h
    mov bl, 0Eh
    call print_char

.opt2:
    mov dh, 11
    mov dl, 30
    mov si, opt2
    cmp byte [selected], 2
    je  .hi2
    mov bl, 0Fh
    call print_str
    jmp .opt3
.hi2:
    mov bl, 0Ah
    call print_str
    mov dh, 11
    mov dl, 28
    mov al, 10h
    mov bl, 0Eh
    call print_char

.opt3:
    mov dh, 13
    mov dl, 30
    mov si, opt3
    cmp byte [selected], 3
    je  .hi3
    mov bl, 0Fh
    call print_str
    jmp .opt4
.hi3:
    mov bl, 0Ah
    call print_str
    mov dh, 13
    mov dl, 28
    mov al, 10h
    mov bl, 0Eh
    call print_char

.opt4:
    mov dh, 15
    mov dl, 30
    mov si, opt4
    cmp byte [selected], 4
    je  .hi4
    mov bl, 0Fh
    call print_str
    jmp .done_opts
.hi4:
    mov bl, 0Ah
    call print_str
    mov dh, 15
    mov dl, 28
    mov al, 10h
    mov bl, 0Eh
    call print_char

.done_opts:
    mov dh, 20
    mov dl, 28
    mov si, str_hello
    mov bl, 0Bh
    call print_str
    mov dh, 20
    mov dl, 35
    mov si, username
    mov bl, 0Eh
    call print_str
    mov dh, 22
    mov dl, 22
    mov si, str_hint
    mov bl, 08h
    call print_str
    ret

; ============================================================
; MAIN MENU LOOP
; ============================================================
main_menu:
    mov byte [selected], 1

.menu_loop:
    call draw_menu

.get_key:
    mov ah, 00h
    int 16h
    cmp ah, 48h
    je  .go_up
    cmp ah, 50h
    je  .go_down
    cmp al, 13
    je  .select
    jmp .get_key

.go_up:
    cmp byte [selected], 1
    je  .menu_loop
    dec byte [selected]
    jmp .menu_loop

.go_down:
    cmp byte [selected], 4
    je  .menu_loop
    inc byte [selected]
    jmp .menu_loop

.select:
    cmp byte [selected], 1
    je  .do_game
    cmp byte [selected], 2
    je  .do_leaderboard
    cmp byte [selected], 3
    je  .do_help
    jmp .do_quit

.do_game:
    call game
    jmp .menu_loop

.do_leaderboard:
    call placeholder_leaderboard
    jmp .menu_loop

.do_help:
    call help_screen
    jmp .menu_loop

.do_quit:
    ret

; ============================================================
; NAME INPUT
; ============================================================
name_input:
    call clear_screen
    call draw_title
    mov dh, 9
    mov dl, 22
    mov si, str_entername
    mov bl, 0Fh
    call print_str
    mov dh, 11
    mov dl, 22
    mov si, str_inputbox
    mov bl, 0Bh
    call print_str
    mov dh, 11
    mov dl, 24
    call gotoxy
    mov ah, 01h
    mov ch, 06h
    mov cl, 07h
    int 10h
    mov si, 0
    mov byte [name_len], 0

.input_loop:
    mov ah, 00h
    int 16h
    cmp al, 13
    je  .input_done
    cmp ah, 0Eh
    je  .backspace
    cmp byte [name_len], 20
    jge .input_loop
    mov [username + si], al
    inc si
    inc byte [name_len]
    mov ah, 0Eh
    int 10h
    jmp .input_loop

.backspace:
    cmp byte [name_len], 0
    je  .input_loop
    dec si
    dec byte [name_len]
    mov byte [username + si], '$'
    mov ah, 0Eh
    mov al, 8
    int 10h
    mov ah, 0Eh
    mov al, ' '
    int 10h
    mov ah, 0Eh
    mov al, 8
    int 10h
    jmp .input_loop

.input_done:
    mov byte [username + si], '$'
    mov ah, 01h
    mov ch, 32
    mov cl, 0
    int 10h
    ret

; ============================================================
; HELP SCREEN
; ============================================================
help_screen:
    call clear_screen
    mov dh, 2
    mov dl, 28
    mov si, str_help_title
    mov bl, 0Eh
    call print_str
    mov dh, 5
    mov dl, 20
    mov si, help_l1
    mov bl, 0Fh
    call print_str
    mov dh, 7
    mov dl, 20
    mov si, help_l2
    mov bl, 0Fh
    call print_str
    mov dh, 9
    mov dl, 20
    mov si, help_l3
    mov bl, 0Fh
    call print_str
    mov dh, 11
    mov dl, 20
    mov si, help_l4
    mov bl, 0Fh
    call print_str
    mov dh, 13
    mov dl, 20
    mov si, help_l5
    mov bl, 0Fh
    call print_str
    mov dh, 18
    mov dl, 22
    mov si, str_presskey
    mov bl, 08h
    call print_str
    mov ah, 00h
    int 16h
    ret

; ============================================================
; PLACEHOLDER LEADERBOARD
; ============================================================
placeholder_leaderboard:
    call clear_screen
    mov dh, 12
    mov dl, 22
    mov si, str_coming_lb
    mov bl, 0Bh
    call print_str
    mov ah, 00h
    int 16h
    ret

; ============================================================
; DELAY — CPU loop for speed control
; ============================================================
delay_loop:
    push cx
    mov cx, 0FFFFh
.inner:
    loop .inner
    pop cx
    ret

; ============================================================
; DRAW HUD — Score and Lives on row 0
; ============================================================
draw_hud:
    mov dh, 0
    mov dl, 1
    mov si, str_score_lbl
    mov bl, 0Fh
    call print_str

    mov al, [score_hi]
    add al, '0'
    mov dh, 0
    mov dl, 8
    mov bl, 0Eh
    call print_char

    mov al, [score_lo]
    add al, '0'
    mov dh, 0
    mov dl, 9
    mov bl, 0Eh
    call print_char

    mov dh, 0
    mov dl, 60
    mov si, str_lives_lbl
    mov bl, 0Fh
    call print_str

    mov al, [lives]
    add al, '0'
    mov dh, 0
    mov dl, 67
    mov bl, 0Ch
    call print_char
    ret

; ============================================================
; ERASE BIRD
; ============================================================
erase_bird:
    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, ' '
    mov bl, 17h
    call print_char
    ret

; ============================================================
; DRAW BIRD
; ============================================================
draw_bird:
    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, 0DBh
    mov bl, 0Eh
    call print_char
    ret

; ============================================================
; ERASE PIPE COLUMN
; ============================================================
erase_pipe:
    mov dl, [old_pipe_x]
    mov dh, 1
.erase_loop:
    cmp dh, 23
    jge .erase_done
    mov al, ' '
    mov bl, 17h
    call print_char
    inc dh
    jmp .erase_loop
.erase_done:
    ret

; ============================================================
; DRAW PIPE
; ============================================================
draw_pipe:
    mov dl, [pipe_x]

    ; Top block: rows 1 to gap_top-1
    mov dh, 1
.top_loop:
    mov al, [gap_top]
    cmp dh, al
    jge .skip_top
    mov al, 0B3h
    mov bl, 02h
    call print_char
    inc dh
    jmp .top_loop

.skip_top:
    ; Bottom block: rows gap_top+gap_size to 22
    mov al, [gap_top]
    add al, [gap_size]
    mov dh, al

.bot_loop:
    cmp dh, 23
    jge .pipe_done
    mov al, 0B3h
    mov bl, 02h
    call print_char
    inc dh
    jmp .bot_loop

.pipe_done:
    ret

; ============================================================
; DRAW GROUND
; ============================================================
draw_ground:
    mov dh, 23
    mov dl, 0
.gloop:
    cmp dl, 80
    jge .gdone
    mov al, '-'
    mov bl, 06h
    call print_char
    inc dl
    jmp .gloop
.gdone:
    ret

; ============================================================
; CHECK COLLISION — AL=1 hit, AL=0 safe
; ============================================================
check_collision:
    ; Bottom wall
    mov al, [bird_y]
    cmp al, 23
    jge .hit

    ; Pipe x overlap?
    mov al, [bird_x]
    cmp al, [pipe_x]
    jne .no_hit

    ; Is bird inside the gap?
    mov al, [bird_y]
    mov cl, [gap_top]
    cmp al, cl
    jl  .hit                ; above gap = top pipe hit

    mov cl, [gap_top]
    add cl, [gap_size]
    cmp al, cl
    jge .hit                ; below gap = bottom pipe hit

.no_hit:
    mov al, 0
    ret
.hit:
    mov al, 1
    ret

; ============================================================
; UPDATE SCORE
; ============================================================
update_score:
    mov al, [bird_x]
    mov cl, [pipe_x]
    inc cl
    cmp al, cl
    jne .no_score
    inc byte [score_lo]
    cmp byte [score_lo], 10
    jl  .no_score
    mov byte [score_lo], 0
    inc byte [score_hi]
.no_score:
    ret

; ============================================================
; LOSE LIFE — flash red, reset bird or trigger game over
; ============================================================
lose_life:
    dec byte [lives]
    cmp byte [lives], 0
    je  .truly_dead

    ; Red flash
    mov cx, 3
.flash_loop:
    push cx
    mov ah, 06h
    mov al, 0
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov bh, 4Fh
    int 10h
    call delay_loop
    call delay_loop
    mov ah, 06h
    mov al, 0
    mov ch, 0
    mov cl, 0
    mov dh, 24
    mov dl, 79
    mov bh, 17h
    int 10h
    call delay_loop
    pop cx
    loop .flash_loop

    ; Reset bird only
    mov byte [bird_y], 10
    mov byte [velocity], 0
    mov byte [jumped], 0
    ret

.truly_dead:
    mov byte [game_state], 0
    ret

; ============================================================
; GAME OVER SCREEN
; ============================================================
game_over_screen:
    call clear_screen
    mov dh, 8
    mov dl, 30
    mov si, str_gameover
    mov bl, 0Ch
    call print_str

    mov dh, 10
    mov dl, 28
    mov si, str_finalscore
    mov bl, 0Fh
    call print_str

    mov al, [score_hi]
    add al, '0'
    mov dh, 10
    mov dl, 41
    mov bl, 0Eh
    call print_char

    mov al, [score_lo]
    add al, '0'
    mov dh, 10
    mov dl, 42
    mov bl, 0Eh
    call print_char

    mov dh, 14
    mov dl, 24
    mov si, str_presskey
    mov bl, 08h
    call print_str

    mov ah, 00h
    int 16h
    ret

; ============================================================
; INIT GAME
; ============================================================
init_game:
    mov byte [bird_y], 10
    mov byte [bird_x], 10
    mov byte [velocity], 0
    mov byte [pipe_x], 79
    mov byte [old_pipe_x], 79
    mov byte [gap_top], 8
    mov byte [gap_size], 6
    mov byte [lives], 3
    mov byte [score_hi], 0
    mov byte [score_lo], 0
    mov byte [jumped], 0
    mov byte [game_state], 1
    ret

; ============================================================
; MAIN GAME LOOP
; ============================================================
game:
    call init_game
    call clear_screen
    call draw_ground

.game_loop:
    ; Erase old positions
    call erase_bird
    call erase_pipe

    ; --- INPUT (non-blocking) ---
    mov byte [jumped], 0
    mov ah, 01h
    int 16h
    jz  .no_key

    mov ah, 00h
    int 16h

    cmp al, 1Bh             ; ESC = back to menu
    je  .quit_game

    cmp al, 20h             ; SPACE = flap
    jne .no_key
    cmp byte [bird_y], 2
    jle .no_key
    dec byte [bird_y]
    dec byte [bird_y]
    mov byte [jumped], 1

.no_key:
    ; --- GRAVITY ---
    cmp byte [jumped], 1
    je  .skip_gravity
    inc byte [bird_y]

.skip_gravity:
    ; --- MOVE PIPE ---
    mov al, [pipe_x]
    mov [old_pipe_x], al
    cmp byte [pipe_x], 0
    je  .reset_pipe
    dec byte [pipe_x]
    jmp .do_collision

.reset_pipe:
    mov byte [pipe_x], 79
    mov byte [old_pipe_x], 79

.do_collision:
    call check_collision
    cmp al, 1
    jne .no_collision

    call lose_life
    cmp byte [game_state], 0
    je  .game_over
    call clear_screen
    call draw_ground
    jmp .draw_frame

.no_collision:
    call update_score

.draw_frame:
    call draw_pipe
    call draw_bird
    call draw_hud
    call delay_loop

    cmp byte [game_state], 1
    je  .game_loop

.game_over:
    call game_over_screen
    ret

.quit_game:
    call clear_screen
    ret

; ============================================================
; DATA
; ============================================================

title_l1   db ' _____ _       _   ___ ____  _   _     ____ ___ ____  ____  $'
title_l2   db '|  ___| |     / \ | _ \_ _|| | | |   | __ )_ _|  _ \|  _ \ $'
title_l3   db '| |_  | |    / _ \|  _/| | | |_| |   |  _ \| || |_) | | | |$'
title_l4   db '|  _| | |___/ ___ \ |  | | |  _  |   | |_) | ||  _ <| |_| |$'
title_l5   db '|_|   |_____/_/  \_\_| |___||_| |_|   |____/___|_| \_\____/ $'
title_line db '===============================================================$'

opt1       db '1. Start Game$'
opt2       db '2. Leaderboard$'
opt3       db '3. Help$'
opt4       db '4. Quit$'

str_entername  db 'Enter your name (max 20 chars):$'
str_inputbox   db '[                    ]$'
str_hello      db 'Player: $'
str_hint       db 'Use UP/DOWN arrows + ENTER to select$'
str_presskey   db 'Press any key to continue...$'
str_help_title db '--- HOW TO PLAY ---$'
str_score_lbl  db 'Score: $'
str_lives_lbl  db 'Lives: $'
str_gameover   db '*** GAME OVER ***$'
str_finalscore db 'Your Score: $'
str_coming_lb  db 'Leaderboard - Coming Soon! (Press any key)$'
str_thanks     db 'Thanks for playing Flappy Bird!$'

help_l1    db 'SPACE        = Flap the bird upward$'
help_l2    db 'Gravity      = Pulls the bird down constantly$'
help_l3    db 'Avoid pipes  = Fly through the gaps$'
help_l4    db 'Avoid walls  = Dont hit the bottom wall$'
help_l5    db 'Score        = +1 for every pipe passed$'

; Game variables
bird_y      db 10
bird_x      db 10
velocity    db 0
jumped      db 0
pipe_x      db 79
old_pipe_x  db 79
gap_top     db 8
gap_size    db 6
lives       db 3
score_hi    db 0
score_lo    db 0
game_state  db 1

; Menu variables
selected    db 1
name_len    db 0
username    times 22 db '$'
