# Built-in process entry points.
# The kernel runs these processes automatically.
# Each process must end with an 'exit' instruction.
include "../vec_libary/main.asm"

cal vec3_load

_start: # Runs once when the VM starts.
    # Initialize your game state here.
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
