


# vec3 sub
## Functionality: 
A - B = C

```python
## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

cal vec3_sub
```


# vec3 Normalize

## Functionality: 
Normalizes vector to unit length (^v = v / |v|)
```python
sbmk "vec3 normalize"
## Params:
# a0    : source vec3 address
# a1    : destination vec3 address

## Output:
# none
cal vec3_normalize
```


# vec3 cross product

## Functionality: 
Calculates Cross Product C = A x B
C.x = (A.y * B.z) - (B.y * A.z)
C.y = (A.z * B.x) - (B.z * A.x)
C.z = (A.x * B.y) - (B.x * A.y)

```python
## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

## Output:
# none
cal vec3_cross_product
```


# vec3 dot product

## Functionality
Calculates dot product of two vectors: (A.x*B.x + A.y*B.y + A.z*B.z)

```python
## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address

## Output:
# a0    : dot product scalar (float)
cal vec3_dot_product
```

# assert_eq_vec3_single_value

# Function
returns wether the values are the same ( `true`/`false`)

```python
# Params
## a0 : vec A
## a1 : vec B
## a2 : function to call (vec3_load_x...)

cal assert_eq_vec3_single_value
```

___

#  assert_eq_vec3

# Funktion
Returns [ Correct / Error (is) (should) ]
```python
# Params
## a0:  vec add (is)
## a1:  vec add (should)

cal assert_eq_vec3
```



___
# vec3 copy

## Functionality: 
Copies 12 bytes from source address to destination address

```python
## Params:
# a0    : source vec3 address
# a1    : destination vec3 address

## Output:
# none
cal vec3_copy
```

___
# vec3 create
## Function
Allocates a 12-byte block in storage for a vec3 instance

## Use
```python
vec3_example: res u8t vector.vector_size
```


# vec3 load

```python
## Functionality: Loads x, y, z from memory into registers a0..a2

## Params:
# a0    : source vec3 address

## Output:
# a0    : component x
# a1    : component y
# a2    : component z

cal vec3_load
```

# vec3 store

```python
## Functionality: Stores registers a0..a2 into memory address a3

## Params:
# a0..a2: values x, y, z
# a3    : destination vec3 address

## Output:
# none
cal vec3_store
```
# vec3 add

## Params
- `a0` : source vec3 A address
- `a1` : source vec3 B address
- `a2` : destination vec3 address

## Function
Adds Vec3 A and Vec3 B to Vec3 Dest
# Use
```python
## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

## Output:
cal vec3_add

```

# vec3 load x

```python
## Params:
# a0    : source vec3 address

## Output:
# a0    : x

cal vec3_load_x
```

