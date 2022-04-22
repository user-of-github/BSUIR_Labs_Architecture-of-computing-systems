.globl iterative
.globl recursive

.data
    n: .word 8
    m: .word 2

.text

    main:
        jal ra, tester

        addi a1, t3, 0
        addi a0, zero, 1
        ecall # Print Result

        addi a1, zero, '\n'
        addi a0, zero, 11
        ecall # Print newline

        addi a0, zero, 10
        ecall # Exit

    tester:
        addi a1, zero, 5
    
        sw ra, 8(sp)
	    jal iterative
        addi t3, a0, 0
        lw ra, 8(sp)

        jr ra

    iterative: # a1 ---> argument
        addi t0, zero, 0 # counter
        addi a0, zero, 1 # response

        count_factorial_iterative:
            beq t0, a1, finished_counting_factorial_iterative
            addi t0, t0, 1
            mul a0, a0, t0

            j count_factorial_iterative

        finished_counting_factorial_iterative:
            jr ra
    
    recursive:
        # YOUR CODE HERE
	    #jalr zero, 0(ra)