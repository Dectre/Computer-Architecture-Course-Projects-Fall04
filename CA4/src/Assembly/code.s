start:
    addi x10, x0, 0
    addi x11, x0, 9
    lw   x12, 0(x10)
    addi x10, x10, 4

loop:
    beq  x11, x0, finish
    lw   x13, 0(x10)
    slt  x14, x13, x12
    beq  x14, x0, skip_update
    add  x12, x13, x0

skip_update:
    addi x10, x10, 4
    addi x11, x11, -1
    jal  x0, loop

finish:
    addi x15, x0, 400
    sw   x12, 0(x15)