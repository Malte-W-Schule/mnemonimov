
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
    cal test_storage_len_set
    cal test_storage_len_increase
    cal test_storage_clear
    cal test_storage_file_count
    cal test_storage_file_count_set
    cal test_storage_file_count_increase
    cal test_storage_last_file_addr
    cal test_storage_add_file
    cal test_storage_get_file

    ret

sbmk "storage globals"
byte_buffer: res u8t 1                  # reserves 1 byte as a buffer to write

def c_max_read_buf 256
read_buffer: res u8t c_max_read_buf       # Ein fester Buffer für alle Lesevorgänge

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

def c_storage_file_count_addr 2
def c_storage_file_count 0

def c_storage_file_lookup_start_addr 3

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

    # file count
    mov a0,c_storage_file_count_addr
    mov a1,c_storage_file_count
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


sbmk "storage len set"
# Param
## a0 : new storage len(addr)
storage_len_set:
    mov a1,a0
    mov a0,c_storage_len_addr
    cal storage_write_single_byte
    ret

# [test]
txt_storage_get_len_set:  emb string "storage_get_len_set"

test_storage_len_set:

    mov a0,txt_storage_get_len
    cal print_method_name
    # init
    cal storage_init
    # chane storage len
    mov a0,200
    cal storage_len_set

    cal storage_len
    mov a1,200                            # start mit 1 comparen (muss 1 sein)
    cal assert_eq_int
    ret

sbmk "storage len increase"

# Param
## a0 : amount (to increase)
storage_len_increase:

    psh a0                              #|(a0)
    cal storage_len
    pop a1
    add a0,a0,a1
    cal storage_len_set

    ret

# [test]
txt_storage_len_increase: emb string "storage_len_increase"

test_storage_len_increase:

    mov a0,txt_storage_len_increase
    cal print_method_name
    # init
    cal storage_init
    mov a0,5
    cal storage_len_increase

    cal storage_len
    mov a1,5
    add a1,a1,c_storage_settings_len
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

    cal storage_len

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


sbmk "storage file count"
# Return
## a0 : storage len(addr)
storage_file_count:
    mov a0,c_storage_file_count_addr
    cal storage_read_single_byte
    ret

# [test]
txt_storage_file_count:  emb string "storage_file_count  "

test_storage_file_count:

    mov a0,txt_storage_file_count
    cal print_method_name

    cal storage_init
    cal storage_file_count

    mov a1,c_storage_file_count                            # start mit 1 comparen (muss 1 sein)
    cal assert_eq_int
    ret


sbmk "storage file count set"

# Param
## a0 : new file count
storage_file_count_set:
    mov a1,a0
    mov a0,c_storage_file_count_addr
    cal storage_write_single_byte

    ret

# [test]
txt_storage_file_count_set: emb string "storage_file_count_set"

test_storage_file_count_set:

    mov a0,txt_storage_file_count_set
    cal print_method_name

    cal storage_init
    mov a0,5
    cal storage_file_count_set
    cal storage_file_count
    mov a1,5
    cal assert_eq_int

    ret



sbmk "storage file count increase"

# Return
## a0 : storage len(addr)
storage_file_count_increase:
    mov a0,c_storage_file_count_addr
    cal storage_read_single_byte
    # save
    psh a0
    # update file count +1
    inc a0
    cal storage_file_count_set
    # load
    pop a0

    ret

# [test]
txt_storage_file_count_increase:  emb string "storage_file_count_increase"

test_storage_file_count_increase:

    mov a0,txt_storage_file_count_increase
    cal print_method_name

    cal storage_init
    cal storage_file_count_increase
    # returns file count before increase so
    # call file count
    cal storage_file_count

    mov a1,c_storage_file_count                            # start mit 1 comparen (muss 1 sein)
    inc a1
    cal assert_eq_int
    ret


sbmk "storage last file addr"
# Return
## a0 : storage len(addr)
storage_last_file_addr:

    # === save ===
    psh s0                              # |(s0)

    cal storage_file_count
    mov s0,a0                           # save file count

    add s0,s0,c_storage_file_lookup_start_addr# add file start + file count = last file addr
    mov a0,s0

    mov a0,s0

    # === load ===
    pop s0                              #|[s0]

    ret

# [test]
txt_storage_last_file_addr:  emb string "storage_last_file_addr"

test_storage_last_file_addr:

    mov a0,txt_storage_last_file_addr
    cal print_method_name

    # init
    cal storage_init
    # get
    cal storage_last_file_addr
    # compare
    mov a1,c_storage_file_lookup_start_addr
    cal assert_eq_int
    # increase
    cal storage_file_count_increase
    # compare again
    cal storage_last_file_addr
    mov a1,c_storage_file_lookup_start_addr
    inc a1
    cal assert_eq_int

    ret

sbmk "storage add file"
# Param
## a0 : text addr
## a1 : size
txt_storage_add_file: emb string "storage_add_file"
txt_storage_add_file_error_too_many_files: emb string "ERROR: storage_add_file_error_too_many_files"

storage_add_file:

    # === Save ===
    psh s0                              # | (s0)
    psh s1                              # | s0-(s1)
    psh s2                              # | s0-s1-(s2)

    # s0: saves file count / addr
    # s1: saves text
    # s2: saves size
    mov s1,a0
    mov s2,a1

    # get last file addr
    cal storage_last_file_addr
    mov s0,a0


    # (files) > storage settings?
    cmp lt,s0,c_storage_settings_len

    # ERROR: error_too_many_files
    jfs .storage_add_fille_error_too_many_files

    # else:
    # s0 storages start + file count = addr where to put new addr
    # get len+1 as start

    cal storage_len                     # get storage len

    mov a1,a0                           # byte_value: file addr
    mov a0,s0                           # load addr where to put file_add in setting block

    mov s0,a1                           # save file_addr -> s0
    cal storage_write_single_byte

    # write text into addr
    # Args: a0:dst_address, a1:src_address, a2:size
    mov a0,s0                           # addr          = s0
    mov a1,s1                           # text addr     = s1
    mov a2,s2                           # size          = s2
    syscall SYS_STORAGE_WRITE

    # === Update ===
    # file len
    mov a0,s2
    cal storage_len_increase
    # file count
    cal storage_file_count_increase


    # === print error ===
    jmp .storage_add_file_end
.storage_add_fille_error_too_many_files:
    mov a0,txt_storage_add_file_error_too_many_files
    syscall SYS_PRINT_LINE_STRING
    #jmp .storage_add_file_end #todo


.storage_add_file_end:

    # === Store ===
    pop s2                              # | s0-s1-[s2]
    pop s1                              # | s0-[s1]
    pop s0                              # | [s0]

    ret

# [test]
test_txt_storage_add_file: emb string "Hallo Ich"
test_txt_storage_add_file_2: emb string "ich hallo"
def c_text_storage_add_file_txt_len 10

test_storage_add_file:

    mov a0,txt_storage_add_file
    cal print_method_name

    # init
    cal storage_init
    # add first file
    mov a0,test_txt_storage_add_file
    mov a1,c_text_storage_add_file_txt_len

    cal storage_add_file
    # add second file
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len

    cal storage_add_file
    # assert
    cal storage_file_count
    mov a1,c_storage_file_count
    add a1,a1,2

    cal assert_eq_int

    # cmp len
    cal storage_len
    mov a1,c_storage_settings_len
    add a1,a1,c_text_storage_add_file_txt_len
    add a1,a1,c_text_storage_add_file_txt_len
    cal assert_eq_int
    # 3
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file
    # 4
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file
    # 5
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file
    # 6
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file
    # 7
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file
    # 8
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len
    cal storage_add_file                # should throw error

    ret


sbmk "storage get file"

# Param
## a0 : index

# Return
# prints

storage_get_file:

    # === SAVE ===
    psh s0                              # |(s0)
    psh s1                              # |s0-(s1)

    mov s0,a0
    # s0 : index

    # !TODO (implemen error handling (<0 >setings size) file count

    # add start addr to index
    add a0,c_storage_file_lookup_start_addr
    mov s0,a0                           # location where addr of file_addr_index is
    cal storage_read_single_byte        # gets the addr pointing

    mov s1,a0                           # store start addr
    # a0 add of start
    # end is len oder nächste start (hier nächste start) !TODO nächste start / len ausäwlen
    inc s0                              # get next file index start add to know end
    mov a0,s0
    cal storage_read_single_byte

    # size of file
    sub a2,a0,s1

    mov a0,read_buffer
    mov a1,s1
    #Args: a0:dst_address, a1:src_address, a2:size
    syscall SYS_STORAGE_READ
    # === PRINT ===
    mov a0, read_buffer
    syscall SYS_PRINT_LINE_STRING

    # === LOAD ===
    pop s1                              # |a0-[s1]
    pop s0                              # |[a0]

    ret

# [test]
txt_storage_get_file:  emb string "storage_get_file"
test_storage_get_file:
    mov a0,txt_storage_get_file
    cal print_method_name

    # init
    cal storage_init
    # add first file
    mov a0,test_txt_storage_add_file
    mov a1,c_text_storage_add_file_txt_len

    cal storage_add_file
    # add second file
    mov a0,test_txt_storage_add_file_2
    mov a1,c_text_storage_add_file_txt_len

    cal storage_add_file
    # assert
    cal storage_file_count
    mov a1,c_storage_file_count
    add a1,a1,2

    # get value
    mov a0,0
    cal storage_get_file
    ret


bmk "start"

_start: # Runs once when the VM starts.
    cal test_storage
    #cal storage_clear
    exit
