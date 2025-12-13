#SingleInstance,off
#NoTrayIcon ;~不显示托盘图标
#Persistent ;~让脚本持久运行
#Include %A_ScriptDir%\公用函数.ahk

FileAppend,%A_ScriptHwnd%`n,%A_Temp%\后台隐藏运行脚本记录.txt
窗口标题名:="XiaoYao_快速跳转【默认路径设置】"
SplitPath, A_ScriptDir,, 软件配置路径
;软件配置路径:="D:\RunAny\PortableSoft\XiaoYao_快速跳转\XiaoYao_快速跳转"

;避免重复打开
if (Single("设置默认路径")) {  ;独一无二的字符串用于识别脚本,或者称为指纹?
    WinActivate, %窗口标题名% ahk_class AutoHotkeyGUI
    ExitApp
}
Single("设置默认路径")

默认路径:=ReplaceVars(Var_Read("默认路径","","基础配置",软件配置路径 "\个人配置.ini","是"))
深浅主题切换:=Var_Read("深浅主题切换","跟随系统","基础配置",软件配置路径 "\个人配置.ini","是")

; 创建 GUI 窗口
;Gui, Add, Text, x10 y10 w80 h20, 默认路径:
;gui, +AlwaysOnTop

;深色/浅色主题切换1【开始】---------------------------------
if (IsDarkMode() and 深浅主题切换="跟随系统") or (深浅主题切换="深色"){
    Gui, Color, 0x202020, 0x202020 ; 深色背景
    gui, font, s10 c0xE0E0E0 ; 浅色字体
}
;深色/浅色主题切换1【结束】---------------------------------

Gui,+HwndGui_winID2
gui, font, s10
Gui, Add, Text, x10 y15 , 每次打开对话框时自动跳转到默认路径
Gui, Add, Edit, x10 y35 w300 vDefaultPath HwndBtn1, %默认路径%  ; 初始值设为桌面路径
Gui, Add, Button, x315 y33 w80 gBrowseFolder HwndBtn2, 浏览...
Gui, Add, Button, x95 y70 w80 h30 gSaveSettings HwndBtn3, 保存
Gui, Add, Button, x195 y70 w80 h30 gCancel HwndBtn4, 取消

;深色/浅色主题切换2【开始】---------------------------------
if (IsDarkMode() and 深浅主题切换="跟随系统") or (深浅主题切换="深色"){
    Loop, 4
    {
        ; 根据系统主题设置标题栏颜色（适用于Windows 10+）
        if (A_OSVersion >= "10.0.17763" && SubStr(A_OSVersion, 1, 3) = "10.") {
            attr := A_OSVersion >= "10.0.18985" ? 20 : 19
            DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Gui_winID2, "int", attr, "int*", 1, "int", 4)
        }
        DllCall("uxtheme\SetWindowTheme", "ptr", Btn%A_Index%, "str", "DarkMode_Explorer", "ptr", 0)
    }

}

Gui, Show, , %窗口标题名%
return

; 浏览文件夹按钮动作
BrowseFolder:
    FileSelectFolder, SelectedFolder,, 3, 请选择默认路径
    if (SelectedFolder != "")  ; 确保用户没有取消选择
    {
        GuiControl,, DefaultPath, %SelectedFolder%
    }
return

; 保存按钮动作
SaveSettings:
    Gui, Submit, NoHide
    ; 获取输入框内容但不关闭窗口
    ; 这里可以添加保存路径的代码（如写入配置文件/注册表）
    ;MsgBox, 已保存默认路径: %DefaultPath%

    if (ErrorLevel || DefaultPath="" || !FileExist(DefaultPath)){
        ;DefaultPath:= ReplaceVars(DefaultPath)
        IniWrite, %DefaultPath%, %软件配置路径%\个人配置.ini,基础配置,默认路径
        ExitApp
        ;MsgBox, 输入错误或路径不存在！
    }Else{
        IniWrite, %DefaultPath%, %软件配置路径%\个人配置.ini,基础配置,默认路径
        ExitApp
    }
return

; 取消按钮动作
Cancel:
GuiClose:
ExitApp

RemoveToolTip:
    ToolTip
return