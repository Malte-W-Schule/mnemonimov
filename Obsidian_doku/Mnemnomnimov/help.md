
# Stack
## PSH
```

    psh s0                              # | (s0)
	psh s1                              # | s0-(s1)
	psh s2                              # | s0-s1-(s2)
	psh s3                              # | s0-s1-s2-(s3)
	psh s4                            
	psh s5
	psh s6
	psh s7
	psh s8
	psh s9



```
## POP
```

    pop s9
	pop s8
	pop s7
	pop s6
	pop s5
	pop s4                            
	pop s3                              # | s0-s1-s2-[s3]
	pop s2                              # | s0-s1-[s2]
	pop s1                              # | s0-[s1]
	pop s0                              # | [s0]
```