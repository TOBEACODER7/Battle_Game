.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib
includelib acllib.lib

include acllib.inc
include var.inc
include msvcrt.inc

include		windows.inc
include		gdi32.inc

include		kernel32.inc
include		user32.inc
include		winmm.inc
includelib	gdi32.lib

includelib	winmm.lib
includelib	user32.lib
includelib	kernel32.lib
.data
pos_high dword 0
pos_low dword 0

flag_dir dword 0

music_Bg byte "resource\music\bg.mp3", 0
music_BgP dd 0

page1_Bg byte "resource\pic\backgrounds\startPage\1.bmp", 0
page1_Title byte "resource\pic\UIs\exampleTitle.bmp", 0
page1_Start byte "resource\pic\UIs\startButton.bmp", 0
page1_Exit byte "resource\pic\UIs\exitButton.bmp", 0


page2_Bg byte "resource\pic\backgrounds\gameBackground_V1.bmp", 0
page2_char1_run byte "resource\pic\characters\p1_run.bmp", 0
page2_char1_hurt byte "resource\pic\characters\p1_hurt.bmp", 0
page2_char1_shot byte "resource\pic\characters\p1_shot.bmp", 0
page2_char1_die byte "resource\pic\characters\p1_die.bmp", 0
page2_char1_bul byte "resource\pic\bullets\p1_bul.bmp", 0

page2_char2_run byte "resource\pic\characters\p2_run.bmp", 0
page2_char2_hurt byte "resource\pic\characters\p2_hurt.bmp", 0
page2_char2_shot byte "resource\pic\characters\p2_shot.bmp", 0
page2_char2_die byte "resource\pic\characters\p2_die.bmp", 0
page2_char2_bul byte "resource\pic\bullets\p2_bul.bmp", 0

page2_ob_box byte "resource\pic\obstacles\box.bmp",0
page2_ob_potion byte "resource\pic\obstacles\potion.bmp",0
page2_ob_rubBin byte "resource\pic\obstacles\rubBin.bmp",0

page2_vs byte "resource\pic\UIs\VS.bmp", 0

page3_Bg byte "resource\pic\backgrounds\startPage\2.bmp", 0
;page3_y byte
;page3_o byte

imgBg ACL_Image <>
imgTitle ACL_Image <>
imgStart ACL_Image <>
imgExit ACL_Image <>

imgBg2 ACL_Image <>
imgCharRun1 ACL_Image <>
imgCharHurt1 ACL_Image <>
imgCharShot1 ACL_Image <>
imgCharDie1 ACL_Image <>
imgCharBul1 ACL_Image <>

imgCharRun2 ACL_Image <>
imgCharHurt2 ACL_Image <>
imgCharShot2 ACL_Image <>
imgCharDie2 ACL_Image <>
imgCharBul2 ACL_Image <>

imgObBox ACL_Image <>
imgObPotion ACL_Image <>
imgObRubBin ACL_Image <>
imgVS ACL_Image <>

imgBg3 ACL_Image <>
imgY ACL_Image <>
imgO ACL_Image <>
t byte "hhh %d",0ah,0


printf PROTO C:ptr sbyte,:ptr sbyte,:vararg
.code



page_start proc C
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

	ret 
page_start endp


getRand proc c uses ecx edx rand_num: dword
	;设置随机种子
	push 0
	call crt_time
	add esp,4
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



random_box proc C ;一对多

	invoke putImageScale, offset imgObBox, 480, 200, 50, 50

	invoke putImageScale, offset imgObBox, 280, 300, 50, 50

	invoke putImageScale, offset imgObBox, 380, 400, 50, 50


	ret

random_box endp


random_potion proc C ;折射

	invoke putImageScale, offset imgObPotion	, 380, 200, 50, 50
	invoke putImageScale, offset imgObPotion	, 380, 300, 50, 50
	invoke putImageScale, offset imgObPotion	, 480, 300, 50, 50
	invoke putImageScale, offset imgObPotion	, 280, 400, 50, 50

	ret
random_potion endp


random_rubBin proc C ;吸收
	invoke putImageScale, offset imgObRubBin , 280, 200, 50, 50
	ret
random_rubBin endp



page_game proc C
	;载入图片
	invoke loadImage, offset page2_Bg, offset imgBg2
	invoke loadImage, offset page2_vs, offset imgVS
	
	invoke loadImage, offset page2_char1_run, offset imgCharRun1
	invoke loadImage, offset page2_char2_run, offset imgCharRun2

	invoke loadImage, offset page2_ob_box, offset imgObBox	
	invoke loadImage, offset page2_ob_potion, offset imgObPotion	
	invoke loadImage, offset page2_ob_rubBin, offset imgObRubBin 
	
	invoke loadSound, addr music_Bg, addr music_BgP
	invoke playSound, music_BgP, 1


	;显示主界面
	invoke beginPaint
	invoke putImageScale, offset imgBg2, 0, 0, 800, 600
	invoke putImageScale, offset imgVS, 130, 480, 550, 80
	
	invoke putImageScale, offset imgCharRun1, 150, 400, 60, 60
	invoke putImageScale, offset imgCharRun2, 600, 160, 60, 60

	invoke random_box
	invoke random_potion
	invoke random_rubBin

	invoke endPaint

	ret 
page_game endp


page_again proc C
	invoke putImageScale, offset imgBg2, 0, 0, 800, 600
	invoke putImageScale, offset imgVS, 130, 480, 550, 80
	

	invoke random_box
	invoke random_potion
	invoke random_rubBin
	ret 
page_again endp


page_over proc C

	invoke loadImage, offset page3_Bg, offset imgBg3
	invoke loadImage, offset page1_Exit, offset imgExit	

	;invoke loadImage, offset page3_y, offset imgY	
	;invoke loadImage, offset page3_o, offset imgO	


	invoke beginPaint
	;.if 
	;	invoke putImageScale, offset imgY, 200, 100, 400, 100
	;.else 
	;	invoke putImageScale, offset imgO, 200, 100, 400, 100
	;.endif

	invoke putImageScale, offset imgBg2, 0, 0, 800, 600
	invoke putImageScale, offset imgExit, 260, 450, 240, 100

	invoke endPaint

	ret 
page_over endp



mouseEvent proc C windowType:dword
	pushad
	.if currWindow == 0 && windowType == 0;开始游戏
		invoke page_game
	
	.elseif currWindow == 0 && windowType == 1;退出游戏
		invoke crt_exit, 0
	.endif
	popad
	ret
mouseEvent endp


inload proc C
		invoke loadImage, offset page2_char1_run, offset imgCharRun1
		invoke loadImage, offset page2_char2_run, offset imgCharRun2
		invoke beginPaint
		ret
inload endp

begin_run proc C

;keep:
	.if pos_now1== 400 && pos_now2 == 160
		mov flag_dir,0
	.endif

	.if pos_now2== 400 && pos_now1 == 160
		mov flag_dir,1
	.endif

	.if pos_now1 > 160 && pos_now2 < 410 && pos_now2 > 0 && flag_dir == 0
		
		invoke clearDevice 

		invoke page_again
		
		invoke printf ,offset t, pos_now1
		invoke printf ,offset t, pos_now2
		sub pos_now1,20
		add pos_now2,20
		invoke putImageScale, offset imgCharRun1, 150, pos_now1, 60, 60
		invoke putImageScale, offset imgCharRun2, 600, pos_now2, 60, 60
	;	invoke Sleep ,500	
	

	.elseif pos_now1 <= 400 && pos_now2 >= 160 && pos_now1 >= 0	&& flag_dir == 1

		invoke clearDevice 

		invoke page_again
				
	invoke printf ,offset t, pos_now1;400
		invoke printf ,offset t, pos_now2;170
		add pos_now1,20
		sub pos_now2,20
		;invoke Sleep ,500
		invoke putImageScale, offset imgCharRun1, 150, pos_now1, 60, 60
		invoke putImageScale, offset imgCharRun2, 600, pos_now2, 60, 60	;	
	
	.endif
	;jmp keep
	ret
begin_run endp

end