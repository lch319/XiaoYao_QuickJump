#SingleInstance,off
#NoTrayIcon ;~不显示托盘图标
#Persistent ;~让脚本持久运行
#Include %A_ScriptDir%\公用函数.ahk

FileAppend,%A_ScriptHwnd%`n,%A_Temp%\后台隐藏运行脚本记录.txt
窗口标题名:="XiaoYao_快速跳转【更多子分类常用路径】"
SplitPath, A_ScriptDir,, 软件配置路径
;软件配置路径:="D:\RunAny\PortableSoft\XiaoYao_快速跳转\XiaoYao_快速跳转"

;避免重复打开
if (Single("设置更多子分类常用路径")) {  ;独一无二的字符串用于识别脚本,或者称为指纹?
    WinActivate, %窗口标题名% ahk_class AutoHotkeyGUI
    ExitApp
}
Single("设置更多子分类常用路径")

loop 5
{
    常用路径开关%A_Index%:= Var_Read("常用路径开关" A_Index,"0","基础配置",软件配置路径 "\个人配置.ini","是")
        常用路径名称%A_Index%:= Var_Read("常用路径名称" A_Index,"常用" A_Index,"基础配置",软件配置路径 "\个人配置.ini","是")
        常用路径%A_Index%:= Var_Read("","","常用路径" A_Index,软件配置路径 "\个人配置.ini","是")

}

Gui,+HwndGui_winID2
Gui, Margin, 20, 20
Gui, Font, W400, Microsoft YaHei

Gui, Add, CheckBox,Checked%常用路径开关1% v常用路径开关1 g设置常用路径1, 常用路径1[名称]:
Gui, Add, Edit, x+5 yp-2 w110 h25 v常用路径名称1 +Disabled, %常用路径名称1%
Gui, Add, Edit, xm yp+24 w400 r4 v常用路径1 +Disabled HScroll -Wrap, %常用路径1%

Gui, Add, CheckBox,Checked%常用路径开关2% v常用路径开关2 g设置常用路径2 xm+5 yp+100, 常用路径2[名称]:
Gui, Add, Edit, x+5 yp-2 w110 h25 v常用路径名称2 +Disabled, %常用路径名称2%
Gui, Add, Edit, xm yp+24 w400 r4 v常用路径2 +Disabled HScroll -Wrap, %常用路径2%

Gui, Add, CheckBox,Checked%常用路径开关3% v常用路径开关3 g设置常用路径3 xm+5 yp+100, 常用路径3[名称]:
Gui, Add, Edit, x+5 yp-2 w110 h25 v常用路径名称3 +Disabled, %常用路径名称3%
Gui, Add, Edit, xm yp+24 w400 r4 v常用路径3 +Disabled HScroll -Wrap, %常用路径3%

Gui, Add, CheckBox,Checked%常用路径开关4% v常用路径开关4 g设置常用路径4 xm+5 yp+100, 常用路径4[名称]:
Gui, Add, Edit, x+5 yp-2 w110 h25 v常用路径名称4 +Disabled, %常用路径名称4%
Gui, Add, Edit, xm yp+24 w400 r4 v常用路径4 +Disabled HScroll -Wrap, %常用路径4%

Gui, Add, CheckBox,Checked%常用路径开关5% v常用路径开关5 g设置常用路径5 xm+5 yp+100, 常用路径5[名称]:
Gui, Add, Edit, x+5 yp-2 w110 h25 v常用路径名称5 +Disabled, %常用路径名称5%
Gui, Add, Edit, xm yp+24 w400 r4 v常用路径5 +Disabled HScroll -Wrap, %常用路径5%
Gui, Add, Button, x115 y630 w80 h30 gSaveSettings HwndBtn3, 保存
Gui, Add, Button, x215 y630 w80 h30 gCancel HwndBtn4, 取消


gosub,设置常用路径1
gosub,设置常用路径2
gosub,设置常用路径3
gosub,设置常用路径4
gosub,设置常用路径5

Gui, Show, , %窗口标题名%
return
RemoveToolTip:
    ToolTip
return

设置常用路径1:
    Gui,Submit, NoHide
    if (常用路径开关1="1"){
        GuiControl, Enable, 常用路径名称1
        GuiControl, Enable, 常用路径1
    }else{
        GuiControl, Disable, 常用路径名称1
        GuiControl, Disable, 常用路径1
    }
return

设置常用路径2:
    Gui,Submit, NoHide
    if (常用路径开关2="1"){
        GuiControl, Enable, 常用路径名称2
        GuiControl, Enable, 常用路径2
    }else{
        GuiControl, Disable, 常用路径名称2
        GuiControl, Disable, 常用路径2
    }
return
设置常用路径3:
    Gui,Submit, NoHide
    if (常用路径开关3="1"){
        GuiControl, Enable, 常用路径名称3
        GuiControl, Enable, 常用路径3
    }else{
        GuiControl, Disable, 常用路径名称3
        GuiControl, Disable, 常用路径3
    }
return
设置常用路径4:
    Gui,Submit, NoHide
    if (常用路径开关4="1"){
        GuiControl, Enable, 常用路径名称4
        GuiControl, Enable, 常用路径4
    }else{
        GuiControl, Disable, 常用路径名称4
        GuiControl, Disable, 常用路径4
    }
return
设置常用路径5:
    Gui,Submit, NoHide
    if (常用路径开关5="1"){
        GuiControl, Enable, 常用路径名称5
        GuiControl, Enable, 常用路径5
    }else{
        GuiControl, Disable, 常用路径名称5
        GuiControl, Disable, 常用路径5
    }
return

SaveSettings:
Gui, Submit, NoHide

loop 5
{
    常用路径开关:= 常用路径开关%A_Index%
    常用路径名称:= 常用路径名称%A_Index%
    常用路径:= 常用路径%A_Index%
    IniWrite, %常用路径开关%, %软件配置路径%\个人配置.ini,基础配置,常用路径开关%A_Index%
    IniWrite, %常用路径名称%, %软件配置路径%\个人配置.ini,基础配置,常用路径名称%A_Index%
    IniDelete, %软件配置路径%\个人配置.ini,常用路径%A_Index%
    IniWrite, %常用路径%, %软件配置路径%\个人配置.ini,常用路径%A_Index%
}
ExitApp
return
; 取消按钮动作
Cancel:
GuiClose:
ExitApp