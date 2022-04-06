;DenKir
	.model tiny
	.code
	.data
	.286
	.startup
	org 100h
; i - input sprits ( k - l choos)
; o - output level
; p - input level
	mov ax,000Dh
	int 10h
        push 0A000h
	pop es
;  cheng size of video buffers
	mov ah,80 ; 80 words in 1 streeng
	mov al,13h ; number reg
	mov dx,3D4h
	out dx,ax
	call read_level
	call restore_video
        call keyread
read_file proc near
	call _open
reread:	call data_offset
	call _load
	call putblock
rf1:	mov ax,0700h
	int 21h
	cmp al,6Bh
	je read_down
	cmp al,6Ch
	je read_up
	cmp al,0Dh
	je read_complit
	jmp rf1

read_down:
	cmp namber,0
	jne rf2
	jmp rf1
rf2:    dec namber
	jmp reread

read_up:cmp namber,0FFh
	jne rf3
	jmp rf1
rf3:    inc namber
	jmp reread

read_complit:
	call _closed
	ret
read_file endp
_open proc near
	mov ax,3D02h ; open for input/output
	mov dx,offset path
	int 21h
	mov opisatel,ax
	ret
_open endp
_closed proc near
	mov ax,3E00h ; closed
	mov bx,opisatel
	int 21h
	ret
_closed endp
data_offset proc near
	mov ax,long 
	mul namber ; dx:ax offset data in file
	mov dx,ax  ; size file don't more 65535
	xor cx,cx  ; offset for int 21h cx*65535+dx
	mov ax,4200h ; nachalo file + dx
	mov bx,opisatel
	int 21h
	ret
data_offset endp
_load proc near
	mov dx,offset bufer
	mov cx,long ; 262
	mov ax,3F00h
	mov bx,opisatel
	int 21h
	ret
_load   endp
keyread  proc near
	mov x,0
	mov y,0
	mov xp,160
	mov yp,96
key1:   mov ah,07h
	int 21h
	mov cx,shag
	cmp al,38h
	je up
	cmp al,32h
	je down
	cmp al,36h
	je tright
	cmp al,34h
	je tleft
        cmp al,71h
	je get_out_her
	cmp al,69h
	je _input
	cmp al,6Fh
	je _output
       	jmp key1
_input: call read_file
	jmp key1
_output:call write_file
	jmp key1
tright: jmp right
get_out_her:
	mov ax,4C00h
	int 21h
tleft:  jmp left
;****************************
up:     cmp yp,97
	 jb up2 ; yp<96
	 ;je up2
	cmp yp,304
	 ja up2 ; yp>304
	 ;je up2
	sub y,cx
	sub yp,cx
	 jmp fil
up2:    cmp yp,0
	 je fil1
	sub yp,cx
	jmp fil

down:   cmp yp,96
	 jb down2 ; yp<96
	 ;je down2
	cmp yp,303
	 ja down2 ; yp>304
	 ;je down2
	add y,cx
        add yp,cx
	 jmp fil
fil1:   jmp fil
down2:  cmp yp,368 ; 400-16
         je fil
        add yp,cx
        jmp fil
;&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
left:   cmp xp,176
	 jb left2 ; xp<160
	cmp xp,1072
	 ja left2 ; xp>1140
	sub x,cx
	sub xp,cx
	jmp fil
left2:  cmp xp,0
	je fil
	sub xp,cx
	jmp fil

right:  cmp xp,1072
	 ja right2 ; xp>1140
	 je right2
	cmp xp,160
	 jb right2 ; xp<160
	add x,cx
        add xp,cx
	jmp fil
right2: cmp xp,1200 ; 1280-16
        ja fil
	je fil
        add xp,cx
        jmp fil

fil:	;call putblock ;$$$$$$$%^$^&%$^&%&^%^&%&^%^&% it is
	call pan
        jmp key1
keyread endp
pan proc near
	mov ax,x
	mov bx,y
l01:	mov cx,8
	div cl
	mov cl,ah
	xor ah,ah
	xchg ax,bx
	mul word ptr _byteperrow
	add bx,ax
	mov dx,03DAh
l20:    in al,dx
	test al,8
	jz l20
l21:    in al,dx
	test al,8
	jnz l21

	cli
	mov dx,03D4h
	mov ah,bh
	mov al,0Ch
	out dx,ax
	mov ah,bl
	inc al
	out dx,ax
	sti
	mov dx,03DAh
l22:    in al,dx
	test al,8
	jz l22
	cli
	mov dx,03D4h
	mov ah,ch
	mov al,8
	out dx,ax
	mov dx,03C0h
	mov al,13h or 20h
	out dx,al
	mov al,cl
	out dx,al
	sti
	ret
pan endp	
xyoffset PROC near
	; bx - x
	; ax - y

	mov cl,bl ; cl low byte x

	push dx 

	mov dx,160 ; ax = y * 80
	mul dx

	pop dx	
	shr bx,1 
	shr bx,1
	shr bx,1 ; bx = x / 8
	add bx,ax ; bx = y * 80 + x / 8
	add bx,0; bx = offset byta  ot (0,0)
	and cl,7 ; cl = x & 7
	xor cl,7 ; cl kolichestvo bitov dlja sdviga ih v byte
	mov ah,1 ; ne sdvinutaja bitovaja maska

	ret
xyoffset endp
write proc near
	mov ax,y
	mov bx,x
	call xyoffset
	push bx
	shl ah,cl
	mov dx,3CEh
	mov al,8
	out dx,ax
	mov ax,205h
	out dx,ax
	mov ah,00h
	mov al,3
	out dx,ax
	mov al,es:[bx]
	mov al,color
	mov es:[bx],al	
	mov ax,0FF08h
	out dx,ax
	mov ax,0005
	out dx,ax
	mov ax,0003
	out dx,ax
	pop bx

       ret
write endp
putblock proc near
	call write_in_level
	push ds
	push si
	push di
	mov ax,yp
	mov bx,xp
	call xyoffset
	inc cl
	and cl,7
	mov di,bx
	mov si,offset bufer
	mov vpr,16
	mov vprl,2
	mov ch,0FFh
	mov dx,3CEh
	mov ah,00h ;mask
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
	jnz lm20
	jmp short lm22
l19:  	rol ax,cl
	and es:[di],ah
	inc di
	dec bx
lm20:   push ax
	mov ax,0FF08h
	out dx,ax
	pop ax
	dec bx
	jng lm22
lm21:    and es:[di],al
	inc di
	lodsw
	dec si
	rol ax,cl
	dec bx
	jnz lm21
lm22:    mov bx,ax
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
write_in_level proc near
	mov cl,4
	mov ax,yp
	mov bx,xp
	shr ax,cl ; ax / 16 --- y / 16 
	shr bx,cl ; bx / 16 --- x / 16
	;dec ax
	mov cl,76
	mul cl    ; y/16 * 76
	add bx,ax ; (x/16)+(y/16*76)
	mov dx,offset level
	mov cl,byte ptr namber
	add bx,dx
	mov byte ptr ds:[bx],cl
	ret
write_in_level endp

write_file proc near
        call _open2
        call _save
	call _closed
	ret
write_file endp
read_level proc near
        call _open2
        call _load2
        call _closed
        ret
read_level endp
_save   proc near

	; save file
	mov dx,offset level
	mov cx,long2 ; 262
	mov ax,4000h
	mov bx,opisatel
	int 21h
	ret
_save   endp
_open2 proc near
	mov ax,3D02h ; open for input/output
	mov dx,offset path2
	int 21h
	mov opisatel,ax
	ret
_open2 endp

_load2 proc near
	mov dx,offset level
	mov cx,long2
	mov ax,3F00h
	mov bx,opisatel
	int 21h
	ret
_load2   endp
restore_video proc near
        call _open
	mov xp,0
	mov yp,0
rv1:    mov cl,4
	mov ax,yp
	mov bx,xp
	shr ax,cl ; ax / 16 --- y / 16
	shr bx,cl ; bx / 16 --- x / 16
	;dec ax
	mov cl,76
	mul cl    ; y/16 * 76
	add bx,ax ; (x/16)+(y/16*76)
	mov dx,offset level
	add bx,dx
	mov cl,byte ptr ds:[bx]
        mov namber,cl
        call data_offset
        call _load
        call putblock
         cmp xp,1200
         ja rv2
         je rv2
        add xp,16
         jmp rv1
rv2:    cmp yp,368
         ja rv3
         je rv3
         mov xp,0
         add yp,16
         jmp rv1
rv3:     mov x,0
	 mov y,0
         mov xp,160
         mov yp,96
	ret
restore_video endp
x dw 0
y dw 0
xp dw 160
yp dw 96
color db 0
_byteperrow dw 160
long dw 128
long2 dw 1824
namber db 0  ; long * namber = offset pictur in file
shag dw 0016 ; chang it for diferent panaram speed !!!!!!!!!!!!!!!!!!!!!
opisatel dw 00h
path db 'pointout.dat',0
path2 db 'a1_out.dat',0
vrc dw 0
vsm dw 0
vprl dw 2 ;byte in 1 streeng pixels
vpr dw 16 ; string of pixels
veml dw 0
vemr dw 0
bpr dw 160
bufer db 128 dup (0)
level db 1824 dup (0) ; 76*24 objects
end
	