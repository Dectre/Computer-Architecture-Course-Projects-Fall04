    addi x1, x0, 0
    addi x2, x0, 0
    addi x8, x0, 20
    addi x4, x0, 19

LOOP1:
    slt x12, x2, x4
    beq x12, x0, done

    addi x3, x0, 0
    addi x7, x1, 0
    sub  x9, x4, x2

LOOP2:
    slt x10, x3, x9
    beq x10, x0, outer_next

    lw  x5, 0(x7)
    lw  x6, 4(x7)
    slt x11, x6, x5
    beq x11, x0, no_swap

    sw  x6, 0(x7)
    sw  x5, 4(x7)

no_swap:
    addi x3, x3, 1
    addi x7, x7, 4
    jal  x0, LOOP2

outer_next:
    addi x2, x2, 1
    jal  x0, LOOP1

done:
    jal x0, done
