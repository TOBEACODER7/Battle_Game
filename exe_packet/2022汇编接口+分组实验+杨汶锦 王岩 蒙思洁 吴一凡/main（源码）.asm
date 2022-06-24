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
;打印相关
winTitle byte "Battle-Battle", 0
coord sbyte "%d,%d",10,0
tmp dword 0
life1Test sbyte "1:life: %d",0ah,0
life2Test sbyte "2:life: %d",0ah,0
tip	sbyte "--------------------------------fu!: %d",0ah,0

;图片资源相关
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


;控制相关
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
	life	dd	?;生命值
	pos_x dd ?;横坐标--不变定死
	pos_y dd ?;纵坐标--上下移动
	size_x	dd	?;大小
	size_y	dd	?
	dir	dd	?;移动方向--1为上-1为下
	speed	dd	?;速度大小--
	bullet	dd	?;子弹数
	is_hit dd	?;是否击中或越界
person ends
person1 person<>
person2	person<>

Bullet struct
	show	dd	?;显示与否
	pos_x dd ?;横坐标
	pos_y dd ?;纵坐标
	dir_x	dd	?;移动方向--1为右，-1为左
	dir_y	dd	?;纵向移动方向 ---用于反弹
	size_x	dd	?;大小
	size_y	dd	?
	speed_x	dd	?;速度大小
	speed_y	dd	?
Bullet ends
bullet1 Bullet<>
bullet2	Bullet<>

seed	dd	?;随机生成数，用于道具生成
Prop struct
	pos_x dd ?;横坐标
	pos_y dd ?;纵坐标
	size_x	dd	?;大小
	size_y	dd	?
	;is_hit dd	?;是否击中
Prop ends
Prop_Bounce Prop 10 dup(<>);回弹的
Bounce_Num	dd	?

Prop_Slow Prop 10 dup(<>);减速的的
Slow_Num	dd	?

Prop_Big Prop 10 dup(<>);变大变强的?
Big_Num	dd	?
Big_flag1 dword 0
Big_flag2 dword 0

cover_flag dword 0

.code
;随机过程
getRand proc c uses ecx edx rand_num: dword
	;设置随机种子
	push 0
	call crt_time
	add esp,4

	add eax,seed
	mov seed,eax;seed更新
	
	push eax
	call crt_srand
	add esp,4

	invoke crt_rand
	mov edx, 0
	mov ecx, rand_num
	div ecx
	mov eax, edx;返回余数
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

;画背景
draw_bg proc
	invoke loadImage, offset page2_Bg, offset imgBg2
	invoke loadImage, offset page2_vs, offset imgVS
	invoke loadImage, offset page2_char1_life, offset imgCharLife1
	invoke loadImage, offset page2_char2_life, offset imgCharLife2

	invoke putImageScale, offset imgBg2, 0, 0, 800, 600
	invoke putImageScale, offset imgVS, 130, 480, 550, 80
	
	;分数显示判断
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

;画人
draw_man proc	
	invoke loadImage, offset page2_char1_run, offset imgCharRun1
	invoke loadImage, offset page2_char2_run, offset imgCharRun2

	invoke loadImage, offset page2_char1_shot, offset imgCharShot1
	invoke loadImage, offset page2_char2_shot, offset imgCharShot2

	invoke loadImage, offset page2_char1_hurt, offset imgCharHurt1
	invoke loadImage, offset page2_char2_hurt, offset imgCharHurt2

	invoke loadImage, offset page2_char1_die, offset imgCharDie1
	invoke loadImage, offset page2_char2_die, offset imgCharDie2
	
	;通过角色拥有子弹数判断人物形态
	.if person1.bullet==1
		.if person1.is_hit>0;判断中弹
			invoke putImageScale, offset imgCharDie1, person1.pos_x, person1.pos_y,  person1.size_x,  person1.size_y
			sub person1.is_hit,1
		.endif
		.if person1.is_hit==0
			invoke putImageScale, offset imgCharShot1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
		.endif
	.endif
	.if person2.bullet==1
		.if person2.is_hit>0;判断中弹
			invoke putImageScale, offset imgCharDie2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
			sub person2.is_hit,1
		.endif
		.if person2.is_hit==0
			invoke putImageScale, offset imgCharShot2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
		.endif
	.endif
	.if person1.bullet==0
		.if person1.is_hit>0;判断中弹
			invoke putImageScale, offset imgCharDie1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
			sub person1.is_hit,1
		.endif
		.if person1.is_hit==0
			invoke putImageScale, offset imgCharRun1, person1.pos_x, person1.pos_y, person1.size_x,  person1.size_y
		.endif
	.endif
	.if person2.bullet==0	
		.if person2.is_hit>0;判断中弹
			invoke putImageScale, offset imgCharDie2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
			sub person2.is_hit,1
		.endif
		.if person2.is_hit==0
			invoke putImageScale, offset imgCharRun2, person2.pos_x, person2.pos_y, person2.size_x,  person2.size_y
		.endif
	.endif
	ret
draw_man endp

;画道具
draw_prop proc
	;invoke loadImage, offset page2_potion, offset imgPotion
	invoke loadImage, offset page2_box, offset imgObBox
	invoke loadImage, offset page2_rub, offset imgObRubBin
	invoke loadImage, offset page2_potion, offset imgObPotion

	mov ebx,0
	mov edi,0
	.while ebx<Bounce_Num
		invoke putImageScale, offset imgObRubBin,(Prop ptr Prop_Bounce[edi]).pos_x,(Prop ptr Prop_Bounce[edi]).pos_y, (Prop ptr Prop_Bounce[edi]).size_x,(Prop ptr Prop_Bounce[edi]).size_y	
		add edi,type Prop ;Prop大小
		inc ebx
	.endw

	mov ebx,0
	mov edi,0
	.while ebx<Slow_Num
		invoke putImageScale, offset imgObBox,(Prop ptr Prop_Slow[edi]).pos_x,(Prop ptr Prop_Slow[edi]).pos_y, (Prop ptr Prop_Slow[edi]).size_x,(Prop ptr Prop_Slow[edi]).size_y	
		add edi,type Prop ;Prop大小
		inc ebx
	.endw

	mov ebx,0
	mov edi,0
	.while ebx<Big_Num
		invoke putImageScale, offset imgObPotion,(Prop ptr Prop_Big[edi]).pos_x,(Prop ptr Prop_Big[edi]).pos_y, (Prop ptr Prop_Big[edi]).size_x,(Prop ptr Prop_Big[edi]).size_y	
		add edi,type Prop ;Prop大小
		inc ebx
	.endw
	ret
draw_prop endp

;画子弹
draw_bullet proc p1:dword,p2:dword
	invoke printf,offset coord,p1,p2
	
	.if p1==1;show为0则不画
		invoke loadImage, offset page2_char1_bul, offset imgCharBul1
		invoke putImageScale, offset imgCharBul1,bullet1.pos_x, bullet1.pos_y, bullet1.size_x, bullet1.size_y
	.endif

	.if p2==1				
		invoke loadImage, offset page2_char2_bul, offset imgCharBul2
		invoke putImageScale, offset imgCharBul2,bullet2.pos_x, bullet2.pos_y, bullet2.size_x, bullet2.size_y			
	.endif
	ret
draw_bullet endp
;越界、射中人判断
check_hit_person proc uses ebx ecx x:dword,y:dword,p:dword
		
	local bound_up:dword	;人的上下限
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
			mov person1.is_hit,10;为了让中弹的样子显示更清楚些，显示10帧
				invoke printf,offset coord,111 ,Big_flag2
				.if  Big_flag2 !=0
					.while Big_flag2>0
						sub person1.life,2
						dec Big_flag2
						invoke printf,offset life1Test,person1.life
						; 没进底下的循环里。
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
			mov person2.is_hit,10;为了让中弹的样子显示更清楚些，显示10帧
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
			;击中人后子弹不显示
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
	;.if person1.bullet==0 && person2.bullet==0;都不显示则填弹
	;	mov person1.bullet,1
	;	mov person2.bullet,1
	;.endif
	;.if person2.life<=0 || person1.life<=0
	;	invoke game_over
	;.endif
	ret
check_hit_person endp

;射中道具判断
check_hit_prop proc uses eax ebx ecx edi edx x:dword,y:dword,p:dword
		
	local bound_up:dword	;up-m_up子弹向上弹
	local bound_m_up:dword	;m_up-m_down 反弹
	local bound_m_down:dword;m_down-down 向下弹
	local bound_down:dword

	local bound_left:dword
	local bound_right:dword
	
	.if p==1;1发的子弹
		;edx循环计数，ecx,ebx xy坐标
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内						
					.if ebx>=bound_m_up && ebx<=bound_up;上半部 ;speed_y+=speed_x dir_y=1
						mov bullet1.dir_y,1
						mov eax,bullet1.speed_x
						add eax,bullet1.speed_y
						mov bullet1.speed_y,eax
					.endif
					.if ebx>=bound_m_down && ebx<=bound_m_up;中间反弹 dir_x反向
						mov eax,-1
						imul bullet1.dir_x
						mov bullet1.dir_x,eax
					.endif
					.if ebx<=bound_m_down && ebx>=bound_down	;下面反弹
						mov bullet1.dir_y,-1
						mov eax,bullet1.speed_x
						add eax,bullet1.speed_y
						mov bullet1.speed_y,eax
					.endif		
					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Bounce[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Bounce[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop大小
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内								
					sub bullet1.speed_x,4
					.if bullet1.speed_x <= 0
						mov bullet1.speed_x,2
					.endif

					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Slow[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Slow[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop大小
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内								
					inc	Big_flag1
					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Big[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Big[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop大小
			inc ecx	
		.endw
	.endif
	
	.if p==2;2发的子弹
		;edx循环计数，ecx,ebx xy坐标
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内						
					.if ebx>=bound_m_up && ebx<=bound_up;上半部 ;speed_y+=speed_x dir_y=1
						mov bullet2.dir_y,1
						mov eax,bullet2.speed_x
						add eax,bullet2.speed_y
						mov bullet2.speed_y,eax
					.endif
					.if ebx>=bound_m_down && ebx<=bound_m_up;中间反弹 dir_x反向
						mov eax,-1
						imul bullet2.dir_x
						mov bullet2.dir_x,eax
					.endif
					.if ebx<=bound_m_down && ebx>=bound_down	;下面反弹
						mov bullet2.dir_y,-1
						mov eax,bullet2.speed_x
						add eax,bullet2.speed_y
						mov bullet2.speed_y,eax
					.endif		
					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Bounce[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Bounce[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif			
			add edi,type Prop ;Prop大小
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内								
					sub bullet2.speed_x,4
					.if bullet2.speed_x == 0
						mov bullet2.speed_x,2
					.endif

					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Slow[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Slow[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif
			
			add edi,type Prop ;Prop大小
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

			.if edx>=bound_left && edx<=bound_right	&& ebx<=bound_up &&  ebx>=bound_down;x在范围内								
					inc	Big_flag2
					;重新更新位置
					invoke getRand,370;150-600为人物x坐标
					add eax,190;范围 190-560
					mov (Prop ptr Prop_Big[edi]).pos_x,eax

					invoke getRand,200;160-400为人物上下界
					add eax,180;范围 180-580
					mov (Prop ptr Prop_Big[edi]).pos_y,eax
					;invoke printf,offset coord,eax,eax			
			.endif			
			add edi,type Prop ;Prop大小
			inc ecx	
		.endw
	.endif
	ret
check_hit_prop endp

draw_game proc
	;人物计算当前位置
	mov eax,person1.speed
	imul person1.dir
	add eax,person1.pos_y
	mov person1.pos_y,eax
	.if person1.pos_y>=400|| person1.pos_y<=160 ;上界400下界160
		mov eax,-1
		imul person1.dir
		mov person1.dir,eax
	.endif

	mov eax,person2.speed
	imul person2.dir
	add eax,person2.pos_y
	mov person2.pos_y,eax
	.if person2.pos_y>=400|| person2.pos_y<=160 ;上界400下界160
		mov eax,-1
		imul person2.dir
		mov person2.dir,eax
	.endif

	;子弹计算
	.if person1.bullet==0 && bullet1.show==1
		;mov bullet1.show,1;开启显示
		mov eax,bullet1.speed_x;计算速度x
		imul bullet1.dir_x
		add eax,bullet1.pos_x
		mov bullet1.pos_x,eax

		mov eax,bullet1.speed_y;计算速度y
		imul bullet1.dir_y
		add eax,bullet1.pos_y
		mov bullet1.pos_y,eax
		invoke printf,offset coord,bullet1.pos_x,bullet1.pos_y
		invoke check_hit_prop,bullet1.pos_x,bullet1.pos_y,1;计算击中道具
		invoke check_hit_person,bullet1.pos_x,bullet1.pos_y,1;计算击中人				
	.endif

	.if person2.bullet==0 && bullet2.show==1 
		;mov bullet2.show,1;开启显示
		mov eax,bullet2.speed_x;计算速度
		imul bullet2.dir_x
		add eax,bullet2.pos_x
		mov bullet2.pos_x,eax
		invoke printf,offset coord,bullet2.pos_x,bullet2.pos_y
		invoke check_hit_prop,bullet2.pos_x,bullet2.pos_y,2;计算击中道具
		invoke check_hit_person,bullet2.pos_x,bullet2.pos_y,2
		
	.endif
	;因为发现了两个人同时发射时可能存在游戏状态与标志变量不同步的情况，故做一个标志变量的更新


	;开始画
	invoke beginPaint
	invoke clearDevice
	.if person1.life>0 && person2.life>0	;同时大于0	
		invoke draw_bg ;画背景
		invoke draw_prop ;画道具
		invoke draw_bullet,bullet1.show,bullet2.show; 画子弹
		invoke draw_man	;画人
	.else									; 有一方小于等于0
		mov curWindow,2
		invoke game_over
	.endif
	invoke endPaint
	ret
draw_game endp

;判断按下区域
judge_area proc C uses ebx x:dword,y:dword,left:dword,right:dword,top:dword,bottom:dword
	;x,y为鼠标按下位置
	mov eax,x
	mov ebx,y
	.if	eax <= left || eax >=right || ebx >= bottom || ebx <= top
		mov eax,0
	.else	
		mov eax,1
	.endif	
	ret
judge_area endp
;随机函数 得到不大于rand_num的随机数存到eax

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

	;子弹刚开始不显示
	mov bullet1.show,0
	mov bullet2.show,0
	mov person1.is_hit,0
	mov person2.is_hit,0
	mov bullet1.size_x,5
	mov bullet2.size_x,5
	mov bullet1.size_y,5
	mov bullet2.size_y,5

	;依靠时间初始化seed
	push 0
	call crt_time
	add esp,4
	mov seed,eax

	;道具初始化:

	;最少五个反弹
	invoke getRand,3
	add eax,5
	mov Bounce_Num,eax
	mov ebx,0
	mov edi,0
	.while ebx<Bounce_Num
		invoke getRand,320;150-600为人物x坐标
		add eax,210;范围 190-560

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
			add esi,type Prop ;Prop大小
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
		invoke getRand,200;160-400为人物上下界
		add eax,180;范围 180-580
		mov (Prop ptr Prop_Bounce[edi]).pos_y,eax

		;道具大小
		mov (Prop ptr Prop_Bounce[edi]).size_x,20
		mov (Prop ptr Prop_Bounce[edi]).size_y,24	
		invoke printf,offset coord,(Prop ptr Prop_Bounce[edi]).pos_x,(Prop ptr Prop_Bounce[edi]).pos_y
		add edi,type Prop ;Prop大小
		inc ebx
	.endw

	;最少2个减速
	invoke getRand,3
	add eax,2 
	mov Slow_Num,eax ;保存数字
	mov ebx,0
	mov edi,0
	
	.while ebx<Slow_Num
		invoke getRand,320;150-600为人物x坐标
		add eax,210;范围 210-540
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
			add esi,type Prop ;Prop大小
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
		invoke getRand,200;160-400为人物上下界
		add eax,180;范围 170-580
		mov (Prop ptr Prop_Slow[edi]).pos_y,eax
		;道具大小
		mov (Prop ptr Prop_Slow[edi]).size_x,20
		mov (Prop ptr Prop_Slow[edi]).size_y,20		
		invoke printf,offset coord,(Prop ptr Prop_Slow[edi]).pos_x,(Prop ptr Prop_Slow[edi]).pos_y
		add edi,type Prop ;Prop大小
		inc ebx
	.endw

	;最少2个减速
	invoke getRand,3
	add eax,2 
	mov Big_Num,eax ;保存数字
	mov ebx,0
	mov edi,0
	mov ecx,0
	.while ebx<Big_Num
		invoke getRand,320;150-600为人物x坐标
		add eax,210;范围 190-560

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
			add esi,type Prop ;Prop大小
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
			add esi,type Prop ;Prop大小
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
		invoke getRand,200;160-400为人物上下界
		add eax,180;范围 170-580
		mov (Prop ptr Prop_Big[edi]).pos_y,eax
		;道具大小
		mov (Prop ptr Prop_Big[edi]).size_x,20
		mov (Prop ptr Prop_Big[edi]).size_y,20		
		invoke printf,offset coord,(Prop ptr Prop_Big[edi]).pos_x,(Prop ptr Prop_Big[edi]).pos_y
		add edi,type Prop ;Prop大小
		inc ebx
	.endw

	invoke printf,offset coord,Bounce_Num,Slow_Num


game_init endp

iface_mouseEvent proc C x:dword,y:dword,button:dword,event:dword
	.if button == LEFT_BUTTON && event == BUTTON_DOWN
		.if	curWindow == 0;当前在主界面
			invoke judge_area,x,y,start_button.left,start_button.right,start_button.top,start_button.bottom
			.if eax==1
				invoke printf,offset coord,x,y
				;游戏开始，设置初始值
				invoke game_init
				;开启循环，30ms触发
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
		.if key == VK_LEFT && event==BUTTON_DOWN;按下左键，！！注意一定要是按下;不然算两次
			.if person1.bullet==1;有子弹
				mov person1.bullet,0
				;其他子弹操作：设置子弹初始化信息
				mov eax,person1.pos_x
				mov bullet1.pos_x,eax
				mov eax,person1.pos_y
				mov bullet1.pos_y,eax
				mov bullet1.dir_x,1
				mov bullet1.dir_y,0
				mov bullet1.speed_x,12
				mov bullet1.speed_y,12
				mov bullet1.show,1
			.else ;换方向
				mov eax,-1
				imul person1.dir
				mov person1.dir,eax
			.endif
		.endif
		.if key == VK_RIGHT && event==BUTTON_DOWN
			.if person2.bullet==1;有子弹
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
			.else ;换方向
				mov eax,-1
				imul person2.dir
				mov person2.dir,eax
			.endif
		.endif
			
	.endif
	ret
iface_keyboardEvent endp

start_menu proc C
	;载入图片
	invoke loadImage, offset page1_Bg, offset imgBg
	invoke loadImage, offset page1_Title, offset imgTitle
	invoke loadImage, offset page1_Start, offset imgStart
	invoke loadImage, offset page1_Exit, offset imgExit	

	;显示主界面
	invoke beginPaint
	invoke putImageScale, offset imgBg, 0, 0, 800, 600
	invoke putImageScale, offset imgTitle, 200, 100, 400, 100
	invoke putImageScale, offset imgStart, 260, 300, 240, 100
	invoke putImageScale, offset imgExit, 260, 450, 240, 100
	invoke endPaint

	;设置参数:
	mov curWindow,0
	ret 
start_menu endp
;
iface_timerEvent proc c tid: dword
	.if tid == 0;游戏主循环
		invoke draw_game
	.endif
	ret
iface_timerEvent endp

main proc c
	invoke init_first  ;初始化绘图环境
	invoke initWindow, offset winTitle, 250, 30, 800, 600 ;左上角的坐标，窗体的宽高
	
	invoke loadSound, addr music_Bg, addr music_BgP
	invoke playSound, music_BgP, 1

	invoke registerMouseEvent,iface_mouseEvent 
	invoke registerKeyboardEvent, iface_keyboardEvent
	invoke registerTimerEvent, iface_timerEvent

	invoke start_menu;画初始菜单以及初始值
	invoke init_second
main ENDP
END main