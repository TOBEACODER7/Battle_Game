.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib
includelib acllib.lib

include acllib.inc
include ui.inc
include play.inc

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
winTitle byte "Happy Game", 0


.code



main proc c
	invoke init_first  ;初始化绘图环境
	invoke initWindow, offset winTitle, 250, 30, 800, 600 ;左上角的坐标，窗体的宽高
	

	invoke registerMouseEvent,iface_mouseEvent 
	invoke registerKeyboardEvent, iface_keyboardEvent
	;invoke registerTimerEvent, iface_timerEvent
	invoke page_start
	invoke init_second

main endp
end main