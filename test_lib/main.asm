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


bmk "Prints" # ==================================


txt_test: emb string "test"
sbmk "print_test"
print_test:
    mov a0,txt_test
    syscall SYS_PRINT_LINE_STRING

    ret

sbmk "print method name (str)"
# Param
## a0   :   method name (string)
print_method_name:
    # === Print Method Name ===
    mov t0,a0
    mov a0,txt_method_name
    syscall SYS_PRINT_STRING
    mov a0,t0
    syscall SYS_PRINT_LINE_STRING
    ret

sbmk "print method number (int)"
# Param
## a0   :   method number (int)
print_method_number:
    # === Print Method Name ===
    mov t0,a0
    mov a0,txt_test_number
    syscall SYS_PRINT_STRING
    mov a0,t0
    syscall SYS_PRINT_LINE_INT
    ret


sbmk "print error predicted int"
# Params:
#   a0 : is (actual)
#   a1 : should (expected)

print_error_predicted:

    # === Save ===
    psh s0
    psh s1

    mov s0, a0
    mov s1, a1

    # === Error ===
    mov a0, txt_error
    syscall SYS_PRINT_STRING
    mov a0, s0
    syscall SYS_PRINT_INT

    # === Predicted ===
    mov a0, txt_predicted
    syscall SYS_PRINT_STRING
    mov a0, s1
    syscall SYS_PRINT_INT

    mov a0, txt_predicted_end
    syscall SYS_PRINT_LINE_STRING

    pop s1
    pop s0
    ret

bmk "Example Tests" # ===========================

sbmk "testsuite run"

testsuite_run:

    # Setup:

    # Tests:
    cal test_1_add_two_int_values


    ret

sbmk "test 1 add two int values"
test_1_add_two_int_values:
    mov a0,1
    cal print_method_number

    mov a0,2
    cal print_method_number

    ret

sbmk "test funktion add"
# Param
## a0   :   int:A
## a1   :   int:B

# Return
## a0   :   (A+B)
test_funktion_add:

    add a0,a0,a1

    ret


bmk "Tests" # ====================================


txt_test_method: emb string "TEST_METHOD"
txt_method_name: emb string "Method: "

txt_test_number: emb string "Test: "

txt_error: emb string " - Error: [ "
txt_predicted: emb string " ] should be: [ "
txt_predicted_end: emb string " ]"
txt_correct: emb string " - Correct "




sbmk "funktion assert eq"
# Param
## a0       : funktion
## a1       : funktion name (str)
## a2       : expected output
## a3-a15   : input (a0-a12)

# Return
## a0       : true false (1/0) if output is matching

# use:
# mov a0,assert_eq_int
# cal call_funktion
funktion_assert_eq:

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

    # else
    # === Print Error Message ===

    psh a0                              # Store result | s0-s1-s2-(a0)
    # Error
    mov a0,txt_error
    syscall SYS_PRINT_STRING

    # Value
    pop a0                              # Load Value | s0-s1-s2-[a0]
    mov a0,a0
    syscall SYS_PRINT_INT

    # === Print Predicted ===
    # Predicted
    mov a0,txt_predicted
    syscall SYS_PRINT_STRING
    mov a0,s2
    # Value
    syscall SYS_PRINT_INT
    mov a0,txt_predicted_end
    syscall SYS_PRINT_LINE_STRING
    jmp .funktion_assert_eq_int_result_done # Jump to end

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


sbmk "assert eq"
# Params
## a0:  value (is)
## a1:  value (should)

#Funktion
## Returns [ Correct / Error (is) (should) ]

assert_eq:

    # === Save Values ===
    psh s0                              # | (s0)
    psh s1                              # | s0-(s1)

    mov s0,a0
    mov s1,a1

    # === Compare ===
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
    pop s1                              # | s0-[s1]
    pop s0                              # | [s0]
    ret


