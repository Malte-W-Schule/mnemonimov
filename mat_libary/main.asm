
bmk "Matrix"


bmk "Matrix"

sbmk "create 1 * 8 matrix"

def MAT1X8_ROWS 8
def MAT1X8_SIZE (MAT1X8_ROWS * 4)   # 8 * 4 = 28 Bytes

mat1x8_get_row:
    # ea = a0 + (a1 * 12) -> jumps to coord
    cea a0, a1, vector.vector_size
    lde f32t,a0,0
    ret

mat1x8_set_row:
    cea a0, a1, 0
    ste f32t, 0, a0
    ret

sbmk "Mat 8x3"

def MAT8X3_ROWS 8
def MAT8X3_SIZE (MAT8X3_ROWS * vector.vector_size)   # 8 * 12 = 96 Bytes

# ------------------------------------------------------------------------------
# Liest eine Zeile (3 Floats) aus einer Matrix
# Input:
#   a0 = Basisadresse der Matrix (z. B. my_matrix)
#   a1 = Zeilenindex (0 bis 7)
# Output:
#   a0..a2 = Werte [x, y, z] dieser Zeile
# ------------------------------------------------------------------------------
mat8x3_get_row:
    # ea = a0 + (a1 * 12) -> springt exakt zur gewünschten Zeile
    cea a0, a1, vector.vector_size

    lde f32t, t0, vector.x
    lde f32t, a1, vector.y
    lde f32t, a2, vector.z
    mov a0, t0
    ret

# ------------------------------------------------------------------------------
# Schreibt eine Zeile (3 Floats) in eine Matrix
# Input:
#   a0..a2 = Werte [x, y, z]
#   a3     = Basisadresse der Matrix
#   a4     = Zeilenindex (0 bis 7)
# ------------------------------------------------------------------------------
mat8x3_set_row:
    cea a3, a4, vector.vector_size

    ste f32t, vector.x, a0
    ste f32t, vector.y, a1
    ste f32t, vector.z, a2
    ret
