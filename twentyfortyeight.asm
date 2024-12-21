# CS 21 -- S1 AY 2024-2025
# Angela Nicole Flores, Anton Chio -- 12/14/2024
# twentyfortyeight.asm -- extended 2048 game


# -- Data
.data
n: 		.word	0x00000006
matrix: 	.word 	0x00000000


# -- Marcos
.macro syscaller(%n)
	li $v0, %n
	syscall			
.end_macro

.macro 	print_str(%str)
	la $a0, %str
	syscaller(4)
.end_macro

.macro 	print_int(%int)
	la $a0, %int
	syscaller(1)
.end_macro

.macro exit
	syscaller(10)
.end_macro

.macro malloc
	la   $t0, n		# n = t0
    	lw   $t0, 0($t0)
    	mult $t0, $t0 		# n * n
    	mflo $t1		# t1 = lower 32 bits of  binary  n*n
    	li   $t0, 4		# t0 = constant 4 (word size0
    	mult $t1, $t0		# n * n * 4			
    	mflo $t2		# t2 = lower 32 bits of  binary  n*n*4
    	addi $t2, $t2, 4	# 1 word offset for adjusted sp value
    	subu $sp, $sp, $t2	
    	la   $t3, matrix
    	sw   $sp, 0($t3)
    	flush_reg
.end_macro

.macro cell_num(%dst_reg, %row_num, %col_num)
    	subi %dst_reg, %row_num, 1      		# dst = row num value - 1
    	mult %dst_reg, $t0           			# dst = (row num - 1) * n
    	mflo %dst_reg            			# Saves the lower-order bits of the product of $destination = row number - 1 and $t0 = n into $destination 
    	addu %dst_reg, %dst_reg, %col_num 		# $destination = ((row number - 1) * n + column number)
.end_macro
		
.macro pick(%cell_num)
	li   $t6, 4			# Loads 4, equal to how many bytes a word has in MIPS, into $t6 to start initializing the offset added to the value of matrix
	mult $t6, %cell_num		# $t6 = 4 * number of the cell to write to
	mflo $t6			# Saves the lower-order bits of product of $t6 = 4 and %cell_number = number of the cell to write to into $t6
	la   $t7, matrix		# Loads the address where matrix is stored in the data segment into $t7
	lw   $t7, 0($t7)		# Loads the *value* of matrix into $t7
	addu $t7, $t7, $t6		# Adds the offset to the value of matrix to get the address of the cell to write to
    	lw   $t8, 0($t7)		
.end_macro

.macro place(%cell_num, %val)
	li	$t6, 4			# Loads 4, equal to how many bytes a word has in MIPS, into $t6 to start initializing the offset added to the value of matrix
	mult	$t6, %cell_num	# $t6 = 4 * number of the cell to write to
	mflo	$t6			# Saves the lower-order bits of product of $t6 = 4 and %cell_number = number of the cell to write to into $t6
	la 	$t7, matrix		# Loads the address where matrix is stored in the data segment into $t7
	lw 	$t7, 0($t7)		# Loads the *value* of matrix into $t7
	addu	$t7, $t7, $t6		# Adds the offset to the value of matrix to get the address of the cell to write to
	sw	%val, 0($t7)		# Stores %value to the cell to write to
.end_macro

.macro flush_reg
    	li $t0, 0
    	li $t1, 0
    	li $t2, 0
    	li $t3, 0
    	li $t4, 0
    	li $t5, 0
    	li $t6, 0
    	li $t7, 0
    	li $t8, 0
    	li $t9, 0
    	li $a0, 0
    	li $a1, 0
    	li $a2, 0
    	li $a3, 0
     	li $s0, 0
    	li $s1, 0
    	li $s2, 0
    	li $s3, 0
    	li $s4, 0
    	li $s5, 0
    	li $s6, 0
    	li $s7, 0
.end_macro


# -- Assignments



.text
main:           
    malloc		# memory for 3x3 matrix

    # Cell 1 (Row 1, Col 1)
    li $s3, 1           # cell num
    li $s4, 1           # val = 1
    place($s3, $s4)     # cell = val

    # Cell 2 (Row 1, Col 2)
    li $s3, 2
    li $s4, 2
    place($s3, $s4)	# cell = val = 2

    # Cell 3 (Row 1, Col 3)
    li $s3, 3
    li $s4, 3
    place($s3, $s4)	# cell = val = 3

    # Cell 4 (Row 2, Col 1)
    li $s3, 4
    li $s4, 4
    place($s3, $s4)      # cell = val = 4

    # Cell 5 (Row 2, Col 2)
    li $s3, 5
    li $s4, 5
    place($s3, $s4)      # cell = val = 5

    # Cell 6 (Row 2, Col 3)
    li $s3, 6
    li $s4, 6
    place($s3, $s4)      # cell = val = 6

    # Cell 7 (Row 3, Col 1)
    li $s3, 7
    li $s4, 7
    place($s3, $s4)      # cell = val = 7

    # Cell 8 (Row 3, Col 2)
    li $s3, 8
    li $s4, 8
    place($s3, $s4)      # cell = val = 8

    # Cell 9 (Row 3, Col 3)
    li $s3, 9
    li $s4, 9
    place($s3, $s4)      # cell = val = 9


#

up: 	subu $sp, $sp, 4		# allocate stack space
	sw   $ra, 0($sp)		# return addr of up move into memory
	jal  up_shift			# shift matrix up
	jal  up_merge			# merge same value cells up
	jal  up_shift			# compresses matrix up

up_end:
	flush_reg
	lw   $ra, 0($sp)	# ra = return addr of up move from memory
	addu $sp, $sp, 4	# deallocates stack space
    	jr   $ra

#

up_shift:
	subu $sp, $sp, 4	# allocate stack space
	sw   $ra, 0($sp)	# return addr of up_shift into memory
	la   $t0, n             # t0 = addr of n in data segment
    	lw   $t0, 0($t0)        # t0 = value of n

up_scol:
	li   $t1, 1              # t1 = column num (1-indexed)

up_scol_check:
	bgt  $t1, $t0, up_shift_end 	# exit when all cols done

up_srow:
	li   $t2, 1              # t2 = row num (1-indexed)
	li   $t3, 1		 # t3 = adjusted (nonzero) row index (1-indexed)

up_srow_check:
	bgt  $t2, $t0, up_zero_fill	# zero fill cols when all rows done
	cell_num($t4, $t2, $t1)		# cell num to read -> t4
	pick($t4)			# cell val to read -> t8
	beqz $t8, up_next_srow		# read cell = empty -> next row
	cell_num($t5, $t3, $t1)		# write in cell num -> t5
	place($t5, $t8)			# adjusted row index = read cell val
	addi $t3, $t3, 1		# (nonzero) row num val + 1

up_next_srow: 
	addi $t2, $t2, 1		# row num + 1
	j    up_srow_check

up_zero_fill:
	bgt  $t3, $t0, up_next_scol	# zero fill done -> next col
	cell_num($t5, $t3, $t1)		# write in cell num -> t5
	place($t5, $0)			# adjusted row index = 0
	addi $t3, $t3, 1       		# Increments the value of the nonzero row number by 1
	j    up_zero_fill    		# Continues filling zeroes

up_next_scol:	
	addi $t1, $t1, 1		# Increments the value of the column number by 1
	j    up_scol_check			# Processes the next column

up_shift_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of up_shift from memory into $ra
    	addu $sp, $sp, 4        	# deallocate stack space
    	jr   $ra

#

up_merge:
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of up_merge into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

up_mcol: 
	li   $t1, 1              	# Initializes the column number into $t1 (1-indexed)

up_mcol_check:
	bgt  $t1, $t0, up_merge_end 	# Exits the loop if all columns are processed

up_mrow:
	li   $t2, 1              	# Initializes the row number into $t2 (1-indexed)

up_mrow_check:
	bge  $t2, $t0, up_next_mcol  # up_mrow_check processes values by pair. The next column is processed if all needed cells in the column are merged or, alternatively, if there is no pair left to process in the column
	cell_num($t3, $t2, $t1)		# Gets the number of the current cell in the column and stores it at $t3
	pick($t3)				# Gets the value of the current cell in the column and stores it at $t8
	move $t9, $t8          	# Saves the value of the current cell in the column in $t9 for comparison with the value of the next cell
	addi $t2, $t2, 1		# Increments the value of the row number by 1
	cell_num($t4, $t2, $t1)		# Gets the number of the next cell in the column and stores it at $t4
	pick($t4)				# Gets the value of the next cell in the column and stores it at $t8
	bne  $t9, $t8, up_mrow_check 	# No merge occurs if the cells are not equal. The next pair of rows are processed e.g. from rows 1 and 2 to rows 2 and 3
	add  $t9, $t9, $t8		# Essentially doubles the value of $t9 and stores it back to the same register
	place($t3, $t9)			# Stores the merged value to the current cell in the column
	place($t4, $0)			# Stores zero to the next cell in the column
	addi $t2, $t2, 1       	# Increments the value of the row number by 1 to process the next pair of rows e.g. from rows 1 and 2 to rows 3 and 4. Note that this extra increment only occurs when a merge happens
	j    up_mrow_check

up_next_mcol:
	addi $t1, $t1, 1		# Increments the value of the column number by 1
	j    up_mcol_check				# Processes the next column

up_merge_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of merge_up from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra

#

down:
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of down into memory
	jal  down_shift				# Compresses the matrix downward
	jal  down_merge				# Merges cells with the same value downward
	jal  down_shift				# Compresses the matrix downward again to account for merges

down_end:
	flush_reg
	lw   $ra, 0($sp)		# Loads the return address of down from memory into $ra
	addu $sp, $sp, 4		# Deallocates stack space
	jr   $ra

#

down_shift:
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of down_shift into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

down_scol: 
	li   $t1, 1              	# Initializes the column number into $t1 (1-indexed)

down_scol_check:
	bgt  $t1, $t0, down_shift_end 	# Exits the loop if all columns are processed

down_srow:
	move $t2, $t0              	# Initializes the row number into $t2. (1-indexed) Bottom to top traversals entail instantiating at n
	move $t2, $t0		# Initializes the adjusted nonzero row index into $t3. (1-indexed) Bottom to top traversals entail instantiating at n

down_srow_check:
	blt  $t2, 1, down_zero_fill	# Fills needed cells in the column with zeroes if all rows are processed
	cell_num($t4, $t2, $t1)		# Gets the number of the cell to read and stores it at $t4
	pick($t4)				# Gets the value of the cell to read and stores it at $t8
	beqz $t8, down_next_srow	# No store occurs if the read cell is empty. The next row is processed
	cell_num($t5, $t3, $t1)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $t8)			# Stores the value of the read cell to the adjusted row index
	subi $t3, $t3, 1		# Decrements the value of the nonzero row number by 1

down_next_srow: 
	subi $t2, $t2, 1		# Decrements the value of the row number by 1
	j    down_srow_check				# Processes the next pair of rows

down_zero_fill:
	blt  $t3, 1, down_next_scol	# Processes the next column if all needed cells in the column are filled with zeroes
	cell_num($t5, $t3, $t1)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $0)			# Stores zero to the adjusted row index
	subi $t3, $t3, 1       	# Decrements the value of the nonzero row number by 1
	j    down_zero_fill    			# Continues filling zeroes

down_next_scol:
	addi $t1, $t1, 1		# Increments the value of the column number by 1
	j    down_scol_check				# Processes the next column

down_shift_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of down_shift from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

#

down_merge:
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of down_merge into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

down_mcol:
	li   $t1, 1              	# Initializes the column number into $t1 (1-indexed)

down_mcol_check:
	bgt  $t1, $t0, down_merge_end 	# Exits the loop if all columns are processed

down_mrow:
	move $t2, $t0              	# Initializes the row number into $t2. (1-indexed) Bottom to top traversals entail instantiating at n

down_mrow_check:
	ble  $t2, 1, down_next_mcol  # down_mrow_check processes values by pair. The next column is processed if all needed cells in the column are merged or, alternatively, if there is no pair left to process in the column
	cell_num($t3, $t2, $t1)		# Gets the number of the current cell in the column and stores it at $t3
	pick($t3)				# Gets the value of the current cell in the column and stores it at $t8
	move $t9, $t8          	# Saves the value of the current cell in the column in $t9 for comparison with the value of the previous cell
	subi $t2, $t2, 1		# Decrements the value of the row number by 1
	cell_num($t4, $t2, $t1)		# Gets the number of the previous cell in the column and stores it at $t4
	pick($t4)				# Gets the value of the previous cell in the column and stores it at $t8
	bne  $t9, $t8, down_mrow_check # No merge occurs if the cells are not equal. The next pair of rows are processed e.g. from rows n and (n - 1) to rows (n - 1) and (n - 2)
	add  $t9, $t9, $t8		# Essentially doubles the value of $t9 and stores it back to the same register
	place($t3, $t9)			# Stores the merged value to the current cell in the column
	place($t4, $0)			# Stores zero to the previous cell in the column
	subi $t2, $t2, 1       	# Decrements the value of the row number by 1 to process the next pair of rows e.g. from rows n and (n - 1) to rows (n - 2) and (n - 3). Note that this extra increment only occurs when a merge happens
	j    down_mrow_check

down_next_mcol:
	addi $t1, $t1, 1		# Increments the value of the column number by 1
	j    down_mcol_check				# Processes the next column

down_merge_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of merge_down from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

#

left: 
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of left into memory
	jal  left_shift				# Compresses the matrix leftward
	jal  left_merge				# Merges cells with the same value leftward
	jal  left_shift				# Compresses the matrix leftward again to account for merges

left_end:
	flush_reg
	lw   $ra, 0($sp)		# Loads the return address of left from memory into $ra
	addu $sp, $sp, 4		# Deallocates stack space
    	jr   $ra					# Return

#

left_shift:
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of left_shift into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

left_srow: 
	li   $t1, 1              	# Initializes the row number into $t1 (1-indexed)

left_srow_check:
	bgt  $t1, $t0, left_shift_end 	# Exits the loop if all rows are processed

left_scol:
	li   $t2, 1              	# Initializes the column number into $t2 (1-indexed)
	li   $t3, 1			# Initializes the adjusted nonzero column index into $t3 (1-indexed)

left_scol_check:
	bgt  $t2, $t0, left_zero_fill	# Fills needed cells in the row with zeroes if all columns are processed
	cell_num($t4, $t1, $t2)		# Gets the number of the cell to read and stores it at $t4
	pick($t4)				# Gets the value of the cell to read and stores it at $t8
	beqz $t8, left_next_scol	# No store occurs if the read cell is empty. The next column is processed
	cell_num($t5, $t1, $t3)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $t8)			# Stores the value of the read cell to the adjusted column index
	addi $t3, $t3, 1		# Increments the value of the nonzero column number by 1

left_next_scol: 
	addi $t2, $t2, 1		# Increments the value of the column number by 1
	j    left_scol_check

left_zero_fill: 
	bgt  $t3, $t0, left_next_srow	# Processes the next row if all needed cells in the row are filled with zeroes
	cell_num($t5, $t1, $t3)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $0)			# Stores zero to the adjusted column index
	addi $t3, $t3, 1       	# Increments the value of the nonzero column number by 1
	j    left_zero_fill    			# Continues filling zeroes

left_next_srow:
	addi $t1, $t1, 1		# Increments the value of the row number by 1
	j    left_srow_check				# Processes the next row

left_shift_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of left_shift from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

#

left_merge: 
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of left_merge into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
    	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

left_mrow:
	li   $t1, 1              	# Initializes the row number into $t1 (1-indexed)

left_mrow_check:
	bgt  $t1, $t0, left_merge_end 	# Exits the loop if all rows are processed

left_mcol:
	li   $t2, 1              	# Initializes the column number into $t2 (1-indexed)

left_mcol_check:
	bge  $t2, $t0, left_next_mrow	# left_mcol_check processes values by pair. The next row is processed if all needed cells in the row are merged or, alternatively, if there is no pair left to process in the row
	cell_num($t3, $t1, $t2)		# Gets the number of the current cell in the row and stores it at $t3
	pick($t3)				# Gets the value of the current cell in the row and stores it at $t8
	move $t9, $t8          	# Saves the value of the current cell in the row in $t9 for comparison with the value of the next cell
	addi $t2, $t2, 1		# Increments the value of the column number by 1
	cell_num($t4, $t1, $t2)		# Gets the number of the next cell in the row and stores it at $t4
	pick($t4)				# Gets the value of the next cell in the row and stores it at $t8
	bne  $t9, $t8, left_mcol_check # No merge occurs if the cells are not equal. The next pair of columns are processed e.g. from columns 1 and 2 to columns 2 and 3
	add  $t9, $t9, $t8		# Essentially doubles the value of $t9 and stores it back to the same register
	place($t3, $t9)			# Stores the merged value to the current cell in the row
	place($t4, $0)			# Stores zero to the next cell in the row
	addi $t2, $t2, 1       	# Increments the value of the column number by 1 to process the next pair of columns e.g. from columns 1 and 2 to columns 3 and 4. Note that this extra increment only occurs when a merge happens
	j    left_mcol_check

left_next_mrow:
	addi $t1, $t1, 1		# Increments the value of the row number by 1
	j    left_mrow_check				# Processes the next row

left_merge_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of merge_left from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

#

right: 
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of right into memory
	jal  right_shift				# Compresses the matrix rightward
	jal  right_merge				# Merges cells with the same value rightward
	jal  right_shift				# Compresses the matrix rightward again to account for merges

right_end:
	flush_reg
	lw   $ra, 0($sp)		# Loads the return address of right from memory into $ra
	addu $sp, $sp, 4		# Deallocates stack space
    	jr   $ra					# Return

#

right_shift: 
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of right_shift into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

right_srow:
	li   $t1, 1              	# Initializes the row number into $t1 (1-indexed)

right_srow_check:  
	bgt  $t1, $t0, right_shift_end 	# Exits the loop if all rows are processed

right_scol: 
	move $t2, $t0              	# Initializes the column number into $t2. (1-indexed) Right to left traversals entail instantiating at n
	move $t2, $t0		# Initializes the adjusted nonzero column index into $t3. (1-indexed) Right to left traversals entail instantiating at n

right_scol_check:
	blt  $t2, 1, right_zero_fill	# Fills needed cells in the row with zeroes if all columns are processed
	cell_num($t4, $t1, $t2)		# Gets the number of the cell to read and stores it at $t4
	pick($t4)				# Gets the value of the cell to read and stores it at $t8
	beqz $t8, right_next_scol	# No store occurs if the read cell is empty. The next column is processed
	cell_num($t5, $t1, $t3)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $t8)			# Stores the value of the read cell to the adjusted column index
	subi $t3, $t3, 1		# Decrements the value of the nonzero column number by 1

right_next_scol:
	subi $t2, $t2, 1		# Decrements the value of the column number by 1
	j    right_scol_check				# Processes the next column

right_zero_fill:
	blt  $t3, 1, right_next_srow	# Processes the next row if all needed cells in the row are filled with zeroes
	cell_num($t5, $t1, $t3)		# Gets the number of the cell to write to and stores it at $t5
	place($t5, $0)			# Stores zero to the adjusted column index
	subi $t3, $t3, 1       	# Decrements the value of the nonzero column number by 1
	j    right_zero_fill    			# Continues filling zeroes

right_next_srow:
	addi $t1, $t1, 1		# Increments the value of the row number by 1
	j    right_srow_check				# Processes the next row

right_shift_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of right_shift from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

#

right_merge: 
	subu $sp, $sp, 4		# Allocates space in the stack
	sw   $ra, 0($sp)		# Stores the return address of right_merge into memory
	la   $t0, n              	# Loads the address where n is stored in the data segment into $t0
	lw   $t0, 0($t0)         	# Loads the *value* of n into $t0

right_mrow:
	li   $t1, 1              	# Initializes the row number into $t1 (1-indexed)

right_mrow_check:
	bgt  $t1, $t0, right_merge_end 	# Exits the loop if all rows are processed

right_mcol:
	move $t2, $t0              	# Initializes the column number into $t2. (1-indexed) Right to left traversals entail instantiating at n

right_mcol_check:
	ble  $t2, 1, right_next_mrow 	# col_mright_for processes values by pair. The next row is processed if all needed cells in the row are merged or, alternatively, if there is no pair left to process in the row
	cell_num($t3, $t1, $t2)		# Gets the number of the current cell in the row and stores it at $t3
	pick($t3)				# Gets the value of the current cell in the row and stores it at $t8
	move $t9, $t8          	# Saves the value of the current cell in the row in $t9 for comparison with the value of the previous cell
	subi $t2, $t2, 1		# Decrements the value of the column number by 1
	cell_num($t4, $t1, $t2)		# Gets the number of the previous cell in the row and stores it at $t4
	pick($t4)				# Gets the value of the previous cell in the row and stores it at $t8
	bne  $t9, $t8, right_mcol_check # No merge occurs if the cells are not equal. The next pair of columns are processed e.g. from columns n and (n - 1) to columns (n - 1) and (n - 2)
	add  $t9, $t9, $t8		# Essentially doubles the value of $t9 and stores it back to the same register
	place($t3, $t9)			# Stores the merged value to the current cell in the row
	place($t4, $0)			# Stores zero to the previous cell in the row
	subi $t2, $t2, 1       	# Decrements the value of the column number by 1 to process the next pair of columns e.g. from columns n and (n - 1) to columns (n - 2) and (n - 3). Note that this extra increment only occurs when a merge happens
	j    right_mcol_check

right_next_mrow:
	addi $t1, $t1, 1		# Increments the value of the row number by 1
	j    right_mrow_check				# Processes the next row

right_merge_end:
	flush_reg
	lw   $ra, 0($sp)        	# Loads the return address of merge_rght from memory into $ra
    	addu $sp, $sp, 4        	# Deallocates stack space
    	jr   $ra                			# Return

moves_counter:
    addi $s0, $s0, 1