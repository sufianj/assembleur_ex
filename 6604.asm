.model small
.stack
.data
product db 45 dup (0)
.code
.startup
mov cx, 9
;lea dx,product    
mov si, 44
outlp:
	mov bl, cl
inlp:
	mov al, cl
	mul bl
	mov product[si], al
	dec si
	dec bl
	cmp bl, 1
	jae inlp
loop outlp

.exit 0

end