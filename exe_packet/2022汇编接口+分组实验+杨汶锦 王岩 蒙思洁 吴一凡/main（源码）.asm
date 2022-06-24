.386
.model flat, stdcall
option casemap:none

includelib	user32.lib
includelib	kernel32.lib
includelib msvcrt.lib
includelib acllib.lib
include acllib.inc
include msvcrt.inc
include	kernel32.inc
include	user32.inc

printf PROTO C:ptr sbyte,:ptr sbyte,:vararg

.const
Zero equ 0h

.data
;��ӡ���
winTitle byte "Battle-Battle", 0
coord sbyte "%d,%d",10,0
tmp dword 0
life1Test sbyte "1:life: %d",0ah,0
life2Test sbyte "2:life: %d",0ah,0
tip	sbyte "--------------------------------fu!: %d",0ah,0

;ͼƬ��Դ���
music_Bg byte "resource\music\bg.mp3", 0
music_BgP dd 0

page1_Bg byte "resource\pic\backgrounds\startPage\1.bmp", 0
page1_Title byte "resource\pic\UIs\exampleTitle.bmp", 0
page1_Start byte "resource\pic\UIs\startButton.bmp", 0
page1_Exit byte "resource\pic\UIs\exitButton.bmp", 0
imgBg ACL_Image <>
imgTitle ACL_Image <>
imgStart ACL_Image <>
imgExit ACL_Image <>

page2_Bg byte "resource\pic\backgrounds\gameBackground_V1.bmp", 0
page2_vs byte "resource\pic\UIs\VS.bmp", 0


page2_char1_run byte "resource\pic\characters\p1_run.bmp", 0
page2_char1_hurt byte "resource\pic\characters\p1_hurt.bmp", 0
page2_char1_shot byte "resource\pic\characters\p1_shot.bmp", 0
page2_char1_die byte "resource\pic\characters\p1_die.bmp", 0
page2_char1_bul byte "resource\pic\bullets\p1_bul.bmp", 0
page2_char1_life byte "resource\pic\UIs\lifePicture_P1.bmp", 0

page2_char2_run byte "resource\pic\characters\p2_run.bmp", 0
page2_char2_hurt byte "resource\pic\characters\p2_hurt.bmp", 0
page2_char2_shot byte "resource\pic\characters\p2_shot.bmp", 0
page2_char2_die byte "resource\pic\characters\p2_die.bmp", 0
page2_char2_bul byte "resource\pic\bullets\p2_bul.bmp", 0
page2_char2_life byte "resource\pic\UIs\lifePicture_P2.bmp", 0

page2_potion byte "resource\pic\obstacles\potion.bmp", 0
page2_box byte "resource\pic\obstacles\box.bmp", 0
page2_rub byte "resource\pic\obstacles\rubBin.bmp", 0

page3_Bg byte "resource\pic\backgrounds\startPage\2.bmp", 0
page3_1 byte "resource\pic\UIs\orangeWin.bmp", 0
page3_2 byte "resource\pic\UIs\yellowWin.bmp", 0

imgBg2 ACL_Image <>
imgCharRun1 ACL_Image <>
imgCharHurt1 ACL_Image <>
imgCharShot1 ACL_Image <>
imgCharDie1 ACL_Image <>
imgCharBul1 ACL_Image <>
imgCharLife1 ACL_Image <>

imgCharRun2 ACL_Image <>
imgCharHurt2 ACL_Image <>
imgCharShot2 ACL_Image <>
imgCharDie2 ACL_Image <>
imgCharBul2 ACL_Image <>
imgCharLife2 ACL_Image <>

imgObBox ACL_Image <>
imgObPotion ACL_Image <>
imgObRubBin ACL_Image <>
imgVS ACL_Image <>

imgBg3 ACL_Image <>
imgY ACL_Image <>
imgO ACL_Image <>


;�������
curWindow dd 0


MyButton struct
	top	dd	?
	left	dd	?
	right	dd	?
	bottom	dd	?
MyButton ends
start_button	MyButton <300,260,500,400>
exit_button	MyButton<450,260,500,550>

person struct
	life	dd	?;����ֵ
	pos_x dd ?;������--���䶨��
	pos_y dd ?;������--�����ƶ�
	size_x	dd	?;��С
	size_y	dd	?
	dir	dd	?;�ƶ�����--1Ϊ��-1Ϊ��
	speed	dd	?;�ٶȴ�С--
	bullet	dd	?;�ӵ���
	is_hit dd	?;�Ƿ���л�Խ��
person ends
person1 person<>
person2	person<>

Bullet struct
	show	dd	?;��ʾ���
	pos_x dd ?;������
	pos_y dd ?;������
	dir_x	dd	?;�ƶ�����--1Ϊ�ң�-1Ϊ��
	dir_y	dd	?;�����ƶ����� ---���ڷ���
	size_x	dd	?;��С
	size_y	dd	?
	speed_x	dd	?;�ٶȴ�С
	speed_y	dd	?
Bullet ends
bullet1 Bullet<>
bullet2	Bullet<>

seed	dd	?;��������������ڵ�������
Prop struct
	pos_x dd ?;������
	pos_y dd ?;������
	size_x	dd	?;��С
	size_y	dd	?
	;is_hit dd	?;�Ƿ����
Prop ends
Prop_Bounce Prop 10 dup(<>);�ص���
Bounce_Num	dd	?

Prop_Slow Prop 10 dup(<>);���ٵĵ�
Slow_Num	dd	?

Prop_Big Prop 10 dup(<>);����ǿ��?
Big_Num	dd	?
Big_flag1 dword 0
Big_flag2 dword 0

cover_flag dword 0

.code
;�������
getRand proc c uses ecx edx rand_num: dword
	;�����������
	push 0
	call crt_time
	add esp,4

	add eax,seed
	mov seed,eax;seed����
	
	push eax
	call crt_srand
	add esp,4

	invoke crt_rand
	mov edx, 0
	mov ecx, rand_num
	div ecx
	mov eax, edx;��������
	ret
getRand endp

game_over proc C

	invoke loadImage, offset page3_Bg, offset imgBg3
	invoke loadImage, offset page1_Exit, offset imgExit	
	invoke loadImage, offset page3_1, offset imgO
	invoke loadImage, offset page3_2, offset imgY

	invoke putImageScale, offset imgBg3, 0, 0, 800, 600
	invoke putImageScale, offset imgExit, 260, 450, 240, 100

	.if person1.life<=0
		invoke putImageScale, offset imgO, 200, 100, 400,100
	.endif
	.if person2.life<=0
		invoke putImageScale, offset imgY, 200, 100, 400,100
	.endif
	ret 
game_over endp

;������
draw_bg proc
	invoke loadImage, offset page2_Bg, offset imgBg2
	invoke loadImage, offset page2_vs, offset imgVS
	invoke loadImage, offset page2_char1_life, offset imgCharLife1
	invoke loadImage, offset page2_char2_life, offset imgCharLife2

	invoke putImageScale, offset imgBg2, 0, 0, 800, 600
	invoke putImageScale, offset imgVS, 130, 480, 550, 80
	
	;������ʾ�ж�
	.if person1.life>=1
		invoke putImageScale, offset imgCharLife1, 145, 495, 30, 50
		.if person1.life>=2
			invoke putImageScale, offset imgCharLife1, 190, 495, 30, 50
			.if person1.life>=3
				invoke putImageScale, offset imgCharLife1, 235, 495, 30, 50
				.if person1.life>=4
					invoke putImageScale, offset imgCharLife1, 280, 495, 30, 50
					.if person1.life==5
						invoke putImageScale, offset imgCharLife1, 325, 495, 30, 50
					.endif
				.endif
			.endif
		.endif
	;.elseif person1.life<=0
	;	invoke game_over
	.endif

	.if person2.life>=1
		invoke putImageScale, offset imgCharLife2, 630, 495, 30, 50
		.if person2.life>=2
			invoke putImageScale, offset imgCharLife2, 585, 495, 30, 50
			.if person2.life>=3
				invoke putImageScale, offset imgCharLife2, 540, 495, 30, 50
				.if person2.life>=4
					invoke putImageScale, offset imgCharLife2, 495, 495, 30, 50
					.if person2.life==5
						invoke putImageScale, offset imgCharLife2, 450, 495, 30, 50
					.endif
				.endif
			.endif
		.endif
	;.elseif person2.life<=0
		;invoke printf,offset life2Test,person2.life
		;invoke game_over
	.endif
	ret
draw_bg endp

;����
draw_man proc	
	invoke loadImage, offset page2_char1_run, offset imgCharRun1
	invoke loadImage, offset page2_char2_run, offset imgCharRun2

	invoke loadImage, offset page2_char1_shot, offset imgCharShot1
	invoke loadImage, offset page2_char2_shot, offset imgCharShot2

	invoke loadImage, offset page2_char1_hurt, offset imgCharHurt1
	invoke loadImage, offset page2_char2_hurt, offset imgCharHurt2

	invoke loadImage, offset page2_char1_die, offset imgCharDie1
	invoke loadImage, offset page2_char2_die, offset imgCharDie2
	
	;ͨ����ɫӵ���ӵ����ж�������̬
	.if person1.bullet==1
		.if person1.is_hit>0;�ж��е�
			invoke putImageScale, offset imgCharDie1, person1.pos_x, person1.pos_y,  person1.size_x,  person1.size_y
			sub person1.is_hit,1
		.endif
		.if person1.is_hit==0
			invoke putImageScale, offset imgCharShot1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
		.endif
	.endif
	.if person2.bullet==1
		.if person2.is_hit>0;�ж��е�
			invoke putImageScale, offset imgCharDie2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
			sub person2.is_hit,1
		.endif
		.if person2.is_hit==0
			invoke putImageScale, offset imgCharShot2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
		.endif
	.endif
	.if person1.bullet==0
		.if person1.is_hit>0;�ж��е�
			invoke putImageScale, offset imgCharDie1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
			sub person1.is_hit,1
		.endif
		.if person1.is_hit==0
			invoke putImageScale, offset imgCharRun1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
		.endif
	.endif
	.if person2.bullet==0	
		.if person2.is_hit>0;�ж��е�
			invoke putImageScale, offset imgCharDie2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
			sub person2.is_hit,1
		.endif
		.if person2.is_hit==0
			invoke putImageScale, offset imgCharRun2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
		.endif
	.endif
	ret
draw_man endp

;������
draw_prop proc
	;invoke loadImage, offset page2_potion, offset imgPotion
	invoke loadImage, offset page2_box, offset imgObBox
	invoke loadImage, offset page2_rub, offset imgObRubBin
	invoke loadImage, offset page2_potion, offset imgObPotion

	mov ebx,0
	mov edi,0
	.while ebx<Bounce_Num
		invoke putImageScale, offset imgObRubBin,(Prop ptr Prop_Bounce[edi]).pos_x,(Prop ptr Prop_Bounce[edi]).pos_y, (Prop ptr Prop_Bounce[edi]).size_x,(Prop ptr Prop_Bounce[edi]).size_y	
		add edi,type Prop ;Prop��С
		inc ebx
	.endw

	mov ebx,0
	mov edi,0
	.while ebx<Slow_Num
		invoke putImageScale, offset imgObBox,(Prop ptr Prop_Slow[edi]).pos_x,(Prop ptr Prop_Slow[edi]).pos_y, (Prop ptr Prop_Slow[edi]).size_x,(Prop ptr Prop_Slow[edi]).size_y	
		add edi,type Prop ;Prop��С
		inc ebx
	.endw

	mov ebx,0
	mov edi,0
	.while ebx<Big_Num
		invoke putImageScale, offset imgObPotion,(Prop ptr Prop_Big[edi]).pos_x,(Prop ptr Prop_Big[edi]).pos_y, (Prop ptr Prop_Big[edi]).size_x,(Prop ptr Prop_Big[edi]).size_y	
		add edi,type Prop ;Prop��С
		inc ebx
	.endw
	ret
draw_prop endp

;���ӵ�
draw_bullet proc p1:dword,p2:dword
	invoke printf,offset coord,p1,p2
	
	.if p1==1;showΪ0�򲻻�
		invoke loadImage, offset page2_char1_bul, offset imgCharBul1
		invoke putImageScale, offset imgCharBul1,bullet1.pos_x, bullet1.pos_y, bullet1.size_x, bullet1.size_y
	.endif

	.if p2==1				
		invoke loadImage, offset page2_char2_bul, offset imgCharBul2
		invoke putImageScale, offset imgCharBul2,bullet2.pos_x, bullet2.pos_y, bullet2.size_x, bullet2.size_y			
	.endif
	ret
draw_bullet endp
;Խ�硢�������ж�
check_hit_person proc uses ebx ecx x:dword,y:dword,p:dword
		
	local bound_up:dword	;�˵�������
	local bound_down:dword
	local bound_left:dword
	local bound_right:dword

	mov ebx,y
	mov ecx,x


	.if p==2

	mov eax,person1.pos_y
	sub eax,30
	mov bound_down,eax
	add eax,60
	mov bound_up,eax
	mov eax,person1.pos_x
	sub eax,30
	mov bound_left,eax
	add eax,60
	mov bound_right,eax

	.if ecx<=bound_right && ecx>=bound_right && ebx <= bound_up && ebx >=bound_down
			mov person1.is_hit,10;Ϊ�����е���������ʾ�����Щ����ʾ10֡
				invoke printf,offset coord,111 ,Big_flag2
				.if  Big_flag2 !=0
					.while Big_flag2>0
						sub person1.life,2
						dec Big_flag2
						invoke printf,offset life1Test,person1.life
						; û�����µ�ѭ���
					.endw 
				.else 
					sub person1.life,1
					invoke printf,offset life1Test,person1.life
				.endif
			.if person1.life == Zero ||person1.life == -1 || person1.life == -2 ||person1.life == -3 || person1.life == -4 || person1.life == -5 ||person1.life == -6 ||person1.life == -7 ||person1.life == -8 ||person1.life == -9 ||person1.life == -10
				invoke printf,offset tip,person1.life
				mov person1.life,0
				;invoke game_over
			.endif
			;.if p==1
			;	mov bullet1.show,0
			;.endif
			;.if p==2
			;	mov bullet2.show,0
			;.endif

			mov bullet2.show,0
			.if person1.bullet == 0 && bullet1.show == 0 && bullet2.show == 0
				mov person2.bullet,1
				mov person1.bullet,1
			.endif

	.endif
	.if ecx<=0 || ecx>=800
		mov bullet2.show,0
		.if person1.bullet == 0 && bullet1.show == 0 && bullet2.show == 0
			mov person2.bullet,1
			mov person1.bullet,1
		.endif
	.endif
	.if (ebx >400 || ebx <160)
			mov eax,-1
			imul bullet2.dir_y
			mov bullet2.dir_y,eax
	.endif
	.endif
	;.if person1.life<=0
	;	invoke game_over
	;.endif

	.if p==1
	mov eax,person2.pos_y
	sub eax,30
	mov bound_down,eax
	add eax,60
	mov bound_up,eax
	mov eax,person2.pos_x
	sub eax,30
	mov bound_left,eax
	add eax,60
	mov bound_right,eax
	.if ecx<=bound_right && ecx>=bound_left && ebx <= bound_up && ebx >=bound_down
			mov person2.is_hit,10;Ϊ�����е���������ʾ�����Щ����ʾ10֡
				invoke printf,offset coord,111 ,Big_flag1
				.if  Big_flag1 !=0
					.while Big_flag1>0
						sub person2.life,2
						dec Big_flag1
						invoke printf,offset life2Test,person2.life
					.endw
				.else 
					sub person2.life,1
					invoke printf,offset life2Test,person2.life
				.endif
			.if person2.life == Zero || person2.life == -1 || person2.life == -2 ||person2.life == -3 || person2.life == -4 || person2.life == -5 ||person2.life == -6 ||person2.life == -7 ||person2.life == -8 ||person2.life == -9 ||person2.life == -10
				invoke printf,offset tip,person2.life
				mov person2.life,0
				;invoke game_over
			.endif 
			;�����˺��ӵ�����ʾ
			;.if p==1
			;	mov bullet1.show,0
			;.endif
			;.if p==2
			;	mov bullet2.show,0
			;.endif
			mov bullet1.show,0
			.if person2.bullet == 0 && bullet1.show == 0 && bullet2.show == 0
				mov person1.bullet,1
				mov person2.bullet,1
			.endif
	.endif
	.if ecx>= 800 || ecx<=0
		mov bullet1.show,0
		.if person2.bullet == 0 && bullet1.show == 0 && bullet2.show == 0
			mov person1.bullet,1
			mov person2.bullet,1
		.endif
	.endif
	.if (ebx >400 || ebx <160)
			mov eax,-1
			imul bullet1.dir_y
			mov bullet1.dir_y,eax
	.endif
	.endif
	;.if person1.bullet==0 && person2.bullet==0;������ʾ���
	;	mov person1.bullet,1
	;	mov person2.bullet,1
	;.endif
	;.if person2.life<=0 || person1.life<=0
	;	invoke game_over
	;.endif
	ret
check_hit_person endp

;���е����ж�
check_hit_prop proc uses eax ebx ecx edi edx x:dword,y:dword,p:dword
		
	local bound_up:dword	;up-m_up�ӵ����ϵ�
	local bound_m_up:dword	;m_up-m_down ����
	local bound_m_down:dword;m_down-down ���µ�
	local bound_down:dword

	local bound_left:dword
	local bound_right:dword
	
	.if p==1;1�����ӵ�
		;edxѭ��������ecx,ebx xy����
		mov edi,0
		mov ecx,0
		mov ebx,y
		mov edx,x
		;Bounce
		.while ecx<Bounce_Num
			mov eax,(Prop ptr Prop_Bounce[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Bounce[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,8
			mov bound_m_up,eax
			sub eax,8
			mov bound_m_down,eax
			sub eax,8
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��						
					.if ebx>=bound_m_up && ebx<=bound_up;�ϰ벿 ;speed_y+=speed_x dir_y=1
						mov bullet1.dir_y,1
						mov eax,bullet1.speed_x
						add eax,bullet1.speed_y
						mov bullet1.speed_y,eax
					.endif
					.if ebx>=bound_m_down && ebx<=bound_m_up;�м䷴�� dir_x����
						mov eax,-1
						imul bullet1.dir_x
						mov bullet1.dir_x,eax
					.endif
					.if ebx<=bound_m_down && ebx>=bound_down	;���淴��
						mov bullet1.dir_y,-1
						mov eax,bullet1.speed_x
						add eax,bullet1.speed_y
						mov bullet1.speed_y,eax
					.endif		
					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Bounce[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Bounce[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw

		mov edi,0
		mov ecx,0
		.while ecx<Slow_Num
			mov eax,(Prop ptr Prop_Slow[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Slow[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,24
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��								
					sub bullet1.speed_x,4
					.if bullet1.speed_x <= 0
						mov bullet1.speed_x,2
					.endif

					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Slow[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Slow[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw


		mov edi,0
		mov ecx,0
		.while ecx<Big_Num
			mov eax,(Prop ptr Prop_Big[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Big[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,24
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��								
					inc	Big_flag1
					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Big[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Big[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw
	.endif
	
	.if p==2;2�����ӵ�
		;edxѭ��������ecx,ebx xy����
		mov edi,0
		mov ecx,0
		mov ebx,y
		mov edx,x
		;Bounce
		.while ecx<Bounce_Num
			mov eax,(Prop ptr Prop_Bounce[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Bounce[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,8
			mov bound_m_up,eax
			sub eax,8
			mov bound_m_down,eax
			sub eax,8
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��						
					.if ebx>=bound_m_up && ebx<=bound_up;�ϰ벿 ;speed_y+=speed_x dir_y=1
						mov bullet2.dir_y,1
						mov eax,bullet2.speed_x
						add eax,bullet2.speed_y
						mov bullet2.speed_y,eax
					.endif
					.if ebx>=bound_m_down && ebx<=bound_m_up;�м䷴�� dir_x����
						mov eax,-1
						imul bullet2.dir_x
						mov bullet2.dir_x,eax
					.endif
					.if ebx<=bound_m_down && ebx>=bound_down	;���淴��
						mov bullet2.dir_y,-1
						mov eax,bullet2.speed_x
						add eax,bullet2.speed_y
						mov bullet2.speed_y,eax
					.endif		
					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Bounce[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Bounce[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw

		mov edi,0
		mov ecx,0
		.while ecx<Slow_Num
			mov eax,(Prop ptr Prop_Slow[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Slow[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,24
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��								
					sub bullet2.speed_x,4
					.if bullet2.speed_x == 0
						mov bullet2.speed_x,2
					.endif

					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Slow[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Slow[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw

		mov edi,0
		mov ecx,0
		.while ecx<Big_Num
			mov eax,(Prop ptr Prop_Big[edi]).pos_x
			add eax,4
			mov bound_right,eax
			sub eax,8
			mov bound_left,eax
		
			mov eax,(Prop ptr Prop_Big[edi]).pos_y
			add eax,12
			mov bound_up,eax
			sub eax,24
			mov bound_down,eax

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x�ڷ�Χ��								
					inc	Big_flag2
					;���¸���λ��
					invoke getRand,370;150-600Ϊ����x����
					add eax,190;��Χ 190-560
					mov (Prop ptr Prop_Big[edi]).pos_x,eax

					invoke getRand,200;160-400Ϊ�������½�
					add eax,180;��Χ 180-580
					mov (Prop ptr Prop_Big[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif			
			add edi,type Prop ;Prop��С
			inc ecx	
		.endw
	.endif
	ret
check_hit_prop endp

draw_game proc
	;������㵱ǰλ��
	mov eax,person1.speed
	imul person1.dir
	add eax,person1.pos_y
	mov person1.pos_y,eax
	.if person1.pos_y>=400|| person1.pos_y<=160 ;�Ͻ�400�½�160
		mov eax,-1
		imul person1.dir
		mov person1.dir,eax
	.endif

	mov eax,person2.speed
	imul person2.dir
	add eax,person2.pos_y
	mov person2.pos_y,eax
	.if person2.pos_y>=400|| person2.pos_y<=160 ;�Ͻ�400�½�160
		mov eax,-1
		imul person2.dir
		mov person2.dir,eax
	.endif

	;�ӵ�����
	.if person1.bullet==0 && bullet1.show==1
		;mov bullet1.show,1;������ʾ
		mov eax,bullet1.speed_x;�����ٶ�x
		imul bullet1.dir_x
		add eax,bullet1.pos_x
		mov bullet1.pos_x,eax

		mov eax,bullet1.speed_y;�����ٶ�y
		imul bullet1.dir_y
		add eax,bullet1.pos_y
		mov bullet1.pos_y,eax
		invoke printf,offset coord,bullet1.pos_x,bullet1.pos_y
		invoke check_hit_prop,bullet1.pos_x,bullet1.pos_y,1;������е���
		invoke check_hit_person,bullet1.pos_x,bullet1.pos_y,1;���������				
	.endif

	.if person2.bullet==0 && bullet2.show==1 
		;mov bullet2.show,1;������ʾ
		mov eax,bullet2.speed_x;�����ٶ�
		imul bullet2.dir_x
		add eax,bullet2.pos_x
		mov bullet2.pos_x,eax
		invoke printf,offset coord,bullet2.pos_x,bullet2.pos_y
		invoke check_hit_prop,bullet2.pos_x,bullet2.pos_y,2;������е���
		invoke check_hit_person,bullet2.pos_x,bullet2.pos_y,2
		
	.endif
	;��Ϊ������������ͬʱ����ʱ���ܴ�����Ϸ״̬���־������ͬ�������������һ����־�����ĸ���


	;��ʼ��
	invoke beginPaint
	invoke clearDevice
	.if person1.life>0 && person2.life>0	;ͬʱ����0	
		invoke draw_bg ;������
		invoke draw_prop ;������
		invoke draw_bullet,bullet1.show,bullet2.show; ���ӵ�
		invoke draw_man	;����
	.else									; ��һ��С�ڵ���0
		mov curWindow,2
		invoke game_over
	.endif
	invoke endPaint
	ret
draw_game endp

;�жϰ�������
judge_area proc C uses ebx x:dword,y:dword,left:dword,right:dword,top:dword,bottom:dword
	;x,yΪ��갴��λ��
	mov eax,x
	mov ebx,y
	.if	eax <= left || eax >=right || ebx >= bottom || ebx <= top
		mov eax,0
	.else	
		mov eax,1
	.endif	
	ret
judge_area endp
;������� �õ�������rand_num��������浽eax

game_init proc
	mov curWindow, 1

	mov person1.pos_x,150
	mov person1.pos_y,280
	mov person1.size_x,40
	mov person1.size_y,40
	mov person1.dir,1
	mov person1.speed,5
	mov person1.bullet,1
	mov person1.life,5

	mov person2.pos_x,600
	mov person2.pos_y,280
	mov person2.size_x,40
	mov person2.size_y,40
	mov person2.dir,-1
	mov person2.speed,5
	mov person2.bullet,1
	mov person2.life,5

	;�ӵ��տ�ʼ����ʾ
	mov bullet1.show,0
	mov bullet2.show,0
	mov person1.is_hit,0
	mov person2.is_hit,0
	mov bullet1.size_x,5
	mov bullet2.size_x,5
	mov bullet1.size_y,5
	mov bullet2.size_y,5

	;����ʱ���ʼ��seed
	push 0
	call crt_time
	add esp,4
	mov seed,eax

	;���߳�ʼ��:

	;�����������
	invoke getRand,3
	add eax,5
	mov Bounce_Num,eax
	mov ebx,0
	mov edi,0
	.while ebx<Bounce_Num
		invoke getRand,320;150-600Ϊ����x����
		add eax,210;��Χ 190-560

		mov esi,0
		mov ecx,0
		.while ecx < ebx
			mov edx,(Prop ptr Prop_Bounce[esi]).pos_x
			sub edx,22
			.if eax >= edx 
				add edx,43
				.if eax <= edx
					mov cover_flag,1	
				.endif
			.endif
			add esi,type Prop ;Prop��С
			inc ecx
		.endw
		;invoke printf,offset coord,111,cover_flag
		.if cover_flag == 0
			mov (Prop ptr Prop_Bounce[edi]).pos_x,eax
		.else
			add eax,50
			mov (Prop ptr Prop_Bounce[edi]).pos_x,eax
		.endif
		mov cover_flag,0
		invoke getRand,200;160-400Ϊ�������½�
		add eax,180;��Χ 180-580
		mov (Prop ptr Prop_Bounce[edi]).pos_y,eax

		;���ߴ�С
		mov (Prop ptr Prop_Bounce[edi]).size_x,20
		mov (Prop ptr Prop_Bounce[edi]).size_y,24	
		invoke printf,offset coord,(Prop ptr Prop_Bounce[edi]).pos_x,(Prop ptr Prop_Bounce[edi]).pos_y
		add edi,type Prop ;Prop��С
		inc ebx
	.endw

	;����2������
	invoke getRand,3
	add eax,2 
	mov Slow_Num,eax ;��������
	mov ebx,0
	mov edi,0
	
	.while ebx<Slow_Num
		invoke getRand,320;150-600Ϊ����x����
		add eax,210;��Χ 210-540
		mov esi,0
		mov ecx,0
		.while ecx < Bounce_Num
			mov edx,(Prop ptr Prop_Bounce[esi]).pos_x
			sub edx,22
			.if eax >= edx 
				add edx,43
				.if eax <= edx
					mov cover_flag,1	
				.endif
			.endif
			add esi,type Prop ;Prop��С
			inc ecx
		.endw
		;invoke printf,offset coord,222,cover_flag
		.if cover_flag == 0
			mov (Prop ptr Prop_Slow[edi]).pos_x,eax
		.else
			add eax,50
			mov (Prop ptr Prop_Slow[edi]).pos_x,eax
		.endif
		mov cover_flag,0
		invoke getRand,200;160-400Ϊ�������½�
		add eax,180;��Χ 170-580
		mov (Prop ptr Prop_Slow[edi]).pos_y,eax
		;���ߴ�С
		mov (Prop ptr Prop_Slow[edi]).size_x,20
		mov (Prop ptr Prop_Slow[edi]).size_y,20		
		invoke printf,offset coord,(Prop ptr Prop_Slow[edi]).pos_x,(Prop ptr Prop_Slow[edi]).pos_y
		add edi,type Prop ;Prop��С
		inc ebx
	.endw

	;����2������
	invoke getRand,3
	add eax,2 
	mov Big_Num,eax ;��������
	mov ebx,0
	mov edi,0
	mov ecx,0
	.while ebx<Big_Num
		invoke getRand,320;150-600Ϊ����x����
		add eax,210;��Χ 190-560

		mov esi,0
		mov ecx,0
		.while ecx < Bounce_Num
			mov edx,(Prop ptr Prop_Bounce[esi]).pos_x
			sub edx,22
			.if eax >= edx 
				add edx,43
				.if eax <= edx
					mov cover_flag,1	
				.endif
			.endif
			add esi,type Prop ;Prop��С
			inc ecx
		.endw

		mov esi,0
		mov ecx,0
		.while ecx < Slow_Num
			mov edx,(Prop ptr Prop_Bounce[esi]).pos_x
			sub edx,22
			.if eax >= edx 
				add edx,43
				.if eax <= edx
					mov cover_flag,1	
				.endif
			.endif
			add esi,type Prop ;Prop��С
			inc ecx
		.endw
			;invoke printf,offset coord,333,cover_flag
		.if cover_flag == 0
			mov (Prop ptr Prop_Big[edi]).pos_x,eax
		.else
			add eax,50
			mov (Prop ptr Prop_Big[edi]).pos_x,eax
		.endif
		mov cover_flag,0
		invoke getRand,200;160-400Ϊ�������½�
		add eax,180;��Χ 170-580
		mov (Prop ptr Prop_Big[edi]).pos_y,eax
		;���ߴ�С
		mov (Prop ptr Prop_Big[edi]).size_x,20
		mov (Prop ptr Prop_Big[edi]).size_y,20		
		invoke printf,offset coord,(Prop ptr Prop_Big[edi]).pos_x,(Prop ptr Prop_Big[edi]).pos_y
		add edi,type Prop ;Prop��С
		inc ebx
	.endw

	invoke printf,offset coord,Bounce_Num,Slow_Num


game_init endp

iface_mouseEvent proc C x:dword,y:dword,button:dword,event:dword
	.if button == LEFT_BUTTON && event == BUTTON_DOWN
		.if	curWindow == 0;��ǰ��������
			invoke judge_area,x,y,start_button.left,start_button.right,start_button.top,start_button.bottom
			.if eax==1
				invoke printf,offset coord,x,y
				;��Ϸ��ʼ�����ó�ʼֵ
				invoke game_init
				;����ѭ����30ms����
				invoke startTimer,0,30
			.endif
			invoke judge_area,x,y,exit_button.left,exit_button.right,exit_button.top,exit_button.bottom
			.if eax ==1
				invoke ExitProcess, NULL
			.endif

		.endif
		.if curWindow == 2
			invoke judge_area,x,y,exit_button.left,exit_button.right,exit_button.top,exit_button.bottom
			.if eax ==1
				invoke ExitProcess, NULL
			.endif
		.endif
	.endif
	ret
iface_mouseEvent endp

iface_keyboardEvent proc C key:dword,event:dword
	.if curWindow == 1
		;invoke printf,offset coord,person1.dir,person2.dir
		.if key == VK_LEFT && event==BUTTON_DOWN;�������������ע��һ��Ҫ�ǰ���;��Ȼ������
			.if person1.bullet==1;���ӵ�
				mov person1.bullet,0
				;�����ӵ������������ӵ���ʼ����Ϣ
				mov eax,person1.pos_x
				mov bullet1.pos_x,eax
				mov eax,person1.pos_y
				mov bullet1.pos_y,eax
				mov bullet1.dir_x,1
				mov bullet1.dir_y,0
				mov bullet1.speed_x,12
				mov bullet1.speed_y,12
				mov bullet1.show,1
			.else ;������
				mov eax,-1
				imul person1.dir
				mov person1.dir,eax
			.endif
		.endif
		.if key == VK_RIGHT && event==BUTTON_DOWN
			.if person2.bullet==1;���ӵ�
				mov person2.bullet,0
				mov eax,person2.pos_x
				mov bullet2.pos_x,eax
				mov eax,person2.pos_y
				mov bullet2.pos_y,eax
				mov bullet2.dir_x,-1
				mov bullet2.dir_y,0
				mov bullet2.speed_x,12
				mov bullet2.speed_y,0
				mov bullet2.show,1
			.else ;������
				mov eax,-1
				imul person2.dir
				mov person2.dir,eax
			.endif
		.endif
			
	.endif
	ret
iface_keyboardEvent endp

start_menu proc C
	;����ͼƬ
	invoke loadImage, offset page1_Bg, offset imgBg
	invoke loadImage, offset page1_Title, offset imgTitle
	invoke loadImage, offset page1_Start, offset imgStart
	invoke loadImage, offset page1_Exit, offset imgExit	

	;��ʾ������
	invoke beginPaint
	invoke putImageScale, offset imgBg, 0, 0, 800, 600
	invoke putImageScale, offset imgTitle, 200, 100, 400, 100
	invoke putImageScale, offset imgStart, 260, 300, 240, 100
	invoke putImageScale, offset imgExit, 260, 450, 240, 100
	invoke endPaint

	;���ò���:
	mov curWindow,0
	ret 
start_menu endp
;
iface_timerEvent proc c tid: dword
	.if tid == 0;��Ϸ��ѭ��
		invoke draw_game
	.endif
	ret
iface_timerEvent endp

main proc c
	invoke init_first  ;��ʼ����ͼ����
	invoke initWindow, offset winTitle, 250, 30, 800, 600 ;���Ͻǵ����꣬����Ŀ��
	
	invoke loadSound, addr music_Bg, addr music_BgP
	invoke playSound, music_BgP, 1

	invoke registerMouseEvent,iface_mouseEvent 
	invoke registerKeyboardEvent, iface_keyboardEvent
	invoke registerTimerEvent, iface_timerEvent

	invoke start_menu;����ʼ�˵��Լ���ʼֵ
	invoke init_second
main ENDP
END main