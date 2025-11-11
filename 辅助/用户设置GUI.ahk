#SingleInstance,Off ;关闭自带互斥功能
#NoTrayIcon ;~不显示托盘图标
#Persistent ;~让脚本持久运行
#Include %A_ScriptDir%\公用函数.ahk

FileAppend,%A_ScriptHwnd%`n,%A_Temp%\后台隐藏运行脚本记录.txt
窗口标题名:="XiaoYao_快速跳转v4.4.9"
SplitPath, A_ScriptDir,, 软件配置路径
;软件配置路径:="D:\RunAny\PortableSoft\XiaoYao_快速跳转\XiaoYao_快速跳转"

;避免重复打开
if (Single("456")) {  ;独一无二的字符串用于识别脚本,或者称为指纹?
    WinActivate, %窗口标题名% ahk_class AutoHotkeyGUI
    if not WinExist(窗口标题名 " ahk_class AutoHotkeyGUI")
        WinKill, %窗口标题名% ahk_class AutoHotkeyGUI
    Else
        ExitApp
}
Single("456")

Gosub, 读取配置
Gosub, 设置可视化

Return

读取配置:
    if FileExist(软件配置路径 "\个人配置.ini"){
        IniRead, 热键, %软件配置路径%\个人配置.ini,基础配置,热键
        IniRead, 自动弹出菜单, %软件配置路径%\个人配置.ini,基础配置,自动弹出菜单
        IniRead, 菜单背景颜色, %软件配置路径%\个人配置.ini,基础配置,菜单背景颜色
        IniRead, 延迟自动弹出时间, %软件配置路径%\个人配置.ini,基础配置,延迟自动弹出时间

        IniRead, 自定义常用路径2, %软件配置路径%\个人配置.ini,常用路径
        自定义常用路径:=ReplaceVars(自定义常用路径2)

        IniRead, 替换双斜杠单反斜杠双引号, %软件配置路径%\个人配置.ini,基础配置,替换双斜杠单反斜杠双引号
        if (替换双斜杠单反斜杠双引号="" || 替换双斜杠单反斜杠双引号="ERROR")
            替换双斜杠单反斜杠双引号:="关闭"

        IniRead, DirectoryOpus全标签路径, %软件配置路径%\个人配置.ini,基础配置,DirectoryOpus全标签路径

        IniRead, 弹出位置X坐标, %软件配置路径%\个人配置.ini,基础配置,弹出位置X坐标
        IniRead, 弹出位置Y坐标, %软件配置路径%\个人配置.ini,基础配置,弹出位置Y坐标

        IniRead, 一键跳转热键, %软件配置路径%\个人配置.ini,基础配置,一键跳转热键
        IniRead, 跳转方式, %软件配置路径%\个人配置.ini,基础配置,跳转方式
        IniRead, 保留个数, %软件配置路径%\个人配置.ini,基础配置,历史跳转保留数
        if (保留个数="" || 保留个数="ERROR")
            保留个数:="5"
        IniRead, 开机自启, %软件配置路径%\个人配置.ini,基础配置,开机自启
        if (开机自启="" || 开机自启="ERROR" || 开机自启="关闭")
            开机自启:="0"
        IniRead, DO的收藏夹, %软件配置路径%\个人配置.ini,基础配置,DO的收藏夹

        IniRead, 自动弹出常驻窗口, %软件配置路径%\个人配置.ini,基础配置,自动弹出常驻窗口
        IniRead, 常驻搜索窗口呼出热键, %软件配置路径%\个人配置.ini,基础配置,常驻搜索窗口呼出热键
        IniRead, 窗口初始坐标x, %软件配置路径%\个人配置.ini,基础配置,窗口初始坐标x
        IniRead, 窗口初始坐标y, %软件配置路径%\个人配置.ini,基础配置,窗口初始坐标y
        IniRead, 窗口初始宽度, %软件配置路径%\个人配置.ini,基础配置,窗口初始宽度
        IniRead, 窗口初始高度, %软件配置路径%\个人配置.ini,基础配置,窗口初始高度
        IniRead, 窗口背景颜色, %软件配置路径%\个人配置.ini,基础配置,窗口背景颜色
        IniRead, 窗口字体颜色, %软件配置路径%\个人配置.ini,基础配置,窗口字体颜色
        IniRead, 窗口字体名称, %软件配置路径%\个人配置.ini,基础配置,窗口字体名称
        IniRead, 窗口字体大小, %软件配置路径%\个人配置.ini,基础配置,窗口字体大小
        IniRead, 窗口透明度, %软件配置路径%\个人配置.ini,基础配置,窗口透明度

        IniRead, 失效路径显示设置, %软件配置路径%\个人配置.ini,基础配置,失效路径显示设置
        if (失效路径显示设置="" || 失效路径显示设置="ERROR")
            失效路径显示设置:="开启"

        IniRead, 文件夹名显示在前, %软件配置路径%\个人配置.ini,基础配置,文件夹名显示在前
        if (文件夹名显示在前="" || 文件夹名显示在前="ERROR")
            文件夹名显示在前:="关闭"

        IniRead, 菜单全局热键, %软件配置路径%\个人配置.ini,基础配置,菜单全局热键
        IniRead, 常驻窗口全局热键, %软件配置路径%\个人配置.ini,基础配置,常驻窗口全局热键
        IniRead, 全局性菜单项功能, %软件配置路径%\个人配置.ini,基础配置,全局性菜单项功能
        IniRead, 初始文本框内容, %软件配置路径%\个人配置.ini,基础配置,初始文本框内容
        IniRead, 是否加载图标, %软件配置路径%\个人配置.ini,基础配置,是否加载图标

        IniRead, 常用路径最多显示数量, %软件配置路径%\个人配置.ini,基础配置,常用路径最多显示数量
        if (常用路径最多显示数量="" || 常用路径最多显示数量="ERROR")
            常用路径最多显示数量:="9"

        IniRead, 常驻窗口窗口列表, %软件配置路径%\个人配置.ini,窗口列表1
        if (常驻窗口窗口列表="" || 常驻窗口窗口列表="ERROR"){
            常驻窗口窗口列表:="
(
选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe
选择 ahk_class #32770 ahk_exe Bandizip.exe
解压路径和选项 ahk_class #32770 ahk_exe WinRAR.exe
选择目标文件夹 ahk_class #32770 ahk_exe dopus.exe
)"
        }

        IniRead, 屏蔽xiaoyao窗口列表,%软件配置路径%\个人配置.ini,窗口列表2
        if (屏蔽xiaoyao窗口列表="" || 屏蔽xiaoyao窗口列表="ERROR"){
            屏蔽xiaoyao窗口列表:="
(
ahk_exe IDMan.exe
)"
        }

        IniRead, 屏蔽xiaoyao程序列表,%软件配置路径%\个人配置.ini,基础配置,屏蔽xiaoyao程序列表
        if (屏蔽xiaoyao程序列表="" || 屏蔽xiaoyao程序列表="ERROR")
            屏蔽xiaoyao程序列表:="War3.exe,dota2.exe,League of Legends.exe"

        IniRead, 窗口文本行距, %软件配置路径%\个人配置.ini,基础配置,窗口文本行距
        if (窗口文本行距="" || 窗口文本行距="ERROR")
            窗口文本行距:= "20"

        IniRead, 隐藏软件托盘图标, %软件配置路径%\个人配置.ini,基础配置,隐藏软件托盘图标
        if (隐藏软件托盘图标="" || 隐藏软件托盘图标="ERROR")
            隐藏软件托盘图标:= "关闭"
        IniRead, 手动弹出计数,  %软件配置路径%\个人配置.ini,基础配置,手动弹出计数
        if (手动弹出计数="" || 手动弹出计数="ERROR")
            手动弹出计数:= "0"
        IniRead, 自动弹出菜单计数,  %软件配置路径%\个人配置.ini,基础配置,自动弹出菜单计数
        if (自动弹出菜单计数="" || 自动弹出菜单计数="ERROR")
            自动弹出菜单计数:= "0"
        IniRead, 自动弹出常驻窗口次数, %软件配置路径%\个人配置.ini,基础配置,自动弹出常驻窗口次数
        if (自动弹出常驻窗口次数="" || 自动弹出常驻窗口次数="ERROR")
            自动弹出常驻窗口次数:= "0"

        IniRead, 自动跳转到默认路径, %软件配置路径%\个人配置.ini,基础配置,自动跳转到默认路径
        if (自动跳转到默认路径="" || 自动跳转到默认路径="ERROR")
            自动跳转到默认路径:= "关闭"
        IniRead, 历史路径设为默认路径, %软件配置路径%\个人配置.ini,基础配置,历史路径设为默认路径
        if (历史路径设为默认路径="" || 历史路径设为默认路径="ERROR")
            历史路径设为默认路径:= "关闭"

        IniRead, 默认路径, %软件配置路径%\个人配置.ini,基础配置,默认路径
        if (默认路径="ERROR")
            默认路径:= ""

        IniRead, 管理员启动,%软件配置路径%\个人配置.ini,基础配置,管理员启动
        if !(管理员启动="关闭")
            管理员启动:="开启"
    }
Return

设置可视化:

    Auto_Launch:=开机自启
    Auto_Launch:= Auto_Launch="0"?0:1

    自动弹出:=自动弹出菜单
    自动弹出:= 自动弹出="关闭"?0:1

    ;自动弹出常驻窗口:=自动弹出常驻窗口
    自动弹出常驻窗口:= 自动弹出常驻窗口="关闭"?0:1

    隐藏软件托盘图标:= 隐藏软件托盘图标="关闭"?0:1

    文件夹名显示在前:= 文件夹名显示在前="关闭"?0:1

    是否加载图标:= 是否加载图标="关闭"?0:1

    全局性菜单项功能:= 全局性菜单项功能="直接打开"?0:1

    自动跳转到默认路径:= 自动跳转到默认路径="关闭"?0:1
    历史路径设为默认路径:= 历史路径设为默认路径="关闭"?0:1

    失效路径显示设置:= 失效路径显示设置="关闭"?0:1

    替换双斜杠单反斜杠双引号:= 替换双斜杠单反斜杠双引号="关闭"?0:1

    管理员启动:= 管理员启动="关闭"?0:1

    DO全标签:=DirectoryOpus全标签路径
    DO全标签:= DO全标签="关闭"?0:1
    跳转方式1:=跳转方式
    跳转方式1 := 跳转方式1="1"?0:跳转方式1="2"?1:跳转方式1="3"?2:跳转方式1="4"?3:跳转方式1="5"?4:3
    自动弹出时间:=延迟自动弹出时间
    X坐标:=弹出位置X坐标
    Y坐标:=弹出位置Y坐标
    历史打开数量:=保留个数
    菜单颜色:=菜单背景颜色
    热键1:=热键
    热键2:=一键跳转热键

    IniRead, 自定义常用路径2, %软件配置路径%\个人配置.ini,常用路径
    常用路径1:=自定义常用路径2

    DO收藏夹1:=DO的收藏夹
    DO收藏夹1:= DO收藏夹1="关闭"?0:1

    OnOffState := "关闭|开启"
    OnOffState2 := "直接打开|复制到剪切板"
    Gui_width_55 := 450
    tab_width_55 := Gui_width_55-20
    group_width_55 := tab_width_55-20
    global group_list_width_55 := tab_width_55-40
    text_width := 110
    left_margin := 10

    Gui, 55:Destroy

    Gui, 55:Default
    Gui, 55:+HwndGui_winID
    FileAppend,%Gui_winID%`n,%A_Temp%\后台隐藏运行脚本记录.txt

    Gui,55:Add, Tab3,x0, 设置|常驻跟随窗口|窗口设置|高级设置|关于

    Gui, 55:Margin, 20, 20
    Gui, 55:Font, W400, Microsoft YaHei

    Gui,55:Tab,设置,,Exact

    Gui, 55:Add, Text, xm+%left_margin% yp+55 cred, 开机自启
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vAuto_Launch, %OnOffState%
    GuiControl, Choose, Auto_Launch,% Auto_Launch+1

    Gui, 55:Add, Text, x+57 yp+2 cred, 管理员启动:
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v管理员启动, %OnOffState%
    GuiControl, Choose, 管理员启动, % 管理员启动+1

    Gui, 55:Add, GroupBox, xm y+10 w%group_width_55% h93, 菜单 热键配置【仅对话框生效】
    Gui, 55:Add, Text, xm+%left_margin% yp+25, 呼出菜单
    Gui, 55:Add, Hotkey, x+5 yp+2 w%text_width% v热键1, %热键1%
    Gui, 55:Add, Text, x+65 yp-2, 一键跳转
    Gui, 55:Add, Hotkey, x+5 yp+2 w%text_width% v热键2, %热键2%

    Gui, 55:Add, Text, xm+%left_margin% yp+35, 全局呼出菜单[可与局部热键相同]:(仅复制到剪切板)
    Gui, 55:Add, Hotkey, x+10 yp+2 w%text_width% v菜单全局热键, %菜单全局热键%

    Gui, 55:Add, GroupBox, xm y+10 w%group_width_55% h210, 菜单【更多】设置

    Gui, 55:Add, Text, xm+%left_margin% yp+25, 自动弹出时间
    Gui, 55:Add, Edit, x+5 yp-2 w60 h25 v自动弹出时间, %自动弹出时间%
    Gui, 55:Add, Text, x+10 yp+2, 毫秒

    Gui, 55:Add, Text, x+58 yp+2, 常用路径显示数量
    Gui, 55:Add, Edit, x+5 yp-2 w60 h25 v常用路径最多显示数量, %常用路径最多显示数量%
    Gui, 55:Add, Text, xm+%left_margin% yp+40, 菜单颜色
    Gui, 55:Add, Edit, x+5 yp-2 w60 h25 v菜单颜色, %菜单颜色%

    Gui, 55:Add, Text, x+45 yp+2, 菜单弹出位置 X:
    Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vX坐标, %X坐标%
    Gui, 55:Add, Text, x+5 yp, Y:
    Gui, 55:Add, Edit, x+5 yp-2 w60 h25 vY坐标, %Y坐标%

    Gui, 55:Add, Text, xm+%left_margin% yp+40, 自动弹出菜单
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v自动弹出, %OnOffState%
    GuiControl, Choose, 自动弹出, % 自动弹出+1

    Gui, 55:Add, Text, xm+%left_margin% yp+40, 是否加载图标
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v是否加载图标, %OnOffState%
    GuiControl, Choose, 是否加载图标,% 是否加载图标+1

    Gui, 55:Add, GroupBox, xm y+50 w%group_width_55% h190, 常用路径设置【支持ahk内置变量 写法：`%A_Desktop`%】
    Gui, 55:Add, Text,Cblue x375 yp w70 g打开使用文档, 更多写法:

    Gui, 55:Add, Edit, xm+%left_margin% yp+20 w400 r9 v常用路径1, %常用路径1%

    Gui, 55:Add, Button, Default w75 x95 y600 G设置ok, 确定
    Gui, 55:Add, Button, w75 x+20 yp G取消ok, 取消
    Gui, 55:Add, Button, w75 x+20 yp G重置ok, 恢复默认
    Gui, 55:Add, Text, Cblue x+20 yp+5  G打开设置2, 配置文件
    ;Gui, wenjianpl: Add, Edit, w400 vThirdVar2, %filebatch5%
    ;-------------------------------------------------------------------------
    Gui,55:Tab,常驻跟随窗口,,Exact
    距离最左边的长度:="10"
    距离最上边的长度:="40"

    ;第一排
    Gui, 55:Add, Text, xm+%距离最左边的长度% ym+%距离最上边的长度% cred, 自动弹出常驻
    Gui, 55:Add, DropDownList, x+5 ym+%距离最上边的长度% w%text_width% v自动弹出常驻窗口, %OnOffState%
    GuiControl, Choose, 自动弹出常驻窗口,% 自动弹出常驻窗口+1

    Gui, 55:Add, Text, x+20 yp+2 cred, 目录名在前
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v文件夹名显示在前, %OnOffState%
    GuiControl, Choose, 文件夹名显示在前, % 文件夹名显示在前+1

    ;第二排
    Gui, 55:Add, GroupBox, xm y+10 w%group_width_55% h93, 热键配置【仅对话框生效】
    Gui, 55:Add, Text, xm+%left_margin% yp+25, 呼出常驻
    Gui, 55:Add, Hotkey, x+5 yp+2 w%text_width% v常驻搜索窗口呼出热键2, %常驻搜索窗口呼出热键%
    Gui, 55:Add, Text, xm+%left_margin% yp+35, 全局呼出常驻[可与局部热键相同]:(仅复制到剪切板)
    Gui, 55:Add, Hotkey, x+5 yp+2 w%text_width% v常驻窗口全局热键, %常驻窗口全局热键%

    ;第三排
    Gui, 55:Add, GroupBox, xm y+10 w%group_width_55% h120, 【窗口坐标】设置

    Gui, 55:Add, Text, xm+%left_margin% yp+25, 坐标可用参数：父窗口X 父窗口Y 父窗口W 父窗口H 鼠标位置X 鼠标位置Y

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 窗口初始坐标x：
    Gui, 55:Add, Edit, x+5 yp-2 w200 h25 v窗口初始坐标x2, %窗口初始坐标x%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 窗口初始坐标y：
    Gui, 55:Add, Edit, x+5 yp-2 w200 h25 v窗口初始坐标y2, %窗口初始坐标y%

    Gui, 55:Add, GroupBox, xm y+20 w%group_width_55% h230, 【更多】设置
    Gui, 55:Add, Text, xm+%left_margin% yp+25, 初始宽度：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口初始宽度2, %窗口初始宽度%

    Gui, 55:Add, Text, x+20 yp+2, 文本行距：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口文本行距, %窗口文本行距%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 初始高度：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口初始高度2, %窗口初始高度%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 背景颜色：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口背景颜色2, %窗口背景颜色%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 字体颜色：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口字体颜色2, %窗口字体颜色%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 字体名称：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口字体名称2, %窗口字体名称%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 字体大小：
    Gui, 55:Add, Edit, x+5 yp-2 w120 h25 v窗口字体大小2, %窗口字体大小%

    Gui, 55:Add, Text, xm+%left_margin% yp+30, 透明度：
    Gui, 55:Add, Edit, x+17 yp-2 w120 h25 v窗口透明度2, %窗口透明度%

    Gui, 55:Add, Text, xm+%left_margin% yp+45 cred, 初始文本框的内容:
    if (初始文本框内容="" || 初始文本框内容="ERROR")
        初始文本框内容:="当前打开"
    Gui, 55:Add, ComboBox, x+5 yp-2 w%text_width% v初始文本框内容, %初始文本框内容%||当前打开|常用路径|历史打开|全部路径|do收藏夹

    Gui, 55:Add, Button, Default w75 x95 y600 G设置ok, 确定
    Gui, 55:Add, Button, w75 x+20 yp G取消ok, 取消
    Gui, 55:Add, Button, w75 x+20 yp G重置ok, 恢复默认
    Gui, 55:Add, Text, Cblue x+20 yp+5  G打开设置2, 配置文件

    Gui,55:Tab,窗口设置,,Exact
    Gui, 55:Add, GroupBox, x10 ym+%距离最上边的长度% cred w420 h215, 窗口列表[自动弹出]
    Gui, 55:Add, Button, x340 ym+%距离最上边的长度% w80 g添加窗口到列表, 添加

    Gui, 55:Add, Edit, xm yp+30 w400 r9 HScroll -Wrap v常驻窗口窗口列表, %常驻窗口窗口列表%

    Gui, 55:Add, GroupBox, x10 ym+260 cred w420 h215, 窗口列表2[屏蔽自动弹出]
    Gui, 55:Add, Button, x340 ym+260 w80 g添加窗口到列表2, 添加

    Gui, 55:Add, Edit, xm yp+30 w400 r9 HScroll -Wrap v窗口列表2, %屏蔽xiaoyao窗口列表%

    Gui, 55:Add, GroupBox, x10 ym+475 cred w420 h100, 屏蔽xiaoyao程序列表(英文逗号隔开)
    Gui, 55:Add, Edit, xm yp+25 w400 h70 v屏蔽xiaoyao程序列表, %屏蔽xiaoyao程序列表%

    Gui, 55:Add, Button, Default w75 x95 y600 G设置ok, 确定
    Gui, 55:Add, Button, w75 x+20 yp G取消ok, 取消
    Gui, 55:Add, Button, w75 x+20 yp G重置ok, 恢复默认
    Gui, 55:Add, Text, Cblue x+20 yp+5  G打开设置2, 配置文件

    Gui,55:Tab,高级设置,,Exact
    ;第一排
    Gui, 55:Add, GroupBox,  x20 ym+%距离最上边的长度% h122 w410, 【默认路径】设置 (第一次打开对话框会自动跳转到默认路径)

    Gui, 55:Add, Text, xm+%left_margin% yp+25, 自动跳转到默认路径
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v自动跳转到默认路径, %OnOffState%
    GuiControl, Choose, 自动跳转到默认路径, % 自动跳转到默认路径+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35, 将历史路径设为默认
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v历史路径设为默认路径, %OnOffState%
    GuiControl, Choose, 历史路径设为默认路径, % 历史路径设为默认路径+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35, 设置默认路径:
    Gui, 55:Add, Edit, x+5 yp-2 w310 h25 v默认路径, %默认路径%

    Gui, 55:Add, Text, xm+%left_margin% yp+45 , DO全标签:(关闭后只获取当前标签路径)
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vDO全标签, %OnOffState%
    GuiControl, Choose, DO全标签, % DO全标签+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35 , DO收藏夹:(部分收藏需先打开 DO获取)
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% vDO收藏夹1, %OnOffState%
    GuiControl, Choose, DO收藏夹1, % DO收藏夹1+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35 , 历史打开数量:(最近跳转路径的个数上限)
    Gui, 55:Add, Edit, x+5 yp-2 w50 h25 v历史打开数量, %历史打开数量%

    Gui, 55:Add, Text, xm+%left_margin% yp+35 , 隐藏软件托盘图标[慎改]:可通过编辑 个人配置.ini 恢复
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v隐藏软件托盘图标, %OnOffState%
    GuiControl, Choose, 隐藏软件托盘图标,% 隐藏软件托盘图标+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35 , 失效路径显示(关闭后失效路径将不显示)
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v失效路径显示设置, %OnOffState%
    GuiControl, Choose, 失效路径显示设置, % 失效路径显示设置+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35 , 常用路径：替换\\和/为\并删除双引号
    Gui, 55:Add, DropDownList, x+5 yp-4 w%text_width% v替换双斜杠单反斜杠双引号, %OnOffState%
    GuiControl, Choose, 替换双斜杠单反斜杠双引号, % 替换双斜杠单反斜杠双引号+1

    Gui, 55:Add, Text, xm+%left_margin% yp+35, 全局点击功能:
    Gui, 55:Add, DropDownList, x+5 yp-4 w%text_width% v全局性菜单项功能, %OnOffState2%
    GuiControl, Choose, 全局性菜单项功能,% 全局性菜单项功能+1

    Gui, 55:Add, Text, x+48 yp+2, 跳转方式:
    Gui, 55:Add, DropDownList, x+5 yp-2 w%text_width% v跳转方式1, 1|2|3|4|5
    GuiControl, Choose, 跳转方式1, % 跳转方式1+1

    Gui, 55:Add, Button, Default w75 x95 y600 G设置ok, 确定
    Gui, 55:Add, Button, w75 x+20 yp G取消ok, 取消
    Gui, 55:Add, Button, w75 x+20 yp G重置ok, 恢复默认
    Gui, 55:Add, Text, Cblue x+20 yp+5  G打开设置2, 配置文件

    Gui,55:Tab,关于,,Exact
    Gui, 55:Add, Text, xm+%距离最左边的长度% ym+%距离最上边的长度% cblue, 作者：逍遥  https://github.com/lch319/XiaoYao_QuickJump
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+40 cblue, 在打开或保存对话框中，快速定位到当前打开的文件夹路径
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+25 cblue, 支持 DO、TC、XY、Q-Dir、Win11资源管理器
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+40 cblue, QQ交流群:246308937(答案:RunAny)

    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+40 cblue, 致谢名单：
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+20 cblue, https://github.com/hui-Zz/RunAny
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+20 cblue, https://github.com/gepruts/QuickSwitch
    Gui, 55:Add, Text, xm+%距离最左边的长度% yp+20 cblue, https://www.autohotkey.com/boards/viewtopic.php?f=6&t=124771

    Gui, 55:Add, Text, xm+%距离最左边的长度% y500 cgreen, XiaoYao_快速跳转[使用统计]：重启后刷新
    Gui, 55:Add, Text, xm+20 yp+20, 自动弹出常驻窗口次数：%自动弹出常驻窗口次数%
    Gui, 55:Add, Text, xm+20 yp+20, 自动弹出菜单次数：%自动弹出菜单计数%
    Gui, 55:Add, Text, xm+20 yp+20, 手动弹出菜单和常驻次数：%手动弹出计数%
    总次数:=自动弹出常驻窗口次数+自动弹出菜单计数+手动弹出计数
    Gui, 55:Add, Text, xm+20 yp+20, 总次数：%总次数%

    GuiTitleContent := A_IsAdmin=1?"（管理员）":"（非管理员）"
    Gui,55: Show,w%Gui_width_55%,%窗口标题名%%GuiTitleContent%

Return

设置ok:
    Critical On
    Thread, NoTimers,True
    Gui,55:Submit
    IniWrite, %热键1%, %软件配置路径%\个人配置.ini,基础配置,热键
    IniWrite, %自动弹出%, %软件配置路径%\个人配置.ini,基础配置,自动弹出菜单
    IniWrite, %菜单颜色%, %软件配置路径%\个人配置.ini,基础配置,菜单背景颜色
    IniWrite, %自动弹出时间%, %软件配置路径%\个人配置.ini,基础配置,延迟自动弹出时间
    IniDelete, %软件配置路径%\个人配置.ini,常用路径
    IniWrite, %常用路径1%, %软件配置路径%\个人配置.ini,常用路径
    IniWrite, %DO全标签%, %软件配置路径%\个人配置.ini,基础配置,DirectoryOpus全标签路径
    IniWrite, %X坐标%, %软件配置路径%\个人配置.ini,基础配置,弹出位置X坐标
    IniWrite, %Y坐标%, %软件配置路径%\个人配置.ini,基础配置,弹出位置Y坐标
    IniWrite, %热键2%, %软件配置路径%\个人配置.ini,基础配置,一键跳转热键
    IniWrite, %跳转方式1%, %软件配置路径%\个人配置.ini,基础配置,跳转方式
    IniWrite, %历史打开数量%, %软件配置路径%\个人配置.ini,基础配置,历史跳转保留数
    IniWrite, %Auto_Launch%, %软件配置路径%\个人配置.ini,基础配置,开机自启
    IniWrite, %DO收藏夹1%, %软件配置路径%\个人配置.ini,基础配置,DO的收藏夹

    IniWrite, %自动弹出常驻窗口%, %软件配置路径%\个人配置.ini,基础配置,自动弹出常驻窗口
    IniWrite, %常驻搜索窗口呼出热键2%, %软件配置路径%\个人配置.ini,基础配置,常驻搜索窗口呼出热键
    IniWrite, %窗口初始坐标x2%, %软件配置路径%\个人配置.ini,基础配置,窗口初始坐标x
    IniWrite, %窗口初始坐标y2%, %软件配置路径%\个人配置.ini,基础配置,窗口初始坐标y
    IniWrite, %窗口初始宽度2%, %软件配置路径%\个人配置.ini,基础配置,窗口初始宽度
    IniWrite, %窗口初始高度2%, %软件配置路径%\个人配置.ini,基础配置,窗口初始高度
    IniWrite, %窗口背景颜色2%, %软件配置路径%\个人配置.ini,基础配置,窗口背景颜色
    IniWrite, %窗口字体颜色2%, %软件配置路径%\个人配置.ini,基础配置,窗口字体颜色
    IniWrite, %窗口字体名称2%, %软件配置路径%\个人配置.ini,基础配置,窗口字体名称
    IniWrite, %窗口字体大小2%, %软件配置路径%\个人配置.ini,基础配置,窗口字体大小
    IniWrite, %窗口透明度2%, %软件配置路径%\个人配置.ini,基础配置,窗口透明度
    IniWrite, %失效路径显示设置%, %软件配置路径%\个人配置.ini,基础配置,失效路径显示设置

    IniWrite, %文件夹名显示在前%, %软件配置路径%\个人配置.ini,基础配置,文件夹名显示在前

    IniWrite, %菜单全局热键%, %软件配置路径%\个人配置.ini,基础配置,菜单全局热键
    IniWrite, %常驻窗口全局热键%, %软件配置路径%\个人配置.ini,基础配置,常驻窗口全局热键
    IniWrite, %全局性菜单项功能%, %软件配置路径%\个人配置.ini,基础配置,全局性菜单项功能
    IniWrite, %初始文本框内容%, %软件配置路径%\个人配置.ini,基础配置,初始文本框内容
    IniWrite, %是否加载图标%, %软件配置路径%\个人配置.ini,基础配置,是否加载图标
    IniWrite, %常用路径最多显示数量%, %软件配置路径%\个人配置.ini,基础配置,常用路径最多显示数量

    IniDelete, %软件配置路径%\个人配置.ini,窗口列表1
    IniWrite, %常驻窗口窗口列表%, %软件配置路径%\个人配置.ini,窗口列表1

    IniDelete, %软件配置路径%\个人配置.ini,窗口列表2
    IniWrite, %窗口列表2%, %软件配置路径%\个人配置.ini,窗口列表2

    IniWrite, %屏蔽xiaoyao程序列表%, %软件配置路径%\个人配置.ini,基础配置,屏蔽xiaoyao程序列表

    IniWrite, %窗口文本行距%, %软件配置路径%\个人配置.ini,基础配置,窗口文本行距
    IniWrite, %隐藏软件托盘图标%, %软件配置路径%\个人配置.ini,基础配置,隐藏软件托盘图标

    IniWrite, %自动跳转到默认路径%, %软件配置路径%\个人配置.ini,基础配置,自动跳转到默认路径
    IniWrite, %历史路径设为默认路径%, %软件配置路径%\个人配置.ini,基础配置,历史路径设为默认路径
    IniWrite, %默认路径%, %软件配置路径%\个人配置.ini,基础配置,默认路径
    IniWrite, %替换双斜杠单反斜杠双引号%, %软件配置路径%\个人配置.ini,基础配置,替换双斜杠单反斜杠双引号
    IniWrite, %管理员启动%, %软件配置路径%\个人配置.ini,基础配置,管理员启动

    gosub, Menu_Reload
Return

重置ok:
    MsgBox, 49, 确认重置吗？
    IfMsgBox Ok
    {
        Gui,Destroy
        FileDelete, %软件配置路径%\个人配置.ini
        FileCopy, %软件配置路径%\ICO\默认.ini, %软件配置路径%\个人配置.ini
        Sleep, 1000
        gosub, Menu_Reload
    }
return
打开设置2:
    if FileExist(软件配置路径 "\个人配置.ini")
        run,%软件配置路径%\个人配置.ini
    Else
        run,%软件配置路径%
return

打开使用文档:
    if FileExist(软件配置路径 "\ICO\常用路径写法说明.txt")
        run,%软件配置路径%\ICO\常用路径写法说明.txt
    Else
        run,%软件配置路径%
return

添加窗口到列表:
    gosub,添加窗口到列表公共部分
    ; 检查是否已存在相同条目
    GuiControlGet, CurrentList,, 常驻窗口窗口列表
    EntryExists := false
    Loop, Parse, CurrentList, `n
    {
        ; 比较忽略前后空格
        if (Trim(A_LoopField) = Trim(NewEntry)){
            EntryExists := true
            break
        }
    }
    Gui,55: show
    if (!EntryExists){
        ; 添加到编辑框
        NewList := CurrentList ? CurrentList "`n" NewEntry : NewEntry
        GuiControl,, 常驻窗口窗口列表, %NewList%
    }else{
        MsgBox, 64, 提示, 该窗口已存在列表中！, 2
    }

return

添加窗口到列表2:
    gosub,添加窗口到列表公共部分
    ; 检查是否已存在相同条目
    GuiControlGet, CurrentList,, 窗口列表2
    EntryExists := false
    Loop, Parse, CurrentList, `n
    {
        ; 比较忽略前后空格
        if (Trim(A_LoopField) = Trim(NewEntry)){
            EntryExists := true
            break
        }
    }
    Gui,55: show
    if (!EntryExists){
        ; 添加到编辑框
        NewList := CurrentList ? CurrentList "`n" NewEntry : NewEntry
        GuiControl,, 窗口列表2, %NewList%
    }else{
        MsgBox, 64, 提示, 该窗口已存在列表中！, 2
    }
return

添加窗口到列表公共部分:
    ToolTip, 请左键点击目标窗口...
    Gui,55: Hide
    KeyWait, LButton, D
    MouseGetPos,,, 获取WinID
    WinGetTitle, WinTitle22, ahk_id %获取WinID%
    WinGetClass, WinClass22, ahk_id %获取WinID%
    WinGet, WinExe22, ProcessName, ahk_id %获取WinID%
    ToolTip
    ; 格式化窗口信息
    NewEntry := WinTitle22 " ahk_class " WinClass22 " ahk_exe " WinExe22
return

Menu_Reload:
    Critical
    FileDelete, %A_Temp%\常驻窗口关闭记录.txt
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    ;Run,%A_AhkPath% /force /restart "%软件配置路径%"
    run,"%软件配置路径%\XiaoYao_快速跳转.exe" "%软件配置路径%\主程序.ahk"
ExitApp
return

55GuiClose:
取消ok:
ExitApp
return

RemoveToolTip:
    ToolTip
return