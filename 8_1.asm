.model small
.stack
.data
   student struct                ;结构定义
          snumber dw 0           ;编号，代表名次
          sid db 15 dup('$')     ;学号
          sname db 20 dup('$')   ;最多20位，姓名
          score1  dw 0           ;成绩1
          score2  dw 0           ;成绩2
          score3  dw 0           ;成绩3
          ttscore dw 0           ;总分
   student ends
   
   scoresheet student <1,'computer01$','zhangsan$',90,70,60,>
              student <2,'computer02$','lisi    $',100,0,100,>
              student <3,'computer03$','wanger  $',95,66,88,>
              student <4,'computer04$','zhuwu   $',120,90,99,>
              student <5,'computer05$','john    $',90,80,95,>
                       ;成绩单长度可以任意，这里只列举5个纪录
    sheetlength=($-scoresheet)/(type scoresheet) ;成绩单长度，即纪录条数
    pushcount db 0  ;临时存放被显示数据的位数
.code
    nextline macro  ;显示换行的宏定义
      mov ah,2
      mov dl,10
      int 21h
      mov ah,2
      mov dl,13
      int 21h
     endm
     dispone macro one    ;显示一个字符的有参数宏定义
       mov ah,2
       mov dl,one
       int 21h
     endm
 dispscore macro          ;按照10进制显示内存单元数据的宏定义
       local loop1,print  ;局部标号定义
         push bx
         push dx
         mov bl,10
    loop1: div bl
         mov dl,ah
         mov ah,0
         push dx           ;把每次除以10的余数压入堆栈，并记录数据位个数
         inc pushcount
         cmp al,0
         jne loop1
   print: pop dx           ;从堆栈弹出每位数据并显示
         add dl,30h
         dispone dl
         dec pushcount
         jnz print
         dispone 20h       ;显示一个空格
         pop dx
         pop bx
 endm

.startup
  lea bx, scoresheet
  mov cx,sheetlength
  .repeat                       ;统计每条记录的总分
    mov ax,[bx].student.score1
    add ax,[bx].student.score2
    add ax,[bx].student.score3
    mov [bx].student.ttscore,ax
    mov [bx].student.snumber, 0 ;名次初始化为0
    add bx, type scoresheet
  .untilcxz

   mov dx,0        ;DX控制总循环次数，初始值为0
   push dx
begin:
   lea bx, scoresheet
   mov cx, sheetlength
  .repeat
    .if [bx].student.snumber==0    ;找到第一个未排名的纪录
      mov ax,[bx].student.ttscore  ;总分记录在AX中
      .break
    .else
      add bx, type scoresheet
    .endif
  .untilcxz

    mov bx,offset scoresheet
    mov cx,sheetlength
   .repeat
    .if [bx].student.snumber==0
      .if [bx].student.ttscore>=ax ;逐一比较找到一个未排序的且总分最高的纪录
         mov ax,[bx].student.ttscore;AX保存最高的总分
         mov di,bx                  ;有最高总分的记录地址保存在DI寄存器中
      .endif
    .endif
     add bx, type scoresheet
   .untilcxz

    nextline                      ;在新的一行显示每条记录信息
    mov bx,di
    pop dx
    inc dx
    push dx
    mov [bx].student.snumber,dx   ;DX加1为当前名次
    mov ax,dx                     ;显示名次
    dispscore
    lea dx, [bx].student.sid      ;显示学号
    mov ah,9
    int 21h
    dispone 20h
    lea dx, [bx].student.sname    ;显示姓名
    mov ah,9
    int 21h
    dispone 20h
    mov ax, [bx].student.score1   ;显示成绩1
    dispscore
    mov ax, [bx].student.score2   ;显示成绩2
    dispscore
    mov ax, [bx].student.score3   ;显示成绩3
    dispscore
    mov ax, [di].student.ttscore  ;显示总分
    dispscore
    pop dx
    .if dl==sheetlength
       .exit 0
    .endif
    push dx
    jmp begin
   end
