.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib
includelib acllib.lib

include acllib.inc
include ui.inc
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
flag dword 0
menu_start_game_left dword 260
menu_start_game_right dword 500
menu_start_game_up dword 300
menu_start_game_bottom dword 400

menu_exit_game_left dword 260
menu_exit_game_right dword 500
menu_exit_game_up dword 450
menu_exit_game_bottom dword 550
t byte "hhh "

printf PROTO C:ptr 

.code
judge_area proc C uses ebx x:dword,y:dword,left:dword,right:dword,up:dword,bottom:dword
	mov eax,x
	mov ebx,y
	.if	eax <= left
		mov eax,0
	.elseif	eax >= right
		mov eax,0
	.elseif ebx >= bottom
		mov eax,0
	.elseif ebx <= up
		mov eax,0
	.else	
		mov eax,1
	.endif	
	ret
judge_area endp






iface_mouseEvent proc C x:dword,y:dword,button:dword,event:dword
	.if event != BUTTON_DOWN
		ret
	.endif

	.if flag == 1
	
		invoke inload
		mov flag,0
		keep:
		invoke begin_run
		jmp keep
		invoke endPaint
	.endif

	.if	currWindow == 0;¿ªÊ¼²Ëµ¥
		invoke judge_area,x,y,menu_start_game_left,menu_start_game_right,menu_start_game_up,menu_start_game_bottom
		.if eax == 1			
			invoke mouseEvent, 0
	
			mov currWindow, 1
			mov pos_now1,400
			mov pos_now2,160
			mov flag,1
					
			;mov cur_timer, 50
			;invoke startTimer, 0, cur_timer
		.endif

		invoke judge_area,x,y,menu_exit_game_left,menu_exit_game_right,menu_exit_game_up,menu_exit_game_bottom
		.if eax == 1
			invoke mouseEvent, 1
		.endif


	.endif



	ret

iface_mouseEvent endp


iface_keyboardEvent proc C key:dword,event:dword
	
	.if currWindow == 1
		.if key == VK_LEFT 
				invoke printf ,offset t		
		.endif

		.if key == VK_RIGHT 
		.endif
	.endif

	ret
iface_keyboardEvent endp

end