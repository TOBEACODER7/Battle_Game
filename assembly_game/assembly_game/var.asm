
.386
.model flat,stdcall
option casemap:none

include msvcrt.inc

.data

ifndef __p_v__
__p_v__ equ <>

currWindow dword 0;当前窗口类别
public currWindow

boundaryH dword 20;高度（块数
public boundaryH
boundaryW dword 10;宽度
public boundaryW

pos_now1 dword 0
public pos_now1

pos_now2 dword 0
public pos_now2

endif

end
