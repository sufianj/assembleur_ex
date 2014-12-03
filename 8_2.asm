.model small
.stack
.data
   student struct               ;结构定义
           snumber dw 0         ;编号，代表名次
           sid db 15 dup('$')   ;学号
           sname db 20 dup('$') ;最多20位，姓名
           score1 dw 0          ;成绩1
           score2 dw 0          ;成绩2
           score3 dw 0          ;成绩3
           score4 dw 0          ;成绩4
           score5 dw 0          ;成绩5
           ttscore dw 0         ;总分
   student ends
   
   scoresheet student<1,'computer01$','zhangsan$',90,70,60,82,67,>
              student<2,'computer02$','lisi    $',100,0,100,68,91,>
              student<3,'computer03$','wanger  $',95,66,88,66,89,>
              student<4,'computer04$','zhuwu   $',120,90,99,58,93,>
              student<5,'computer05$','john    $',90,80,95,79,83,>
   sheetlength = ($ - scoresheet)/(type scoresheet) ;成绩单长度
   pushcount db 0    ;临时存放被显示数据的位数
.code
  nextline macro   ;显示换行的宏定义
     mov ah,2
     mov dl,10
     int 21h
     mov ah,2
     mov dl,13
     int 21h
  endm
  dispone macro one  ;显示一个字符的有参数宏定义
     mov ah,2
     mov dl,one
     int 21h
  endm
  dispscore macro        ;按照十进制显示内存单元数据的宏定义
     local loop1,print   ;局部标号定义
     push bx
     push dx
     mov bl,10
   loop1:
     div bl
     mov dl,ah
     mov ah,0
     push dx      ;余数
     inc pushcount
     cmp al,0
     jne loop1
   print:
     pop dx       ;从堆栈弹出每位数据并显示
     add dl,30h
     dispone dl
     dec pushcount
     jnz print
     dispone 20h  ;显示一个空格
     pop dx
     pop bx
  endm

.startup
  lea bx,scoresheet
  mov cx,sheetlength
  .repeat            ;统计每条记录的总分
     mov ax,[bx].student.score1
     add ax,[bx].student.score2
     add ax,[bx].student.score3
     add ax,[bx].student.score4
     add ax,[bx].student.score5
     mov [bx].student.ttscore,ax
     mov [bx].student.snumber,0   ;名次初始化为0
     add bx,type scoresheet
  .untilcxz

  mov dx,0   ;
  push dx
 begin:
  lea bx,scoresheet
  mov cx,sheetlength
  .repeat
    cmp [bx].student.snumber,0  ;找到第一个未排名的记录
    jnz p1
    mov ax,[bx].student.ttscore ;总分记录在ax中
    jmp p2                      ;跳出循环
  p1:
    add bx,type scoresheet
  .untilcxz

 p2:
  mov bx,offset scoresheet
  mov cx,sheetlength
  .repeat
    cmp [bx].student.snumber,0  
    jnz p3
    cmp [bx].student.ttscore,ax  ;逐一比较找到一个未排序的且总分最高的记录
    jb p3
    mov ax,[bx].student.ttscore ;ax保存最高总分
    mov di,bx                   ;有最高总分的记录地址保存到di寄存器中
   p3:                     
    add bx,type scoresheet
  .untilcxz

  nextline          ;在新的一行显示每条记录信息
  mov bx,di
  pop dx
  inc dx
  push dx
  mov [bx].student.snumber,dx ;dx加1为当前名次
  mov ax,dx                   ;显示名次
  dispscore
  lea dx,[bx].student.sid     ;显示学号
  mov ah,9
  int 21h
  dispone 20h
  mov ax,[bx].student.score1  ;显示成绩1
  dispscore
  mov ax,[bx].student.score2  ;显示成绩2
  dispscore
  mov ax,[bx].student.score3  ;显示成绩3
  dispscore
  mov ax,[bx].student.score4  ;显示成绩4
  dispscore
  mov ax,[bx].student.score5  ;显示成绩5
  dispscore
  mov ax,[di].student.ttscore ;显示总分
  dispscore
  pop dx
  cmp dl,sheetlength
  jnz p4
  .exit 0
 p4:
  push dx
  jmp begin
 end 
