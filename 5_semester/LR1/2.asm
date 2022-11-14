use16


org 100h


start:
    ; At the beginning we are in real mode
    mov ah, 00
    int 21h

    ; Prohibit masked interruptions
    cli
    ; Prohibit not basked interruptions (NMI)
    in   al, 70h
    or   al, 80h
    out 70h, al


    ; Open Line A20
    in   al, 92h
    or   al, 2
    out 92h, al

    ; Switch to protected mode
    ; Let's try to do smth, we can't allow in protected mode
    mov eax, cr0
    or    al, 1
    mov cr0, eax

    ; In protected mode
    ; Let's try to do smth, we can't allow in protected mode
    ;mov ah, 00
    ;int 21h

    ; Switch to real mode
    mov eax, cr0
    and  al, 0FEh
    mov cr0, eax
    ; Close A20 Line
    in    al, 92h
    and al, 0FDh
    out  92h, al

    ; Allow not masked
    in    al, 70h
    and al, 7Fh
    out  70h, al

    ; Allow masked
    sti

    ; real working again
    ret  
