
bmk "Readme"
# How to use the libary
#
# the libary is designed to make vector usage simple
#
# there are examples of
# - how to create a vector
# - how to access a vector.value
#
# other then that, read the Params and Output for each
# function carefully since some might feel "unintuitive"
# - like write vec3, wherea address is param a3..
# - allowing to read vec3 (a0-a2) -> write (a0-a2) tho
# - withouth swapping all the values
#
# there is also an vec3_tmp "storage" per default givin in this libary allowing for
# temporarily saving a result to it and then reading the values via vec3_read
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
## Functionality
# loads the values x,y,z from a given vec a0 into a0-a2
# into c ea

## Params
# a0    :   source vec3 to load

## Output
# a0-a2 :   values x,y,z
vec3_load:

    cea a0,0,1                          # load vec adress in a0
    lde f32t,a0,vector.x                # a0 -> x
    lde f32t,a1,vector.y                # a1 -> y
    lde f32t,a2,vector.z                # a2 -> z

    ret

sbmk "vec3 store"
## Functionality
# stores vec3 into c ae

## Params
# a0-a2     :   x,y,z
# a3        :   dest vec3

## Output
vec3_store:

cea a3,0,1                              # load vec3 address in a3
    ste f32t,vector.x,a0                # write a0-a2 into vec
    ste f32t,vector.y,a1
    ste f32t,vector.z,a2

    ret

sbmk "vec3 copy"
## Functionality
# copys vec from addr a -> addr b

## Params
# a0    :   source vec3 address
# a1    :   destination vec3 address

## Output
vec3_copy:

    mov a3,a1
    cal vec3_load
    cal vec3_store

    ret

bmk "vec3 Advanced"

sbmk "vec3 load 2"
## Functionality
# loads the values x,y,z from a given vec a0 into a0-a2

## Params
# a0    :   source vec3 A (adress) to load
# a1    :   source vec3 B (adress) to load

## Output
# a0-a2 :   A(x,y,z)
# a3-a5 :   B(x,y,z)
vec3_load_2:

    psh a0                              # |a0(vec A)

    # --- Load vec3 B ---
    mov a0,a1                           # move to load adress -> a0
    cea a0,0,1                          # load Vec B
    lde f32t,a3,vector.x                # load vec B values -> a3-a5
    lde f32t,a4,vector.y
    lde f32t,a5,vector.z

    # --- Load vec3 A ---
    pop a0                              # |     [a0(vec A)]
    cea a0,0,1                          # load Vec A
    cal vec3_load                       # load a0-a2 into cae

    ret

sbmk "vec3 store 2"
## Functionality
# writes 2 vec into cae

## Params
# a0-a2     :   values Vec A
# a3-a5     :   values Vec B
# a6        :   vec3 A
# a7        :   vec3 B

## Output
vec3_store_2:

    # --- store Vec A ---
    cea a6,0,1                          # load vec A address
    cal vec3_store

    # --- store Vec B ---
    cea a7,0,1                          # load vec B address
    ste f32t,vector.x,a3                # Vec B x -> A3
    ste f32t,vector.y,a4                # Vec B y -> A4
    ste f32t,vector.z,a5                # Vec B z -> A5

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
# a2    : destination vec3 addr

## Output:
vec3_swizzle:

    # --- Save ---
    mov a3,a1                           # mask (a1) -> a3
    psh a2                              # |a2(dest add)
    cal vec3_load                       # a0 (ptr) -> loads a0=x, a1=y, a2=z

    # --- swizzle X ---
    cal swizzle_single                  # Result in a4
    psh a4                              # |a2(dest)-a4(x)

    # -- swzizzle Y ---
    cal swizzle_single                  # Result in a4
    psh a4                              # |a2(dest)-a4(x)-a4(y)

    # --- swizzle Z ---
    cal swizzle_single                  # Result in a4
    mov a2, a4                          # a2 = new Z

    # restor x and y in old regs
    pop a1                              # |a2(dest)-a4(x)   a4(y)
    pop a0                              # |a2(dest)     a4(x)

    # --- write to dest ---
    pop a3                              # |     a2(dest)
    cal vec3_store                      # save xyz in dest addr

    mov a2,a3                           # a3(dest) -> a2
    ret

bmk "Vec3 Calculations"
sbmk "vec3 dot product"
## Functionality
# calculates the dot product of 2 vectors

## Params
# a0    : source vec3 A
# a1    : source vec3 B

## Output
# a0    : single value representing dot product of both vectors

vec3_dot_product:

    # --- load  ---
    mov a6,a0
    mov a7,a1
    cal vec3_load_2

    # ---  ---
    vffma a0..a2,a0..,a3..,zr           # mutiplaying A.X * B.X -> A.X ...

    fadd a0,a0,a1                       # X+Y -> A.X (a0)
    fadd a0,a0,a2                       # (X+Y) + Z -> A.X (a0)

    ret

sbmk "vec3 magnitute"
## Functionality
# sqrt(x^2 + y^2 + z^2) = sqrt(v*v)
#(v-length)

## Params
# a0    :   source vec3

## Output
# a0    :   magnitute / lenght of vector

Vec3_magnitute:

    # --- load source vec ---
    cal vec3_load

    # --- calc magnitute  ---
    fmul t0, a0, a0                     # X*X
    ffma t0,a1,a1,t0                    # Y*Y + (x^2)
    ffma a0,a2,a2,t0                    # Z*Z + (x^2 + y^2)
    fsqrt a0, a0                        # sqrt()

    ret

sbmk "vec3 normalize"
## Functionality
# v / |v| = ^v

## Params
# a0        :   source vec3
# a1        :   dest vec3

## Output
# a0-a2     :   returns normalized Vec A
Vec3_normalize:

    # --- Save source vec3 ---
    psh a1                              # |a1(dest)
    psh a0                              # |a1(dest)-a0(source)

    # --- calc magnitude ---
    cal Vec3_magnitute
    mov t0,a0                           # magnitute result -> t0

    # --- load source vec3 ---
    pop a0                              # |a1(dest)     [a0(source)]

    # --- Normalize each value ---
    fdiv a0, a0, t0                     #add = div / sor    x/x^
    fdiv a1, a1, t0                     #                   y/y^
    fdiv a2, a2, t0                     #                   z/z^

    # --- store result ---
    pop a3                              # |     [a1(dest)]
    cal vec3_store

    ret

sbmk "vec3 cross product"
## Functionality
# ( A.Y * B.Z) - (B.Y * A.Z) -> C.X
# ( A.Z * B.X) - (B.Z * A.X) -> C.Y
# ( A.X * B.Y) - (B.X * A.Y) -> C.Z

## Params
# a0    :   source vec3 A
# a1    :   source vec3 B
# a2    :   dest vec3

## Output

Vec3_cross_product:

    # --- load vec3 A and B ---
    cal vec3_load_2                     # a0-a5 vec A/B values

    # --- save vec3 B to t3-t5 ---
    mov t3,a0                           # a0 -> t3 (x)
    mov t4,a1                           # a1 -> t4 (y)
    mov t5,a2                           # a2 -> t5 (z)

    # --- X: ( A.Y * B.Z) - (B.Y * A.Z) -> C.X ---
    fmul t0,t4,a5                       # ( A.Y * B.Z)
    fmul t1,a4,t5                       # (B.Y * A.Z)

    fsub a0,t0,t1                       # X = () - ()

    # --- Y: ( A.Z * B.X) - (B.Z * A.X) -> C.Y ---
    fmul t0,t5,a3                       # ( A.Z * B.X)
    fmul t1,a5,t3                       # (B.Z * A.X)

    fsub a1,t0,t1                       # Y = () - ()

    # --- Z: ( A.X * B.Y) - (B.X * A.Y) -> C.Z ---
    fmul t0,t3,a4                       # ( A.X * B.Y)
    fmul t1,a3,t4                       # (B.X * A.Y)

    fsub a2,t0,t1                       # Z = () - ()

    ret

bmk "Vec3 examples"

sbmk "vec3 create"
# vec-name: res u8t vector.vector_size (allowcates vector size storage for vec)
# vec.0 = vec(address, for example 100) + x (0) = 100
# for y and z its then vec(100) + y (4) = 104.. leading to the correct address where
# x, y or z are stored
vec3_example: res u8t vector.vector_size

sbmk "vec3 read value"
# or use the vec3 read cea function ;)
vec3_read_example:

    cea a0,0,1                          # a0 = vec adress
    lde f32t,a0,vector.x                # load x into a0

    ret




sbmk "vec3 write value"
vec3_write_example:
    cea a0,0,1                          # a0 = vec adress
     ste f32t,vector.x,a5               # a5 = new value (vector.x/.y/.z depending on which value)




bmk "Vec3 draw/print"
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
    cal vec3_load                       # get values
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
    cal vec3_load

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

bmk "vec3 helper functions"

sbmk "vec3 tmp"

vec3_tmp: res u8t vector.vector_size

sbmk "swizzle single"
## Helper: Extracts lowest 2 bits from a3, sets a4, and shifts a3 right by 2

## Params:
# a0    : original x
# a1    : original y
# a2    : original z
# a3    : bitmask

## Output:
# a0    : original x
# a1    : original y
# a2    : original z
# a3    : bitmask (shifted 2 >> on return)
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

bmk "vec3 end"
