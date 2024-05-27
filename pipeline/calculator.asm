.text
    lui  s1, 0xFFFFF   # Address of IO device
Test:  
    lw s0, 0x70(s1)  		# Fetch instruction from switch	
    srli a0, s0, 21		# Shift right for 21 bits to compare operation code
    andi a0, a0, 0x00000007   	# Get opcode
    andi t2, s0, 0x000000FF   	# Get rs2
    srli s9, s0, 8		# Shift right for 8 bits to get rs1
    andi t1, s9, 0x000000FF   	# Getrs1

    beq a0, zero, And 			# opcode = 0?
    addi a1, zero, 1			# opcode = 1? 
    beq a0, a1, Or  		
    addi a1, a1, 1			# opcode = 2?
    beq a0, a1, Xor
    addi a1, a1, 1			# opcode = 3?
    beq a0, a1, ShiftLeft  
    addi a1, a1, 1  			# opcode = 4?
    beq a0, a1, ShiftRight    
    addi a1, a1, 1			# opcode = 5?
    beq a0, a1, Conditional
    addi a1, a1, 1			# opcode = 6?
    beq a0, a1, Division 

And:					# Operation Add Execute
    and t0, t1, t2      
    jal zero, Store

Or:					# Operation Or Execute
    or t0, t1, t2      
    jal zero, Store

Xor:					# Operation Xor Execute
    xor t0, t1, t2       
    jal zero, Store

ShiftLeft:   				# Operation Sll Execute
    andi t3, t1, 0x80
    sll t4, t1, t2   
    andi s4, t4, 0x7F 
    add t0, t3, s4   
    jal zero, Store

ShiftRight:  				# Operation Srl Execute
    andi t3, t1, 0x80
    sra t4, t1, t2
    andi s4, t4, 0x3F 
    add t0, t3, s4  
    jal zero, Store

Conditional:				# Operation Conditional Execute
    bne t1, zero, ConditionalElse      
    add t0, zero, t2     
    jal zero, Store

ConditionalElse:			#Branch
    andi s8, t2, 0x80
    bne s8, zero, GetComplement
    andi t0, t2, 0x00FF
    jal zero, Store
    
GetComplement:				# Get the Complement of rs2
    andi s9, t2, 0x7F
    xori t0, s9, -1 
    addi t0, t0, 1  
    jal zero, Store

Division:  
    andi s10, t1, 0x80
    srli s10, s10, 7
    andi s11, t2, 0x80
    srli s11, s11, 7
    xor s6, s10, s11
    beq s6, zero, Assign0
    addi t0, zero, 1
    jal zero, AbsOfA
    
Assign0:
    addi t0, zero, 0

AbsOfA:
    beq s10, zero, AbsOfB
    andi t1, t1, 0x7F
    
AbsOfB:
    beq s11, zero, Cal	
    andi t2, t2, 0x7F
Cal:	
    slli s2, t2, 6
    addi s5, zero, 6
        
Loop:
    sub t1, t1, s2
    bge t1, zero, Reserve
    add t1, t1, s2   
    slli t0, t0, 1
    srli s2, s2, 1
    beq s5, zero, Store
    sub s5, s5, a1
    jal zero, Loop

Reserve:
    slli t0, t0, 1
    addi t0, t0, 1
    srli s2, s2, 1
    beq s5, zero, Store
    sub s5, s5, a1
    jal zero, Loop

Store:
Bit0To4:
    addi s3, zero, 0
    andi t5, t0, 0x1
    beq t5, zero, Bit5To8
    add s3, s3, a1
Bit5To8:
    andi t5, t0, 0x2
    beq t5, zero, Bit9To12
    slli s7, a1, 4
    add s3, s3, s7
Bit9To12:
    andi t5, t0, 0x4
    beq t5, zero, Bit13To16
    slli s7, a1, 8
    add s3, s3, s7
Bit13To16:
    andi t5, t0, 0x8
    beq t5, zero, Bit17To20
    slli s7, a1, 12
    add s3, s3, s7
Bit17To20:
    andi t5, t0, 0x10
    beq t5, zero, Bit21To24
    slli s7, a1, 16
    add s3, s3, s7
Bit21To24:
    andi t5, t0, 0x20
    beq t5, zero, Bit25To28
    slli s7, a1, 20
    add s3, s3, s7
Bit25To28:
    andi t5, t0, 0x40
    beq t5, zero, Bit29to32
    slli s7, a1, 24
    add s3, s3, s7
Bit29to32:
    andi t5, t0, 0x80
    beq t5, zero, Display
    slli s7, a1, 28
    add s3, s3, s7
    
Display:
    sw   t0, 0x60(s1)		# write led	
    sw   s3, 0x00(s1)           # write digit
    jal zero, Test
