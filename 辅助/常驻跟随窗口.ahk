#SingleInstance Off ;~可多开脚本
;#SingleInstance,Force ;~运行替换旧实例
#NoTrayIcon ;~不显示托盘图标
#Persistent ;;~让脚本持久运行
#Include %A_ScriptDir%\公用函数.ahk

SetWinDelay, -1 ;设置在每次执行窗口命令,使用 -1 表示无延时
SetBatchLines, -1   ;让操作以最快速度进行.
SetTimer, ExitScript, -5000 ; 设置5秒后执行退出函数


;F1::
;global 参数1 := "-常驻窗口跟随"
;global 参数2 := "0x700404"
global 参数1 := A_Args[1]
global 参数2 := A_Args[2]
global 参数3 := A_Args[3]
global 参数4 := A_Args[4]

;功能一:
if (参数1="-常驻窗口跟随"){

    DetectHiddenWindows, off
    if !WinExist("ahk_id " 参数2) or (参数2="")
        ExitApp
    Else
        SetTimer,父窗口关闭运行事件, 1 ;每1毫秒检测一次父窗口是否关闭

    ;避免重复打开
    if (Single(参数2)) {  ;独一无二的字符串用于识别脚本,或者称为指纹?
        ExitApp
    }
    Single(参数2)

    global 唯一性:= 参数2 ;获取当前活动窗口的ID
    global 窗口标题名称:="常用路径跳转" 唯一性
    ;[读取用户自定义配置]-------------------------------------
    ;global 自动弹出常驻窗口:="开启"
    ;常驻搜索窗口呼出热键=^d

    ;父窗口X, 父窗口Y, 父窗口W, 父窗口H
    global 窗口初始坐标x:= "父窗口X - 10 + 父窗口W"
    global 窗口初始坐标y:= "父窗口Y + 50"

    global 窗口初始宽度:= "240"
    global 窗口初始高度:= "360"

    global 窗口背景颜色:=""
    global 窗口字体颜色:=""
    global 窗口字体名称:="WenQuanYi Micro Hei"
    global 窗口字体大小:="12"
    global 窗口透明度:="225"

    global 文件夹名显示在前:="关闭"
    ;[读取软件自己的配置]------------------------------------------------
    global 跳转方式:="1"
    global 历史跳转保留数:="5"
    global DO的收藏夹:="开启"

    ;global 软件安装路径:="D:\RunAny\PortableSoft\XiaoYao_快速跳转"
    SplitPath, A_ScriptDir, , parentDir
    ;SplitPath, parentDir, , parentDir2
    global 软件安装路径:= parentDir
    ;MsgBox, %软件安装路径%

    if FileExist(软件安装路径 "\个人配置.ini"){
        IniRead, 自定义常用路径2, %软件安装路径%\个人配置.ini,常用路径
        自定义常用路径:=ReplaceVars(自定义常用路径2)

        IniRead, DO的收藏夹, %软件安装路径%\个人配置.ini,基础配置,DO的收藏夹

        IniRead, 跳转方式, %软件安装路径%\个人配置.ini,基础配置,跳转方式

        IniRead, 历史跳转保留数, %软件安装路径%\个人配置.ini,基础配置,历史跳转保留数

        IniRead, 窗口初始坐标x, %软件安装路径%\个人配置.ini,基础配置,窗口初始坐标x
        IniRead, 窗口初始坐标y, %软件安装路径%\个人配置.ini,基础配置,窗口初始坐标y
        IniRead, 窗口初始宽度, %软件安装路径%\个人配置.ini,基础配置,窗口初始宽度
        IniRead, 窗口初始高度, %软件安装路径%\个人配置.ini,基础配置,窗口初始高度
        IniRead, 窗口背景颜色, %软件安装路径%\个人配置.ini,基础配置,窗口背景颜色
        IniRead, 窗口字体颜色, %软件安装路径%\个人配置.ini,基础配置,窗口字体颜色
        IniRead, 窗口字体名称, %软件安装路径%\个人配置.ini,基础配置,窗口字体名称
        IniRead, 窗口字体大小, %软件安装路径%\个人配置.ini,基础配置,窗口字体大小
        IniRead, 窗口透明度, %软件安装路径%\个人配置.ini,基础配置,窗口透明度
        IniRead, 文件夹名显示在前, %软件安装路径%\个人配置.ini,基础配置,文件夹名显示在前
        IniRead, 全局性菜单项功能, %软件安装路径%\个人配置.ini,基础配置,全局性菜单项功能
        IniRead, 初始文本框内容, %软件安装路径%\个人配置.ini,基础配置,初始文本框内容

        IniRead, 窗口文本行距, %软件安装路径%\个人配置.ini,基础配置,窗口文本行距
        if (窗口文本行距="" || 窗口文本行距="ERROR")
            窗口文本行距:= "20"

    }
    ;-------------------------------------------------------------------
    gosub,将所有内容路径加入到数组2
    gosub,将所有内容路径加入到数组

    if (初始文本框内容="常用路径"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(自定义常用路径))
    }Else if (初始文本框内容="历史打开"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(历史所有路径))
    }Else if (初始文本框内容="全部路径"){
        global 文本框内容写入:= 换行符转换为竖杠(Trim(移除空白行(合并所有路径),"`n"))
    }Else if (初始文本框内容="do收藏夹"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(获取到的do收藏夹路径))
    }Else{
        global 文本框内容写入:= 换行符转换为竖杠(RemoveDuplicateLines(移除空白行(Trim(资管所有路径 "`n" do所有路径 "`n" tc所有路径 "`n" xy所有路径 "`n" qdir所有路径,"`n"))))
        if (文本框内容写入="")
            global 文本框内容写入:= 换行符转换为竖杠(移除空白行(自定义常用路径))
    }
    gosub,显示常驻搜索窗口
    gosub,跟随当前窗口
    Return
}
if (参数1="-跳转事件"){
    global 跳转方式:="1"
    SplitPath, A_ScriptDir, , parentDir
    global 软件安装路径:= parentDir

    if FileExist(软件安装路径 "\个人配置.ini"){
        IniRead, 跳转方式, %软件安装路径%\个人配置.ini,基础配置,跳转方式
    }
    另存为窗口id值:= 参数2
    跳转目标路径:= 参数3

    gosub,读取配置跳转方式
    ExitApp
}
;没有参数则关闭脚本
ExitApp
Return
;[显示窗口]-------------------------------------
显示常驻搜索窗口:

    if WinExist(窗口标题名称 " ahk_class AutoHotkeyGUI"){
        ;MsgBox, 已存在常驻搜索窗口,请先关闭后再打开
        ExitApp
        Return
    }
    Gui,searchbox:Destroy
    global Gui_winID
    ;Gui,searchbox: +Resize +AlwaysOnTop +ToolWindow +HwndGui_winID
    Gui,searchbox: +Resize +AlwaysOnTop +ToolWindow +E0x08000000 +HwndGui_winID
    ;Clipboard:= Gui_winID
    FileAppend,%Gui_winID%`n,%A_Temp%\后台隐藏运行脚本记录.txt

    Gui,searchbox: Color,%窗口背景颜色%,%窗口背景颜色%
    Gui,searchbox: Font,c%窗口字体颜色%,%窗口字体名称%

    Gui,searchbox: Add, Button,x-2 y0 g当前打开,当前
    Gui,searchbox: Add, Button,x+0 y0 g常用路径,常用
    Gui,searchbox: Add, Button,x+0 y0 g历史打开,历史
    Gui,searchbox: Add, Button,x+0 y0 g全部目录路径,全部

    if (DO的收藏夹="开启")
        Gui,searchbox: Add, Button,x+0 y0 gdo收藏夹,dopus

    Gui,searchbox: Add, Button,x+0 y0 g直接复制粘贴,粘贴
    Gui,searchbox: Add, Button,x+0 y0 g更多功能设置,更多

    Gui,searchbox: Font,s%窗口字体大小%
    Gui,searchbox: Add, Edit, w200 x-2 y24 Hwnd搜索框ID v搜索框输入值, % ""
    EM_SETCUEBANNER(搜索框ID, "输入框")

    Gui,searchbox: Add, ListBox, w200 x-2 y+6 Hwnd文本框ID g文本框选择后执行的操作 v文本框选择值1, % ""
    ; 设置行高为  像素
    SendMessage, 0x01A0, 0, 窗口文本行距, , ahk_id %文本框ID%  ; LB_SETITEMHEIGHT

    Gui searchbox:+LastFound ; 让 GUI 窗口成为上次找到的窗口以用于下一行的命令.

    文本框内容写入 := Trim(文本框内容写入,"|")
    GuiControl, , % 文本框ID, % "|" 文本框内容写入
    GuiControl, Choose, % 文本框ID, 1

    窗口初始坐标x:= Calculate(字符坐标替换(窗口初始坐标x))
    窗口初始坐标y:= Calculate(字符坐标替换(窗口初始坐标y))
    窗口初始宽度:= Calculate(字符坐标替换(窗口初始宽度))
    窗口初始高度:= Calculate(字符坐标替换(窗口初始高度))

    ;如果是0,0则显示在鼠标位置
    if (窗口初始坐标x="0" and 窗口初始坐标y="0"){
        CoordMode, Mouse, Screen
        MouseGetPos, 鼠标位置X, 鼠标位置Y
        窗口初始坐标x:=鼠标位置X
        窗口初始坐标y:=鼠标位置Y
    }

    ;坐标保护防止显示在屏幕外面
    if  (A_ScreenWidth < (窗口初始坐标x + 窗口初始宽度))
        窗口初始坐标x:= A_ScreenWidth - 窗口初始宽度
    if  (A_ScreenHeight < (窗口初始坐标y + 窗口初始高度))
        窗口初始坐标y:= A_ScreenHeight - 窗口初始高度

    Gui,searchbox: Show,NoActivate h%窗口初始高度% w%窗口初始宽度% X%窗口初始坐标x% Y%窗口初始坐标y%,%窗口标题名称%
    SetTimer, ExitScript, Off   ;关闭5秒后的退出操作
    WinSet, Transparent,%窗口透明度%,%窗口标题名称% ahk_class AutoHotkeyGUI
    Sleep, 20
    ControlFocus,Edit1,%窗口标题名称% ahk_class AutoHotkeyGUI
    OnMessage(0x0101, "searchbox")
Return

;[跟随当前窗口]-------------------------------------
跟随当前窗口:
    global menu:= "searchbox"
    global MinMax变量:="最小化"
    global 是否是第一次激活切换:="是"
    global 是否是第一次非激活切换:="是"
    global 是否是第一次最大化切换:="是"
    global 是否是第一次最小化切换:="是"
    global 是否是第一次中化切换:="是"
    global 是否是第一次置顶:="是"
    global Gs_tcWinID := 参数2  ; 获取当前活动窗口的ID
    global newX2:="",newY2:=""
    if (Gs_tcWinID=Gui_winID ) or (WinActive("ahk_class Progman")){
        MsgBox, 跟随失败！`n请先点击并激活要跟随的窗口
        Return
    }

    SetTimer, FollowParentWindow, 1  ; 每1毫秒检测一次
Return

;[允许gui窗口调整大小]----------------------------------
searchboxGuiSize:
    GuiControl, Move, 文本框选择值1, % "H" . (A_GuiHeight - 46) . " W" . (A_GuiWidth +5)
    GuiControl, Move, 搜索框输入值, % "W" . (A_GuiWidth +5)
Return
;[gui窗口关闭事件]----------------------------------
searchboxGuiClose:
    FileAppend,%唯一性%`n,%A_Temp%\常驻窗口关闭记录.txt

    SetTimer, FollowParentWindow, Off  ; 停止跟随父窗口
    Gui,searchbox: Destroy
ExitApp
Return
;[窗口各个按钮功能直达]-------------------------------------
当前打开:
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(RemoveDuplicateLines(移除空白行(Trim(资管所有路径 "`n" do所有路径 "`n" tc所有路径 "`n" xy所有路径 "`n" qdir所有路径,"`n"))))
    GuiControl, , % 文本框ID, % "|" 实时Text
    GuiControl, Choose, % 文本框ID, 1
Return
常用路径:
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(自定义常用路径))
    GuiControl, , % 文本框ID, % "|" 实时Text
    GuiControl, Choose, % 文本框ID, 1
Return
历史打开:
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(历史所有路径))
    GuiControl, , % 文本框ID, % "|" 实时Text
    GuiControl, Choose, % 文本框ID, 1
Return
全部目录路径:
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(Trim(移除空白行(合并所有路径),"`n"))
    GuiControl, , % 文本框ID, % "|" 实时Text
    GuiControl, Choose, % 文本框ID, 1
Return
do收藏夹:
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(获取到的do收藏夹路径))
    GuiControl, , % 文本框ID, % "|" 实时Text
    GuiControl, Choose, % 文本框ID, 1
Return
直接复制粘贴:
    Gui searchbox: Submit, NoHide
    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")
    Clipboard:=文本框选择值1
    SendInput, ^v
    ttip("已复制并粘贴到当前文本框:`n"文本框选择值1,3000)
    写入文本到(文本框选择值1,软件安装路径 "\ICO\历史跳转.ini",历史跳转保留数)
Return
更多设置:
Return

文本框选择后执行的操作:
    if (A_GuiEvent = "DoubleClick"){
        Gosub, 打开跳转事件
    }
Return

复制到剪切板:
    Gui searchbox: Submit, NoHide
    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")
    Clipboard:=文本框选择值1
    ttip("已复制: "文本框选择值1,3000)
Return

打开路径:
    Gui searchbox: Submit, NoHide
    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")
    Run, % 文本框选择值1

Return

添加到常用:
    IniRead, 自定义常用路径, %软件安装路径%\个人配置.ini,常用路径
    Gui searchbox: Submit, NoHide

    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")

    自定义常用路径:=Trim(RemoveDuplicateLines(自定义常用路径 "`n" 文本框选择值1),"`n") ;移除重复内容
    IniDelete, %软件安装路径%\个人配置.ini,常用路径
    IniWrite, %自定义常用路径%, %软件安装路径%\个人配置.ini,常用路径
    所有路径合集.Insert(文本框选择值1)
Return

从常用中移除:
    IniRead, 自定义常用路径, %软件安装路径%\个人配置.ini,常用路径
    Gui searchbox: Submit, NoHide
    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")

    自定义常用路径 := Trim(RemoveDuplicateLines(DeleteMatchingLines(自定义常用路径, 文本框选择值1)),"`n")
    IniDelete, %软件安装路径%\个人配置.ini,常用路径
    IniWrite, %自定义常用路径%, %软件安装路径%\个人配置.ini,常用路径
Return

更多功能设置:

    IniRead, 自动跳转到默认路径,%软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
    if (自动跳转到默认路径="" || 自动跳转到默认路径="ERROR")
        自动跳转到默认路径:= "关闭"
    IniRead, 历史路径设为默认路径, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径
    if (历史路径设为默认路径="" || 历史路径设为默认路径="ERROR")
        历史路径设为默认路径:= "关闭"

    IniRead, 默认路径, %软件安装路径%\个人配置.ini,基础配置,默认路径
    if (默认路径="ERROR")
        默认路径:= ""
    默认路径:=ReplaceVars(默认路径)

    if (自动跳转到默认路径="关闭")
        Menu, searchbox, Add, 开启 自动跳默认路径, 开启自动跳默认路径
    if (自动跳转到默认路径="开启"){
        Menu, searchbox, Add, 自动跳默认路径, 关闭自动跳默认路径
        Menu, searchbox, Icon, 自动跳默认路径, shell32.dll, 145
    }

    if (历史路径设为默认路径="关闭"){
        Menu, searchbox, Add, 开启 历史路径设为默认, 开启历史路径设为默认
        if (自动跳转到默认路径="关闭")
            Menu, searchbox, Disable, 开启 历史路径设为默认
    }
    if (历史路径设为默认路径="开启"){
        Menu, searchbox, Add, 历史路径设为默认, 关闭历史路径设为默认
        Menu, searchbox, Icon, 历史路径设为默认, shell32.dll, 145
        if (自动跳转到默认路径="关闭")
            Menu, searchbox, Disable, 历史路径设为默认
    }

    Menu, searchbox, Add, 设置 默认路径, 设置默认路径
    Menu, searchbox, Add, 查看 当前自动跳转路径, 查看默认路径
    if (自动跳转到默认路径="关闭") or (自动跳转到默认路径="开启" and 历史路径设为默认路径="开启"){
        Menu, searchbox, Disable, 设置 默认路径
        Menu, searchbox, Disable, 查看 当前自动跳转路径
    }
    /*
        Menu, searchbox, Add, 查看 当前自动跳转路径, 查看默认路径
        if (自动跳转到默认路径="关闭")
            Menu, searchbox, Disable, 查看 当前自动跳转路径
    */

    Menu, searchbox, Add
    Menu, searchbox, Add, 设置(&D), 设置可视化
    Menu, searchbox, Add, 重启(&R), Menu_Reload
    Menu, searchbox, Add, 退出(&E), Menu_Exit
    Menu, searchbox, Show
    Menu, searchbox, DeleteAll
Return

设置可视化:
    run,"%A_AhkPath%" "%A_ScriptDir%\用户设置GUI.ahk"
Return
Menu_Reload:
    Critical
    FileDelete, %A_Temp%\常驻窗口关闭记录.txt
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    SplitPath, A_ScriptDir,, 软件配置路径
    run,"%软件配置路径%\XiaoYao_快速跳转.exe" "%软件配置路径%\主程序.ahk"
ExitApp
return

Menu_Exit:
    FileDelete, %A_Temp%\常驻窗口关闭记录.txt
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    run,%comSpec% /c taskkill /f /im XiaoYao_快速跳转.exe,,Hide
ExitApp
return

;[菜单项打开事件]-------------------------------------
打开跳转事件:
    Gui,searchbox: Show,NoActivate
    Gui searchbox: Submit, NoHide
    ;MsgBox, 点击了%文本框选择值1%
    文本框选择值1:=RegExReplace(文本框选择值1, "^\<(.*?)\>")

    if (参数3="全局版"){ ;如果是全局版
        ;MsgBox, %全局性菜单项功能%
        if (全局性菜单项功能="直接打开"){
            Run, % 文本框选择值1
        }Else{
            Clipboard:=文本框选择值1
            ttip("已复制: "文本框选择值1,3000)
        }
        Return
    }
    跳转目标路径:=文本框选择值1
    另存为窗口id值:= 参数2 ;获取当前活动窗口的ID
    gosub 读取配置跳转方式

    if FileExist(跳转目标路径){
        写入文本到(跳转目标路径,软件安装路径 "\ICO\历史跳转.ini",历史跳转保留数)
    }
Return

读取配置跳转方式:

    if not FileExist(跳转目标路径){
        ttip("路径不存在: "跳转目标路径,3000)
        Return
    }
    ;MsgBox, 跳转目标路径: %跳转目标路径%`n另存为窗口id值: %另存为窗口id值%`n跳转方式: %跳转方式%

    WinGet CtlList, ControlList, ahk_id %另存为窗口id值%
    ControlGet, hctl222, Hwnd,, SysTreeView321, ahk_id %另存为窗口id值%
    ControlGet, hctl333, Hwnd,, Edit1, ahk_id %另存为窗口id值%

    if (跳转方式="2"){

        If (InStr(CtlList, "SHBrowseForFolder ShellNameSpace Control")
            || CtlList = "Static1`nStatic2`nSysTreeView321`nButton1`nButton2"){    ;如果是旧式对话框
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%"
        }Else if not(hctl333) {  ;如果没有Edit1控件
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%"
        }else{
            $DialogType := SmellsLikeAFileDialog(另存为窗口id值)
            FeedDialog%$DialogType%(另存为窗口id值, 跳转目标路径)
        }

    }else if (跳转方式="3")
        run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%" 是
    else if (跳转方式="4"){

        $DialogType := SmellsLikeAFileDialog(另存为窗口id值)
        If $DialogType      ;如果是新式对话框
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%" 是
        else
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%"

    }else if (跳转方式="5")
        跳转方式2(另存为窗口id值, 跳转目标路径)
    ;else if (跳转方式="6")
    ;跳转方式3(另存为窗口id值, 跳转目标路径)
    Else{   ;智能跳转方式

        ;if (InStr(CtlList, "DirectUIHWND2") ){   ;如果是新式对话框
        $DialogType := SmellsLikeAFileDialog(另存为窗口id值)
        If $DialogType{    ;如果是新式对话框
            FeedDialog%$DialogType%(另存为窗口id值, 跳转目标路径)
        }Else
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%"

    }
Return

父窗口关闭运行事件:
    if !WinExist("ahk_id " 参数2)  ; 如果父窗口已关闭
    {
        Gui, searchbox: Destroy
        SetTimer, FollowParentWindow, Off
        SetTimer, 父窗口关闭运行事件, Off
        ExitApp
        return
    }
Return
;[搜索框内容定位和右键菜单]-------------------------------------
#If MouseIsOver(%窗口标题名称% " ahk_class AutoHotkeyGUI") ;当前鼠标所指的窗口
    ~LButton::
        MouseGetPos, , ,,OutputVarControl
        if (OutputVarControl="Edit1"){
            ;WinGet, activeWindow22, ID, A
            WinActivate,ahk_id %Gui_winID%
        }
    return

    RButton::
        Critical
        KeyWait, RButton
        KeyWait, RButton, D T0.1
        if (ErrorLevel=1){
            MouseGetPos, , ,,OutputVarControl2
            if (OutputVarControl2="ListBox1"){

                Menu, searchbox2, Add, 复制到剪切板, 复制到剪切板
                Menu, searchbox2, Add, 直接复制粘贴,直接复制粘贴
                Menu, searchbox2, Add, 打开路径, 打开路径

                IniRead, 自动跳转到默认路径,%软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
                if (自动跳转到默认路径="" || 自动跳转到默认路径="ERROR")
                    自动跳转到默认路径:= "关闭"
                IniRead, 历史路径设为默认路径, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径
                if (历史路径设为默认路径="" || 历史路径设为默认路径="ERROR")
                    历史路径设为默认路径:= "关闭"

                Menu, searchbox2, Add, 设为默认路径, 选中项设为默认路径
                if (自动跳转到默认路径="关闭") or (自动跳转到默认路径="开启" and 历史路径设为默认路径="开启")
                    Menu, searchbox2, Disable, 设为默认路径
                Else
                    Menu, searchbox2, Enable, 设为默认路径

                Menu, searchbox2, Add, 添加到常用, 添加到常用
                Menu, searchbox2, Add, 从常用中移除, 从常用中移除
                Menu, searchbox2, Show
                ;

            }
        }
        Critical, Off
    return
#If
return

;[跟随父窗口移动]═════════════════════════════════════════════════
;需要传递的全局变量
;global menu:= "窗口menu名"
;global MinMax变量:="最小化"
;global 是否是第一次激活切换:="是"
;global 是否是第一次非激活切换:="是"
;global 是否是第一次最大化切换:="是"
;global 是否是第一次最小化切换:="是"
;global 是否是第一次中化切换:="是"
;global 是否是第一次置顶:="是"
;global Gs_tcWinID := Gs_tcWinID2  ; 父窗口ID
;global newX2:="",newY2:=""

FollowParentWindow:
    menu名:= menu
    if !WinExist("ahk_id " Gs_tcWinID)  ; 如果父窗口已关闭
    {
        Gui, %menu名%: Destroy
        SetTimer, FollowParentWindow, Off
        ExitApp
        return
    }
    ;判断窗口激活与未激活的切换..........................................
    if WinActive("ahk_id " Gs_tcWinID){
        if (是否是第一次激活切换="是"){
            ;MsgBox, 1
            是否是第一次激活切换:="否"
            是否是第一次非激活切换:="是"
            Gui,%menu名%:+AlwaysOnTop
        }
        WinGet, ExStyle, ExStyle, ahk_id %Gs_tcWinID% ; 检查窗口是否已经置顶
        if (ExStyle & 0x8)
            Gui,%menu名%:+AlwaysOnTop
    }Else{
        if (是否是第一次非激活切换="是"){
            ;MsgBox, 2
            是否是第一次激活切换:="是"
            是否是第一次非激活切换:="否"
            WinGet, ExStyle, ExStyle, ahk_id %Gs_tcWinID% ; 检查窗口是否已经置顶
            if (ExStyle & 0x8){ ; 如果窗口已经置顶
                Gui,%menu名%:+AlwaysOnTop
            }Else{
                Gui,%menu名%:-AlwaysOnTop
                ;MsgBox, 4
            }
        }
    }
    ;.....................................................................
    WinGet, active_MinMax, MinMax, ahk_id %Gs_tcWinID%
    WinGetPos, newX, newY, newW, newH, ahk_id %Gs_tcWinID%

    ;判断最大化到最小化的切换..........................................

    if (active_MinMax="-1"){
        if (是否是第一次最小化切换="是"){
            是否是第一次最大化切换:="是"
            是否是第一次最小化切换:="否"
            是否是第一次中化切换:="是"
            ;WinGetPos, guiX3, guiY3, guiW3, guiH3, ahk_id %Gui_winID%
            Gui,%menu名%:hide
            ;print("最小化" guiX3 "`n" guiY3)
        }
        Return
    }Else if (active_MinMax="1"){
        if (是否是第一次最大化切换="是"){
            是否是第一次最大化切换:="否"
            是否是第一次最小化切换:="是"
            是否是第一次中化切换:="是"
            ;MsgBox, 2
            Gui,%menu名%:Show,NoActivate
            ;WinMove, ahk_id %Gui_winID%,, %guiX3%, %guiY3%
            Gui,%menu名%:+AlwaysOnTop
            WinActivate, ahk_id %Gs_tcWinID%
            ;print("最大化" guiX3 "`n" guiY3)
        } ;Else
        ;Gui,%menu名%:+AlwaysOnTop
        Return
    }Else{
        if (是否是第一次中化切换="是"){
            是否是第一次最大化切换:="是"
            是否是第一次最小化切换:="是"
            是否是第一次中化切换:="否"
            ;MsgBox, 2
            Gui,%menu名%:Show,NoActivate
            ;WinMove, ahk_id %Gui_winID%,, %guiX3%, %guiY3%
            Gui,%menu名%:+AlwaysOnTop
            WinActivate, ahk_id %Gs_tcWinID%
            ;print("中化" guiX3 "`n" guiY3)
        }
    }

    ;..........................................
    if (newX = newX2 && newY = newY2)
        Return

    gX := newX2 - newX
    gY := newY2 - newY
    ;MsgBox, %newX%`n%newX2%`n%newY%`n%newY2%
    WinGetPos, guiX, guiY, guiW, guiH, ahk_id %Gui_winID%
    guiX2:= guiX - gX
    guiY2:= guiY - gY
    WinMove, ahk_id %Gui_winID%,, %guiX2%, %guiY2%
    ;MsgBox, %newX%`n%newX2%`n%newY%`n%newY2%`n

    global newX2:=newX
    global newY2:=newY
return

;[将所有内容路径加入到数组]═════════════════════════════════════════════════
将所有内容路径加入到数组:

    资管所有路径:=""
    do所有路径:=""
    tc所有路径:=""
    xy所有路径:=""
    qdir所有路径:=""

    global 历史所有路径:= HistoryOpenPath(软件安装路径)

    DetectHiddenWindows,Off
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass")
        资管所有路径:=Explorer_Path() "`n" Explorer_Path全部()

    if WinExist("ahk_exe dopus.exe")
        do所有路径:=Trim(DirectoryOpus_path("Clipboard SET {sourcepath}"),"\") "`n" DirectoryOpusgetinfo()

    if WinExist("ahk_class TTOTAL_CMD")
        tc所有路径:= TotalCommander_path("1") "`n" TotalCommander_path("2")

    xy所有路径:=XYplorer_Path()
    qdir所有路径:=Q_Dir_Path()

    IniRead, 自定义常用路径2, %软件安装路径%\个人配置.ini,常用路径
    自定义常用路径:=ReplaceVars(自定义常用路径2)
    常用所有路径:= 自定义常用路径

    if (文件夹名显示在前="开启"){
        资管所有路径 := 给行首加文件名(资管所有路径)
        do所有路径 := 给行首加文件名(do所有路径)
        tc所有路径 := 给行首加文件名(tc所有路径)
        自定义常用路径 := 给行首加文件名(自定义常用路径)
        xy所有路径 := 给行首加文件名(xy所有路径)
        qdir所有路径 := 给行首加文件名(qdir所有路径)
        历史所有路径 := 给行首加文件名(历史所有路径)
    }
return

将所有内容路径加入到数组2:

    global 获取到的do收藏夹路径:=""
    if (DO的收藏夹="开启")
        获取到的do收藏夹路径:=DirectoryOpusgetfa()

    if (文件夹名显示在前="开启"){
        获取到的do收藏夹路径 := 给行首加文件名(获取到的do收藏夹路径)
    }

    合并所有路径:= Trim(资管所有路径, "`n") "`n" Trim(do所有路径, "`n") "`n" Trim(tc所有路径, "`n") "`n" Trim(获取到的do收藏夹路径, "`n") "`n" Trim(常用所有路径, "`n") "`n" Trim(历史所有路径, "`n") "`n" Trim(xy所有路径, "`n") "`n" Trim(qdir所有路径, "`n")
    合并所有路径:=RemoveDuplicateLines(合并所有路径)    ;移除重复内容

    global 所有路径合集:= []
    ;MsgBox, %合并所有路径%
    Loop, Parse, 合并所有路径, `n, `r
    {
        所有路径合集.Insert(A_LoopField)
    }
return

开启自动跳默认路径:
    IniWrite, 开启, %软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
    if (默认路径="" || 默认路径="ERROR" || !FileExist(默认路径)){
        gosub,设置默认路径
    }

return
关闭自动跳默认路径:
    IniWrite, 关闭, %软件安装路径%\个人配置.ini,基础配置,自动跳转到默认路径
return
开启历史路径设为默认:
    IniWrite, 开启, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径
return
关闭历史路径设为默认:
    IniWrite, 关闭, %软件安装路径%\个人配置.ini,基础配置,历史路径设为默认路径
return
查看默认路径:
    ttip("当前默认路径: " 默认路径, 3000)
return

设置默认路径:
    run,"%A_AhkPath%" "%A_ScriptDir%\设置默认路径.ahk"
return

选中项设为默认路径:
    ;MsgBox, 1
    Gui searchbox: Submit, NoHide
    默认路径222:=RegExReplace(文本框选择值1, "^\<(.*?)\>")
    IniWrite, %默认路径222%, %软件安装路径%\个人配置.ini,基础配置,默认路径

    ttip("当前默认路径: " 默认路径222, 3000)
return
;========================================================================================================================================
;========================================================================================================================================
;[需要用到的函数]-------------------------------------------------

;设置Edit控件默认提示文本
EM_SETCUEBANNER(handle, string, hideonfocus := true){
    static EM_SETCUEBANNER := 0x1501
    return DllCall("user32\SendMessage", "ptr", handle, "uint", EM_SETCUEBANNER, "int", hideonfocus, "str", string, "int")
}

;搜索框搜索内容
searchbox(W, L, M, H)
{
    global 搜索框ID,文本框ID,所有路径合集,文本框内容写入
    Static LastText := ""
    If (H = 搜索框ID)
    {
        GuiControlGet, value, , % 搜索框ID
        ;MsgBox, %value%
        If (value And value!=LastText)
        {
            Text := ""
            for index, ele in 所有路径合集
                if (InStr(ele,value))
                    Text .= (Text ? "|" ele : ele)
            GuiControl, , % 文本框ID, % "|" Text
        }
        Else If (!value)
            GuiControl, , % 文本框ID, % "|" 文本框内容写入
        LastText := value
    }
}

RemoveToolTip:
    ToolTip
return

;字符坐标替换------------------------------------------------------------------------------
字符坐标替换(str){
    global 唯一性
    WinGetPos, 父窗口X, 父窗口Y, 父窗口W, 父窗口H, ahk_id %唯一性%
    CoordMode, Mouse, Screen
    MouseGetPos, 鼠标位置X, 鼠标位置Y

    str := StrReplace(str, "鼠标位置X", 鼠标位置X)
    str := StrReplace(str, "鼠标位置Y", 鼠标位置Y)

    str := StrReplace(str, "父窗口X", 父窗口X)
    str := StrReplace(str, "父窗口Y", 父窗口Y)
    str := StrReplace(str, "父窗口W", 父窗口W)
    str := StrReplace(str, "父窗口H", 父窗口H)
    Return str
}

ExitScript:
    ExitApp ; 退出脚本
return