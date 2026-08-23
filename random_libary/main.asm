
bmk "Random Libary"
# ==================================== #
# Random Libary
# ==================================== #
#
#
bmk "Random Functions"

rnd_seed: res u32t 1337

sbmk "rnd init"
## Functionality

## Params

# Output
rnd_init:


    syscall SYS_GET_MOUSE_POSITION
    mov a1,a0
    syscall SYS_GET_UNIX_TIME
    fadd a0,a0,a1

    syscall SYS_PRINT_LINE_INT

    ret


_start:



    exit



_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit
