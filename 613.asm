.model small
.stack
.data
.code
.startup
	mov al, 14h
	call searchal
 .exit 0
   searchal proc
	clc
	.repeat 
	 cmp byte ptr ds:[si],0
	 jz ending            ;查找区域以0作为结束标志,跳出循环           
	 cmp ds:[si],al
	 jnz p1
	 stc       ;若找到使CF=1
	 jmp ending
	 p1:
		inc si
		clc
  .untilcxz
	ending:
   ret
   searchal endp

end