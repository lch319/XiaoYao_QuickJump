#SingleInstance Off ;~可多开脚本
;#SingleInstance,Force ;~运行替换旧实例
#NoTrayIcon ;~不显示托盘图标
#Persistent ;;~让脚本持久运行
#Include %A_ScriptDir%\公用函数.ahk

;================ 界面风格分发（经典 / 现代共存）================
; 配置：个人配置.ini → 基础配置 → 界面风格 = 经典 | 现代
; 经典：本文件原样运行；现代：把参数原封不动转交给 常驻跟随窗口_现代.ahk
; 守卫：只有本文件（经典入口）才允许分发，避免现代脚本被误复制本段后无限自我重启
_风格参数1 := A_Args[1]

if (A_ScriptName = "常驻跟随窗口.ahk" and _风格参数1 = "-常驻窗口跟随"){
    SplitPath, A_ScriptDir, , _配置目录
    ; 默认界面风格 = 现代（新装 / ini 里缺这一项时走现代）
    IniRead, _界面风格, %_配置目录%\个人配置.ini, 基础配置, 界面风格, 现代
    _现代脚本 := A_ScriptDir "\常驻跟随窗口_现代.ahk"
    if (_界面风格 = "现代" and FileExist(_现代脚本)){
        ; 显式构造命令行：跳过空参数，给含空格的参数加引号
        _命令行 := """" A_AhkPath """ """ _现代脚本 """"
        Loop, 4
        {
            _参数值 := A_Args[A_Index]
            if (_参数值 = "")
                Continue
            if InStr(_参数值, " ")
                _命令行 .= " """ _参数值 """"
            Else
                _命令行 .= " " _参数值
        }
        Run, %_命令行%
        ExitApp
    }
}
;===============================================================

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

;【新增】常用路径变更广播：某个常驻窗口移除/添加常用后，通知其它常驻窗口即时刷新
global 常用变更消息 := DllCall("user32\RegisterWindowMessage", "Str", "XiaoYao_QuickJump_FavChanged", "UInt")
if (常用变更消息)
    OnMessage(常用变更消息, "收到常用变更通知")

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
    global 自动按修改时间排序:="关闭"
    global 修改时间排序方向:="降序"

    ;global 软件安装路径:="D:\RunAny\PortableSoft\XiaoYao_快速跳转"
    SplitPath, A_ScriptDir, , parentDir
    ;SplitPath, parentDir, , parentDir2
    global 软件安装路径:= parentDir
    ;MsgBox, %软件安装路径%
    if not FileExist(软件安装路径 "\个人配置.ini")
        FileCopy,%软件安装路径%\ICO\默认.ini, %软件安装路径%\个人配置.ini

    if FileExist(软件安装路径 "\个人配置.ini"){
        ;自定义常用路径2:=ReplaceVars(Var_Read("","","常用路径",软件安装路径 "\个人配置.ini","是"))
        替换双斜杠单反斜杠双引号:=Var_Read("替换双斜杠单反斜杠双引号","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
        DO的收藏夹:=Var_Read("DO的收藏夹","开启","基础配置",软件安装路径 "\个人配置.ini","是")
        跳转方式:=Var_Read("跳转方式","1","基础配置",软件安装路径 "\个人配置.ini","是")
        历史跳转保留数:=Var_Read("历史跳转保留数","5","基础配置",软件安装路径 "\个人配置.ini","是")
        自动按修改时间排序:=Var_Read("自动按修改时间排序","关闭","基础配置",软件安装路径 "\个人配置.ini","否")
        修改时间排序方向:=Var_Read("修改时间排序方向","降序","基础配置",软件安装路径 "\个人配置.ini","否")
        自动弹出常驻窗口:=Var_Read("自动弹出常驻窗口","开启","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口初始坐标x:=Var_Read("窗口初始坐标x","父窗口X + 父窗口W","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口初始坐标y:=Var_Read("窗口初始坐标y","父窗口Y + 20","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口初始宽度:=Var_Read("窗口初始宽度","300","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口初始高度:=Var_Read("窗口初始高度","360","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口背景颜色:=Var_Read("窗口背景颜色","","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口字体颜色:=Var_Read("窗口字体颜色","","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口字体名称:=Var_Read("窗口字体名称","","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口字体大小:=Var_Read("窗口字体大小","9","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口透明度:=Var_Read("窗口透明度","225","基础配置",软件安装路径 "\个人配置.ini","是")
        global 文件夹名显示在前:=Var_Read("文件夹名显示在前","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
        全局性菜单项功能:=Var_Read("全局性菜单项功能","复制到剪切板","基础配置",软件安装路径 "\个人配置.ini","是")
        初始文本框内容:=Var_Read("初始文本框内容","当前打开","基础配置",软件安装路径 "\个人配置.ini","是")
        失效路径显示设置:=Var_Read("失效路径显示设置","开启","基础配置",软件安装路径 "\个人配置.ini","是")
        给dc发送热键:=Var_Read("给dc发送热键","^+{F12}","基础配置",软件安装路径 "\个人配置.ini","是")
        窗口文本行距:=Var_Read("窗口文本行距","20","基础配置",软件安装路径 "\个人配置.ini","是")
        屏蔽xiaoyao窗口列表:=Var_Read("","ahk_exe IDMan.exe","窗口列表2",软件安装路径 "\个人配置.ini","是")
        屏蔽xiaoyao程序列表:=Var_Read("屏蔽xiaoyao程序列表","War3.exe,dota2.exe,League of Legends.exe","基础配置",软件安装路径 "\个人配置.ini","是")
        深浅主题切换:=Var_Read("深浅主题切换","跟随系统","基础配置",软件安装路径 "\个人配置.ini","是")
        自动弹出常驻窗口次数:=Var_Read("自动弹出常驻窗口次数","0","基础配置",软件安装路径 "\个人配置.ini","是")

        自定义_当前打开:=Var_Read("自定义_当前打开","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_常用路径:=Var_Read("自定义_常用路径","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_历史打开:=Var_Read("自定义_历史打开","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_全部路径:=Var_Read("自定义_全部路径","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_do收藏夹:=Var_Read("自定义_do收藏夹","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_粘贴:=Var_Read("自定义_粘贴","1","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_更多:=Var_Read("自定义_更多","1","基础配置",软件安装路径 "\个人配置.ini","是")

        自定义_当前打开_文本 :=Var_Read("自定义_当前打开_文本","当前","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_常用路径_文本 :=Var_Read("自定义_常用路径_文本","常用","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_历史打开_文本 :=Var_Read("自定义_历史打开_文本","历史","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_全部路径_文本 :=Var_Read("自定义_全部路径_文本","全部","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_do收藏夹_文本 :=Var_Read("自定义_do收藏夹_文本","dopus","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_粘贴_文本 :=Var_Read("自定义_粘贴_文本","粘贴","基础配置",软件安装路径 "\个人配置.ini","是")
        自定义_更多_文本 :=Var_Read("自定义_更多_文本","更多","基础配置",软件安装路径 "\个人配置.ini","是")

        global 名称列最大宽度:=Var_Read("名称列最大宽度","200","基础配置",软件安装路径 "\个人配置.ini","是")
        global 单击运行跳转:=Var_Read("单击运行跳转","关闭","基础配置",软件安装路径 "\个人配置.ini","是")

        global 悬停提示状态:=Var_Read("悬停提示状态","1","基础配置",软件安装路径 "\个人配置.ini","是")
        global 延迟悬停显示:=Var_Read("延迟悬停显示","300","基础配置",软件安装路径 "\个人配置.ini","是")
        global 不存在时新建:=Var_Read("不存在时新建","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
        global 隐藏标题栏:=Var_Read("隐藏标题栏","关闭","基础配置",软件安装路径 "\个人配置.ini","是")

        gosub, 重新读取分组常用路径
    }
    ;-----------------------------------------------------------------------------------
    global ev排除列表:=Var_Read("ev排除列表","!C:\Windows* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*","基础配置",软件安装路径 "\个人配置.ini","是")
    global 返回的最多结果次数:=Var_Read("返回的最多结果次数","150","基础配置",软件安装路径 "\个人配置.ini","是")
    global 启用ev进行搜索:=Var_Read("启用ev进行搜索","开启","基础配置",软件安装路径 "\个人配置.ini","是")
    global 搜索延迟:=Var_Read("搜索延迟","50","基础配置",软件安装路径 "\个人配置.ini","是")
    global 搜索上次文本:=""   ; 上一次搜索的关键字（替代原来取不到的 searchbox 静态变量）

    if (启用ev进行搜索="开启"){
        ;指定Everything.dll或Everything64.dll的路径
        global evdll位置:= A_ScriptDir
        global everyDLL
        ;[检查当前运行Everything的位数]
        if(FileExist(evdll位置 "\Everything.dll")){
            everyDLL:=DllCall("LoadLibrary", str, "Everything.dll") ? "Everything.dll" : "Everything64.dll"
        }else if(FileExist(evdll位置 "\Everything64.dll")){
            everyDLL:=DllCall("LoadLibrary", str, "Everything64.dll") ? "Everything64.dll" : "Everything.dll"
        }
        ;Else{
        ;MsgBox, 16, 错误, 未找到Everything.dll或Everything64.dll文件.`n请将其放置在脚本同目录下或指定路径中.
        ;Return
        ;}
        ;最终确定DLL路径
        global everyDLL:=evdll位置 "\" everyDLL

        ;global ev排除列表:="!C:\Windows* !?:\$RECYCLE.BIN* !?:\Users\*\AppData\Local\Temp\* !?:\Users\*\AppData\Roaming\*"
        ;global 返回的最多结果次数:="150"
    }
    ;-------------------------------------------------------------------
    gosub,将所有内容路径加入到数组
    gosub,将所有内容路径加入到数组2

    ;【新增】记住当前列表对应的视图标签，右键移除/添加后据此即时刷新
    global 当前视图标签 := "当前打开"
    if (初始文本框内容="常用路径")
        当前视图标签 := "常用路径"
    Else if (初始文本框内容="历史打开")
        当前视图标签 := "历史打开"
    Else if (初始文本框内容="全部路径")
        当前视图标签 := "全部目录路径"
    Else if (初始文本框内容="do收藏夹")
        当前视图标签 := "do收藏夹"

    if (初始文本框内容="常用路径"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(自定义常用路径))
    }Else if (初始文本框内容="历史打开"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(历史所有路径))
    }Else if (初始文本框内容="全部路径"){
        global 文本框内容写入:= 换行符转换为竖杠(Trim(移除空白行(合并所有路径),"`n"))
    }Else if (初始文本框内容="do收藏夹"){
        global 文本框内容写入:= 换行符转换为竖杠(移除空白行(获取到的do收藏夹路径))
    }Else{
        global 文本框内容写入:= 换行符转换为竖杠(RemoveDuplicateLines(移除空白行(Trim(资管所有路径 "`n" do所有路径 "`n" tc所有路径 "`n" xy所有路径 "`n" qdir所有路径 "`n" dc所有路径,"`n"))))
        if (文本框内容写入=""){
            global 文本框内容写入:= 换行符转换为竖杠(移除空白行(自定义常用路径))
            当前视图标签 := "常用路径"   ; 回退显示的是常用列表，视图标签同步
        }
    }
    gosub,显示常驻搜索窗口
    gosub,跟随当前窗口
    ; 【常驻窗口自动恢复】记下跟随的目标窗口，设置保存 / 切换界面风格重启主程序后
    ; 由主程序据此重新拉起（对话框不会再弹一次，否则窗口就永远回不来了）
    常驻恢复_写入(参数2, 参数3)
    Return
}
if (参数1="-跳转事件"){
    global 跳转方式:="1"
    global 自动按修改时间排序:="关闭"
    global 修改时间排序方向:="降序"
    SplitPath, A_ScriptDir, , parentDir
    global 软件安装路径:= parentDir
    if not FileExist(软件安装路径 "\个人配置.ini")
        FileCopy,%软件安装路径%\ICO\默认.ini, %软件安装路径%\个人配置.ini

    if FileExist(软件安装路径 "\个人配置.ini"){
        跳转方式:=Var_Read("跳转方式","1","基础配置",软件安装路径 "\个人配置.ini","是")
        不存在时新建:=Var_Read("不存在时新建","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
        自动按修改时间排序:=Var_Read("自动按修改时间排序","关闭","基础配置",软件安装路径 "\个人配置.ini","否")
        修改时间排序方向:=Var_Read("修改时间排序方向","降序","基础配置",软件安装路径 "\个人配置.ini","否")
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

    Gui,Destroy

    ;深色/浅色主题切换1【开始】---------------------------------
    if (IsDarkMode() and 深浅主题切换="跟随系统") or (深浅主题切换="深色"){
        Menu_Dark(2)    ;菜单强制深色
        if (窗口背景颜色="")
            窗口背景颜色 := "0x202020" ; 深色背景
        if (窗口字体颜色="")
            窗口字体颜色 := "0xE0E0E0" ; 浅色字体
    }
    ;深色/浅色主题切换1【结束】---------------------------------

    global Gui_winID
    ;Gui, +Resize +AlwaysOnTop +ToolWindow +HwndGui_winID
    Gui, +Resize +ToolWindow +HwndGui_winID

    if (隐藏标题栏 = "开启")
        Gui, -Caption

    ;Clipboard:= Gui_winID
    FileAppend,%Gui_winID%`n,%A_Temp%\后台隐藏运行脚本记录.txt

    Gui, Color,%窗口背景颜色%,%窗口背景颜色%
    Gui, Font,c%窗口字体颜色%,%窗口字体名称%

    Gui, Add, Text,x-7 y0,% " "
    if (自定义_当前打开 !="0")
        Gui, Add, Button,x+0 y0 g当前打开 HwndBtn1,%自定义_当前打开_文本%

    if (自定义_常用路径 !="0"){
        Gui, Add, Button,x+0 y0 g常用路径 HwndBtn2,%自定义_常用路径_文本%
        Loop, 5
        {
            if (常用路径开关%A_Index%="1" and 常用路径%A_Index%!="" and 常用路径名称%A_Index%!=""){
                常用路径名称:= 常用路径名称%A_Index%
                Gui, Add, Button,x+0 y0 g常用路径%A_Index% Hwndbtn常%A_Index%,%常用路径名称%
            }
        }
    }
    if (自定义_历史打开 !="0")
        Gui, Add, Button,x+0 y0 g历史打开 HwndBtn3,%自定义_历史打开_文本%

    if (自定义_全部路径 !="0")
        Gui, Add, Button,x+0 y0 g全部目录路径 HwndBtn4,%自定义_全部路径_文本%

    if (DO的收藏夹="开启") and (获取到的do收藏夹路径 !="") and (自定义_do收藏夹 !="0")
        Gui, Add, Button,x+0 y0 gdo收藏夹 HwndBtn5,%自定义_do收藏夹_文本%

    if (自定义_粘贴 !="0")
        Gui, Add, Button,x+0 y0 g直接复制粘贴 HwndBtn6,%自定义_粘贴_文本%

    if (自定义_更多 !="0")
        Gui, Add, Button,x+0 y0 g更多功能设置 HwndBtn7,%自定义_更多_文本%

    Gui, Font,s%窗口字体大小%
    Gui, Add, Edit, w200 x-2 Hwnd搜索框ID v搜索框输入值, % ""
    EM_SETCUEBANNER(搜索框ID, "输入框")

    if (文件夹名显示在前 ="开启")
        Gui, Add, ListView,w200 x-2 y+6 Hwnd文本框ID g文本框选择后执行的操作 v文本框选择值1 -Hdr -Multi +AltSubmit +HScroll, 名称|完整路径
    Else
        Gui, Add, ListView,w200 x-2 y+6 Hwnd文本框ID g文本框选择后执行的操作 v文本框选择值1 -Hdr -Multi +AltSubmit +HScroll, 完整路径

    ;深色/浅色主题切换2【开始】---------------------------------
    if (IsDarkMode() and 深浅主题切换="跟随系统") or (深浅主题切换="深色"){
        DllCall("uxtheme\SetWindowTheme", "ptr", 搜索框ID, "str", "DarkMode_Explorer", "ptr", 0)
        DllCall("uxtheme\SetWindowTheme", "ptr", 文本框ID, "str", "DarkMode_Explorer", "ptr", 0)
        Loop, 7
        {
            ; 根据系统主题设置标题栏颜色（适用于Windows 10+）
            if (A_OSVersion >= "10.0.17763" && SubStr(A_OSVersion, 1, 3) = "10.") {
                attr := A_OSVersion >= "10.0.18985" ? 20 : 19
                DllCall("dwmapi\DwmSetWindowAttribute", "ptr", Gui_winID, "int", attr, "int*", 1, "int", 4)
            }
            DllCall("uxtheme\SetWindowTheme", "ptr", Btn%A_Index%, "str", "DarkMode_Explorer", "ptr", 0)
            DllCall("uxtheme\SetWindowTheme", "ptr", Btn常%A_Index%, "str", "DarkMode_Explorer", "ptr", 0)
        }

    }
    ;深色/浅色主题切换2【结束】---------------------------------
    Gui +LastFound ; 让 GUI 窗口成为上次找到的窗口以用于下一行的命令.

    ;MsgBox,% 字符坐标替换(窗口初始坐标x)
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

    SysGet, VirtualWidth, 78
    SysGet, VirtualHeight, 79
    ;坐标保护防止显示在屏幕外面
    if  (VirtualWidth < (窗口初始坐标x + 窗口初始宽度))
        窗口初始坐标x:= VirtualWidth - 窗口初始宽度 - 5
    if  (VirtualHeight < (窗口初始坐标y + 窗口初始高度))
        窗口初始坐标y:= VirtualHeight - 窗口初始高度

    Gui, Show,NoActivate h%窗口初始高度% w%窗口初始宽度% X%窗口初始坐标x% Y%窗口初始坐标y%,%窗口标题名称%

    SetTimer, ExitScript, Off   ;关闭5秒后的退出操作

    If (参数3="自动弹出"){
        自动弹出常驻窗口次数++
        IniWrite, %自动弹出常驻窗口次数%, %软件安装路径%\个人配置.ini,基础配置,自动弹出常驻窗口次数
    }

    WinSet, Transparent,%窗口透明度%,%窗口标题名称% ahk_class AutoHotkeyGUI

    Sleep, 20

    文本框内容写入 := Trim(文本框内容写入,"|")
    ;MsgBox, %文本框内容写入%
    ; 实时Text = 当前标签页的完整列表，是搜索框清空后的回退目标（启动时要先有值）
    实时Text := 文本框内容写入
    更新ListView内容(文本框内容写入)

    ;ControlFocus,Edit1,%窗口标题名称% ahk_class AutoHotkeyGUI
    OnMessage(0x0101, "searchbox")

    if (悬停提示状态="1")
        OnMessage(0x200, "WM_MOUSEMOVE")
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
GuiSize:
    GuiControl, Move, 文本框选择值1, % "H" . (A_GuiHeight - 64) . " W" . (A_GuiWidth +5)
    GuiControl, Move, 搜索框输入值, % "W" . (A_GuiWidth +5)
Return
;[gui窗口关闭事件]----------------------------------
GuiClose:
    ; 主程序重载中（设置保存 / 切换界面风格）时保留恢复记录，重启后还要重新跟随打开
    if !常驻恢复_重载中() {
        FileAppend,%唯一性%`n,%A_Temp%\常驻窗口关闭记录.txt
        常驻恢复_清除(参数2)
    }
    SetTimer, FollowParentWindow, Off  ; 停止跟随父窗口
    Gui, Destroy
ExitApp
Return
;[gui右键点击事件]----------------------------------
GuiContextMenu:  ; 运行此标签来响应右键点击或按下 Apps 键.
    if (A_GuiControl != "文本框选择值1")  ; 这个检查是可选的. 让它只为 ListView 中的点击显示菜单.
        return

    ;MsgBox,% 获取选中项的值(A_EventInfo)
    global 文本框选择值1:= 获取选中项的值2()
    ;【新增】右键点在没有高亮的行上时，回退取鼠标所在行，避免选中值为空
    if (文本框选择值1 = "" and A_EventInfo > 0)
        文本框选择值1 := 获取选中项的值(A_EventInfo)
    Menu, searchbox2, Add, 打开, 打开
    Menu, searchbox2, Add, 打开所在路径, 打开所在路径

    Menu, searchbox2, Add, 复制到剪切板, 复制到剪切板
    Menu, searchbox2, Add, 直接复制粘贴,直接复制粘贴

    自动跳转到默认路径:=Var_Read("自动跳转到默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
    历史路径设为默认路径:=Var_Read("历史路径设为默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")

    Menu, searchbox2, Add, 设为默认路径, 选中项设为默认路径
    if (自动跳转到默认路径="关闭") or (自动跳转到默认路径="开启" and 历史路径设为默认路径="开启")
        Menu, searchbox2, Disable, 设为默认路径
    Else
        Menu, searchbox2, Enable, 设为默认路径

    Menu, searchbox2, Add, 添加到常用, 添加到常用
    Menu, searchbox2, Add, 从常用中移除, 从常用中移除
    Menu, searchbox2, Show
return

;[窗口各个按钮功能直达]-------------------------------------
当前打开:
    当前视图标签 := A_ThisLabel
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(RemoveDuplicateLines(移除空白行(Trim(资管所有路径 "`n" do所有路径 "`n" tc所有路径 "`n" xy所有路径 "`n" qdir所有路径 "`n" dc所有路径,"`n"))))
    更新ListView内容(实时Text)
Return

常用路径:
    当前视图标签 := A_ThisLabel
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(自定义常用路径))
    更新ListView内容(实时Text)
Return
常用路径1:
    当前视图标签 := A_ThisLabel
    gosub, 重新读取分组常用路径
    实时Text:= 换行符转换为竖杠(移除空白行(常用分组路径[1]))
    更新ListView内容(实时Text)
Return
常用路径2:
    当前视图标签 := A_ThisLabel
    gosub, 重新读取分组常用路径
    实时Text:= 换行符转换为竖杠(移除空白行(常用分组路径[2]))
    更新ListView内容(实时Text)
Return
常用路径3:
    当前视图标签 := A_ThisLabel
    gosub, 重新读取分组常用路径
    实时Text:= 换行符转换为竖杠(移除空白行(常用分组路径[3]))
    更新ListView内容(实时Text)
Return
常用路径4:
    当前视图标签 := A_ThisLabel
    gosub, 重新读取分组常用路径
    实时Text:= 换行符转换为竖杠(移除空白行(常用分组路径[4]))
    更新ListView内容(实时Text)
Return
常用路径5:
    当前视图标签 := A_ThisLabel
    gosub, 重新读取分组常用路径
    实时Text:= 换行符转换为竖杠(移除空白行(常用分组路径[5]))
    更新ListView内容(实时Text)
Return

历史打开:
    当前视图标签 := A_ThisLabel
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(历史所有路径))
    更新ListView内容(实时Text)
Return
全部目录路径:
    当前视图标签 := A_ThisLabel
    gosub,将所有内容路径加入到数组
    gosub,将所有内容路径加入到数组2
    实时Text:= 换行符转换为竖杠(Trim(移除空白行(合并所有路径),"`n"))
    更新ListView内容(实时Text)
Return
do收藏夹:
    当前视图标签 := A_ThisLabel
    gosub,将所有内容路径加入到数组
    实时Text:= 换行符转换为竖杠(移除空白行(获取到的do收藏夹路径))
    更新ListView内容(实时Text)
Return
直接复制粘贴:
    WinActivate,ahk_id %唯一性%
    文本框选择值1:=获取选中项的值2()
    ;MsgBox, %文本框选择值1%
    Clipboard:=文本框选择值1
    SendInput, ^v
    ;ControlSend, , ^v, ahk_id %唯一性%
    ttip("已复制并粘贴到当前文本框:`n"文本框选择值1,3000)
    写入文本到(文本框选择值1,软件安装路径 "\ICO\历史跳转.ini",历史跳转保留数)
Return
更多设置:
Return

文本框选择后执行的操作:
    ;MsgBox, %A_GuiEvent%
    if (A_GuiEvent = "DoubleClick"){
        ToolTip
        Gosub, 打开跳转事件
    }
    if (A_GuiEvent = "Normal"){
        if (单击运行跳转="开启" and 参数3 !="全局版"){
            ToolTip
            Gosub, 打开跳转事件
        }
    }

    /*
        if (A_GuiEvent = "Normal" || A_GuiEvent = "I"){
            if WinActive("ahk_id " Gui_winID){
            测试111:= 获取选中项的值2()
            if (测试111 !=""){
                ControlGetPos, cX, cY, cW, cH, SysListView321, ahk_id %Gui_winID%

                cY2:=cY + cH
                ;MsgBox, %cY2% `n %cY%
                ToolTip, %测试111%, %cX%, %cY2%
            }Else
                ToolTip
                }
        }
    */

Return
复制到剪切板:
    ;文本框选择值1:=获取选中项的值(A_EventInfo)

    Clipboard:=文本框选择值1
    ttip("已复制: "文本框选择值1,3000)
Return

打开:
    ;文本框选择值1:=获取选中项的值(A_EventInfo)
    runtry(文本框选择值1, 不存在时新建)
Return

打开所在路径:
    if not FileExist(文本框选择值1){
        ttip("网络路径 或 路径不存在: "文本框选择值1,3000)
    }Else{
        if not InStr(FileExist(文本框选择值1), "D")
            SplitPath, 文本框选择值1, , 文本框选择值1
    }
    runtry(文本框选择值1, 不存在时新建)
Return
添加到常用:
    if (Trim(文本框选择值1) = "")
        Return

    原始段 := Trim(Var_Read("","","常用路径",软件安装路径 "\个人配置.ini","是"), "`n`r")
    ; 先把已有行换算成显示值用于查重，避免同一路径被写成两种写法重复添加
    已有显示值 := ""
    Loop, Parse, 原始段, `n, `r
        已有显示值 .= 常用行转显示路径(A_LoopField, 参数2, 替换双斜杠单反斜杠双引号, false) . "`n"

    新段 := 原始段
    添加数 := 0
    Loop, Parse, 文本框选择值1, `n, `r
    {
        待添加 := Trim(A_LoopField)
        if (待添加 = "") or 选中列表包含(已有显示值, 待添加)
            Continue
        新段 .= (新段 != "" ? "`n" : "") . 待添加
        已有显示值 .= 待添加 "`n"
        添加数++
    }
    if (添加数 > 0){
        IniDelete, %软件安装路径%\个人配置.ini,常用路径
        IniWrite, %新段%, %软件安装路径%\个人配置.ini,常用路径
        gosub, 刷新当前列表
        广播常用变更()
        ttip("已添加 " 添加数 " 条到常用路径", 2000)
    }Else{
        ttip("该路径已存在于常用路径列表中", 2000)
    }
Return

从常用中移除:
    if (Trim(文本框选择值1) = "")
        Return

    ini路径 := 软件安装路径 "\个人配置.ini"
    ; 当前是某个分类视图时只删该段；其它视图（当前打开/历史/全部/搜索结果）
    ; 无法确定来源，就把主段和所有分类段里命中该路径的行一起删掉。
    段列表 := []
    if (当前视图标签 = "常用路径"){
        段列表.Push("常用路径")
    }Else if (SubStr(当前视图标签, 1, 4) = "常用路径" and StrLen(当前视图标签) = 5){
        段列表.Push(当前视图标签)
    }Else{
        段列表.Push("常用路径")
        Loop, 5
            段列表.Push("常用路径" A_Index)
    }

    删除数 := 0
    for 序号, 段名 in 段列表
        删除数 += 从常用段删除匹配(段名, ini路径, 文本框选择值1, 参数2, 替换双斜杠单反斜杠双引号)

    if (删除数 > 0){
        gosub, 刷新当前列表
        广播常用变更()
        ttip("已从常用中移除 " 删除数 " 条", 2000)
    }Else{
        ttip("未在常用路径中找到该路径（可能来自历史/收藏夹）", 2500)
    }
Return

更多功能设置:
    自动跳转到默认路径:=Var_Read("自动跳转到默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
    历史路径设为默认路径:=Var_Read("历史路径设为默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
    默认路径:=ReplaceVars(Var_Read("默认路径","","基础配置",软件安装路径 "\个人配置.ini","是"))
    自动跳转到文件管理器路径:=Var_Read("自动跳转到文件管理器路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")

    ;if (自动跳转到文件管理器路径="关闭")
    ;Menu, searchbox, Add, 开启 自动跳转到文件管理器路径, 开启自动跳转到文件管理器路径
    ;if (自动跳转到文件管理器路径="开启"){
    ;Menu, searchbox, Add, 自动跳转到文件管理器路径, 关闭自动跳转到文件管理器路径
    ;Menu, searchbox, Icon, 自动跳转到文件管理器路径, shell32.dll, 145
    ;}

    if (自动跳转到默认路径="关闭"){
        Menu, searchbox, Add, 开启 自动跳默认路径, 开启自动跳默认路径
        if (自动跳转到文件管理器路径="开启")
            Menu, searchbox, Disable, 开启 自动跳默认路径
    }
    if (自动跳转到默认路径="开启"){
        Menu, searchbox, Add, 自动跳默认路径, 关闭自动跳默认路径
        Menu, searchbox, Icon, 自动跳默认路径, shell32.dll, 145
        if (自动跳转到文件管理器路径="开启")
            Menu, searchbox, Disable, 自动跳默认路径
    }

    if (历史路径设为默认路径="关闭"){
        Menu, searchbox, Add, 开启 历史路径设为默认, 开启历史路径设为默认
        if (自动跳转到默认路径="关闭") or (自动跳转到文件管理器路径="开启")
            Menu, searchbox, Disable, 开启 历史路径设为默认
    }
    if (历史路径设为默认路径="开启"){
        Menu, searchbox, Add, 历史路径设为默认, 关闭历史路径设为默认
        Menu, searchbox, Icon, 历史路径设为默认, shell32.dll, 145
        if (自动跳转到默认路径="关闭") or (自动跳转到文件管理器路径="开启")
            Menu, searchbox, Disable, 历史路径设为默认
    }

    Menu, searchbox, Add, 设置 默认路径, 设置默认路径
    Menu, searchbox, Add, 查看 当前自动跳转路径, 查看默认路径
    if (自动跳转到默认路径="关闭") or (自动跳转到默认路径="开启" and 历史路径设为默认路径="开启") or (自动跳转到文件管理器路径="开启"){
        Menu, searchbox, Disable, 设置 默认路径
        Menu, searchbox, Disable, 查看 当前自动跳转路径
    }
    /*
        Menu, searchbox, Add, 查看 当前自动跳转路径, 查看默认路径
        if (自动跳转到默认路径="关闭")
            Menu, searchbox, Disable, 查看 当前自动跳转路径
    */
    Menu, searchbox, Add

    if (自动弹出常驻窗口="开启"){
        gosub,获取窗口信息
        ; -----------------------------------------------------
        ; 动态显示“允许”或“移除”菜单
        ; -----------------------------------------------------
        gosub,获取自动弹出窗口信息
        if (!EntryExists_AutoPopup){
            Menu, searchbox, Add, 添加当前窗口自动弹出, 允许当前窗口自动弹出
        } Else {
            Menu, searchbox, Add, 从自动弹出列表中移除, 从自动弹出列表中移除
            ; 如果你希望移除菜单带个图标，可以保留下面这行（132 对应一个红叉图标）
            Menu, searchbox, Icon, 从自动弹出列表中移除, shell32.dll, 132
        }
        ; -----------------------------------------------------
        Menu, searchbox, Add
        if (!EntryExists)
            Menu, searchbox, Add, 禁止当前窗口自动弹出, 禁止当前窗口自动弹出
        Else{
            Menu, searchbox, Add, 禁止当前窗口自动弹出, 禁止当前窗口自动弹出
            Menu, searchbox, Icon, 禁止当前窗口自动弹出, shell32.dll, 145
        }

    }
    Menu, searchbox, Add, 在该程序中禁用xiaoyao, 在该程序中禁用xiaoyao

    Menu, searchbox, Add
    Menu, searchbox, Add, 导出日志, 导出日志
    Menu, searchbox, Add, 设置(&D), 设置可视化
    Menu, searchbox, Add, 重启(&R), Menu_Reload
    Menu, searchbox, Add, 关闭(&G), GuiClose
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
    ;Gui, Show,NoActivate
    文本框选择值1:=获取选中项的值2()
    if (文本框选择值1="")
        Return

    if (参数3="全局版"){ ;如果是全局版
        ;MsgBox, %全局性菜单项功能%
        if (全局性菜单项功能="直接打开"){
            runtry(文本框选择值1, 不存在时新建)
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
        if (不存在时新建="开启"){
            FileCreateDir, %跳转目标路径%
            Sleep, 50
        }
        if not FileExist(跳转目标路径)
            ttip("网络路径 或 路径不存在: "跳转目标路径,3000)
        ;MsgBox, 1
        ;Return
    }Else{
        if not InStr(FileExist(跳转目标路径), "D")
            SplitPath, 跳转目标路径, , 跳转目标路径
    }
    ;MsgBox, 跳转目标路径: %跳转目标路径%`n另存为窗口id值: %另存为窗口id值%`n跳转方式: %跳转方式%

    WinGet CtlList, ControlList, ahk_id %另存为窗口id值%
    ControlGet, hctl222, Hwnd,, SysTreeView321, ahk_id %另存为窗口id值%
    ControlGet, hctl333, Hwnd,, Edit1, ahk_id %另存为窗口id值%

    $DialogType := SmellsLikeAFileDialog(另存为窗口id值)
    if ($DialogType = "WPS") {
        跳转成功 := FeedDialogWPS(另存为窗口id值, 跳转目标路径)
        if (跳转成功 && 自动按修改时间排序 = "开启")
            按修改时间排序窗口(另存为窗口id值, 修改时间排序方向)
        WinActivate,ahk_id %Gui_winID%
        Return
    }

    if (跳转方式="2"){
        If (InStr(CtlList, "SHBrowseForFolder ShellNameSpace Control")){    ;如果是旧式对话框
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
        ;if (InStr(CtlList, "DirectUIHWND2") ){
        $DialogType := SmellsLikeAFileDialog(另存为窗口id值)
        If ($DialogType="SYSLISTVIEW" or $DialogType="GENERAL"){    ;如果是新式对话框
            FeedDialog%$DialogType%(另存为窗口id值, 跳转目标路径)
        }Else
            run,"%A_AhkPath%" "%A_ScriptDir%\外部调用跳转.ahk" %另存为窗口id值% "%跳转目标路径%"

    }
    if (自动按修改时间排序 = "开启")
        按修改时间排序窗口(另存为窗口id值, 修改时间排序方向)
    WinActivate,ahk_id %Gui_winID%
Return

父窗口关闭运行事件:
    if !WinExist("ahk_id " 参数2)  ; 如果父窗口已关闭
    {
        Gui,  Destroy
        SetTimer, FollowParentWindow, Off
        SetTimer, 父窗口关闭运行事件, Off
        常驻恢复_清除(参数2)   ; 目标窗口没了，恢复记录一并作废
        ExitApp
        return
    }
Return
;[搜索框内容定位和右键菜单]-------------------------------------
/*
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

                 自动跳转到默认路径:=Var_Read("自动跳转到默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")
                 历史路径设为默认路径:=Var_Read("历史路径设为默认路径","关闭","基础配置",软件安装路径 "\个人配置.ini","是")

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
 */
#If WinActive("ahk_id" Gui_winID) ; 搜索框的热键
    Up::
        ControlFocus,,ahk_id %文本框ID%
        RowNumber := LV_GetNext(0)
        If (RowNumber = 0){
            LV_Modify(1, "+Focus +Select +Vis")
        }Else If (RowNumber = 1){
            LV_Modify(LV_GetCount(), "+Focus +Select +Vis")
        }
        Else{
            LV_Modify(RowNumber-1, "+Focus +Select +Vis")
        }
    Return

    Down::
        ControlFocus,,ahk_id %文本框ID%
        RowNumber := LV_GetNext(0)
        If (RowNumber = 0 || RowNumber=LV_GetCount()){
            LV_Modify(1, "+Focus +Select +Vis")
        }Else{
            LV_Modify(RowNumber+1, "+Focus +Select +Vis")
        }
    Return

    Enter::
        ToolTip
        Gosub, 打开跳转事件
    Return

#If

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
    if !WinExist("ahk_id " Gs_tcWinID)  ; 如果父窗口已关闭 [cite: 64]
    {
        Gui,  Destroy
        SetTimer, FollowParentWindow, Off
        ExitApp
        return
    }

    ;=============== 窗口层级（Z 序）统一维护 ===============
    ; 目标：让本窗口始终「紧贴父窗口的上方一层」——谁挡住父窗口，就同样挡住本窗口。
    ; 旧写法有两个致命问题：
    ;   1) 用「是否是第一次激活切换 / 是否是第一次非激活切换」这类一次性开关决定置顶，
    ;      开关一辈子只翻转一次，取消置顶的分支之后再也走不到，窗口就永久留在最上层；
    ;   2) 取消置顶时把窗口插到「当前前台窗口」之后，等于把它抬到除前台窗口以外所有窗口
    ;      之上 —— 打开设置窗口、点任意其它窗口，它都会以「又跑到最上层」的样子出现。
    ; 现在改为按父窗口的真实 Z 序邻居定位，并每帧自检，一旦没贴合立刻重排。
    WinGet, Active_HWnd, ID, A
    本窗口在前台 := (Active_HWnd <> "" and (Active_HWnd + 0) = (Gui_winID + 0))
    if (窗口是否置顶(Gs_tcWinID) != 窗口是否置顶(Gui_winID))
        Gosub, 应用窗口层级   ; 置顶位必须先跟父窗口一致，否则父窗口是置顶窗时会盖住本窗口
    Else if (!本窗口在前台 and (父窗口上方窗口ID() + 0) != (Gui_winID + 0))
        Gosub, 应用窗口层级   ; 本窗口当前是前台窗时不要再调 Z 序，否则会把自己挤到别人后面
    ;======================================================
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
            Gui,hide
            ;print("最小化" guiX3 "`n" guiY3)
        }
        Return
    }Else if (active_MinMax="1"){
        if (是否是第一次最大化切换="是"){
            是否是第一次最大化切换:="否"
            是否是第一次最小化切换:="是"
            是否是第一次中化切换:="是"
            ;MsgBox, 2
            Gui,Show,NoActivate
            ;WinMove, ahk_id %Gui_winID%,, %guiX3%, %guiY3%
            ; Z 序由「应用窗口层级」每帧自检，Show 之后下一帧会自动排回父窗口上方
            ;WinActivate, ahk_id %Gs_tcWinID%
            ;print("最大化" guiX3 "`n" guiY3)
        } ;Else
        Return
    }Else{
        if (是否是第一次中化切换="是"){
            是否是第一次最大化切换:="是"
            是否是第一次最小化切换:="是"
            是否是第一次中化切换:="否"
            ;MsgBox, 2
            Gui,Show,NoActivate
            ;WinMove, ahk_id %Gui_winID%,, %guiX3%, %guiY3%
            ;WinActivate, ahk_id %Gs_tcWinID%
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

;[按父窗口位置维护窗口层级]─────────────────────────────────────
; 不再用「置顶 / 取消置顶」的开关思路，而是让本窗口在 Z 序里紧贴父窗口上方：
;   · 父窗口自己置顶 → 本窗口也置顶，再插到父窗口上方；
;   · 父窗口不置顶   → 本窗口也非置顶，同样插到父窗口上方，
;     于是任何盖住父窗口的窗口都会顺手把本窗口一起盖住，不会再浮在所有窗口最上层。
; 0x13 = SWP_NOSIZE|SWP_NOMOVE|SWP_NOACTIVATE：只调 Z 序，不动位置尺寸、不抢焦点。
应用窗口层级:
    父窗口已置顶 := 窗口是否置顶(Gs_tcWinID)
    本窗口已置顶 := 窗口是否置顶(Gui_winID)
    if (父窗口已置顶 and !本窗口已置顶)
        DllCall("user32\SetWindowPos", "Ptr", Gui_winID, "Ptr", -1, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)  ; HWND_TOPMOST
    Else if (!父窗口已置顶 and 本窗口已置顶)
        DllCall("user32\SetWindowPos", "Ptr", Gui_winID, "Ptr", -2, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)  ; HWND_NOTOPMOST

    锚点 := 父窗口上方窗口ID()
    if ((锚点 + 0) = (Gui_winID + 0))
        Return
    ; 锚点必须与本窗口同层（同为置顶或同为非置顶），否则插到它后面会把本窗口一起染成置顶
    if (锚点 and (窗口是否置顶(锚点) != 父窗口已置顶))
        锚点 := 0
    DllCall("user32\SetWindowPos", "Ptr", Gui_winID, "Ptr", 锚点, "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
Return

;[取窗口是否带 WS_EX_TOPMOST]─────────────────────────────────────
窗口是否置顶(hwnd) {
    if !hwnd
        Return 0
    WinGet, 扩展样式, ExStyle, ahk_id %hwnd%
    Return (扩展样式 & 0x8) ? 1 : 0
}

;[取 Z 序中紧挨在父窗口上方（更靠前）的那个窗口]───────────────────
父窗口上方窗口ID() {
    global Gs_tcWinID
    Return DllCall("user32\GetWindow", "Ptr", Gs_tcWinID, "UInt", 3, "Ptr")   ; 3 = GW_HWNDPREV
}

;[将所有内容路径加入到数组]═════════════════════════════════════════════════
将所有内容路径加入到数组:

    资管所有路径:=""
    do所有路径:=""
    tc所有路径:=""
    xy所有路径:=""
    qdir所有路径:=""
    dc所有路径:=""

    global 历史所有路径:= HistoryOpenPath(软件安装路径)
    if (失效路径显示设置 ="关闭")
        历史所有路径:= FilterExistingPaths(历史所有路径)

    DetectHiddenWindows,Off
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass")
        资管所有路径:=Explorer_Path() "`n" Explorer_Path全部()

    if WinExist("ahk_exe dopus.exe")
        do所有路径:= Trim(DirectoryOpusgetinfo(0),"`n")

    if WinExist("ahk_class TTOTAL_CMD")
        tc所有路径:= TotalCommander_path("0")

    xy所有路径:=XYplorer_Path()
    qdir所有路径:=Q_Dir_Path()
    dc所有路径:=DoubleCommander_path(给dc发送热键)

    自定义常用路径2:=Var_Read("","","常用路径",软件安装路径 "\个人配置.ini","是")

    自定义常用路径:=ReplaceVars(自定义常用路径2)
    自定义常用路径:=程序专属路径筛选(自定义常用路径, 参数2)

    if (替换双斜杠单反斜杠双引号="开启"){
        自定义常用路径:=RegExReplace(StrReplace(自定义常用路径, """", ""), "\\\\|/", "\")
    }

    if (失效路径显示设置 ="关闭")
        自定义常用路径:= FilterExistingPaths(自定义常用路径)

    常用所有路径:= 自定义常用路径

    ;【新增】每次重建列表都重读分类段，保证外部修改配置后能立刻反映出来
    gosub, 重新读取分组常用路径
return

将所有内容路径加入到数组2:

    global 获取到的do收藏夹路径:=""
    if (DO的收藏夹="开启"){
        获取到的do收藏夹路径:=DirectoryOpusgetfa()
        if (失效路径显示设置 ="关闭")
            获取到的do收藏夹路径:= FilterExistingPaths(获取到的do收藏夹路径)
    }

    合并所有路径:= Trim(资管所有路径, "`n") "`n" Trim(do所有路径, "`n") "`n" Trim(tc所有路径, "`n") "`n" Trim(获取到的do收藏夹路径, "`n") "`n" Trim(常用所有路径, "`n") "`n" Trim(历史所有路径, "`n") "`n" Trim(xy所有路径, "`n") "`n" Trim(qdir所有路径, "`n") "`n" Trim(dc所有路径, "`n")
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

开启自动跳转到文件管理器路径:
    IniWrite, 开启, %软件安装路径%\个人配置.ini,基础配置,自动跳转到文件管理器路径
return
关闭自动跳转到文件管理器路径:
    IniWrite, 关闭, %软件安装路径%\个人配置.ini,基础配置,自动跳转到文件管理器路径
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
    ;文本框选择值1:=获取选中项的值(A_EventInfo)
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
;搜索框搜索内容【没加防抖的版本】--------------------------------------------------------
/*
searchbox(W, L, M, H)
{
    global 搜索框ID,文本框ID,所有路径合集,文本框内容写入,返回的最多结果次数,ev排除列表,启用ev进行搜索,文件夹名显示在前
    Static LastText := ""
    If (H = 搜索框ID)
    {
        GuiControlGet, value, , % 搜索框ID

        if (启用ev进行搜索="开启"){
            value2:=everythingSearch(ev排除列表 " " value,返回的最多结果次数)   ;调用everything进行搜索
            if (文件夹名显示在前="开启")
                value2:=给行首加文件名(value2)
            value2:=StrReplace(value2, "`n", "|")
        }
        ;MsgBox, %value%
        If (value And value!=LastText)
        {
            Text := ""
            for index, ele in 所有路径合集
                if (InStr(ele,value))
                    Text .= (Text ? "|" ele : ele)
            if (启用ev进行搜索="开启")
                Text := trim(value2 "|" Text, "|")
            GuiControl, , % 文本框ID, % "|" Text
        }
        Else If (!value)
            GuiControl, , % 文本框ID, % "|" 文本框内容写入
        LastText := value
    }
}
*/

;搜索框搜索内容[加了防抖]
searchbox(W, L, M, H)
{
    global 搜索框ID,文本框ID,所有路径合集,文本框内容写入,搜索延迟
    Static LastText := ""
    Static DebounceTimer := 0  ; 防抖计时器

    If (H = 搜索框ID)
    {
        GuiControlGet, value, , % 搜索框ID
        if (搜索延迟 > 0){
            ; 取消之前的计时器
            if (DebounceTimer) {
                SetTimer, % DebounceTimer, Delete
            }

            ; 设置新的防抖计时器（300毫秒后执行）
            DebounceTimer := Func("PerformSearch").Bind(value, LastText)
            SetTimer, % DebounceTimer, -%搜索延迟%
        }Else{
            PerformSearch(value, LastText)
        }
    }
}

PerformSearch(value, LastText)
{
    global 搜索框ID,文本框ID,所有路径合集,文本框内容写入,启用ev进行搜索,ev排除列表,返回的最多结果次数,文件夹名显示在前,Text2,搜索上次文本,实时Text

    ; 重置计时器标识
    searchbox.DebounceTimer := 0

    If (value And value != 搜索上次文本)
    {
        ; 先做不依赖 Everything 的本地匹配（常用路径 / 所有路径 / 历史 / 当前打开），
        ; 关掉 Everything 之后仍然能搜到这些内容
        Text := ""
        for index, ele in 所有路径合集
        {
            if (ele = "")
                continue
            if (InStr(ele,value))
                Text .= (Text ? "|" ele : ele)
        }

        ; 再叠加 Everything 的全盘结果；查不到就保持本地结果，不覆盖
        if (启用ev进行搜索 = "开启") {
            value2 := everythingSearch(ev排除列表 " " value, 返回的最多结果次数)   ;调用everything进行搜索
            if (value2 != "") {
                value2 := StrReplace(value2, "`n", "|")
                Text := Text ? (value2 "|" Text) : value2
            }
        }

        if (Text !=Text2)
            更新ListView内容(Text)
        Text2:=Text
    }
    Else If (!value)
    {
        ; 搜索框清空 → 回到当前标签页的列表（原写法固定用 文本框内容写入，
        ; 那是启动时的默认列表，切到「全部/常用/历史」后一按键就被刷回去）
        if (搜索上次文本 != "" or Text2 != "")
        {
            Text2 := ""
            更新ListView内容(实时Text)
        }
    }

    ; 更新LastText（原来写的是 searchbox.LastText，跨函数写不到，去重从未生效）
    搜索上次文本 := value
}

RemoveToolTip:
    ToolTip
return

;字符坐标替换------------------------------------------------------------------------------
字符坐标替换(str){
    global 唯一性
    WinGetPos, 父窗口X, 父窗口Y, 父窗口W, 父窗口H, ahk_id %唯一性%
    ;GetWindowRect(唯一性, 父窗口X, 父窗口Y)
    GetClientSize(唯一性, 父窗口W, 父窗口H)

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
常驻恢复_清除(参数2)   ; 窗口没能正常显示出来，恢复记录不该留着
ExitApp ; 退出脚本
return

获取窗口信息:

    屏蔽xiaoyao窗口列表:=Var_Read("","ahk_exe IDMan.exe","窗口列表2",软件安装路径 "\个人配置.ini","是")

    WinGetTitle, WinTitle22, ahk_id %参数2%
    WinGetClass, WinClass22, ahk_id %参数2%
    WinGet, WinExe22, ProcessName, ahk_id %参数2%
    ; 格式化窗口信息
    NewEntry := WinTitle22 " ahk_class " WinClass22 " ahk_exe " WinExe22

    ; 检查是否已存在相同条目

    EntryExists := false
    Loop, Parse, 屏蔽xiaoyao窗口列表, `n, `r
    {
        ; 比较忽略前后空格
        if (Trim(A_LoopField) = Trim(NewEntry)){
            EntryExists := true
            break
        }
    }
Return

禁止当前窗口自动弹出:
    gosub,获取窗口信息

    if (!EntryExists){
        ; 添加到编辑框
        NewList := 屏蔽xiaoyao窗口列表 ? 屏蔽xiaoyao窗口列表 "`n" NewEntry : NewEntry
        ;MsgBox,% NewList
        IniDelete, %软件安装路径%\个人配置.ini,窗口列表2
        IniWrite, %NewList%, %软件安装路径%\个人配置.ini,窗口列表2
        run,"%软件安装路径%\XiaoYao_快速跳转.exe" "%软件安装路径%\主程序.ahk"
    }Else{
        ; 如果已存在，则从编辑框中移除
        NewList := ""
        Loop, Parse, 屏蔽xiaoyao窗口列表, `n, `r
        {
            if !(Trim(A_LoopField) = Trim(NewEntry)){
                NewList .= (NewList ? "`n" : "") A_LoopField
            }
        }

        ;MsgBox,2%NewList%
        IniDelete, %软件安装路径%\个人配置.ini,窗口列表2
        IniWrite, %NewList%, %软件安装路径%\个人配置.ini,窗口列表2
        run,"%软件安装路径%\XiaoYao_快速跳转.exe" "%软件安装路径%\辅助\自动弹出常驻窗口.ahk"
    }

return

允许当前窗口自动弹出:
    gosub,获取自动弹出窗口信息

    if (!EntryExists_AutoPopup){
        ; 添加到配置列表中
        NewList := 常驻窗口窗口列表 ? 常驻窗口窗口列表 "`n" NewEntry : NewEntry
        IniDelete, %软件安装路径%\个人配置.ini,窗口列表1
        IniWrite, %NewList%, %软件安装路径%\个人配置.ini,窗口列表1
        ; 添加后重启主程序生效
        run,"%软件安装路径%\XiaoYao_快速跳转.exe" "%软件安装路径%\主程序.ahk"
    }
return

从自动弹出列表中移除:
    gosub,获取自动弹出窗口信息

    if (EntryExists_AutoPopup){
        ; 从配置列表中过滤掉当前窗口
        NewList := ""
        Loop, Parse, 常驻窗口窗口列表, `n, `r
        {
            if !(Trim(A_LoopField) = Trim(NewEntry)){
                NewList .= (NewList ? "`n" : "") A_LoopField
            }
        }
        IniDelete, %软件安装路径%\个人配置.ini,窗口列表1
        IniWrite, %NewList%, %软件安装路径%\个人配置.ini,窗口列表1
        ; 移除后重启常驻窗口辅助脚本生效
        run,"%软件安装路径%\XiaoYao_快速跳转.exe" "%软件安装路径%\辅助\自动弹出常驻窗口.ahk"
    }
return

在该程序中禁用xiaoyao:
    WinGet, WinExe22, ProcessName, ahk_id %参数2%
    NewList2 := RemoveDuplicateLines(屏蔽xiaoyao程序列表 "`," WinExe22,jiangeci:="`,")
    IniWrite, %NewList2%, %软件安装路径%\个人配置.ini,基础配置,屏蔽xiaoyao程序列表
    run,"%软件安装路径%\XiaoYao_快速跳转.exe" "%软件安装路径%\主程序.ahk"
;MsgBox, %NewList2%
return

导出日志:
    未转化之前的坐标x:=Var_Read("窗口初始坐标x","","基础配置",软件安装路径 "\个人配置.ini","是")
    未转化之前的坐标y:=Var_Read("窗口初始坐标y","","基础配置",软件安装路径 "\个人配置.ini","是")
    窗口初始宽度:=Var_Read("窗口初始宽度","","基础配置",软件安装路径 "\个人配置.ini","是")
    窗口初始高度:=Var_Read("窗口初始高度","","基础配置",软件安装路径 "\个人配置.ini","是")

    转化之后的坐标x:= Calculate(字符坐标替换(未转化之前的坐标x))
    转化之后的坐标y:= Calculate(字符坐标替换(未转化之前的坐标y))

    SysGet, VirtualWidth, 78
    SysGet, VirtualHeight, 79
    ;坐标保护防止显示在屏幕外面
    转化之后的坐标x2:= 转化之后的坐标x
    转化之后的坐标y2:= 转化之后的坐标y
    if  (VirtualWidth < (转化之后的坐标x + 窗口初始宽度))
        转化之后的坐标x2:= VirtualWidth - 窗口初始宽度
    if  (VirtualHeight < (转化之后的坐标y + 窗口初始高度))
        转化之后的坐标y2:= VirtualHeight - 窗口初始高度

    常驻窗口的相关坐标信息:="未转化之前的坐标x：" 未转化之前的坐标x "`n未转化之前的坐标y：" 未转化之前的坐标y "`n转化之后的坐标x：" 转化之后的坐标x "`n转化之后的坐标y：" 转化之后的坐标y "`n屏幕保护后的坐标x2：" 转化之后的坐标x2 "`n屏幕保护后的坐标y2：" 转化之后的坐标y2

    SysGet, MonitorCount, MonitorCount
    SysGet, MonitorPrimary, MonitorPrimary
    ;MsgBox, 显示器的数量‌:`t%MonitorCount%`n主显示器:`t%MonitorPrimary%
    显示屏信息:=""
    Loop, %MonitorCount%
    {
        SysGet, MonitorName, MonitorName, %A_Index%
        SysGet, Monitor, Monitor, %A_Index%
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
        显示屏信息 .="显示屏:`t#" A_Index "`n名称:`t" MonitorName "`n左边:`t" MonitorLeft " (" MonitorWorkAreaLeft " work)`n上边:`t" MonitorTop " (" MonitorWorkAreaTop " work)`n右边:`t" MonitorRight " (" MonitorWorkAreaRight " work)`n下边:`t" MonitorBottom " (" MonitorWorkAreaBottom " work)`n"
        ;MsgBox, 显示屏:`t#%A_Index%`n名称:`t%MonitorName%`n左边:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`n上边:`t%MonitorTop% (%MonitorWorkAreaTop% work)`n右边:`t%MonitorRight% (%MonitorWorkAreaRight% work)`n下边:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
    }

    显示器的信息:= "显示器数量: " MonitorCount "`n主显示器: " MonitorPrimary "`n`n显示屏信息:`n" 显示屏信息

    WinGetPos, 活动窗口X, 活动窗口Y, 活动窗口W, 活动窗口H, ahk_id %唯一性%
    WinGetPos, 常驻窗口X2, 常驻窗口Y2, 常驻窗口W2, 常驻窗口H2, %窗口标题名称%

    父窗口的信息:= "活动窗口：X: " 活动窗口X "  Y: " 活动窗口Y "  W: " 活动窗口W "  H: " 活动窗口H
    常驻窗口的信息:= "常驻窗口：X2: " 常驻窗口X2 "  Y2: " 常驻窗口Y2 "  W2: " 常驻窗口W2 "  H2: " 常驻窗口H2

    ;MsgBox, % 常驻窗口的相关坐标信息 "`n`n" 父窗口的信息 "`n" 常驻窗口的信息 "`n`n" 显示器的信息
    ttip("已导出日志到软件安装路径下",3000)
    FileAppend,% "窗口边界信息：" VirtualWidth " " VirtualHeight "`n`n" 常驻窗口的相关坐标信息 "`n`n" 父窗口的信息 "`n" 常驻窗口的信息 "`n`n" 显示器的信息,%软件安装路径%\导出日志%A_Now%.txt
Return

;Everything搜=========================================================================================
;[使用everything搜索,返回第一个匹配值]
everythingSearch(str,最多次数:="150",MatchPath:="0",MatchWholeWord:="0",MatchCase:="0",Regex:="0",Max:="150",Sort1:="1"){
    global everyDLL
    ; DLL 没加载成功（没装 Everything / 文件缺失）时不要硬调，否则 DllCall 会弹错误框
    if (everyDLL = "" or !FileExist(everyDLL))
        return ""
    ev := new everything_xiaoyao
    ;set
    ;MatchPath 完整路径匹配(true)
    ;MatchWholeWord 全字匹配(true)
    ;MatchCase 匹配大小写(true)
    ;Regex 匹配正则表达式(true)
    ;Max 返回的最大结果数(1)
    ;Sort 结果的排序方式(1-26) https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setsort/
    ;ev.SetMatchPath(MatchPath)  ;完整路径匹配(1)
    ;ev.SetMatchWholeWord(MatchWholeWord)     ;全字匹配(1)
    ;ev.SetMatchCase(MatchCase)  ;匹配大小写(1)
    ;ev.SetRegex(Regex)  ;匹配正则表达式(1)
    ;ev.SetMax(Max)    ;返回的最大结果数(10)
    ;ev.SetSort(Sort1)   ;结果的排序方式(1-26) https://www.voidtools.com/zh-cn/support/everything/sdk/everything_setsort/

    ev.SetSearch(str)
    ;执行搜索
    ;查询失败（Everything 没开 / 刚关掉）直接返回空，由调用方退回本地匹配；
    ;否则会读到上一次查询残留的结果，看起来像"搜索结果不对"
    if !(ev.Query())
        return ""

    ;MsgBox, % "`n最大返回数" ev.GetMax() "`n返回匹配总数" ev.GetTotResults() "`n排序" ev.GetSort() "`n实际的" ev.GetResultListSort() "`n" ev.GetResultFileName(0) "`n" ev.GetResultFullPathName(0)
    所有结果文件路径:=""
    Loop,%最多次数%
    {
        结果路径 := ev.GetResultFullPathName(A_Index-1)
        if (结果路径 = "")
            break
        所有结果文件路径.=结果路径 "`n"
    }
    return trim(所有结果文件路径, "`n")
}

;[IPC方式和everything进行通讯，修改于AHK论坛]
class everything_xiaoyao
{
    __New(){
        this.hModule := DllCall("LoadLibrary", str, everyDLL)
    }
    __Get(aName){
    }
    __Set(aName, aValue){
    }
    __Delete(){
        DllCall("FreeLibrary", "UInt", this.hModule)
        return
    }
    SetSearch(aValue){
        this.eSearch := aValue
        ; 只有 Everything_SetSearchW / A 两个导出，写错名字 DllCall 会静默失败，
        ; 关键字根本没送到 Everything，结果自然是"搜不到"
        dllcall(everyDLL "\Everything_SetSearchW","wstr",aValue)
        return
    }
    ;设置全字匹配
    SetMatchWholeWord(aValue){
        this.eMatchWholeWord := aValue
        dllcall(everyDLL "\Everything_SetMatchWholeWord",int,aValue)
        return
    }
    ;完整路径匹配
    SetMatchPath(aValue){
        this.eMatchPath := aValue
        dllcall(everyDLL "\Everything_SetMatchPath",int,aValue)
        return
    }
    ;大小写匹配
    SetMatchCase(aValue){
        this.eMatchCase := aValue
        dllcall(everyDLL "\Everything_SetMatchCase",int,aValue)
        return
    }
    ;设置正则表达式搜索
    SetRegex(aValue){
        this.eRegex := aValue
        dllcall(everyDLL "\Everything_SetRegex",int,aValue)
        return
    }
    ;【新增】设置返回的最大结果数
    SetMax(aValue){
        this.eMax := aValue
        dllcall(everyDLL "\Everything_SetMax", "int", aValue)
        return
    }
    ;【新增】设置结果的排序方式
    SetSort(aValue){
        this.eSort := aValue
        dllcall(everyDLL "\Everything_SetSort", "int", aValue)
        return
    }
    ;【新增】最大结果数
    GetMax(){
        return dllcall(everyDLL "\Everything_GetMax")
    }
    ;【新增】结果的排序方式
    GetSort(){
        return dllcall(everyDLL "\Everything_GetSort")
    }
    ;【新增】实际的结果的排序方式
    GetResultListSort(){
        return dllcall(everyDLL "\Everything_GetResultListSort")
    }

    ;执行搜索动作
    Query(aValue=1){
        ; 导出名只有 Everything_QueryW / A；1=成功，0=失败（Everything 没在运行）
        return dllcall(everyDLL "\Everything_QueryW","int",aValue,"int")
    }
    ;返回管理员权限状态
    GetIsAdmin(){
        return dllcall(everyDLL "\Everything_IsAdmin")
    }
    ;返回匹配总数
    GetTotResults(){
        return dllcall(everyDLL "\Everything_GetTotResults")
    }
    ;返回可见文件结果的数量
    GetNumFileResults(){
        return dllcall(everyDLL "\Everything_GetNumFileResults")
    }
    ;返回文件名
    GetResultFileName(aValue){
        ; 导出名只有 Everything_GetResultFileNameW，且返回值是指针（64 位不能当 int）
        h := dllcall(everyDLL "\Everything_GetResultFileNameW","int",aValue,"ptr")
        return h ? strget(h, 0, "UTF-16") : ""
    }
    ;返回文件全路径
    GetResultFullPathName(aValue,cValue=1000){
        VarSetCapacity(bValue, cValue*2, 0)
        ; 导出名只有 Everything_GetResultFullPathNameW
        if !dllcall(everyDLL "\Everything_GetResultFullPathNameW","int",aValue,"ptr",&bValue,"int",cValue)
            return ""
        return StrGet(&bValue, cValue, "UTF-16")
    }
}

更新ListView内容(str,分隔符:="|"){
    global 文本框ID

    ; 【核心优化】：关闭控件重绘，防止列表逐条插入时频繁刷新导致的严重卡顿
    GuiControl, -Redraw, %文本框ID%

    LV_Delete()
    Loop, parse, str, %分隔符%
    {
        if (RegExMatch(A_LoopField, "^\s*$")) ;匹配空白行
            Continue

        ; --- 新增：拆分真实路径与自定义名称 ---
        当前真实路径 := A_LoopField
        自定义名称 := ""
        if (Pos := InStr(当前真实路径, "?")) {
            自定义名称 := SubStr(当前真实路径, Pos + 1)
            当前真实路径 := SubStr(当前真实路径, 1, Pos - 1)
        }
        ; ---------------------------------------

        if (文件夹名显示在前="开启"){
            if (自定义名称 != "") {
                ; 优先使用自定义名称，隐藏列（Col 2）存写真实路径保证跳转正常
                LV_Add("", 自定义名称, 当前真实路径)
            } Else {
                ; 没写自定义名称时，走原逻辑提取文件夹名
                SplitPath, 当前真实路径, name
                if (name != "")
                    LV_Add("", name, 当前真实路径)
                Else
                    LV_Add("", 当前真实路径, 当前真实路径)
            }
        }Else {
            ; 未开启文件夹名前置功能时，仅显示真实路径（丢弃自定义名称）
            LV_Add("", 当前真实路径)
        }
    }
    if (文件夹名显示在前 ="开启")
        SetColumnWidthWithLimit(1,名称列最大宽度)
    Else
        LV_ModifyCol(1)
    LV_ModifyCol(2)

    ; 【核心优化】：数据全部添加完毕后，一次性恢复重绘
    GuiControl, +Redraw, %文本框ID%
}

; 设置列宽并限制最大值的函数
SetColumnWidthWithLimit(col, maxWidth)
{
    ; 先自动调整列宽
    LV_ModifyCol(col, "AutoHdr")
    Sleep, 10

    ; 获取当前宽度
    SendMessage, 0x101D, col-1, 0, SysListView321,%窗口标题名称% ahk_class AutoHotkeyGUI  ; 0x101D 为 LVM_GETCOLUMNWIDTH.
    currentWidth := ErrorLevel
    ;MsgBox, %currentWidth%

    ; 如果超过最大值，设置为最大值
    if (currentWidth > maxWidth)
    {
        LV_ModifyCol(col, maxWidth)
    }
}

获取选中项的值(行号){
    选择值2:=""
    if (文件夹名显示在前 ="开启")
        LV_GetText(选择值2, 行号, 2)
    Else
        LV_GetText(选择值2, 行号, 1)
    Return 选择值2
}

获取选中项的值2(){
    DelRowList:=""
    RowNumber:=0
    RowText:=""
    RowText2:=""
    Loop
    {
        RowNumber := LV_GetNext(RowNumber) ; 在前一次找到的位置后继续搜索.
        if not RowNumber ; 上面返回零, 所以选择的行已经都找到了.
            break
        DelRowList:=RowNumber . ":" . DelRowList
        zonghangshu:=A_Index + 1
    }
    loop, parse, DelRowList, :
    {
        if (zonghangshu = A_Index)
            Break
        if (文件夹名显示在前 ="开启")
            LV_GetText(RowText2, A_loopfield,2) ; 获取每行第一个字段的文本 (索引从1开始)
        Else
            LV_GetText(RowText2, A_loopfield,1) ; 获取每行第一个字段的文本 (索引从1开始)
        RowText:=RowText2 "`n" RowText
        zonghangshu2:=A_Index
    }
    Return Trim(RowText,"`n")
}

; --- 悬停提示消息处理函数 ---
WM_MOUSEMOVE(wParam, lParam, msg, hwnd){
    static PrevRow := -1
    global TargetRow, TargetHwnd

    ; 确保我们在正确的 ListView 上
    GuiControlGet, ControlName, Name, %hwnd%
    MouseGetPos, , , 获取id, 获取control
    ;MsgBox, %获取control%`n%Gui_winID%`n%获取id%
    if (ControlName != "文本框选择值1") or (获取id != Gui_winID)  or (获取control != "SysListView321"){
        ToolTip
        PrevRow := -1
        return
    }

    ; 获取当前鼠标下的行号
    VarSetCapacity(LVHITTESTINFO, 24, 0)
    NumPut(lParam & 0xFFFF, LVHITTESTINFO, 0, "Int")
    NumPut(lParam >> 16, LVHITTESTINFO, 4, "Int")
    SendMessage, 0x1039, 0, &LVHITTESTINFO, , ahk_id %hwnd% ; LVM_SUBITEMHITTEST
    Row := NumGet(LVHITTESTINFO, 12, "Int") + 1

    ; 如果行号发生变化
    if (Row != PrevRow) {
        ; 1. 立即关闭之前的计时器和 ToolTip
        SetTimer, DisplayToolTip, Off
        ToolTip

        ; 2. 如果移动到的是有效行，则开启新计时器
        if (Row > 0) {
            TargetRow := Row
            TargetHwnd := hwnd
            ; 设置延迟时间（单位：毫秒），-500 表示 500ms 后只运行一次
            SetTimer, DisplayToolTip, -%延迟悬停显示%
        }

        PrevRow := Row
    }
}

; --- 实际显示 ToolTip 的标签 ---
DisplayToolTip:
    ; 确保我们在正确的 ListView 上
    GuiControlGet, ControlName, Name, %TargetHwnd%
    MouseGetPos, , , 获取id, 获取control
    ;MsgBox, %获取control%`n%Gui_winID%`n%获取id%
    if (ControlName != "文本框选择值1") or (获取id != Gui_winID)  or (获取control != "SysListView321")
        return

    ; 获取内容并显示
    LV_GetText(Col1, TargetRow, 1)
    LV_GetText(Col2, TargetRow, 2)

    FileGetTime, OutputVar, %Col2%
    If (OutputVar)
        FormatTime, OutTime, % OutputVar, yyyy/MM/dd HH:mm:ss
    Else
        OutTime:="not found"

    ToolTip, % "名称: " Col1 "`n路径: " Col2 "`n修改时间: " OutTime
return
获取自动弹出窗口信息:
    常驻窗口窗口列表:=Var_Read("","", "窗口列表1",软件安装路径 "\个人配置.ini","是")

    WinGetTitle, WinTitle22, ahk_id %参数2%
    WinGetClass, WinClass22, ahk_id %参数2%
    WinGet, WinExe22, ProcessName, ahk_id %参数2%
    ; 格式化窗口信息
    NewEntry := WinTitle22 " ahk_class " WinClass22 " ahk_exe " WinExe22

    ; 检查是否已存在相同条目
    EntryExists_AutoPopup := false
    Loop, Parse, 常驻窗口窗口列表, `n, `r
    {
        ; 比较忽略前后空格
        if (Trim(A_LoopField) = Trim(NewEntry)){
            EntryExists_AutoPopup := true
            break
        }
    }
Return

;==================================================================================================
; 【新增】常用路径实时刷新 2026-11-07
; 右键移除/添加后立刻做三件事：重读 ini 重建内存数据、刷新当前 ListView、通知其它常驻窗口。
;==================================================================================================
重新读取分组常用路径:
    常用分组路径 := []
    loop 5
    {
        常用路径开关%A_Index% := Var_Read("常用路径开关" A_Index,"0","基础配置",软件安装路径 "\个人配置.ini","是")
        if (常用路径开关%A_Index% = "1"){
            常用路径名称%A_Index% := Var_Read("常用路径名称" A_Index,"常用" A_Index,"基础配置",软件安装路径 "\个人配置.ini","是")
            段内容 := 程序专属路径筛选(ReplaceVars(Var_Read("","","常用路径" A_Index,软件安装路径 "\个人配置.ini","是")), 参数2)
            if (替换双斜杠单反斜杠双引号 = "开启")
                段内容 := RegExReplace(StrReplace(段内容, """", ""), "\\\\|/", "\")
            常用分组路径[A_Index] := 段内容
            常用路径%A_Index% := 段内容
        }Else{
            常用路径名称%A_Index% := ""
            常用路径%A_Index% := ""
            常用分组路径[A_Index] := ""
        }
    }
Return

刷新当前列表:
    gosub, 将所有内容路径加入到数组    ; 重读 ini 主段 + 分类段
    gosub, 将所有内容路径加入到数组2   ; 重建 所有路径合集 / 合并所有路径
    if (当前视图标签 = "")
        当前视图标签 := "当前打开"
    Gosub, %当前视图标签%
    文本框内容写入 := 实时Text
    ; 若搜索框里正有关键字，重新过滤一次，避免移除后突然跳回未过滤列表
    GuiControlGet, 搜索值, , %搜索框ID%
    if (搜索值 != ""){
        Text2 := ""
        搜索上次文本 := ""   ; 清掉去重值，否则关键字没变时会被当成"重复搜索"直接跳过
        PerformSearch(搜索值, "")
    }
Return

; 向所有常驻窗口广播变更（wParam 带自己的脚本窗口句柄，接收方据此忽略自己）
广播常用变更(){
    global 常用变更消息
    if (常用变更消息)
        DllCall("user32\PostMessage", "Ptr", 0xFFFF, "UInt", 常用变更消息, "Ptr", A_ScriptHwnd, "Ptr", 0, "Int")
}

收到常用变更通知(wParam, lParam, msg, hwnd){
    global 常用变更消息
    if (msg != 常用变更消息) or (wParam = A_ScriptHwnd)
        return 0
    SetTimer, 收到后刷新常用列表, -100
    return 0
}

收到后刷新常用列表:
    SetTimer, 收到后刷新常用列表, Off
    if (参数1 != "-常驻窗口跟随") or (Gui_winID = "") or !WinExist("ahk_id " Gui_winID)
        Return
    gosub, 刷新当前列表
Return
