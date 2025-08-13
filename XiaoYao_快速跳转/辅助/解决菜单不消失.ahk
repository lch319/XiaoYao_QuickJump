#SingleInstance,Force ;~运行替换旧实例
#NoTrayIcon ;~不显示托盘图标
#Persistent ;;~让脚本持久运行
FileAppend,%A_ScriptHwnd%`n,%A_Temp%\后台隐藏运行脚本记录.txt
Loop
{
    if WinExist("ahk_class #32768 ahk_exe " A_AhkPath){
        WinGet, active_id, ID, ahk_class #32768 ahk_exe %A_AhkPath%
        KeyWait, LButton, D
        ;MsgBox, 3
        MouseGetPos,,, Win
        WinGetClass, this_class, ahk_id %Win%
        WinGet,path,ProcessPath ,ahk_id %Win%
        if not (this_class = "#32768" and path = A_AhkPath){
            WinClose,ahk_id %active_id%
            ;MsgBox, 测试
        }
    }
    Sleep, 100
}

;方法1占cpu大-----------------------------------------
/*
;MsgBox, %A_AhkPath%
SetTimer,检测窗口关闭, 10

;Return
检测窗口关闭:
    WinWait, ahk_class #32768 ahk_exe %A_AhkPath%
    WinGet, active_id, ID, ahk_class #32768 ahk_exe %A_AhkPath%

    KeyWait, LButton, D
    ;MsgBox, 3
    MouseGetPos,,, Win
    WinGetClass, this_class, ahk_id %Win%
    WinGet,path,ProcessPath ,ahk_id %Win%
    ;MsgBox, %active_id%`n%Win% `n %path%
    While  (this_class = "#32768" and path = A_AhkPath){
        KeyWait, LButton, D
        MouseGetPos,,, Win
        WinGetClass, this_class, ahk_id %Win%
        WinGet,path,ProcessPath ,ahk_id %Win%
        ;MsgBox, 1
    }
    ;Sleep, 100
    WinClose,ahk_id %active_id%
    Win:=""
    this_class:=""
    path:=""
    MsgBox, 2
Return
*/

/*
;方法2占cpu大-----------------------------------------
SetTimer,Label_ClearMEM,-1000
Loop
{
    WinWait, ahk_class #32768 ahk_exe %A_AhkPath%
    WinGet, active_id, ID, ahk_class #32768 ahk_exe %A_AhkPath%

    KeyWait, LButton, D
    ;MsgBox, 3
    MouseGetPos,,, Win
    WinGetClass, this_class, ahk_id %Win%
    WinGet,path,ProcessPath ,ahk_id %Win%
    ;MsgBox, %active_id%`n%Win% `n %path%
    While  (this_class = "#32768" and path = A_AhkPath){
        KeyWait, LButton, D
        MouseGetPos,,, Win
        WinGetClass, this_class, ahk_id %Win%
        WinGet,path,ProcessPath ,ahk_id %Win%
        ;MsgBox, 1
    }
    ;Sleep, 100
    WinClose,ahk_id %active_id%
    Win:=""
    this_class:=""
    path:=""
    ;MsgBox, 2
}
Return

Label_ClearMEM: ;清理内存
    pid:=() ? DllCall("GetCurrentProcessId") : pid
    h:=DllCall("OpenProcess", "UInt", 0x001F0FFF, "Int", 0, "Int", pid)
    DllCall("SetProcessWorkingSetSize", "UInt", h, "Int", -1, "Int", -1)
    DllCall("CloseHandle", "Int", h)
Return
*/

