#SingleInstance,Force ;~运行替换旧实例
#NoTrayIcon ;~不显示托盘图标
#Persistent ;;~让脚本持久运行
SetWinDelay, -1 ;设置在每次执行窗口命令,使用 -1 表示无延时
SetBatchLines, -1   ;让操作以最快速度进行.

SplitPath, A_ScriptDir, , parentDir
global 软件安装路径:= parentDir

IniRead, 自动弹出常驻窗口, %软件安装路径%\个人配置.ini,基础配置,自动弹出常驻窗口
IniRead, 自动跳转到默认路径, %软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
IniRead, 默认路径, %软件安装路径%\个人配置.ini,基础配置,默认路径
默认路径:=ReplaceVars(默认路径)
IniRead, 历史路径设为默认路径, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径

IniRead, 常驻窗口窗口列表,%软件安装路径%\个人配置.ini,窗口列表1
if (常驻窗口窗口列表="" || 常驻窗口窗口列表="ERROR"){
    常驻窗口窗口列表:="
(
选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe
选择 ahk_class #32770 ahk_exe Bandizip.exe
解压路径和选项 ahk_class #32770 ahk_exe WinRAR.exe
选择目标文件夹 ahk_class #32770 ahk_exe dopus.exe
)"
}

IniRead, 自动弹出常驻窗口次数, %软件安装路径%\个人配置.ini,基础配置,自动弹出常驻窗口次数
if (自动弹出常驻窗口次数="" || 自动弹出常驻窗口次数="ERROR")
    自动弹出常驻窗口次数:= "0"

;MsgBox, %自动弹出常驻窗口%
if (自动弹出常驻窗口 != "开启") and (自动跳转到默认路径 != "开启")  ;如果配置文件中设置了关闭，则退出脚本
    ExitApp

OnExit, 退出时运行

;常驻窗口窗口列表:="选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe`n选择 ahk_class #32770 ahk_exe Bandizip.exe"
; 解析窗口列表到数组
windows := []
Loop, Parse, 常驻窗口窗口列表, `n, `r
{
    if not (RegExMatch(A_LoopField, "^\s*$"))  ; 跳过空行
        windows.Push(Trim(A_LoopField))
}
; 设置定时器检查窗口（每秒检查一次）
SetTitleMatchMode, 2  ; 使用部分匹配窗口标题
SetTimer, 检查窗口列表, 10

ReplaceBrowseForFolder(true)

loop
{
    WinWaitActive, ahk_class #32770
    ;sleep, 200
    if WinActive("ahk_class #32770") && not WinActive("ahk_exe IDMan.exe"){
        WinID2 := WinExist("A")

        IniRead, 自动跳转到默认路径, %软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
        IniRead, 默认路径, %软件安装路径%\个人配置.ini,基础配置,默认路径
        默认路径:=ReplaceVars(默认路径)
        IniRead, 历史路径设为默认路径, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径

        if (自动跳转到默认路径 = "开启"){

            result2 := CheckStringInFile(A_Temp "\跳转默认打开记录.txt",WinID2)
            sleep, 10
            if (result2 = "" or result2 = "FILE_ERROR"){

                if (历史路径设为默认路径 = "开启"){
                    FileRead, 全部历史跳转路径, %软件安装路径%\ICO\历史跳转.ini
                    if (全部历史跳转路径 !=""){
                        ;MsgBox, %全部历史跳转路径%
                        Loop, parse, 全部历史跳转路径, `n, `r
                        {
                            if !(RegExMatch(A_LoopField, "^\s*$")){ ;判断是否是空白行
                                默认路径 := A_LoopField
                                ;MsgBox,1 %默认路径% `n %A_LoopField%
                                Break
                            }
                        }
                    }
                }

                run,"%A_AhkPath%" "%A_ScriptDir%\常驻跟随窗口.ahk" -跳转事件 %WinID2% "%默认路径%"
                FileAppend,%WinID2%`n,%A_Temp%\跳转默认打开记录.txt

            }

        }

        if (自动弹出常驻窗口="开启"){
            ; 示例调用
            result := CheckStringInFile(A_Temp "\常驻窗口关闭记录.txt",WinID2)
            sleep, 10
            if (result != ""){
                if (result != "FILE_ERROR")
                    Continue
            }
            sleep, 100
            DialogType := SmellsLikeAFileDialog(WinID2)
            If DialogType{
                WinGetClass, WindowClass, ahk_id %WinID2%   ; 获取目标窗口的类名
                if (WindowClass = "#32770"){    ; 判断类名是否为 #32770
                    run,"%A_AhkPath%" "%A_ScriptDir%\常驻跟随窗口.ahk" -常驻窗口跟随 %WinID2%
                    自动弹出常驻窗口次数++
                    DialogType := ""
                }
            }
        }

    }
    WinWaitNotActive, ahk_class #32770
    sleep, 100
    ;Menu ContextMenu, Delete
    WinID2 := ""
    DialogType :=""
}

;-------------------------------------------
;只有在下列情况下，才将此对话框视为可能的文件对话框
SmellsLikeAFileDialog(_thisID ){
    WinGet, _controlList, ControlList, ahk_id %_thisID%
    Loop, Parse, _controlList, `n
    {
        If ( A_LoopField = "SysListView321" )
            _SysListView321 := 1
        If ( A_LoopField = "ToolbarWindow321")
            _ToolbarWindow321 := 1
        If ( A_LoopField = "DirectUIHWND1" )
            _DirectUIHWND1 := 1
        If ( A_LoopField = "Edit1" )
            _Edit1 := 1
    }
    If ( _DirectUIHWND1 and _ToolbarWindow321 and _Edit1 )
        Return "GENERAL"
    Else If ( _SysListView321 and _ToolbarWindow321 and _Edit1 )
        Return "SYSLISTVIEW"
    else
        Return FALSE
}

; 函数：检查文件中是否存在包含目标字符串的行
; 参数：
;   filePath - 文本文件路径
;   targetString - 要查找的字符串
; 返回值：
;   成功找到：返回匹配行的完整内容
;   未找到：返回空字符串 ""
;   文件读取错误：返回 "FILE_ERROR"
CheckStringInFile(filePath, targetString) {
    ; 尝试读取文件
    FileRead, fileContent, %filePath%
    ;MsgBox, %fileContent%
    if (ErrorLevel)  ; 文件读取失败
        return "FILE_ERROR"

    ; 逐行检查
    foundLine := ""
    Loop, Parse, fileContent, `n, `r  ; 处理不同换行符
    {
        if InStr(A_LoopField, targetString)
        {
            foundLine := A_LoopField
            break  ; 找到后立即退出循环
        }
    }

    return foundLine
}

ReplaceBrowseForFolder(Params*) {
    Static EVENT_OBJECT_SHOW := 0x8002
        ,      OBJID_WINDOW := 0
        ,      INDEXID_CONTAINER := 0
        ,      hHook := 0
    If IsObject(Params) {
        Return hHook := Params[1]
            ? DllCall("SetWinEventHook", "Int", EVENT_OBJECT_SHOW
            , "Int", EVENT_OBJECT_SHOW, "Ptr", 0, "Ptr"
            ,  RegisterCallback(A_ThisFunc)
            , "Int", 0, "Int", 0, "Int", 0, "Ptr")
            : DllCall("UnhookWinEvent", "Ptr", hHook), DllCall("CoUninitialize")
    } Else {
        hwnd := NumGet(params+0, 2*A_PtrSize, "Ptr")
        idObject := NumGet(params+0, 3*A_PtrSize, "Int")
        idChild := NumGet(params+0, 4*A_PtrSize, "Int")
        If (idObject != OBJID_WINDOW || idChild != INDEXID_CONTAINER)
            Return
        WinGetClass wndClass, % "ahk_id" hwnd
        If (wndClass != "#32770")
            Return
        WinGet CtlList, ControlList, % "ahk_id" hwnd
        If !(  InStr(CtlList, "SHBrowseForFolder ShellNameSpace Control")
            || CtlList = "Static1`nStatic2`nSysTreeView321`nButton1`nButton2" )
            Return
        ;If (SelectedPath := SelectFolderEx(, , hwnd))
        ;SetPathForBrowseForFolder(SelectedPath, hwnd)
        ;Else
        ;WinClose % "ahk_id" hwnd
        WinID2 := WinExist("A")
        run,"%A_AhkPath%" "%A_ScriptDir%\常驻跟随窗口.ahk" -常驻窗口跟随 %WinID2%
        自动弹出常驻窗口次数++
    }
}

;将字符串中的 %变量名% 替换为变量值----------------------------------------------------------------
ReplaceVars(str) {
    ; 创建新字符串避免修改原始数据
    result := str

    ; 使用更可靠的正则表达式匹配 %变量名%
    pos := 1
    While (pos := RegExMatch(result, "OiU)%([\w#@$]+)%", match, pos)) {
        varName := match.Value(1)  ; 提取变量名

        ; 检查是否是内置变量或全局变量
        if IsLabel(varName) || (%varName% != "") {
            varValue := %varName%  ; 获取变量值

            ; 替换匹配部分
            result := RegExReplace(result, "U)\Q" match.Value() "\E", varValue, , 1, pos)
            pos += StrLen(varValue)  ; 调整位置
        } else {
            ; 如果不是有效变量，跳过
            pos += match.Len
        }
    }

    ; 处理转义的 %% 为 %
    result := StrReplace(result, "``%``%", "``%")
    return result
}

检查窗口列表:
    for index, winTitle in windows
    {
        ; 检查窗口是否存在
        if WinActive(winTitle){
            WinID2 := WinExist(winTitle)
            IniRead, 自动跳转到默认路径, %软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
            IniRead, 默认路径, %软件安装路径%\个人配置.ini,基础配置,默认路径
            默认路径:=ReplaceVars(默认路径)
            IniRead, 历史路径设为默认路径, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径

            if (自动跳转到默认路径 = "开启"){

                result2 := CheckStringInFile(A_Temp "\跳转默认打开记录.txt",WinID2)
                sleep, 10
                if (result2 = "" or result2 = "FILE_ERROR"){
                    if (历史路径设为默认路径 = "开启"){
                        FileRead, 全部历史跳转路径, %软件安装路径%\ICO\历史跳转.ini
                        if (全部历史跳转路径 !=""){
                            ;MsgBox, %全部历史跳转路径%
                            Loop, parse, 全部历史跳转路径, `n, `r
                            {
                                if !(RegExMatch(A_LoopField, "^\s*$")){ ;判断是否是空白行
                                    默认路径 := A_LoopField
                                    ;MsgBox,1 %默认路径% `n %A_LoopField%
                                    Break
                                }
                            }
                        }
                    }

                    run,"%A_AhkPath%" "%A_ScriptDir%\常驻跟随窗口.ahk" -跳转事件 %WinID2% "%默认路径%"
                    FileAppend,%WinID2%`n,%A_Temp%\跳转默认打开记录.txt
                }

            }

            if (自动弹出常驻窗口="开启"){
                ; 示例调用
                result := CheckStringInFile(A_Temp "\常驻窗口关闭记录.txt",WinID2)
                sleep, 10
                if (result = "" or result = "FILE_ERROR"){
                    run,"%A_AhkPath%" "%A_ScriptDir%\常驻跟随窗口.ahk" -常驻窗口跟随 %WinID2%
                    自动弹出常驻窗口次数++
                }
                ;MsgBox, 0x40, 窗口出现提示, 检测到目标窗口：`n"%activeTitle%"`n`n匹配条件：`n%winTitle%
            }

            WinWaitNotActive,% winTitle
            break  ; 每次只处理一个出现的窗口
        }
    }
return

退出时运行:
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    ;如果配置不存在，新建一个默认配置
    if not FileExist(软件安装路径 "\个人配置.ini")
        FileCopy,%软件安装路径%\ICO\默认.ini, %软件安装路径%\个人配置.ini

    IniWrite, %自动弹出常驻窗口次数%, %软件安装路径%\个人配置.ini,基础配置,自动弹出常驻窗口次数
ExitApp
Return

