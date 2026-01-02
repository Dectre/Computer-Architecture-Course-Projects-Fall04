// Register Map:
// x10: Base Address (Pointer to Array)
// x11: Loop Counter (Remaining elements)
// x12: Minimum Value Found So Far
// x13: Current Element Loaded from Array
// x14: Comparison Result (Temp)

start:
    addi x10, x0, 0       // x10 = 0 (Base Address of Array)
    addi x11, x0, 9       // x11 = 9 (We define min as 1st element, so 9 remain)
    
    lw   x12, 0(x10)      // x12 = Array[0] (Assume first element is min)
    addi x10, x10, 4      // x10 = x10 + 4 (Move pointer to Array[1])

loop:
    beq  x11, x0, finish  // If counter (x11) == 0, go to finish
    
    lw   x13, 0(x10)      // x13 = Array[i] (Load current element)
    
    // Check if (Current < Min)
    // slt sets x14 = 1 if x13 < x12, else sets x14 = 0
    slt  x14, x13, x12    
    
    // If x14 == 0 (Current >= Min), skip update
    beq  x14, x0, skip_update 

    // Update Min: Min = Current
    add  x12, x13, x0     // x12 = x13 (Copy x13 to x12)

skip_update:
    addi x10, x10, 4      // Pointer moves to next element
    addi x11, x11, -1     // Decrement counter
    jal  x0, loop         // Jump back to start of loop

finish:
    addi x15, x0, 100     // Address to store result (100)
    sw   x12, 0(x15)      // Store the Minimum Value at Mem[100]

halt:
    jal  x0, halt         // Infinite loop to stop the processor