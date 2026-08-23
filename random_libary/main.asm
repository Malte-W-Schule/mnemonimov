
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

    # --- get time ---
    syscall SYS_GET_UNIX_TIME


    syscall SYS_PRINT_LINE_INT

    sll a0,7
    syscall SYS_PRINT_LINE_INT




    ret


_start:
    cal rnd_init


    exit



_update: # Runs at 60 Hz.
    # Write your game logic here.
    exit
