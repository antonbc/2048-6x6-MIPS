.macro do_syscall(%n) # Performs syscalls
    li $v0, %n
    syscall
.end_macro

.macro read_integer # reads input integer
    do_syscall(5)                 
.end_macro

.macro read_string # reads input integer
    do_syscall(12)     
    move $a0, $v0            
.end_macro

.macro print_integer(%label) # print an integer
    move $a0, %label            
    do_syscall(1)                 
.end_macro

.macro print_string(%label) # print a string
    la $a0, %label
    do_syscall(4)
.end_macro

.macro generate_random_number
    do_syscall(42)
.end_macro

.macro exit
    do_syscall(10)                
.end_macro

.macro set_all_temp_registers_to_zero
    li $t0, 0
    li $t1, 0
    li $t2, 0
    li $t3, 0
    li $t4, 0
    li $t5, 0
    li $t6, 0
    li $t7, 0
    li $t9, 0
.end_macro

.macro set_all_save_registers_to_zero
    li $s0, 0
    li $s1, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
    li $s7, 0
.end_macro

.macro set_all_registers_to_zero
    li $s0, 0
    li $s1, 0
    li $s2, 0
    li $s3, 0
    li $s4, 0
    li $s5, 0
    li $s6, 0
    li $s7, 0
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
.end_macro


.data
menu_msg:              .asciiz "Choose [1] or [2]: \n[1] New Game \n[2] Start from a State \n"
start_from_state_msg:  .asciiz "Enter a board configuration:\n"
grid_line:             .asciiz "+----+----+----+----+----+----+\n"    
cell_left_border:      .asciiz "|"                 
cell_end_border:       .asciiz "|\n"              
cell_space:            .asciiz " "  
empty_cell:            .asciiz " "             
enter_move:            .asciiz "Enter a move (A, D, W, S, 3, 4): "
win_msg:               .asciiz "Congratulations! You have reached the 2048 tile!\n"
lose_msg:              .asciiz "Game over..\n"
invalid_input:         .asciiz "Invalid input. Try again.\n"
newline:               .asciiz "\n"
moves_text:            .asciiz "Moves: "
score_text:            .asciiz "Score: "

n:                     .word 6 # Grid size (can be changed to any value)
backup_grid:           .space 148 # Gird copy will be ((6x6 = 36) x 4 bytes) + extra 4bytes = 148 just in case for return address

.text
main:
    li $s5, 4
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s3, $t0              # Store n in $s3 for later use

    # Calculate total grid memory size (n * n * 4 bytes for integers)
    mul  $t1, $t0, $t0         # n * n (number of cells)
    mul  $t1, $t1, 4           # n * n * 4 (bytes per cell)

    # Allocate space for the grid and the return address
    addi $t1, $t1, 4           # Add 4 bytes for the return address
    subu $sp, $sp, $t1         # Adjust stack pointer to create space
    move $s4, $sp              # Base address of the grid is now in $s4

    # Store the return address at the top of the allocated space
    sw   $ra, 0($s4)           # Save return address at the top of the allocated space

game_choice_loop:
    jal get_game_choice
    beq $s0, 1, new_game
    beq $s0, 2, start_from_state
    j game_choice_loop

get_game_choice:
    print_string(menu_msg)
    read_integer
    move $s0, $v0              # Store user input in $s0
    jr $ra

new_game:
    li $s0, 0
    jal random_two_index     # Get two random indices in $s1, $s2
    jal store_random_value
    j play_game

    exit

store_random_value:
    li   $t2, 2              # Value to place in grid
    mul  $t0, $s1, 4          # $t0 = $s1 * 4 (byte offset)
    add  $t0, $s4, $t0        # $t0 = base address ($s4) + offset
    li   $t2, 2               # Load the value 2
    sw   $t2, 0($t0)          # Store 2 at the calculated address

    mul  $t1, $s2, 4          # $t1 = $s2 * 4 (byte offset)
    add  $t1, $s4, $t1        # $t1 = base address ($s4) + offset
    li   $t2, 2               # Load the value 2 again
    sw   $t2, 0($t1)          # Store 2 at the calculated address

    # Save $ra before calling print_grid
    addi $sp, $sp, -4         # Allocate space on the stack
    sw   $ra, 0($sp)          # Save the return address

    jal print_grid

    lw   $ra, 0($sp)          # Restore the return address
    addi $sp, $sp, 4          # Deallocate stack space

    jr   $ra  

print_grid:
    li   $t1, 0              # Row counter (initialize to 0)
    li   $t2, 0              # Cell counter (initialize to 0)
    move $t0, $s4            # Base address of grid (stored in $s4)
    print_string(moves_text)
    print_integer($s0)
    print_string(newline)

print_row:
    print_string(grid_line)

print_cell:
    # Check if cell counter equals n (end of row)
    beq  $t2, $s3, new_row
    print_string(cell_left_border)
    lw   $a0, 0($t0)         
    beq  $a0, 0, print_empty_cell # If 0, print empty cell

    move $t3, $a0            
    beq $t3, 0, print_empty_cell
    ble  $t3, 9, print_single_digit
    ble  $t3, 99, print_double_digit
    ble  $t3, 999, print_triple_digit
    ble  $t3, 9999, print_four_digit
    j    increment_cell      

# Print format depends on the number of digits
print_empty_cell:
    print_string(cell_space) 
    print_string(empty_cell) 
    print_string(empty_cell) 
    print_string(cell_space) 
    j    increment_cell      

print_single_digit:
    print_string(cell_space) 
    print_integer($t3)       
    print_string(cell_space) 
    print_string(cell_space) 
    j    increment_cell

print_double_digit:
    print_string(cell_space) 
    print_integer($t3)   
    print_string(cell_space)     
    j    increment_cell

print_triple_digit:
    print_string(cell_space) 
    print_integer($t3)       
    j    increment_cell

print_four_digit:
    print_integer($t3)       
    j    increment_cell

increment_cell:
    addi $t2, $t2, 1         # increment cell counter
    addi $t0, $t0, 4         # move to next cell (4 bytes per integer)
    j    print_cell

new_row:
    print_string(cell_end_border)
    addi $t1, $t1, 1         # increment row counter
    li   $t2, 0              # reset cell counter
    bne  $t1, $s3, print_row # continue to next row if not done
    print_string(grid_line) #final row separator
    jr $ra                    # Return from the function

random_two_index:
    mul  $t2, $s3, $s3       # Calculate total cells n*n
    print_string(newline)

generate_first_index:
    move   $a1, $t2
    generate_random_number    # Generate random number
    move $s1, $a0              

generate_second_index:
    move   $a1, $t2
    generate_random_number
    move $s2, $a0             
    bne  $s2, $s1, generate_two_index_end  # ensure unique indices
    j    generate_second_index # if same regenerate second index

generate_two_index_end:
    jr $ra

# s1 = first random index
# s2 = second random index

start_from_state:
    li $s0, 0
    print_string(start_from_state_msg)
    li   $t0, 0              # cell counter (initialize to 0)
    move $t1, $s4            # base address of grid 
    mul  $t2, $s3, $s3       # calculate total cells (n * n)

# $t2 = 6x6 = 36
input_loop:
    beq  $t0, $t2, input_done # if all cells done
    read_integer
    move $t3, $v0            

validate_input:
    beq  $t3, 0, store_input
    beq  $t3, 2, store_input
    beq  $t3, 4, store_input
    beq  $t3, 8, store_input
    beq  $t3, 16, store_input
    beq  $t3, 32, store_input
    beq  $t3, 64, store_input
    beq  $t3, 128, store_input
    beq  $t3, 256, store_input
    beq  $t3, 512, store_input
    beq  $t3, 1024, store_input
    beq  $t3, 2048, store_input

    # if input is invalid, re-read
    j    input_loop

store_input:
    sw   $t3, 0($t1)         # store the value at the current memory address
    addi $t1, $t1, 4         # move to the next memory address
    addi $t0, $t0, 1         # increment cell counter
    j    input_loop          # next cell

input_done:
    lw   $ra, 0($s4)         # Load return address
    jal print_grid
    j play_game




copy_grid_to_backup:
    li   $t0, 0          # t0 is the loop counter 
    li   $t3, 0   # t3 is the row index for the backup grid

copy_grid_loop:
    mul  $t1, $s3, $s3         
    beq  $t0, $t1, copy_done   # if i = n * n exit loop

    # get value in grid then put in t5
    mul  $t2, $t0, 4          
    add  $t4, $s4, $t2         
    lw   $t5, 0($t4)           

    # put t5 in backup_grid
    add  $t2, $t0, $t0        
    mul  $t2, $t2, 4          
    la   $t6, backup_grid      
    add  $t6, $t6, $t2         
    sw   $t5, 0($t6)           
    
    addi $t0, $t0, 1
    j copy_grid_loop

copy_done:
    jr   $ra                  




compare_grids:
    li   $t0, 0              

compare_loop:

    mul  $t1, $s3, $s3         # t1 = n * n 
    beq  $t0, $t1, compare_done # If i = n * n done


    mul  $t2, $t0, 4           
    add  $t4, $s4, $t2        
    lw   $t5, 0($t4)   # t5 = grid[i]        


    add  $t2, $t0, $t0         
    mul  $t2, $t2, 4           
    la   $t6, backup_grid      
    add  $t6, $t6, $t2        
    lw   $t7, 0($t6)    # t7 = backup_grid[i]

    # Compare grid[i] with backup_grid[i]
    bne  $t5, $t7, grid_not_equal_to_backup # if grid[i] != backup_grid[i]

    addi $t0, $t0, 1
    j compare_loop

grid_not_equal_to_backup:
    li   $t8, 1               # Set $t8 to 1 meaning flag that there is a difference

#======================== MOVES TRACKER
moves_counter:
    add $s0, $s0, 1
    jr   $ra                  

compare_done:
    li   $t8, 0
    jr   $ra                   



#===================================================================================================================
#============================================= GAME MECHANICS ====================================================+=
#===================================================================================================================
play_game:
    jal check_game_status 
    jal copy_grid_to_backup
    set_all_temp_registers_to_zero
    print_string(enter_move)        
    read_string                     
    move $t1, $a0

    print_string(newline)
    li   $t0, 88 # 88 ASCII = X
    beq  $t1, $t0, end_game

    li   $t0, 51 # 51 ASCII = 3
    beq  $t1, $t0, disable_random_generator

    li   $t0, 52 # 52 ASCII = 4
    beq  $t1, $t0, enable_random_generator

    li   $t0, 65 # 65 ASCII = A
    beq  $t1, $t0, swipe_left

    li   $t0, 68 # 68 ASCII = D
    beq  $t1, $t0, swipe_right

    li   $t0, 87 # 87 ASCII = W
    beq  $t1, $t0, swipe_up

    li   $t0, 83 # 83 ASCII = S
    beq  $t1, $t0, swipe_down

    li   $t0, 122 # 122 ASCII = z
    beq  $t1, $t0, undo_move

    print_string(invalid_input) 
    j    play_game 

random_tile_generator:
    beq $t8, $zero, no_change # if flag = 0 no need to generate
    mul  $t2, $s3, $s3       
    move $a1, $t2            

generate_random_index:
    generate_random_number   
    move $s1, $a0            

    mul  $t0, $s1, 4         
    add  $t0, $s4, $t0       

    lw   $t3, 0($t0)         
    beq  $t3, $zero, place_two
    j    generate_random_index

place_two:
    li   $t3, 2              
    sw   $t3, 0($t0)         
    jal print_grid           
    j play_game

no_change:
    jal print_grid
    j play_game

disable_random_generator:
    li   $s5, 3             # if input is 3 disable
    li   $t8, 0
    j    play_game          

enable_random_generator:
    li   $s5, 4       
    li   $t8, 1      
    j    play_game          



#============ SWIPE RIGHT
swipe_right:
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s7, $t0              # Store n in $s7 for later use
    li   $t0, 0                # Row counter initialized to 0

swipe_right_row:
    # Calculate base address of the current row
    mul  $t9, $s7, 4           # Bytes per row = n * 4
    mul  $t1, $t0, $t9         # Row index * Bytes per row
    add  $t2, $s4, $t1         # Base address of the current row

    # Load the row into registers
    lw   $t3, 0($t2)           # Leftmost value
    lw   $t4, 4($t2)
    lw   $t5, 8($t2)
    lw   $t6, 12($t2)
    lw   $t7, 16($t2)
    lw   $t8, 20($t2)          # Rightmost value

    # Shift and Merge
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right
    jal  shift_right_row       # Shift non-zeroes to the right

    jal  merge_right_row       # Merge adjacent values

    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging
    jal  shift_right_row       # Shift again after merging

right_store_back:
    # Store updated row back to memory
    sw   $t3, 0($t2)
    sw   $t4, 4($t2)
    sw   $t5, 8($t2)
    sw   $t6, 12($t2)
    sw   $t7, 16($t2)
    sw   $t8, 20($t2)

    # Increment row counter and check end condition
    addi $t0, $t0, 1
    bne  $t0, 6, swipe_right_row # Process next row if not done

    # Finalize
    jal  compare_grids
    beq  $s5, 4, random_tile_generator
    jal  print_grid

    j play_game


shift_right_row:
    # Begin shifting from right to left
    # Shift 5th to 6th
    bne $t8, $zero, right_shift_4th_to_5th  # If $t8 is not zero, skip
    move $t8, $t7                     # Move $t7 to $t8
    li   $t7, 0                       # Set $t7 to zero

right_shift_4th_to_5th:
    bne $t7, $zero, right_shift_3rd_to_4th  # If $t7 is not zero, skip
    move $t7, $t6                     # Move $t6 to $t7
    li   $t6, 0                       # Set $t6 to zero

right_shift_3rd_to_4th:
    bne $t6, $zero, right_shift_2nd_to_3rd  # If $t6 is not zero, skip
    move $t6, $t5                     # Move $t5 to $t6
    li   $t5, 0                       # Set $t5 to zero

right_shift_2nd_to_3rd:
    bne $t5, $zero, right_shift_1st_to_2nd  # If $t5 is not zero, skip
    move $t5, $t4                     # Move $t4 to $t5
    li   $t4, 0                       # Set $t4 to zero

right_shift_1st_to_2nd:
    bne $t4, $zero, end_right_shift         # If $t4 is not zero, skip
    move $t4, $t3                     # Move $t3 to $t4
    li   $t3, 0                       # Set $t3 to zero

end_right_shift:
    jr $ra                 # End of shifting

merge_right_row:
    # Merge 5th and 6th
    bne $t8, $t7, right_merge_4th_and_5th  # If $t8 != $t7, skip
    add $t8, $t8, $t7                # Add $t7 to $t8
    li  $t7, 0                       # Set $t7 to zero

right_merge_4th_and_5th:
    bne $t7, $t6, right_merge_3rd_and_4th  # If $t7 != $t6, skip
    add $t7, $t7, $t6                # Add $t6 to $t7
    li  $t6, 0                       # Set $t6 to zero

right_merge_3rd_and_4th:
    bne $t6, $t5, right_merge_2nd_and_3rd  # If $t6 != $t5, skip
    add $t6, $t6, $t5                # Add $t5 to $t6
    li  $t5, 0                       # Set $t5 to zero

right_merge_2nd_and_3rd:
    bne $t5, $t4, right_merge_1st_and_2nd  # If $t5 != $t4, skip
    add $t5, $t5, $t4                # Add $t4 to $t5
    li  $t4, 0                       # Set $t4 to zero

right_merge_1st_and_2nd:
    bne $t4, $t3, end_right_merge          # If $t4 != $t3, skip
    add $t4, $t4, $t3                # Add $t3 to $t4
    li  $t3, 0                       # Set $t3 to zero

end_right_merge:
    jr $ra





# =============== SWIPE LEFT
swipe_left:
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s7, $t0              # Store n in $s7 for later use
    li   $t0, 0                # Row counter initialized to 0


swipe_left_row:
    # Calculate base address of the current row
    mul  $t9, $s7, 4           # Bytes per row = n * 4
    mul  $t1, $t0, $t9         # Row index * Bytes per row
    add  $t2, $s4, $t1         # Base address of the current row

    # Load the row into registers
    lw   $t3, 0($t2)           # Leftmost value
    lw   $t4, 4($t2)
    lw   $t5, 8($t2)
    lw   $t6, 12($t2)
    lw   $t7, 16($t2)
    lw   $t8, 20($t2)          # Rightmost value

    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row

    jal merge_left_row

    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row
    jal shift_left_row


left_store_back:
    # Store updated row back to memory
    sw   $t3, 0($t2)
    sw   $t4, 4($t2)
    sw   $t5, 8($t2)
    sw   $t6, 12($t2)
    sw   $t7, 16($t2)
    sw   $t8, 20($t2)

    # Increment row counter and check end condition
    addi $t0, $t0, 1
    bne  $t0, 6, swipe_left_row # Process next row if not done

    # Finalize
    jal  compare_grids
    beq  $s5, 4, random_tile_generator
    jal  print_grid

    j play_game

shift_left_row:
    # Begin shifting from left to right
    # Shift 1st to 2nd
    bne $t3, $zero, left_shift_2nd_to_3rd  # If $t3 is not zero, skip
    move $t3, $t4                     # Move $t4 to $t3
    li   $t4, 0                       # Set $t4 to zero

left_shift_2nd_to_3rd:
    bne $t3, $zero, left_shift_3rd_to_4th  # If $t3 is not zero, skip
    move $t3, $t5                     # Move $t5 to $t3
    li   $t5, 0                       # Set $t5 to zero

left_shift_3rd_to_4th:
    bne $t3, $zero, left_shift_4th_to_5th  # If $t3 is not zero, skip
    move $t3, $t6                     # Move $t6 to $t3
    li   $t6, 0                       # Set $t6 to zero

left_shift_4th_to_5th:
    bne $t3, $zero, left_shift_5th_to_6th  # If $t3 is not zero, skip
    move $t3, $t7                     # Move $t7 to $t3
    li   $t7, 0                       # Set $t7 to zero

left_shift_5th_to_6th:
    bne $t3, $zero, end_left_shift      # If $t3 is not zero, skip
    move $t3, $t8                     # Move $t8 to $t3
    li   $t8, 0                       # Set $t8 to zero

end_left_shift:
    jr $ra          # Return when done



merge_left_row:
    # Merge 1st and 2nd
    bne $t3, $t4, left_merge_2nd_and_3rd  # If $t3 != $t4, skip
    add $t3, $t3, $t4                # Add $t4 to $t3
    li  $t4, 0                       # Set $t4 to zero

left_merge_2nd_and_3rd:
    bne $t4, $t5, left_merge_3rd_and_4th  # If $t4 != $t5, skip
    add $t4, $t4, $t5                # Add $t5 to $t4
    li  $t5, 0                       # Set $t5 to zero

left_merge_3rd_and_4th:
    bne $t5, $t6, left_merge_4th_and_5th  # If $t5 != $t6, skip
    add $t5, $t5, $t6                # Add $t6 to $t5
    li  $t6, 0                       # Set $t6 to zero

left_merge_4th_and_5th:
    bne $t6, $t7, left_merge_5th_and_6th  # If $t6 != $t7, skip
    add $t6, $t6, $t7                # Add $t7 to $t6
    li  $t7, 0                       # Set $t7 to zero

left_merge_5th_and_6th:
    bne $t7, $t8, end_left_merge      # If $t7 != $t8, skip
    add $t7, $t7, $t8                # Add $t8 to $t7
    li  $t8, 0                       # Set $t8 to zero

end_left_merge:
    jr $ra          # Return when done





#=========== SWIPE UP
swipe_up:
    set_all_temp_registers_to_zero
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s7, $t0              # Store n in $s7 for later use
    li   $t0, 0                # Row counter initialized to 0

swipe_up_column:
    # Calculate base address of the current row
    mul  $t1, $t0, 4
    add  $t2, $s4, $t1

# 0   4  8 12 16 20
# 24 28 32 36 40 44
# 48 52 56 60 64 68
# 72 76 80 84 88 92
# 96 100 104 108 112 116
# 120 124 128 132 136 140

    lw   $t3, 0($t2)           # topmost value
    lw   $t4, 24($t2)
    lw   $t5, 48($t2)
    lw   $t6, 72($t2)
    lw   $t7, 96($t2)
    lw   $t8, 120($t2)          # bottom most value

    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column

    jal merge_up_column

    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column
    jal shift_up_column


up_store_back:
    sw   $t3, 0($t2)           # topmost value
    sw   $t4, 24($t2)
    sw   $t5, 48($t2)
    sw   $t6, 72($t2)
    sw   $t7, 96($t2)
    sw   $t8, 120($t2)         # bottom most value

    addi $t0, $t0, 1
    bne  $t0, 6, swipe_up_column # Process next row if not done

    jal compare_grids
    beq $s5, 4, random_tile_generator
    jal  print_grid
    
    j play_game

shift_up_column:
    # Shift 1st to 2nd
    bne $t3, $zero, up_shift_2nd_to_3rd  # If $t3 is not zero, skip
    move $t3, $t4                     # Move $t4 to $t3
    li   $t4, 0                       # Set $t4 to zero

up_shift_2nd_to_3rd:
    bne $t3, $zero, up_shift_3rd_to_4th  # If $t4 is not zero, skip
    move $t3 $t5                     # Move $t5 to $t4
    li   $t5, 0                       # Set $t5 to zero

up_shift_3rd_to_4th:
    bne $t3, $zero, up_shift_4th_to_5th  # If $t5 is not zero, skip
    move $t3, $t6                     # Move $t6 to $t5
    li   $t6, 0                       # Set $t6 to zero

up_shift_4th_to_5th:
    bne $t3, $zero, up_shift_5th_to_6th  # If $t6 is not zero, skip
    move $t3, $t7                     # Move $t7 to $t6
    li   $t7, 0                       # Set $t7 to zero

up_shift_5th_to_6th:
    bne $t3, $zero, end_up_shift      # If $t7 is not zero, skip
    move $t3, $t8                     # Move $t8 to $t7
    li   $t8, 0                       # Set $t8 to zero

end_up_shift:
    jr $ra          # Return when done


merge_up_column:
    # Merge 1st and 2nd
    bne $t3, $t4, up_merge_2nd_and_3rd  # If $t3 != $t4, skip
    add $t3, $t3, $t4                # Add $t4 to $t3
    li  $t4, 0                       # Set $t4 to zero

up_merge_2nd_and_3rd:
    bne $t4, $t5, up_merge_3rd_and_4th  # If $t4 != $t5, skip
    add $t4, $t4, $t5                # Add $t5 to $t4
    li  $t5, 0                       # Set $t5 to zero

up_merge_3rd_and_4th:
    bne $t5, $t6, up_merge_4th_and_5th  # If $t5 != $t6, skip
    add $t5, $t5, $t6                # Add $t6 to $t5
    li  $t6, 0                       # Set $t6 to zero

up_merge_4th_and_5th:
    bne $t6, $t7, up_merge_5th_and_6th  # If $t6 != $t7, skip
    add $t6, $t6, $t7                # Add $t7 to $t6
    li  $t7, 0                       # Set $t7 to zero

up_merge_5th_and_6th:
    bne $t7, $t8, end_up_merge      # If $t7 != $t8, skip
    add $t7, $t7, $t8                # Add $t8 to $t7
    li  $t8, 0                       # Set $t8 to zero

end_up_merge:
    jr $ra          # Return when done


#============== SWIPE DOWN
swipe_down:
    set_all_temp_registers_to_zero
    la   $a0, n                # Load address of n
    lw   $t0, 0($a0)           # Load grid size into $t0
    move $s7, $t0              # Store n in $s7 for later use
    li   $t0, 5                # Row counter initialized to 5 (last row)

swipe_down_column:
    # Calculate base address of the current row
    mul  $t1, $t0, 4
    add  $t2, $s4, $t1

    lw   $t3, 0($t2)           # bottommost value
    lw   $t4, 24($t2)
    lw   $t5, 48($t2)
    lw   $t6, 72($t2)
    lw   $t7, 96($t2)
    lw   $t8, 120($t2)         # topmost value

    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column

    jal merge_down_column


    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column
    jal shift_down_column


down_store_back:
    sw   $t3, 0($t2)           # bottommost value
    sw   $t4, 24($t2)
    sw   $t5, 48($t2)
    sw   $t6, 72($t2)
    sw   $t7, 96($t2)
    sw   $t8, 120($t2)         # topmost value

    addi $t0, $t0, -1
    bge  $t0, 0, swipe_down_column # Process next row if not done

    jal compare_grids
    beq $s5, 4, random_tile_generator
    jal  print_grid
    
    j play_game

shift_down_column:
    # Shift 6th to 5th
    bne $t8, $zero, down_shift_5th_to_4th  # If $t8 is not zero, skip
    move $t8, $t7                     # Move $t7 to $t8
    li   $t7, 0                       # Set $t7 to zero

down_shift_5th_to_4th:
    bne $t8, $zero, down_shift_4th_to_3rd  # If $t7 is not zero, skip
    move $t8, $t6                     # Move $t6 to $t7
    li   $t6, 0                       # Set $t6 to zero

down_shift_4th_to_3rd:
    bne $t8, $zero, down_shift_3rd_to_2nd  # If $t6 is not zero, skip
    move $t8, $t5                     # Move $t5 to $t6
    li   $t5, 0                       # Set $t5 to zero

down_shift_3rd_to_2nd:
    bne $t8, $zero, down_shift_2nd_to_1st  # If $t5 is not zero, skip
    move $t8, $t4                     # Move $t4 to $t5
    li   $t4, 0                       # Set $t4 to zero

down_shift_2nd_to_1st:
    bne $t8, $zero, end_down_shift      # If $t4 is not zero, skip
    move $t8, $t3                     # Move $t3 to $t4
    li   $t3, 0                       # Set $t3 to zero

end_down_shift:
    jr $ra          # Return when done


merge_down_column:
    # Merge 6th and 5th
    bne $t8, $t7, down_merge_5th_and_4th  # If $t8 != $t7, skip
    add $t8, $t8, $t7                # Add $t7 to $t8
    li  $t7, 0                       # Set $t7 to zero

down_merge_5th_and_4th:
    bne $t7, $t6, down_merge_4th_and_3rd  # If $t7 != $t6, skip
    add $t7, $t7, $t6                # Add $t6 to $t7
    li  $t6, 0                       # Set $t6 to zero

down_merge_4th_and_3rd:
    bne $t6, $t5, down_merge_3rd_and_2nd  # If $t6 != $t5, skip
    add $t6, $t6, $t5                # Add $t5 to $t6
    li  $t5, 0                       # Set $t5 to zero

down_merge_3rd_and_2nd:
    bne $t5, $t4, down_merge_2nd_and_1st  # If $t5 != $t4, skip
    add $t5, $t5, $t4                # Add $t4 to $t5
    li  $t4, 0                       # Set $t4 to zero

down_merge_2nd_and_1st:
    bne $t4, $t3, end_down_merge      # If $t4 != $t3, skip
    add $t4, $t4, $t3                # Add $t3 to $t4
    li  $t3, 0                       # Set $t3 to zero

end_down_merge:
    jr $ra          # Return when done





#==================== Win/Lose CHECKER ==============================

check_game_status:
    # Initialize variables
    li   $t0, 0                # Start index (0)
    li   $t1, 36                # Total number of cells (6x6 grid)

# checking 2048 working dont edit
check_2048_loop:
    # Exit loop if all cells are checked
    beq  $t0, $t1, game_over_check_done

    # Load grid[t0] value
    mul  $t3, $t0, 4           # Offset = index * 4
    add  $t3, $s4, $t3         # Address = grid base + offset
    lw   $t4, 0($t3)           # Load grid[t0] value into $t4

    # If the current cell is 0, there is still space to play
    beq  $t4, $zero, game_continues
    beq  $t4, 2048, win_game
    add $t0, $t0, 1
    j check_2048_loop

game_over_check_done:
    li   $t0, 0                # Start index (0)
    li   $t1, 36                # Total number of cells (6x6 grid)
    
check_top_neighbor:
    li $t5, 0
    sub $t5, $t0, 6           # $t5 = cell - n
    bge  $t5, 6, has_top_neighbor  # If cell >= n (i.e., valid top neighbor)
    j check_bottom_neighbor      # Skip if no valid top neighbor

has_top_neighbor:
    # Load the top neighbor value
    mul  $t6, $t5, 4           # Offset = top index * 4
    add  $t6, $s4, $t6         # Address = grid base + offset
    lw   $t7, 0($t6)           # Load top neighbor value into $t7

    # Check if the top neighbor has the same value
    beq  $t4, $t7, game_continues   # If current cell value == top neighbor, game can continue
    beq  $t7, $zero, game_continues   # if top is zero continue game

check_bottom_neighbor:
    li $t5, 0
    add  $t5, $t0, 6           # $t5 = cell + n
    blt  $t5, 30, has_bottom_neighbor  # If cell < n(n-1) or 6
    j check_left_neighbor       # Skip if no valid bottom neighbor

has_bottom_neighbor:
    # Load the bottom neighbor value
    mul  $t6, $t5, 4           # Offset = bottom index * 4
    add  $t6, $s4, $t6         # Address = grid base + offset
    lw   $t7, 0($t6)           # Load bottom neighbor value into $t7

    # Check if the bottom neighbor has the same value
    beq  $t4, $t7, game_continues   # If current cell value == bottom neighbor, game can continue
    beq  $t7, $zero, game_continues   # if top is zero continue game

check_left_neighbor:
    li $t5, 0
    sub $t5, $t0, 1           # $t5 = cell - 1
    div  $t0, $t1               # cell % n
    mfhi $t6                    # $t6 = cell % n
    bnez $t6, has_left_neighbor  # If cell % 3 != 0, valid left neighbor
    j check_right_neighbor      # Skip if no valid left neighbor

has_left_neighbor:
    # Load the left neighbor value
    mul  $t6, $t5, 4           # Offset = left index * 4
    add  $t6, $s4, $t6         # Address = grid base + offset
    lw   $t7, 0($t6)           # Load left neighbor value into $t7

    # Check if the left neighbor has the same value
    beq  $t4, $t7, game_continues   # If current cell value == left neighbor, game can continue
    beq  $t7, $zero, game_continues   # if top is zero continue game

check_right_neighbor:
    li $t5, 0
    add  $t5, $t0, 1           # $t5 = cell + 1
    div  $t5, $t1               # (cell + 1) % n
    mfhi $t6                    # $t6 = (cell + 1) % 3
    bnez $t6, has_right_neighbor  # If (cell + 1) % 3 != 0, valid right neighbor
    j check_game_over_loop      # Skip if no valid right neighbor

has_right_neighbor:
    # Load the right neighbor value
    mul  $t6, $t5, 4           # Offset = right index * 4
    add  $t6, $s4, $t6         # Address = grid base + offset
    lw   $t7, 0($t6)           # Load right neighbor value into $t7

    # Check if the right neighbor has the same value
    beq  $t4, $t7, game_continues   # If current cell value == right neighbor, game can continue
    beq  $t7, $zero, game_continues   # if top is zero continue game
    
check_game_over_loop:
    # Increment index to check the next cell
    addi $t0, $t0, 1           # Increment index
    beq  $t0, 36, check_game_over_done # If index >= 36, end game check
    j check_game_over_loop      # Otherwise, check next cell

check_game_over_done:
    print_string(lose_msg)
    exit




#======================== UNDO 
# Main idea: pag input ng 'z' sabay print ko si back_up grid since delayed yun
# tapos moves - 1 tapos score tracker for backup_grid
# imove ko nalang yung laman nung backup_grid then babalik ko to memory then print

undo_move:


game_continues:
    jr $ra

win_game:
    print_string(win_msg)
    exit

end_game:
    exit