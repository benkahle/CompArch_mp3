# Calls fibonacci with 4 and 10, returns the sum
main:
  #add $sp, $sp, -8 # Save initial state
  #sw $ra, 4($sp)
  #sw $a0, 0($sp)
  add $v0, $zero, $zero
  add $a0, $zero, 5 # Call fibonacci(4)
  jal fibonacci
  add $t0, $zero, $v0 # save return value in $t0
  #add $a0, $zero, 10 # Call fibonacci(10)
  #jal fibonacci
  #add $v0, $t0, $v0 # Add return value to $t0, and save in $v0 
  #lw $ra, 4($sp) # load initial state
  #lw $a0, 0($sp)
  #add $sp, $sp, 8
  add $v1, $zero, $v0
  li $v0, 10
  syscall
  
# returns fibonacci number of x
# $a0 is argument (x)
# $v0 is result
fibonacci:
  ble $a0, 1, ret1 # return immediates
  
  add $sp, $sp, -12 # Store state
  sw $ra, 8($sp)
  sw $a0, 4($sp)
  sw $v0, 0($sp)
  
  add $a0, $a0, -1 # call Fib_1 
  jal fibonacci
  
  lw $ra, 8($sp)
  lw $a0, 4($sp)
  lw $t0, 0($sp)
  add $v0, $t0, $v0
  sw $v0, 0($sp)
  #add $sp, $sp, 12
  
  add $a0, $a0, -2 #call Fib_1
  jal fibonacci
  
  lw $ra, 8($sp)
  lw $a0, 4($sp)
  lw $t0, 0($sp)
  add $v0, $t0, $v0 # Sum Fib_1 and Fib_2 and return the sum
  sw $v0, 0($sp)
  add $sp, $sp, 12
 
  jr $ra
  
  #lw $ra, 4($sp)
  #lw $a0, 0($sp)
  #add $sp, $sp, 8
  
  ret1:
    beq $a0, 0, ret0
    add $v0, $zero, 1 # if x=1, return 1
    jr $ra
  ret0:
    add $v0, $zero, $zero # if x=0, return 0
    jr $ra