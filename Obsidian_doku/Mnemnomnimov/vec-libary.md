
# vec3 create
## Function
Allocates a 12-byte block in storage for a vec3 instance

## Use
```
vec3_example: res u8t vector.vector_size
```


# vec3 load

```
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

```
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
```
## Functionality:

## Params:
# a0    : source vec3 A address
# a1    : source vec3 B address
# a2    : destination vec3 address

## Output:
cal vec3_add

```

# vec3 load x

```
## Functionality:

## Params:
# a0    : source vec3 address

## Output:
# a0    : x

cal vec3_load_x
```