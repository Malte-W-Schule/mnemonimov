# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.


# different types of ammo?
# score? save files?

# write? read? from fie?




_start: # Runs once when the VM starts.
    # Initialize your game state here.


    # Args: a0:dst_address, a1:src_address, a2:size
    mov a0, 20
    mov a1, 20
    mov a2, 20
    syscall  SYS_STORAGE_WRITE
    syscall  SYS_STORAGE_READ



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
