.model small
.stack
.data
product db 45 dup (0)
.code
.startup
mov dl, 1
mov di, 0
outlp:
	mov cl, 1
	inlp:
		mov al, dl
		mul cl
		;inc di
		mov product[di], al
		inc di
		inc cl
		cmp cl, dl
		jbe inlp
inc dl	
cmp dl, 9
jbe outlp

.exit 0


end