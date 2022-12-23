.386p

RM_seg segment para public "CODE" use16
        assume cs:RM_seg, ds:PM_seg, ss:stack_seg
start:
; подготовить сегментные регистры
        push       PM_seg
        pop        ds
; очистить экран
        mov        ax, 3
        int        10h
; вычислить базы для всех дескрипторов сегментов данных
        xor        eax,eax
        mov        ax,RM_seg
        shl        eax,4
        mov        word ptr GDT_16bitCS+2,ax
        shr        eax,16
        mov        byte ptr GDT_16bitCS+4,al
        mov        ax,PM_seg
        shl        eax,4
        mov        word ptr GDT_32bitCS+2,ax
        mov        word ptr GDT_32bitSS+2,ax
        shr        eax,16
        mov        byte ptr GDT_32bitCS+4,al
        mov        byte ptr GDT_32bitSS+4,al
; вычислить линейный адрес GDT
        xor        eax,eax
        mov        ax,PM_seg
        shl        eax,4
        push       eax
        add        eax,offset GDT
        mov        dword ptr gdtr+2,eax
; загрузить GDT
        lgdt       fword ptr gdtr
; вычислить линейные адреса сегментов TSS наших двух задач
        pop        eax
        push       eax
        push       eax
        push       eax
        push       eax
        
        pop        eax
        add        eax,offset TSS_0
        mov        word ptr GDT_TSS0+2, ax
        shr        eax,16
        mov        byte ptr GDT_TSS0+4, al
        
        pop        eax
        add        eax,offset TSS_1
        mov        word ptr GDT_TSS1+2,ax
        shr        eax,16
        mov        byte ptr GDT_TSS1+4,al
        
        pop        eax
        add        eax,offset TSS_2
        mov        word ptr GDT_TSS2+2,ax
        shr        eax,16
        mov        byte ptr GDT_TSS2+4,al
        
        pop        eax
        add        eax,offset TSS_3
        mov        word ptr GDT_TSS3+2,ax
        shr        eax,16
        mov        byte ptr GDT_TSS3+4,al
        
; открыть А20
        mov        al,2
        out        92h,al
; запретить прерывания
        cli
; запретить NMI
        in         al,70h
        or         al,80h
        out        70h,al
; переключиться	в РМ
        mov        eax,cr0
        or         al,1
        mov        cr0,eax
; загрузить CS
        db         66h
        db         0EAh
        dd         offset PM_entry
        dw         SEL_32bitCS

RM_return:
; переключиться	в реальный режим RM
        mov        eax,cr0
        and        al,0FEh
        mov        cr0,eax
; сбросить очередь предвыборки и загрузить CS
        db         0EAh
        dw         $+4
        dw         RM_seg
; настроить сегментные регистры для реального режима
        mov        ax,PM_seg
        mov        ds,ax
        mov        es,ax
        mov        ax,stack_seg
        mov        bx,stack_pointer_start
        mov        ss,ax
        mov        sp,bx
; разрешить NMI
        in         al,70h
        and        al,07FH
        out        70h,al
; разрешить прерывания
        sti
; завершить программу
        mov        ah,4Ch
        int        21h
RM_seg  ends

PM_seg segment para public "CODE" use32
        assume cs:PM_seg

; таблица глобальных дескрипторов
GDT       label    byte
                   db    8 dup(0)
GDT_flatDS         db    0FFh,0FFh,0,0,0,10010010b,11001111b,0
GDT_16bitCS        db    0FFh,0FFh,0,0,0,10011010b,0,0
GDT_32bitCS        db    0FFh,0FFh,0,0,0,10011010b,11001111b,0
GDT_32bitSS        db    0FFh,0FFh,0,0,0,10010010b,11001111b,0
; сегменты TSS задач (32-битный свободный TSS)
GDT_TSS0           db    067h,0,0,0,0,10001001b,01000000b,0
GDT_TSS1           db    067h,0,0,0,0,10001001b,01000000b,0
GDT_TSS2           db    067h,0,0,0,0,10001001b,01000000b,0
GDT_TSS3           db    067h,0,0,0,0,10001001b,01000000b,0
gdt_size = $ - GDT
gdtr               dw    gdt_size-1    ; размер GDT
                   dd    ?             ; адрес GDT
; используемые селекторы
SEL_flatDS         equ   001000b
SEL_16bitCS        equ   010000b
SEL_32bitCS        equ   011000b
SEL_32bitSS        equ   100000b
SEL_TSS0           equ   101000b
SEL_TSS1           equ   110000b
SEL_TSS2           equ   111000b
SEL_TSS3           equ  1000000b

; сегмент TSS_0 будет инициализирован, как только мы выполним переключение
; из нашей основной задачи. 
TSS_0              db    100h dup(0)

; Сегменты TSS_123. В них будет выполняться переключение, так что надо
; инициализировать все, что может потребоваться:

TSS_1              dd    0,0,0,0,0,0,0,0                ; связь, стеки, CR3
                   dd    offset task_1                  ; EIP
; регистры общего назначения
                   dd    0,0,0,0,0,stack_pointer_1,0,0,0B8140h ; (ESP и EDI)
; сегментные регистры
                   dd    SEL_flatDS,SEL_32bitCS,SEL_32bitSS,SEL_flatDS,0,0
                   dd    0                              ; LDTR
                   dd    0                              ; адрес таблицы ввода-вывода
                   
TSS_2              dd    0,0,0,0,0,0,0,0                ; связь, стеки, CR3
                   dd    offset task_2                  ; EIP
; регистры общего назначения
                   dd    0,0,0,0,0,stack_pointer_2,0,0,0B8140h ; (ESP и EDI)
; сегментные регистры
                   dd    SEL_flatDS,SEL_32bitCS,SEL_32bitSS,SEL_flatDS,0,0
                   dd    0                              ; LDTR
                   dd    0                              ; адрес таблицы ввода-вывода
                   
TSS_3              dd    0,0,0,0,0,0,0,0                ; связь, стеки, CR3
                   dd    offset task_3                  ; EIP
; регистры общего назначения
                   dd    0,0,0,0,0,stack_pointer_3,0,0,0B8140h ; (ESP и EDI)
; сегментные регистры
                   dd    SEL_flatDS,SEL_32bitCS,SEL_32bitSS,SEL_flatDS,0,0
                   dd    0                              ; LDTR
                   dd    0                              ; адрес таблицы ввода-вывода

; точка входа в 32-битный защищенный режим
PM_entry:
; подготовить регистры
        xor        eax,eax
        mov        ax,SEL_flatDS
        mov        ds,ax
        mov        es,ax
        mov        ax,SEL_32bitSS
        mov        ebx,stack_pointer_start
        mov        ss,ax
        mov        esp,ebx
; загрузить TSS задачи 0 в регистр TR
        mov        ax,SEL_TSS0
        ltr        ax
; только теперь наша программа выполнила все требования к переходу
; в защищенный режим
        xor        eax,eax
        mov        edi,0B8000h          ; DS:EDI - адрес начала экрана

; настройка менеджера задач
        mov        cx, 1000
        jmp        task_main
        
; процедура небольшой задержки
        wait_proc proc
            push cx
                mov cx, 32000
                wait_loop:
                    nop
                loop wait_loop
            pop cx
            ret
        wait_proc endp

task_main:
; дальний переход на TSS иных задач с задержкой для наглядности

        db         0EAh
        dd         0
        dw         SEL_TSS1
        
        db         0EAh
        dd         0
        dw         SEL_TSS2
        
        db         0EAh
        dd         0
        dw         SEL_TSS3
        
        push       cx
        mov        cx,42
        long_wait_loop:
            call wait_proc
        loop       long_wait_loop
        pop        cx
        
        loop       task_main

; дальний переход на процедуру выхода в реальный режим
        db         0EAh
        dd         offset RM_return
        dw         SEL_16bitCS


; задача 1
task_1_message      db      "Lab is done!"
task_1_message_length = $ - task_1_message

; начало подпрограммы
task_1:
        add        edi,160                ; смещаем на несколько строк
        mov        esi,offset task_1_message
        mov        cx,task_1_message_length
task_1_loop:
        mov        al,cs:[esi]          ; записать символ в регистр
        inc        esi                  ; перейти на следующий символ
        mov        byte ptr ds:[edi],al ; вывести символ на экран
        add        edi,2                ; увеличить адрес вывода

; пусть эта задача работает реже остальных
        mov        ax,cx
        mov        cx,35
        multiple_wait:
; переключиться на задачу 0
            db         0EAh
            dd         0
            dw         SEL_TSS0
; сюда будет возвращаться управление из задачи 0
        loop       multiple_wait
        mov        cx,ax
        
        loop       task_1_loop
; по завершении задачи просто сразу возвращаем управление
task_1_finish:
        db         0EAh
        dd         0
        dw         SEL_TSS0
        jmp        task_1_finish


; задача 2
    
task_2_message  db   "MARVEL MOVIES 2023-...:"
                db   "Avengers: Kung's Dinsasty"
                db   "Avengers: Secret Wars"
                db   "Guardians of the Galaxy. Vol 3"
                db   "Ant-Man and Wasp: Quantumania"
task_2_message_length = $ - task_2_message

; начало подпрограммы
task_2:
        add        edi,1440                ; смещаем на несколько строк
        mov        esi,offset task_2_message
        mov        cx,task_2_message_length
task_2_loop:
        inc        cx
        sub        cx,5
        push       cx
        mov        cx,5
        multiple_print:
            mov        al,cs:[esi]          ; записать символ в регистр
            inc        esi                  ; перейти на следующий символ
            mov        byte ptr ds:[edi],al ; вывести символ на экран
            add        edi,2                ; увеличить адрес вывода
        loop multiple_print
        pop cx
; переключиться на задачу 0
        db         0EAh
        dd         0
        dw         SEL_TSS0
; сюда будет возвращаться управление из задачи 0
        loop       task_2_loop
; по завершении задачи просто сразу возвращаем управление
task_2_finish:
        db         0EAh
        dd         0
        dw         SEL_TSS0
        jmp        task_2_finish

; задача 3
    
task_3_message  db   "DC MOVIES 2022...:"
                db   "- Black Adam"
                db   "- Shazam 2: Fury of the gods"
                db   "- Flash"
                db   "- Joker 2: Folie a Deux"
                

task_3_message_length = $ - task_3_message

; начало подпрограммы
task_3:
        add        edi,2720                ; смещаем на несколько строк
        mov        esi,offset task_3_message
        mov        cx,task_3_message_length
task_3_loop:
        mov        al,cs:[esi]          ; записать символ в регистр
        inc        esi                  ; перейти на следующий символ
        mov        byte ptr ds:[edi],al ; вывести символ на экран
        add        edi,2                ; увеличить адрес вывода
; переключиться на задачу 0
        db         0EAh
        dd         0
        dw         SEL_TSS0
; сюда будет возвращаться управление из задачи 0
        loop       task_3_loop
; по завершении задачи просто сразу возвращаем управление
task_3_finish:
        db         0EAh
        dd         0
        dw         SEL_TSS0
        jmp        task_3_finish


PM_seg  ends

stack_seg segment para stack "STACK"    ; стеки задач
stack_start        db    100h dup(?)    
stack_pointer_start = $ - stack_start
stack_task1        db    100h dup(?)
stack_pointer_1 = $ - stack_start
stack_task2        db    100h dup(?)
stack_pointer_2 = $ - stack_start
stack_task3        db    100h dup(?)
stack_pointer_3 = $ - stack_start
stack_seg ends

        end        start

