
.386
.model flat,stdcall
option casemap:none

include msvcrt.inc

.data

ifndef __p_v__
__p_v__ equ <>

currWindow dword 0;��ǰ�������
public currWindow

boundaryH dword 20;�߶ȣ�����
public boundaryH
boundaryW dword 10;���
public boundaryW

pos_now1 dword 0
public pos_now1

pos_now2 dword 0
public pos_now2

endif

end
