# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.



# ======================================
#
#
#
#
#
# =====================================

txt_test: emb string "test"
txt_test_method: emb string "TEST_METHOD"


bmk "Prints"

sbmk "print method name"

# Param
## a0   :   method name (string)

print_method_name:
    # === Print Method Name ===
    mov t0,a0
    mov a0,txt_method_name
    syscall SYS_PRINT_STRING
    mov a0,t0
    syscall SYS_PRINT_STRING
    ret


bmk "Assert"

sbmk "Text"
txt_method_name: emb string "Method: "

txt_error: emb string " - Error: [ "
txt_predicted: emb string " ] should be: [ "
txt_predicted_end: emb string " ]"

txt_correct: emb string " - Correct "

sbmk "test funktion add"
# Param
## a0   :   int:A
## a1   :   int:B

# Return
## a0   :   (A+B)
test_funktion_add:

    add a0,a0,a1

    ret


sbmk "funktion assert eq int result"
# Param
## a0       : funktion
## a1       : funktion name (str)
## a2       : expected output (int)
## a3-a15   : input (a0-a12)

# Return
## a0       : true false (1/0) if output is matching

# use:
# mov a0,assert_eq_int
# cal call_funktion
funktion_assert_eq_int_result:

    # === Store Values ===
    psh s0                              # | (s0)
    psh s1                              # | s0-(s1)
    psh s2                              # | s0-s1-(s2)

    mov s0,a0                           # s0 <- funktion
    mov s1,a1                           # s1 <- funktion name (str)
    mov s2,a2                           # s2 <- expected result (int)

    # === Print Method Name ===

    mov a0,s1
    cal print_method_name

    # === shift values ===
    vmov a0..a12,a3..

    # === Call Funktion ===
    cala s0

    # result value has to be in a0
    cmp eq,a0,s2                        # cmp a0,s2
    jtr .funktion_assert_eq_int_result_correct

    psh a0
    # else
    # === Error ===
    mov a0,txt_error
    syscall SYS_PRINT_STRING

    pop a0
    mov a0,a0
    syscall SYS_PRINT_INT

    # === predicted ===
    mov a0,txt_predicted
    syscall SYS_PRINT_STRING
    mov a0,s2
    syscall SYS_PRINT_INT
    mov a0,txt_predicted_end
    syscall SYS_PRINT_LINE_STRING
    jmp .funktion_assert_eq_int_result_done

    # === Correct ===
.funktion_assert_eq_int_result_correct:
    mov a0,txt_correct
    syscall SYS_PRINT_LINE_STRING

    # === Done ===
.funktion_assert_eq_int_result_done:

    # === Load Values ===
    pop s2                              # | s0-s1-[s2]
    pop s1                              # | s0-[s1]
    pop s0                              # | [s1]
    ret


sbmk "assert eq int"
# Params
## a0:  value (is)
## a1:  value (should)
## a2:  method_name?

#Funktion
## Returns [ Correct / Error (is) (should) ]

assert_eq_int:

    # === Save Values ===
    psh a0                              # | (a0)
    psh a1                              # | a0-(a1)

    # === Print Method Name ===
    mov a0,txt_method_name
    syscall SYS_PRINT_STRING
    mov a0,a2
    syscall SYS_PRINT_STRING

    # === Load Values & Compare ===
    pop a2                              # | a0-[a1]
    pop a1                              # | [a0]
    cmp eq,a1,a2
    jtr .assert_eq_int_correct

    # === Error ===
    mov a0,txt_error
    syscall SYS_PRINT_STRING
    mov a0,a1
    syscall SYS_PRINT_INT

    # === pred ===
    mov a0,txt_predicted
    syscall SYS_PRINT_STRING
    mov a0,a2
    syscall SYS_PRINT_INT
    mov a0,txt_predicted_end
    syscall SYS_PRINT_LINE_STRING
    jmp .assert_eq_int_done

    # === Correct ===
.assert_eq_int_correct:
    mov a0,txt_correct
    syscall SYS_PRINT_LINE_STRING

    # === Done ===
.assert_eq_int_done:
    ret

sbmk "print_test"
print_test:
    mov a0,txt_test
    syscall SYS_PRINT_LINE_STRING

    ret


_start: # Runs once when the VM starts.
    # Initialize your game state here.


    # Params
    ## a0:  value (is)
    ## a1:  value (should)
    ## a2:  method_name?

    #mov a0,0
    #mov a1,0
    #mov a2,txt_test_method
    #cal assert_eq_int

    mov a0,test_funktion_add
    mov a1,txt_test_method
    mov a2,4
    mov a3,2
    mov a4,2
    cal funktion_assert_eq_int_result


    exit




_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit


_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.
    exit


_input: # Runs when input state changes.
    # React to player input here.
    exit
