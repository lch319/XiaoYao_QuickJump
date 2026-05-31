;====================================================================================
;仿Listary_C+G 列出打开的路径 （支持文件管理器、Directory Opus、 TC）最后更新：20251227
;代码借鉴 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102377
;====================================================================================
#NoEnv
#Persistent ;~让脚本持久运行
#SingleInstance,Force ;~运行替换旧实例
#Include %A_ScriptDir%\辅助\公用函数.ahk

SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

软件版本号:="4.5.8"

;如果配置不存在，新建一个默认配置
if not FileExist(A_ScriptDir "\个人配置.ini")
    FileCopy,%A_ScriptDir%\ICO\默认.ini, %A_ScriptDir%\个人配置.ini

;判断是否管理员启动
Gosub, Label_AdminLaunch

;清除辅助脚本进程
FileRead,后台隐藏运行脚本记录,%A_Temp%\后台隐藏运行脚本记录.txt
Loop, parse, 后台隐藏运行脚本记录, `n, `r
{
    WinKill,ahk_id %A_LoopField%
}
FileDelete, %A_Temp%\后台隐藏运行脚本记录.txt

run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\辅助\解决菜单不消失.ahk"

;------------------ 读取配置 ------------------
热键:="^g"
自动弹出菜单:="开启"
菜单背景颜色:=""
延迟自动弹出时间:="250"
自定义常用路径:=A_Desktop "`n" A_MyDocuments
开机自启:="0"
global 全局变量11:="0"

global DO的收藏夹
global do收藏夹所有路径
global 全局性菜单
global processList:="ahk_class #32770"

global 全局历史跳转
FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini

热键:=Var_Read("热键","","基础配置",A_ScriptDir "\个人配置.ini","否")
自动弹出菜单:=Var_Read("自动弹出菜单","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
自动跳转到文件管理器路径:=Var_Read("自动跳转到文件管理器路径","关闭","基础配置",A_ScriptDir "\个人配置.ini","否")
菜单背景颜色:=Var_Read("菜单背景颜色","","基础配置",A_ScriptDir "\个人配置.ini","是")
global 延迟自动弹出时间:=Var_Read("延迟自动弹出时间","100","基础配置",A_ScriptDir "\个人配置.ini","是")

自定义常用路径2:=Var_Read("","","常用路径",A_ScriptDir "\个人配置.ini","是")
自定义常用路径2:=ReplaceVars(自定义常用路径2)

替换双斜杠单反斜杠双引号:=Var_Read("替换双斜杠单反斜杠双引号","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
if (替换双斜杠单反斜杠双引号="开启"){
    自定义常用路径2:=RegExReplace(StrReplace(自定义常用路径2, """", ""), "\\\\|/", "\")
}

DirectoryOpus全标签路径:=Var_Read("DirectoryOpus全标签路径","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
弹出位置X坐标:=Var_Read("弹出位置X坐标","","基础配置",A_ScriptDir "\个人配置.ini","是")
弹出位置Y坐标:=Var_Read("弹出位置Y坐标","","基础配置",A_ScriptDir "\个人配置.ini","是")

一键跳转热键:=Var_Read("一键跳转热键","","基础配置",A_ScriptDir "\个人配置.ini","否")
跳转方式:=Var_Read("跳转方式","1","基础配置",A_ScriptDir "\个人配置.ini","是")
保留个数:=Var_Read("历史跳转保留数","5","基础配置",A_ScriptDir "\个人配置.ini","是")
开机自启:=Var_Read("开机自启","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")

DO的收藏夹:=Var_Read("DO的收藏夹","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
if (DO的收藏夹="开启")
    do收藏夹所有路径:=DirectoryOpusgetfa()

自动弹出常驻窗口:=Var_Read("自动弹出常驻窗口","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
常驻搜索窗口呼出热键:=Var_Read("常驻搜索窗口呼出热键","","基础配置",A_ScriptDir "\个人配置.ini","否")
窗口初始坐标x:=Var_Read("窗口初始坐标x","父窗口X + 父窗口W","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口初始坐标y:=Var_Read("窗口初始坐标y","父窗口Y + 20","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口初始宽度:=Var_Read("窗口初始宽度","300","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口初始高度:=Var_Read("窗口初始高度","360","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口背景颜色:=Var_Read("窗口背景颜色","","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口字体颜色:=Var_Read("窗口字体颜色","","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口字体名称:=Var_Read("窗口字体名称","","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口字体大小:=Var_Read("窗口字体大小","9","基础配置",A_ScriptDir "\个人配置.ini","是")
窗口透明度:=Var_Read("窗口透明度","245","基础配置",A_ScriptDir "\个人配置.ini","是")
失效路径显示设置:=Var_Read("失效路径显示设置","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
文件夹名显示在前:=Var_Read("文件夹名显示在前","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
菜单全局热键:=Var_Read("菜单全局热键","","基础配置",A_ScriptDir "\个人配置.ini","否")
常驻窗口全局热键:=Var_Read("常驻窗口全局热键","","基础配置",A_ScriptDir "\个人配置.ini","否")
全局性菜单项功能:=Var_Read("全局性菜单项功能","复制到剪切板","基础配置",A_ScriptDir "\个人配置.ini","是")
初始文本框内容:=Var_Read("初始文本框内容","当前打开","基础配置",A_ScriptDir "\个人配置.ini","是")
是否加载图标:=Var_Read("是否加载图标","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
常用路径最多显示数量:=Var_Read("常用路径最多显示数量","9","基础配置",A_ScriptDir "\个人配置.ini","是")
屏蔽xiaoyao程序列表:=Var_Read("屏蔽xiaoyao程序列表","War3.exe,dota2.exe,League of Legends.exe","基础配置",A_ScriptDir "\个人配置.ini","是")
深浅主题切换:=Var_Read("深浅主题切换","跟随系统","基础配置",A_ScriptDir "\个人配置.ini","是")
global 只显示文件夹名:=Var_Read("只显示文件夹名","关闭","基础配置",A_ScriptDir "\个人配置.ini","是") ; 【新增配置项】

默认常驻窗口窗口列表:="
(
选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe
选择 ahk_class #32770 ahk_exe Bandizip.exe
解压路径和选项 ahk_class #32770 ahk_exe WinRAR.exe
选择目标文件夹 ahk_class #32770 ahk_exe dopus.exe
)"
常驻窗口窗口列表:=Var_Read("",默认常驻窗口窗口列表,"窗口列表1",A_ScriptDir "\个人配置.ini","是")

;----------------黑名单窗列表读取-----------
屏蔽xiaoyao窗口列表:=Var_Read("","ahk_exe IDMan.exe","窗口列表2",A_ScriptDir "\个人配置.ini","是")

;解析窗口列表到数组
windows2 := []
Loop, Parse, 屏蔽xiaoyao窗口列表, `n, `r
{
    if not (RegExMatch(A_LoopField, "^\s*$"))
        windows2.Push(Trim(A_LoopField))
}
Loop, Parse, 屏蔽xiaoyao程序列表, `,
{
    if not (RegExMatch(A_LoopField, "^\s*$"))
        windows2.Push(Trim("ahk_exe " A_LoopField))
}
;----------------黑名单窗列表读取-----------

窗口文本行距:=Var_Read("窗口文本行距","20","基础配置",A_ScriptDir "\个人配置.ini","是")
隐藏软件托盘图标:=Var_Read("隐藏软件托盘图标","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
手动弹出计数:=Var_Read("手动弹出计数","0","基础配置",A_ScriptDir "\个人配置.ini","是")
自动弹出菜单计数:=Var_Read("自动弹出菜单计数","0","基础配置",A_ScriptDir "\个人配置.ini","是")
给dc发送热键:=Var_Read("给dc发送热键","^+{F12}","基础配置",A_ScriptDir "\个人配置.ini","是")
global 不存在时新建:=Var_Read("不存在时新建","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")

loop 5
{
    常用路径开关%A_Index%:= Var_Read("常用路径开关" A_Index,"0","基础配置",A_ScriptDir "\个人配置.ini","是")
    if (常用路径开关%A_Index%="1"){
        常用路径名称%A_Index%:= Var_Read("常用路径名称" A_Index,"常用" A_Index,"基础配置",A_ScriptDir "\个人配置.ini","是")
        常用路径%A_Index%:= ReplaceVars(Var_Read("","","常用路径" A_Index,A_ScriptDir "\个人配置.ini","是"))
        if (替换双斜杠单反斜杠双引号="开启"){
            常用路径%A_Index%:=RegExReplace(StrReplace(常用路径%A_Index%, """", ""), "\\\\|/", "\")
        }
    }Else{
        常用路径名称%A_Index%:= ""
        常用路径%A_Index%:=""
    }
}

;------------------ 读取配置终止线 ----------------

if (隐藏软件托盘图标="开启"){
    Menu, Tray, NoIcon
}
if not FileExist(A_ScriptDir "\ICO\历史跳转.ini")
    FileAppend, ,%A_ScriptDir%\ICO\历史跳转.ini

if (开机自启="开启")
    开机自启:="1"
Else
    开机自启:="0"

Label_AutoRun(开机自启)
;------------------ 托盘右键菜单设置 ----------------
Menu,Tray,NoStandard
Menu,Tray,Icon ,ICO/程序图标.ico

GuiTitleContent := A_IsAdmin=1?"（管理员）":""
Menu,Tray,Tip,XiaoYao_快速跳转%GuiTitleContent%`n版本：v%软件版本号%`n作者：逍遥

Menu,Tray,add,设置(&D),打开设置
Menu,Tray,add,关于(&G),关于
Menu,Tray,add,目录(&F),打开软件安装目录
Menu,Tray,add
Menu,Tray,add,重启(&R),Menu_Reload
Menu,Tray,add,停用(&S),Menu_Suspend
Menu,Tray,add,退出(&E),Menu_Exit
;------------------ 快捷键弹出设置 ------------------
global processList2:="ahk_class Qt5QWindowIcon`n" 常驻窗口窗口列表

Hotkey, If,WinActiveList(屏蔽xiaoyao程序列表)
if not (菜单全局热键="" || 菜单全局热键="ERROR")
    Hotkey, %菜单全局热键%, ShowMenu2
if not (常驻窗口全局热键="" || 常驻窗口全局热键="ERROR")
    Hotkey, %常驻窗口全局热键%, 打开常驻搜索窗口2
Hotkey, If

Hotkey, If,WinActiveList2(屏蔽xiaoyao程序列表)
if not (热键="" || 热键="ERROR")
    Hotkey, %热键%, ShowMenu1
if not (一键跳转热键="" || 一键跳转热键="ERROR")
    Hotkey, %一键跳转热键%, 一键跳转路径
if not (常驻搜索窗口呼出热键="" || 常驻搜索窗口呼出热键="ERROR")
    Hotkey, %常驻搜索窗口呼出热键%, 打开常驻搜索窗口
Hotkey, If

;深色/浅色主题切换1【开始】---------------------------------
if (IsDarkMode() and 深浅主题切换="跟随系统") or (深浅主题切换="深色"){
    Menu_Dark(2)    ;菜单强制深色
    if (菜单背景颜色="")
        菜单背景颜色 := "0x202020" ; 深色背景
}
;深色/浅色主题切换1【结束】---------------------------------

;------------------ 自动弹出菜单设置 ------------------
FileDelete, %A_Temp%\跳转默认打开记录.txt
run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\辅助\自动弹出常驻窗口.ahk"

If (自动弹出菜单="开启" or 自动跳转到文件管理器路径="开启"){
    windows := []
    Loop, Parse, 常驻窗口窗口列表, `n, `r
    {
        if not (RegExMatch(A_LoopField, "^\s*$"))
            windows.Push(Trim(A_LoopField))
    }
    SetTitleMatchMode, 2
    SetTimer, 检查窗口列表, 10
}
return

;------------------ 生成菜单 ------------------
ShowMenu:
    ; 【新增】每次弹出菜单前，初始化菜单名称与真实路径的映射表
    global MenuDisplayMap := {}
    global FolderNameCount := {}
    global RealPathMap := {}

    ExplorerPath:=""
    DirectoryOpuspath:=""
    TotalCommanderpath:=""
    xy所有路径:=XYplorer_Path()
    qdir所有路径:=Q_Dir_Path()
    dc所有路径:=DoubleCommander_path(给dc发送热键)

    开头内容:="按shift复制 ctrl打开"

    if (全局性菜单="开启"){
        if (全局性菜单项功能="直接打开")
            开头内容:="全局菜单(直接打开,按shift复制)"
        Else
            开头内容:="全局菜单(仅复制,按ctrl打开)"
    }
    DetectHiddenWindows,Off
    $WinID := WinExist("A")

    Menu ContextMenu, Add,%开头内容% , Choice
    Menu ContextMenu, Disable, %开头内容%

    ; ------------------ File Explorer ------------------
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass"){
        folder:=Explorer_Path()
        ExplorerPath:=folder
        DispFolder := FormatMenuName(folder)
        Menu ContextMenu, Add, %DispFolder%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %DispFolder%, shell32.dll, 5
        For $Exp in ComObjCreate("Shell.Application").Windows{
            try folder := $Exp.Document.Folder.Self.Path
            if(!folder){
                Continue
            }
            DispFolder := FormatMenuName(folder)
            Menu ContextMenu, Add, %DispFolder%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %DispFolder%, shell32.dll, 5
        }
        $Exp := ""
    }

    ; ------------------ Total Commander ------------------
    SetTitleMatchMode RegEx
    if WinExist("ahk_exe i)totalcmd.*\.exe"){
        TotalCommanderpath:=TotalCommander_path("1")
        If (TotalCommanderpath != "") {
            DispTC := FormatMenuName(TotalCommanderpath)
            Menu ContextMenu, Add, %DispTC%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %DispTC%, ICO/Totalcmd.ico
        }
        TotalCommanderpath2:=TotalCommander_path("2")
        If (TotalCommanderpath2 != "") {
            DispTC2 := FormatMenuName(TotalCommanderpath2)
            Menu ContextMenu, Add, %DispTC2%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %DispTC2%, ICO/Totalcmd.ico
        }
    }
    SetTitleMatchMode 1

    ; ------------------ XYplorer ------------------
    Loop, parse, xy所有路径, `n, `r
    {
        DispName := FormatMenuName(A_LoopField)
        Menu ContextMenu, Add, %DispName%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %DispName%, ICO/XYplorer.ico
    }

    ; ------------------ Q_Dir ------------------
    Loop, parse, qdir所有路径, `n, `r
    {
        DispName := FormatMenuName(A_LoopField)
        Menu ContextMenu, Add, %DispName%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %DispName%, ICO/Q-Dir.ico
    }

    ; ------------------ DoubleCommander ------------------
    Loop, parse, dc所有路径, `n, `r
    {
        DispName := FormatMenuName(A_LoopField)
        Menu ContextMenu, Add, %DispName%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %DispName%, ICO/DoubleCommander.ico
    }

    ; ------------------ Directory Opus ------------------
    if WinExist("ahk_exe dopus.exe"){
        do所有标签页:= DirectoryOpusgetinfo(0)
        Loop, Parse, do所有标签页, `n, `r
        {
            if (A_Index = "1")
                DirectoryOpuspath:= A_LoopField
        }

        If (DirectoryOpus全标签路径="开启")
            结果:= Trim(DirectoryOpusgetinfo(0),"`n")
        Else
            结果:= Trim(DirectoryOpusgetinfo(2),"`n")

        Loop, parse, 结果, `n, `r
        {
            geshihua:= RTrim(A_LoopField,"\")
            DispName := FormatMenuName(geshihua)
            Menu ContextMenu, Add, %DispName%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon,%DispName%, ICO/dopus.ico
        }
    }

    ;------------------ 常用路径 ------------------
    自定义常用路径:=程序专属路径筛选(自定义常用路径2,$WinID)
    if (深浅主题切换="浅色" or (深浅主题切换="跟随系统" and not IsDarkMode()))
        Menu ContextMenu, Add
    Menu ContextMenu, Add, < 常用路径 >, Choice
    Menu ContextMenu, Disable, < 常用路径 >

    Menu ContextMenu, Add, (&T)将当前路径加入常用, 添加到常用路径
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon, (&T)将当前路径加入常用, shell32.dll, 46

    Loop, parse, 自定义常用路径, `n, `r
    {
        DispName := FormatMenuName(A_LoopField)
        if (A_Index = (常用路径最多显示数量 + 1)){
            Menu, 更多常用, Add,更多常用, Choice
            Menu, 更多常用, Disable,更多常用
            Menu ContextMenu, Add, (&M)更多常用, :更多常用
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon,(&M)更多常用, shell32.dll, 44
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu, 更多常用, Add, %DispName%, Choice
                if (是否加载图标 !="关闭")
                    Menu, 更多常用, Icon,%DispName%, shell32.dll, 44
            }
        }Else if (A_Index > (常用路径最多显示数量 + 1)){
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu, 更多常用, Add, %DispName%, Choice
                if (是否加载图标 !="关闭")
                    Menu, 更多常用, Icon,%DispName%, shell32.dll, 44
            }
        }Else{
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu ContextMenu, Add, (&%A_index%)%DispName%, Choice
                if (是否加载图标 !="关闭")
                    Menu ContextMenu, Icon,(&%A_index%)%DispName%, shell32.dll, 44
            }
        }
    }

    Loop, 5
    {
        常用路径%A_Index%:= 程序专属路径筛选(常用路径%A_Index%, $WinID)
        if (常用路径开关%A_Index%="1" and 常用路径%A_Index%!="" and 常用路径名称%A_Index%!=""){
            常用路径名称:= 常用路径名称%A_Index%
            更多常用路径:="更多常用路径" A_Index
            Loop, parse, 常用路径%A_Index%, `n, `r
            {
                if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                    DispName := FormatMenuName(A_LoopField)
                    Menu, %更多常用路径%, Add, %DispName%, Choice
                    if (是否加载图标 !="关闭")
                        Menu, %更多常用路径%, Icon,%DispName%, shell32.dll, 4
                }
            }

            Menu ContextMenu, Add, %常用路径名称%, :%更多常用路径%
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon,%常用路径名称%, shell32.dll, 44
        }
    }

    ;------------------ 历史打开 ------------------
    if (深浅主题切换="浅色" or (深浅主题切换="跟随系统" and not IsDarkMode()))
        Menu ContextMenu, Add

    Menu, 历史打开1, Add, 路径列表, Choice
    Menu, 历史打开1, Disable, 路径列表
    Menu ContextMenu, Add, (&H)历史打开, :历史打开1
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon,(&H)历史打开, shell32.dll, 20
    if FileExist(A_ScriptDir "\ICO\历史跳转.ini"){
        历史跳转:=""
        历史跳转:=全局历史跳转
        if (历史跳转 !=""){
            Loop, parse, 历史跳转, `n, `r
            {
                if !(RegExMatch(A_LoopField, "^\s*$")){
                    if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                        DispName := FormatMenuName(A_LoopField)
                        Menu, 历史打开1, Add, %DispName%, Choice
                        if (是否加载图标 !="关闭")
                            Menu, 历史打开1, Icon,%DispName%, shell32.dll, 4
                    }
                }
            }
        }
    }

    ;------------------ do收藏夹 ------------------
    if (DO的收藏夹="开启") and (do收藏夹所有路径 !=""){
        Menu, do收藏夹, Add,部分收藏夹需先运行do, Choice
        Menu, do收藏夹, Disable,部分收藏夹需先运行do
        Menu ContextMenu, Add, (&H)do收藏夹, :do收藏夹
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon,(&H)do收藏夹, shell32.dll, 20
        if (do收藏夹所有路径 !=""){
            Loop, parse, do收藏夹所有路径, `n, `r
            {
                if !(RegExMatch(A_LoopField, "^\s*$")){
                    if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                        DispName := FormatMenuName(A_LoopField)
                        Menu, do收藏夹, Add, %DispName%, Choice
                        if (是否加载图标 !="关闭")
                            Menu, do收藏夹, Icon,%DispName%, shell32.dll, 4
                    }
                }
            }
        }
    }

    ; ------------------ 设置 ------------------
    Gosub, 读取默认路径配置

    if (自动跳转到默认路径="关闭")
        Menu, 更多设置项, Add, 开启 自动跳默认路径, 开启自动跳默认路径
    if (自动跳转到默认路径="开启"){
        Menu, 更多设置项, Add, 自动跳默认路径, 关闭自动跳默认路径
        Menu, 更多设置项, Icon, 自动跳默认路径, shell32.dll, 145
    }

    if (历史路径设为默认路径="关闭"){
        Menu, 更多设置项, Add, 开启 历史路径设为默认, 开启历史路径设为默认
        if (自动跳转到默认路径="关闭")
            Menu, 更多设置项, Disable, 开启 历史路径设为默认
    }
    if (历史路径设为默认路径="开启"){
        Menu, 更多设置项, Add, 历史路径设为默认, 关闭历史路径设为默认
        Menu, 更多设置项, Icon, 历史路径设为默认, shell32.dll, 145
        if (自动跳转到默认路径="关闭")
            Menu, 更多设置项, Disable, 历史路径设为默认
    }

    Menu, 更多设置项, Add, 设置 默认路径, 设置默认路径
    Menu, 更多设置项, Add, 查看 当前自动跳转路径, 查看默认路径
    if (自动跳转到默认路径="关闭") or (自动跳转到默认路径="开启" and 历史路径设为默认路径="开启"){
        Menu, 更多设置项, Disable, 设置 默认路径
        Menu, 更多设置项, Disable, 查看 当前自动跳转路径
    }
    Menu, 更多设置项, Add
    Menu, 更多设置项, Add, 在该程序中禁用xiaoyao, 在该程序中禁用xiaoyao

    Menu, 更多设置项, Add
    Menu, 更多设置项, Add, 设置(&D), 打开设置
    Menu, 更多设置项, Add, 重启(&R), Menu_Reload
    Menu, 更多设置项, Add, 退出(&E), Menu_Exit

    Menu ContextMenu, Add, (&S)打开设置, :更多设置项
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon,(&S)打开设置, shell32.dll, 163
    ;------------------------------------------
    Menu ContextMenu, Add, (&C)关闭菜单, 关闭菜单
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon,(&C)关闭菜单, shell32.dll, 28
    ;------------------------------------------
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Color, %菜单背景颜色%

    弹出位置X坐标2:= Calculate(字符坐标替换(弹出位置X坐标))
    弹出位置Y坐标2:= Calculate(字符坐标替换(弹出位置Y坐标))

    if (弹出位置X坐标2="" || 弹出位置X坐标2="ERROR")
        弹出位置X坐标2:=100
    if (弹出位置Y坐标2="" || 弹出位置Y坐标2="ERROR")
        弹出位置Y坐标2:=100

    ;高亮当前活动标签
    当前活动标签:=""
    Firstpath:=Trim(ExplorerPath "`n" DirectoryOpuspath "`n" TotalCommanderpath,"`n")
    Loop, parse, Firstpath, `n, `r
    {
        当前活动标签:=RegExReplace(A_LoopField, "^\((.*?)\)")
        当前活动标签:=RTrim(A_LoopField,"\")
        if FileExist(当前活动标签){
            ; 【修改】通过字典查找它的菜单名称，以支持高亮简称
            RenameTarget := (只显示文件夹名 = "开启" && MenuDisplayMap.HasKey(当前活动标签)) ? MenuDisplayMap[当前活动标签] : 当前活动标签
            Menu, ContextMenu, Rename, %RenameTarget% , (&A)%RenameTarget%
            Break
        }
    }

    if (弹出位置X坐标2="0" and 弹出位置Y坐标2="0")
        Menu ContextMenu, Show
    Else
        Menu ContextMenu, Show, %弹出位置X坐标2%,%弹出位置Y坐标2%

    Menu ContextMenu, Delete
    Menu 历史打开1, Delete
    if (DO的收藏夹="开启")
        Menu do收藏夹, Delete
    Menu 更多设置项, Delete

    全局性菜单:=""

    if (DO的收藏夹="开启")
        do收藏夹所有路径:=DirectoryOpusgetfa()
Return

ShowMenu2:
    全局性菜单:="开启"
    Gosub, ShowMenu
    Gosub,手动弹出计数
Return

ShowMenu1:
    Gosub, ShowMenu
    Gosub,手动弹出计数
Return
;-------------------------------------------------------------------
Choice:
    $FolderPath:=RegExReplace(A_ThisMenuItem, "^\((.*?)\)")

    ; 【新增】如果开启了精简显示，将短名称还原回真实的绝对路径
    global 只显示文件夹名, RealPathMap
    if (只显示文件夹名 = "开启" && RealPathMap.HasKey($FolderPath)){
        $FolderPath := RealPathMap[$FolderPath]
    }

    if GetKeyState("shift"){
        Clipboard:=$FolderPath
        ttip("已复制: "Clipboard,2000)
        Return
    }

    if GetKeyState("ctrl"){
        runtry($FolderPath,不存在时新建)
        Return
    }

    if (全局性菜单="开启"){
        if (全局性菜单项功能="直接打开"){
            runtry($FolderPath,不存在时新建)
        }Else{
            Clipboard:=$FolderPath
            ttip("已复制: "Clipboard,2000)
        }
        Return
    }

    Gosub FeedExplorerOpenSave
    if  FileExist($FolderPath){
        写入文本到($FolderPath,A_ScriptDir "\ICO\历史跳转.ini",保留个数)
    }
    FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini
return
;-------------------------------------------------------------------
打开设置:
    Gosub, 设置可视化
return
;-------------------------------------------------------------------
一键跳转路径:
    Gosub,手动弹出计数
    $WinID := WinExist("A")
    Firstpath:=Trim(Explorer_Path() "`n" DirectoryOpusgetinfo(0) "`n" TotalCommander_path() "`n" XYplorer_Path("1") "`n" DoubleCommander_path(给dc发送热键),"`n")
    $FolderPath=""
    Loop, parse, Firstpath, `n, `r
    {
        if !(RegExMatch(A_LoopField, "^\s*$")){
            $FolderPath:=RTrim( RegExReplace(A_LoopField, "^\((.*?)\)"),"\")
            Break
        }
    }
    if ($FolderPath="")
        return
    if  FileExist($FolderPath){
        写入文本到($FolderPath,A_ScriptDir "\ICO\历史跳转.ini",保留个数)
    }
    FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini
    Gosub FeedExplorerOpenSave
return
;-------------------------------------------------------------------
FeedExplorerOpenSave:
    另存为窗口id值:=$WinID
    跳转目标路径:=$FolderPath
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -跳转事件 %另存为窗口id值% "%跳转目标路径%"
Return
;-------------------------------------------
关闭菜单:
Return
关于:
    Gui,guanyu:font, s10
    Gui,guanyu:Add, Edit,r9 w380,作者:逍遥`nhttps://github.com/lch319/XiaoYao_QuickJump`n`nQQ群：`n246308937(RunAny快速启动一劳永逸)`n736344313(Directory Opus 2000人群)`n`n在打开或保存对话框中，快速定位到当前打开的文件夹路径。`n目前支持 资管/TC/DO/XY/Q-Dir
    Gui,guanyu:Show,,快速跳转_v%软件版本号%
Return
Menu_Reload:
    Critical
    FileDelete, %A_Temp%\常驻窗口关闭记录.txt
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    Run,%A_AhkPath% /force /restart "%A_ScriptFullPath%"
ExitApp
return
Menu_Suspend:
    Menu,tray,ToggleCheck,停用(&S)
    Suspend
return
Menu_Exit:
    FileDelete, %A_Temp%\常驻窗口关闭记录.txt
    FileDelete, %A_Temp%\跳转默认打开记录.txt
    run,%comSpec% /c taskkill /f /im XiaoYao_快速跳转.exe,,Hide
ExitApp
return

打开软件安装目录:
    runtry(A_ScriptDir)
return

;字符坐标替换------------------------------------------------------------------------------
字符坐标替换(str){
    hwnd := WinExist("A")
    WinGetPos, 父窗口X, 父窗口Y, 父窗口W, 父窗口H, A
    GetClientSize(hwnd, 父窗口W, 父窗口H)

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

RemoveToolTip:
    ToolTip
return

Label_AutoRun(Auto_Launch:="0"){
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, 主程序
    RegRead, Auto_Launch_reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, XiaoYao_快速跳转
    Auto_Launch_reg := Auto_Launch_reg=A_ScriptDir "\XiaoYao_快速跳转.exe" ? 1 : 0
    If(Auto_Launch!=Auto_Launch_reg){
        Auto_Launch_reg:=Auto_Launch
        If(Auto_Launch){
            RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, XiaoYao_快速跳转, %A_ScriptDir%\XiaoYao_快速跳转.exe
        }Else{
            RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, XiaoYao_快速跳转
        }
    }
}
设置可视化:
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\用户设置GUI.ahk"
Return

;==================================================================================================

打开常驻搜索窗口:
    Gosub,手动弹出计数
    获取窗口id:=WinExist("A")
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -常驻窗口跟随 %获取窗口id%
return

打开常驻搜索窗口2:
    Gosub,手动弹出计数
    获取窗口id:=WinExist("A")
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -常驻窗口跟随 %获取窗口id% 全局版
return

检查窗口列表:
    for index, winTitle2 in windows2
    {
        if WinActive(winTitle2)
            Return
    }

    for index, winTitle in windows
    {
        if WinActive(winTitle){
            if (全局变量11="0"){
                自动跳转到文件管理器路径:=Var_Read("自动跳转到文件管理器路径","关闭","基础配置",A_ScriptDir "\个人配置.ini","否")
                给dc发送热键:=Var_Read("给dc发送热键","^+{F12}","基础配置",A_ScriptDir "\个人配置.ini","否")

                If (自动跳转到文件管理器路径 = "开启"){
                    WinID2 := WinExist(winTitle)
                    Firstpath22:=Trim(Explorer_Path() "`n" DirectoryOpusgetinfo(1) "`n" TotalCommander_path() "`n" XYplorer_Path("1") "`n" DoubleCommander_path(给dc发送热键),"`n")
                    FolderPath222 :=""
                    Loop, parse, Firstpath22, `n, `r
                    {
                        if !(RegExMatch(A_LoopField, "^\s*$")){
                            FolderPath222:=RTrim( RegExReplace(A_LoopField, "^\((.*?)\)"),"\")
                            Break
                        }
                    }

                    if (FolderPath222 !=""){
                        Sleep, 100
                        DialogType := SmellsLikeAFileDialog(WinID2)
                        If DialogType{
                            run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -跳转事件 %WinID2% "%FolderPath222%"
                            FileAppend,%WinID2%`n,%A_Temp%\跳转默认打开记录.txt
                            DialogType := ""
                        }
                    }
                }

                if (自动弹出菜单="开启"){
                    If (自动跳转到文件管理器路径 = "开启")
                        Sleep, 200
                    WinID2 := WinExist(winTitle)
                    DialogType := SmellsLikeAFileDialog(WinID2)
                    If DialogType{
                        sleep, %延迟自动弹出时间%
                        Gosub, ShowMenu
                        Gosub,自动弹出菜单计数
                        DialogType := ""
                    }
                }

                WinWaitNotActive,% winTitle
            }
            global 全局变量11 :="1"
            Return
        }
    }
    if WinActive("ahk_class #32770"){
        if (全局变量11="0"){

            自动跳转到文件管理器路径:=Var_Read("自动跳转到文件管理器路径","关闭","基础配置",A_ScriptDir "\个人配置.ini","否")
            给dc发送热键:=Var_Read("给dc发送热键","^+{F12}","基础配置",A_ScriptDir "\个人配置.ini","否")

            If (自动跳转到文件管理器路径 = "开启"){
                WinID2 := WinExist("ahk_class #32770")
                Firstpath22:=Trim(Explorer_Path() "`n" DirectoryOpusgetinfo(1) "`n" TotalCommander_path() "`n" XYplorer_Path("1") "`n" DoubleCommander_path(给dc发送热键),"`n")
                FolderPath222 :=""
                Loop, parse, Firstpath22, `n, `r
                {
                    if !(RegExMatch(A_LoopField, "^\s*$")){
                        FolderPath222:=RTrim( RegExReplace(A_LoopField, "^\((.*?)\)"),"\")
                        Break
                    }
                }

                if (FolderPath222 !=""){
                    Sleep, 100
                    DialogType := SmellsLikeAFileDialog(WinID2)
                    If DialogType{
                        run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -跳转事件 %WinID2% "%FolderPath222%"
                        FileAppend,%WinID2%`n,%A_Temp%\跳转默认打开记录.txt
                        DialogType := ""
                    }
                }
            }

            if (自动弹出菜单="开启"){
                If (自动跳转到文件管理器路径 = "开启")
                    Sleep, 200
                WinID2 := WinExist("ahk_class #32770")
                DialogType := SmellsLikeAFileDialog(WinID2)
                If DialogType{
                    sleep, %延迟自动弹出时间%
                    Gosub, ShowMenu
                    Gosub,自动弹出菜单计数
                    DialogType := ""
                }
            }
            WinWaitNotActive, ahk_class #32770
        }
        全局变量11 :="1"
        Return
    }
    窗口列表123:="常用路径跳转 ahk_class AutoHotkeyGUI ahk_exe XiaoYao_快速跳转.exe`nahk_class #32770`n" . 常驻窗口窗口列表
    文件管理器窗口列表:="ahk_class i)^ATL: ahk_exe Q-Dir.*\.exe`nahk_class TTOTAL_CMD ahk_exe i)totalcmd.*\.exe`nahk_exe explorer.exe ahk_class CabinetWClass`nahk_class ThunderRT6FormDC ahk_exe XYplorer.exe`nahk_class TTOTAL_CMD ahk_exe doublecmd.exe`nahk_exe dopus.exe"
    result2 := CheckStringInFile(A_Temp "\跳转默认打开记录.txt",WinID2)

    if ((not 检测窗口列表的窗口是否激活(窗口列表123)) and (检测窗口列表的窗口是否激活(文件管理器窗口列表))) or (result2 = "" or result2 = "FILE_ERROR")
        全局变量11 :="0"
return

自动弹出菜单计数:
    if not FileExist(A_ScriptDir "\个人配置.ini")
        FileCopy,%A_ScriptDir%\ICO\默认.ini, %A_ScriptDir%\个人配置.ini
    自动弹出菜单计数++
    IniWrite, %自动弹出菜单计数%, %A_ScriptDir%\个人配置.ini,基础配置,自动弹出菜单计数
Return

手动弹出计数:
    if not FileExist(A_ScriptDir "\个人配置.ini")
        FileCopy,%A_ScriptDir%\ICO\默认.ini, %A_ScriptDir%\个人配置.ini
    手动弹出计数++
    IniWrite, %手动弹出计数%, %A_ScriptDir%\个人配置.ini,基础配置,手动弹出计数
Return

开启自动跳默认路径:
    IniWrite, 开启, %A_ScriptDir%\个人配置.ini,基础配置,自动跳转到默认路径
    if (默认路径="" || 默认路径="ERROR" || !FileExist(默认路径)){
        gosub,设置默认路径
    }
return
关闭自动跳默认路径:
    IniWrite, 关闭, %A_ScriptDir%\个人配置.ini,基础配置,自动跳转到默认路径
return
开启历史路径设为默认:
    IniWrite, 开启, %A_ScriptDir%\个人配置.ini,基础配置,历史路径设为默认路径
return
关闭历史路径设为默认:
    IniWrite, 关闭, %A_ScriptDir%\个人配置.ini,基础配置,历史路径设为默认路径
return
查看默认路径:
    ttip("当前默认路径: " 默认路径, 3000)
return

设置默认路径:
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\设置默认路径.ahk"
return

读取默认路径配置:
    自动跳转到默认路径:=Var_Read("自动跳转到默认路径","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
    历史路径设为默认路径:=Var_Read("历史路径设为默认路径","关闭","基础配置",A_ScriptDir "\个人配置.ini","是")
    默认路径:=ReplaceVars(Var_Read("默认路径","","基础配置",A_ScriptDir "\个人配置.ini","是"))
return

WinActiveList(窗口列表1111){
    excludedProcesses := StrSplit(窗口列表1111, "`,")
    for index, process in excludedProcesses {
        if WinActive("ahk_exe " process)
            return false
    }

    窗口列表2222:=processList "`n" processList2
    SetTitleMatchMode, 2
    excludedProcesses2 := StrSplit(窗口列表2222, "`n")
    for index, process in excludedProcesses2 {
        if WinActive(process){
            return false
        }
    }
    return true
}

WinActiveList2(窗口列表1111){
    屏蔽程序:=""
    窗口列表2222:=processList "`n" processList2
    excludedProcesses := StrSplit(窗口列表1111, "`,")
    for index, process in excludedProcesses {
        if WinActive("ahk_exe " process)
            屏蔽程序:="是"
        Break
    }

    if (屏蔽程序 !="是"){
        SetTitleMatchMode, 2
        excludedProcesses2 := StrSplit(窗口列表2222, "`n")
        for index, process in excludedProcesses2 {
            if WinActive(process)
                return true
        }
    }
    return false
}

#if WinActiveList(屏蔽xiaoyao程序列表)

#if

#if WinActiveList2(屏蔽xiaoyao程序列表)

#if

在该程序中禁用xiaoyao:
    WinGet, WinExe22, ProcessName, ahk_id %$WinID%
    NewList2 := RemoveDuplicateLines(屏蔽xiaoyao程序列表 "`," WinExe22,jiangeci:="`,")
    IniWrite, %NewList2%, %A_ScriptDir%\个人配置.ini,基础配置,屏蔽xiaoyao程序列表
    run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\主程序.ahk"
return

Label_AdminLaunch:
    管理员启动:=Var_Read("管理员启动","开启","基础配置",A_ScriptDir "\个人配置.ini","是")
    if (!A_IsAdmin && 管理员启动="开启")
    {
        try
        {
            if A_IsCompiled
                Run *RunAs "%A_ScriptFullPath%" /restart
            else
                Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        }catch{
            MsgBox, 1,, 以【管理员权限】启动失败！将以普通权限启动，管理员应用窗口将失效！
            IfMsgBox OK
            {
                if A_IsCompiled
                    Run "%A_ScriptFullPath%" /restart
                else
                    Run "%A_AhkPath%" /restart "%A_ScriptFullPath%"
            }
        }
        ExitApp
    }
return

;-------------------------------------------------------------------
; 【新增】处理路径精简及同名计数的专门函数
FormatMenuName(FullPath) {
    global 只显示文件夹名, MenuDisplayMap, FolderNameCount, RealPathMap
    FullPath := RTrim(FullPath, "\")
    if (FullPath = "")
        return " " ; 返回空格避免 AHK Menu 崩溃

    if (只显示文件夹名 != "开启")
        return FullPath

    ; 如果已经映射过，直接返回缓存显示名（防止重复递增同名序号）
    if MenuDisplayMap.HasKey(FullPath)
        return MenuDisplayMap[FullPath]

    ; 提取文件夹名称
    RegExMatch(FullPath, "([^\\/]+)$", FolderName)
    if (FolderName = "")
        FolderName := FullPath

    ; 处理同名后缀逻辑
    if !FolderNameCount.HasKey(FolderName) {
        FolderNameCount[FolderName] := 1
        DisplayName := FolderName
    } else {
        FolderNameCount[FolderName]++
        DisplayName := FolderName . "[同名" . (FolderNameCount[FolderName] - 1) . "]"
    }

    ; 记录双向映射：绝对路径 -> 显示名称，显示名称 -> 绝对路径
    MenuDisplayMap[FullPath] := DisplayName
    RealPathMap[DisplayName] := FullPath

    return DisplayName
}

;-------------------------------------------------------------------
添加到常用路径:
    if InStr("`n" 自定义常用路径2 "`n", "`n" 当前活动标签 "`n") {
        ttip("该路径已存在于常用路径列表中！")
        return
    }
    ConfigFile := A_ScriptDir "\个人配置.ini"
    FileRead, ConfigContent, %ConfigFile%
    if InStr(ConfigContent, "[常用路径]") {
        ConfigContent := RegExReplace(ConfigContent, "(\[常用路径\])", "$1`n" 当前活动标签, , 1)
        FileDelete, %ConfigFile%
        FileEncoding, UTF-16
        FileAppend, %ConfigContent%, %ConfigFile%
    } else {
        FileAppend, `n[常用路径]`n%NewPath%, %ConfigFile%
    }

    自定义常用路径2 := 当前活动标签 "`n" 自定义常用路径2
    ttip("已成功添加至常用列表：`n" 当前活动标签, 2000)
return
;-------------------------------------------------------------------