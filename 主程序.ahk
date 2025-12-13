;====================================================================================
;仿Listary_C+G 列出打开的路径 （支持文件管理器、Directory Opus、 TC）最后更新：20250727
;代码借鉴 https://www.autohotkey.com/boards/viewtopic.php?f=6&t=102377
;====================================================================================
#NoEnv
#Persistent ;~让脚本持久运行
#SingleInstance,Force ;~运行替换旧实例
#Include %A_ScriptDir%\辅助\公用函数.ahk

SendMode Input
SetWorkingDir %A_ScriptDir%
SetBatchLines -1

软件版本号:="4.5.0.1"

;判断是否管理员启动
Gosub, Label_AdminLaunch

;清除辅助脚本进程
FileRead,后台隐藏运行脚本记录,%A_Temp%\后台隐藏运行脚本记录.txt
;MsgBox, 常驻窗口关闭记录: %常驻窗口关闭记录%
Loop, parse, 后台隐藏运行脚本记录, `n, `r
{
    WinKill,ahk_id %A_LoopField%
}
FileDelete, %A_Temp%\后台隐藏运行脚本记录.txt

run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\辅助\解决菜单不消失.ahk"
;run,C:\Windows\System32\cmd.exe /c taskkill /f /im XiaoYao_快速跳转.exe,,Hide
;------------------ 读取配置 ------------------
热键:="^g"
自动弹出菜单:="开启"
菜单背景颜色:=""
延迟自动弹出时间:="250"
自定义常用路径:=A_Desktop "`n" A_MyDocuments
开机自启:="0"

global DO的收藏夹
global do收藏夹所有路径
global 全局性菜单
global processList:="ahk_class #32770"

;MsgBox, %do收藏夹所有路径%
;注意:带别名的需要do先打开

global 全局历史跳转
FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini

;如果配置不存在，新建一个默认配置
if not FileExist(A_ScriptDir "\个人配置.ini")
    FileCopy,%A_ScriptDir%\ICO\默认.ini, %A_ScriptDir%\个人配置.ini

IniRead, 热键, %A_ScriptDir%\个人配置.ini,基础配置,热键
IniRead, 自动弹出菜单, %A_ScriptDir%\个人配置.ini,基础配置,自动弹出菜单
IniRead, 菜单背景颜色, %A_ScriptDir%\个人配置.ini,基础配置,菜单背景颜色
IniRead, 延迟自动弹出时间, %A_ScriptDir%\个人配置.ini,基础配置,延迟自动弹出时间

IniRead, 自定义常用路径2, %A_ScriptDir%\个人配置.ini,常用路径
自定义常用路径2:=ReplaceVars(自定义常用路径2)

IniRead, 替换双斜杠单反斜杠双引号, %A_ScriptDir%\个人配置.ini,基础配置,替换双斜杠单反斜杠双引号
if (替换双斜杠单反斜杠双引号="" || 替换双斜杠单反斜杠双引号="ERROR")
    替换双斜杠单反斜杠双引号:="关闭"
if (替换双斜杠单反斜杠双引号="开启"){
    自定义常用路径2:=RegExReplace(StrReplace(自定义常用路径2, """", ""), "\\\\|/", "\")
}

IniRead, DirectoryOpus全标签路径, %A_ScriptDir%\个人配置.ini,基础配置,DirectoryOpus全标签路径

IniRead, 弹出位置X坐标, %A_ScriptDir%\个人配置.ini,基础配置,弹出位置X坐标
IniRead, 弹出位置Y坐标, %A_ScriptDir%\个人配置.ini,基础配置,弹出位置Y坐标

IniRead, 一键跳转热键, %A_ScriptDir%\个人配置.ini,基础配置,一键跳转热键
IniRead, 跳转方式, %A_ScriptDir%\个人配置.ini,基础配置,跳转方式
IniRead, 保留个数, %A_ScriptDir%\个人配置.ini,基础配置,历史跳转保留数
if (保留个数="" || 保留个数="ERROR")
    保留个数:="5"
IniRead, 开机自启, %A_ScriptDir%\个人配置.ini,基础配置,开机自启
if (开机自启="" || 开机自启="ERROR" || 开机自启="关闭")
    开机自启:="0"
IniRead, DO的收藏夹, %A_ScriptDir%\个人配置.ini,基础配置,DO的收藏夹
if (DO的收藏夹="开启")
    do收藏夹所有路径:=DirectoryOpusgetfa()

IniRead, 自动弹出常驻窗口, %A_ScriptDir%\个人配置.ini,基础配置,自动弹出常驻窗口
IniRead, 常驻搜索窗口呼出热键, %A_ScriptDir%\个人配置.ini,基础配置,常驻搜索窗口呼出热键
IniRead, 窗口初始坐标x, %A_ScriptDir%\个人配置.ini,基础配置,窗口初始坐标x
IniRead, 窗口初始坐标y, %A_ScriptDir%\个人配置.ini,基础配置,窗口初始坐标y
IniRead, 窗口初始宽度, %A_ScriptDir%\个人配置.ini,基础配置,窗口初始宽度
IniRead, 窗口初始高度, %A_ScriptDir%\个人配置.ini,基础配置,窗口初始高度
IniRead, 窗口背景颜色, %A_ScriptDir%\个人配置.ini,基础配置,窗口背景颜色
IniRead, 窗口字体颜色, %A_ScriptDir%\个人配置.ini,基础配置,窗口字体颜色
IniRead, 窗口字体名称, %A_ScriptDir%\个人配置.ini,基础配置,窗口字体名称
IniRead, 窗口字体大小, %A_ScriptDir%\个人配置.ini,基础配置,窗口字体大小
IniRead, 窗口透明度, %A_ScriptDir%\个人配置.ini,基础配置,窗口透明度

IniRead, 失效路径显示设置, %A_ScriptDir%\个人配置.ini,基础配置,失效路径显示设置

IniRead, 文件夹名显示在前, %A_ScriptDir%\个人配置.ini,基础配置,文件夹名显示在前
if (文件夹名显示在前="" || 文件夹名显示在前="ERROR")
    文件夹名显示在前:="关闭"

IniRead, 菜单全局热键, %A_ScriptDir%\个人配置.ini,基础配置,菜单全局热键
IniRead, 常驻窗口全局热键, %A_ScriptDir%\个人配置.ini,基础配置,常驻窗口全局热键
IniRead, 全局性菜单项功能, %A_ScriptDir%\个人配置.ini,基础配置,全局性菜单项功能
IniRead, 初始文本框内容, %A_ScriptDir%\个人配置.ini,基础配置,初始文本框内容
IniRead, 是否加载图标, %A_ScriptDir%\个人配置.ini,基础配置,是否加载图标

IniRead, 常用路径最多显示数量, %A_ScriptDir%\个人配置.ini,基础配置,常用路径最多显示数量
if (常用路径最多显示数量="" || 常用路径最多显示数量="ERROR")
    常用路径最多显示数量:="9"

IniRead, 屏蔽xiaoyao程序列表,%A_ScriptDir%\个人配置.ini,基础配置,屏蔽xiaoyao程序列表
if (屏蔽xiaoyao程序列表="" || 屏蔽xiaoyao程序列表="ERROR")
    屏蔽xiaoyao程序列表:="War3.exe,dota2.exe,League of Legends.exe"

IniRead, 常驻窗口窗口列表, %A_ScriptDir%\个人配置.ini,窗口列表1
if (常驻窗口窗口列表="" || 常驻窗口窗口列表="ERROR"){
    常驻窗口窗口列表:="
(
选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe
选择 ahk_class #32770 ahk_exe Bandizip.exe
解压路径和选项 ahk_class #32770 ahk_exe WinRAR.exe
选择目标文件夹 ahk_class #32770 ahk_exe dopus.exe
)"
}

;----------------黑名单窗列表读取-----------
IniRead, 屏蔽xiaoyao窗口列表,%A_ScriptDir%\个人配置.ini,窗口列表2
if (屏蔽xiaoyao窗口列表="" || 屏蔽xiaoyao窗口列表="ERROR"){
    屏蔽xiaoyao窗口列表:="
(
ahk_exe IDMan.exe
)"
}
;常驻窗口窗口列表:="选择解压路径 ahk_class #32770 ahk_exe Bandizip.exe`n选择 ahk_class #32770 ahk_exe Bandizip.exe"
; 解析窗口列表到数组
windows2 := []
Loop, Parse, 屏蔽xiaoyao窗口列表, `n, `r
{
    if not (RegExMatch(A_LoopField, "^\s*$"))  ; 跳过空行
        windows2.Push(Trim(A_LoopField))
}
Loop, Parse, 屏蔽xiaoyao程序列表, `,
{
    if not (RegExMatch(A_LoopField, "^\s*$"))  ; 跳过空行
        windows2.Push(Trim("ahk_exe " A_LoopField))
}
;----------------黑名单窗列表读取-----------

IniRead, 窗口文本行距, %A_ScriptDir%\个人配置.ini,基础配置,窗口文本行距
if (窗口文本行距="" || 窗口文本行距="ERROR")
    窗口文本行距:= "20"

IniRead, 隐藏软件托盘图标, %A_ScriptDir%\个人配置.ini,基础配置,隐藏软件托盘图标
if (隐藏软件托盘图标="" || 隐藏软件托盘图标="ERROR")
    隐藏软件托盘图标:= "关闭"

IniRead, 手动弹出计数, %A_ScriptDir%\个人配置.ini,基础配置,手动弹出计数
if (手动弹出计数="" || 手动弹出计数="ERROR")
    手动弹出计数:= "0"
IniRead, 自动弹出菜单计数, %A_ScriptDir%\个人配置.ini,基础配置,自动弹出菜单计数
if (自动弹出菜单计数="" || 自动弹出菜单计数="ERROR")
    自动弹出菜单计数:= "0"

IniRead, 给dc发送热键, %A_ScriptDir%\个人配置.ini,基础配置,给dc发送热键
if (给dc发送热键="" || 给dc发送热键="ERROR")
    给dc发送热键:= "^+{F12}"

OnExit, 退出时运行

;------------------ 读取配置终止线 ----------------

if (隐藏软件托盘图标="开启"){
    Menu, Tray, NoIcon
}
if not FileExist(A_ScriptDir "\ICO\历史跳转.ini")
    FileAppend, ,%A_ScriptDir%\ICO\历史跳转.ini
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

;------------------ 自动弹出菜单设置 ------------------
;If (自动弹出常驻窗口="开启")
;SetTimer, 自动弹出常驻事件,10
run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\辅助\自动弹出常驻窗口.ahk"

If (自动弹出菜单="开启"){
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
        sleep, %延迟自动弹出时间%
        if WinActive("ahk_class #32770"){
            ;----------------黑名单窗口跳过-----------
            for index, winTitle2 in windows2
            {
                ;检查窗口是否存在
                ;MsgBox, %winTitle2%
                if WinActive(winTitle2){
                    黑名单窗口:="1"
                    Break
                }
            }
            if (黑名单窗口="1"){
                黑名单窗口:="0"
                ;MsgBox, 1
                Continue
            }
            ;----------------黑名单窗口跳过-----------

            WinID2 := WinExist("A")

            sleep, 100
            DialogType := SmellsLikeAFileDialog(WinID2)
            If DialogType{
                WinGetClass, WindowClass, ahk_id %WinID2%   ; 获取目标窗口的类名
                if (WindowClass = "#32770"){    ; 判断类名是否为 #32770
                    Gosub, ShowMenu
                    自动弹出菜单计数++
                    DialogType := ""
                }
            }
        }
        WinWaitNotActive, ahk_class #32770
        sleep, 100
        ;Menu ContextMenu, Delete
        WinID2 := ""
        DialogType :=""
    }
    ;SetTimer, 自动弹出菜单事件,10

}
return

;------------------ 生成菜单 ------------------
ShowMenu:
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
    ;DetectHiddenWindows,On
    $WinID := WinExist("A")

    Menu ContextMenu, Add,%开头内容% , Choice
    Menu ContextMenu, Disable, %开头内容%
    ; ------------------ File Explorer ------------------
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass"){
        folder:=Explorer_Path()
        ExplorerPath:=folder
        Menu ContextMenu, Add, %folder%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %folder%, shell32.dll, 5
        For $Exp in ComObjCreate("Shell.Application").Windows{
            try folder := $Exp.Document.Folder.Self.Path
            if(!folder){
                Continue
            }
            Menu ContextMenu, Add, %folder%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %folder%, shell32.dll, 5
        }
        $Exp := ""
    }
    ; ------------------ Total Commander ------------------
    SetTitleMatchMode RegEx
    if WinExist("ahk_exe i)totalcmd.*\.exe"){
        TotalCommanderpath:=TotalCommander_path("1")
        If (TotalCommanderpath != "") {
            Menu ContextMenu, Add, %TotalCommanderpath%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %TotalCommanderpath%, ICO/Totalcmd.ico
        }
        TotalCommanderpath2:=TotalCommander_path("2")
        If (TotalCommanderpath2 != "") {
            Menu ContextMenu, Add, %TotalCommanderpath2%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon, %TotalCommanderpath2%, ICO/Totalcmd.ico
        }        
    }
    SetTitleMatchMode 1
    ; ------------------ XYplorer ------------------
    Loop, parse, xy所有路径, `n, `r
    {
        Menu ContextMenu, Add, %A_LoopField%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %A_LoopField%, ICO/XYplorer.ico
    }

    ; ------------------ Q_Dir ------------------
    Loop, parse, qdir所有路径, `n, `r
    {
        Menu ContextMenu, Add, %A_LoopField%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %A_LoopField%, ICO/Q-Dir.ico
    }

    ; ------------------ DoubleCommander ------------------
    Loop, parse, dc所有路径, `n, `r
    {
        Menu ContextMenu, Add, %A_LoopField%, Choice
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon, %A_LoopField%, ICO/DoubleCommander.ico
    }

    ; ------------------ Directory Opus ------------------
    if WinExist("ahk_exe dopus.exe"){
        ;MsgBox, 1
        DirectoryOpuspath:=DirectoryOpus_path("Clipboard SET {sourcepath}")
        If (DirectoryOpus全标签路径="开启")
            ;结果:= DirectoryOpusgetinfo()
            结果:= Trim(Trim(DirectoryOpuspath "`n" DirectoryOpus_path("Clipboard SET {destpath}"),"`n") "`n" DirectoryOpusgetinfo(),"`n")
        Else
            结果:= Trim(DirectoryOpuspath "`n" DirectoryOpus_path("Clipboard SET {destpath}"),"`n")

        Loop, parse, 结果, `n
        {
            geshihua:= RTrim(A_LoopField,"\")
            Menu ContextMenu, Add, %geshihua%, Choice
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon,%geshihua%, ICO/dopus.ico
        }
    }
    ; ------------------ 常用路径 ------------------
    自定义常用路径:=程序专属路径筛选(自定义常用路径2)

    Menu ContextMenu, Add
    Menu ContextMenu, Add, < 常用路径 >, Choice
    Menu ContextMenu, Disable, < 常用路径 >
    ;在ini配置里添加自定义路径，`n隔开，只修改其中路径即可
    Loop, parse, 自定义常用路径, `n, `r
    {
        if (A_Index = (常用路径最多显示数量 + 1)){
            Menu, 更多常用, Add,更多常用, Choice
            Menu, 更多常用, Disable,更多常用
            Menu ContextMenu, Add, (&M)更多常用, :更多常用
            if (是否加载图标 !="关闭")
                Menu ContextMenu, Icon,(&M)更多常用, shell32.dll, 44
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu, 更多常用, Add, %A_LoopField%, Choice
                if (是否加载图标 !="关闭")
                    Menu, 更多常用, Icon,%A_LoopField%, shell32.dll, 44
            }
        }Else if (A_Index > (常用路径最多显示数量 + 1)){
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu, 更多常用, Add, %A_LoopField%, Choice
                if (是否加载图标 !="关闭")
                    Menu, 更多常用, Icon,%A_LoopField%, shell32.dll, 44
            }
        }Else{
            if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                Menu ContextMenu, Add, (&%A_index%)%A_LoopField%, Choice
                if (是否加载图标 !="关闭")
                    Menu ContextMenu, Icon,(&%A_index%)%A_LoopField%, shell32.dll, 44 ;44也可以
            }
        }
    }
    ; ------------------ 历史打开 ------------------
    Menu ContextMenu, Add

    Menu, 历史打开1, Add, 路径列表, Choice
    Menu, 历史打开1, Disable, 路径列表
    Menu ContextMenu, Add, (&H)历史打开, :历史打开1
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon,(&H)历史打开, shell32.dll, 20
    if FileExist(A_ScriptDir "\ICO\历史跳转.ini"){
        历史跳转:=""
        历史跳转:=全局历史跳转
        ;FileRead, 历史跳转, %A_ScriptDir%\ICO\历史跳转.ini
        if (历史跳转 !=""){
            Loop, parse, 历史跳转, `n, `r
            {
                if !(RegExMatch(A_LoopField, "^\s*$")){ ;判断是否是空白行
                    if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                        Menu, 历史打开1, Add, %A_LoopField%, Choice
                        if (是否加载图标 !="关闭")
                            Menu, 历史打开1, Icon,%A_LoopField%, shell32.dll, 4
                    }
                }
            }
        }
    }
    ; ------------------ do收藏夹 ------------------
    if (DO的收藏夹="开启") and (do收藏夹所有路径 !=""){

        Menu, do收藏夹, Add,部分收藏夹需先运行do, Choice
        Menu, do收藏夹, Disable,部分收藏夹需先运行do
        Menu ContextMenu, Add, (&H)do收藏夹, :do收藏夹
        if (是否加载图标 !="关闭")
            Menu ContextMenu, Icon,(&H)do收藏夹, shell32.dll, 20
        if (do收藏夹所有路径 !=""){
            Loop, parse, do收藏夹所有路径, `n, `r
            {
                if !(RegExMatch(A_LoopField, "^\s*$")){ ;判断是否是空白行
                    if (失效路径显示设置 !="关闭") or (失效路径显示设置 ="关闭" and FileExist(A_LoopField)){
                        Menu, do收藏夹, Add, %A_LoopField%, Choice
                        if (是否加载图标 !="关闭")
                            Menu, do收藏夹, Icon,%A_LoopField%, shell32.dll, 4
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
    ; ------------------------------------------
    Menu ContextMenu, Add, (&C)关闭菜单, 关闭菜单
    if (是否加载图标 !="关闭")
        Menu ContextMenu, Icon,(&C)关闭菜单, shell32.dll, 28
    ; ------------------------------------------
    Menu ContextMenu, UseErrorLevel
    Menu ContextMenu, Color, %菜单背景颜色%

    弹出位置X坐标2:= Calculate(字符坐标替换(弹出位置X坐标))
    弹出位置Y坐标2:= Calculate(字符坐标替换(弹出位置Y坐标))

    if (弹出位置X坐标2="" || 弹出位置X坐标2="ERROR")
        弹出位置X坐标2:=100
    if (弹出位置Y坐标2="" || 弹出位置Y坐标2="ERROR")
        弹出位置Y坐标2:=100

    ;高亮当前活动标签
    Firstpath:=Trim(ExplorerPath "`n" DirectoryOpuspath "`n" TotalCommanderpath,"`n")
    ;Firstpath:=Trim(DirectoryOpus_path("Clipboard SET {sourcepath}") "`n" Explorer_Path() "`n" TotalCommander_path(),"`n")
    Loop, parse, Firstpath, `n, `r
    {
        当前活动标签:=RegExReplace(A_LoopField, "^\((.*?)\)")
        当前活动标签:=RTrim(A_LoopField,"\")
        if FileExist(当前活动标签){
            Menu, ContextMenu, Rename, %当前活动标签% , (&A)%当前活动标签%
            Break
        }
    }
    ;显示菜单-------------------------------------------------
    ;MsgBox, %弹出位置X坐标2%`n%弹出位置Y坐标2%
    if (弹出位置X坐标2="0" and 弹出位置Y坐标2="0") ;如果是0,0则显示在鼠标位置
        Menu ContextMenu, Show
    Else
        Menu ContextMenu, Show, %弹出位置X坐标2%,%弹出位置Y坐标2%
    Menu ContextMenu, Delete
    Menu 历史打开1, Delete
    if (DO的收藏夹="开启")
        Menu do收藏夹, Delete
    Menu 更多设置项, Delete

    全局性菜单:=""

    ;MsgBox, 1
    if (DO的收藏夹="开启")
        do收藏夹所有路径:=DirectoryOpusgetfa()
Return

ShowMenu2:
    全局性菜单:="开启"
    手动弹出计数++
    Gosub, ShowMenu
Return

ShowMenu1:
    手动弹出计数++
    Gosub, ShowMenu
Return
; -------------------------------------------------------------------
Choice:
    ;$FolderPath := A_ThisMenuItem
    $FolderPath:=RegExReplace(A_ThisMenuItem, "^\((.*?)\)")
    if GetKeyState("shift"){     ; 判断是否按下 shift 键
        Clipboard:=$FolderPath
        ttip("已复制: "Clipboard,2000)
        Return
    }

    if GetKeyState("ctrl"){     ; 判断是否按下 ctrl 键
        Run, % $FolderPath
        Return
    }

    if (全局性菜单="开启"){
        ;MsgBox, %全局性菜单项功能%
        if (全局性菜单项功能="直接打开"){
            Run, % $FolderPath
        }Else{
            Clipboard:=$FolderPath
            ttip("已复制: "Clipboard,2000)
        }
        Return
    }

    Gosub FeedExplorerOpenSave
    ;MsgBox Folder = %$FolderPath%
    if  FileExist($FolderPath){
        写入文本到($FolderPath,A_ScriptDir "\ICO\历史跳转.ini",保留个数)
    }
    FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini
;global 全局历史跳转
return
; -------------------------------------------------------------------
打开设置:
    Gosub, 设置可视化
    /*
    if FileExist(A_ScriptDir "\个人配置.ini")
        run,%A_ScriptDir%\个人配置.ini
    Else
        run,%A_ScriptDir%
    */
return
; -------------------------------------------------------------------

一键跳转路径:
    手动弹出计数++
    $WinID := WinExist("A")
    ;MsgBox,1
    Firstpath:=Trim(Explorer_Path() "`n" DirectoryOpus_path("Clipboard SET {sourcepath}") "`n" TotalCommander_path() "`n" XYplorer_Path("1") "`n" DoubleCommander_path(给dc发送热键),"`n")
    ;expath:=Explorer_Path()
    ;dopath:=Trim(DirectoryOpus_path("Clipboard SET {sourcepath}"))
    ;tcpath:=TotalCommander_path()
    $FolderPath=""
    Loop, parse, Firstpath, `n, `r
    {
        if !(RegExMatch(A_LoopField, "^\s*$")){ ;判断是否是空白行
            $FolderPath:=RTrim( RegExReplace(A_LoopField, "^\((.*?)\)"),"\") ;去掉括号和别名，并去掉结尾的斜杠
            Break
        }
    }
    if ($FolderPath="")
        return
    ;MsgBox,%$FolderPath%
    ;$FolderPath:=RegExReplace(A_ThisMenuItem, "^\((.*?)\)")
    ;判断文本内容是否已存在($FolderPath,A_ScriptDir "\ICO\历史跳转.ini",保留个数)
    if  FileExist($FolderPath){
        写入文本到($FolderPath,A_ScriptDir "\ICO\历史跳转.ini",保留个数)
    }
    FileRead, 全局历史跳转, %A_ScriptDir%\ICO\历史跳转.ini
    Gosub FeedExplorerOpenSave
return
; -------------------------------------------------------------------
FeedExplorerOpenSave:
    另存为窗口id值:=$WinID
    跳转目标路径:=$FolderPath
    ;MsgBox,%跳转目标路径%
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -跳转事件 %另存为窗口id值% "%跳转目标路径%"

Return
;-------------------------------------------
关闭菜单:
Return
关于:
    ;Gui,guanyu:+AlwaysOnTop
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
    Run, %A_ScriptDir%
return

;字符坐标替换------------------------------------------------------------------------------
字符坐标替换(str){
    ;global 唯一性
    WinGetPos, 父窗口X, 父窗口Y, 父窗口W, 父窗口H, A
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

/*
自动弹出菜单事件:
    Loop, parse, processList, `n, `r
    {
        ; 使用 WinActive 检查活动窗口是否匹配条件
        if WinActive(A_LoopField){
            sleep, %延迟自动弹出时间%
            WinID2 := WinExist(A_LoopField)
            if WinActive("ahk_class #32770"){
                if not WinActive("ahk_exe IDMan.exe"){
                    ;WinID2 := WinExist("A")
                    sleep, 100
                    DialogType := SmellsLikeAFileDialog(WinID2)
                    If DialogType{
                        Gosub, ShowMenu
                        DialogType := ""
                    }
                }
                WinWaitNotActive, ahk_class #32770
                sleep, 100
                ;Menu ContextMenu, Delete
                WinID2 := ""
                DialogType :=""
                Return
            }Else{
                Gosub, ShowMenu
                if (WinID2 != 0){
                    WinWaitNotActive, %A_LoopField%
                    sleep, 100
                }
                Return
            }
        }
    }
Return
*/

/*
;可视化gui设置----------------------------------------------------------------
;开机自启,等于0禁用，等于1开启
Label_AutoRun(Auto_Launch:="0"){
    SplitPath, A_ScriptName , , , , OutNameNoExt
    RegRead, Auto_Launch_reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %OutNameNoExt%
    Auto_Launch_reg := Auto_Launch_reg=A_ScriptDir "\" OutNameNoExt ".exe" ? 1 : 0
    ;MsgBox, %Auto_Launch_reg%
    If(Auto_Launch!=Auto_Launch_reg){
        Auto_Launch_reg:=Auto_Launch
        If(Auto_Launch){
            RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %OutNameNoExt%, %A_ScriptDir%\%OutNameNoExt%.exe
        }Else{
            RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, %OutNameNoExt%
        }
    }
}
*/
;可视化gui设置----------------------------------------------------------------
;开机自启,等于0禁用，等于1开启
Label_AutoRun(Auto_Launch:="0"){
    RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, 主程序
    ;SplitPath, A_ScriptName , , , , OutNameNoExt
    RegRead, Auto_Launch_reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, XiaoYao_快速跳转
    Auto_Launch_reg := Auto_Launch_reg=A_ScriptDir "\XiaoYao_快速跳转.exe" ? 1 : 0
    ;MsgBox, %Auto_Launch_reg%
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
    手动弹出计数++
    获取窗口id:=WinExist("A")
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -常驻窗口跟随 %获取窗口id%
return

打开常驻搜索窗口2:
    手动弹出计数++
    获取窗口id:=WinExist("A")
    run,"%A_AhkPath%" "%A_ScriptDir%\辅助\常驻跟随窗口.ahk" -常驻窗口跟随 %获取窗口id% 全局版
return

检查窗口列表:
    ;----------------黑名单窗口跳过-----------
    for index, winTitle2 in windows2
    {
        ;检查窗口是否存在
        if WinActive(winTitle2)
            Return
    }
    ;----------------黑名单窗口跳过-----------

    for index, winTitle in windows
    {
        ; 检查窗口是否存在
        if WinActive(winTitle){
            WinID2 := WinExist(winTitle)
            Gosub, ShowMenu
            自动弹出菜单计数++
            ;MsgBox, 0x40, 窗口出现提示, 检测到目标窗口：`n"%activeTitle%"`n`n匹配条件：`n%winTitle%
            WinWaitNotActive,% winTitle
            break  ; 每次只处理一个出现的窗口
        }
    }
return

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
        Gosub, ShowMenu
        自动弹出菜单计数++
    }
}

退出时运行:
    ;如果配置不存在，新建一个默认配置
    if not FileExist(A_ScriptDir "\个人配置.ini")
        FileCopy,%A_ScriptDir%\ICO\默认.ini, %A_ScriptDir%\个人配置.ini

    IniWrite, %自动弹出菜单计数%, %A_ScriptDir%\个人配置.ini,基础配置,自动弹出菜单计数
    IniWrite, %手动弹出计数%, %A_ScriptDir%\个人配置.ini,基础配置,手动弹出计数
ExitApp
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
    IniRead, 自动跳转到默认路径,%A_ScriptDir%\个人配置.ini,基础配置,自动跳转到默认路径
    if (自动跳转到默认路径="" || 自动跳转到默认路径="ERROR")
        自动跳转到默认路径:= "关闭"
    IniRead, 历史路径设为默认路径, %A_ScriptDir%\个人配置.ini,基础配置,历史路径设为默认路径
    if (历史路径设为默认路径="" || 历史路径设为默认路径="ERROR")
        历史路径设为默认路径:= "关闭"

    IniRead, 默认路径, %A_ScriptDir%\个人配置.ini,基础配置,默认路径
    if (默认路径="ERROR")
        默认路径:= ""
    默认路径:=ReplaceVars(默认路径)
return

; 检查窗口处于激活状态
WinActiveList(窗口列表1111){
    excludedProcesses := StrSplit(窗口列表1111, "`,")    ; 将窗口列表按 , 分割成数组
    ; 遍历检查是否匹配
    for index, process in excludedProcesses {
        if WinActive("ahk_exe " process)
            return false  ; 找到匹配项，返回 true
    }

    窗口列表2222:=processList "`n" processList2
    ;MsgBox, % 窗口列表2222
    SetTitleMatchMode, 2  ; 使用部分匹配窗口标题
    excludedProcesses2 := StrSplit(窗口列表2222, "`n")    ; 将窗口列表按 , 分割成数组
    ; 遍历检查是否匹配
    for index, process in excludedProcesses2 {
        if WinActive(process){
            ;MsgBox, 1
            return false  ; 找到匹配项，返回 true
        }
    }

    return true  ; 无匹配项，返回 false
}

; 检查窗口处于激活状态
WinActiveList2(窗口列表1111){
    屏蔽程序:=""
    窗口列表2222:=processList "`n" processList2
    ;MsgBox, % 窗口列表2222
    excludedProcesses := StrSplit(窗口列表1111, "`,")    ; 将窗口列表按 换行 分割成数组
    ; 遍历检查是否匹配
    for index, process in excludedProcesses {
        if WinActive("ahk_exe " process)
            屏蔽程序:="是"
        Break
    }

    if (屏蔽程序 !="是"){
        ;MsgBox, % 窗口列表2222
        SetTitleMatchMode, 2  ; 使用部分匹配窗口标题
        excludedProcesses2 := StrSplit(窗口列表2222, "`n")    ; 将窗口列表按 , 分割成数组
        ; 遍历检查是否匹配
        for index, process in excludedProcesses2 {
            if WinActive(process)
                return true  ; 找到匹配项，返回 true
        }
    }
    return false  ; 无匹配项，返回 false
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
;MsgBox, %NewList2%
return

Label_AdminLaunch: ; 管理员启动
    IniRead, 管理员启动, %A_ScriptDir%\个人配置.ini,基础配置,管理员启动
    if !(管理员启动="关闭")
        管理员启动:="开启"

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