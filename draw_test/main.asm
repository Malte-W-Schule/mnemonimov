

bmk "Includes"

include "../vec_libary/main.asm"


bmk "Assets"

spaceship: emb file "assets/spcae.png"


bmk "Draw Libary"
# ==================================== #
# Draw Libary
# ==================================== #
sbmk "Readme"

vec3_0: res u8t vector.vector_size

vec3_max_screen: res u8t vector.vector_size

vec3_tmp_0: res u8t vector.vector_size
vec3_tmp_1: res u8t vector.vector_size
vec3_tmp_2: res u8t vector.vector_size

bmk "Draw functions"

sbmk "draw pixel save"

## Function: draws a pixel on the screen... and doesnt when its outside the window

## Params:
# a0    : x
# a1    : y
# a2    : luma (1..255)
draw_float_pixel_save:
    # --- Bounds Check (0.0 <= x < 320.0 und 0.0 <= y < 240.0) ---

    fcti a0, a0
    fcti a1, a1
    cmp lt, a0, 0
    jtr .dont_draw_pixel_save
    cmp lt, a1, 0
    jtr .dont_draw_pixel_save

    cmp gt, a0, (SCREEN_WIDTH-1)
    jtr .dont_draw_pixel_save
    cmp gt, a1, (SCREEN_HEIGHT-1)
    jtr .dont_draw_pixel_save

    # --- Draw ---
    sbpx a0, a1, a2

.dont_draw_pixel_save:
    ret

sbmk "draw line"
## Function: Draws line with out-of-bounds pixel discarding
## Params:
# a0    : vec3 start (X, Y, Z)
# a1    : vec3 end (X, Y, Z)
# a2    : luma (1..255)

draw_line:

    # --- save values ---
    psh s0
    psh s1
    psh s2
    psh s3
    psh s4
    psh s5
    # --- save input > s ---
    mov s0, a0                          # start vec3
    mov s1, a1                          # end vec3
    mov s2, a2                          # luma

    # end - start
    mov a0, s0
    mov a1, s1
    mov a2, vec3_tmp_0
    cal vec3_difference_vec

    # --- Magnitute (distance) ---
    mov a0, vec3_tmp_0
    cal vec3_magnitude
    frou a0, a0                         # Auf Ganzzahl runden
    fcti s4, a0                         # s4 = max steps

    # --- Normalize ---
    mov a0, vec3_tmp_0                  # a0    : source vec3 address
    mov a1, vec3_tmp_0                  # a1    : destination vec3 address
    cal vec3_normalize

    # --- loop ---

    mov a0, s0                          # load start -> a0
    mov a1, vec3_tmp_1                  # a1    : dst vec
    cal vec3_copy                       # copy start into tmp_1 (current)

    mov s5,0                            # counter to 0
    add s4,s4,1
    # - start loop -
.draw_line_loop:

    # - draw -
    mov a0,vec3_tmp_1
    # a0    : x
    # a1    : y

    cal vec3_load
    mov a2,s2                           # a2    : luma (1..255)

    cal draw_float_pixel_save
    # - increase -
    mov a0,vec3_tmp_1                   # load param 1 current vec
    mov a1,vec3_tmp_0                   # load param 2 to add (normalized)
    mov a2,vec3_tmp_1                   # dst
    cal vec3_add

    # - end loop -
    inc s5
    cmp lt,s5,s4                       # while counter < max
    jtr .draw_line_loop

    .draw_line_done:
    pop s5
    pop s4
    pop s3
    pop s2
    pop s1
    pop s0
    ret

bmk "start"
start_1:    res u8t vector.vector_size
end_1:      res u8t vector.vector_size

_start: # Runs once when the VM starts.
    # Initialize your game state here.

    mov a0,20.0
    mov a1,200.0
    mov a2,0.0
    mov a3,start_1
    cal vec3_store

    exit

bmk "update"
_update: # Runs at 60 Hz.

    # keyboard
    syscall SYS_GET_INPUT

    # BTN_LEFT
    and t0,a0,BTN_LEFT
    and t1,a0,BTN_RIGHT
    cmp neq, t0, 0
    jfs .left_button
    # wenn getdrückt

    mov a0,start_1
    cal vec3_load
    fsub a0,a0,1.0
    mov a3, start_1                       # destination
    cal vec3_store

.left_button:
    # wenn nich gedrückt bzw
    cmp neq,t1,0
    jfs .right_button

    mov a0,start_1
    cal vec3_load
    fadd a0,a0,1.0
    mov a3, start_1                       # destination
    cal vec3_store

    .right_button:

    #draw ship
    mov a0,start_1
    cal vec3_load

    mov t0,a0
    mov t1,a1

    mov a0, spaceship    # a0: PA-relative Adresse der Textur

    fcti a1,t0
    fcti a2,t1



    mov a3, 0           # mirrow
    syscall SYS_DRAW_TEXTURE

    # mouse
    syscall SYS_GET_MOUSE_POSITION      # a0 = x (int), a1 = y (int)

    fctf a0, a0                         # int -> float
    fctf a1, a1                         # int -> float
    mov a2, 0.0                         # z = 0.0 (float)
    mov a3, end_1                       # destination
    cal vec3_store




    exit

bmk "draw"
_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.

    mov a0, start_1
    mov a1, end_1
    mov a2, 100                         # Luma 255
    cal draw_line
    exit

bmk "input"
_input: # Runs when input state changes.
    # React to player input here.
    exit
