
bmk "Deritrives"

sbmk "buffer"
buffer: res u8t MAX_TERMINAL_INPUT_SIZE

bmk "Settings"

def LEARNRATE 0.1
def PRINT_NN_IN_TERMINAL false          # values: true/falses
bmk "Vec3 Readme"
# ==============================================================================
# Vec3 Math & Utility Library
# ==============================================================================
# Version: 1.1
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

bmk "Vec3 Calculations"

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
Vec3_magnitute:
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
Vec3_normalize:
    # --- Save parameters ---
    psh a1                              # | a1(dst)
    psh a0                              # | a1(dst) - a0(src)

    # --- Calculate magnitude ---
    cal Vec3_magnitute                  # a0 = |v|
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
Vec3_cross_product:
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
vec3_store_example:
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


bmk "Helper functions"

sbmk "function dokumentation"

## Functionality

## Params

## Output

sbmk "draw_float_on_screen"
## Functionality

## Params
# a0    :   start x coordinate
# a1    :   to draw float

## Output

sbmk "Parse Single Float"
## Functionality
# Converts the ASCII string at address a0 into a float

## Params:
# a0 = Address of the ASCII string (e.g., term_buffer)

## Output:
# a0 = Calculated float value

parse_single_float:
    mov t6, a0                          # t0 <- a0

    mov t1, 1.0                         # (1.0 = positive, -1.0 = negative)
    mov t2, 0.0                         # pre dot -Sum
    mov t3, 0.0                         # post dot -sum
    mov t4, 0.1                         # post dot, index (* 0.1, * 0.01, ...)
    mov t5, 0                           # 0 = pre dot mode, 1 = post dot mode

    # Check first character for sign
    cea t6, 0, 1
    lde u8t, t0, 0

    # Minus sign '-' (ASCII 45)
    cmp eq, t0, 45
    jfsa .digit_loop
    mov t1, -1.0
    add t6, t6, 1

.digit_loop:
    cea t6, 0, 1
    lde u8t, t0, 0

    # Terminate on null terminator (0), newline (10), or carriage return (13)
    cmp eq, t0, 0
    jtra .done
    cmp eq, t0, 10
    jtra .done
    cmp eq, t0, 13
    jtra .done

    # Decimal point '.' (ASCII 46)
    cmp eq, t0, 46
    jfsa .handle_num
    mov t5, 1                           # Switch to fractional (post-dot) mode
    add t6, t6, 1
    jmp .digit_loop

.handle_num:
    sub t0, t0, 48                      # ASCII ('0'..'9') to integer (0..9)
    fctf t0, t0                         # Int to float

    cmp eq, t5, 0
    jfsa .after_dot

    # --- Integer part (before decimal point) ---
    fmul t2, t2, 10.0
    fadd t2, t2, t0
    add t6, t6, 1
    jmp .digit_loop

.after_dot:
    # --- Fractional part (after decimal point) ---
    ffma t3, t0, t4, t3
    fmul t4, t4, 0.1
    add t6, t6, 1
    jmp .digit_loop

.done:
    fadd a0, t2, t3                     # Integer part + fractional part
    fmul a0, a0, t1                     # Apply sign
    ret


bmk "NN Basics"

msg_pred: emb string "Prediction:"

sbmk "predict_nn"
## Functionality

## Params

## Output
# a0 result of nn
predict_nn:

    # --- save ---
    psh s0
    psh s1
    psh s2

    # calc
    # --- input layer * hidden layer (1/3) ---

    mov a0,vecInput                     # a0    : source vec3 A address
    mov a1,vecHid1                      # a1    : source vec3 B address

    cal vec3_dot_product                # result -> a0
    mov s0,a0                           # save result a0 -> s0

    # --- input layer * hidden layer (2/3) ---
    mov a0,vecInput                     # a0    : source vec3 A address
    mov a1,vecHid2                      # a1    : source vec3 B address

    cal vec3_dot_product
    mov s1,a0                           # save result a0 -> s1

    # --- input layer * hidden layer (3/3) ---
    mov a0,vecInput                     # a0    : source vec3 A address
    mov a1,vecHid3                      # a1    : source vec3 B address

    cal vec3_dot_product
    mov s2,a0                           # save result a0 -> s2

    # --- RELU function ---
    # save results (s0-s2) in vecHidRes
    mov a0,s0
    mov a1,s1
    mov a2,s2

    mov a3,vecHidRes                    # save hidden layer result
    cal vec3_store

    mov a0,vecHidRes                    # a0        :   source vec3 (src)
    mov a1,vecHidRes                    # a1        :   destination vec3 (dst)

    cal relu_vec3                       # calc relu -> vecHidRes

    # --- hidden * output ---
    # result hidden in vecHidRes
    mov a0,vecHidRes                    # a0    : source vec3 A address
    mov a1,vecOut                       # a1    : source vec3 B address

    cal vec3_dot_product                # a0    : dot product scalar (float)
    cal hard_sigmoid                    # a0 -> sigmoid (0-1) -> a0

    psh a0                              # |a0

    #mov a0, msg_pred                    # print prediction message
    #syscall SYS_PRINT_LINE_STRING       # print

    pop a0                              # |     (a0)
    #syscall SYS_PRINT_LINE_FLOAT        # print result

    # --- pop ---
    pop s2
    pop s1
    pop s0

    ret
sbmk "Back Propagation *"

## Params:
# a0 = predicted value (y_hat)
# a1 = target value (y)

packprop_nn:

    # --- Output Layer Delta: delta_out = (y_hat - y) * 0.2 ---
    cal calc_delta                      # a0 = y_hat - y
    cal hard_sigmoid_backprop           # a0 = delta_out
    mov s0, a0                          # s0 = delta_out

    # --- Preserve Unmodified Output Weights (w_out) for Hidden Layer Deltas ---
    mov a0, vecOut
    cal vec3_load                       # a0=w_out.x, a1=w_out.y, a2=w_out.z
    mov s1, a0                          # s1 = old w_out.x
    mov s2, a1                          # s2 = old w_out.y
    mov s3, a2                          # s3 = old w_out.z

    # --- Update Output Weights: vecOut <- vecOut - (lr * delta_out) * vecHidRes ---
    mov a0, s0                          # a0 = delta_out
    mov a1, LEARNRATE                   # a1 = learning rate
    mov a2, vecOut                      # a2 = src old weights
    mov a3, vecHidRes                   # a3 = src inputs (hidden layer activations)
    mov a4, vecOut                      # a4 = dst updated weights
    cal update_vec3_weights

    # --- Hidden Layer 1 (vecHid1) Update ---
    mov a0, vecHidRes
    cal vec3_load_x                     # a0 = relu_result_1
    mov a2, a0                          # a2 = relu_result
    mov a0, s0                          # a0 = delta_out
    mov a1, s1                          # a1 = old w_out.x
    cal relu_backprop                   # a0 = delta_hid1

    mov a1, LEARNRATE
    mov a2, vecHid1                     # a2 = src old weights
    mov a3, vecInput                    # a3 = src network inputs
    mov a4, vecHid1                     # a4 = dst updated weights
    cal update_vec3_weights

    # --- Hidden Layer 2 (vecHid2) Update ---
    mov a0, vecHidRes
    cal vec3_load_y                     # a0 = relu_result_2
    mov a2, a0                          # a2 = relu_result
    mov a0, s0                          # a0 = delta_out
    mov a1, s2                          # a1 = old w_out.y
    cal relu_backprop                   # a0 = delta_hid2

    mov a1, LEARNRATE
    mov a2, vecHid2                     # a2 = src old weights
    mov a3, vecInput                    # a3 = src network inputs
    mov a4, vecHid2                     # a4 = dst updated weights
    cal update_vec3_weights

    # --- Hidden Layer 3 (vecHid3) Update ---
    mov a0, vecHidRes
    cal vec3_load_z                     # a0 = relu_result_3
    mov a2, a0                          # a2 = relu_result
    mov a0, s0                          # a0 = delta_out
    mov a1, s3                          # a1 = old w_out.z
    cal relu_backprop                   # a0 = delta_hid3

    mov a1, LEARNRATE
    mov a2, vecHid3                     # a2 = src old weights
    mov a3, vecInput                    # a3 = src network inputs
    mov a4, vecHid3                     # a4 = dst updated weights
    cal update_vec3_weights

    ret

sbmk "train step"

print_train: emb string "Train With values X,Y,Z,result"
print_res: emb string "actual result: "

## Function
# predicts, backprops and prints nn

## Params

train_nn:

    cal predict_nn
    cal packprop_nn
    cal print_nn

    ret

bmk "NN print & plot"
sbmk "nn boundary plot"

current_plot_y: emb i32t -10            # Start bei -10
## Functionality: Draws 3 component bar representations on LCD screen

## Params:
# a0    :   x start
# a1    :   y start

## Output:
nn_boundary_plot:


    mov a0,60                           # a0    :   x start
    mov a1,15                           # a1    :   y start
    # --- save ---
    psh s0
    psh s1
    psh s2
    psh s3
    psh s4
    #
    mov s2,a0                           # x start -> s2
    mov s3,a1                           # y start -> s3

    mov s1,-10                          # y

    # --- loop y ---
    # for y -10 -> 10
    .y_loop_draw_nn:
    mov s0,-10                          # x reset

    # --- loop x ---
    # for x -10 -> 10
    .x_loop_draw_nn:

    # --- nn predict ---
    fctf a0,s0                          # x for nn
    fctf a1,s1                          # y for nn
    mov a2,1.0
    mov a3,vecInput
    cal vec3_store

    cal predict_nn
    mov s4,a0

    # --- calc screen cords ---
    # PosX = s2 + (s0 + 10) * 10
    add t0, s0, 10                      # Grid-Index 0 .. 20
    mul t0, t0, 10                      # Pixel-Offset 0 .. 200 px
    add a0, s2, t0                      # a0 = Screen Pos X (200..400)

    sub t1, 10, s1                      # t1 = 10 - s1 (für y=10 -> 0; für y=-10 -> 20)
    mul t1, t1, 10
    add a1, s3, t1
    # --- draw box ---
    mov a2,s4# a2    : nn result value
    cal nn_draw_box

    # x++ check
    inc s0                              # x++
    cmp lt,s0,11                        # while x < 11 (-10 <-> 10)
    jtr .x_loop_draw_nn

    yield

    # y++ check
    inc s1
    cmp lt,s1,11
    jtr .y_loop_draw_nn


    # --- pop ---
    pop s4
    pop s3
    pop s2
    pop s1
    pop s0


    ret
sbmk "nn draw box"
## Functionality:
# each box 10pixel

## Params:
# a0    :   x start
# a1    :   y start
# a2    :   value (0.0-1.0 ; from sigmoid)

## Output:
nn_draw_box:

    # --- set luma ---
    ffma a4,a2,245.0,10.0                    # 255 * vlaue
    fcti a4,a4                          # float -> int
    clp a4,a4,0,255

    mov a2,10                           # width 10
    mov a3,10                           # height 10
    #Args: a0:pos_x, a1:pos_y, a2:size_x, a3:size_y, a4:luma
    syscall SYS_DRAW_RECT               # draw


    ret


sbmk "nn print"

nn_print:

    mov a1,vecInput
    mov a0,10
    cal vec3_draw_on_screen

    mov a1,vecHid1
    mov a0,60
    cal vec3_draw_on_screen

    mov a1,vecHid2
    mov a0,110
    cal vec3_draw_on_screen

    mov a1,vecHid3
    mov a0,160
    cal vec3_draw_on_screen

    mov a1,vecOut
    mov a0,210
    cal vec3_draw_on_screen
    ret


sbmk "print nn text"

print_line: emb string "=========================================="
print_input: emb string "input layer"
print_hid1: emb string "Hidden Layer 1/3"
print_hid2: emb string "Hidden Layer 2/3"
print_hid3: emb string "Hidden Layer 3/3"
print_output: emb string "output layer"

print_nn:

    mov a0,print_line                       # pretty line ===
    syscall SYS_PRINT_LINE_STRING

    mov a0,print_input                      # print Input layer
    syscall SYS_PRINT_LINE_STRING
    mov a0,vecInput
    cal vec3_print

    mov a0,print_hid1                       # print hidden layer 1/3
    syscall SYS_PRINT_LINE_STRING
    mov a0,vecHid1
    cal vec3_print

    mov a0,print_hid2                       # print hidden layer 2/3
    syscall SYS_PRINT_LINE_STRING
    mov a0,vecHid2
    cal vec3_print

    mov a0,print_hid3                       # print hidden layer 3/3
    syscall SYS_PRINT_LINE_STRING
    mov a0,vecHid3
    cal vec3_print

    mov a0,print_output                     # print output layer
    syscall SYS_PRINT_LINE_STRING
    mov a0,vecOut
    cal vec3_print

    mov a0,print_line                       # pretty line ===
    syscall SYS_PRINT_LINE_STRING
    ret




bmk "NN Dialog"

sbmk "plot state"
needs_redraw:   emb u32t 1              # 1 = neu zeichnen, 0 = fertig
sbmk "Data"

msg_start:       emb string "Welcome to this Neural Network"
msg_select_mode: emb string "Input:"
msg_option_1:    emb string " - 1: Training"
msg_option_2:    emb string " - 2: Inference / Using"

dialog:          emb u32t 0
state:           emb u32t 0

temp_pred:       emb f32t 0.0

msg_prompt_x:    emb string "Enter Input X:"
msg_prompt_y:    emb string "Enter Input Y:"
msg_prompt_res:  emb string "Enter Target Result (0.0 / 1.0):"
msg_done:        emb string "Successfully trained!"

sbmk "Set State"
## Params:
# a0 = new state ID
set_state:
    cea state, 0, 1
    ste u32t, 0, a0
    ret

sbmk "Set Dialog"
## Params:
# a0 = new dialog ID (0: Menu, 1: Train, 2: Use)
set_dialog:
    cea dialog, 0, 1
    ste u32t, 0, a0
    ret

sbmk "Router"
start_dialog:
    # 1. Read input from terminal into buffer
    mov a0, buffer
    mov a1, MAX_TERMINAL_INPUT_SIZE
    syscall SYS_READ_TERMINAL_INPUT

    # 2. Check active dialog mode
    cea dialog, 0, 1
    lde u32t, t0, 0

    cmp eq, t0, 0
    jtr dialog_menu

    cmp eq, t0, 1
    jtr dialog_train

    cmp eq, t0, 2
    jtr dialog_use

    ret

# ==========================================
# Sub-Dialog Routers
# ==========================================

sbmk "Menu Router"
dialog_menu:
    cea state, 0, 1
    lde u32t, t0, 0

    cmp eq, t0, 0
    jtr state_0

    cmp eq, t0, 1
    jtr state_1

    ret

sbmk "Train Router"
dialog_train:
    cea state, 0, 1
    lde u32t, t0, 0

    cmp eq, t0, 3
    jtr state_3

    cmp eq, t0, 4
    jtr state_4

    cmp eq, t0, 5
    jtr state_5

    ret

sbmk "Infer Router"
dialog_use:
    cea state, 0, 1
    lde u32t, t0, 0

    cmp eq, t0, 6
    jtr state_6

    cmp eq, t0, 7
    jtr state_7

    ret

bmk "Dialog States"
sbmk "State 0"
state_0:
    mov a0, msg_start
    syscall SYS_PRINT_LINE_STRING

    mov a0, msg_select_mode
    syscall SYS_PRINT_LINE_STRING

    mov a0, msg_option_1
    syscall SYS_PRINT_LINE_STRING

    mov a0, msg_option_2
    syscall SYS_PRINT_LINE_STRING

    mov a0, 1                           # Advance to State 1: wait for menu input
    cal set_state
    ret

sbmk "State 1"
state_1:
    mov a0, buffer
    cal parse_single_float              # Parse selection number
    fcti a0, a0                         # Convert float to integer in a0

    cmp eq, a0, 1                       # Option 1 -> Start Training Mode
    jtr start_train_flow

    cmp eq, a0, 2                       # Option 2 -> Start Inference Loop
    jtr start_use_flow

    ret

start_train_flow:
    mov a0, 1                           # Set dialog = 1 (Training)
    cal set_dialog

    mov a0, msg_prompt_x
    syscall SYS_PRINT_LINE_STRING

    mov a0, 3                           # Advance to State 3: Read X & Prompt Y
    cal set_state
    ret

start_use_flow:
    mov a0, 2                           # Set dialog = 2 (Inference)
    cal set_dialog

    mov a0, msg_prompt_x                # Directly ask for X
    syscall SYS_PRINT_LINE_STRING

    mov a0, 6                           # Advance to State 6: Read X & Prompt Y
    cal set_state
    ret

# --- Training Flow ---

sbmk "State 3"
state_3:
    mov a0, buffer
    cal parse_single_float              # Parse Input X

    cea vecInput, 0, 1
    ste f32t, vector.x, a0              # Store Input X

    mov a0, msg_prompt_y
    syscall SYS_PRINT_LINE_STRING

    mov a0, 4                           # Advance to State 4: Read Y & Prompt Target Result
    cal set_state
    ret

sbmk "State 4"
state_4:
    mov a0, buffer
    cal parse_single_float              # Parse Input Y

    cea vecInput, 0, 1
    ste f32t, vector.y, a0              # Store Input Y

    cea vecInput, 0, 1
    ste f32t, vector.z, 1.0             # Store Bias Z = 1.0

    mov a0, msg_prompt_res
    syscall SYS_PRINT_LINE_STRING

    mov a0, 5                           # Advance to State 5: Execute Training Step
    cal set_state
    ret

sbmk "State 5"
state_5:


    mov a0, msg_pred
    syscall SYS_PRINT_LINE_STRING

    mov a0, buffer
    cal parse_single_float              # Parse Target Result (y)
    mov s15, a0                         # s15 = Target value (y)

    cal predict_nn                      # a0 = Prediction (y_hat)
    syscall SYS_PRINT_LINE_FLOAT

    mov a1, s15                         # a1 = Target value (y)
    cal packprop_nn                     # Run backprop with a0 (y_hat) and a1 (y)


    # Reset dialog back to Main Menu
    mov a0, 0
    cal set_dialog
    mov a0, 0
    cal set_state
    # --- redraw ---
    mov t0, 1
    str u32t, needs_redraw, t0
    ret

# --- Inference Flow (Continuous Loop) ---

sbmk "State 6"
state_6:
    mov a0, buffer
    cal parse_single_float              # Read Input X

    cea vecInput, 0, 1
    ste f32t, vector.x, a0              # Store Input X

    mov a0, msg_prompt_y                # Ask for Input Y
    syscall SYS_PRINT_LINE_STRING

    mov a0, 7                           # Advance to State 7: Read Y & Predict
    cal set_state
    ret

sbmk "State 7"
state_7:
    mov a0, buffer
    cal parse_single_float              # Read Input Y

    cea vecInput, 0, 1
    ste f32t, vector.y, a0              # Store Input Y

    cea vecInput, 0, 1
    ste f32t, vector.z, 1.0             # Set Bias Z = 1.0

    mov a0, msg_pred
    syscall SYS_PRINT_LINE_STRING
    # Execute Prediction (prints result internally)
    cal predict_nn

    syscall SYS_PRINT_LINE_FLOAT

    # Immediately prompt for the next X (Loop)
    mov a0, msg_prompt_x
    syscall SYS_PRINT_LINE_STRING

    mov a0, 6                           # Set state back to 6 for the next run
    cal set_state
    ret

bmk "NN Functions"

sbmk "calc delta"
## Functionality

## Params
# a0        :   result
# a1        :   actual result

## Output
# a0        :   delta

calc_delta:

    fsub a0,a0,a1

    ret

sbmk "update weight"

## Functionality
# wNeu <- wAlt - (learnrate * delta(error)) * x(input)

## Params
# a0        :   backprop res / delta
# a1        :   learnrate
# a2        :   oldWeight
# a3        :   input x

# Output
# a0        :   delta
# a1        :   learnrate
# a2        :   newWeight

update_weight:

    fmul a3,a3,a1           # learnrate * x
    fneg a3,a3              # * -1
    ffma a2,a0,a3,a2        # (-[learnrate*x] * delta) + wOld

    ret

sbmk "update vec3 weights *"

## Functionality
# wNeu <- wAlt - (learnrate * delta(error)) * x(input)

## Params
# a0        :   backprop res / delta
# a1        :   Learnrate
# a2        :   oldWeight vec3 (source src)
# a3        :   input x vec3 (source src)
# a4        :   destination vec3 (dst)

# Output
update_vec3_weights:

    # --- save ---
    mov t0,a0                           # save delta
    mov t1,a2                           # save oldWeight vec3
    mov t2,a3                           # save input x vec3
    mov t3,a4                           # destination vec3

    # --- X ---
    # get x value
    mov a0,t1                           # get oldWeight vec3
    cal vec3_load_x
    mov a2,a0                           # a2        :   oldWeight

    mov a0,t2                           # get input x vec3
    cal vec3_load_x
    mov a3,a0                           # a3        :   input x

    mov a0,t0                           # a0        :   backprop res / delta
    mov a1,LEARNRATE                    # a1        :   learnrate

    cal update_weight                   # a2        :   newWeight
    # --- save updated weight ---
    mov a1,a4
    cal vec3_store_x                    # save x into new vec

    # --- Y ---
    # get y value
    mov a0,t1                           # get oldWeight vec3
    cal vec3_load_y
    mov a2,a0                           # a2        :   oldWeight

    mov a0,t2                           # get input x vec3
    cal vec3_load_y
    mov a3,a0                           # a3        :   input x

    mov a0,t0                           # a0        :   backprop res / delta
    mov a1,LEARNRATE                    # a1        :   learnrate

    cal update_weight                   # a2        :   newWeight
    # --- save updated weight ---
    mov a1,a4
    cal vec3_store_y                    # save y into new vec

    # --- Z ---
    # get z value
    mov a0,t1                           # get oldWeight vec3
    cal vec3_load_z
    mov a2,a0                           # a2        :   oldWeight

    mov a0,t2                           # get input x vec3
    cal vec3_load_z
    mov a3,a0                           # a3        :   input x

    mov a0,t0                           # a0        :   backprop res / delta
    mov a1,LEARNRATE                    # a1        :   learnrate

    cal update_weight                   # a2        :   newWeight
    # --- save updated weight ---
    mov a1,a4
    cal vec3_store_z                    # save z into new vec

    # result in dst vec3

    ret

bmk "NN Relu"

sbmk "Relu"

## Functionality

## Params
# a0    :   input

## Output
# a0    :   result
relu:
    # a0 input
    # if a0 < 0 a0 = 0

    fmax a0,a0,0.0              # max(0,X)
    ret

sbmk "Relu vec3"
## Functionality

## Params
# a0        :   source vec3 (src)
# a1        :   destination vec3 (dst)

## Output
relu_vec3:

    mov a3,a1                   # dst vec -> a3
    cal vec3_load               # loads source vec from a0

    fmax a0,a0,0.0              # max(0,X)
    fmax a1,a1,0.0              # max(0,X)
    fmax a2,a2,0.0              # max(0,X)
    cal vec3_store

    ret

sbmk "relu backprop"
## Params:
# a0 = deltaOut
# a1 = wOut
# a2 = relu_result

## Output:
# a0 = deltaHidden (Skalar)

relu_backprop:
    cmp fgt, a2, 0.0        # Is relu_result > 0.0?
    jfs .relu_inactive      # if no result/error = 0

    fmul a0, a0, a1         # if JA -> deltaHidden = deltaOut * wOut
    ret

.relu_inactive:
    mov a0, 0.0
    ret

bmk "NN Sigmoid"
sbmk "Sigmoid"

## Functionality
# 1/(1+e^z) = z

## Params
# a0    :   z

## Output
# a0    :   z

sigmoid:
    #a0
    ret

sbmk "Hard Sigmoid"

## Functionality
# hard-sigmoid(x): max(0.0,min(1.0, (0.2*z+0.5))

## Params
# a0    :   z

## Output
# a0    :   z
hard_sigmoid:

    # hard-sigmoid(x): max(0.0,min(1.0, (0.2*z+0.5))

    fmul a0,a0,0.2              # (0.2*z)
    fadd a0,a0,0.5              # x + 0.5

    fmin a0,1.0,a0              # min(1.0 , x)

    fmax a0,0.0,a0              # max(0.0 , x)

    ret


sbmk "Hard Sigmoid backprop"

## Functionality

## Params
# a0        :   delta

## Output
# a0        :   error value

hard_sigmoid_backprop:

    fmul a0,a0,0.2       # error * 0.2 =

    ret

sbmk "Hard Sigmoid vec3"

## Functionality

## Params
# a0        :   vec3 source
# a1        :   vec3 destination

## Output

hard_sigmoid_vec3:

    mov a3,a1                   # pre load destionation param for vec3_store
    cal vec3_load               # load x,y,z -> a0-a2

    # --- X ---
    fmul a0,a0,0.2              # (0.2*z)
    fadd a0,a0,0.5              # x + 0.5
    fmin a0,1.0,a0              # min(1.0 , x)
    fmax a0,0.0,a0              # max(0.0 , x)
    # --- Y ---
    fmul a1,a1,0.2              # (0.2*z)
    fadd a1,a1,0.5              # x + 0.5
    fmin a1,1.0,a1              # min(1.0 , x)
    fmax a1,0.0,a1              # max(0.0 , x)
    # --- Z ---
    fmul a2,a2,0.2              # (0.2*z)
    fadd a2,a2,0.5              # x + 0.5
    fmin a2,1.0,a2              # min(1.0 , x)
    fmax a2,0.0,a2              # max(0.0 , x)

    # --- store result ---
    cal vec3_store

    ret

bmk "Programm Globals"

sbmk "Global Vectors"

vecInput: res u8t vector.vector_size
# --- HIdden ---
vecHid1:  res u8t vector.vector_size
vecHid2:  res u8t vector.vector_size
vecHid3:  res u8t vector.vector_size

vecHidRes:res u8t vector.vector_size

vecOut:   res u8t vector.vector_size

bmk "Start "
_start:


     # 1. vecInput init
    mov a0, 1.0
    mov a1, -1.0
    mov a2, 1.0
    mov a3, vecInput
    cal vec3_store

    # 2. vecHid1 init
    mov a0, 1.0
    mov a1, -1.0
    mov a2, 0.0
    mov a3, vecHid1
    cal vec3_store

    # 3. vecHid2 init
    mov a0, -1.0
    mov a1, 1.0
    mov a2, 0.0
    mov a3, vecHid2
    cal vec3_store

    # 4. vecHid3 init
    mov a0, 0.0
    mov a1, 0.0
    mov a2, 1.0
    mov a3, vecHid3
    cal vec3_store


    # 5. vecOut init
    mov a0, -50.0
    mov a1, -50.0
    mov a2, 2.5
    mov a3, vecOut
    cal vec3_store

    # start dialog 1 time
    cal start_dialog
    cal nn_boundary_plot
    exit

bmk "Update"
_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit

bmk "Draw"
_draw: # Läuft mit 60 Hz[cite: 1]
    # 1. Back-Buffer erhalten (verhindert das Löschen bereits gezeichneter Zeilen)[cite: 1]
    syscall SYS_PRESERVE_BACK_BUFFER
    # --- plot nn --
    lod u32t, t0, needs_redraw          # Flag laden[cite: 1]
    cmp eq, t0, 1
    jfsa .no_redraw                     # Wenn nicht 1 -> überspringen[cite: 1]

    # --- reset flat ---
    mov t0, 0
    str u32t, needs_redraw, t0

    # --- replot ---
    cal nn_boundary_plot

    .no_redraw:
    exit                               # Frame beenden[cite: 1]

bmk "Input"
_input: # Runs when input state changes.
    # React to player input here.
    exit



bmk "Terminal Input"
_terminal_input:
    cal start_dialog

    exit
