; DenKir 
	.model tiny
	.code
	.data
        .286
	.startup
	org 100h
        mov dx,offset path
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov dx,offset path2
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf2
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov dx,offset path3
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf3
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov dx,offset path4
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf4
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov dx,offset path5
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf5
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov dx,offset path6
	mov ah,3Dh
	mov al,0
	int 21h
	mov dx,offset buf6
	mov bx,ax
	mov cx,0A66h
	mov ax,3F00H
	int 21h

        mov ax,0010h
        int 10h
        push 0A000h
        pop es
abc1:	call putblock
	add py,50
	cmp py,200
	je abd1
	jmp abc1
abd1:   mov py,0
	add px,107
	cmp px,560
	ja ab3
	jmp abc1
ab3:    mov px,0
	jmp ab1
ab1:	mov dl,0FFh
	mov ah,06h
	int 21h
	cmp al,00	
	jne __exit
	jmp abc1
__exit:	mov ax,0003h
	int 10h
	mov ax,4C00h
	int 21h
putblock proc near
	push ds
	push si
	push di
	mov ax,py
	mov bx,px
	call xyoffset
	inc cl
	and cl,7
	mov di,bx
        cmp mp,00h
        jne d1
        mov si,offset buf
        jmp oka1
d1:	cmp mp,01h
        jne d2
	mov si,offset buf2
        jmp oka1

d2:	cmp mp,02h
        jne d3
	mov si,offset buf3
        jmp oka1

d3:	cmp mp,03h
        jne d4
	mov si,offset buf4
        jmp oka1

d4:	cmp mp,04h
        jne d5
	mov si,offset buf5
        jmp oka1

d5:     cmp mp,05h
        jne oka1
	mov si,offset buf6
        jmp oka1

oka1:   cmp mp,04
        jae oka2
        inc mp
        jmp oka3
oka2:   mov mp,00h
oka3:

k1:	lodsw
	mov vpr,ax
	lodsw
	mov vprl,ax
	lodsb
	mov ch,al
	mov dx,3CEh
	mov ah,rmw
	mov al,3
	out dx,ax
	mov ax,0805h
	out dx,ax
	mov ax,0007h
	out dx,ax
	mov ax,0FF08h
	out dx,ax
	mov dl,0C4h
	mov ax,0802h
	cmp cx,0FF00h
	jne l15
	mov cx,vprl
l10:	out dx,ax
	push ax
	push di
	mov bx,vpr
l11:    push di
	push cx
l12:    lodsb
	and es:[di],al
	inc di
	loop l12
	pop cx
	pop di
	add di,bpr
	dec bx
	jnz l11
	pop di
	pop ax
	shr ah,1
	jnz l10
	jmp lexit
l15:	push ax
	mov bx,0FFh
	mov al,ch
	cbw
	cmp vprl,1
	jne l16
	mov bl,ch
	mov ah,ch
	xor al,al
l16:    shl ax,cl
	shl bx,cl
	mov bl,al
	mov al,8
	mov veml,ax
	mov ah,bl
	mov vemr,ax
	mov ah,bh
	mov vsm,ax
	mov bx,vprl
	pop ax
l17:    out dx,ax
	push ax
	push di
	mov dl,0CEh
	mov ax,vpr
	mov vrc,ax
l18:    push di
	push si
	push bx
	mov ax,vsm
	out dx,ax
	lodsw
	dec si
	test cl,cl
	jnz l19
	dec bx
	jnz l20
	jmp short l22
l19:  	rol ax,cl
	and es:[di],ah
	inc di
	dec bx
l20:    push ax
	mov ax,0FF08h
	out dx,ax
	pop ax
	dec bx
	jng l22
l21:    and es:[di],al
	inc di
	lodsw
	dec si
	rol ax,cl
	dec bx
	jnz l21
l22:    mov bx,ax
	mov ax,veml
	out dx,ax
	and es:[di],bl
	mov ax,vemr
	out dx,ax
	and es:[di+1],bh
	pop bx
	pop si
	add si,bx
	pop di
	add di,bpr
	dec vrc
	cmp vrc,0
	jne l18
	;jnz l18  do not debug it
	pop di
	pop ax
	mov dl,0C4h
	shr ah,1
	cmp ah,0
	jne l17
	;jnz l17
lexit:  mov ax,0F02h
	out dx,ax
	mov dl,0CEh
	mov ax,0003h
	out dx,ax
	mov ax,0005h
	out dx,ax
	mov ax,0F07h
	out dx,ax
	mov ax,0FF08h
	out dx,ax
	pop di
	pop si
	pop ds
	ret
putblock endp
         mov ax,4C00h
         int 21h
xyoffset PROC near
	; bx - x
	; ax - y

	mov cl,bl ; cl low byte x

	push dx 

	mov dx,bpl ; ax = y * 80
	mul dx

	pop dx	
	shr bx,1 
	shr bx,1
	shr bx,1 ; bx = x / 8
	add bx,ax ; bx = y * 80 + x / 8
	;add bx,OriginOffset ; bx = offset byta  ot (0,0)
	and cl,7 ; cl = x & 7
	xor cl,7 ; cl kolichestvo bitov dlja sdviga ih v byte
	mov ah,1 ; ne sdvinutaja bitovaja maska
	ret
xyoffset endp
path db 'testpic.dat',0
path2 db 'testpic2.dat',0
path3 db 'testpic3.dat',0
path4 db 'testpic4.dat',0
path5 db 'testpic5.dat',0
path6 db 'testpic6.dat',0
string db 'pholki'
codeok dw 0
px dw 0
py dw 0
vrc dw 0
vsm dw 0
veml dw 0
vemr dw 0
rmw db 00000000b ; and
vpr dw 0
vprl dw 0
bpr dw 80
bpl dw 80
mst dw 0
mp dw 0
buf db 3000 dup (0)
buf2 db 3000 dup (0)
buf3 db 3000 dup (0)
buf4 db 3000 dup (0)
buf5 db 3000 dup (0)
buf6 db 3000 dup (0)


end

