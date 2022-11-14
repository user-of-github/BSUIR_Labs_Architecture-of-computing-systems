use16

org 100h

start:
    .string_demo:
        db "Everything works...$"
; В самом начале программы мы находимся в реальном режиме
    mov ah, 00
    int 21h
    ; Запрещаем маскируемые прерывания
    cli
    ; Запрещаем немаскируемые прерывания (NMI)
    in   al, 70h
    or   al, 80h
    out 70h, al
    ; Открываем линию A20
    in   al, 92h
    or   al, 2
    out 92h, al

            ; Закрываем линию A20
    in    al, 92h
    and al, 0FDh
    out  92h, al
    ; Переключаемся в защищённый режим
    ; Пытаемся совершить действия, на которые у нас нет прав
    mov eax, cr0
    or    al, 1
    mov cr0, eax

    in    al, 70h
    and al, 7Fh
    out  70h, al
    ; Разрешаем маскируемые прерывания
    sti



    ; type string in protected node
    mov ah, 9h
    mov dx, .string_demo
    int 21h

    ; Теперь находимся в защищённом режиме
    ; Пытаемся совершить действия, на которые у нас нет прав
    ;mov ah, 00
    ;int 21h
    ; Переключаемся в реальный режим

     ; Запрещаем маскируемые прерывания
    cli
    ; Запрещаем немаскируемые прерывания (NMI)
    in   al, 70h
    or   al, 80h
    out 70h, al
    
    mov eax, cr0
    and  al, 0FEh
    mov cr0, eax
    ; Закрываем линию A20
    in    al, 92h
    and al, 0FDh
    out  92h, al
    ; Разрешаем немаскируемые прерывания (NMI)
   
    ; Мы снова находимся в реальном режиме
    ret  

 
