.data
n: .word 9

.text
main:
    add t0, x0, x0 # curr_fib = 0
    addi t1, x0, 1 # next_fib = 1
    la t3, n # получить адрес метки n
    lw t3, 0(t3) # получить значение хранимое по адресу метки n
fib:
    beq t3, x0, finish # выход из цикла после n итераций
    add t2, t1, t0 # new_fib = curr_fib + next_fib;
    mv t0, t1 # curr_fib = next_fib;
    mv t1, t2 # next_fib = new_fib;
    addi t3, t3, -1 # уменьшить счетчик
    j fib # loop
finish:
    addi a0, x0, 1 # аргумент ecall указывающий на печать целого
    addi a1, t0, 0 # аргумент ecall, значение для печати
    ecall # вызов печати целого
    addi a0, x0, 10 # аргумент ecall для завершения программы
    ecall # выход из программы