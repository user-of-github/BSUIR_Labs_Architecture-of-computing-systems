.globl function


.data
    data_array: .word   6, 61, 17, -38, 19, 42, 5, -1 


.text
    main:
        addi     a2, zero, 0 # test value to check: 0
        la       a3, data_array # copied address of data_array to a3

        jal      ra, function

        jal      ra, print_int
        jal      ra, print_newline

        #return
        addi     a0, zero, 10
        ecall


    # a2 значение для которого мы хотим вычислить функцию f
    # a3 адрес выходного ("output") массива, содержащего все допустимые варианты.
    # a0 - function's response
    function:
        addi     t0, a2, 3 # t0 = a2 + 3 (shift += 3, because I have possible args: range(-3, 3, 1)
        slli     t0, t0, 2 # t0 *= 4
        add      t0, t0, a3 # t0 = address of arr[counter]
        lw       t1, 0(t0) 
        mv       a0, t1 # response = t1 (a0 = t1)

        jr       ra # return


    print_int: # from a0
        mv      a1, a0
        addi    a0, zero, 1
        ecall

        jr      ra


    print_newline:
        addi    a1, zero, '\n'
        addi    a0, zero, 11
        ecall

        jr      ra
