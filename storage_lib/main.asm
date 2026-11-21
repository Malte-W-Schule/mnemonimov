
bmk "imports"

include "../test_lib/main.asm"

bmk "storage"


# [test]
test_storage:

    cal test_storage_write_single_byte
    cal test_storage_read_single_byte
    cal test_storage_init
    cal test_storage_settings_len
    cal test_storage_len
    cal test_storage_clear

    ret

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
txt_test_storage_read_single_byte: emb string "test_storage_read_single_byte"

test_storage_read_single_byte:
    mov a0,txt_test_storage_read_single_byte
    ## a0   :   method name (string)
    cal print_method_name

    mov a0,4## a0 :     storage addr
    mov a1,4 ## a1 :     byte value
    cal storage_write_single_byte

    mov a0,4
    cal storage_read_single_byte

    mov a1,4
    cal assert_eq_int

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

txt_test_storage_write_single_byte: emb string "test_storage_write_single_byte"
# [test]
test_storage_write_single_byte:

    ## a0   :   method name (string)
    mov a0,txt_test_storage_write_single_byte
    cal print_method_name

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


# CONST
# name: byte in settings
def c_storage_len_addr 0
def c_storage_settings_len_addr 1
def c_storage_settings_len 10

# Function
## creates a "head" in which the first 10 byte (offset 0-9) are saved for information about the storage
## start -> byte 10
# [settings][block]
# settings is [exclusive] `storage_len` long
# block starts at [inclusive] `storage_len`

storage_init:

    # storage end
    mov a0,c_storage_len_addr                          # a0 : storage addr
    mov a1,c_storage_settings_len                           # a1 : byte value
    cal storage_write_single_byte
    # storage len
    mov a0,c_storage_settings_len_addr
    mov a1,c_storage_settings_len
    cal storage_write_single_byte

    ret

# [test]
txt_test_storage_init: emb string "test_storage_init"

test_storage_init:

    mov a0,txt_test_storage_init
    cal print_method_name

    cal storage_init

    mov a0,c_storage_len_addr
    cal storage_read_single_byte
    mov a1,c_storage_settings_len
    cal assert_eq_int

    mov a0,c_storage_settings_len_addr
    cal storage_read_single_byte
    mov a1,c_storage_settings_len
    cal assert_eq_int

    ret


sbmk "storage settings len"

# Return
## a0 : storage settings len (addr)
storage_settings_len:
    mov a0,c_storage_settings_len_addr
    cal storage_read_single_byte
    ret

# [test]
txt_test_storage_len: emb string "test_storage_settings_len"

test_storage_settings_len:

    mov a0,txt_test_storage_len
    cal print_method_name

    cal storage_init

    cal storage_settings_len
    mov a1,c_storage_settings_len
    cal assert_eq_int

    ret

sbmk "storage len"
# Return
## a0 : storage len(addr)
storage_len:
    mov a0,c_storage_len_addr
    cal storage_read_single_byte
    ret

# [test]
txt_storage_get_len:  emb string "storage_get_len"

test_storage_len:

    mov a0,txt_storage_get_len
    cal print_method_name

    cal storage_init
    cal storage_len
    mov a1,c_storage_settings_len                            # start mit 1 comparen (muss 1 sein)
    cal assert_eq_int
    ret

sbmk "storage clear"

storage_clear:

    # save
    psh s0                              # |(s0)
    psh s1                              # | s0-(s1)
    # s0 = len
    # s1 = index

    # get storage len
    cal storage_len
    mov s0,a0                           # save storage len in s0
    mov s1,0                            # i = 0

.storage_clear_loop_start:
    # === LOOP ===
    # for i = 0 till storage len, set byte to 0

    # set byte to 16x00
    mov a0,s1                           ## a0 :     storage addr
    mov a1,0                            ## a1 :     byte value
    cal storage_write_single_byte

    # loop end
    inc s1                              # i++
    cmp lt,s1,s0                       # i <= storage.len
    jtr .storage_clear_loop_start

    # load
    pop s1                              # | s0-[s1]
    pop s0                              # |[s0]

    ret

# [test]
txt_test_storage_clear: emb string "test_storage_clear"
test_storage_clear:

    mov a0,txt_test_storage_clear
    cal print_method_name
    # init
    cal storage_init
    # len getten sollte len lang sein
    # voher
    cal storage_len
    mov a1,c_storage_settings_len
    cal assert_eq_int

    cal storage_clear
    # nachher
    cal storage_len
    mov a1,0
    cal assert_eq_int

    ret

_start: # Runs once when the VM starts.
    cal test_storage
    exit
