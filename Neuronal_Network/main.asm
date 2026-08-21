#
#
#

bmk "Deritrives"

sbmk "buffer"
buffer: res u8t MAX_TERMINAL_INPUT_SIZE

bmk "Settings"

def LEARNRATE 0.1
def PRINT_NN_IN_TERMINAL false          # values: true/falses

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
draw_float_on_screen:


    mov a4, 80                          # set luma

    cmp flt,a1,0.0                      # if float < 0.0
    jtr .draw_float

    mov a4,255                          # if false (pos) set luma to 255
    .draw_float:

    fabs a3,a1                          # calc y height (depth)

    fmul a3,a3,10.0                     # mul by 10
    fcti a3,a3                          # convert to int

    cmp eq,a3,0                         # if value = 0, draw one pixel
    jfs .draw_not_0

    mov a3,1
    .draw_not_0:

    mov a1, 10                          # set y pos
    mov a2, 10                          # set x size

    # Args: a0:pos_x, a1:pos_y, a2:size_x, a3:size_y, a4:luma
    syscall SYS_DRAW_RECT
    ret

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


sbmk "vec3 read cea (storage)"
## Functionality
# loads the values x,y,z from a given vec a0 into a0-a2

## Params
# a0    :   vec3 (adress) to load

## Output
# a0-a2 :   values x,y,z
vec3_read:

    cea a0,0,1                          # load vec adress in a0
    lde f32t,a0,vector.x                # load vec.values into a0-a2
    lde f32t,a1,vector.y
    lde f32t,a2,vector.z

    ret


sbmk "vec3 writes cea (storage)"
## Functionality
# writes vec into cae

## Params
# a0-a2     :   values Vec A
# a3        :   vec3 A

## Output

vec3_write:

cea a3,0,1                              # load vec3 address in a3
    ste f32t,vector.x,a0                # write a0-a2 into vec
    ste f32t,vector.y,a1
    ste f32t,vector.z,a2

    ret

bmk "vec3 Advanced"

sbmk "vec 3 read cea 2vec"
## Functionality
# loads the values x,y,z from a given vec a0 into a0-a2

## Params
# a0    :   vec3 (adress) to load
# a1    :   vec3 (adress) to load

## Output
# a0-a2 :   values x,y,z
# a3-a5 :   values x,y,z
vec3_read_2:

    psh a0                              # |a0

    mov a0,a1                           # move to load adress -> a0
    cea a0,0,1                          # load Vec B
    lde f32t,a3,vector.x                # load vec B values -> a3-a5
    lde f32t,a4,vector.y
    lde f32t,a5,vector.z

    pop a0                              # |     (a0)
    cea a0,0,1                          # load Vec A
    lde f32t,a0,vector.x                # load Vec A values -> a0-a2
    lde f32t,a1,vector.y
    lde f32t,a2,vector.z

    ret

sbmk "vec3 writes cea 2"
## Functionality
# writes vec into cae

## Params
# a0-a2     :   values Vec A
# a3-a5     :   values Vec B
# a6        :   vec3 A
# a7        :   vec3 B

## Output
vec3_write_2:

    cea a6,0,1                          # read Vec A
    ste f32t,vector.x,a0                # vec A x -> a0
    ste f32t,vector.y,a1                # Vec A y -> a1
    ste f32t,vector.z,a2                # Vec A z -> a2

    cea a7,0,1                          # read Vec B
    ste f32t,vector.x,a3                # Vec B x -> A3
    ste f32t,vector.y,a4                # Vec B y -> A4
    ste f32t,vector.z,a5                # Vec B z -> A5

    ret

bmk "Vec3 Calculations"
sbmk "vec3 dot product"
## Functionality
# calculates the dot product of 2 vectors

## Params
# a0-a2 : Vec A
# a3-a5 : Vec B

## Output
# a0    : single value representing dot product of both vectors

vec3_dot_product:
    vffma a0..a2,a0..,a3..,zr           # mutiplaying A.X * B.X -> A.X ...

    fadd a0,a0,a1                       # X+Y -> A.X (a0)
    fadd a0,a0,a2                       # (X+Y) + Z -> A.X (a0)

    ret

sbmk "vec3 magnitute"
#(v-length)

## Functionality
# sqrt(x^2 + y^2 + z^2) = sqrt(v*v)

## Params
# a0-a2 :   Vec

## Output
# a0    :   magnitute / lenght of vector

Vec3_magnitute:
    fmul t0, a0, a0                     # X*X
    ffma t0,a1,a1,t0                    # Y*Y + (x^2)
    ffma a0,a2,a2,t0                    # Z*Z + (x^2 + y^2)
    fsqrt a0, a0                        # sqrt()
    ret

sbmk "vec3 normalize"

## Functionality
# v / |v| = ^v

## Params
# a0-a2 :   Vec A

## Output
# a0-a2    :   returns normalized Vec A
Vec3_normalize:

    # Save Vec A
    psh a0                              # |a0
    psh a1                              # |a0-a1
    psh a2                              # |a0-a1-a2

    # calc Vec A magnitude
    cal Vec3_magnitute
    mov t0,a0                           # magnitute result -> t0

    # restore Vec A
    pop a2                              # |a0-a1    (a2)
    pop a1                              # |a0       (a1)
    pop a0                              # |         (a0)

    # normalize each value
    fdiv a0, a0, t0                     #add = div / sor    x/x^
    fdiv a1, a1, t0                     #                   y/y^
    fdiv a2, a2, t0                     #                   z/z^

    ret

sbmk "vec3 cross product"
## Functionality
# ( A.Y * B.Z) - (B.Y * A.Z) -> C.X
# ( A.Z * B.X) - (B.Z * A.X) -> C.Y
# ( A.X * B.Y) - (B.X * A.Y) -> C.Z

## Params
# a0-a2 :   Vec A
# a3-a5 :   Vec B

## Output
# a0-a2 :   Vec C (A x B)

Vec3_cross_product:

    mov t3,a0                           # a0 -> t3 (x)
    mov t4,a1                           # a1 -> t4 (y)
    mov t5,a2                           # a2 -> t5 (z)

    # X
    # ( A.Y * B.Z) - (B.Y * A.Z) -> C.X
    fmul t0,t4,a5                       # ( A.Y * B.Z)
    fmul t1,a4,t5                       # (B.Y * A.Z)

    fsub a0,t0,t1                       # X = () - ()

    # Y
    # ( A.Z * B.X) - (B.Z * A.X) -> C.Y
    fmul t0,t5,a3                       # ( A.Z * B.X)
    fmul t1,a5,t3                       # (B.Z * A.X)

    fsub a1,t0,t1                       # Y = () - ()

    # Z
    # ( A.X * B.Y) - (B.X * A.Y) -> C.Z
    fmul t0,t3,a4                       # ( A.X * B.Y)
    fmul t1,a3,t4                       # (B.X * A.Y)

    fsub a2,t0,t1                       # Z = () - ()

    ret

bmk "Vec3 Extra / Help"

sbmk "vec3 create example"
# vec-name: res u8t vector.vector_size (allowcates vector size storage for vec)
# vec.0 = vec(address, for example 100) + x (0) = 100
# for y and z its then vec(100) + y (4) = 104.. leading to the correct address where
# x, y or z are stored
vec3_example: res u8t vector.vector_size

sbmk "vec3 read value exmaple"
# or use the vec3 read cea function ;)
vec3_read_example:

    cea a0,0,1                          # a0 = vec adress
    lde f32t,a0,vector.x                # load x into a0

    ret

sbmk "vec3 swizzle"
## Functionality:
# Re-positions vector
# Encoding per component (2 bits):
# 00 = 0.0 (zero)
# 01 = x
# 10 = y
# 11 = z

## Params:
# a0    : pointer to vec3
# a1    : binary mask (e.g. 0b11_10_01 for z, y, x)

## Output:
# a0    : new x
# a1    : new y
# a2    : new z
vec3_swizzle:
    mov a3, a1                          # Save mask in a3
    cal vec3_read                       # a0 (ptr) -> loads a0=x, a1=y, a2=z

    # --- New X (Bits 1..0) ---
    cal swizzle_single                  # Result in a4
    psh a4                              # Push new X to stack

    # --- New Y (Bits 3..2) ---
    cal swizzle_single                  # Result in a4
    psh a4                              # Push new Y to stack

    # --- New Z (Bits 5..4) ---
    cal swizzle_single                  # Result in a4
    mov a2, a4                          # a2 = new Z

    # --- Restore X and Y in correct registers ---
    pop a1                              # pop into a1 = new Y
    pop a0                              # pop into a0 = new X

    ret

sbmk "swizzle single"
## Helper: Extracts lowest 2 bits from a3, sets a4, and shifts a3 right by 2
## Params:
# a0    : original x
# a1    : original y
# a2    : original z
# a3    : bitmask (shifted by 2 on return)
## Output:
# a4    : selected value (0.0, x, y, or z)
swizzle_single:
    and a4, a3, 3                       # get 2 lowest bits 0b00_00_[11]
    sar a3, a3, 2                       # >> mask for the next component

    cmp eq, a4, 0
    jtr .swizzle_00

    cmp eq, a4, 1
    jtr .swizzle_01

    cmp eq, a4, 2
    jtr .swizzle_10

    # else: for 3 (0b11)
    mov a4, a2                          # 11 -> z
    ret

.swizzle_00:
    mov a4, 0.0                         # 00 -> 0.0
    ret

.swizzle_01:
    mov a4, a0                          # 01 -> x
    ret

.swizzle_10:
    mov a4, a1                          # 10 -> y
    ret

sbmk "vec3 write value example"
vec3_write_example:
    cea a0,0,1                          # a0 = vec adress
     ste f32t,vector.x,a5               # a5 = new value (vector.x/.y/.z depending on which value)


sbmk "vec3_draw_on_screen"
## Functionality
# draws a vec3 on the (lcd) screen, starting from x, and y is the "value" of the float

## Params
# a0    :   start x coordinate
# a1    :   to draw vector (address)

## Output

vec3_draw_on_screen:

    mov t0,a0

    mov a0,a1                           # vec address in a0, for param cal
    cal vec3_read                       # get values
    psh a2                              # |a2
    psh a1                              # |a2-a1


    mov a1,a0
    mov a0,t0
    cal draw_float_on_screen

    add t0,t0,15
    mov a0,t0
    pop a1                              # |a2-  (a1)
    cal draw_float_on_screen

     add t0,t0,15
    mov a0,t0
    pop a1                              # |     (a2)
    cal draw_float_on_screen
    ret



sbmk "vec3 print"

print_x: emb string "X: "
print_y: emb string "Y: "
print_z: emb string "Z: "

## Functionality

## Params
# a0    :     vec3

## Output

vec3_print:

    psh a0

    mov a0,print_x
    syscall SYS_PRINT_STRING

    pop a0
    cal vec3_read

    syscall SYS_PRINT_LINE_FLOAT

    mov a0,print_y
    syscall SYS_PRINT_STRING
    mov a0,a1
    syscall SYS_PRINT_LINE_FLOAT

    mov a0,print_z
    syscall SYS_PRINT_STRING
    mov a0,a2
    syscall SYS_PRINT_LINE_FLOAT
    ret


sbmk "Vec3 x Matrix"
sbmk "Matrix x Matrix"


bmk "Matrix"

sbmk "create 1 * 8 matrix"

def MAT1X8_ROWS 8
def MAT1X8_SIZE (MAT1X8_ROWS * 4)   # 8 * 4 = 28 Bytes

mat1x8_get_row:
    # ea = a0 + (a1 * 12) -> jumps to coord
    cea a0, a1, vector.vector_size
    lde f32t,a0,0
    ret

mat1x8_set_row:
    cea a0, a1, 0
    ste f32t, 0, a0
    ret

sbmk "Mat 8x3"

def MAT8X3_ROWS 8
def MAT8X3_SIZE (MAT8X3_ROWS * vector.vector_size)   # 8 * 12 = 96 Bytes

# ------------------------------------------------------------------------------
# Liest eine Zeile (3 Floats) aus einer Matrix
# Input:
#   a0 = Basisadresse der Matrix (z. B. my_matrix)
#   a1 = Zeilenindex (0 bis 7)
# Output:
#   a0..a2 = Werte [x, y, z] dieser Zeile
# ------------------------------------------------------------------------------
mat8x3_get_row:
    # ea = a0 + (a1 * 12) -> springt exakt zur gewünschten Zeile
    cea a0, a1, vector.vector_size

    lde f32t, t0, vector.x
    lde f32t, a1, vector.y
    lde f32t, a2, vector.z
    mov a0, t0
    ret

# ------------------------------------------------------------------------------
# Schreibt eine Zeile (3 Floats) in eine Matrix
# Input:
#   a0..a2 = Werte [x, y, z]
#   a3     = Basisadresse der Matrix
#   a4     = Zeilenindex (0 bis 7)
# ------------------------------------------------------------------------------
mat8x3_set_row:
    cea a3, a4, vector.vector_size

    ste f32t, vector.x, a0
    ste f32t, vector.y, a1
    ste f32t, vector.z, a2
    ret

bmk "NN Basics"

msg_pred: emb string "Prediction:"

sbmk "predict_nn"
## Functionality
# uses s0-s7

## Params
# s0 input vec
# s1 hid layer vec 1/3
# s2 hid layer vec 2/3
# s3 hid layer vec 3/3
# s4 output layer
# s5-s7 hidden layer result (after relu)

## Output
# a0 result of nn
#
# s0 input vec
# s1 hid layer vec 1/3
# s2 hid layer vec 2/3
# s3 hid layer vec 3/3
# s4 output layer
# s5-s7 hidden layer result (after relu)
predict_nn:

    mov s0,vecInput   # input vec
    mov s1,vecHid1   # hidden layer 1 vec 1/3
    mov s2,vecHid2   # hidden layer 1 vec 2/3
    mov s3,vecHid3   # hidden layer 1 vec 3/3
    mov s4,vecOut   # output layer

    # calc
    # input layer * hidden layer1

    mov a0,s0                           # vec3 A
    mov a1,s1                           # vec3 B

    # input * hidden layer
    cal vec3_read_2
    cal vec3_dot_product                # result in a0  (1/3)
    mov s5,a0

    mov a0,s0
    mov a1,s2                           # (2/3)
    cal vec3_read_2
    cal vec3_dot_product
    mov s6,a0

    mov a0,s0
    mov a1,s3                           # (3/3)
    cal vec3_read_2
    cal vec3_dot_product
    mov s7,a0

    # Relu for each value s5 - s7
    mov a0,s5
    mov a1,s6
    mov a2,s7
    cal relu_vec3
    mov s5,a0
    mov s6,a1
    mov s7,a2


    # hidden * output                   # start preparing for dot product
    mov a0,s4                           # add vec hidden -> a0
    cal vec3_read                       # vec B (hidden layer) -> a0-a2

    mov a3,s5                           # vec A.X -> a3 (output layer)..
    mov a4,s6                           # vec A.Y -> s4
    mov a5,s7                           # vec A.Z -> s5

    cal vec3_dot_product                # calc dot product -> a0
    cal hard_sigmoid                    # a0 -> sigmoid (0-1) -> a0

    psh a0                              # |a0

    mov a0, msg_pred                    # print prediction message
    syscall SYS_PRINT_LINE_STRING       # print

    pop a0                              # |     (a0)
    psh a0                              # |a0
    syscall SYS_PRINT_LINE_FLOAT        # print result
    pop a0                              # |     (a0)

    ret


    ret

sbmk "Back Propagation"

## Params
# a0 = result (predicted value y_hat)
# a1 = actual result (target value y)

packprop_nn:
    # 1. Calculate output delta: delta_out = (y_hat - y) * 0.2
    cal calc_delta                      # a0 = y_hat - y
    cal hard_sigmoid_backprop           # a0 = delta_out
    mov s9, a0                          # Save delta_out to s9

    # 2. Save old output weights (needed for hidden layer backpropagation)
    mov a0, s4
    cal vec3_read                       # a0..a2 = old w_out
    mov s10, a0                         # old w_out.x
    mov s11, a1                         # old w_out.y
    mov s12, a2                         # old w_out.z

    # 3. Update Output Layer (vecOut)
    mov a0, s9                          # delta_out
    mov a1, LEARNRATE
    mov a2, s10                         # oldWeight x
    mov a3, s11                         # oldWeight y
    mov a4, s12                         # oldWeight z
    mov a5, s5                          # input x (ReLU intermediate value 1)
    mov a6, s6                          # input y (ReLU intermediate value 2)
    mov a7, s7                          # input z (ReLU intermediate value 3)
    cal update_vec3_weights             # returns new weights in a0..a2
    mov a3, s4                          # Destination address to a3
    cal vec3_write

    # 4. Load original inputs from vecInput (remain identical for all 3 hidden updates)
    mov a0, s0
    cal vec3_read
    mov s13, a0                         # s13 = in.x
    mov s14, a1                         # s14 = in.y
    mov s15, a2                         # s15 = in.z

    # --- Hidden Layer 1/3 (vecHid1) ---
    mov a0, s9                          # delta_out
    mov a1, s10                         # old w_out.x
    mov a2, s5                          # ReLU result 1
    cal relu_backprop                   # a0 = delta_hid1

    psh a0                              # Briefly push delta_hid1 onto the stack
    mov a0, s1
    cal vec3_read                       # a0=X, a1=Y, a2=Z
    mov a4, a2                          # a4 = Z first!
    mov a3, a1                          # a3 = Y
    mov a2, a0                          # a2 = X
    pop a0                              # Restore delta_hid1
    mov a1, LEARNRATE
    mov a5, s13                         # in.x
    mov a6, s14                         # in.y
    mov a7, s15                         # in.z
    cal update_vec3_weights
    mov a3, s1                          # Destination address to a3
    cal vec3_write

    # --- Hidden Layer 2/3 (vecHid2) ---
    mov a0, s9
    mov a1, s11                         # old w_out.y
    mov a2, s6
    cal relu_backprop                   # a0 = delta_hid2

    psh a0
    mov a0, s2
    cal vec3_read                       # a0=X, a1=Y, a2=Z
    mov a4, a2                          # a4 = Z first!
    mov a3, a1                          # a3 = Y
    mov a2, a0                          # a2 = X
    pop a0
    mov a1, LEARNRATE
    mov a5, s13
    mov a6, s14
    mov a7, s15
    cal update_vec3_weights
    mov a3, s2
    cal vec3_write

    # --- Hidden Layer 3/3 (vecHid3) ---
    mov a0, s9
    mov a1, s12                         # old w_out.z
    mov a2, s7
    cal relu_backprop                   # a0 = delta_hid3

    psh a0
    mov a0, s3
    cal vec3_read                       # a0=X, a1=Y, a2=Z
    mov a4, a2                          # a4 = Z first!
    mov a3, a1                          # a3 = Y
    mov a2, a0                          # a2 = X
    pop a0
    mov a1, LEARNRATE
    mov a5, s13
    mov a6, s14
    mov a7, s15
    cal update_vec3_weights
    mov a3, s3
    cal vec3_write

    ret

sbmk "train step"

print_train: emb string "Train With values X,Y,Z,result"
print_res: emb string "actual result: "

## Function
# predicts, backprops and prints nn

## Params
# s0 input vec
# s1 hid layer vec 1/3
# s2 hid layer vec 2/3
# s3 hid layer vec 3/3
# s4 output layer
# s5-s7 hidden layer result (after relu)

train_nn:

    cal predict_nn
    cal packprop_nn
    cal print_nn

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

bmk "NN Dialog"
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
    mov a0, buffer
    cal parse_single_float              # Parse Target Result (y)
    mov s15, a0                         # s15 = Target value (y)

    # 1. Forward Pass
    cal predict_nn                      # a0 = Prediction (y_hat)

    # 2. Backpropagation
    mov a1, s15                         # a1 = Target value (y)
    cal packprop_nn                     # Run backprop with a0 (y_hat) and a1 (y)

    # 3. Optional Debug Print
    cmp eq, PRINT_NN_IN_TERMINAL, true
    jfs .skip_print
    cal print_nn
.skip_print:

    mov a0, msg_done
    syscall SYS_PRINT_LINE_STRING

    # Reset dialog back to Main Menu
    mov a0, 0
    cal set_dialog
    mov a0, 0
    cal set_state
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

    # Execute Prediction (prints result internally)
    cal predict_nn

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

sbmk "update vec3 weights"

## Functionality
# wNeu <- wAlt - (learnrate * delta(error)) * x(input)

## Params
# a0        :   backprop res / delta
# a1        :   Learnrate
# a2-a4     :   oldWeight
# a5-a7     :   input x

# Output
# a0-a2     :   new Weights
update_vec3_weights:

    # X
    # a0 stays delta
    mov a1,LEARNRATE
    # a2 allready correct
    psh a3                      # |a3

    mov a3,a5
    cal update_weight
    mov t0,a2                   # result in a2

    # Y
    # a0,a1 stay
    pop a2                      # |     (a3)
    psh t0                      # |t0[x]
    mov a3,a6                   # set param a3 for cal
    cal update_weight
    psh a2                      # |t0[x]-a2[y]

    # Z
    # a0,a1 stay
    mov a2,a4                   # load param a2 for cal
    mov a3,a7                   # load param a3 for cal
    cal update_weight           # a2 (z)

    pop a1                      # |t0[x]    (a2[y])
    pop a0                      # |     (t0[x])

    ret

bmk "NN Relu"

sbmk "Relu vec3"
    ## Functionality

    ## Params
    # a0-a2    :   input values

    ## Output
    # a0-a2    :   result values
relu_vec3:

    fmax a0,a0,0.0              # max(0,X)
    fmax a1,a1,0.0              # max(0,X)
    fmax a2,a2,0.0              # max(0,X)
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
# a0-a2     :   input values

## Output
# a0-a2     :   output values

hard_sigmoid_vec3:

    psh a0              # |a0
    psh a1              # |a0-a1

    mov a0,a2
    cal hard_sigmoid    # sigmoid of a2
    mov a2,a0

    pop a0              # |a0   (a1)
    cal hard_sigmoid    # sigmoid of a1
    mov a1,a0

    pop a0              # |     (a0)
    cal hard_sigmoid    # sigmoid of a0
    ret

bmk "Programm Globals"

sbmk "Global Vectors"

vecInput: res u8t vector.vector_size
vecHid1:  res u8t vector.vector_size
vecHid2:  res u8t vector.vector_size
vecHid3:  res u8t vector.vector_size
vecOut:   res u8t vector.vector_size

bmk "Start "
_start:
     # 1. vecInput init
    mov a0, 1.0
    mov a1, -1.0
    mov a2, 1.0
    mov a3, vecInput
    cal vec3_write

    # 2. vecHid1 init
    mov a0, 1.0
    mov a1, -1.0
    mov a2, 0.0
    mov a3, vecHid1
    cal vec3_write

    # 3. vecHid2 init
    mov a0, -1.0
    mov a1, 1.0
    mov a2, 0.0
    mov a3, vecHid2
    cal vec3_write

    # 4. vecHid3 init
    mov a0, 0.0
    mov a1, 0.0
    mov a2, 1.0
    mov a3, vecHid3
    cal vec3_write

    # 5. vecOut init
    mov a0, -50.0
    mov a1, -50.0
    mov a2, 2.5
    mov a3, vecOut
    cal vec3_write

    # start dialog 1 time
    cal start_dialog

    exit


bmk "Update"
_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit

bmk "Draw"
_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.

    # get vectors:

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


    exit

bmk "Input"
_input: # Runs when input state changes.
    # React to player input here.

    exit



bmk "Terminal Input"
_terminal_input:
    cal start_dialog

    exit
