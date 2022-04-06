;DenKir
	.model tiny
	.code
	.data
	.286
	.startup
	org 100h
; big screen xb [100....228]  step 8 pixelov 1 byte
;	     yb [1......129] 
; real screen x [1.......17]
;  	      y [1.......17]
;		   16X16		
; i -  read file 
; o -  write file
	mov ax,000Dh
	int 10h
	push 0A000h
	pop es
	call write_screen
        call ramka
keyread  proc near
key1:	mov ah,07h
	int 21h
	cmp al,38h
	je tup
	cmp al,32h
	je tdown
	cmp al,36h
	je tright
	cmp al,34h
	je tleft
	cmp al,71h
	je get_out_her
	cmp al,63h
	je point
	cmp al,64h
	je colordown
	cmp al,66h
	je colorup
	cmp al,78h
	je zaboy
	cmp al,73h
	je all_point_flag_cheng
	cmp al,69h
	je _input
	cmp al,6Fh
	je _output
	jmp key1
tright: jmp right
colorup:inc color
	cmp color,0A0h
	jne tendfil
	mov color,0Fh
	jmp endfil
tup:    jmp up
tdown:  jmp down
tleft:  jmp left
colordown:
	dec color
	cmp color,0FFh
	jne tendfil
	mov color,00h
	jmp endfil
zaboy:  call blac
	jmp endfil
all_point_flag_cheng:
	not all_point
	jmp endfil
_input: call read_file
	jmp endfil
_output:call getblock
        call write_file
	jmp endfil
point:  call new_pixel
	jmp endfil 
get_out_her:
	mov ax,0002h
	int 10h
	mov ax,4C00h
	int 21h
up:     dec y
	sub yb,8
	jmp fil
down:   inc y
	add yb,8
	jmp fil
left:   dec x
	sub xb,8
	jmp fil
tendfil: jmp endfil
right:  inc x
	add xb,8
fil:    cmp x,0
	jne fil2
	mov x,1
	mov xb,100
fil2:   cmp x,17
	jne fil3
	mov x,16
	mov xb,220
fil3:   cmp y,0
	jne fil4
	mov y,1
	mov yb,1 
fil4:   cmp y,17
	jne endfil
	mov y,16
	mov yb,121
endfil: call write_screen
	jmp key1
keyread endp
write_screen proc near
	; for all point
	cmp all_point,0FFh
	jne ws3
	call new_pixel
ws3:    mov xws,1
        mov yws,1
        mov xbws,100
        mov ybws,1
ws1:    mov ax,yws
        mov bx,xws
        call get_pixel_color
        mov ax,ybws
        mov bx,xbws
        mov box_color,cl
        call draw_box
        inc xws
        add xbws,8
        cmp xws,17
        jne ws1
        mov xws,1
        mov xbws,100
        inc yws
        add ybws,8
        cmp yws,17
        jne ws1

        call print_cursor
	ret
write_screen endp
print_cursor proc near
        mov ax,y
        mov bx,x
        call get_pixel_color
        mov ax,yb
        mov bx,xb
        mov box_color,cl
        call draw_box
; draw mushku
        mov ax,yb
        mov bx,xb
        call xyoffset
        mov cx,8
tw1:    mov dx,03CEh
        mov ax,0205h
        out dx,ax
        mov al,08h ;reg mask
	mov ah,00011000b
        out dx,ax
        mov al,0Fh
        mov es:[bx],al
	add bx,40
	loop tw1
        mov ax,yb
        mov bx,xb
        add ax,4
        call xyoffset
        mov dx,03CEh
        mov ax,0205h
        out dx,ax
        mov al,08h ;reg mask
	mov ah,11111111b
        out dx,ax
        mov al,0Fh
        mov es:[bx],al

	; draw curent color box
	mov box_color,0
	mov ybws,170 ; y for color box
	mov xbws,1   ; x for color box
cbw1:	mov ax,ybws
	mov bx,xbws
	call draw_box
	add xbws,8
	inc box_color
	cmp box_color,010h
	jne cbw1

	mov ybws,186
	mov xbws,9
cbw2:	mov ax,ybws
	mov bx,xbws	
	mov cl,color
	mov box_color,cl
	call draw_box
	add xbws,8
	cmp xbws,125
	jbe cbw2
        ret
print_cursor endp
new_pixel proc near
        mov ax,y
        mov bx,x
        call put_pixel
	ret
new_pixel endp
blac proc near 
	mov cl,color
	mov blac_color,cl
	mov color,00h
	mov ax,y
	mov bx,x
	call put_pixel
	mov cl,blac_color
	mov color,cl
	ret
blac    endp
get_pixel_color proc near
        call xyoffset
        mov ch,ah
        shl ch,cl
        mov si,bx
        xor bl,bl
        mov dx,03CEh
        mov ax,0304h
pc1:    out dx,ax
        mov bh,es:[si]
        and bh,ch
        neg bh
        rol bx,1
        dec ah
        jge pc1
        mov al,bl
        xor ah,ah
        mov cl,al ; cl - color pixel in x,y cursor
        ret
get_pixel_color endp
xyoffset PROC near
	; bx - x
	; ax - y

	mov cl,bl ; cl low byte x

	push dx 

	mov dx,40 ; ax = y * 80
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
draw_box proc near
        call xyoffset
        ;write2 8 pixelov in 1 byte color-color 8 stroc
        mov cx,8
db1:    mov dx,03CEh
        mov ax,0205h
        out dx,ax
        mov ax,0FF08h ;mask
        out dx,ax
        mov al,box_color
        mov es:[bx],al
        add bx,40
        loop db1
        ret
draw_box endp
put_pixel proc near
	call xyoffset
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

       ret
put_pixel endp
ramka proc near
       mov color,15
       mov xws,95
ram1:  mov ax,0
       mov bx,xws
       call put_pixel
       mov ax,129
       mov bx,xws
       call put_pixel
       inc xws
       cmp xws,225
       jne ram1
       mov yws,0
ram2:  mov ax,yws
       mov bx,95
       call put_pixel
       mov ax,yws
       mov bx,224
       call put_pixel
       inc yws
       cmp yws,130
       jne ram2
       ret
ramka  endp
putblock proc near
	push ds
	push si
	push di
	mov ax,1
	mov bx,1
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
	add di,40
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
getblock proc near
	push ds es si di
	mov ax,1
	mov bx,1
	call xyoffset
	xor cl,7
	mov si,bx
	push ds es
	pop ds es
	mov di,offset bufer
	mov dx,3CEh
	mov ax,0005h
	out dx,ax
	mov ax,0304h
lb01:   out dx,ax
	push ax
	push es:[vpr]
	push si
lb02:   mov bx,es:[vprl] ; byte in 1 string
	push si
lb03:   lodsw
	dec si
	rol ax,cl
	stosb
	dec bx
	jnz lb03
	; and es:[di-1],ch  ; mask for last byte !!! don't mask !!! 0FFh
	pop si
	add si,40
	dec es:[vpr]
	jnz lb02
	pop si
	pop es:[vpr]
	pop ax
	dec ah
	jns lb01
	mov ax,di
	pop di
	pop si
	pop es
	pop ds
        ret
getblock endp



; file tools block

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
_save   proc near
       ; search end of file
	xor dx,dx
	xor cx,cx
	mov ax,4202h ; pointer on end the file
	mov bx,opisatel
	int 21h

	; save file
	mov dx,offset bufer
	mov cx,long ; 262
	mov ax,4000h
	mov bx,opisatel
	int 21h
	ret
_save   endp
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
write_file proc near
        call _open
        call _save
	call _closed
	ret
write_file endp
	
x  dw 1
y  dw 1
xb dw 100
yb dw 1
color db 0Fh
blac_color db 00h ; for blakc
box_color db 00h
xws dw 1 ; x_write_screen
yws dw 1 ; y_write_screen
xbws dw 10 ; x_big_write_screen
ybws dw 1  ; y_big_write_screen
______not db 111
all_point db 00h ; flag for point with cursor
; data for file

long dw 128
namber dw 0  ; long * namber = offset pictur in file

opisatel dw 00h
path db 'pointout.dat',0
vrc dw 0
vsm dw 0
vprl dw 2 ;byte in 1 streeng pixels
vpr dw 16 ; string of pixels
veml dw 0
vemr dw 0
bpr dw 40
bufer db 128 dup (0) ; reale  need 262 bytes


end