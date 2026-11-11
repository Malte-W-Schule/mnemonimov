

bmk "Includes"

include "../vec_libary/main.asm"



tmpVec: res u8t vector.vector_size

txt_error: emb string "Error: "
txt_error_pred: emb string " Predicted: "

txt_cmp: emb string "Complete "

txt_done: emb string "Done"



bmk "Test_help"

bmk "Tests"


sbmk "write read"
# Params
write_read:

    mov a3,tmpVec
    mov a0,1
    mov a1,2
    mov a2,3

    mov s0,1
    mov s1,2
    mov s2,3

    cal vec3_store

    mov a0,0
    mov a1,0
    mov a2,0

    mov a0,tmpVec
    cal vec3_load

    # === Compare eingaben zu gestorten ausgaben ===
    cmp eq,a0,s0
    jfs .write_read_error

    cmp eq,a1,s1
    jfs .write_read_error

    cmp eq,a2,s2
    jfs .write_read_error

    jmp .write_read_complete


.write_read_error:

    psh a0
    mov a0,txt_error
    syscall SYS_PRINT_STRING

    pop a0
    syscall SYS_PRINT_INT

    mov a0,txt_error_pred
    syscall SYS_PRINT_STRING

    mov a0,s0
    syscall SYS_PRINT_LINE_INT
    jmp .write_read_done


.write_read_complete:

    mov a0,txt_cmp
    syscall SYS_PRINT_LINE_STRING
    jmp .write_read_done


.write_read_done:
    mov a0,txt_done
    syscall SYS_PRINT_LINE_STRING


    ret



# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.

bmk "Start"

_start: # Runs once when the VM starts.
    # Initialize your game state here.

    cal write_read

    exit


bmk "Update"
_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit


bmk "Draw"
_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.
    exit


bmk "Input"
_input: # Runs when input state changes.
    # React to player input here.
    exit
