	.model tiny
	.code
	.data
	.startup
	org 100h

        mov ax,0010h
        int 10h
	mov ax,0A000h
	mov es,ax
timers  proc near
b:
;second
        jmp test1
b30:
	mov al,old_d_second
	mov dlina,al
	dec al
	dec al
	mov radius,al
	mov alfa,0
	mov color,0
b401:   call present_vector
	inc alfa
	dec radius
	dec radius
	cmp alfa,361
	jne b401
	
	mov al,d_second
	mov old_d_second,al
	mov dlina,al
	dec al
	dec al
	mov radius,al
	mov alfa,0
	mov color,15
b501:   call present_vector
	inc alfa
	dec radius
	dec radius
	cmp alfa,361
	jne b501		
	
        xor ax,ax
        mov ah,2Ch
        int 21h
        mov al,second
        cmp al,dh
        ;je b

         mov ax,old_second
         mov second,dh
         mov alfa,ax
         mov dlina,200
	 mov radius,0
         mov color,0
         call present_vector


        mov al,second
	xor dx,dx
	mov dl,6
	mul dl
	mov old_second,ax
        mov alfa,ax
	mov cl,d_second
        mov dlina,cl
	mov radius,0
        mov color,12
        call present_vector

;minuts xor ax,ax
        mov ah,2Ch
        int 21h

         mov ax,old_minuts
         mov minuts,cl
         mov alfa,ax
         mov dlina,200
	 mov radius,0
         mov color,0
         call present_vector


        mov al,minuts
	xor dx,dx
	mov dl,6
	mul dl
	mov old_minuts,ax
        mov alfa,ax
	mov cl,d_minuts
        mov dlina,cl
	mov radius,0
        mov color,14
        call present_vector

;hours  xor ax,ax
        mov ah,2Ch
        int 21h

         mov ax,old_hours
         mov hours,ch
         mov alfa,ax
         mov dlina,200
	 mov radius,0
         mov color,0
         call present_vector


        mov al,hours
	cmp al,13
	jb b20
	sub al,12
b20:	xor dx,dx
	mov dl,30
	mul dl
	mov old_hours,ax
        mov alfa,ax
	mov cl,d_hours
        mov dlina,cl
	mov radius,0
        mov color,15
        call present_vector

        mov dl,0FFh
	xor al,al
        mov ah,06h
        int 21h
        jnz _exit1
        jmp b
test1:	cmp d_second,180
	ja t3
	cmp flag2,1
	je t4
	add d_second,4
        add d_minuts,3
        add d_hours,2
	jmp b30
t3:     mov flag2,1
	sub d_second,4
	cmp d_second,10
	jb t4
        cmp d_minuts,4
        je t10
        sub d_minuts,3
t10:    cmp d_hours,4
        je b301
        sub d_hours,2
	jmp b30
_exit1: jmp _exit
t4:     cmp d_second,8
	jb t5
	sub d_second,4
        cmp d_minuts,4
        jb t11
        sub d_minuts,3
t11:    cmp d_hours,4
        jb b301
        sub d_hours,2
b301:	jmp b30
t5:     mov flag2,0
	add d_second,4
        add d_minuts,3
        add d_hours,2
        jmp b30
_exit:  mov ax,0003h
	int 10h
	mov ah,09h
	mov dx,offset mesaga
	int 21h
	mov ax,4C00h
        int 21h
timers  endp
present_vector proc near
a:
        xor ax,ax
        xor si,si
	xor cx,cx
	mov cl,255
	inc radius
        mov al,radius
        cmp al,dlina
        je out_her
	call sincos
	xor al,al
	mov al,radius
        mul sinalfa ;radius *sinalfa (dx:ax)
        div cx
        ;ax = x
        mov x,ax
        xor ax,ax
	xor dx,dx
        mov al,radius
        mul cosalfa
        div cx
        mov y,ax
	xor ax,ax
	xor bx,bx

	cmp sinflag,0
	je sin0
	mov bx,x
	add bx,x0
	jmp test_cos
sin0:   mov bx,x0
	sub bx,x
test_cos:
	cmp cosflag,0
	je cos0
	mov ax,y
	add ax,y0
	jmp testok
cos0:   mov ax,y0
	sub ax,y
testok:	
        call put_pixel
        jmp a
out_her: ret

present_vector endp
sincos proc near
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
sin:
	cmp alfa,90
	ja alfa90
        xor ax,ax
	mov bx,offset a1
	mov ax,alfa
	xlat
	mov sinalfa,ax
        mov sinflag,1
	jmp cos
alfa90: cmp alfa,180
	ja alfa180
        xor ax,ax ;alfa>90
        mov ax,alfa
        sub ax,90
	mov bx,offset qr1
	xlat
	mov sinalfa,ax
        mov sinflag,1
	jmp cos
alfa180:cmp alfa,270
	ja alfa270
        xor ax,ax ;alfa>180
        mov ax,alfa
        sub ax,180
	mov bx,offset a1
	xlat
	mov sinalfa,ax
        mov sinflag,0 ; sin<0
	jmp cos
alfa270:xor ax,ax
        mov ax,360
        sub ax,alfa
	mov bx,offset a1
	xlat
	mov sinalfa,ax
	mov sinflag,0 ; sin<0

cos:
	cmp alfa,89
	ja alfac90
        xor ax,ax
	mov bx,offset qr1
	mov ax,alfa
	xlat
	mov cosalfa,ax
        mov cosflag,0 ; cos>0
	jmp _ret

alfac90:cmp alfa,180
	ja alfac180
        xor ax,ax ;alfa>90
        mov ax,alfa
        sub ax,90 ; al = alfa - 90 [alfa (90...179)
	mov bx,offset a1
	xlat
	mov cosalfa,ax
        mov cosflag,1 ; cos<0
	jmp _ret

alfac180:cmp alfa,270
	ja alfac270
        xor ax,ax ;alfa>180
        mov ax,alfa
        sub ax,180
	mov bx,offset qr1
	xlat
	mov cosalfa,ax
        mov cosflag,1 ; cos<0
	jmp _ret
alfac270:xor ax,ax
        mov ax,360
        sub ax,alfa
	mov bx,offset qr1
	xlat
	mov cosalfa,ax
	mov cosflag,0 ; cos>0
_ret:   ret
sincos endp
 
	
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
xyoffset PROC near
	; bx - x
	; ax - y

	mov cl,bl ; cl low byte x

	push dx 

	mov dx,80 ; ax = y * 80
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
alfa dw 0
old_second dw 0
old_minuts dw 0
old_hours dw 0
sinalfa dw 0
cosalfa dw 0
sinflag db 0
cosflag db 0
second db 1
minuts db 1
hours db 1
test_second db 0FFh
alfa_second dw 0
x  dw 0
y dw 0
radius db 0
dlina db 0
d_second db 200
d_minuts db 150
d_hours  db 50
old_d_second db 200
flag db 1
flag2 db 0
color db 15
x0 dw 300
y0 dw 150
a1 db 0 
a2 db 4 
a3 db 8 
a4 db 13 
AD db 17 
BE db 22 
CF db 26 
DG db 31 
EH db 35 
FI db 40 
GJ db 44 
HK db 48 
IL db 53 
JM db 57 
KN db 61 
LO db 66 
MP db 70 
NQ db 74 
_OR db 79 
PS db 83 
QT db 87 
RU db 91 
SV db 95 
TW db 99 
UX db 104 
VY db 108 
WZ db 112 
X80 db 116 
Y1 db 120 
Z2 db 124 
s1 db 127 
s2 db 131 
s3 db 135 
s4 db 139 
s5 db 143 
s6 db 146 
ad3 db 150 
be3 db 153 
cf3 db 157 
dg3 db 161 
eh3 db 164 
Ae3 db 167 
eB3 db 171 
fC3 db 174 
D13 db 177 
AE32 db 180 
BF db 184 
CG db 187 
D45 db 190 
EI db 193 
FJ db 196 
GK db 198 
HL db 201 
IM db 204 
JN db 207 
KO db 209 
LP db 212 
MQ db 214 
NR db 217 
OS db 219 
PT db 221 
QU db 223 
RV db 225 
SW db 228 
TX db 230 
UY db 231 
VZ db 233 
W15 db 235 
X1 db 237 
Y14 db 238 
Z34 db 240 
f54 db 242 
g54 db 243 
h54 db 244 
j54 db 246 
c94 db 247 
d94 db 248 
ae4 db 249 
bf4 db 250 
cg4 db 251 
dh4 db 252 
ei4 db 252 
A94 db 253 
B94 db 254 
C945 db 254 
@D1 db 255 
AE1 db 255 
BF1 db 255 
CG1 db 255 
DH1 db 255 
safasd db 255

QR1 db 255
RS1 db 255 
ST1 db 255 
TU1 db 255 
UV1 db 255 
VW1 db 255 
WX1 db 254 
XY1 db 254 
YZ1 db 253 
Z14 db 252 
q11 db 252 
q21 db 251 
q31 db 250 
q41 db 249 
q51 db 248 
a01 db 247 
ab1 db 246 
bc1 db 244 
cd1 db 243 
de1 db 242 
w11 db 240 
w21 db 239 
w31 db 237 
w41 db 235 
w51 db 233 
AC1 db 232 
BD1 db 230 
CE1 db 228 
DF1 db 226 
EG1 db 223 
FH1 db 221 
GI1 db 219 
HJ1 db 217 
IK1 db 214 
JL1 db 212 
KM1 db 209 
LN1 db 207 
MO1 db 204 
NP1 db 201 
OQ1 db 199 
PR1 db 196 
QS1 db 193 
RT1 db 190 
SU1 db 187 
TV1 db 184 
UW1 db 181 
VX1 db 177 
WY1 db 174 
XZ1 db 171 
Y91 db 168 
Z91 db 164 
e11 db 161 
e21 db 157 
e31 db 154 
e41 db 150 
e51 db 146 
r11 db 143 
ac12 db 139 
bd12 db 135 
ce12 db 131 
df12 db 128 
r112 db 124 
r212 db 120 
r312 db 116 
r412 db 112 
r512 db 108 
AC125 db 104 
BD125 db 100 
CE1255 db 96 
DF125 db 91 
EG1225 db 87 
FH125 db 83 
GI1225 db 79 
HJ125 db 75 
IK125 db 70 
JL12 db 66 
KM12 db 62 
LN122 db 57 
MO12 db 53 
NP12 db 49 
OQ12 db 44 
PR12 db 40 
QS122 db 35 
RT12 db 31 
SU12 db 26 
TV12 db 22 
UW12 db 18 
VX12 db 13 
WY12 db 9 
XZ12 db 4 
asffdsad db 4
mesaga db ' DenKir EGA ScreenSaver Collection 1997 (assembler) ','$'
end