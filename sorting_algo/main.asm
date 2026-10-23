# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.
bmk "help"

sbmk "store value example"
## Params
# a1    : address
# a0    : value
store_value:
    cea a1, 0, 1                        # Load destination address into CEA
    ste i32t, 0, a0                     # Type,displacement,value
    ret

sbmk "load value example"
## Params
# a0    : addr

## Return
# a0    : value
load_value:
    cea a0, 0, 1                        # (pa)base_address,index,scale
    lde i32t, a0, 0                     # Type,dest,displacement
    ret

bmk "list struct"
## list has 10 elements

list:
    ._l0: emb i32t 0
    ._l1: emb i32t 0
    ._l2: emb i32t 0
    ._l3: emb i32t 0
    ._l4: emb i32t 0
    ._l5: emb i32t 0
    ._l6: emb i32t 0
    ._l7: emb i32t 0
    ._l8: emb i32t 0
    ._l9: emb i32t 0
    ._l10: emb i32t 0
    ._l11: emb i32t 0
    ._l12: emb i32t 0
    ._l13: emb i32t 0
    ._l14: emb i32t 0
    ._l15: emb i32t 0
    ._l16: emb i32t 0
    ._l17: emb i32t 0
    ._l18: emb i32t 0
    ._l19: emb i32t 0

    def .i0 (._l0 - list)
    def .i1 (._l1 - list)
    def .i2 (._l2 - list)
    def .i3 (._l3 - list)
    def .i4 (._l4 - list)
    def .i5 (._l5 - list)
    def .i6 (._l6 - list)
    def .i7 (._l7 - list)
    def .i8 (._l8 - list)
    def .i9 (._l9 - list)
    def .i10 (._l0 - list)
    def .i11 (._l1 - list)
    def .i12 (._l2 - list)
    def .i13 (._l3 - list)
    def .i14 (._l4 - list)
    def .i15 (._l5 - list)
    def .i16 (._l6 - list)
    def .i17 (._l7 - list)
    def .i18 (._l8 - list)
    def .i19 (._l9 - list)

    def .list_size ( $ - list)      # size 40
    def .list_length (list.list_size / 4)

sbmk "list examples"

# create list example
list_example: res u8t list.list_size

llist_load:
    cea a0, 0, 1                        # Load vec address into CEA
    lde f32t, a0, list.i1              # a0 <- x
    ret

sbmk "list load"

## Params
# a0    :   list addr

# Return
# a0-a9 :   list elements

list_load:
    cea a0,0,1                          # load vec address into CEA
    lde i32t,a0,list.i0
    lde i32t,a1,list.i1
    lde i32t,a2,list.i2
    lde i32t,a3,list.i3
    lde i32t,a4,list.i4

    lde i32t,a5,list.i5
    lde i32t,a6,list.i6
    lde i32t,a7,list.i7
    lde i32t,a8,list.i8
    lde i32t,a9,list.i9

    ret

sbmk "list store"
## Params
# a10    :   list addr
# a0-a9 :   list elements
list_store:
    cea a10,0,1                          # load vec address into CEA
    ste i32t, list.i0 ,a0
    ste i32t, list.i1 ,a1
    ste i32t, list.i2 ,a2
    ste i32t, list.i3 ,a3
    ste i32t, list.i4 ,a4

    ste i32t,list.i5 ,a5
    ste i32t,list.i6 ,a6
    ste i32t,list.i7 ,a7
    ste i32t,list.i8 ,a8
    ste i32t,list.i9 ,a9

    ret

sbmk "list load index"

## Params
# a0    :   list
# a1    :   index (int)

## Return
# a0    :   value

list_load_index:

    # ea = (pa + a0) + (a1 * 4) | (i32t == 4bit)
    cea a0, a1, 4
    lde i32t,a0,0

    ret

sbmk "list store index"

## Params
# a0    :   list
# a1    :   index (int)
# a2    :   value

list_store_index:

    # ea = (pa + a0) + (a1 * 4) | (i32t == 4bit)
    cea a0, a1, 4
    ste i32t,0,a2

    ret

sbmk "list set random"

## Params
# a10    :   list addr

list_set_random:

    rnd a0,0,10
    rnd a1,0,10
    rnd a2,0,10
    rnd a3,0,10
    rnd a4,0,10

    rnd a5,0,10
    rnd a6,0,10
    rnd a7,0,10
    rnd a8,0,10
    rnd a9,0,10

    cal list_store
    ret

sbmk "list print"

## Params
# a0    :   list

list_print:
    cal list_load
    # a0
    syscall SYS_PRINT_INT
    mov a0,a1
    syscall SYS_PRINT_INT
    mov a0,a2
    syscall SYS_PRINT_INT
    mov a0,a3
    syscall SYS_PRINT_INT
    mov a0,a4
    syscall SYS_PRINT_INT

    mov a0,msg_dot
    syscall SYS_PRINT_STRING

    mov a0,a5
    syscall SYS_PRINT_INT
    mov a0,a6
    syscall SYS_PRINT_INT
    mov a0,a7
    syscall SYS_PRINT_INT
    mov a0,a8
    syscall SYS_PRINT_INT
    mov a0,a9
    syscall SYS_PRINT_LINE_INT
    ret

sbmk "list sort 2"

## Param
# a0    :   list
# a1    :   to sort index (i ; i+1)
list_sort_2:

    add a2,a1,1                              # i = i+1

    # load i
    cea a0, a1, 4
    lde i32t,t0,0                       # i -> t0

    # load i+1
    cea a0, a2, 4
    lde i32t,t1,0                       # i+1 -> t1

    cmp lt,t0,t1                        # compare i < i+1
    jtr .list_sort_2_end

    # swap if not i < i+1
    swp t0,t1

.list_sort_2_end:

    cea a0,a1,4
    ste i32t,0,t0

    cea a0,a2,4
    ste i32t,0,t1

    ret

bmk "sorting"

bmk "bubblesort"

## Param
# a0    :   list

bubblesort:
    # --- setup outer loop ---
    mov s0,0    # (index)
    mov s1,0    # sorted
    mov s2,10    # size
    sub s4,s2,1    # (size -2)
    mov s5,a0
    # (since the algo allways compares i and i+1 ( i=2 (compares index i+1 and i+2)

    # --- Bubble Sort ---

.outer_bubble_loop_start:
    # outer loop
    # calculate (size-sorted)
    sub s3,s2,s1                        # calc (size-sorted)
    sub s3,s3,1                         # s3-2 (4-0)-2) = 2

    mov s0,0                            # reset index to 0

    # --- Inner loop ---
    # increase index till (size-sorted)
    # then outer loop

.inner_bubble_loop_start:

    # --- get correct register ---

    # index 0 (pos 1) ; 1

    # a0    :   list
    mov a0,s5
    # a1    :   to sort index (i ; i+1)
    mov a1,s0
    cal list_sort_2

    # - debug -
    #cal print_t                         # print current step result

    # --- inner loop end ---

    inc s0                              # increase index
    cmp lt,s0,s3                        # check if index < (size-sorted)
    jtr .inner_bubble_loop_start

    # - debug -
    #psh a0
    #mov a0,msg_outer_loop_end
    #syscall SYS_PRINT_LINE_STRING
    #pop a0

    # - outer loop end -
    inc s1
    cmp lt,s1,s4                        # as long as sorted < (size-2)
    jtr .outer_bubble_loop_start        # jump back if (sorted <= size) == True

.outer_bubbble_loop_end:
   ret

bmk "flipsort"
## Param
# a0    :   list
flipsort:

sbmk " - overview"
    # s0    :   (max index) "start" of loop (moves left with "+1 sorted")
    # s1    :   active symbol
    # s2    :   last same symbol connected to active index
    # s3    :   ---
    # s4    :   loop index counter
    # s5    :   flip start index
    # s6    :   list
    # s7    :   flip index counter
    # s8    :   flip end index

    # --- store ---
    psh s0
    psh s1
    psh s2
    psh s3
    psh s4
    psh s5
    psh s6
    psh s7
    psh s8

sbmk " - start Setup"

    # --- Start Setup ---
    mov s6,a0                           # store list

    mov s0,list.list_length             # get list size
    dec s0
    #cal flipsort_print_start            # DEBUG

sbmk " - loop start find next left same symbol"

.flipsort_loop_find_same_symbol_left_restart:
    mov s4,s0                           # reset: index setup (reset to (max index))
    mov s2,s0                           # reset: last same symbol connected to active (index)

    mov a0,s6                           # a0    :   list
    mov a1,s0                           # a1    :   index (int)
    cal list_load_index                 # a0    :   value
    mov s1,a0                           # active symbol = s1
.flipsort_loop_find_same_symbol_left_start:
    dec s4                              # decrease to not make it "search" itself

    # --- get element at current index (t4) ---
    mov a0,s6                    # a0    :   list
    mov a1,s4                           # a1    :   index (int)
    cal list_load_index                 # a0    :   (returns current index symbol)

    #cal flipsort_print_state            # DEBUG

    cmp eq,a0,s1                        # compare "current index symbol" (a0) and "active symbol"(s1)
    jtr .flipsort_same_symbol           # if theyre the same handle same symbol

    yield
sbmk " - end of loop"
    cmp gte,s4,0                         # while index (s4) >= 0 (loop again)
    jtr .flipsort_loop_find_same_symbol_left_start
sbmk " - else : sorted + 1"
    # else when no same symbol was found till end of list "sorted +1" maxindex -1
    # "sorted +1" = max index = last connected index -1

    #cal flipsort_print_decrease_max_index #DEBUG

    mov s0,s2
    dec s0

    cmp lt,0,s0
    jfs .flipsort_end
    # else "loop" again
    jmp .flipsort_loop_find_same_symbol_left_restart

sbmk " - flipsort same symbol"
    .flipsort_same_symbol:

    #cal flipsort_print_same_symbol      # DEBUG

    # is "last same symbol connected" (t2) next to current same symbol?
    add s5,s4,1
    cmp eq, s5,s2
    jfs .flipsort_flip
    # if next to each other.. ignore

    dec s2                              # decrease "next to each other connected index)
    jmp .flipsort_loop_find_same_symbol_left_start

sbmk " - flip"
.flipsort_flip:
    # flip s0 till s            | ....s5...s0...

    mov s7,0                            # create tmp index counter
    mov s8,s0                           # get max index

sbmk " - flip loop"
.flipsort_flip_loop_start:
    # flip ....(s5+s7)....(s8-s7)
    mov a0,s6                           # a0    :   list , load list into param
    add a1,s5,s7                        # start (s5) + index(s7)        :   index element A
    sub a2,s8,s7                        # (max index) - (tmp index s7)  :   index element B
    cal flipsort_flip_2

    # while [(max index (s8) - index (s7)] > [to swap symbol (s5) + index (s7)]
    inc s7                              # increase index for next round
    sub t0,s8,s7                        # [(max index (s8) - index (s7)]
    add t1,s5,s7                        # [to swap symbol (s5) + index (s7)]
    cmp gt,t0,t1                        # compare (left index) > (right index)
    jtr .flipsort_flip_loop_start

    #cal flipsort_print_step             # DEBUG

    cmp lt,0,s0                        # while max index > 0 loop
    jtr .flipsort_loop_find_same_symbol_left_restart

sbmk " - end"
.flipsort_end:
    #mov a0,msg_flipsort_end
    #syscall SYS_PRINT_LINE_STRING

    # --- restore ---
    pop s8
    pop s7
    pop s6
    pop s5
    pop s4
    pop s3
    pop s2
    pop s1
    pop s0

    ret

bmk "flipsort print"

sbmk "flipsort flip 2"
## Param
# a0    :   list
# a1    :   index element A
# a2    :   index element B
flipsort_flip_2:

    # --- load values ---
    cea a0, a1, 4                       # load element from index A -> t0
    lde i32t,t0,0

    cea a0, a2, 4                       # load element from index B -> t2
    lde i32t,t1,0

    # --- store ---
    cea a0, a1, 4                       # store t1 B -> A
    ste i32t,0,t1

    cea a0, a2, 4                       # store t0 A -> B
    ste i32t,0,t0
    ret

sbmk "flipsort print step"

flipsort_print_step:

    # --- store ---
    psh a0

    mov a0,msg_flipsort_print_step      # print step text
    syscall SYS_PRINT_LINE_STRING
    mov a0,s6
    cal list_print

    # --- restore ---
    pop a0
    ret

sbmk "flipsort pring state"
## function prints t0-t5 values
flipsort_print_state:

    # --- save ---
    psh a0

    mov a0,msg_line
    syscall SYS_PRINT_LINE_STRING

    # --- print active symbol ---
    mov a0,msg_flipsort_active
    syscall SYS_PRINT_STRING
    mov a0,s1
    syscall SYS_PRINT_LINE_INT

    # --- last same symbol connected to active index ---
    mov a0,msg_flipsort_last_same_symbol_index
    syscall SYS_PRINT_STRING
    mov a0,s2
    syscall SYS_PRINT_LINE_INT

    # --- print current index ---
    mov a0,msg_flipsort_current
    syscall SYS_PRINT_STRING
    mov a0,s4
    syscall SYS_PRINT_LINE_INT

    mov a0,msg_flipsort_maxindex
    syscall SYS_PRINT_STRING
    mov a0,s0
    syscall SYS_PRINT_LINE_INT

    # --- print current symbol --- + restore ----
    mov a0,msg_flipsort_current_sym
    syscall SYS_PRINT_STRING
    pop a0
    syscall SYS_PRINT_LINE_INT
    # - debug end -

    ret

sbmk "flipsort print start"
flipsort_print_start:
 # --- print flipsort start ---
    psh a0
    mov a0,msg_flipsort_start
    syscall SYS_PRINT_LINE_STRING
    pop a0
    ret

sbmk "flipsort print same symbol"

flipsort_print_same_symbol:
    psh a0                                      # save a0
    mov a0,msg_flipsort_same_symbol             # load "flipsort found same symbol at: "
    syscall SYS_PRINT_LINE_STRING               # print
    pop a0                                      # restore a0
    ret

sbmk "flipsort print flip"
flipsort_print_flip:

    psh a0                                      # save a0
    mov a0,msg_flipsort_flip                    # load text
    syscall SYS_PRINT_LINE_STRING               # print text
    pop a0                                      # restore a0
    ret

sbmk "flipsort print decrease max index"
flipsort_print_decrease_max_index:

    psh a0
    mov a0,msg_flipsort_decreasemaxindex
    syscall SYS_PRINT_STRING
    mov a0,s0
    syscall SYS_PRINT_LINE_INT

    mov a0,msg_flipsort_decreasemaxindexto
    syscall SYS_PRINT_STRING
    mov a0,s2
    dec a0
    syscall SYS_PRINT_LINE_INT
    pop a0

    ret


bmk "dialogue"


msg_outer_loop_end: emb string "outer loop cycle end"
msg_result: emb string   "Result:   "
msg_previous: emb string "Previous: "

msg_test: emb string "test: "
msg_dot: emb string "."
msg_line: emb string "=========="

msg_flipsort_start: emb string " === flipsort start === "
msg_flipsort_decreasemaxindex: emb string "flipsort decrease max index from: "
msg_flipsort_decreasemaxindexto: emb string "flipsort decrease max index to: "
msg_flipsort_maxindex: emb string "flipsort maxindex: "
msg_flipsort_active: emb string "flipsort active symbol: "
msg_flipsort_current: emb string "fliposrt current index: "
msg_flipsort_current_sym: emb string "flipsort current symbol: "
msg_flipsort_same_symbol: emb string "flipsort found same symbol !!"
msg_flipsort_flip: emb string "FLIP"
msg_flipsort_last_same_symbol_index: emb string "flipsort last connected same symbol at: "
msg_flipsort_print_step: emb string "step result: "

msg_round_1: emb string "==="
msg_round_2: emb string " Round: "
msg_round_3: emb string " Sec -"

msg_round_time: emb string "Time: "

msg_avr_time: emb string "Average Time: "

msg_flipsort_end: emb string " === flipsort end === "

bmk "start"


valuelist: res u8t list.list_size

_start: # Runs once when the V starts.
    # Initialize your game state here.

    mov s1,0                            # round counter
    mov s2,0.0000000000                 # added time

    # --- set Random seed ---
    mov a0,0
    syscall SYS_SET_RNG_SEED
.round_loop:

    # --- Print Previous: ---
    mov a0,msg_previous
    syscall SYS_PRINT_STRING

    # - init list with random values -
    mov a10,valuelist                   # a10    :   list addr
    cal list_set_random

    # - print list -
    mov a0,valuelist
    cal list_print

    # - save time before starting -
    syscall SYS_GET_RUNNING_TIME
    mov s0,a0

    # --- Flipsort setup and execution ---
    mov a0,valuelist                    # a0    :   list
    cal flipsort                        # flipsort

    # time
    syscall SYS_GET_RUNNING_TIME        # a0    : unix time
    fsub s3,a0,s0                       # time = starttime - endtime
    fadd s2,s3

    # - print result -
    mov a0,msg_result
    syscall SYS_PRINT_STRING
    mov a0,valuelist
    cal list_print

    # --- print round end text ---
    #mov a0,msg_round_1
    #syscall SYS_PRINT_STRING
    #mov a1,10
    #mov a0,s3
    #syscall SYS_PRINT_FLOAT
    #mov a0,msg_round_3
    #syscall SYS_PRINT_STRING

    #mov a0,msg_round_2
    #syscall SYS_PRINT_STRING
    #mov a0,s1
    #syscall SYS_PRINT_INT
    #mov a0,msg_round_1
    #syscall SYS_PRINT_LINE_STRING

    inc s1
    cmp lt,s1,1
    jtr .round_loop

    mov a0,msg_avr_time
    syscall SYS_PRINT_LINE_STRING
    fctf t0, s1                         # t0 = (float)s1
    fdiv a0,s2,t0                       # added times / roundcount = avr time
    mov a1,10
    syscall SYS_PRINT_LINE_FLOAT
    mov a0,s2
    syscall SYS_PRINT_LINE_FLOAT
 exit

bmk "update"
_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit

bmk "draw"
_draw: # Runs at 60 Hz and updates the front buffer.
    # Draw graphics to the screen here.
    exit

bmk "input"
_input: # Runs when input state changes.
    # React to player input here.
    exit
