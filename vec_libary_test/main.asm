

bmk "Includes"

include "../vec_libary/main.asm"

include "../test_lib/main.asm"



tmpVec: res u8t vector.vector_size

bmk "Test_help"


sbmk "assert eq vec3 single value"

# Params
## a0 : vec A
## a1 : vec B
## a2 : function to call (vec3_load_x...)

# Function
## returns wether the values are the same ( true/false)

assert_eq_vec3_single_value:

    # === Store Values ===
    psh s0                              # | (s0)
    psh s1                              # | s0-(s1)
    psh s2                              # | s0-s1-(s2)

    mov s0,a0                           # s0 <- vec A
    mov s1,a1                           # s1 <- vec B
    mov s2,a2                           # s2 <- function to call

    # === get value ===

    # xyz value from A
    mov a0,s0
    cala s2                             # call load_x_y_or_z function
    # result in a0
    mov s0,a0                           # vec A <- xyz. vec A

    # xyz value from B
    mov a0,s1
    cala s2
    mov s1,a0
    # === Compare ===

    mov a0,s0
    mov a1,s1
    cal assert_eq

    # === Load Values ===
    pop s2                              # | s0-s1-[s2]
    pop s1                              # | s0-[s1]
    pop s0                              # | [s0]

    ret


sbmk "assert eq vec3"

txt_test_vec3_x: emb string " - X "
txt_test_vec3_y: emb string " - Y "
txt_test_vec3_z: emb string " - Z "

# Params
## a0:  vec add (is)
## a1:  vec add (should)

#Funktion
## Returns [ Correct / Error (is) (should) ]

assert_eq_vec3:

    # === Save Values ===
    psh s0                              # | (s0)
    psh s1                              # | s0-(s1)
    psh s2                              # | s0-s1-(s2)
    psh s3                              # | s0-s1-s2-(s3)

    mov s0,a0
    mov s1,a1
    # S2 = tmp "store" for A values


    # === Compare X ===
    mov a0,txt_test_vec3_x
    syscall SYS_PRINT_STRING
    # Params
    mov a0,s0                           ## a0 : vec A
    mov a1,s1                           ## a1 : vec B
    mov a2,vec3_load_x                  ## a2 : function to call (vec3_load_x...)
    cal assert_eq_vec3_single_value

    # === Compare Y ===
    mov a0,txt_test_vec3_y
    syscall SYS_PRINT_STRING
    # Params
    mov a0,s0                           ## a0 : vec A
    mov a1,s1                           ## a1 : vec B
    mov a2,vec3_load_y                  ## a2 : function to call (vec3_load_x...)
    cal assert_eq_vec3_single_value

    # === Compare Z ===
    mov a0,txt_test_vec3_z
    syscall SYS_PRINT_STRING
    # Params
    mov a0,s0                           ## a0 : vec A
    mov a1,s1                           ## a1 : vec B
    mov a2,vec3_load_z                  ## a2 : function to call (vec3_load_x...)
    cal assert_eq_vec3_single_value

    # === Done ===
.assert_eq_vec3_done:

    pop s3                              # | s0-s1-s2-[s3]
    pop s2                              # | s0-s1-[s2]
    pop s1                              # | s0-[s1]
    pop s0                              # | [s0]
    ret



test_assert_eq_vec3:

    cal test_vec3_moc
    mov a0,vec3_A
    mov a1,vec3_A
    cal assert_eq_vec3

    cal test_vec3_moc
    mov a0,vec3_A
    mov a1,vec3_B
    cal assert_eq_vec3

    ret

bmk "Tests"



bmk "Test Vec3 lib"

sbmk "test vec3 moc"
vec3_A: res u8t vector.vector_size
vec3_B: res u8t vector.vector_size
vec3_C: res u8t vector.vector_size

test_vec3_reset_vec3_A:

    mov a0,1.0                            # X: 1
    mov a1,2.0                            # Y: 2
    mov a2,3.0                            # Z: 3
    mov a3,vec3_A

    cal vec3_store
    ret

test_vec3_reset_vec3_B:

    mov a0,3.0                            # X: 3
    mov a1,2.0                            # Y: 2
    mov a2,1.0                            # Z: 1
    mov a3,vec3_B

    cal vec3_store
    ret

test_vec3_reset_vec3_C:

    mov a0,0.0
    mov a1,0.0
    mov a2,0.0
    mov a3,vec3_C

    cal vec3_store
    ret

test_vec3_moc:

    cal test_vec3_reset_vec3_A
    cal test_vec3_reset_vec3_B
    cal test_vec3_reset_vec3_C

    ret

sbmk "test vec3 Add"

txt_test_vec3_add: emb string "test_vec3_add"

test_vec3_add:

    mov a0,txt_test_vec3_add
    cal print_method_name

    cal test_vec3_moc

    ## Params:
    mov a0,vec3_A                       # a0    : source vec3 A address
    mov a1,vec3_B                       # a1    : source vec3 B address
    mov a2,vec3_C                       # a2    : destination vec3 address

    cal vec3_add

    # === Test X ===
    mov a0,txt_test_vec3_x
    syscall SYS_PRINT_STRING
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_x                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a1,4.0 ## a1:  value (should)
    cal assert_eq

    # === Test Y ===
    mov a0,txt_test_vec3_y
    syscall SYS_PRINT_STRING
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_y                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a1,4.0 ## a1:  value (should)
    cal assert_eq

    # === Test Z ===
    mov a0,txt_test_vec3_z
    syscall SYS_PRINT_STRING
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_z                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a1,4.0 ## a1:  value (should)
    cal assert_eq

    ret


sbmk "test vec3 Copy"

txt_test_vec3_copy: emb string "test_vec3_copy"

test_vec3_copy:

    # Param
    mov a0,txt_test_vec3_copy           ## a0   :   method name (string)
    cal print_method_name

    # === Reset Vec3 test vecs ===
    cal test_vec3_moc

    ## Params:
    mov a0,vec3_A                       # a0    : source vec3 address
    mov a1,vec3_B                       # a1    : destination vec3 address
    cal vec3_copy

    # call assert eq vec3 to check if A and B are equal now
    mov a0,vec3_A
    mov a1,vec3_B
    cal assert_eq_vec3

    ret



bmk "Start"

_start: # Runs once when the VM starts.
    # Initialize your game state here.

    cal test_vec3_add
    cal test_vec3_copy



    exit

