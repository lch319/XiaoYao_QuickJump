#SingleInstance,off
#NoTrayIcon ;~不显示托盘图标
#Persistent ;~让脚本持久运行

; 暗黑模式相关函数
Menu_Dark(d) { ; 0=Default  1=AllowDark  2=ForceDark  3=ForceLight  4=Max  
  static uxtheme := DllCall("GetModuleHandle", "str", "uxtheme", "ptr")
  static SetPreferredAppMode := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 135, "ptr")
  static FlushMenuThemes := DllCall("GetProcAddress", "ptr", uxtheme, "ptr", 136, "ptr")

  DllCall(SetPreferredAppMode, "int", d) ; 0=Default  1=AllowDark  2=ForceDark  3=ForceLight  4=Max  
  DllCall(FlushMenuThemes)
}

; 读取系统深色模式状态
IsDarkMode() {
    ; 注册表路径和值名称
    static RegPath := "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    static ValueName := "AppsUseLightTheme"
    
    ; 读取注册表值
    RegRead, AppsUseLightTheme, %RegPath%, %ValueName%
    
    ; AppsUseLightTheme = 0 表示深色模式，1 表示浅色模式
    return (AppsUseLightTheme = 0)
}

; 根据系统主题自动设置模式
global 系统深色模式状态 := IsDarkMode()
if (系统深色模式状态)
    Menu_Dark(2) ; 启用暗黑模式
else
    Menu_Dark(3) ; 启用浅色模式

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

IniRead, 默认路径, %软件配置路径%\个人配置.ini,基础配置,默认路径
if (默认路径="ERROR")
    默认路径:= ""

; 创建 GUI 窗口
;gui, +AlwaysOnTop

; 根据系统主题设置窗口背景和字体颜色
if (系统深色模式状态) {
    Gui, Color, 0x202020, 0x202020 ; 深色背景
    gui, font, s10 c0xE0E0E0 ; 浅色字体
} else {
    Gui, Color, 0xF0F0F0, 0xF0F0F0 ; 浅色背景
    gui, font, s10 c0x202020 ; 深色字体
}

Gui, Add, Text, x10 y15, 每次打开对话框时自动跳转到默认路径
Gui, Add, Edit, x10 y35 w300 HwndEditID vDefaultPath, %默认路径%  ; 初始值设为桌面路径
Gui, Add, Button, x315 y33 w80 HwndBtnBrowseFolder gBrowseFolder, 浏览...
Gui, Add, Button, x95 y70 w80 h30 HwndBtnSaveSettings gSaveSettings, 保存
Gui, Add, Button, x195 y70 w80 h30 HwndBtnCancel gCancel, 取消
Gui, Show, , %窗口标题名%

; 设置控件主题
if (系统深色模式状态) {
    ; 设置编辑框暗黑主题
    DllCall("uxtheme\SetWindowTheme", "ptr", EditID, "str", "DarkMode_Explorer", "ptr", 0)
    
    ; 设置按钮暗黑主题
    DllCall("uxtheme\SetWindowTheme", "ptr", BtnBrowseFolder, "str", "DarkMode_Explorer", "ptr", 0)
    DllCall("uxtheme\SetWindowTheme", "ptr", BtnSaveSettings, "str", "DarkMode_Explorer", "ptr", 0)
    DllCall("uxtheme\SetWindowTheme", "ptr", BtnCancel, "str", "DarkMode_Explorer", "ptr", 0)
    
    ; 设置暗黑标题栏（适用于Windows 10+）
    if (A_OSVersion >= "10.0.17763" && SubStr(A_OSVersion, 1, 3) = "10.") {
        Gui +LastFound
        hwnd := WinExist()
        attr := A_OSVersion >= "10.0.18985" ? 20 : 19
        DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "int", attr, "int*", 1, "int", 4)
    }
}
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

Single(flag) { ;,返回1为重复,返回0为第一个运行
    DllCall("CreateMutex", "Ptr",0, "int",0, "str", "Ahk_Single_" flag)
    return A_LastError=0xB7 ? true : false
}