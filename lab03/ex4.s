.globl iterative
.globl recursive

.data
n: .word 8
m: .word 2

.text
main:
    la t0, n
    lw a0, 0(t0)
    jal ra, tester

    addi a1, a0, 0
    addi a0, x0, 1
    ecall # Print Result

    addi a1, x0, '\n'
    addi a0, x0, 11
    ecall # Print newline

    addi a0, x0, 10
    ecall # Exit

tester:
    # YOUR CODE HERE
    # вызвать итеративную и рекурсивные функции, сравнить ответ и вернуть результат, если совпал. иначе вернуть -1.
	jalr zero, 0(ra)

iterative:
    # YOUR CODE HERE
	jalr zero, 0(ra)
    
recursive:
    # YOUR CODE HERE
	jalr zero, 0(ra)