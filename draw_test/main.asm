bmk "Readme"
# ==============================================================================
# Vec3 Math & Utility Library
# ==============================================================================
# Version: 1.2
#
# OVERVIEW:
# A 3D single-precision float vector library
#
# - Struct Layout:
#     vector.x = offset 0  (4 bytes, f32t)
#     vector.y = offset 4  (4 bytes, f32t)
#     vector.z = offset 8  (4 bytes, f32t)
#     Total Size = 12 bytes
#
# - Memory Primitives:
#     - vec3_load  : Reads RAM (a0) -> Registers (a0=x, a1=y, a2=z)
#     - vec3_store : Writes Registers (a0..a2) -> RAM (a3)
#     - vec3_copy  : Copies RAM (a0) -> RAM (a1)
#
# - Destination Pointer Standard:
#       most functions provide a destination pointer (dst) as input
#       allowing to direcly write the function to memory
#       also allowing in-place operations (src == dst)
#
# - Temporary vector:
#       a pre_allocated global temporary `vec3_tmp` buffer, for temporarily storing
#       results when allocating it somewhere else isnt available
# ==============================================================================

bmk "Vec3 Basics"

sbmk "vec3 struct"

vector:
    ._x: emb f32t 0.0
    ._y: emb f32t 0.0
    ._z: emb f32t 0.0

    def .x (._x - vector)               # offset 0
    def .y (._y - vector)               # offset 4
    def .z (._z - vector)               # offset 8
    def .vector_size ( $ - vector)      # size 12

sbmk "vec3 load"
## Functionality: Loads x, y, z from memory into registers a0..a2

## Params:
# a0    : source vec3 address

## Output:
# a0    : component x
# a1    : component y
# a2    : component z
vec3_load:
    cea a0, 0, 1                        # Load vec address into CEA
    lde f32t, a0, vector.x              # a0 <- x
    lde f32t, a1, vector.y              # a1 <- y
    lde f32t, a2, vector.z              # a2 <- z
    ret

sbmk "vec3 store"
## Functionality: Stores registers a0..a2 into memory address a3

## Params:
# a0..a2: values x, y, z
# a3    : destination vec3 address

## Output:
# none
vec3_store:
    cea a3, 0, 1                        # Load destination address into CEA
    ste f32t, vector.x, a0              # Store x
    ste f32t, vector.y, a1              # Store y
    ste f32t, vector.z, a2              # Store z
    ret

sbmk "vec3 copy"
## Functionality: Copies 12 bytes from source address to destination address

## Params:
# a0    : source vec3 address
# a1    : destination vec3 address

## Output:
# none
vec3_copy:
    mov a3, a1                          # Destination pointer -> a3
    cal vec3_load                       # Load src (a0) into a0..a2
    cal vec3_store                      # Store a0..a2 into dst (a3)
    ret

bmk "Vec3 single access"

sbmk "vec3 load x"
## Functionality:

## Params:
# a0    : source vec3 address

## Output:
# a0    : x

vec3_load_x:
    cea a0, 0, 1                        # Load vec address into CEA
    lde f32t, a0, vector.x              # a0 <- x
    ret

sbmk "vec3 load y"
## Functionality:

## Params:
# a0    : source vec3 address

## Output:
# a0    : y

vec3_load_y:
    cea a0, 0, 1                        # Load vec address into CEA
    lde f32t, a0, vector.y              # a0 <- y
    ret

sbmk "vec3 load z"
## Functionality:

## Params:
# a0    : source vec3 address

## Output:
# a0    : z

vec3_load_z:
    cea a0, 0, 1                        # Load vec address into CEA
    lde f32t, a0, vector.z              # a0 <- z
    ret

sbmk "vec3 store x"
## Functionality: Stores registers a0..a2 into memory address a3

## Params:
# a0    :   value x
# a1    :   destination vec3 add (dst)

## Output:
# none
vec3_store_x:
    cea a1, 0, 1                        # Load destination address into CEA
    ste f32t, vector.x, a0              # Store x
    ret

sbmk "vec3 store y"
## Functionality: Stores registers a0..a2 into memory address a3

## Params:
# a0    :   value y
# a1    :   destination vec3 add (dst)

## Output:
# none
vec3_store_y:
    cea a1, 0, 1                        # Load destination address into CEA
    ste f32t, vector.x, a0              # Store y
    ret

sbmk "vec3 store z"
## Functionality: Stores registers a0..a2 into memory address a3

## Params:
# a0    :   value z
# a1    :   destination vec3 add (dst)

## Output:
# none
vec3_store_z:
    cea a1, 0, 1                        # Load destination address into CEA
    ste f32t, vector.x, a0              # Store z
    ret


bmk "Vec3 Advanced"

sbmk "vec3 load 2"
## Functionality: Loads two vectors into registers simultaneously
## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
## Output:
# a0..a2: Vec A (x, y, z)
# a3..a5: Vec B (x, y, z)
vec3_load_2:
    psh a0                              # | a0(srcA)

    # --- Load Vec B ---
    mov a0, a1                          # a0 = srcB
    cea a0, 0, 1
    lde f32t, a3, vector.x              # a3 <- B.x
    lde f32t, a4, vector.y              # a4 <- B.y
    lde f32t, a5, vector.z              # a5 <- B.z

    # --- Load Vec A ---
    pop a0                              # | [a0(srcA)]
    cea a0, 0, 1
    cal vec3_load                       # a0..a2 <- A(x, y, z)
    ret

sbmk "vec3 store 2"
## Functionality: Stores two vectors to their respective destination addresses

## Params:
# a0..a2: Vec A (x, y, z)
# a3..a5: Vec B (x, y, z)
# a6    : destination vec3 A address
# a7    : destination vec3 B address

## Output:
# none
vec3_store_2:
    # --- Store Vec A ---
    cea a6, 0, 1
    cal vec3_store

    # --- Store Vec B ---
    cea a7, 0, 1
    ste f32t, vector.x, a3              # Store B.x
    ste f32t, vector.y, a4              # Store B.y
    ste f32t, vector.z, a5              # Store B.z
    ret

sbmk "vec3 swizzle"
## Functionality: Re-orders / broadcasts vector components based on a bitmask
## Bitmask Encoding (2 bits per component):
# 00 = 0.0 (zero)
# 01 = x
# 10 = y
# 11 = z

## Params:
# a0    : source vec3 address
# a1    : 6-bit mask (e.g. 0b11_10_01 for z, y, x)
# a2    : destination vec3 address

## Output:
# none
vec3_swizzle:
    # --- Preserve parameters ---
    mov a3, a1                          # Mask (a1) -> a3
    psh a2                              # | a2(dst)
    cal vec3_load                       # a0..a2 = x, y, z

    # --- Swizzle X (Bits 1..0) ---
    cal swizzle_single                  # Selected component in a4
    psh a4                              # | a2(dst) - a4(new_x)

    # --- Swizzle Y (Bits 3..2) ---
    cal swizzle_single                  # Selected component in a4
    psh a4                              # | a2(dst) - a4(new_x) - a4(new_y)

    # --- Swizzle Z (Bits 5..4) ---
    cal swizzle_single                  # Selected component in a4
    mov a2, a4                          # a2 = new Z

    # --- Restore X and Y into standard registers ---
    pop a1                              # a1 = new Y
    pop a0                              # a0 = new X

    # --- Store to destination ---
    pop a3                              # a3 = dst address
    cal vec3_store
    ret

sbmk"vec3 clip"
## Functionality:
# clips a vectors values between (min;max)
# (min,x,max)

## Params:
# a0    :   source vec3 A
# a1    :   vec 3 (min values)
# a2    :   vec 3 (max values)
# a3    :   destionation vec3

## Output:
vec3_clip:

    # --- save values ---
    psh a3                              # |a3(dst)
    psh a2                              # |a3(dst)-a2(max)
    psh a1                              # |a3(dst)-a2(max)-a1(min)
    # --- load vec A & Min values ---
    cal vec3_load                       # values a0-a2
    # --- tmp store values in t0-t2 ---
    mov t0,a0
    mov t1,a1
    mov t2,a2
    # --- load min max in a0-a5 ---
    psh a0                              # |a3(dst)-a2(max)  [a1(min)]
    psh a1                              # |a3(dst)          [a2(max)]
    cal vec3_load_2
    # a0..a2: Vec min (x, y, z)
    # a3..a5: Vec max (x, y, z)
    # t0..t2: Vec A (x, y, z)

    # --- clamp ---
    fclp a0,t0,a0,a3
    fclp a1,t1,a1,a4
    fclp a2,t2,a2,a5
    # --- store in dst ---
    psh a3                              # |     [a1(dst)]
    cal vec3_store

    ret

bmk "Vec3 Calculations"

sbmk "vec3 add"
## Functionality:

## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

## Output:
vec3_add:

    psh a2                              # |a2(dst)
    cal vec3_load_2                     # values in a0-a5
    # vec A a0:x a1:y a2:z
    # bec B a3:x a4:y a5:z

    vfadd a0..a2,a0..,a3..

    pop a3                              # |     [a2(dst)]
    cal vec3_store

    ret

sbmk "vec3 difference vec"

## Functionality:

## Params:
# a0    : source vec3 A address (start)
# a1    : source vec3 B address (end)
# a2    : destination vec3 address

## Output:
vec3_difference_vec:

    psh a2                              # |a2(destination)

    cal vec3_load_2                     # load vec a b a0-a5
    # vec A a0:x a1:y a2:z
    # bec B a3:x a4:y a5:z

    # --- X ---
    fsub a0,a3,a0
    # --- Y ---
    fsub a1,a4,a1
    # --- Z ---
    fsub a2,a5,a2
    # --- store in destination ---
    pop a3                              # |     [a2(dst)]
    cal vec3_store
    ret


sbmk "vec3 dot product"
## Functionality: Calculates dot product of two vectors: (A.x*B.x + A.y*B.y + A.z*B.z)

## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address

## Output:
# a0    : dot product scalar (float)
vec3_dot_product:
    # --- Load both vectors ---
    cal vec3_load_2                     # a0..a2 = A, a3..a5 = B

    # --- Vectorized FMA: A.x*B.x, A.y*B.y, A.z*B.z ---
    vffma a0..a2, a0.., a3.., zr

    # --- Horizontal Sum ---
    fadd a0, a0, a1                     # a0 = (A.x*B.x) + (A.y*B.y)
    fadd a0, a0, a2                     # a0 = total dot product
    ret

sbmk "vec3 magnitude"
## Functionality: Calculates vector Euclidean length |v| = sqrt(x^2 + y^2 + z^2)

## Params:
# a0    : source vec3 address

## Output:
# a0    : magnitude scalar (float)
vec3_magnitude:
    # --- Load source vector ---
    cal vec3_load                       # a0..a2 = x, y, z

    # --- Sum of squares ---
    fmul t0, a0, a0                     # t0 = x^2
    ffma t0, a1, a1, t0                 # t0 = y^2 + x^2
    ffma a0, a2, a2, t0                 # a0 = z^2 + (x^2 + y^2)
    fsqrt a0, a0                        # a0 = sqrt(|v|^2)
    ret

sbmk "vec3 normalize"
## Functionality: Normalizes vector to unit length (^v = v / |v|)

## Params:
# a0    : source vec3 address
# a1    : destination vec3 address

## Output:
# none
vec3_normalize:
    # --- Save parameters ---
    psh a1                              # | a1(dst)
    psh a0                              # | a1(dst) - a0(src)

    # --- Calculate magnitude ---
    cal vec3_magnitude                  # a0 = |v|
    mov t0, a0                          # t0 = magnitude divisor

    # --- Reload source vector ---
    pop a0                              # | a1(dst) [a0(src)]
    cal vec3_load                       # a0..a2 = x, y, z

    # --- Scale components ---
    fdiv a0, a0, t0                     # x' = x / |v|
    fdiv a1, a1, t0                     # y' = y / |v|
    fdiv a2, a2, t0                     # z' = z / |v|

    # --- Store unit vector ---
    pop a3                              # | [a1(dst)]
    cal vec3_store
    ret

sbmk "vec3 cross product"
## Functionality: Calculates Cross Product C = A x B
# C.x = (A.y * B.z) - (B.y * A.z)
# C.y = (A.z * B.x) - (B.z * A.x)
# C.z = (A.x * B.y) - (B.x * A.y)

## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

## Output:
# none
vec3_cross_product:
    psh a2                              # | a2(dst)

    # --- Load Vec A and Vec B ---
    cal vec3_load_2                     # a0..a2 = Vec A, a3..a5 = Vec B

    # --- Backup Vec A in temp registers ---
    mov t3, a0                          # t3 = A.x
    mov t4, a1                          # t4 = A.y
    mov t5, a2                          # t5 = A.z

    # --- Compute C.x ---
    fmul t0, t4, a5                     # t0 = A.y * B.z
    fmul t1, a4, t5                     # t1 = B.y * A.z
    fsub a0, t0, t1                     # a0 = C.x

    # --- Compute C.y ---
    fmul t0, t5, a3                     # t0 = A.z * B.x
    fmul t1, a5, t3                     # t1 = B.z * A.x
    fsub a1, t0, t1                     # a1 = C.y

    # --- Compute C.z ---
    fmul t0, t3, a4                     # t0 = A.x * B.y
    fmul t1, a3, t4                     # t1 = B.x * A.y
    fsub a2, t0, t1                     # a2 = C.z

    # --- Store to destination ---
    pop a3                              # a3 = dst
    cal vec3_store
    ret

bmk "Vec3 Examples"

sbmk "vec3 create"
# Allocates a 12-byte block in storage for a vec3 instance
vec3_example: res u8t vector.vector_size

sbmk "vec3 load value"
# Example: Loading a single component directly
vec3_load_example:
    cea a0, 0, 1                        # a0 = vector address
    lde f32t, a0, vector.x              # Load x into a0
    ret

sbmk "vec3 store value"
# Example: Storing a single component directly
vec3_write_example:
    cea a0, 0, 1                        # a0 = vector address
    ste f32t, vector.x, a5              # Store a5 into vector.x
    ret

bmk "Vec3 Draw/Print"

sbmk "vec3 draw on screen"
## Functionality: Draws 3 component bar representations on LCD screen

## Params:
# a0    : start X coordinate
# a1    : source vec3 address

## Output:
# none
vec3_draw_on_screen:
    mov t0, a0                          # Save start X pos -> t0
    mov a0, a1                          # a0 = vec address
    cal vec3_load                       # Load a0..a2

    psh a2                              # | a2(z)
    psh a1                              # | a2(z) - a1(y)

    # Draw X
    mov a1, a0                          # a1 = float val
    mov a0, t0                          # a0 = screen X
    cal draw_float_on_screen

    # Draw Y
    add t0, t0, 15                      # Next column
    mov a0, t0
    pop a1                              # Restore Y
    cal draw_float_on_screen

    # Draw Z
    add t0, t0, 15                      # Next column
    mov a0, t0
    pop a1                              # Restore Z
    cal draw_float_on_screen
    ret

sbmk "vec3 print"

print_x: emb string "X: "
print_y: emb string "Y: "
print_z: emb string "Z: "

## Functionality: Prints formatted vector components to the terminal

## Params:
# a0    : source vec3 address

## Output:
# none
vec3_print:
    cal vec3_load                       # a0..a2 = x, y, z
    psh a2                              # | a2(z)
    psh a1                              # | a2(z) - a1(y)
    psh a0                              # | a2(z) - a1(y) - a0(x)

    # --- Print X ---
    mov a0, print_x
    syscall SYS_PRINT_STRING
    pop a0                              # Restore X
    syscall SYS_PRINT_LINE_FLOAT

    # --- Print Y ---
    mov a0, print_y
    syscall SYS_PRINT_STRING
    pop a0                              # Restore Y
    syscall SYS_PRINT_LINE_FLOAT

    # --- Print Z ---
    mov a0, print_z
    syscall SYS_PRINT_STRING
    pop a0                              # Restore Z
    syscall SYS_PRINT_LINE_FLOAT
    ret

bmk "Vec3 Helpers"

sbmk "vec3 tmp"
# Global scratchpad for temporary vector operations
vec3_tmp: res u8t vector.vector_size

sbmk "swizzle single"
## Helper: Extracts lowest 2 bits from a3, loads value into a4, shifts mask right

## Params:
# a0..a2: original x, y, z
# a3    : bitmask

## Output:
# a0..a2: original x, y, z (preserved)
# a3    : bitmask (shifted right by 2)
# a4    : selected float value (0.0, x, y, or z)
swizzle_single:
    and a4, a3, 3                       # a4 = lowest 2 bits (0b11 = 3)
    sar a3, a3, 2                       # Shift mask for next component

    cmp eq, a4, 0
    jtr .swizzle_00

    cmp eq, a4, 1
    jtr .swizzle_01

    cmp eq, a4, 2
    jtr .swizzle_10

    # 0b11 -> Z component
    mov a4, a2
    ret

.swizzle_00:
    mov a4, 0.0                         # 0b00 -> 0.0
    ret

.swizzle_01:
    mov a4, a0                          # 0b01 -> X
    ret

.swizzle_10:
    mov a4, a1                          # 0b10 -> Y
    ret

sbmk "draw float on screen"
## Helper: Renders a single float as a bar on screen

## Params:
# a0    : start X coordinate
# a1    : float value to draw
draw_float_on_screen:
    mov a4, 80                          # Default luma (negative/dim)

    cmp flt, a1, 0.0
    jtr .draw_calc_height

    mov a4, 255                         # Positive luma (bright)

.draw_calc_height:
    fabs a3, a1                         # Absolute value for height
    fmul a3, a3, 10.0                   # Scale factor 10x
    fcti a3, a3                         # Float -> Int height

    cmp eq, a3, 0                       # Clamp minimum height to 1 pixel
    jfs .draw_render
    mov a3, 1

.draw_render:
    mov a1, 10                          # Screen Y pos
    mov a2, 10                          # Bar width (size X)

    # Args: a0=pos_x, a1=pos_y, a2=size_x, a3=size_y, a4=luma
    syscall SYS_DRAW_RECT
    ret

bmk "Vec3 End"


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
    mov a2, 155                         # Luma 255
    cal draw_line
    exit

bmk "input"
_input: # Runs when input state changes.
    # React to player input here.
    exit
