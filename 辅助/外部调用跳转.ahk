#NoEnv
#SingleInstance Force   ;~运行替换旧实例
#NoTrayIcon ;~不显示托盘图标
#Include %A_ScriptDir%\公用函数.ahk
SetWinDelay, -1 ;设置在每次执行窗口命令,使用 -1 表示无延时
SetBatchLines, -1   ;让操作以最快速度进行.
SetTimer, ExitScript, -5000 ; 设置5秒后执行退出函数


global 参数1 := A_Args[1]   ;第一个参数是另存为窗口的句柄
global 参数2 := A_Args[2]   ;第二个参数是跳转目标路径
global 参数3 := A_Args[3]
global 参数4 := A_Args[4]
;MsgBox, 外部调用跳转
if not (参数1="")
    跳转方式4(参数1,参数2,参数3)
ExitApp


RemoveToolTip:
    ToolTip
return

ExitScript:
    ExitApp ; 退出脚本
return
/*

F1::
    
    SelectedPath:= "C:\Users\Administrator\Downloads"
    DialogHwnd:= WinExist("A")
    MsgBox, 1
    跳转方式4(DialogHwnd,SelectedPath)
return
*/