

bmk "Includes"

include "../vec_libary/main.asm"

include "../test_lib/main.asm"



tmpVec: res u8t vector.vector_size

bmk "Test_help"

bmk "Tests"



bmk "Test Vec3 lib"

sbmk "vec3 moc"
vec3_A: res u8t vector.vector_size
vec3_B: res u8t vector.vector_size
vec3_C: res u8t vector.vector_size


test_vec3_reset_vec3_A:

    mov a0,1                            # X: 1
    mov a1,2                            # Y: 2
    mov a2,3                            # Z: 3
    mov a3,vec3_A

    cal vec3_store
    ret

test_vec3_reset_vec3_B:

    mov a0,3                            # X: 3
    mov a1,2                            # Y: 2
    mov a2,1                            # Z: 1
    mov a3,vec3_B

    cal vec3_store
    ret

test_vec3_reset_vec3_C:

    mov a0,0
    mov a1,0
    mov a2,0
    mov a3,vec3_C

    cal vec3_store
    ret


test_vec3_moc:

    cal test_vec3_reset_vec3_A
    cal test_vec3_reset_vec3_B
    cal test_vec3_reset_vec3_C

    ret

sbmk "Vec3 Add"

txt_test_vec3_add: emb string "test_vec3_add"

test_vec3_add:

    cal test_vec3_moc

    ## Functionality:

    ## Params:
    mov a0,vec3_A                       # a0    : source vec3 A address
    mov a1,vec3_B                       # a1    : source vec3 B address
    mov a2,vec3_C                       # a2    : destination vec3 address

    cal vec3_add

    # === Test X ===
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_x                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a3,4 ## a1:  value (should)
    cal assert_eq

    # === Test Y ===
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_y                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a3,4 ## a1:  value (should)
    cal assert_eq

    # === Test Z ===
    ## Params:
    mov a0,vec3_C                       # a0    : source vec3 address

    cal vec3_load_z                     # a0    : x
    # set via vec_load_x ## a0:  value (is)
    mov a3,4 ## a1:  value (should)
    cal assert_eq

    ret

# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.

bmk "Start"

_start: # Runs once when the VM starts.
    # Initialize your game state here.

    mov a0,txt_test_vec3_add
    ## a0   :   method name (string)
    cal print_method_name
    cal test_vec3_add

    exit



#bmk "Update"
#_update: # Runs at 60 Hz.
    # Write your game logic here.
#    exit


#bmk "Draw"
#_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.
#    exit


#bmk "Input"
#_input: # Runs when input state changes.
    # React to player input here.
#    exit
