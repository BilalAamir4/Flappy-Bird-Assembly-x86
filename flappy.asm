; ============================================================
; FLAPPY BIRD - Complete Game
; Features: 2 pipes, random gaps, speed increase, file leaderboard
; NASM flat binary .COM file
; Assemble: nasm flappy.asm -f bin -o flappy.com
; scores.dat must be in same folder (auto-created if missing)
; ============================================================

org 100h

; ============================================================
; CONSTANTS
; ============================================================
; scores.dat = 3 x (1 score byte + 21 name bytes) = 69 bytes
LB_SLOTS      equ 3
LB_SLOT_SIZE  equ 22        ; 1 score + 21 name bytes
LB_TOTAL      equ 66        ; 3 * 22

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

    ; Load leaderboard from file at startup
    call load_scores

    call clear_screen
    call name_input
    call main_menu

    ; Restore cursor and exit
    mov ah, 01h
    mov ch, 06h
    mov cl, 07h
    int 10h
    call clear_screen

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
; LOAD SCORES FROM scores.dat
; If file doesn't exist, leaderboard stays zeroed (default)
; ============================================================
load_scores:
    ; Open file for reading
    mov ah, 3Dh
    mov al, 0               ; read-only
    mov dx, filename
    int 21h
    jc  .file_not_found     ; carry set = file doesn't exist, skip

    mov [file_handle], ax   ; save handle

    ; Read LB_TOTAL bytes into lb_scores buffer
    mov ah, 3Fh
    mov bx, [file_handle]
    mov cx, LB_TOTAL
    mov dx, lb_scores
    int 21h

    ; Close file
    mov ah, 3Eh
    mov bx, [file_handle]
    int 21h

.file_not_found:
    ret

; ============================================================
; SAVE SCORES TO scores.dat
; Creates file if it doesn't exist, overwrites if it does
; ============================================================
save_scores:
    ; Create/overwrite file
    mov ah, 3Ch
    mov cx, 0               ; normal attributes
    mov dx, filename
    int 21h
    jc  .save_error         ; carry = disk full or write protected

    mov [file_handle], ax

    ; Write LB_TOTAL bytes from lb_scores
    mov ah, 40h
    mov bx, [file_handle]
    mov cx, LB_TOTAL
    mov dx, lb_scores
    int 21h

    ; Close file
    mov ah, 3Eh
    mov bx, [file_handle]
    int 21h

.save_error:
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
    call show_leaderboard
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
; DELAY — variable speed via delay_count
; ============================================================
delay_loop:
    push cx
    push bx
    mov bl, [delay_count]
.outer:
    cmp bl, 0
    je  .done_delay
    mov cx, 0FFFFh
.inner:
    loop .inner
    dec bl
    jmp .outer
.done_delay:
    pop bx
    pop cx
    ret

; ============================================================
; UPDATE SPEED — every 5 points reduce delay by 1 (min 1)
; ============================================================
update_speed:
    mov al, [score_hi]
    mov bl, 10
    mul bl
    add al, [score_lo]      ; AL = total score
    mov bl, 5
    div bl                  ; AL = score / 5
    mov bl, 5
    sub bl, al              ; bl = 5 - level
    cmp bl, 1
    jge .set_delay
    mov bl, 1
.set_delay:
    mov [delay_count], bl
    ret

; ============================================================
; RANDOMIZE PIPE — BX = pipe index
; ============================================================
randomize_pipe:
    push bx
    mov ah, 00h
    int 1Ah
    mov al, dl
    xor ah, ah
    pop bx
    add al, bl
    push bx
    mov bl, 14
    div bl
    add ah, 2
    pop bx
    mov [gap_top + bx], ah
    ret

; ============================================================
; DRAW HUD
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

    mov dh, 0
    mov dl, 35
    mov si, str_speed_lbl
    mov bl, 0Fh
    call print_str
    mov al, 6
    sub al, [delay_count]
    add al, '0'
    mov dh, 0
    mov dl, 42
    mov bl, 0Bh
    call print_char
    ret

; ============================================================
; ERASE / DRAW BIRD
; ============================================================
erase_bird:
    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, ' '
    mov bl, 17h
    call print_char
    ret

draw_bird:
    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, 0DBh
    mov bl, 0Eh
    call print_char
    ret

; ============================================================
; ERASE PIPE COLUMN — DL = column
; ============================================================
erase_pipe_col:
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

erase_pipes:
    mov dl, [old_pipe_x]
    call erase_pipe_col
    mov dl, [old_pipe_x + 1]
    call erase_pipe_col
    ret

; ============================================================
; DRAW ONE PIPE — DL=col, BX=pipe index
; ============================================================
draw_pipe_i:
    mov dh, 1
    mov cl, [gap_top + bx]
.top_loop:
    cmp dh, cl
    jge .skip_top
    mov al, 0B3h
    mov bl, 02h
    call print_char
    inc dh
    jmp .top_loop
.skip_top:
    mov cl, [gap_top + bx]
    add cl, [gap_size]
    mov dh, cl
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

draw_pipes:
    mov dl, [pipe_x]
    xor bx, bx
    call draw_pipe_i
    mov dl, [pipe_x + 1]
    mov bx, 1
    call draw_pipe_i
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
; CHECK COLLISION
; ============================================================
check_collision_i:
    mov al, [bird_y]
    cmp al, 23
    jge .hit
    mov al, [bird_x]
    cmp al, [pipe_x + bx]
    jne .no_hit
    mov al, [bird_y]
    mov cl, [gap_top + bx]
    cmp al, cl
    jl  .hit
    mov cl, [gap_top + bx]
    add cl, [gap_size]
    cmp al, cl
    jge .hit
.no_hit:
    mov al, 0
    ret
.hit:
    mov al, 1
    ret

check_collision:
    xor bx, bx
    call check_collision_i
    cmp al, 1
    je  .done
    mov bx, 1
    call check_collision_i
.done:
    ret

; ============================================================
; UPDATE SCORE
; ============================================================
update_score:
    mov al, [bird_x]
    mov cl, [pipe_x]
    inc cl
    cmp al, cl
    je  .give_point
    mov cl, [pipe_x + 1]
    inc cl
    cmp al, cl
    jne .no_score
.give_point:
    inc byte [score_lo]
    cmp byte [score_lo], 10
    jl  .no_score
    mov byte [score_lo], 0
    inc byte [score_hi]
    call update_speed
.no_score:
    ret

; ============================================================
; LOSE LIFE
; ============================================================
lose_life:
    dec byte [lives]
    cmp byte [lives], 0
    je  .truly_dead
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
    mov byte [bird_y], 10
    mov byte [velocity], 0
    mov byte [jumped], 0
    ret
.truly_dead:
    mov byte [game_state], 0
    ret

; ============================================================
; SAVE SCORE TO LEADERBOARD
; lb_scores layout: each slot = 1 score byte + 21 name bytes
;   slot 0: lb_scores+0  (score), lb_scores+1  (name, 21 bytes)
;   slot 1: lb_scores+22 (score), lb_scores+23 (name, 21 bytes)
;   slot 2: lb_scores+44 (score), lb_scores+45 (name, 21 bytes)
; ============================================================
save_score:
    ; Compute final score as single byte (hi*10 + lo)
    mov al, [score_hi]
    mov bl, 10
    mul bl
    add al, [score_lo]
    mov [cur_score_byte], al

    ; Compare against slot 0
    cmp al, [lb_scores]
    jg  .insert0

    ; Compare against slot 1
    cmp al, [lb_scores + 22]
    jg  .insert1

    ; Compare against slot 2
    cmp al, [lb_scores + 44]
    jg  .insert2

    ret                     ; didn't make top 3

.insert0:
    ; Shift slot 1 -> slot 2
    call shift_slot1_to_2
    ; Shift slot 0 -> slot 1
    call shift_slot0_to_1
    ; Write new entry into slot 0
    mov al, [cur_score_byte]
    mov [lb_scores], al
    call copy_username_to_slot0
    call save_scores
    ret

.insert1:
    ; Shift slot 1 -> slot 2
    call shift_slot1_to_2
    ; Write new entry into slot 1
    mov al, [cur_score_byte]
    mov [lb_scores + 22], al
    call copy_username_to_slot1
    call save_scores
    ret

.insert2:
    ; Write new entry into slot 2
    mov al, [cur_score_byte]
    mov [lb_scores + 44], al
    call copy_username_to_slot2
    call save_scores
    ret

; ---- Slot shift helpers ----
shift_slot1_to_2:
    ; Copy 22 bytes from slot1 to slot2
    push si
    push di
    push cx
    mov si, lb_scores + 22
    mov di, lb_scores + 44
    mov cx, 22
    rep movsb
    pop cx
    pop di
    pop si
    ret

shift_slot0_to_1:
    push si
    push di
    push cx
    mov si, lb_scores
    mov di, lb_scores + 22
    mov cx, 22
    rep movsb
    pop cx
    pop di
    pop si
    ret

copy_username_to_slot0:
    push si
    push di
    push cx
    mov si, username
    mov di, lb_scores + 1   ; name starts at byte 1 of slot
    mov cx, 21
    rep movsb
    pop cx
    pop di
    pop si
    ret

copy_username_to_slot1:
    push si
    push di
    push cx
    mov si, username
    mov di, lb_scores + 23
    mov cx, 21
    rep movsb
    pop cx
    pop di
    pop si
    ret

copy_username_to_slot2:
    push si
    push di
    push cx
    mov si, username
    mov di, lb_scores + 45
    mov cx, 21
    rep movsb
    pop cx
    pop di
    pop si
    ret

; ============================================================
; PRINT SCORE BYTE — AL=score value, DH=row, DL=col
; ============================================================
print_score_byte:
    push ax
    push dx
    xor ah, ah
    mov bl, 10
    div bl                  ; AL=tens, AH=units
    add al, '0'
    push ax
    mov bl, 0Eh
    call print_char
    inc dl
    pop ax
    mov al, ah
    add al, '0'
    mov bl, 0Eh
    call print_char
    pop dx
    pop ax
    ret

; ============================================================
; SHOW LEADERBOARD
; ============================================================
show_leaderboard:
    call clear_screen

    mov dh, 2
    mov dl, 26
    mov si, str_lb_title
    mov bl, 0Eh
    call print_str

    ; Divider
    mov dh, 4
    mov dl, 18
    mov si, str_lb_divider
    mov bl, 0Bh
    call print_str

    ; Column headers
    mov dh, 5
    mov dl, 18
    mov si, str_lb_header
    mov bl, 0Bh
    call print_str

    mov dh, 6
    mov dl, 18
    mov si, str_lb_divider
    mov bl, 0Bh
    call print_str

    ; --- Slot 0 ---
    mov dh, 8
    mov dl, 18
    mov si, str_rank1
    mov bl, 0Eh             ; gold
    call print_str

    mov dh, 8
    mov dl, 26
    mov si, lb_scores + 1   ; name for slot 0
    mov bl, 0Fh
    call print_str

    mov al, [lb_scores]     ; score for slot 0
    mov dh, 8
    mov dl, 52
    call print_score_byte

    ; --- Slot 1 ---
    mov dh, 10
    mov dl, 18
    mov si, str_rank2
    mov bl, 07h             ; silver
    call print_str

    mov dh, 10
    mov dl, 26
    mov si, lb_scores + 23
    mov bl, 0Fh
    call print_str

    mov al, [lb_scores + 22]
    mov dh, 10
    mov dl, 52
    call print_score_byte

    ; --- Slot 2 ---
    mov dh, 12
    mov dl, 18
    mov si, str_rank3
    mov bl, 06h             ; bronze
    call print_str

    mov dh, 12
    mov dl, 26
    mov si, lb_scores + 45
    mov bl, 0Fh
    call print_str

    mov al, [lb_scores + 44]
    mov dh, 12
    mov dl, 52
    call print_score_byte

    mov dh, 14
    mov dl, 18
    mov si, str_lb_divider
    mov bl, 0Bh
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

    ; Show if new record
    mov al, [cur_score_byte]
    cmp al, 0
    je  .no_record
    cmp al, [lb_scores + 44]
    jl  .no_record

    mov dh, 12
    mov dl, 23
    mov si, str_new_record
    mov bl, 0Eh
    call print_str

.no_record:
    mov dh, 16
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
    mov byte [pipe_x],       79
    mov byte [pipe_x + 1],   39
    mov byte [old_pipe_x],     79
    mov byte [old_pipe_x + 1], 39
    mov byte [gap_size], 6
    mov byte [lives], 3
    mov byte [score_hi], 0
    mov byte [score_lo], 0
    mov byte [cur_score_byte], 0
    mov byte [jumped], 0
    mov byte [game_state], 1
    mov byte [delay_count], 5
    xor bx, bx
    call randomize_pipe
    mov bx, 1
    call randomize_pipe
    ret

; ============================================================
; MAIN GAME LOOP
; ============================================================
game:
    call init_game
    call clear_screen
    call draw_ground

.game_loop:
    call erase_bird
    call erase_pipes

    ; --- INPUT ---
    mov byte [jumped], 0
    mov ah, 01h
    int 16h
    jz  .no_key
    mov ah, 00h
    int 16h
    cmp al, 1Bh
    je  .quit_game
    cmp al, 20h
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
    ; --- MOVE PIPES ---
    mov al, [pipe_x]
    mov [old_pipe_x], al
    mov al, [pipe_x + 1]
    mov [old_pipe_x + 1], al

    cmp byte [pipe_x], 0
    je  .reset_pipe0
    dec byte [pipe_x]
    jmp .move_pipe1
.reset_pipe0:
    mov byte [pipe_x], 79
    mov byte [old_pipe_x], 79
    xor bx, bx
    call randomize_pipe

.move_pipe1:
    cmp byte [pipe_x + 1], 0
    je  .reset_pipe1
    dec byte [pipe_x + 1]
    jmp .do_collision
.reset_pipe1:
    mov byte [pipe_x + 1], 79
    mov byte [old_pipe_x + 1], 79
    mov bx, 1
    call randomize_pipe

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
    call draw_pipes
    call draw_bird
    call draw_hud
    call delay_loop
    cmp byte [game_state], 1
    je  .game_loop

.game_over:
    call save_score         ; update leaderboard + write to file
    call game_over_screen
    ret

.quit_game:
    call save_score
    call clear_screen
    ret

; ============================================================
; DATA
; ============================================================

title_l1   db ' _____ _     _   _ _____ ______   __    ____ ___ ____  ____   $'
title_l2   db '|  ___| |   / \ | |  _ \|  _ \ \ / /   | __ )_ _|  _ \|  _ \  $'
title_l3   db '| |_  | |  / _ \| | |_) | |_) \ V /    |  _ \| || |_) | | | | $'
title_l4   db '|  _| | |_/ ___ \ |  __/|  __/ | |     | |_) | ||  _ <| |_| | $'
title_l5   db '|_|   |_/_/   \_\_|_|   |_|    |_|     |____/___|_| \_\____/  $'
title_line db '=============================================================$'

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
str_speed_lbl  db 'Speed: $'
str_gameover   db '*** GAME OVER ***$'
str_finalscore db 'Your Score: $'
str_new_record db '*** NEW LEADERBOARD ENTRY! ***$'
str_thanks     db 'Thanks for playing Flappy Bird!$'
str_lb_title   db '=== LEADERBOARD - TOP 3 ===$'
str_lb_header  db 'Rank   Name                    Score$'
str_lb_divider db '=====================================$'
str_rank1      db '#1  $'
str_rank2      db '#2  $'
str_rank3      db '#3  $'

help_l1    db 'SPACE        = Flap the bird upward$'
help_l2    db 'Gravity      = Pulls the bird down constantly$'
help_l3    db 'Avoid pipes  = Fly through the gaps$'
help_l4    db 'Avoid walls  = Dont hit the bottom wall$'
help_l5    db 'Score        = +1 for every pipe passed$'

; File I/O
filename      db 'SCORES.DAT', 0
file_handle   dw 0

; Game variables
bird_y        db 10
bird_x        db 10
velocity      db 0
jumped        db 0
pipe_x        db 79, 39
old_pipe_x    db 79, 39
gap_top       db 8, 8
gap_size      db 6
lives         db 3
score_hi      db 0
score_lo      db 0
cur_score_byte db 0
game_state    db 1
delay_count   db 5

; Leaderboard buffer — 3 slots x 22 bytes = 66 bytes
; Each slot: [score_byte][name 21 bytes]
lb_scores     times 66 db 0

; Menu variables
selected      db 1
name_len      db 0
username      times 22 db '$'