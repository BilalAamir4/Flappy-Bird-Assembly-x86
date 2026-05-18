; ============================================================
; FLAPPY BIRD - Complete Game
; Features: 2 pipes, random gaps, speed increase, file leaderboard, star boost
; NASM flat binary .COM file
; Assemble: nasm flappy.asm -f bin -o flappy.com
; scores.dat must be in same folder (auto-created if missing)
; ============================================================

org 100h

; ============================================================
; CONSTANTS
; ============================================================
; scores.dat = 3 x (1 score byte + 21 name bytes) = 66 bytes
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
    mov bh, 3Fh
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
    push cx             ; <--- SHIELD CX BEFORE MODIFYING
    call gotoxy
    mov ah, 09h
    mov bh, 0
    mov cx, 1
    int 10h
    pop cx              ; <--- RESTORE CX TO ITS ORIGINAL STATE
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
    jmp .opt5
.hi4:
    mov bl, 0Ah
    call print_str
    mov dh, 15
    mov dl, 28
    mov al, 10h
    mov bl, 0Eh
    call print_char

.opt5:
    mov dh, 17
    mov dl, 30
    mov si, opt5
    cmp byte [selected], 5
    je  .hi5
    mov bl, 0Fh
    call print_str
    jmp .done_opts
.hi5:
    mov bl, 0Ah
    call print_str
    mov dh, 17
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
    cmp byte [selected], 5
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
    cmp byte [selected], 4
    je  .do_2p
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

.do_2p:
    call game_2p
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
; UPDATE SPEED — every 5 points reduce pipe_move_rate (min 1)
; ============================================================
update_speed:
    ; Compute total score using 16-bit math to avoid divide overflow
    xor dx, dx
    xor ax, ax
    mov al, [score_hh]
    mov bx, 100
    mul bx                  ; AX = score_hh * 100
    mov cx, ax              ; save in CX

    xor ax, ax
    mov al, [score_hi]
    mov bl, 10
    mul bl                  ; AX = score_hi * 10
    add cx, ax

    xor ax, ax
    mov al, [score_lo]
    add cx, ax              ; CX = total score

    mov ax, cx
    xor dx, dx              ; MUST clear DX before DIV
    mov bx, 5
    div bx                  ; AX = level (quotient)

    ; pipe_move_rate = 4 - level, minimum 1
    mov bx, 4
    sub bx, ax              ; BX = 4 - level
    cmp bx, 1
    jge .set_rate
    mov bx, 1
.set_rate:
    mov [pipe_move_rate], bl
    ret

; ============================================================
; XOR_RAND — returns random byte in AL
; ============================================================
xor_rand:
    push dx
    mov ah, 00h
    int 1Ah                 ; DL = timer tick low byte
    mov al, [rng_state]
    ; XOR AL with (AL << 3)
    mov ah, al
    shl ah, 3
    xor al, ah
    ; XOR AL with (AL >> 5)
    mov ah, al
    shr ah, 5
    xor al, ah
    ; XOR AL with (AL << 1)
    mov ah, al
    shl ah, 1
    xor al, ah
    ; XOR AL with DL (timer tick)
    xor al, dl
    mov [rng_state], al
    pop dx
    ret

; ============================================================
; RANDOMIZE PIPE — BX = pipe index
; ============================================================
randomize_pipe:
    call xor_rand
    xor  al, bl
    xor  ah, ah
    push bx
    mov  bl, 10             ; remainder 0..9
    div  bl
    add  ah, 5              ; gap_top range: 4..13
    pop  bx
    mov  [gap_top + bx], ah
    ret

; ============================================================
; DRAW HUD BANNER — fills row 0 with solid blue background
; ============================================================
draw_hud_banner:
    mov dh, 0
    mov dl, 0
.banner_loop:
    cmp dl, 80
    jge .banner_done
    mov al, ' '
    mov bl, 1Fh
    call print_char
    inc dl
    jmp .banner_loop
.banner_done:
    ret

; ============================================================
; DRAW HUD
; ============================================================
draw_hud:
    mov dh, 0
    mov dl, 1
    mov si, str_score_lbl
    mov bl, 1Fh
    call print_str
    mov al, [score_hh]
    add al, '0'
    mov dh, 0
    mov dl, 8
    mov bl, 1Eh
    call print_char
    mov al, [score_hi]
    add al, '0'
    mov dh, 0
    mov dl, 9
    mov bl, 1Eh
    call print_char
    mov al, [score_lo]
    add al, '0'
    mov dh, 0
    mov dl, 10
    mov bl, 1Eh
    call print_char

    mov dh, 0
    mov dl, 60
    mov si, str_lives_lbl
    mov bl, 1Fh
    call print_str
    mov al, [lives]
    add al, '0'
    mov dh, 0
    mov dl, 67
    mov bl, 1Ch
    call print_char

    mov dh, 0
    mov dl, 35
    mov si, str_speed_lbl
    mov bl, 1Fh
    call print_str
    mov al, 5
    sub al, [pipe_move_rate]
    add al, '0'
    mov dh, 0
    mov dl, 42
    mov bl, 1Bh
    call print_char

    ; Boost indicator
    cmp byte [has_boost], 1
    jne .no_boost_icon
    mov dh, 0
    mov dl, 72
    mov al, 0F7h
    mov bl, 1Eh
    call print_char
    jmp .hud_done
.no_boost_icon:
    mov dh, 0
    mov dl, 72
    mov al, ' '
    mov bl, 1Fh
    call print_char
.hud_done:
    ret

; ============================================================
; ERASE / DRAW BIRD
; ============================================================
erase_bird:
    mov dh, [bird_y]
    mov dl, [bird_x]
    dec dl
    call restore_bg_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    call restore_bg_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    inc dl
    call restore_bg_char
    ret

draw_bird:
    mov al, [bird_frame]
    cmp al, 0
    je  .frame0
    cmp al, 1
    je  .frame1

    ; frame 2: / o \
    mov dh, [bird_y]
    mov dl, [bird_x]
    dec dl
    mov al, 2Fh
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, 6Fh
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    inc dl
    mov al, 5Ch
    mov bl, 3Eh
    call print_char
    ret

.frame0:
    ; frame 0: \ o /
    mov dh, [bird_y]
    mov dl, [bird_x]
    dec dl
    mov al, 5Ch
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, 6Fh
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    inc dl
    mov al, 2Fh
    mov bl, 3Eh
    call print_char
    ret

.frame1:
    ; frame 1: - o -
    mov dh, [bird_y]
    mov dl, [bird_x]
    dec dl
    mov al, 2Dh
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    mov al, 6Fh
    mov bl, 3Eh
    call print_char

    mov dh, [bird_y]
    mov dl, [bird_x]
    inc dl
    mov al, 2Dh
    mov bl, 3Eh
    call print_char
    ret

; ============================================================
; ERASE STAR
; ============================================================
erase_star:
    cmp byte [star_x], 0
    je  .erase_star_done
    mov dh, [star_y]
    mov dl, [star_x]
    call restore_bg_char
.erase_star_done:
    ret

; ============================================================
; DRAW STAR
; ============================================================
draw_star:
    cmp byte [star_x], 0
    je  .draw_star_done
    mov dh, [star_y]
    mov dl, [star_x]
    mov al, 0F7h
    mov bl, 0Eh
    call print_char
.draw_star_done:
    ret

; ============================================================
; UPDATE STAR — spawn, move, and check collision with bird
; ============================================================
update_star:
    cmp byte [star_x], 0
    jne .move_star

    ; Star inactive — count down spawn timer
    dec byte [star_timer]
    cmp byte [star_timer], 0
    jne .update_star_done

    ; SPAWN: reset timer
    call xor_rand
    xor ah, ah
    mov bl, 60
    div bl
    add ah, 40
    mov [star_timer], ah

    ; Random Y position (4..37)
    call xor_rand
    xor ah, ah
    mov bl, 16
    div bl
    add ah, 4              ; range: 4..19
    mov [star_y], ah

    ; Start at right edge
    mov byte [star_x], 78
    jmp .update_star_done

.move_star:
    dec byte [star_x]
    cmp byte [star_x], 0
    jne .check_star_collision

    ; Went off screen — reset timer
    call xor_rand
    xor ah, ah
    mov bl, 60
    div bl
    add ah, 40
    mov [star_timer], ah
    jmp .update_star_done

.check_star_collision:
    mov al, [star_x]
    cmp al, [bird_x]
    jne .update_star_done
    mov al, [star_y]
    cmp al, [bird_y]
    jne .update_star_done

    ; Collected!
    mov byte [has_boost], 1
    mov byte [star_x], 0

    call xor_rand
    xor ah, ah
    mov bl, 60
    div bl
    add ah, 40
    mov [star_timer], ah

.update_star_done:
    ret

; ============================================================
; RESTORE_BG_CHAR — Repaints the background at DH=row, DL=col
; Checks skyline_heights[DL] and prints sky, roof, or body.
; ============================================================
restore_bg_char:
    push ax
    push bx
    push dx 
    push si

    ; Load height for this column: SI = skyline_heights + DL
    xor si, si
    mov si, skyline_heights
    xor ax, ax
    mov al, dl
    add si, ax                  ; SI now points to skyline_heights[DL]
    mov al, [si]                ; AL = height of building at this column
    xor ah, ah

    ; If height is 0, no building here — print sky
    cmp al, 0
    je  .rbg_sky

    ; Calculate top_row = 23 - height
    mov ah, 23
    sub ah, al                  ; AH = top_row

    ; Compare current row (DH) against top_row (AH)
    cmp dh, ah
    jl  .rbg_sky                ; DH < top_row → sky
    je  .rbg_roof               ; DH == top_row → roof
    ; else DH > top_row → body

.rbg_body:
    mov al, 0DBh
    mov bl, 07h
    call print_char
    jmp .rbg_done

.rbg_roof:
    mov al, 0DCh
    mov bl, 0Fh
    call print_char
    jmp .rbg_done

.rbg_sky:
    mov al, ' '
    mov bl, 3Fh
    call print_char

.rbg_done:
    pop si
    pop dx
    pop bx
    pop ax
    ret

; ============================================================
; ERASE PIPE COLUMN — DL = column
; ============================================================
erase_pipe_col:
    mov dh, 1
.erase_loop:
    cmp dh, 23
    jge .erase_done
    call restore_bg_char
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
    jge .draw_top_cap
    mov al, 0DBh
    push bx              ; <--- SHIELD BX (Pipe Index)
    mov bl, 02h
    call print_char
    pop bx               ; <--- RESTORE BX
    inc dh
    jmp .top_loop

.draw_top_cap:
    cmp dh, 1
    je  .skip_top
    dec dh
    mov al, 0DFh
    push bx              ; <--- SHIELD BX
    mov bl, 0Ah
    call print_char
    pop bx               ; <--- RESTORE BX
    inc dh

.skip_top:
    mov cl, [gap_top + bx]  ; BX is now safely 0 or 1!
    add cl, [gap_size]
    mov dh, cl

    cmp dh, 23
    jge .bot_loop
    mov al, 0DCh
    push bx              ; <--- SHIELD BX
    mov bl, 0Ah
    call print_char
    pop bx               ; <--- RESTORE BX
    inc dh

.bot_loop:
    cmp dh, 23
    jge .pipe_done
    mov al, 0DBh
    push bx              ; <--- SHIELD BX
    mov bl, 02h
    call print_char
    pop bx               ; <--- RESTORE BX
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
    mov al, 0B1h
    mov bl, 26h
    call print_char
    inc dl
    jmp .gloop
.gdone:
    ret

; ============================================================
; DRAW GROUND SCROLL — animated ground on row 23
; ============================================================
draw_ground_scroll:
    inc byte [ground_offset]

    mov dh, 23
    mov dl, 0
    mov cx, 80
.loop:
    push cx
    push dx
    mov al, dl
    add al, [ground_offset]
    and al, 1
    cmp al, 0
    je .char_dash
    mov al, 0B2h
    jmp .print
.char_dash:
    mov al, 0B1h
.print:
    mov bl, 26h
    call print_char
    pop dx
    pop cx
    inc dl
    loop .loop

    ret

; ============================================================
; DRAW SKY — static city skyline at bottom of playfield
; ============================================================
draw_sky:
    push bx
    push cx
    push si

    mov si, skyline_heights   ; SI points to height table
    mov dl, 0                 ; DL = current column (0..79)

.col_loop:
    cmp dl, 80
    jge .sky_done

    push dx
    mov bl, [si]              ; BL = height for this column
    xor bh, bh
    cmp bx, 0
    je  .next_col             ; height 0 = no building here

    mov dh, 23
    sub dh, bl                ; DH = top row of building

    ; Draw rooftop
    mov al, 0DCh
    mov bl, 0Fh               ; bright white rooftop
    push cx
    call print_char
    pop cx
    inc dh

.body_loop:
    cmp dh, 23                ; stop before ground row
    jge .next_col
    mov al, 0DBh
    mov bl, 07h               ; light grey building body
    push cx
    call print_char
    pop cx
    inc dh
    jmp .body_loop

.next_col:
    pop dx
    inc dl
    inc si
    jmp .col_loop

.sky_done:
    pop si
    pop cx
    pop bx
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
    dec cl                  ; 1 row grace on top lip
    cmp al, cl
    jl  .hit

    mov cl, [gap_top + bx]
    add cl, [gap_size]
    inc cl                  ; 1 row grace on bottom lip
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
; ERASE / DRAW BIRD 2
; ============================================================
erase_bird2:
    mov dh, [bird2_y]
    mov dl, [bird2_x]
    dec dl
    call restore_bg_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    call restore_bg_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    inc dl
    call restore_bg_char
    ret

draw_bird2:
    mov al, [bird_frame]    ; P2 shares the same animation frame as P1
    cmp al, 0
    je  .frame0_2
    cmp al, 1
    je  .frame1_2

    ; frame 2: / o \
    mov dh, [bird2_y]
    mov dl, [bird2_x]
    dec dl
    mov al, 2Fh
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    mov al, 6Fh
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    inc dl
    mov al, 5Ch
    mov bl, 3Ch
    call print_char
    ret

.frame0_2:
    ; frame 0: \ o /
    mov dh, [bird2_y]
    mov dl, [bird2_x]
    dec dl
    mov al, 5Ch
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    mov al, 6Fh
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    inc dl
    mov al, 2Fh
    mov bl, 3Ch
    call print_char
    ret

.frame1_2:
    ; frame 1: - o -
    mov dh, [bird2_y]
    mov dl, [bird2_x]
    dec dl
    mov al, 2Dh
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    mov al, 6Fh
    mov bl, 3Ch
    call print_char

    mov dh, [bird2_y]
    mov dl, [bird2_x]
    inc dl
    mov al, 2Dh
    mov bl, 3Ch
    call print_char
    ret

; ============================================================
; ADVANCE BIRD ANIMATION — cycles frame 0,1,2 every 3 ticks
; ============================================================
advance_bird_anim:
    inc byte [anim_tick]
    mov al, [anim_tick]
    cmp al, 3              ; advance frame every 3 game ticks
    jl  .anim_done
    mov byte [anim_tick], 0
    inc byte [bird_frame]
    mov al, [bird_frame]
    cmp al, 3
    jl  .anim_done
    mov byte [bird_frame], 0
.anim_done:
    ret

; ============================================================
; CHECK COLLISION — BIRD 2
; ============================================================
check_col2_i:
    mov al, [bird2_y]
    cmp al, 23
    jge .hit2
    mov al, [bird2_x]
    cmp al, [pipe_x + bx]
    jne .no_hit2

    mov al, [bird2_y]
    mov cl, [gap_top + bx]
    dec cl                  ; 1 row grace on top lip
    cmp al, cl
    jl  .hit2

    mov cl, [gap_top + bx]
    add cl, [gap_size]
    inc cl                  ; 1 row grace on bottom lip
    cmp al, cl
    jge .hit2

.no_hit2:
    mov al, 0
    ret
.hit2:
    mov al, 1
    ret

check_collision2:
    xor bx, bx
    call check_col2_i
    cmp al, 1
    je  .done2
    mov bx, 1
    call check_col2_i
.done2:
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
    cmp byte [score_hi], 10
    jl  .update_spd
    mov byte [score_hi], 0
    inc byte [score_hh]
.update_spd:
    call update_speed
.no_score:
    ret

; ============================================================
; LOSE LIFE
; ============================================================
lose_life:
    mov byte [jump_sound_timer], 0
    call speaker_off
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
    push cx
    mov al, 60h
    mov ah, 10h
    mov cx, 1
    call beep
    pop cx
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
    mov byte [pipe_moved], 0
    ret
.truly_dead:
    call sound_death
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
    ; Compute final score using 16-bit math: AX = hh*100 + hi*10 + lo
    xor ax, ax
    mov al, [score_hh]
    mov bl, 100
    mul bl                  ; AX = score_hh * 100
    push ax
    xor ax, ax
    mov al, [score_hi]
    mov bl, 10
    mul bl                  ; AX = score_hi * 10
    pop bx
    add ax, bx              ; AX = hh*100 + hi*10
    xor bh, bh
    mov bl, [score_lo]
    add ax, bx              ; AX = total score
    cmp ax, 255
    jle .no_cap
    mov ax, 255             ; cap at 255 for 1-byte slot
.no_cap:
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

    mov al, [score_hh]
    add al, '0'
    mov dh, 10
    mov dl, 41
    mov bl, 0Eh
    call print_char

    mov al, [score_hi]
    add al, '0'
    mov dh, 10
    mov dl, 42
    mov bl, 0Eh
    call print_char

    mov al, [score_lo]
    add al, '0'
    mov dh, 10
    mov dl, 43
    mov bl, 0Eh
    call print_char

    ; Show if new record
    mov al, [cur_score_byte]
    cmp al, 0
    je  .no_record
    cmp al, [lb_scores + 44]
    jle .no_record

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
    mov byte [gap_size], 5
    mov byte [lives], 3
    mov byte [score_hh], 0
    mov byte [score_hi], 0
    mov byte [score_lo], 0
    mov byte [cur_score_byte], 0
    mov byte [jumped], 0
    mov byte [game_state], 1
    mov byte [delay_count],   3    ; fixed base tick rate
    mov byte [pipe_move_rate], 4
    mov byte [pipe_tick],      0
    mov byte [pipe_moved],     0
    mov byte [jump_sound_timer], 0
    mov byte [rng_state], 0xA5
    mov byte [ground_offset], 0
    mov byte [star_x], 0
    mov byte [star_timer], 30
    mov byte [has_boost], 0
    mov byte [bird_frame], 0
    mov byte [anim_tick], 0
    mov byte [gravity_tick], 0
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
    call draw_hud_banner
    call draw_sky
    call draw_ground_scroll

.game_loop:
    call erase_bird
    call erase_pipes
    call erase_star

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
    cmp byte [has_boost], 1
    jne .no_boost_jump
    dec byte [bird_y]
    mov byte [has_boost], 0
.no_boost_jump:
    mov byte [jumped], 1
    call sound_jump

.no_key:
    ; --- GRAVITY TICK UPDATE ---
    inc byte [gravity_tick]
    cmp byte [gravity_tick], 2
    jl  .check_grav
    mov byte [gravity_tick], 0

.check_grav:
    ; --- GRAVITY ---
    cmp byte [jumped], 1
    je  .skip_gravity
    cmp byte [gravity_tick], 0
    jne .skip_gravity
    inc byte [bird_y]

.skip_gravity:
    call update_star

    ; --- MOVE PIPES ---
    mov byte [pipe_moved], 0    ; default to not moved
    inc byte [pipe_tick]
    mov al, [pipe_tick]
    cmp al, [pipe_move_rate]
    jl  .skip_pipe_move
    mov byte [pipe_tick], 0
    mov byte [pipe_moved], 1    ; flag that pipes are moving this frame

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
    mov byte [old_pipe_x], 0     ; ← keep 0 so this frame's erase erases col 0
    xor bx, bx
    call randomize_pipe

.move_pipe1:
    cmp byte [pipe_x + 1], 0
    je  .reset_pipe1
    dec byte [pipe_x + 1]
    jmp .skip_pipe_move
.reset_pipe1:
    mov byte [pipe_x + 1], 79
    mov byte [old_pipe_x + 1], 0
    mov bx, 1
    call randomize_pipe

.skip_pipe_move:

    cmp byte [jump_sound_timer], 0
    je .skip_sound_tick
    dec byte [jump_sound_timer]
    cmp byte [jump_sound_timer], 0
    jne .skip_sound_tick
    call speaker_off
.skip_sound_tick:

    call check_collision
    cmp al, 1
    jne .no_collision
    call lose_life
    cmp byte [game_state], 0
    je  .game_over
    call clear_screen
    call draw_hud_banner
    call draw_sky
    call draw_ground_scroll
    jmp .draw_frame

.no_collision:
    cmp byte [pipe_moved], 1
    jne .draw_frame             ; If pipes didn't move, skip scoring
    call update_score

.draw_frame:
    call advance_bird_anim
    call draw_ground_scroll
    call draw_pipes
    call draw_star
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
; 2-PLAYER GAME LOOP
; ============================================================
game_2p:
    call init_game
    mov byte [p1_dead], 0
    mov byte [p2_dead], 0
    mov byte [bird_y],  8
    mov byte [bird2_y], 14
    call clear_screen
    call draw_hud_banner
    call draw_sky
    call draw_ground

    mov dh, 0
    mov dl, 1
    mov si, str_p1_lbl
    mov bl, 1Eh
    call print_str

    mov dh, 0
    mov dl, 55
    mov si, str_p2_lbl
    mov bl, 1Ch
    call print_str

.g2_loop:
    ; Erase both birds
    cmp byte [p1_dead], 0
    jne .skip_erase1
    call erase_bird
.skip_erase1:
    cmp byte [p2_dead], 0
    jne .skip_erase2
    call erase_bird2
.skip_erase2:

    call erase_pipes

    ; --- INPUT ---
    mov byte [jumped],  0
    mov byte [jumped2], 0

    mov ah, 01h
    int 16h
    jz  .g2_no_key
    mov ah, 00h
    int 16h

    cmp al, 1Bh
    je  .g2_quit

    ; P1: Space
    cmp al, 20h
    jne .check_p2_key
    cmp byte [p1_dead], 1
    je  .check_p2_key
    cmp byte [bird_y], 2
    jle .check_p2_key
    dec byte [bird_y]
    dec byte [bird_y]
    mov byte [jumped], 1
    call sound_jump
    jmp .g2_no_key

    ; P2: Enter
.check_p2_key:
    cmp al, 0Dh
    jne .g2_no_key
    cmp byte [p2_dead], 1
    je  .g2_no_key
    cmp byte [bird2_y], 2
    jle .g2_no_key
    dec byte [bird2_y]
    dec byte [bird2_y]
    mov byte [jumped2], 1
    call sound_jump

.g2_no_key:
    ; --- GRAVITY TICK UPDATE ---
    inc byte [gravity_tick]
    cmp byte [gravity_tick], 2
    jl  .check_p1_grav
    mov byte [gravity_tick], 0

.check_p1_grav:
    ; --- GRAVITY P1 ---
    cmp byte [p1_dead], 1
    je  .skip_grav1
    cmp byte [jumped], 1
    je  .skip_grav1
    cmp byte [gravity_tick], 0
    jne .skip_grav1
    inc byte [bird_y]
.skip_grav1:

    ; --- GRAVITY P2 ---
    cmp byte [p2_dead], 1
    je  .skip_grav2
    cmp byte [jumped2], 1
    je  .skip_grav2
    cmp byte [gravity_tick], 0
    jne .skip_grav2
    inc byte [bird2_y]
.skip_grav2:

    ; --- PIPE TICK GATE ---
    mov byte [pipe_moved], 0
    inc byte [pipe_tick]
    mov al, [pipe_tick]
    cmp al, [pipe_move_rate]
    jl  .g2_skip_pipes
    mov byte [pipe_tick], 0
    mov byte [pipe_moved], 1

    mov al, [pipe_x]
    mov [old_pipe_x], al
    mov al, [pipe_x + 1]
    mov [old_pipe_x + 1], al

    cmp byte [pipe_x], 0
    je  .g2_reset0
    dec byte [pipe_x]
    jmp .g2_pipe1
.g2_reset0:
    mov byte [pipe_x], 79
    mov byte [old_pipe_x], 0
    xor bx, bx
    call randomize_pipe

.g2_pipe1:
    cmp byte [pipe_x + 1], 0
    je  .g2_reset1
    dec byte [pipe_x + 1]
    jmp .g2_skip_pipes
.g2_reset1:
    mov byte [pipe_x + 1], 79
    mov byte [old_pipe_x + 1], 0
    mov bx, 1
    call randomize_pipe

.g2_skip_pipes:
    ; --- NON-BLOCKING AUDIO TICK ---
    ; Must be present in this loop — without it the speaker stays on forever
    cmp byte [jump_sound_timer], 0
    je  .g2_skip_sound
    dec byte [jump_sound_timer]
    cmp byte [jump_sound_timer], 0
    jne .g2_skip_sound
    call speaker_off
.g2_skip_sound:

    ; --- COLLISION P1 ---
    cmp byte [p1_dead], 1
    je  .g2_col2
    call check_collision
    cmp al, 1
    jne .g2_col2
    mov byte [p1_dead], 1
    call sound_death

    ; --- COLLISION P2 ---
.g2_col2:
    cmp byte [p2_dead], 1
    je  .g2_check_end
    call check_collision2
    cmp al, 1
    jne .g2_check_end
    mov byte [p2_dead], 1
    call sound_death

.g2_check_end:
    ; Match ends if EITHER player is dead (OR, not AND)
    ; AND would mean both must die simultaneously — zombie player bug
    mov al, [p1_dead]
    or  al, [p2_dead]
    cmp al, 1
    je  .g2_over

    ; Score only updates on frames where pipes actually moved
    cmp byte [pipe_moved], 1
    jne .g2_draw
    call update_score

.g2_draw:
    call advance_bird_anim
    call erase_pipes
    call draw_pipes
    cmp byte [p1_dead], 0
    jne .skip_draw1
    call draw_bird
.skip_draw1:
    cmp byte [p2_dead], 0
    jne .skip_draw2
    call draw_bird2
.skip_draw2:
    call draw_hud
    call draw_ground_scroll
    call delay_loop
    jmp .g2_loop

.g2_over:
    call game_over_2p
    ret

.g2_quit:
    call clear_screen
    ret

; ============================================================
; 2-PLAYER GAME OVER
; ============================================================
game_over_2p:
    call clear_screen

    mov dh, 7
    mov dl, 26
    mov si, str_2p_over
    mov bl, 0Ch
    call print_str

    ; Determine winner using OR logic to match .g2_check_end
    mov al, [p1_dead]
    cmp al, 1
    je  .p1_lost
    mov dh, 10
    mov dl, 28
    mov si, str_p1_wins
    mov bl, 0Eh
    call print_str
    jmp .show_score_2p
.p1_lost:
    mov al, [p2_dead]
    cmp al, 1
    je  .its_draw
    mov dh, 10
    mov dl, 28
    mov si, str_p2_wins
    mov bl, 0Ch
    call print_str
    jmp .show_score_2p
.its_draw:
    mov dh, 10
    mov dl, 30
    mov si, str_draw
    mov bl, 0Fh
    call print_str

.show_score_2p:
    mov dh, 13
    mov dl, 28
    mov si, str_finalscore
    mov bl, 0Fh
    call print_str
    mov al, [score_hh]
    add al, '0'
    mov dh, 13
    mov dl, 41
    mov bl, 0Eh
    call print_char
    mov al, [score_hi]
    add al, '0'
    mov dh, 13
    mov dl, 42
    mov bl, 0Eh
    call print_char
    mov al, [score_lo]
    add al, '0'
    mov dh, 13
    mov dl, 43
    mov bl, 0Eh
    call print_char

    mov dh, 17
    mov dl, 24
    mov si, str_presskey
    mov bl, 08h
    call print_str
    mov ah, 00h
    int 16h
    ret

; ============================================================
; PC SPEAKER — speaker_on, speaker_off, beep, sound_jump, sound_death
; ============================================================

; --- speaker_on: AL = low byte, AH = high byte ---
speaker_on:
    push ax
    mov al, 0B6h
    out 43h, al
    pop ax
    push ax           ; save frequency before port 61h clobbers AL
    out 42h, al
    mov al, ah
    out 42h, al
    in  al, 61h
    or  al, 03h
    out 61h, al
    pop ax            ; restore original AX
    ret

; --- speaker_off ---
speaker_off:
    push ax
    in  al, 61h
    and al, 0FCh      ; clear bits 0 and 1
    out 61h, al
    pop ax
    ret

; --- beep: AX = frequency word, CX = duration (busy-wait) ---
; Used ONLY for blocking events (death/damage) to create hit-pause
beep:
    call speaker_on
.wait:
    push cx
    mov  cx, 0FFFFh
.inner:
    loop .inner
    pop  cx
    loop .wait
    call speaker_off
    ret

; --- sound_jump ---
; NON-BLOCKING: Turns speaker on and sets a timer, physics keep running
sound_jump:
    mov al, 0D3h      ; ~800 Hz low byte
    mov ah, 05h       ; ~800 Hz high byte
    call speaker_on
    mov byte [jump_sound_timer], 2   ; keep speaker on for 2 frames
    ret

; --- sound_death ---
; BLOCKING: Descending slide for game over
sound_death:
    mov al, 0D3h
    mov ah, 05h
    mov cx, 1
    call beep
    mov al, 0A0h
    mov ah, 09h
    mov cx, 1
    call beep
    mov al, 60h
    mov ah, 10h
    mov cx, 2
    call beep
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
opt4       db '4. 2-Player$'
opt5       db '5. Quit$'

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

str_p1_lbl  db 'P1:$'
str_p2_lbl  db 'P2:$'
str_2p_over db '*** 2-PLAYER GAME OVER ***$'
str_p1_wins db 'Player 1 WINS! (Yellow)$'
str_p2_wins db 'Player 2 WINS! (Red)$'
str_draw    db 'Its a DRAW!$'

; File I/O
filename      db 'SCORES.DAT', 0
file_handle   dw 0

; Game variables
bird_y        db 10
bird_x        db 10
velocity      db 0
jumped        db 0
jumped2       db 0
pipe_x        db 79, 39
old_pipe_x    db 79, 39
gap_top       db 8, 8
gap_size      db 5
lives         db 3
score_hh      db 0
score_hi      db 0
score_lo      db 0
cur_score_byte db 0
game_state    db 1
delay_count   db 5
rng_state     db 0xA5
star_x        db 0
star_y        db 0
star_timer    db 30
has_boost     db 0
ground_offset db 0
pipe_tick      db 0    ; counts up each frame
pipe_move_rate db 4    ; pipes move every N frames
pipe_moved     db 0    ; 1 = pipes moved this frame, 0 = didn't move
jump_sound_timer db 0
bird2_y     db 14
bird2_x     db 10
p2_dead     db 0
p1_dead     db 0
bird_frame  db 0      ; cycles 0, 1, 2, 0, 1, 2 ...
anim_tick   db 0      ; counts frames between animation steps
gravity_tick db 0     ; counts frames between gravity steps

; Skyline height table — 80 bytes, one per column
skyline_heights:
    db 0,0,4,4,4,4,4,4,0,0   ; cols 0-9
    db 0,6,6,6,6,6,6,6,6,0   ; cols 10-19
    db 0,0,3,3,3,3,3,0,0,0   ; cols 20-29
    db 7,7,7,7,7,7,7,7,7,7   ; cols 30-39
    db 7,7,7,7,7,7,7,7,7,7   ; cols 40-49
    db 0,0,5,5,5,5,5,5,0,0   ; cols 50-59
    db 0,4,4,4,4,4,4,4,0,0   ; cols 60-69
    db 0,0,6,6,6,6,6,6,6,0   ; cols 70-79

; Leaderboard buffer — 3 slots x 22 bytes = 66 bytes
; Each slot: [score_byte][name 21 bytes]
lb_scores     times 66 db 0

; Menu variables
selected      db 1
name_len      db 0
username      times 22 db '$'