
bmk "imports"

include "../test_lib/main.asm"

bmk "storage"

sbmk "storage globals"
byte_buffer: res u8t 1                  # reserves 1 byte as a buffer to write


sbmk "storage read single byte"

# Params
## a0 :     storage addr

# Return
## a0 :     storage addr

storage_read_single_byte:
    mov a1, a0
    mov a0, byte_buffer
    mov a2, 1
    syscall SYS_STORAGE_READ

    lod u8t, a0, byte_buffer
    ret

# [test]
test_storage_read_single_byte:
    mov a0,4
    cal storage_read_single_byte
    syscall SYS_PRINT_INT

    ret


sbmk "storage write single byte"

# Params
## a0 :     storage addr
## a1 :     byte value

storage_write_single_byte:
    str u8t, byte_buffer,a1
    mov a1, byte_buffer
    mov a2,1
    syscall SYS_STORAGE_WRITE
    ret

    # Schreibt eine 32-Bit-Zahl (a1) an die Storage-Adresse (a0) – komplett ohne res-Puffer!
write_u32_from_reg:
    psh a1                                  # 4 Bytes auf den Stack legen (sp zeigt jetzt darauf)[cite: 38]

    tpr a1, sp                              # Absolute Stack-Adresse 'sp' in [pa-relative] umrechnen[cite: 37]
    mov a2, 4                               # Größe: 4 Bytes[cite: 32]
    syscall SYS_STORAGE_WRITE               # Direkt vom Stack in den Storage schreiben[cite: 32]

    pop t0                                  # Stack wieder bereinigen (4 Bytes entfernen)[cite: 38]
    ret                                     #[cite: 35]

# [test]
test_storage_write_single_byte:
    mov a0,0
    mov a1,0
    cal storage_write_single_byte
    mov a0,1
    mov a1,1
    cal storage_write_single_byte
    mov a0,2
    mov a1,2
    cal storage_write_single_byte
    mov a0,3
    mov a1,3
    cal storage_write_single_byte
    mov a0,4
    mov a1,4
    cal storage_write_single_byte
    mov a0,5
    mov a1,5
    cal storage_write_single_byte
    mov a0,6
    mov a1,6
    cal storage_write_single_byte
    mov a0,7
    mov a1,7
    cal storage_write_single_byte
    mov a0,8
    mov a1,8
    cal storage_write_single_byte
    mov a0,9
    mov a1,9
    cal storage_write_single_byte
    ret


sbmk "storage init"

# Function
## creates a "head" in which the first 10 byte (offset 0-9) are saved for information about the storage
## start -> byte 10

storage_init:

    # Byte 0, len of storage
    mov a0,0                            # a0 : storage addr
    mov a1,10                           # a1 : byte value
    cal storage_write_single_byte
    # Byte 1, len of Storage-settings-block
    mov a0,1
    mov a1,10
    cal storage_write_single_byte

    ret

# [test]
test_storage_init:
    cal storage_init
    ret


sbmk "storage get len"

# Return
## a0 : last addr of storage
storage_get_len:
    mov a0,0
    cal storage_read_single_byte
    ret


# [test]
test_storage_get_len:

    cal storage_clear
    cal storage_init
    cal storage_get_len


    mov a1,10
    cal assert_eq
    # should be 10

    ret

sbmk "storage get start"
# Return
## a0 : first add of storage (after setting block)
storage_get_start:
    mov a0,1
    cal storage_read_single_byte
    ret

sbmk "storage clear"
storage_clear:



    ret

sbmk "storage write"


log_buffer: emb string "Test 1: OK\nTest 2: FAIL\0"
def LOG_SIZE 100

write_storage:
    mov a0, 0                   # Starte im Storage bei Byte 0
    mov a1, log_buffer          # Adresse des Strings im RAM
    mov a2, LOG_SIZE            # Schreibe 25 Bytes
    syscall SYS_STORAGE_WRITE   # Daten persistent sichern[cite: 32]
    ret                        # Prozess sauber beenden[cite: 37]

read_buffer: res u8t 100         # Leeren Puffer mit 25 Bytes im RAM reservieren[cite: 10]
read_storage:
    mov a0, read_buffer         # Ziel-Puffer im RAM[cite: 32]
    mov a1, 0                   # Lese im Storage ab Byte 0[cite: 32]
    mov a2, LOG_SIZE            # Lese 25 Bytes[cite: 32]
    syscall SYS_STORAGE_READ    # Daten aus Storage in read_buffer laden[cite: 32]

    # Geladenen Text zur Kontrolle im Terminal ausgeben
    mov a0, read_buffer         # Adresse des Puffers übergeben[cite: 30]
    syscall SYS_PRINT_STRING    # String ausgeben[cite: 30]
    exit                        # Prozess sauber beenden[cite: 37]


_start: # Runs once when the VM starts.

    cal test_storage_get_len
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
