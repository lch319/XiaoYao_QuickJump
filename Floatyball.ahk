; 编译exe文件信息及版本号设置
当前工具版本:="1.7.2"                  ;设置版本号
;@Ahk2Exe-Obey U_bits, = "%A_PtrSize%>4" ? "-64bit" : "-32bit"  ;判断位数
;@Ahk2Exe-Let U_version = %A_PriorLine~U)^(.+"){1}(.+)".*$~$2%  ;读取版本号以编译
;@Ahk2Exe-SetMainIcon Floatyball.ico          ; 指定托盘图标文件
;@Ahk2Exe-AddResource Floatyball.ico, 160      ; 替换自带的'蓝色H'图标
;@Ahk2Exe-AddResource Floatyball.ico, 206      ; 替换为 '绿色 S'
;@Ahk2Exe-AddResource Floatyball.ico, 207      ; 替换自带的'红色H'图标
;@Ahk2Exe-AddResource Floatyball.ico, 208      ; 替换为 '红色 S'
;@Ahk2Exe-ExeName %A_ScriptDir%\Floatyball%U_version%.exe  ; 打包后的exe文件路径
;@Ahk2Exe-SetCompanyName 逍遥xiaoyao        ; 企业信息
;@Ahk2Exe-SetCopyright 逍遥xiaoyao          ; 版权信息
;@Ahk2Exe-SetDescription 高度可自定义的多功能悬浮工具  ; 文件说明
;@Ahk2Exe-SetFileVersion %U_version%        ; 文件版本
;@Ahk2Exe-SetInternalName Floatyball        ; 文件内部名
;@Ahk2Exe-SetLanguage 0x0804            ; 区域语言
;@Ahk2Exe-SetName Floatyball          ; 名称
;@Ahk2Exe-SetProductName Floatyball        ; 产品名称
;@Ahk2Exe-SetOrigFilename Floatyball.exe      ; 原始文件名称
;@Ahk2Exe-SetProductVersion %U_version%        ; 产品版本号
;@Ahk2Exe-SetVersion %U_version%          ; 版本号

; --- 参数设置 ---
LastHoverTime:= 0       ; 记录最后一次悬停的时间戳
CurrentAlpha := 255     ; 记录当前实时透明度的变量

; --- 参数设置 ---
LastHoverTime:= 0       ; 记录最后一次悬停的时间戳
CurrentAlpha := 255     ; 记录当前实时透明度的变量

; =================== 【新增：权限与自启检测】 ===================
AdminLaunch := Var_Read("AdminLaunch","0","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否管理员运行
AutoRun := Var_Read("AutoRun","0","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否开机自启

; --- 管理员启动 ---
if (!A_IsAdmin && AdminLaunch="1")
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

; --- 开机自启检测 ---
Label_AutoRun(AutoRun)
; ================================================================

BallImage := Var_Read("BallImage","PokéBall.png","基础配置",A_ScriptDir "\Settings.ini","否") ; 图片文件名

BallImage := Var_Read("BallImage","PokéBall.png","基础配置",A_ScriptDir "\Settings.ini","否") ; 图片文件名
SnapRange := Var_Read("SnapRange","5","基础配置",A_ScriptDir "\Settings.ini","否")    ; 吸附感应距离
HideMargin := Var_Read("HideMargin","10","基础配置",A_ScriptDir "\Settings.ini","否") ; 隐藏后露出的宽度（像素）
HideDelay := Var_Read("HideDelay","800","基础配置",A_ScriptDir "\Settings.ini","否")  ; 吸附后多久开始隐藏 (毫秒)
maxBallSize := Var_Read("maxBallSize","300","基础配置",A_ScriptDir "\Settings.ini","否") ; 限制最大悬浮球大小
minBallSize := Var_Read("minBallSize","20","基础配置",A_ScriptDir "\Settings.ini","否")  ; 限制最小悬浮球大小
BallSizeIncrement := Var_Read("BallSizeIncrement","5","基础配置",A_ScriptDir "\Settings.ini","否") ; 每次滚轮滚动的增量
ShowTrayIcon := Var_Read("ShowTrayIcon","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否显示托盘图标
EnableWheelResize := Var_Read("EnableWheelResize","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否允许滚轮调节大小

GUI_X := Var_Read("GUI_X","","基础配置",A_ScriptDir "\Settings.ini","否") ;x坐标
GUI_Y := Var_Read("GUI_Y","","基础配置",A_ScriptDir "\Settings.ini","否") ;y坐标
; ==============================================================================
; --- 时间模式核心设置 (字体共用 BallSize 版) ---
; ==============================================================================

; 显示模式：Image=传统图片悬浮球，Time=纯文本时间悬浮条
DisplayMode := Var_Read("DisplayMode","Image","基础配置",A_ScriptDir "\Settings.ini","否")

; 时间格式：支持 AHK 的 FormatTime 语法。
; 例如 "HH:mm:ss" 显示 14:30:00，"yyyy-MM-dd" 显示日期。
; 支持输入 "\n" 实现强制换行双行显示，例如 "yyyy-MM-dd\nHH:mm:ss"
TimeFormat := Var_Read("TimeFormat","HH:mm:ss","基础配置",A_ScriptDir "\Settings.ini","否")
TimeFormat := StrReplace(TimeFormat, "\n", "`n")

; --- 文字样式设置 ---
; 字体名称：你电脑里安装的字体名，比如 "微软雅黑", "黑体", "Consolas"
TimeFont := Var_Read("TimeFont","微软雅黑","基础配置",A_ScriptDir "\Settings.ini","否")

; 字体颜色：ARGB 格式（8位16进制）。前2位是透明度(FF=完全不透明，00=完全透明)，后6位是RGB颜色(如 FFFFFF 是纯白)
TimeColor := Var_Read("TimeColor","FFFFFFFF","基础配置",A_ScriptDir "\Settings.ini","否")

; 字体大小比例：字号占悬浮球基础大小 (BallSize) 的比例。
; 比如 BallSize 是 50，比例 0.5，那字号就是 25。推荐在 0.4 ~ 0.6 之间。滚轮调整大小时会自动等比缩放。
TimeFontRatio := Var_Read("TimeFontRatio","0.4","基础配置",A_ScriptDir "\Settings.ini","否")

; 【修改】字体加粗：1=加粗，0=正常。(注：底层 GDI+ 绘图标准仅支持这两种粗细切换)
TimeFontBold := Var_Read("TimeFontBold","1","基础配置",A_ScriptDir "\Settings.ini","否")

; 文字垂直微调：填入具体数字(像素)。正数表示文字整体往下挪，负数表示往上挪。
; 用途：有些字体天生偏上或偏下，导致视觉上没有绝对垂直居中，用这个微调完美对齐。
TimeOffsetY := Var_Read("TimeOffsetY","0","基础配置",A_ScriptDir "\Settings.ini","否")

; --- 背景包裹边界设置 ---
; 背景开关：1=显示时间后面的圆角背景框，0=只显示漂浮的纯文字，完全透明无背景框
EnableTimeBg := Var_Read("EnableTimeBg","1","基础配置",A_ScriptDir "\Settings.ini","否")

; 背景颜色：ARGB 格式。比如 "66000000" 中，66 代表半透明，000000 代表纯黑色。
TimeBgColor := Var_Read("TimeBgColor","66000000","基础配置",A_ScriptDir "\Settings.ini","否")

; 背景圆角程度：控制背景框的圆润度。0=四四方方的直角矩形，0.2=稍微有点圆角，0.5=左右两边完全是半圆的胶囊/药丸形状
TimeCornerRatio := Var_Read("TimeCornerRatio","0.2","基础配置",A_ScriptDir "\Settings.ini","否")

; 左右留白：背景框的左边缘和右边缘，距离里面文字的像素距离。数值越大，背景条越长。
TimePaddingX := Var_Read("TimePaddingX","5","基础配置",A_ScriptDir "\Settings.ini","否")

; 上下留白：背景框的上边缘和下边缘，距离里面文字的像素距离。数值越大，背景条越胖。
TimePaddingY := Var_Read("TimePaddingY","5","基础配置",A_ScriptDir "\Settings.ini","否")

; ==============================================================================

; --- 动态透明度设置 ---
EnableDynamicOpacity := Var_Read("EnableDynamicOpacity","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否动态调整透明度
MinOpacity := Var_Read("MinOpacity","120","基础配置",A_ScriptDir "\Settings.ini","否")    ; 鼠标离开后的基础透明度
MaxOpacity := Var_Read("MaxOpacity","255","基础配置",A_ScriptDir "\Settings.ini","否") ; 鼠标进入后的最高透明度
FadeStep := Var_Read("FadeStep","15","基础配置",A_ScriptDir "\Settings.ini","否") ; 每次透明度变化的幅度（数值越大变色越快）
hideOpacity  := Var_Read("hideOpacity","150","基础配置",A_ScriptDir "\Settings.ini","否") ; 隐藏后的透明度
ThroughOpacity := Var_Read("ThroughOpacity","120","基础配置",A_ScriptDir "\Settings.ini","否") ; 新增：穿透模式下的固定透明度
MouseLeaveDelay := Var_Read("MouseLeaveDelay","1000","基础配置",A_ScriptDir "\Settings.ini","否") ; 鼠标离开后多久开始变透明（毫秒）

IsAlwaysOnTop   := Var_Read("IsAlwaysOnTop","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=强制置顶 0=否
IsLocked := Var_Read("IsLocked","0","基础配置",A_ScriptDir "\Settings.ini","否")        ; 1=固定位置禁止拖拽 0=否
; === 新增：鼠标穿透配置 ===
IsClickThrough := Var_Read("IsClickThrough","0","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=全鼠标穿透 0=否
IsLeftClickThroughOnly := Var_Read("IsLeftClickThroughOnly","0","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=仅左键穿透 0=否

SavePosition    := Var_Read("SavePosition","1","基础配置",A_ScriptDir "\Settings.ini","否")    ; 1=退出时保存位置 0=保持初始位置不变
SaveSize        := Var_Read("SaveSize","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=退出时保存大小 0=保持初始大小不变
HideInFullScreen:= Var_Read("HideInFullScreen","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=全屏时隐藏 0=否
EnableEdgeHide  := Var_Read("EnableEdgeHide","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=开启贴边隐藏 0=否
ShowCloseButton := Var_Read("ShowCloseButton","0","基础配置",A_ScriptDir "\Settings.ini","否") ; 1=显示关闭按钮 0=否
IsFullScreenHidden := false

BallSize := Var_Read("BallSize","50","基础配置",A_ScriptDir "\Settings.ini","否") ;悬浮球大小
ToggleHotkey := Var_Read("ToggleHotkey","#p","基础配置",A_ScriptDir "\Settings.ini","否") ; 全局显示/隐藏快捷键，默认 Alt+H (!h)
EnableHotkey := Var_Read("EnableHotkey","1","基础配置",A_ScriptDir "\Settings.ini","否") ; 是否启用全局快捷键
IsEditMode := 0 ; 编辑模式状态（运行时变量，退出重置为0）

; --- 关闭按钮设置 ---

CloseBtn_X := Var_Read("CloseBtn_X","18","基础配置",A_ScriptDir "\Settings.ini","否") ;关闭按钮的x坐标偏移（相对于悬浮球右边缘的距离）
CloseBtn_Y := Var_Read("CloseBtn_Y","14","基础配置",A_ScriptDir "\Settings.ini","否") ;关闭按钮的y坐标偏移（相对于悬浮球上边缘的距离）
CloseBtn_Size := Var_Read("CloseBtn_Size","20","基础配置",A_ScriptDir "\Settings.ini","否") ;关闭按钮的大小（保持正方形）
CloseBtn_HideTime := Var_Read("CloseBtn_HideTime","400","基础配置",A_ScriptDir "\Settings.ini","否") ;鼠标离开后，按钮继续显示的时间（毫秒），建议 500-1000
CloseBtn_Thickness := Var_Read("CloseBtn_Thickness","3","基础配置",A_ScriptDir "\Settings.ini","否") ;关闭按钮的粗细
CloseBtn_VisualMargin := Var_Read("CloseBtn_VisualMargin","5","基础配置",A_ScriptDir "\Settings.ini","否") ;关闭按钮的视觉边距
CloseBtnAction := Var_Read("CloseBtnAction","0","基础配置",A_ScriptDir "\Settings.ini","否")  ; 关闭按钮的功能类型，默认0=退出程序 1=隐藏悬浮球

; --- 占位符相关：落地文件与获取选中内容配置 ---
MaxTempFiles := Var_Read("MaxTempFiles","10","基础配置",A_ScriptDir "\Settings.ini","否") ; 每种落地临时文件最多保留的个数
SelectedCopyKey := Var_Read("SelectedCopyKey","^c","基础配置",A_ScriptDir "\Settings.ini","否") ; 获取选中内容的复制快捷键
SelectedWaitTime := Var_Read("SelectedWaitTime","0.15","基础配置",A_ScriptDir "\Settings.ini","否") ; 获取选中内容的最长等待时间(秒)

; ==============================================================================
; --- 新增：配置管理设置 ---
; ==============================================================================
CfgMgr_UserConfigDir := Var_Read("UserConfigDir", A_ScriptDir "\UserConfig", "基础配置", A_ScriptDir "\Settings.ini", "否")
CfgMgr_EnableAutoBackup := Var_Read("EnableAutoBackup", "1", "基础配置", A_ScriptDir "\Settings.ini", "否")
CfgMgr_MaxBackupCount := Var_Read("MaxBackupCount", "10", "基础配置", A_ScriptDir "\Settings.ini", "否")

; 确保配置和备份目录存在
if !InStr(FileExist(CfgMgr_UserConfigDir), "D")
    FileCreateDir, %CfgMgr_UserConfigDir%
if !InStr(FileExist(CfgMgr_UserConfigDir "\backup"), "D")
    FileCreateDir, % CfgMgr_UserConfigDir "\backup"

; ==============================================================================
; --- 新增：悬停面板配置读取 (自动保存于 Settings.ini 的 [悬停面板] 段落) ---
; ==============================================================================
HoverPanel_Enable := Var_Read("Enable", "1", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 是否启用悬停面板 (1=启用, 0=停用)
HoverPanel_HideOnLeftClickThrough := Var_Read("HideOnLeftClickThrough", "1", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 仅左键穿透时禁用悬停面板
HoverPanel_ShowDelay := Var_Read("ShowDelay", "350", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 鼠标悬浮多少毫秒后触发显示
HoverPanel_HideDelay := Var_Read("HideDelay", "200", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 鼠标移出多少毫秒后触发隐藏
HoverPanel_Width := Var_Read("Width", "330", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 悬停面板的固定宽度 (像素)
HoverPanel_BgColor := Var_Read("BgColor", "2B2B2B", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 面板背景色 (Hex格式)
HoverPanel_FontColor := Var_Read("FontColor", "FFFFFF", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 面板文字色 (Hex格式)
HoverPanel_IconSize := Var_Read("IconSize", "20", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 左侧图标的尺寸
HoverPanel_ItemHeight := Var_Read("ItemHeight", "23", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 单个菜单项的垂直行高间距
HoverPanel_FontSize := Var_Read("FontSize", "10", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 菜单项文字大小
HoverPanel_FontName := Var_Read("FontName", "微软雅黑", "悬停面板", A_ScriptDir "\Settings.ini", "否")  ; 菜单项字体名称
HoverPanel_TextOffsetY := Var_Read("TextOffsetY", "-6", "悬停面板", A_ScriptDir "\Settings.ini", "否")  ; 文字垂直偏移（负数向上，正数向下）

HoverPanel_ItemWidth := Var_Read("ItemWidth", "155", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 单个菜单项的固定宽度
HoverPanel_GUIHeight := Var_Read("GUIHeight", "300", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; gui窗口的整体最低高度

; ▼▼▼ 新增：悬停高亮配置 ▼▼▼
HoverPanel_EnableHoverHighlight := Var_Read("EnableHoverHighlight", "1", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 是否启用悬停高亮
HoverPanel_HoverBgColor := Var_Read("HoverBgColor", "404040", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 悬停高亮背景色
HoverPanel_HoverCornerRadius := Var_Read("HoverCornerRadius", "5", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 悬停高亮背景的圆角大小(填0为直角)

HoverPanel_ShowTooltip := Var_Read("ShowTooltip", "1", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 是否显示悬停提示
HoverPanel_ShowItemIcon := Var_Read("ShowItemIcon", "1", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 是否显示菜单项图标
HoverPanel_TooltipDelay := Var_Read("TooltipDelay", "600", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 悬停提示延迟触发(毫秒)
HoverPanel_Margin := Var_Read("Margin", "8", "悬停面板", A_ScriptDir "\Settings.ini", "否") ; 面板的全局边缘间距

; === 新增：加载全局主题配色 ===
GoSub, LoadThemeConfig

;; 声明悬停面板所需的运行时全局变量

global HoverPanel_ShowTooltip, HoverPanel_TooltipDelay
global CurrentTooltipControl := "", HoverTooltipLastCtrl := ""
global HoverPanel_EnableHoverHighlight, HoverPanel_HoverBgColor, HoverPanel_HoverCornerRadius
global hHoverPanel, isHoverPanelPinned := false, HoverPanel_Margin

global hHoverPanel, isHoverPanelPinned := false
global HoverGroups := [], HoverItemsData := [], CurrentHoverGroup := ""
global HoverPanelVisible := false, HoverTriggerTime := 0, LastPanelActiveTime := 0
global isHoverPanelEditMode := false       ; 【新增】标记是否处于批量删除模式
global HoverPanelSelectedItems := {}       ; 【新增】存储被选中的项目索引

; --- 悬浮球点击事件配置 ---
; 左键单击
LBtn_Enable := Var_Read("启用","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Type   := Var_Read("功能类型","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Param  := Var_Read("功能参数","https://www.baidu.com/s?wd={$Selected_loop$}","左键单击事件",A_ScriptDir "\Settings.ini","否","否")
LBtn_Enable_ctrl := Var_Read("启用_ctrl","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Type_ctrl   := Var_Read("功能类型_ctrl","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Param_ctrl  := Var_Read("功能参数_ctrl","","左键单击事件",A_ScriptDir "\Settings.ini","否","否")
LBtn_Enable_alt  := Var_Read("启用_alt","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Type_alt    := Var_Read("功能类型_alt","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Param_alt   := Var_Read("功能参数_alt","","左键单击事件",A_ScriptDir "\Settings.ini","否","否")
LBtn_Enable_shift := Var_Read("启用_shift","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Type_shift   := Var_Read("功能类型_shift","1","左键单击事件",A_ScriptDir "\Settings.ini","否")
LBtn_Param_shift  := Var_Read("功能参数_shift","","左键单击事件",A_ScriptDir "\Settings.ini","否","否")

; 中键单击
MBtn_Enable := Var_Read("启用","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Type   := Var_Read("功能类型","6","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Param  := Var_Read("功能参数","MsgBox, {$AHK_Var|A_YYYY$}年{$AHK_Var|A_MM$}月{$AHK_Var|A_DD$}日","中键单击事件",A_ScriptDir "\Settings.ini","否","否")
MBtn_Enable_ctrl := Var_Read("启用_ctrl","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Type_ctrl   := Var_Read("功能类型_ctrl","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Param_ctrl  := Var_Read("功能参数_ctrl","","中键单击事件",A_ScriptDir "\Settings.ini","否","否")
MBtn_Enable_alt  := Var_Read("启用_alt","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Type_alt    := Var_Read("功能类型_alt","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Param_alt   := Var_Read("功能参数_alt","","中键单击事件",A_ScriptDir "\Settings.ini","否","否")
MBtn_Enable_shift := Var_Read("启用_shift","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Type_shift   := Var_Read("功能类型_shift","1","中键单击事件",A_ScriptDir "\Settings.ini","否")
MBtn_Param_shift  := Var_Read("功能参数_shift","","中键单击事件",A_ScriptDir "\Settings.ini","否","否")

; 滚轮向上
WheelUp_Enable := Var_Read("启用","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Type   := Var_Read("功能类型","2","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Param  := Var_Read("功能参数","{Volume_Up}","滚轮向上事件",A_ScriptDir "\Settings.ini","否","否")
WheelUp_Enable_ctrl := Var_Read("启用_ctrl","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Type_ctrl   := Var_Read("功能类型_ctrl","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Param_ctrl  := Var_Read("功能参数_ctrl","","滚轮向上事件",A_ScriptDir "\Settings.ini","否","否")
WheelUp_Enable_alt  := Var_Read("启用_alt","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Type_alt    := Var_Read("功能类型_alt","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Param_alt   := Var_Read("功能参数_alt","","滚轮向上事件",A_ScriptDir "\Settings.ini","否","否")
WheelUp_Enable_shift := Var_Read("启用_shift","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Type_shift   := Var_Read("功能类型_shift","1","滚轮向上事件",A_ScriptDir "\Settings.ini","否")
WheelUp_Param_shift  := Var_Read("功能参数_shift","","滚轮向上事件",A_ScriptDir "\Settings.ini","否","否")

; 滚轮向下
WheelDown_Enable := Var_Read("启用","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Type   := Var_Read("功能类型","2","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Param  := Var_Read("功能参数","{Volume_Down}","滚轮向下事件",A_ScriptDir "\Settings.ini","否","否")
WheelDown_Enable_ctrl := Var_Read("启用_ctrl","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Type_ctrl   := Var_Read("功能类型_ctrl","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Param_ctrl  := Var_Read("功能参数_ctrl","","滚轮向下事件",A_ScriptDir "\Settings.ini","否","否")
WheelDown_Enable_alt  := Var_Read("启用_alt","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Type_alt    := Var_Read("功能类型_alt","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Param_alt   := Var_Read("功能参数_alt","","滚轮向下事件",A_ScriptDir "\Settings.ini","否","否")
WheelDown_Enable_shift := Var_Read("启用_shift","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Type_shift   := Var_Read("功能类型_shift","1","滚轮向下事件",A_ScriptDir "\Settings.ini","否")
WheelDown_Param_shift  := Var_Read("功能参数_shift","","滚轮向下事件",A_ScriptDir "\Settings.ini","否","否")

; --- 拖放事件配置 ---
DropFile_Enable := Var_Read("启用","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Type   := Var_Read("功能类型","6","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Param  := Var_Read("功能参数","MsgBox, {$Dropped_allfile$|-i}","拖放事件_文件",A_ScriptDir "\Settings.ini","否","否")
DropFile_Enable_ctrl := Var_Read("启用_ctrl","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Type_ctrl   := Var_Read("功能类型_ctrl","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Param_ctrl  := Var_Read("功能参数_ctrl","","拖放事件_文件",A_ScriptDir "\Settings.ini","否","否")
DropFile_Enable_alt  := Var_Read("启用_alt","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Type_alt    := Var_Read("功能类型_alt","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Param_alt   := Var_Read("功能参数_alt","","拖放事件_文件",A_ScriptDir "\Settings.ini","否","否")
DropFile_Enable_shift := Var_Read("启用_shift","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Type_shift   := Var_Read("功能类型_shift","1","拖放事件_文件",A_ScriptDir "\Settings.ini","否")
DropFile_Param_shift  := Var_Read("功能参数_shift","","拖放事件_文件",A_ScriptDir "\Settings.ini","否","否")

DropText_Enable := Var_Read("启用","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Type   := Var_Read("功能类型","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Param  := Var_Read("功能参数","""{$Dropped_texttofile$}""","拖放事件_文本",A_ScriptDir "\Settings.ini","否","否")
DropText_Enable_ctrl := Var_Read("启用_ctrl","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Type_ctrl   := Var_Read("功能类型_ctrl","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Param_ctrl  := Var_Read("功能参数_ctrl","","拖放事件_文本",A_ScriptDir "\Settings.ini","否","否")
DropText_Enable_alt  := Var_Read("启用_alt","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Type_alt    := Var_Read("功能类型_alt","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Param_alt   := Var_Read("功能参数_alt","","拖放事件_文本",A_ScriptDir "\Settings.ini","否","否")
DropText_Enable_shift := Var_Read("启用_shift","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Type_shift   := Var_Read("功能类型_shift","1","拖放事件_文本",A_ScriptDir "\Settings.ini","否")
DropText_Param_shift  := Var_Read("功能参数_shift","","拖放事件_文本",A_ScriptDir "\Settings.ini","否","否")

; --- 环境初始化 ---
#SingleInstance Force   ;~运行替换旧实例
;#Include *i %A_ScriptDir%\..\RunAny_ObjReg.ahk
#Include %A_ScriptDir%\lib\Gdip_All.ahk
;#Include %A_ScriptDir%\lib\Helper_function.ahk
SetWinDelay, -1
SetBatchLines, -1
CoordMode, Mouse, Screen

If !pToken := Gdip_Startup() {
    MsgBox, 48, 错误， GDI+ 启动失败！
    ExitApp
}

IconDir := A_ScriptDir "\Icons"
if !FileExist(IconDir)
    FileCreateDir, %IconDir%

; --- 1. 初始化 OLE 环境 ---
DllCall("ole32\OleInitialize", "Ptr", 0)

; 创建窗口：增加 +E0x8 (置顶) 和 +E0x80000 (分层)
Gui, -Caption +E0x80000 +LastFound +AlwaysOnTop +HwndhBall +E0x08000000
If (GUI_X = "" && GUI_Y = "") {
    Gui, Show, xCenter yCenter w%BallSize% h%BallSize% Na, FloatingBall悬浮球
} else {
    Gui, Show, x%GUI_X% y%GUI_Y% w%BallSize% h%BallSize% Na, FloatingBall悬浮球
}

; === 新增：初始化鼠标穿透状态 ===
if (IsClickThrough = "1")
    WinSet, ExStyle, +0x20, ahk_id %hBall%
; --- 核心：向 Windows 注册本窗口为 OLE 拖拽目标 ---
pDropTarget := CreateDropTargetStruct()
DllCall("ole32\RegisterDragDrop", "Ptr", hBall, "Ptr", pDropTarget)

; --- 关闭按钮 GDI+ 初始化 ---
Gui, CloseBtn: -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +HwndhCloseBtn
Gui, CloseBtn: Show, % "x0 y0 w" CloseBtn_Size " h" CloseBtn_Size " Na", CloseButton悬浮球
CloseBtn_Hover := false ; 记录按钮自身的悬停状态

WinGetPos, StartX, StartY,,, ahk_id %hBall%
; 确保变量有初始值，防止第一次计算位移时出现空值

; --- 动画相关的变量初始化 ---
global IsGif := false
global GifFrameCount := 1
global GifCurrentFrame := 0
global GifDelays := []
global GifDimensionID
VarSetCapacity(GifDimensionID, 16, 0)

; 变量初始化
IsDocked := false
IsHidden := false
CurrentEdge := ""
LastMoveTime := A_TickCount
BallLastHoverTime := 0

; --- 新增：检查悬浮球图片是否存在，若不存在则寻找下一个 png/gif ---
TargetPath := IconDir "\" BallImage
if !FileExist(TargetPath) {
    FallbackFound := false
    Loop, Files, %IconDir%\*.*
    {
        if (A_LoopFileExt = "png" || A_LoopFileExt = "gif") {
            BallImage := A_LoopFileName
            TargetPath := IconDir "\" BallImage
            FallbackFound := true
            ; 将新找到的可用图片写回配置文件，防止下次启动仍报错
            Var_Set(BallImage, "PokéBall.png", "BallImage", "基础配置", A_ScriptDir "\Settings.ini")
            break ; 找到第一个合适的就退出循环
        }
    }

    ; 如果连一张 png/gif 都没找到的极端情况防错
    if (!FallbackFound) {
        MsgBox, 48, 错误, Icons 文件夹中未找到任何可用的 .png 或 .gif 图片！`n请放入图片后重试。
        ExitApp
    }
}

; 载入图片 (使用新增的支持 GIF 的自定义函数)
LoadBallImage(TargetPath)

LastMoveTime := A_TickCount
BallLastHoverTime := 0  ; 记录鼠标离开悬浮球的基准时间戳

; 首次显示：直接调用更新函数，这会自动设置窗口的初始位置
UpdateBallDisplay(hBall, pBitmap, StartX, StartY, BallSize, MaxOpacity)
; 首次运行执行一次吸附检查
GoSub, HandleSnapping

SetTimer, WatchMouse, 30

; --- 新增：时钟刷新定时器 ---
SetTimer, UpdateTimeLoop, 1000

; --- 新增：如果初始状态是时间模式，清空图片留边数据并暂停 GIF ---
if (DisplayMode = "Time") {
    ImgPadL_Ratio := 0, ImgPadR_Ratio := 0, ImgPadT_Ratio := 0, ImgPadB_Ratio := 0
    SetTimer, UpdateGifFrame, Off
}

; 初始化托盘图标显示状态
if (ShowTrayIcon = "0")
    Menu, Tray, NoIcon
else
    Menu, Tray, Icon

; 拦截托盘图标鼠标消息 (实现左键显示，右键打开悬浮球菜单)
OnMessage(0x404, "AHK_NOTIFYICON")
OnMessage(0x0200, "WM_MOUSEMOVE") ; 注册鼠标移动事件，用于处理悬停面板的 ToolTip

; --- 注册全局显示/隐藏快捷键 ---
if (ToggleHotkey != "") {
    Hotkey, %ToggleHotkey%, ToggleBallVisibility, UseErrorLevel
    if (EnableHotkey != "1")
        Hotkey, %ToggleHotkey%, Off ; 如果配置不启用，则关闭热键
}

IconDir := A_ScriptDir "\Icons"
if !FileExist(IconDir)
    FileCreateDir, %IconDir%

; 【新增】初始化读取悬停面板配置文件
LoadHoverItems()

OnExit, 退出时运行
return

;═════════════════════════════════设置鼠标左键移动窗口═════════════════════════════════════════════════
; === 新增：优先处理仅左键穿透逻辑 ===
#If MouseIsHwnd(hBall) && (IsLeftClickThroughOnly = "1")
    *LButton::
        ; 瞬间开启鼠标穿透，让当前的点击事件落到底层窗口
        WinSet, ExStyle, +0x20, ahk_id %hBall%
        SendInput {Blind}{LButton Down}
        KeyWait, LButton
        SendInput {Blind}{LButton Up}
        ; 松开左键后，立即恢复悬浮球为不可穿透状态
        WinSet, ExStyle, -0x20, ahk_id %hBall%
    return

#If MouseIsHwnd(hBall)
    *~LButton::
        SetWinDelay, -1

        ; 2. 记录【按下瞬间】的初始状态（绝对基准点，同时获取真实宽高）
        MouseGetPos, StartMouseX, StartMouseY
        WinGetPos, StartWinX, StartWinY, StartWinW, StartWinH, ahk_id %hBall%

        ; 判定是否移动过的标记
        HasMoved := false

        ; 只要左键还处于按下状态（逻辑或物理），就持续循环
        While GetKeyState("LButton", "P")
        {
            MouseGetPos, CurrentMouseX, CurrentMouseY

            ; 计算鼠标相对于初始位置的偏移量
            DeltaX := CurrentMouseX - StartMouseX
            DeltaY := CurrentMouseY - StartMouseY

            ; 如果偏移超过2像素，才认为开始拖拽（防手抖，防误触点击）
            if (!HasMoved && (Abs(DeltaX) > 2 || Abs(DeltaY) > 2)) {
                HasMoved := true

                ; ▼▼▼ 【修复】：一旦判定为拖拽，仅在面板【未固定】时才销毁它 ▼▼▼
                if (HoverPanelVisible && !isHoverPanelPinned) {
                    DllCall("ole32\RevokeDragDrop", "Ptr", hHoverPanel) ; <--- 新增
                    Gui, HoverPanel: Destroy
                    HoverPanelVisible := false
                    HoverTriggerTime := 0
                }
                ; ▲▲▲ ========================================================== ▲▲▲
            }

            if (HasMoved && IsLocked != "1")
            {
                TargetX := StartWinX + DeltaX
                TargetY := StartWinY + DeltaY

                SysGet, Mon, MonitorWorkArea
                curPadL := Round(ImgPadL_Ratio * BallSize)
                curPadR := Round(ImgPadR_Ratio * BallSize)
                curPadT := Round(ImgPadT_Ratio * BallSize)
                curPadB := Round(ImgPadB_Ratio * BallSize)

                ; 【修改点】：使用 StartWinW/StartWinH 代替原本硬编码的 BallSize 防越界
                if (TargetX + curPadL < MonLeft)
                    TargetX := MonLeft - curPadL
                if (TargetX + StartWinW - curPadR > MonRight)
                    TargetX := MonRight - StartWinW + curPadR

                if (TargetY + curPadT < MonTop)
                    TargetY := MonTop - curPadT
                if (TargetY + StartWinH - curPadB > MonBottom)
                    TargetY := MonBottom - StartWinH + curPadB

                ; 5. 更新显示
                UpdateBallDisplay(hBall, pBitmap, TargetX, TargetY, BallSize, MaxOpacity)

                ; 同步更新关闭按钮（如果开启）
                if (ShowCloseButton = "1") {
                    ; 【修复】使用真实宽度 StartWinW 计算，并用 WinMove 平滑移动防闪烁
                    cbX := TargetX + StartWinW - CloseBtn_X
                    cbY := TargetY - CloseBtn_Y
                    WinMove, ahk_id %hCloseBtn%,, %cbX%, %cbY%

                    ; 确保拖拽时按钮不会意外消失
                    if !DllCall("IsWindowVisible", "Ptr", hCloseBtn)
                        Gui, CloseBtn: Show, Na
                }
            }
            Sleep, 10 ; 降低 CPU 占用，保持流畅
        }

        ; 6. 鼠标松开后的最终处理
        MouseGetPos,,, EndWin ; 【新增】获取松开鼠标那一刻，鼠标指针下的窗口句柄
        if (IsLocked != "1") {
            ;没固定位置时，需要区分是“拖拽”还是“点击”
            if (HasMoved) {
                ; 发生过拖拽，松开时触发吸附逻辑
                GoSub, HandleSnapping
            } else if (EndWin = hBall) {
                ; 没有拖拽位移，且在球上松开，触发左键点击
                GoSub, LeftClickAction
            }
        } else {
            ; 没有位移，触发点击事件
            if (HasMoved)
                GoSub, HandleSnapping
            else if (EndWin = hBall) ; 【优化】确保没移动且松开时在球上才触发
                GoSub, LeftClickAction
        }

    return

    *~WheelUp:: ; 滚轮向上
        if (EnableWheelResize = "1") {
            BallSize += BallSizeIncrement
            if (BallSize > maxBallSize)
                BallSize := maxBallSize
            GoSub, ApplyNewSize
        } else {
            finalEnable := WheelUp_Enable, finalType := WheelUp_Type, finalParam := WheelUp_Param
            if (GetKeyState("Ctrl", "P") && WheelUp_Enable_ctrl == "1")
                finalEnable := WheelUp_Enable_ctrl, finalType := WheelUp_Type_ctrl, finalParam := WheelUp_Param_ctrl
            else if (GetKeyState("Alt", "P") && WheelUp_Enable_alt == "1")
                finalEnable := WheelUp_Enable_alt, finalType := WheelUp_Type_alt, finalParam := WheelUp_Param_alt
            else if (GetKeyState("Shift", "P") && WheelUp_Enable_shift == "1")
                finalEnable := WheelUp_Enable_shift, finalType := WheelUp_Type_shift, finalParam := WheelUp_Param_shift

            ExecuteAction(finalEnable, finalType, finalParam)
        }
    return

    *~WheelDown:: ; 滚轮向下
        if (EnableWheelResize = "1") {
            BallSize -= BallSizeIncrement
            if (BallSize < minBallSize)
                BallSize := minBallSize
            GoSub, ApplyNewSize
        } else {
            finalEnable := WheelDown_Enable, finalType := WheelDown_Type, finalParam := WheelDown_Param
            if (GetKeyState("Ctrl", "P") && WheelDown_Enable_ctrl == "1")
                finalEnable := WheelDown_Enable_ctrl, finalType := WheelDown_Type_ctrl, finalParam := WheelDown_Param_ctrl
            else if (GetKeyState("Alt", "P") && WheelDown_Enable_alt == "1")
                finalEnable := WheelDown_Enable_alt, finalType := WheelDown_Type_alt, finalParam := WheelDown_Param_alt
            else if (GetKeyState("Shift", "P") && WheelDown_Enable_shift == "1")
                finalEnable := WheelDown_Enable_shift, finalType := WheelDown_Type_shift, finalParam := WheelDown_Param_shift

            ExecuteAction(finalEnable, finalType, finalParam)
        }
    return

    ApplyNewSize:
        WinGetPos, curX, curY,,, ahk_id %hBall%
        ; 立即重新绘制图片
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
        ; 调整大小后建议重新检查一次吸附状态，防止变大后超出屏幕
        GoSub, HandleSnapping
    return

    *RButton:: return  ; 拦截右键按下事件，防止系统产生多余焦点变化
    *RButton up:: GoSub, RightClickAction

    *MButton:: return  ; 同样拦截中键按下事件
    *MButton up:: GoSub, MiddleClickAction
#If

#If MouseIsHwnd(hCloseBtn)
    *~LButton::
        if (CloseBtnAction = "1") {
            ; 隐藏到托盘（如果未启用托盘图标，会临时显示图标）
            GoSub, HideToTray
        } else {
            ; 正常退出（会执行保存位置等清理工作）
            GoSub, 退出时运行
        }
    return
#If
return

;═════════════════════════════════ 编辑模式热键 ═════════════════════════════════════════════════
#If IsEditMode
    Up:: MoveBallBy(0, -5)
    Down:: MoveBallBy(0, 5)
    Left:: MoveBallBy(-5, 0)
    Right:: MoveBallBy(5, 0)

    NumpadAdd::
    =::
    +::
        BallSize += BallSizeIncrement
        if (BallSize > maxBallSize)
            BallSize := maxBallSize
        GoSub, ApplyNewSize
    return

    NumpadSub::
    -::
        BallSize -= BallSizeIncrement
        if (BallSize < minBallSize)
            BallSize := minBallSize
        GoSub, ApplyNewSize
    return
#If

; 辅助移动函数
MoveBallBy(dx, dy) {
    global hBall, pBitmap, BallSize, CurrentAlpha, ImgPadL_Ratio, ImgPadR_Ratio, ImgPadT_Ratio, ImgPadB_Ratio
    ; 【修改点】：获取真实的 curW 和 curH
    WinGetPos, curX, curY, curW, curH, ahk_id %hBall%
    TargetX := curX + dx
    TargetY := curY + dy

    SysGet, Mon, MonitorWorkArea
    curPadL := Round(ImgPadL_Ratio * BallSize)
    curPadR := Round(ImgPadR_Ratio * BallSize)
    curPadT := Round(ImgPadT_Ratio * BallSize)
    curPadB := Round(ImgPadB_Ratio * BallSize)

    if (TargetX + curPadL < MonLeft)
        TargetX := MonLeft - curPadL
    ; 【修改点】：用实时宽度 curW 计算右边缘
    if (TargetX + curW - curPadR > MonRight)
        TargetX := MonRight - curW + curPadR
    if (TargetY + curPadT < MonTop)
        TargetY := MonTop - curPadT
    if (TargetY + curH - curPadB > MonBottom)
        TargetY := MonBottom - curH + curPadB

    UpdateBallDisplay(hBall, pBitmap, TargetX, TargetY, BallSize, CurrentAlpha)
}

HandleSnapping:
    WinGetPos, CurX, CurY, CurW, CurH, ahk_id %hBall%
    SysGet, Mon, MonitorWorkArea

    curPadL := Round(ImgPadL_Ratio * BallSize)
    curPadR := Round(ImgPadR_Ratio * BallSize)
    curPadT := Round(ImgPadT_Ratio * BallSize)
    curPadB := Round(ImgPadB_Ratio * BallSize)

    ; 初始目标位置即为当前位置
    TargetX := CurX
    TargetY := CurY
    IsDocked := false
    CurrentEdge := ""

    ; 计算图案主体当前在屏幕上的真实坐标
    ContentLeft  := CurX + curPadL
    ContentRight := CurX + CurW - curPadR
    ContentTop   := CurY + curPadT

    ; --- 1. 吸附判定 ---
    if (ContentLeft < MonLeft + SnapRange) {
        TargetX := MonLeft - curPadL, IsDocked := true, CurrentEdge := "L"
    }
    else if (ContentRight > MonRight - SnapRange) {
        TargetX := MonRight - CurW + curPadR, IsDocked := true, CurrentEdge := "R"
    }
    else if (ContentTop < MonTop + SnapRange) {
        TargetY := MonTop - curPadT, IsDocked := true, CurrentEdge := "T"
    }

    ; --- 2. 边界强制修正 (确保图案主体不超出屏幕工作区) ---
    if (TargetX + curPadL < MonLeft)
        TargetX := MonLeft - curPadL
    if (TargetX + CurW - curPadR > MonRight)
        TargetX := MonRight - CurW + curPadR
    if (TargetY + curPadT < MonTop)
        TargetY := MonTop - curPadT
    if (TargetY + CurH - curPadB > MonBottom)
        TargetY := MonBottom - CurH + curPadB

    UpdateBallDisplay(hBall, pBitmap, TargetX, TargetY, BallSize, CurrentAlpha)

    if (IsDocked) {
        LastMoveTime := A_TickCount
        IsHidden := false
    }
return

; --- 鼠标监控 ---
WatchMouse:
    ; --- 2. 全屏自动隐藏检测 ---
    if (HideInFullScreen = "1") {
        WinGet, actWin, ID, A
        WinGetClass, actClass, ahk_id %actWin%
        WinGetPos, ax, ay, aw, ah, ahk_id %actWin%
        SysGet, mon, Monitor
        ; 判断是否全屏且不是桌面背景
        if (actClass != "WorkerW" && actClass != "Progman" && ax <= monLeft && ay <= monTop && aw >= (monRight-monLeft) && ah >= (monBottom-monTop)) {
            if (!IsFullScreenHidden) {
                ; 【补充修复】全屏隐藏前记录坐标
                WinGetPos, preHideX, preHideY,,, ahk_id %hBall%

                WinHide, ahk_id %hBall%
                WinHide, ahk_id %hCloseBtn%
                IsFullScreenHidden := true
            }
            return ; 全屏状态下直接跳过后续的透明度和位置计算
        } else if (IsFullScreenHidden) {
            ; 【补充修复】全屏结束重新显示前，强制刷回原坐标
            if (preHideX != "" && preHideY != "") {
                UpdateBallDisplay(hBall, pBitmap, preHideX, preHideY, BallSize, CurrentAlpha)
            }

            WinShow, ahk_id %hBall%
            IsFullScreenHidden := false
            ; 【新增】全屏结束重新显示时，恢复动画
            if (IsGif)
                GoSub, UpdateGifFrame
        }
    }

    if (IsAlwaysOnTop = "1" && !IsFullScreenHidden) {
        WinSet, AlwaysOnTop, On, ahk_id %hBall%
    }

    if (GetKeyState("LButton", "P"))
        return

    ; --- 将原有的 IsHovered 判定替换为以下内容 ---
    MouseGetPos, mx, my, mWin
    IsOnBall := (mWin = hBall)
    IsOnClose := (mWin = hCloseBtn)
    IsOnHoverPanel := (mWin = hHoverPanel) ; 【新增】判断鼠标是否在悬停面板上
    IsHovered := (IsOnBall || IsOnClose || IsOnHoverPanel || IsMenuOpen) ; 【终极修改】加入菜单展开状态，防止菜单跑到外面时面板消失

    ; ▼▼▼ 新增：鼠标离开面板时，立即清除悬停提示 ▼▼▼
    if (!IsOnHoverPanel && HoverTooltipLastCtrl != "") {
        ToolTip
        SetTimer, ShowHoverTooltip, Off
        HoverTooltipLastCtrl := ""
        CurrentTooltipControl := ""
    }

    ; 只要鼠标在球、按钮或面板上，就刷新时间戳
    if (IsHovered)
        BallLastHoverTime := A_TickCount

    ; =================================================================
    ; 【新增】悬停面板的触发与自动隐藏逻辑
    ; =================================================================

    ; ▼▼▼ 新增：判断是否因为穿透设置而需要禁用悬停面板 ▼▼▼
    DisablePanelByClickThrough := (IsClickThrough = "1") || (IsLeftClickThroughOnly = "1" && HoverPanel_HideOnLeftClickThrough = "1")

    if (HoverPanel_Enable = "1" && !IsEditMode && !IsHidden && !DisablePanelByClickThrough) {
        if (IsHovered) {
            LastPanelActiveTime := A_TickCount
            if (!HoverPanelVisible && !isHoverPanelPinned) {
                if (HoverTriggerTime = 0)
                    HoverTriggerTime := A_TickCount
                else if (A_TickCount - HoverTriggerTime > HoverPanel_ShowDelay) {
                    GoSub, ShowHoverPanelGUI
                    HoverTriggerTime := 0
                }
            }
        } else {
            HoverTriggerTime := 0 ; 鼠标离开，重置触发进度
            ; 离开时间超过设定延迟，且没有开启图钉固定时，销毁面板
            if (HoverPanelVisible && !isHoverPanelPinned && (A_TickCount - LastPanelActiveTime > HoverPanel_HideDelay)) {
                DllCall("ole32\RevokeDragDrop", "Ptr", hHoverPanel)
                Gui, HoverPanel: Destroy
                HoverPanelVisible := false
            }
        }
    } else {
        HoverTriggerTime := 0
        if (HoverPanelVisible) {
            GoSub, CloseHoverPanel
        }
    }

    ; --- 关闭按钮的状态切换 ---
    if (IsOnClose != CloseBtn_Hover) {
        CloseBtn_Hover := IsOnClose
        UpdateCloseBtnDisplay(hCloseBtn,CloseBtn_Size,CloseBtn_Thickness, CloseBtn_VisualMargin, CloseBtn_Hover, CurrentAlpha)
    }

    ; --- 修改后的透明度逻辑 ---
    if (IsClickThrough = "1" || IsLeftClickThroughOnly = "1") {
        TargetAlpha := ThroughOpacity ; 穿透模式下，强制关闭动态透明度，使用专属固定透明度
    } else if (IsEditMode || IsHovered || (A_TickCount - BallLastHoverTime < MouseLeaveDelay) || EnableDynamicOpacity = "0") {
        TargetAlpha := MaxOpacity ; 鼠标悬停、离开时间未到，或者【关闭了动态透明度】时，保持最高透明度
    } else {
        TargetAlpha := MinOpacity ; 超过延迟且开启了动态透明度时，进入淡出逻辑
    }

    if (IsHidden) {
        TargetAlpha := hideOpacity ; 如果触发了贴边隐藏，强制使用隐藏透明度覆盖上述逻辑
    }

    if (CurrentAlpha != TargetAlpha) {
        if (CurrentAlpha < TargetAlpha)
            CurrentAlpha := ((CurrentAlpha + FadeStep) > TargetAlpha) ? TargetAlpha : (CurrentAlpha + FadeStep)
        else
            CurrentAlpha := ((CurrentAlpha - FadeStep) < TargetAlpha) ? TargetAlpha : (CurrentAlpha - FadeStep)

        WinGetPos, curX, curY,,, ahk_id %hBall%
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
        UpdateCloseBtnDisplay(hCloseBtn,CloseBtn_Size,CloseBtn_Thickness, CloseBtn_VisualMargin, CloseBtn_Hover, CurrentAlpha)
    }

    ; --- 关闭按钮显示/位置控制 (核心修改处) ---
    if (ShowCloseButton = "1" && IsHovered && !IsHidden) {   ; <--- 这里加上了 ShowCloseButton = "1"
        LastHoverTime := A_TickCount ; 只要还在球或按钮上，就不断更新时间戳

        WinGetPos, bx, by, bw, bh, ahk_id %hBall%
        btnX := bx + bw - CloseBtn_X
        btnY := by - CloseBtn_Y

        WinMove, ahk_id %hCloseBtn%,, %btnX%, %btnY%
        if !DllCall("IsWindowVisible", "Ptr", hCloseBtn)
            Gui, CloseBtn: Show, Na
    } else {
        ; 如果不需要显示关闭按钮，或者鼠标离开了
        if (ShowCloseButton != "1" || A_TickCount - LastHoverTime > CloseBtn_HideTime) { ; <--- 这里加上了立刻隐藏的判断
            Gui, CloseBtn: Hide
        }
    }

    ; --- 原有的隐藏/显示判定 ---
    if (IsHovered) {
        if (IsHidden) {
            GoSub, ShowBall
        }
        LastMoveTime := A_TickCount
    } else {
        ; <--- 在这里的 if 中加入 EnableEdgeHide = "1"
        if (EnableEdgeHide = "1" && IsDocked && !IsHidden && (A_TickCount - LastMoveTime > HideDelay)) {
            GoSub, HideBall
        }
    }
return

; --- 执行隐藏/显示 ---
HideBall:
    IsHidden := true
    SysGet, Mon, MonitorWorkArea
    WinGetPos, x, y, w, h, ahk_id %hBall%
    newX := x, newY := y

    ; 计算当前尺寸下的实际像素留边量
    curPadL := Round(ImgPadL_Ratio * BallSize)
    curPadR := Round(ImgPadR_Ratio * BallSize)
    curPadT := Round(ImgPadT_Ratio * BallSize)
    curPadB := Round(ImgPadB_Ratio * BallSize)

    if (CurrentEdge = "L")
        newX := MonLeft - w + HideMargin + curPadR
    else if (CurrentEdge = "R")
        newX := MonRight - HideMargin - curPadL
    else if (CurrentEdge = "T")
        newY := MonTop - h + HideMargin + curPadB

    if (newX = "" || newY = "")
        return

    ; 直接在更新函数里移动并改变透明度
    UpdateBallDisplay(hBall, pBitmap, newX, newY, BallSize, CurrentAlpha)
return

ShowBall:
    IsHidden := false
    SysGet, Mon, MonitorWorkArea
    WinGetPos, x, y, w, h, ahk_id %hBall%
    newX := x, newY := y

    curPadL := Round(ImgPadL_Ratio * BallSize)
    curPadR := Round(ImgPadR_Ratio * BallSize)
    curPadT := Round(ImgPadT_Ratio * BallSize)

    if (CurrentEdge = "L")
        newX := MonLeft - curPadL
    else if (CurrentEdge = "R")
        newX := MonRight - w + curPadR
    else if (CurrentEdge = "T")
        newY := MonTop - curPadT

    UpdateBallDisplay(hBall, pBitmap, newX, newY, BallSize, CurrentAlpha)
    ; 【新增】如果是 GIF，从边缘拉出时恢复动画
    if (IsGif)
        GoSub, UpdateGifFrame

return

LeftClickAction:
    if (IsEditMode) {
        ToolTip, 🛠️ 编辑模式中：请【右键点击悬浮球】退出并保存！
        SetTimer, RemoveToolTip, -2000
        return
    }
    finalEnable := LBtn_Enable, finalType := LBtn_Type, finalParam := LBtn_Param
    if (GetKeyState("Ctrl", "P") && LBtn_Enable_ctrl == "1")
        finalEnable := LBtn_Enable_ctrl, finalType := LBtn_Type_ctrl, finalParam := LBtn_Param_ctrl
    else if (GetKeyState("Alt", "P") && LBtn_Enable_alt == "1")
        finalEnable := LBtn_Enable_alt, finalType := LBtn_Type_alt, finalParam := LBtn_Param_alt
    else if (GetKeyState("Shift", "P") && LBtn_Enable_shift == "1")
        finalEnable := LBtn_Enable_shift, finalType := LBtn_Type_shift, finalParam := LBtn_Param_shift

    ExecuteAction(finalEnable, finalType, finalParam)
return

MiddleClickAction:
    if (IsEditMode) {
        ToolTip, 🛠️ 编辑模式中：请【右键点击悬浮球】退出并保存！
        SetTimer, RemoveToolTip, -2000
        return
    }
    finalEnable := MBtn_Enable, finalType := MBtn_Type, finalParam := MBtn_Param
    if (GetKeyState("Ctrl", "P") && MBtn_Enable_ctrl == "1")
        finalEnable := MBtn_Enable_ctrl, finalType := MBtn_Type_ctrl, finalParam := MBtn_Param_ctrl
    else if (GetKeyState("Alt", "P") && MBtn_Enable_alt == "1")
        finalEnable := MBtn_Enable_alt, finalType := MBtn_Type_alt, finalParam := MBtn_Param_alt
    else if (GetKeyState("Shift", "P") && MBtn_Enable_shift == "1")
        finalEnable := MBtn_Enable_shift, finalType := MBtn_Type_shift, finalParam := MBtn_Param_shift

    ExecuteAction(finalEnable, finalType, finalParam)
return

RightClickAction:
    ; ▼▼▼ 新增修复：右键菜单弹出前，先强制关闭悬停面板防止卡死 ▼▼▼
    if (HoverPanelVisible) {
        GoSub, CloseHoverPanel
    }

    ; ▼▼▼ 右键拦截改为：如果是编辑模式，直接退出 ▼▼▼
    if (IsEditMode) {
        GoSub, ExitEditMode
        return
    }

    Menu, MyMenu, Add
    Menu, MenuTimeStyle, Add
    Menu, MenuStyle, Add
    Menu, MenuMore, Add

    Menu, MyMenu, DeleteAll
    Menu, MenuTimeStyle, DeleteAll  ; <--- 新增这一行
    Menu, MenuStyle, DeleteAll
    Menu, MenuMore, DeleteAll

    ; --- 动态构建样式子菜单 (根据当前显示模式切换) ---
    if (DisplayMode = "Time" || DisplayMode = "NetTraffic") {
        ; 1. 添加可点击的开关项
        Menu, MenuTimeStyle, Add, 文字加粗显示, ToggleTimeFontBold
        if (TimeFontBold = "1")
            Menu, MenuTimeStyle, Check, 文字加粗显示

        Menu, MenuTimeStyle, Add, 显示时间背景, ToggleTimeBg
        if (EnableTimeBg = "1")
            Menu, MenuTimeStyle, Check, 显示时间背景

        Menu, MenuTimeStyle, Add  ; 分割线

        ; 2. 准备截断过长字符的辅助变量 (限制最多显示 12 个字符)
        maxL := 12

        ; 还原真实换行符为 \n 以便单行显示，防菜单断层
        dispFmt := StrReplace(TimeFormat, "`n", "\n")

        ; 三元表达式：长度超限则截断并拼接 "..."
        m_Fmt   := StrLen(dispFmt) > maxL ? SubStr(dispFmt, 1, maxL) . "..." : dispFmt
        m_Font  := StrLen(TimeFont) > maxL ? SubStr(TimeFont, 1, maxL) . "..." : TimeFont
        m_FCol  := StrLen(TimeColor) > maxL ? SubStr(TimeColor, 1, maxL) . "..." : TimeColor
        m_BCol  := StrLen(TimeBgColor) > maxL ? SubStr(TimeBgColor, 1, maxL) . "..." : TimeBgColor
        m_Ratio := StrLen(TimeCornerRatio) > maxL ? SubStr(TimeCornerRatio, 1, maxL) . "..." : TimeCornerRatio

        ; 3. 添加带有当前配置信息的展示项，并将其指向一个空动作且禁用
        Menu, MenuTimeStyle, Add, % "时间格式 (" m_Fmt ")", MenuDoNothing
        Menu, MenuTimeStyle, Disable, % "时间格式 (" m_Fmt ")"

        Menu, MenuTimeStyle, Add, % "字体名称 (" m_Font ")", MenuDoNothing
        Menu, MenuTimeStyle, Disable, % "字体名称 (" m_Font ")"

        Menu, MenuTimeStyle, Add, % "字体颜色 (" m_FCol ")", MenuDoNothing
        Menu, MenuTimeStyle, Disable, % "字体颜色 (" m_FCol ")"

        Menu, MenuTimeStyle, Add, % "背景颜色 (" m_BCol ")", MenuDoNothing
        Menu, MenuTimeStyle, Disable, % "背景颜色 (" m_BCol ")"

        Menu, MenuTimeStyle, Add, % "背景圆角 (" m_Ratio ")", MenuDoNothing
        Menu, MenuTimeStyle, Disable, % "背景圆角 (" m_Ratio ")"

        ; 将时间样式子菜单挂载到主菜单
        Menu, MyMenu, Add, 时间/文本设置, :MenuTimeStyle

    } else {
        ; 构建原有的“悬浮球样式”图片菜单
        Loop, Files, %IconDir%\*.*
        {
            if (A_LoopFileExt = "png" || A_LoopFileExt = "gif") {
                Menu, MenuStyle, Add, %A_LoopFileName%, UpdateBallStyle
                if (A_LoopFileName = BallImage)
                    Menu, MenuStyle, Check, %A_LoopFileName%
            }
        }

        Menu, MyMenu, Add, 悬浮球样式, :MenuStyle
    }

    ; --- 动态构建显示模式子菜单 ---
    Menu, MenuDisplayMode, Add
    Menu, MenuDisplayMode, DeleteAll
    Menu, MenuDisplayMode, Add, 图标模式, SetDisplayMode
    Menu, MenuDisplayMode, Add, 时间模式, SetDisplayMode
    Menu, MenuDisplayMode, Add, 网速模式, SetDisplayMode

    ; 根据当前模式给对应菜单项打钩
    if (DisplayMode = "Image")
        Menu, MenuDisplayMode, Check, 图标模式
    else if (DisplayMode = "Time")
        Menu, MenuDisplayMode, Check, 时间模式
    else if (DisplayMode = "NetTraffic")
        Menu, MenuDisplayMode, Check, 网速模式

    Menu, MyMenu, Add, 显示模式切换, :MenuDisplayMode ; 挂载子菜单

    Menu, MyMenu, Add, 事件设置, ShowEventSettingsGUI
    Menu, MyMenu, Add, 全局设置, ShowMainSettingsGUI

    Menu, MyMenu, Add  ; 分割线
    ; --------------------------------------

    ;构建“更多选项”子菜单 ---
    Menu, MenuMore, Add, 滚轮调节大小, ToggleWheelResize
    Menu, MenuMore, Add, 显示关闭按钮, ToggleCloseButton
    Menu, MenuMore, Add, 关闭按钮仅隐藏, ToggleCloseBtnAction
    Menu, MenuMore, Add, 显示托盘图标, ToggleTrayIcon
    Menu, MenuMore, Add, 动态透明度, ToggleDynamicOpacity
    Menu, MenuMore, Add, 仅左键穿透, ToggleLeftClickThrough

    Menu, MenuMore, Add  ; 分割线
    Menu, MenuMore, Add, 退出时保存大小, ToggleSaveSize
    Menu, MenuMore, Add, 退出时保存位置, ToggleSavePosition
    Menu, MenuMore, Add  ; 分割线
    Menu, MenuMore, Add, 切换深浅主题, ToggleThemeMode ; <--- 新增此行
    Menu, MenuMore, Add, 位置重置, ResetPosition
    Menu, MenuMore, Add, 大小重置, ResetSize
    Menu, MenuMore, Add, 全部重置, ResetAll
    Menu, MenuMore, Add, 编辑模式, ToggleEditMode

    Menu, MyMenu, Add, % "全局快捷键 (" ToggleHotkey ")", ToggleHotkeyEnable
    ; 动态创建/刷新菜单
    Menu, MyMenu, Add, 置顶显示, ToggleAlwaysOnTop
    Menu, MyMenu, Add, 贴边自动隐藏, ToggleEdgeHide
    Menu, MyMenu, Add, 全屏时自动隐藏, ToggleFullScreenHide

    Menu, MyMenu, Add, 固定位置, ToggleLockPosition
    ; === 新增：将穿透选项加到主菜单固定位置的下方 ===
    Menu, MyMenu, Add, 鼠标穿透, ToggleClickThrough

    Menu, MyMenu, Add, 更多选项, :MenuMore

    ; ==============================================================================
    ; --- 新增/修改：动态构建「配置管理」子菜单 ---
    ; ==============================================================================
    ; 先清空防止重复叠加
    Menu, MenuConfigMgr, Add
    Menu, MenuConfigMgr, DeleteAll
    Menu, MenuMyConfigs, Add
    Menu, MenuMyConfigs, DeleteAll
    Menu, MenuMyBackups, Add
    Menu, MenuMyBackups, DeleteAll

    ; 1. 构建“我的配置”动态菜单
    CfgMgr_HasConfig := false
    Loop, Files, %CfgMgr_UserConfigDir%\*.ini
    {
        SplitPath, A_LoopFileName,,,, configNameNoExt
        Menu, MenuMyConfigs, Add, %configNameNoExt%, LoadUserConfig
        CfgMgr_HasConfig := true
    }
    if (!CfgMgr_HasConfig)
        Menu, MenuMyConfigs, Add, (无可用配置), MenuDoNothing

    ; 2. 构建“自动备份”动态菜单
    CfgMgr_HasBackup := false
    CfgMgr_FileList := ""
    Loop, Files, %CfgMgr_UserConfigDir%\backup\Settings_*.ini
        CfgMgr_FileList .= A_LoopFileTimeModified "`t" A_LoopFileName "`n"

    Sort, CfgMgr_FileList, R ; 按时间戳倒序

    Loop, Parse, CfgMgr_FileList, `n, `r
    {
        if (A_LoopField = "")
            continue
        bakFile := SubStr(A_LoopField, InStr(A_LoopField, "`t") + 1)
        if RegExMatch(bakFile, "Settings_(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})\.ini", m) {
            dispName := m1 "-" m2 "-" m3 " " m4 ":" m5 ":" m6
            Menu, MenuMyBackups, Add, %dispName%, LoadBackupConfig
            CfgMgr_HasBackup := true
        }
    }
    if (!CfgMgr_HasBackup)
        Menu, MenuMyBackups, Add, (无备份), MenuDoNothing

    ; 3. 构建“配置管理”主菜单
    Menu, MenuConfigMgr, Add, 保存当前配置..., SaveUserConfig
    Menu, MenuConfigMgr, Add, 我的配置, :MenuMyConfigs
    Menu, MenuConfigMgr, Add, 自动备份, :MenuMyBackups
    Menu, MenuConfigMgr, Add, 打开配置文件夹, OpenConfigDir
    Menu, MenuConfigMgr, Add ; 分割线
    Menu, MenuConfigMgr, Add, 清空所有备份, ClearAllBackups
    Menu, MenuConfigMgr, Add, 开启自动备份, ToggleAutoBackup

    if (CfgMgr_EnableAutoBackup = "1")
        Menu, MenuConfigMgr, Check, 开启自动备份
    else
        Menu, MenuConfigMgr, Uncheck, 开启自动备份

    Menu, MyMenu, Add, 配置管理, :MenuConfigMgr

    Menu, MyMenu, Add  ; 分割线

    ;Menu, MyMenu, Add, 编辑配置文件, EditConfig
    Menu, MyMenu, Add, 重启, ReloadScript
    Menu, MyMenu, Add, 停用, ToggleSuspend
    Menu, MyMenu, Add, 关于, ShowAboutGui
    Menu, MyMenu, Add  ; 分割线

    ; ▼▼▼ 修改点：将执行标签改为 ToggleBallVisibility，并加入状态判定 ▼▼▼
    Menu, MyMenu, Add, 隐藏到托盘, ToggleBallVisibility

    ; 利用现有的系统底层调用来判断悬浮球是否隐藏
    if !DllCall("IsWindowVisible", "Ptr", hBall)
        Menu, MyMenu, Check, 隐藏到托盘
    else
        Menu, MyMenu, Uncheck, 隐藏到托盘
    ; ▲▲▲ 修改点结束 ▲▲▲

    Menu, MyMenu, Add, 退出, 退出时运行

    Loop, 5 {
        currVar := ["IsLocked", "IsAlwaysOnTop", "EnableEdgeHide", "HideInFullScreen", "IsClickThrough"][A_Index]
        currName := ["固定位置", "置顶显示", "贴边自动隐藏", "全屏时自动隐藏", "鼠标穿透"][A_Index]

        if (%currVar% = "1")
            Menu, MyMenu, Check, %currName%
        else
            Menu, MyMenu, Uncheck, %currName%
    }

    Loop, 8 {
        currVar := ["ShowCloseButton", "ShowTrayIcon", "EnableWheelResize", "CloseBtnAction", "EnableDynamicOpacity", "SaveSize", "SavePosition", "IsLeftClickThroughOnly"][A_Index]
        currName := ["显示关闭按钮", "显示托盘图标", "滚轮调节大小", "关闭按钮仅隐藏", "动态透明度", "退出时保存大小", "退出时保存位置", "仅左键穿透"][A_Index]

        if (%currVar% = "1")
            Menu, MenuMore, Check, %currName%
        else
            Menu, MenuMore, Uncheck, %currName%
    }

    ;根据 AHK 内置变量判断“停用”是否打钩 ---
    if (A_IsSuspended)
        Menu, MyMenu, Check, 停用
    else
        Menu, MyMenu, Uncheck, 停用

    if (EnableHotkey = "1")
        Menu, MyMenu, Check, % "全局快捷键 (" ToggleHotkey ")"
    else
        Menu, MyMenu, Uncheck, % "全局快捷键 (" ToggleHotkey ")"

    IsMenuOpen := true
    Menu, MyMenu, Show
    IsMenuOpen := false
return

退出时运行:
    if (SaveSize = "1") {
        Var_Set(BallSize, "50", "BallSize", "基础配置",A_ScriptDir "\Settings.ini")
    }
    if (SavePosition = "1") {
        Gosub, 获取悬浮球坐标_调整到屏幕内
        Var_Set(nowX,"","GUI_X", "基础配置",A_ScriptDir "\Settings.ini")
        Var_Set(nowY,"","GUI_Y", "基础配置",A_ScriptDir "\Settings.ini")
    }

    If (CfgMgr_EnableAutoBackup = "1")
        BackupCurrentConfig()
    ; 优雅退出
    SetTimer, UpdateGifFrame, Off
    if (pBitmap)
        Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
ExitApp
Return

; --- 菜单功能处理 ---
UpdateBallStyle:
    ; A_ThisMenuItem 是你点击的菜单项名称（即文件名）
    BallImage := A_ThisMenuItem

    ; 释放旧图片并加载新图片（兼容静态与动态图）
    LoadBallImage(IconDir "\" BallImage)

    ; 立即刷新显示
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    Var_Set(BallImage, "PokéBall.png", "BallImage", "基础配置", A_ScriptDir "\Settings.ini")
return

; --- 时间模式专属菜单功能 ---
ToggleTimeFontBold:
    TimeFontBold := (TimeFontBold = "1" ? "0" : "1")
    Var_Set(TimeFontBold, "1", "TimeFontBold", "基础配置", A_ScriptDir "\Settings.ini")

    ; 立即重新绘制时间条生效
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    GoSub, HandleSnapping ; 防越界
return

ToggleTimeBg:
    EnableTimeBg := (EnableTimeBg = "1" ? "0" : "1")
    Var_Set(EnableTimeBg, "1", "EnableTimeBg", "基础配置", A_ScriptDir "\Settings.ini")

    ; 立即重新绘制时间条生效
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    GoSub, HandleSnapping ; 防越界
return

; 空动作：专门给被 Disable 的菜单项当占位符，防止 AHK 报缺失 Label 的错
MenuDoNothing:
return

ToggleAlwaysOnTop:
    IsAlwaysOnTop := (IsAlwaysOnTop = "1" ? "0" : "1")
    WinSet, AlwaysOnTop, % (IsAlwaysOnTop = "1" ? "On" : "Off"), ahk_id %hBall%
    Var_Set(IsAlwaysOnTop, "1", "IsAlwaysOnTop", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleEdgeHide:
    EnableEdgeHide := (EnableEdgeHide = "1" ? "0" : "1")
    ; 如果关闭了贴边隐藏，且当前是隐藏状态，立即显示出来
    if (EnableEdgeHide = "0" && IsHidden)
        GoSub, ShowBall
    Var_Set(EnableEdgeHide, "1", "EnableEdgeHide", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleFullScreenHide:
    HideInFullScreen := (HideInFullScreen = "1" ? "0" : "1")
    ; 如果关闭了全屏隐藏，确保窗口显示
    if (HideInFullScreen = "0" && IsFullScreenHidden) {
        WinShow, ahk_id %hBall%
        IsFullScreenHidden := false
    }
    Var_Set(HideInFullScreen, "1", "HideInFullScreen", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleCloseButton:
    ShowCloseButton := (ShowCloseButton = "1" ? "0" : "1")
    ;
    if (ShowCloseButton = "0")
        Gui, CloseBtn: Hide
    Var_Set(ShowCloseButton, "0", "ShowCloseButton", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleLockPosition:
    IsLocked := (IsLocked = "1" ? "0" : "1")
    Var_Set(IsLocked, "0", "IsLocked", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleClickThrough:
    IsClickThrough := (IsClickThrough = "1" ? "0" : "1")
    if (IsClickThrough = "1") {
        ; 开启 E0x20 (WS_EX_TRANSPARENT)
        WinSet, ExStyle, +0x20, ahk_id %hBall%

        ; 开启全穿透时，自动关闭仅左键穿透防止逻辑冲突
        if (IsLeftClickThroughOnly = "1") {
            IsLeftClickThroughOnly := "0"
            Var_Set("0", "0", "IsLeftClickThroughOnly", "基础配置", A_ScriptDir "\Settings.ini")
        }

        TrayTip, 穿透已开启, 悬浮球现在已完全无视鼠标！`n无法再通过右键悬浮球唤出菜单，`n请右键【系统托盘图标】进行恢复设置。, 4, 1
    } else {
        ; 取消穿透
        WinSet, ExStyle, -0x20, ahk_id %hBall%
    }
    Var_Set(IsClickThrough, "0", "IsClickThrough", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleLeftClickThrough:
    IsLeftClickThroughOnly := (IsLeftClickThroughOnly = "1" ? "0" : "1")
    if (IsLeftClickThroughOnly = "1" && IsClickThrough = "1") {
        ; 开启仅左键穿透时，必须关闭全穿透，否则左键热键捕获不到
        IsClickThrough := "0"
        WinSet, ExStyle, -0x20, ahk_id %hBall%
        Var_Set("0", "0", "IsClickThrough", "基础配置", A_ScriptDir "\Settings.ini")
    }
    Var_Set(IsLeftClickThroughOnly, "0", "IsLeftClickThroughOnly", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleCloseBtnAction:
    CloseBtnAction := (CloseBtnAction = "1" ? "0" : "1")
    Var_Set(CloseBtnAction, "0", "CloseBtnAction", "基础配置", A_ScriptDir "\Settings.ini")
return

ResetPosition:
    ; 获取屏幕工作区大小，计算中心坐标
    SysGet, Mon, MonitorWorkArea
    TargetX := MonLeft + (MonRight - MonLeft) / 2 - BallSize / 2
    TargetY := MonTop + (MonBottom - MonTop) / 2 - BallSize / 2

    ; 更新悬浮球位置
    UpdateBallDisplay(hBall, pBitmap, TargetX, TargetY, BallSize, CurrentAlpha)

    ; 同步写入配置，防止退出时被再次覆盖
    Var_Set(TargetX, "", "GUI_X", "基础配置", A_ScriptDir "\Settings.ini")
    Var_Set(TargetY, "", "GUI_Y", "基础配置", A_ScriptDir "\Settings.ini")
return

ResetSize:
    BallSize := 50  ; 将悬浮球大小恢复为默认的 50
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)

    ; 写入配置并重新触发一次吸附检查防越界
    Var_Set(BallSize, "50", "BallSize", "基础配置", A_ScriptDir "\Settings.ini")
    GoSub, HandleSnapping
return

ResetAll:
    ; 弹窗二次确认防误触 (276 = 问号图标 + 是/否按钮 + 默认选中第二按钮)
    MsgBox, 276, 警告, 确定要重置所有设置并重启脚本吗？
    IfMsgBox, Yes
    {
        ; 删除配置文件中的[基础配置]整个段落，然后重启脚本
        IniDelete, %A_ScriptDir%\Settings.ini, 基础配置
        Reload
    }
return

EditConfig:
    Run, "%A_ScriptDir%\Settings.ini"
return

ReloadScript:
    Reload
return

ToggleSuspend:
    ; 切换脚本挂起状态（暂停所有的热键响应）
    Suspend, Toggle
return

; --- 新增托盘与滚轮设置选项路由 ---
ToggleTrayIcon:
    ShowTrayIcon := (ShowTrayIcon = "1" ? "0" : "1")
    if (ShowTrayIcon = "1")
        Menu, Tray, Icon
    else
        Menu, Tray, NoIcon
    Var_Set(ShowTrayIcon, "1", "ShowTrayIcon", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleWheelResize:
    EnableWheelResize := (EnableWheelResize = "1" ? "0" : "1")
    Var_Set(EnableWheelResize, "1", "EnableWheelResize", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleDynamicOpacity:
    EnableDynamicOpacity := (EnableDynamicOpacity = "1" ? "0" : "1")
    Var_Set(EnableDynamicOpacity, "1", "EnableDynamicOpacity", "基础配置", A_ScriptDir "\Settings.ini")

    ; 如果刚才是低透明度，关闭动态调整后立刻重绘一次恢复高亮
    if (EnableDynamicOpacity = "0") {
        CurrentAlpha := MaxOpacity
        WinGetPos, curX, curY,,, ahk_id %hBall%
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    }
return

ToggleSaveSize:
    SaveSize := (SaveSize = "1" ? "0" : "1")
    Var_Set(SaveSize, "1", "SaveSize", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleSavePosition:
    SavePosition := (SavePosition = "1" ? "0" : "1")
    Var_Set(SavePosition, "1", "SavePosition", "基础配置", A_ScriptDir "\Settings.ini")
return

HideToTray:
    ; 【修复点1】在隐藏前，记录下当前的精确坐标
    WinGetPos, preHideX, preHideY,,, ahk_id %hBall%

    if (ShowTrayIcon = "0") {
        Menu, Tray, Icon ; 临时显示托盘图标，防止悬浮球和图标同时消失找不回来
    }
    WinHide, ahk_id %hBall%
    WinHide, ahk_id %hCloseBtn%
    TrayTip, 提示, 悬浮球已隐藏到托盘`n左键单击托盘图标恢复显示, 3, 1
return

ShowBallFromTray:
    ; 【修复点2】在显示前，使用底层 GDI+ 恢复原坐标和透明度，覆盖系统的默认坐标
    if (preHideX != "" && preHideY != "") {
        UpdateBallDisplay(hBall, pBitmap, preHideX, preHideY, BallSize, CurrentAlpha)
    }

    WinShow, ahk_id %hBall%
    ; 如果之前是因为隐藏到托盘临时开启的图标，恢复原状
    if (ShowTrayIcon = "0")
        Menu, Tray, NoIcon

    GoSub, HandleSnapping ; 防越界修正

    ; 【新增】从托盘或快捷键恢复显示时，重新唤醒 GIF 动画
    if (IsGif)
        GoSub, UpdateGifFrame
return

ToggleHotkeyEnable:
    EnableHotkey := (EnableHotkey = "1" ? "0" : "1")
    if (ToggleHotkey != "") {
        if (EnableHotkey = "1")
            Hotkey, %ToggleHotkey%, On
        else
            Hotkey, %ToggleHotkey%, Off
    }
    Var_Set(EnableHotkey, "1", "EnableHotkey", "基础配置", A_ScriptDir "\Settings.ini")
return

ToggleBallVisibility:
    ; 获取窗口当前的可见状态，实现类似托盘的隐藏/恢复
    if DllCall("IsWindowVisible", "Ptr", hBall) {
        GoSub, HideToTray
    } else {
        GoSub, ShowBallFromTray
    }
return

; ==============================================================================
; 编辑模式状态切换 (已升级：圆角自适应高分屏UI)
; ==============================================================================
ToggleEditMode:
    IsEditMode := !IsEditMode
    if (IsEditMode) {
        ; 1. 强制设为最高透明度并立即更新
        CurrentAlpha := MaxOpacity
        WinGetPos, curX, curY,,, ahk_id %hBall%
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)

        ; 2. 创建美化的无边框半透明提示窗 (HUD样式，并开启鼠标穿透 +E0x20)
        Gui, EditPrompt: Destroy
        Gui, EditPrompt: +AlwaysOnTop +ToolWindow -Caption +E0x20 +HwndhEditGui
        Gui, EditPrompt: Color, %G_BgColor%
        Gui, EditPrompt: Margin, 0, 0

        W := 250, H := 135

        ; === 【应用系统 DPI 缩放并绘制圆角】 ===
        DPIScale := A_ScreenDPI / 96
        RealW := Round(W * DPIScale)
        RealH := Round(H * DPIScale)
        RealRgn := Round(15 * DPIScale)

        SetWindowRgn(hEditGui, RealW, RealH, RealRgn)
        DrawRoundedBackground_API(hEditGui, RealW, RealH, RealRgn, G_BgARGB, G_BorderARGB)
        ; ======================================

        Gui, EditPrompt: Font, s12 c%G_FontColor% w700, 微软雅黑
        ; 注意：这里加入了 BackgroundTrans 确保文字背景透明，融入圆角底色
        Gui, EditPrompt: Add, Text, x0 y20 w%W% Center BackgroundTrans, 🛠️ 编 辑 模 式
        Gui, EditPrompt: Font, s10 c%G_SubFontColor% w400
        Gui, EditPrompt: Add, Text, x0 y55 w%W% Center BackgroundTrans, [方向键] 移动位置`n[+ / -] 调整大小`n`n👉 右键点击悬浮球退出

        ; 居中显示在屏幕顶部，不抢焦点
        Gui, EditPrompt: Show, w%W% h%H% NoActivate y80, EditPromptGui
        WinSet, Transparent, 230, ahk_id %hEditGui%
    } else {
        GoSub, ExitEditMode
    }
return

ExitEditMode:
    IsEditMode := 0
    Gui, EditPrompt: Destroy ; 销毁美化版提示框
    ToolTip, 已保存并退出编辑模式！
    SetTimer, RemoveToolTip, -1500

    ; 保存坐标和大小
    Var_Set(BallSize, "50", "BallSize", "基础配置", A_ScriptDir "\Settings.ini")
    WinGetPos, curX, curY,,, ahk_id %hBall%
    Var_Set(curX, "", "GUI_X", "基础配置", A_ScriptDir "\Settings.ini")
    Var_Set(curY, "", "GUI_Y", "基础配置", A_ScriptDir "\Settings.ini")
return

RemoveToolTip:
    ToolTip
return

; 托盘图标消息回调函数 (拦截左键单击与右键单击)
AHK_NOTIFYICON(wParam, lParam) {
    if (lParam = 0x202) { ; WM_LBUTTONUP (左键松开)
        SetTimer, ShowBallFromTray, -10
        return 0
    }
    if (lParam = 0x205) { ; WM_RBUTTONUP (右键松开)
        SetTimer, RightClickAction, -10 ; 直接复用悬浮球的右键菜单生成逻辑
        return 0
    }
}

获取悬浮球坐标_调整到屏幕内:
    WinGetPos, nowX, nowY, nowW, nowH, ahk_id %hBall%
    SysGet, Mon, MonitorWorkArea

    curPadL := Round(ImgPadL_Ratio * BallSize)
    curPadR := Round(ImgPadR_Ratio * BallSize)
    curPadT := Round(ImgPadT_Ratio * BallSize)
    curPadB := Round(ImgPadB_Ratio * BallSize)

    if (nowX + curPadL < MonLeft)
        nowX := MonLeft - curPadL + SnapRange + 1
    if (nowX + nowW - curPadR > MonRight)
        nowX := MonRight - nowW + curPadR - SnapRange
    if (nowY + curPadT < MonTop)
        nowY := MonTop - curPadT + SnapRange + 1
    if (nowY + nowH - curPadB > MonBottom)
        nowY := MonBottom - nowH + curPadB - SnapRange
return

; --- GDI+ 核心函数库（修复文字加粗与参数冲突版） ---
UpdateBallDisplay(hwnd, pBitmap, x, y, size:=60, alpha:=255) {
    ; 引入所有的全局变量
    global DisplayMode, TimeFormat, TimeFont, TimeColor, EnableTimeBg, TimeBgColor
    global TimeFontRatio, TimeFontBold, TimeCornerRatio, TimeOffsetY, TimePaddingX, TimePaddingY

    ; 使用 static 变量锁定脚本启动时的初始 BallSize，专用于等比缩放留白与偏移量
    static InitialSize := 0
    if (InitialSize = 0 && size > 0) {
        InitialSize := size
    }

    Ptr := A_PtrSize ? "UPtr" : "UInt"

    if (DisplayMode = "Time" || DisplayMode = "NetTraffic") {
        ; --- 1. 计算缩放后的所有尺寸 ---
        ScaledFontSize := Round(size * TimeFontRatio)
        Scale := (InitialSize > 0) ? (size / InitialSize) : 1
        ScaledPaddingX := Round(TimePaddingX * Scale)
        ScaledPaddingY := Round(TimePaddingY * Scale)
        ScaledOffsetY  := Round(TimeOffsetY * Scale)

        ; --- 2. 获取要显示的文本并设定测量模板 ---
        if (DisplayMode = "Time") {
            FormatTime, currentDisplayStr,, %TimeFormat%
            MeasureStr := currentDisplayStr ; 时间模式依旧随时间长度变化
        } else {
            global NetRxSpeed, NetTxSpeed
            if (NetRxSpeed == "")
                NetRxSpeed := "0 B/s", NetTxSpeed := "0 B/s"

            ; 【修改点1】将箭头和数值重新合并，中间只有一个空格，绝对紧凑
            currentDisplayStr := "↑ " . NetTxSpeed . "`n↓ " . NetRxSpeed

            ; 模板文本改为 3 位数样式，让背景框更紧凑美观
            MeasureStr := "↑ 999 MB/s`n↓ 999 MB/s"
        }

        ; --- 3. 借用屏幕 DC 预先测量排版宽高 ---
        hDCScreen := DllCall("GetDC", Ptr, 0, Ptr)
        GScreen := Gdip_GraphicsFromHDC(hDCScreen)
        DllCall("gdiplus\GdipSetSmoothingMode", Ptr, GScreen, "Int", 4)

        FontStyle := (TimeFontBold = "1") ? "Bold" : "Regular"
        MeasureOptions := "s" ScaledFontSize " " FontStyle " Center VCenter"

        ; 【修改点】：统一使用 MeasureStr 测量出最大边界
        MeasureBox := Gdip_TextToGraphics(GScreen, MeasureStr, MeasureOptions, TimeFont, 10000, 10000, 1)
        StringSplit, mInfo, MeasureBox, |
        TextW := Ceil(mInfo3)
        TextH := Ceil(mInfo4)

        Gdip_DeleteGraphics(GScreen)
        DllCall("ReleaseDC", Ptr, 0, Ptr, hDCScreen)

        ; --- 4. 计算最终包裹窗口的宽高 ---
        RenderW := TextW + (ScaledPaddingX * 2)
        RenderH := TextH + (ScaledPaddingY * 2)
    } else {
        ; 图片模式宽高
        RenderW := size
        RenderH := size
    }

    ; --- 5. 准备 GDI+ 画布 ---
    VarSetCapacity(ptDst, 8)
    NumPut(x, ptDst, 0, "Int"), NumPut(y, ptDst, 4, "Int")
    VarSetCapacity(sizeDst, 8)
    NumPut(RenderW, sizeDst, 0, "Int"), NumPut(RenderH, sizeDst, 4, "Int")
    VarSetCapacity(ptSrc, 8, 0)

    hDC := DllCall("GetDC", Ptr, 0, Ptr)
    mDC := DllCall("CreateCompatibleDC", Ptr, hDC, Ptr)
    hBM := DllCall("CreateCompatibleBitmap", Ptr, hDC, "Int", RenderW, "Int", RenderH, Ptr)
    oBM := DllCall("SelectObject", Ptr, mDC, Ptr, hBM, Ptr)
    G := Gdip_GraphicsFromHDC(mDC)
    DllCall("gdiplus\GdipSetSmoothingMode", Ptr, G, "Int", 4)

    if (DisplayMode = "Time" || DisplayMode = "NetTraffic") {
        ; 画背景
        if (EnableTimeBg = "1") {
            pBrushBg := Gdip_BrushCreateSolid("0x" TimeBgColor)
            CornerRadius := Round(RenderH * TimeCornerRatio)
            Gdip_FillRoundedRectangle(G, pBrushBg, 0, 0, RenderW, RenderH, CornerRadius)
            Gdip_DeleteBrush(pBrushBg)
        }

        ; 分模式画文字
        if (DisplayMode = "Time") {
            ; 时间模式：传统整体居中绘制 (Center)
            DrawOptions := "x0 y" ScaledOffsetY " w" RenderW " h" RenderH " Center VCenter c" TimeColor " s" ScaledFontSize " " FontStyle
        } else {
            ; 流量模式：【修改点2】左对齐紧凑绘制。
            ; 去除 Center 和 Right，利用 x 指定起点为左留白，让箭头定死在左侧，数值紧随其后
            DrawOptions := "x" ScaledPaddingX " y" ScaledOffsetY " w" (RenderW - ScaledPaddingX) " h" RenderH " VCenter c" TimeColor " s" ScaledFontSize " " FontStyle
        }
        Gdip_TextToGraphics(G, currentDisplayStr, DrawOptions, TimeFont, RenderW, RenderH)
    } else {
        DllCall("gdiplus\GdipSetInterpolationMode", Ptr, G, "Int", 7)
        Gdip_DrawImage(G, pBitmap, 0, 0, RenderW, RenderH)
    }

    ; --- 6. 渲染到桌面 ---
    DllCall("UpdateLayeredWindow", Ptr, hwnd, Ptr, hDC, Ptr, &ptDst, Ptr, &sizeDst, Ptr, mDC, Ptr, &ptSrc, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 2)

    Gdip_DeleteGraphics(G)
    DllCall("SelectObject", Ptr, mDC, Ptr, oBM)
    DllCall("DeleteObject", Ptr, hBM)
    DllCall("DeleteDC", Ptr, mDC)
    DllCall("ReleaseDC", Ptr, 0, Ptr, hDC)
}

; ==============================================================================
; 新增：支持静态图片与 GIF 的统一加载函数
; ==============================================================================
LoadBallImage(imgPath) {
    global pBitmap, IsGif, GifFrameCount, GifCurrentFrame, GifDelays, GifDimensionID

    ; 清除旧资源与定时器
    SetTimer, UpdateGifFrame, Off
    if (pBitmap) {
        Gdip_DisposeImage(pBitmap)
        pBitmap := 0
    }

    pBitmap := Gdip_CreateBitmapFromFile(imgPath)
    UpdateBitmapPadding() ; 【新增】首次运行，自动计算留边比例
    if (!pBitmap)
        return false

    IsGif := false
    SplitPath, imgPath,,, ext
    if (ext = "gif") {
        ; 获取 DimensionID (通常为 FrameDimensionTime 的 GUID)
        DllCall("gdiplus\GdipImageGetFrameDimensionsList", "Ptr", pBitmap, "Ptr", &GifDimensionID, "UInt", 1)
        ; 获取总帧数
        DllCall("gdiplus\GdipImageGetFrameCount", "Ptr", pBitmap, "Ptr", &GifDimensionID, "UInt*", GifFrameCount)

        if (GifFrameCount > 1) {
            IsGif := true
            GifCurrentFrame := 0
            GifDelays := []

            ; 获取 PropertyTagFrameDelay (0x5100)，读取各帧延迟
            DllCall("gdiplus\GdipGetPropertyItemSize", "Ptr", pBitmap, "UInt", 0x5100, "UInt*", propSize)
            if (propSize) {
                VarSetCapacity(propItem, propSize, 0)
                DllCall("gdiplus\GdipGetPropertyItem", "Ptr", pBitmap, "UInt", 0x5100, "UInt", propSize, "Ptr", &propItem)

                ; PropertyItem 结构体在 32 位和 64 位下指针偏移不同 (32位偏移12, 64位偏移16)
                valuePtr := NumGet(propItem, A_PtrSize = 8 ? 16 : 12, "Ptr")

                Loop, % GifFrameCount {
                    ; GDI+ 记录的延迟单位是 10 毫秒
                    delay := NumGet(valuePtr + (A_Index - 1) * 4, "UInt") * 10
                    ; 防止无延迟配置导致 CPU 满载，给个 30ms 的保底
                    if (delay < 30)
                        delay := 100
                    GifDelays.Push(delay)
                }
            } else {
                ; 兜底逻辑：如果 GIF 没有延迟属性信息，默认 100ms
                Loop, % GifFrameCount
                    GifDelays.Push(100)
            }
            ; 立即触发第一帧并启动循环
            GoSub, UpdateGifFrame
        }
    }
    return true
}

; 【新增】自动扫描当前图片的不透明主体边界，计算留边比例
UpdateBitmapPadding() {
    global pBitmap, ImgPadL_Ratio, ImgPadR_Ratio, ImgPadT_Ratio, ImgPadB_Ratio
    if (!pBitmap) {
        ImgPadL_Ratio := 0, ImgPadR_Ratio := 0, ImgPadT_Ratio := 0, ImgPadB_Ratio := 0
        return
    }

    ; 获取图片原始宽高
    DllCall("gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "UInt*", w)
    DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", h)

    minX := 0, maxX := w - 1
    minY := 0, maxY := h - 1

    ; 1. 从左向右扫描，找最左侧不透明边界 (minX)
    found := false
    Loop, %w% {
        x := A_Index - 1
        Loop, %h% {
            y := A_Index - 1
            DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", x, "Int", y, "UInt*", ARGB)
            if (((ARGB >> 24) & 0xFF) > 10) { ; Alpha 超过 10 视为有效内容
                minX := x
                found := true
                break
            }
        }
        if (found)
            break
    }

    ; 2. 从右向左扫描，找最右侧不透明边界 (maxX)
    found := false
    Loop, %w% {
        x := w - A_Index
        Loop, %h% {
            y := A_Index - 1
            DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", x, "Int", y, "UInt*", ARGB)
            if (((ARGB >> 24) & 0xFF) > 10) {
                maxX := x
                found := true
                break
            }
        }
        if (found)
            break
    }

    ; 3. 从上向下扫描，找最顶部不透明边界 (minY)
    found := false
    Loop, %h% {
        y := A_Index - 1
        Loop, %w% {
            x := A_Index - 1
            DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", x, "Int", y, "UInt*", ARGB)
            if (((ARGB >> 24) & 0xFF) > 10) {
                minY := y
                found := true
                break
            }
        }
        if (found)
            break
    }

    ; 4. 从下向上扫描，找最底部不透明边界 (maxY)
    found := false
    Loop, %h% {
        y := h - A_Index
        Loop, %w% {
            x := A_Index - 1
            DllCall("gdiplus\GdipBitmapGetPixel", "Ptr", pBitmap, "Int", x, "Int", y, "UInt*", ARGB)
            if (((ARGB >> 24) & 0xFF) > 10) {
                maxY := y
                found := true
                break
            }
        }
        if (found)
            break
    }

    ; 计算不透明主体四周的留边占总宽高的比例
    ImgPadL_Ratio := minX / w
    ImgPadR_Ratio := (w - 1 - maxX) / w
    ImgPadT_Ratio := minY / h
    ImgPadB_Ratio := (h - 1 - maxY) / h
}

; 专门用于绘制漂亮的关闭按钮
UpdateCloseBtnDisplay(hwnd,size:="24",CloseBtn_Thickness:="2", CloseBtn_VisualMargin:="5", isHovered:=false, alpha:=255) {
    Ptr := A_PtrSize ? "UPtr" : "UInt"

    hDC := DllCall("GetDC", Ptr, 0, Ptr)
    mDC := DllCall("CreateCompatibleDC", Ptr, hDC, Ptr)
    hBM := DllCall("CreateCompatibleBitmap", Ptr, hDC, "Int", size, "Int", size, Ptr)
    oBM := DllCall("SelectObject", Ptr, mDC, Ptr, hBM, Ptr)
    G := Gdip_GraphicsFromHDC(mDC)
    DllCall("gdiplus\GdipSetSmoothingMode", Ptr, G, "Int", 4)

    ; 绘制背景
    ;colorBG := isHovered ? 0xFFE81123 : 0x88333333
    ;pBrush := Gdip_BrushCreateSolid(colorBG)
    ;Gdip_FillEllipse(G, pBrush, 0, 0, size-1, size-1)
    ;Gdip_DeleteBrush(pBrush)

    ; 绘制 X
    colorX := isHovered ? 0xFFFF0000 : 0xFF808080  ; 红色 vs 灰色
    pPen := Gdip_CreatePen(colorX, CloseBtn_Thickness)  ; 加粗线条
    margin := CloseBtn_VisualMargin  ; 关闭按钮的视觉边距

    Gdip_DrawLine(G, pPen, margin, margin, size-margin-1, size-margin-1)
    Gdip_DrawLine(G, pPen, size-margin-1, margin, margin, size-margin-1)
    Gdip_DeletePen(pPen)

    ; 更新窗口
    VarSetCapacity(ptSrc, 8, 0)
    ; 注意这里的 Int64* 技巧，可以一次性传递 width 和 height
    DllCall("UpdateLayeredWindow", Ptr, hwnd, Ptr, hDC, Ptr, 0, "Int64*", size|size<<32, Ptr, mDC, Ptr, &ptSrc, "UInt", 0, "UInt*", alpha << 16 | 1 << 24, "UInt", 2)

    Gdip_DeleteGraphics(G)
    DllCall("SelectObject", Ptr, mDC, Ptr, oBM)
    DllCall("DeleteObject", Ptr, hBM)
    DllCall("DeleteDC", Ptr, mDC)
    DllCall("ReleaseDC", Ptr, 0, Ptr, hDC)
}

; 6. 底层 C++ / COM 接口模拟（兼容 32 位和 64 位 AHK）
; =================================================================
CreateDropTargetStruct() {
    global IDropTarget_VTable, IDropTarget_Obj
    ; IDropTarget 接口有 7 个方法，为其分配虚函数表 (VTable)
    VarSetCapacity(IDropTarget_VTable, 7 * A_PtrSize, 0)

    ; 将 AHK 函数绑定到 COM 对象的虚函数表
    NumPut(RegisterCallback("IDropTarget_QueryInterface", "", 3), IDropTarget_VTable, 0 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_AddRef", "", 1),         IDropTarget_VTable, 1 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_Release", "", 1),        IDropTarget_VTable, 2 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_DragEnter", "", 6),      IDropTarget_VTable, 3 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_DragOver", "", 5),       IDropTarget_VTable, 4 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_DragLeave", "", 1),      IDropTarget_VTable, 5 * A_PtrSize, "Ptr")
    NumPut(RegisterCallback("IDropTarget_Drop", "", 6),           IDropTarget_VTable, 6 * A_PtrSize, "Ptr")

    VarSetCapacity(IDropTarget_Obj, A_PtrSize, 0)
    NumPut(&IDropTarget_VTable, IDropTarget_Obj, 0, "Ptr")
    return &IDropTarget_Obj
}

;═════════════════════════════════当前鼠标所指的窗口 ═════════════════════════════════════════════════
MouseIsHwnd(hwnd) {
    MouseGetPos,,, win
    return (win = hwnd)
}

;[读取配置]
Var_Read(rValue,defVar:="",Section名:="基础配置",Config:="个人配置.ini",是否删除默认项:="是",为空时是否重置为默认值:="是"){
    IniRead, regVar,%Config%, %Section名%, %rValue%,% defVar ? defVar : A_Space

    if(regVar!=""){
        ; 【新增】：将 INI 中的安全占位符还原为真实的双行/多行换行符
        regVar := StrReplace(regVar, "[CRLF]", "`n")

        if(defVar!="" && regVar=defVar){
            if (是否删除默认项 = "是")
                IniDelete, %Config%, %Section名%, %rValue%
            return defVar
        }else
            return regVar
    }else{
        if (是否删除默认项 = "是")
            IniDelete, %Config%, %Section名%, %rValue%
        if (为空时是否重置为默认值 = "是")
            return defVar
        return ""
    }
}

;[写入配置]
Var_Set(vGui, var, sz,Section名:="基础配置",Config:="个人配置.ini"){
    StringCaseSense, On

    ; 【新增】：将多行文本中的真实换行符转义为安全的单行占位符，防止破坏 INI 结构
    vGui_safe := StrReplace(vGui, "`r`n", "[CRLF]")
    vGui_safe := StrReplace(vGui_safe, "`n", "[CRLF]")

    if(vGui_safe!=var)
        IniWrite,%vGui_safe%,%Config%, %Section名%, %sz%
    Else
        IniDelete,%Config%,%Section名%, %sz%
    StringCaseSense, Off
}

;═════════════════════════════════ 动作执行引擎 ═════════════════════════════════════════════════
ExecuteAction(Enable, Type, Param, DropData := "", DropType := "") {
    ; 如果未启用，或类型为 0，或类型为空，则什么都不做
    if (Enable != "1" || Type == "0" || Type == "")
        return

    ; --- 调用引擎解析占位符，返回一个待执行数组 ---
    CommandsToRun := ExpandPlaceholders(Param, DropData, DropType)

    ; --- 循环执行数组中的每一条命令 ---
    for index, FinalParam in CommandsToRun {

        ; 【类别 6】单独处理：执行AHK代码 (保持原样，无需过滤，直接让 AHK 原生解释器处理注释)
        if (Type == "6") {
            tempScript := A_Temp "\FloatingBall_TempRun.ahk"
            FileDelete, %tempScript%
            FileAppend, %FinalParam%, %tempScript%
            Run, "%A_AhkPath%" "%tempScript%"
        }
        ; 【类别 1-5】支持多行独立执行、支持注释和空行过滤
        else {
            ; 逐行解析当前参数
            Loop, Parse, FinalParam, `n, `r
            {
                lineCmd := Trim(A_LoopField) ; 去除首尾空白符

                ; 核心过滤逻辑：如果当前行是空行，或是以分号 ; 开头的注释，则直接跳过
                if (lineCmd == "" || SubStr(lineCmd, 1, 1) == ";")
                    continue

                ; 根据对应类型执行当前有效行
                if (Type == "1") {
                    ; 1=运行程序/打开文件夹
                    Run, %lineCmd%,, UseErrorLevel
                }
                else if (Type == "2") {
                    ; 2=发送按键
                    Send, %lineCmd%
                }
                else if (Type == "3") {
                    ; 3=发送文本 (纯文本模式)
                    SendRaw, %lineCmd%
                }
                else if (Type == "4") {
                    ; 4=调用RunAny (使用动态调用防报错兼容)
                    if IsFunc("RunAny_Send_WM_COPYDATA") {
                        funcName := "RunAny_Send_WM_COPYDATA"
                        %funcName%(lineCmd, "RunAny.ahk ahk_class AutoHotkey")
                    } else {
                        MsgBox, 48, 提示, 未找到 RunAny_ObjReg.ahk 库文件，无法执行调用。
                    }
                }
                else if (Type == "5") {
                    ; 5=内部命令
                    if (lineCmd = "Reload")
                        Reload
                    else if (lineCmd = "ExitApp")
                        ExitApp
                }
            }
        }

    }
}

; --- 拖放业务逻辑 ---
OnDropFiles(FileList) {
    global
    finalEnable := DropFile_Enable, finalType := DropFile_Type, finalParam := DropFile_Param
    if (GetKeyState("Ctrl", "P") && DropFile_Enable_ctrl == "1")
        finalEnable := DropFile_Enable_ctrl, finalType := DropFile_Type_ctrl, finalParam := DropFile_Param_ctrl
    else if (GetKeyState("Alt", "P") && DropFile_Enable_alt == "1")
        finalEnable := DropFile_Enable_alt, finalType := DropFile_Type_alt, finalParam := DropFile_Param_alt
    else if (GetKeyState("Shift", "P") && DropFile_Enable_shift == "1")
        finalEnable := DropFile_Enable_shift, finalType := DropFile_Type_shift, finalParam := DropFile_Param_shift

    ExecuteAction(finalEnable, finalType, finalParam, FileList, "File")
}

OnDropText(TextData) {
    global
    finalEnable := DropText_Enable, finalType := DropText_Type, finalParam := DropText_Param
    if (GetKeyState("Ctrl", "P") && DropText_Enable_ctrl == "1")
        finalEnable := DropText_Enable_ctrl, finalType := DropText_Type_ctrl, finalParam := DropText_Param_ctrl
    else if (GetKeyState("Alt", "P") && DropText_Enable_alt == "1")
        finalEnable := DropText_Enable_alt, finalType := DropText_Type_alt, finalParam := DropText_Param_alt
    else if (GetKeyState("Shift", "P") && DropText_Enable_shift == "1")
        finalEnable := DropText_Enable_shift, finalType := DropText_Type_shift, finalParam := DropText_Param_shift

    ExecuteAction(finalEnable, finalType, finalParam, TextData, "Text")
}

; ==============================================================================
; 优化后的选中文本/内容获取函数
; ==============================================================================
get_Selected(copyKey:="^c", time:="0.15", ByRef 判断内容类型:="") {
    SavedSelected := ""
    ClipSaved := ClipboardAll
    clipboard := ""

    ; 显式释放修饰键，防止发送按键时冲突
    SendInput, {Shift up}{Ctrl up}{Alt up}
    Sleep, 10

    SendInput, %copyKey%
    ClipWait, %time%, 1 ; 1表示等待任何数据（包含文件/文本）
    SavedSelected := clipboard

    if DllCall("IsClipboardFormatAvailable", "UInt", 15)
        判断内容类型 := "文件"
    else if DllCall("IsClipboardFormatAvailable", "UInt", 2)
        判断内容类型 := "图片"
    else if (SavedSelected != "")
        判断内容类型 := "文本"
    else
        判断内容类型 := "空"

    clipboard := ClipSaved
    ClipSaved := ""

    SendInput, {Shift up}{Ctrl up}{Alt up}
    return SavedSelected
}
; ==============================================================================
; 清理过期的落地临时文件 (仅保留最新生成的 N 个)
; ==============================================================================
CleanOldTempFiles(dir, prefix, maxCount) {
    if (maxCount <= 0)
        return

    FileList := ""
    ; 遍历目标目录下匹配前缀的所有 txt 文件
    Loop, Files, %dir%\%prefix%*.txt
    {
        ; 格式：修改时间 + Tab符 + 完整路径
        FileList .= A_LoopFileTimeModified "`t" A_LoopFileFullPath "`n"
    }

    if (FileList = "")
        return

    ; 使用 R 选项进行倒序排序（最新的时间戳会排在最上面）
    Sort, FileList, R

    ; 逐行解析，将超出保留名额的旧文件删除
    Loop, Parse, FileList, `n, `r
    {
        if (A_LoopField = "")
            continue

        ; A_Index 表示当前是倒序后的第几个文件
        if (A_Index > maxCount) {
            ; 提取 Tab 符之后的文件路径
            path := SubStr(A_LoopField, InStr(A_LoopField, "`t") + 1)
            FileDelete, %path%
        }
    }
}
; ==============================================================================
; 核心函数：ExpandPlaceholders (增强版 - 修复未匹配占位符残留问题)
; 作用：解析用户命令参数，根据不同的占位符、拖放模式返回可执行的命令数组
; ==============================================================================
ExpandPlaceholders(Param, DropData, DropType) {
    global
    cmdList := []
    TargetDir := A_ScriptDir "\Dropped"

    ; --------------------------------------------------------------------------
    ; 0. 系统与通用交互类占位符 (优先解析，防止干扰后续数据)
    ; --------------------------------------------------------------------------
    if InStr(Param, "{$Mouse") {
        CoordMode, Mouse, Screen
        MouseGetPos, mx, my
        Param := StrReplace(Param, "{$MouseX$}", mx)
        Param := StrReplace(Param, "{$MouseY$}", my)
        if InStr(Param, "{$MouseColor$}") {
            CoordMode, Pixel, Screen
            PixelGetColor, mcolor, %mx%, %my%, RGB
            Param := StrReplace(Param, "{$MouseColor$}", mcolor)
        }
    }

    if InStr(Param, "{$ActiveWindow$}") {
        WinGetActiveTitle, winTitle
        Param := StrReplace(Param, "{$ActiveWindow$}", winTitle)
    }
    if InStr(Param, "{$ActiveProcess$}") {
        WinGet, winProc, ProcessName, A
        Param := StrReplace(Param, "{$ActiveProcess$}", winProc)
    }
    if InStr(Param, "{$ActiveClass$}") {
        WinGetClass, winClass, A
        Param := StrReplace(Param, "{$ActiveClass$}", winClass)
    }

    while RegExMatch(Param, "i)\{\$Env:([^$]+)\$\}", match) {
        EnvGet, envVal, %match1%
        Param := StrReplace(Param, match, envVal)
    }

    while RegExMatch(Param, "i)\{\$inputbox\|([^|]*)\|([^|]*)\|([^$]*)\$\}", match) {
        InputBox, userInput, %match2%, %match3%, , , , , , , , %match1%
        if ErrorLevel
            return [] ; 用户取消输入，中断本次动作执行
        Param := StrReplace(Param, match, userInput)
    }

    if InStr(Param, "{$SelectFolder$}") {
        FileSelectFolder, selectedFolder, , 3, 请选择文件夹
        if (selectedFolder = "")
            return []
        Param := StrReplace(Param, "{$SelectFolder$}", selectedFolder)
    }

    ; --------------------------------------------------------------------------
    ; 1. 预处理：【拖放版占位符】向【基础占位符】的映射转换
    ; --------------------------------------------------------------------------
    if (DropType = "File") {
        Param := StrReplace(Param, "{$Dropped$}", "{$Dropped_file$}")
        Param := StrReplace(Param, "{$Dropped_loop$}", "{$Dropped_file_loop$}")
        if RegExMatch(Param, "i)\{\$Dropped_all\$(\|.*?)?\}", m)
            Param := StrReplace(Param, m, StrReplace(m, "Dropped_all", "Dropped_allfile"))
        Param := StrReplace(Param, "{$Droppedtofile$}", "{$Dropped_filetofile$}")
    } else if (DropType = "Text") {
        Param := StrReplace(Param, "{$Dropped$}", "{$Dropped_text$}")
        Param := StrReplace(Param, "{$Dropped_loop$}", "{$Dropped_text_loop$}")
        if RegExMatch(Param, "i)\{\$Dropped_all\$(\|.*?)?\}", m)
            Param := StrReplace(Param, m, StrReplace(m, "Dropped_all", "Dropped_alltext"))
        Param := StrReplace(Param, "{$Droppedtofile$}", "{$Dropped_texttofile$}")
    }

    ; --------------------------------------------------------------------------
    ; 2. 预处理：解析动态环境变量占位符
    ; --------------------------------------------------------------------------
    while RegExMatch(Param, "i)\{\$AHK_Var\|(.*?)\$\}", match) {
        varName := match1, varValue := ""
        if (varName != "")
            varValue := %varName%
        Param := StrReplace(Param, match, varValue)
    }

    ; --------------------------------------------------------------------------
    ; 3. 处理【不循环】类型的 Drop 数据
    ; --------------------------------------------------------------------------
    if InStr(Param, "{$Dropped_file$}")
        Param := StrReplace(Param, "{$Dropped_file$}", DropData)
    if InStr(Param, "{$Dropped_text$}")
        Param := StrReplace(Param, "{$Dropped_text$}", DropData)

    if RegExMatch(Param, "i)\{\$Dropped_allfile\$(\|.*?)?\}", match) {
        sep := match1 ? SubStr(match1, 2) : " "
        allPaths := ""
        Loop, Parse, DropData, `n, `r
        {
            if (A_LoopField != "")
                allPaths .= (allPaths = "" ? "" : sep) . """" . A_LoopField . """"
        }
        Param := StrReplace(Param, match, allPaths)
    }
    if RegExMatch(Param, "i)\{\$Dropped_alltext\$(\|.*?)?\}", match) {
        sep := match1 ? SubStr(match1, 2) : " "
        allText := ""
        Loop, Parse, DropData, `n, `r
        {
            if (A_LoopField != "")
                allText .= (allText = "" ? "" : sep) . A_LoopField
        }
        Param := StrReplace(Param, match, allText)
    }

    if InStr(Param, "{$Dropped_filetofile$}") {
        if !InStr(FileExist(TargetDir), "D")
            FileCreateDir, %TargetDir%
        tempFile := TargetDir "\DropPaths_" A_TickCount ".txt"
        FileDelete, %tempFile%
        FileAppend, %DropData%, %tempFile%, UTF-8

        ; 触发清理旧文件
        CleanOldTempFiles(TargetDir, "DropPaths_", MaxTempFiles)

        Param := StrReplace(Param, "{$Dropped_filetofile$}", tempFile)
    }
    if InStr(Param, "{$Dropped_texttofile$}") {
        if !InStr(FileExist(TargetDir), "D")
            FileCreateDir, %TargetDir%
        tempFile := TargetDir "\DropText_" A_TickCount ".txt"
        FileDelete, %tempFile%
        FileAppend, %DropData%, %tempFile%, UTF-8

        ; 触发清理旧文件
        CleanOldTempFiles(TargetDir, "DropText_", MaxTempFiles)

        Param := StrReplace(Param, "{$Dropped_texttofile$}", tempFile)
    }

    ; --- 新增：处理【拖入文件_获取第一行文件属性】相关的占位符 ---
    if InStr(Param, "{$Dropped_file_f_") {
        firstLine := ""
        Loop, Parse, DropData, `n, `r
        {
            if (A_LoopField != "") {
                firstLine := A_LoopField
                break
            }
        }
        SplitPath, firstLine, f_name, f_dir, f_ext, f_nameNoExt, f_drive
        RegExMatch(f_dir, "[^\\]+$", f_dirname)

        Param := StrReplace(Param, "{$Dropped_file_f_path$}", firstLine)
        Param := StrReplace(Param, "{$Dropped_file_f_name$}", f_name)
        Param := StrReplace(Param, "{$Dropped_file_f_dir$}", f_dir)
        Param := StrReplace(Param, "{$Dropped_file_f_ext$}", f_ext)
        Param := StrReplace(Param, "{$Dropped_file_f_nameNoExt$}", f_nameNoExt)
        Param := StrReplace(Param, "{$Dropped_file_f_drive$}", f_drive)
        Param := StrReplace(Param, "{$Dropped_file_f_dirname$}", f_dirname)
    }

    ; --------------------------------------------------------------------------
    ; 4. 处理【Selected 原地获取内容】相关的占位符 (非循环部分)
    ; --------------------------------------------------------------------------
    selText := ""
    if RegExMatch(Param, "i)\{\$Selected(_[^$]+)?\$\}") {
        ; 【修改】：将原本无参的调用改为传入配置好的变量
        selText := get_Selected(SelectedCopyKey, SelectedWaitTime)

        if InStr(Param, "{$Selected$}")
            Param := StrReplace(Param, "{$Selected$}", selText)

        if InStr(Param, "{$Selectedtofile$}") {
            if !InStr(FileExist(TargetDir), "D")
                FileCreateDir, %TargetDir%
            tempFile := TargetDir "\Selected_" A_TickCount ".txt"
            FileDelete, %tempFile%
            FileAppend, %selText%, %tempFile%, UTF-8

            ; 触发清理旧文件
            CleanOldTempFiles(TargetDir, "Selected_", MaxTempFiles)

            Param := StrReplace(Param, "{$Selectedtofile$}", tempFile)
        }

        if RegExMatch(Param, "i)\{\$Selected_all(\|.*?)?\}", match) {
            sep := match1 ? SubStr(match1, 2) : " "
            combined := ""
            Loop, Parse, selText, `n, `r
            {
                if (A_LoopField != "")
                    combined .= (combined = "" ? "" : sep) . """" . A_LoopField . """"
            }
            Param := StrReplace(Param, match, combined)
        }

        if InStr(Param, "{$Selected_f_") {
            firstLine := ""
            Loop, Parse, selText, `n, `r
            {
                if (A_LoopField != "") {
                    firstLine := A_LoopField
                    break
                }
            }
            SplitPath, firstLine, f_name, f_dir, f_ext, f_nameNoExt, f_drive
            RegExMatch(f_dir, "[^\\]+$", f_dirname)

            Param := StrReplace(Param, "{$Selected_f_path$}", firstLine)
            Param := StrReplace(Param, "{$Selected_f_name$}", f_name)
            Param := StrReplace(Param, "{$Selected_f_dir$}", f_dir)
            Param := StrReplace(Param, "{$Selected_f_ext$}", f_ext)
            Param := StrReplace(Param, "{$Selected_f_nameNoExt$}", f_nameNoExt)
            Param := StrReplace(Param, "{$Selected_f_drive$}", f_drive)
            Param := StrReplace(Param, "{$Selected_f_dirname$}", f_dirname)
        }
    }

    ; --------------------------------------------------------------------------
    ; 5. 处理【带有 _loop 标记的循环】类型占位符
    ; --------------------------------------------------------------------------
    hasDropLoop := InStr(Param, "{$Dropped_file_loop$}") || InStr(Param, "{$Dropped_text_loop$}")
    hasSelLoop  := InStr(Param, "{$Selected_loop")

    if (hasDropLoop) {
        Loop, Parse, DropData, `n, `r
        {
            if (A_LoopField = "")
                continue
            line := A_LoopField
            currentCmd := Param

            if InStr(currentCmd, "{$Dropped_file_loop") {
                SplitPath, line, l_name, l_dir, l_ext, l_nameNoExt, l_drive
                RegExMatch(l_dir, "[^\\]+$", l_dirname)

                l_dbl := StrReplace(line, "\", "\\")
                l_dbl_bs := StrReplace(line, "/", "\")

                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop$}", line)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_dbl$}", l_dbl)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_dbl_bs$}", l_dbl_bs)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_name$}", l_name)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_dir$}", l_dir)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_ext$}", l_ext)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_nameNoExt$}", l_nameNoExt)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_drive$}", l_drive)
                currentCmd := StrReplace(currentCmd, "{$Dropped_file_loop_dirname$}", l_dirname)
            }

            if InStr(currentCmd, "{$Dropped_text_loop$}")
                currentCmd := StrReplace(currentCmd, "{$Dropped_text_loop$}", line)

            cmdList.Push(currentCmd)
        }
    } else if (hasSelLoop && selText != "") {
        Loop, Parse, selText, `n, `r
        {
            if (A_LoopField = "")
                continue
            line := A_LoopField
            currentCmd := Param

            SplitPath, line, l_name, l_dir, l_ext, l_nameNoExt, l_drive
            RegExMatch(l_dir, "[^\\]+$", l_dirname)

            l_dbl := StrReplace(line, "\", "\\")
            l_dbl_bs := StrReplace(line, "/", "\")

            currentCmd := StrReplace(currentCmd, "{$Selected_loop$}", line)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_dbl$}", l_dbl)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_dbl_bs$}", l_dbl_bs)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_name$}", l_name)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_dir$}", l_dir)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_ext$}", l_ext)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_nameNoExt$}", l_nameNoExt)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_drive$}", l_drive)
            currentCmd := StrReplace(currentCmd, "{$Selected_loop_dirname$}", l_dirname)

            cmdList.Push(currentCmd)
        }
    } else {
        ; 没有循环标记，或者开启了循环但是缺少有效数据源（比如空选取），存入原始队列
        cmdList.Push(Param)
    }

    ; 遍历执行队列，使用正则表达式找出所有未被成功替换的 {$xxx$} 标签，直接替换为空
    for index, finalCmd in cmdList {
        cmdList[index] := RegExReplace(finalCmd, "i)\{\$.*?\$\}", "")
    }

    return cmdList
}

; ==============================================================================
; 再次优化：微调纵向间距，解决第一行贴顶问题
; ==============================================================================
ShowEventSettingsGUI:
    global hEventGui, pToken
    if WinExist("ahk_id " hEventGui) {
        Gui, EventSettings: show
        return
    }

    Events := ["左键单击", "中键单击", "滚轮向上", "滚轮向下", "拖放_文件", "拖放_文本"]
    Sections := ["左键单击事件", "中键单击事件", "滚轮向上事件", "滚轮向下事件", "拖放事件_文件", "拖放事件_文本"]
    Prefixes := ["LBtn", "MBtn", "WheelUp", "WheelDown", "DropFile", "DropText"]
    TypeDesc := "1=运行程序/打开文件夹|2=发送按键|3=发送文本|4=调用RunAny|5=内部命令|6=执行AHK代码"

    ; 保持全宽 720，高度稍微撑大 10px 到 325，给内部留出向下挪动的空间
    Gui, EventSettings: New, +HwndhEventGui -Caption
    Gui, EventSettings: Color, %G_BgColor%
    Gui, EventSettings: Margin, 0, 0

    W := 720, H := 325

    ; === 【修复系统缩放裁剪问题】 获取系统 DPI，按比例放大 GDI 绘图区域 ===
    DPIScale := A_ScreenDPI / 96
    RealW := Round(W * DPIScale)
    RealH := Round(H * DPIScale)
    RealRgn := Round(20 * DPIScale)
    RealBgRadius := Round(15 * DPIScale)

    SetWindowRgn(hEventGui, RealW, RealH, RealRgn)
    DrawRoundedBackground_API(hEventGui, RealW, RealH, RealBgRadius, G_BgARGB, G_BorderARGB)
    ; ====================================================================

    Gui, EventSettings: Font, s12 c%G_FontColor% w700, 微软雅黑
    Gui, EventSettings: Add, Text, x20 y5 w680 h40 BackgroundTrans gGuiDrag, 悬浮球事件高级设置

    ; Tab 高度同步撑大到 215
    Gui, EventSettings: Font, s9 c%G_SubFontColor% w400, 微软雅黑
    Gui, EventSettings: Add, Tab3, x15 y45 w690 h215 c%G_FontColor%, 左键单击|中键单击|滚轮向上|滚轮向下|拖放文件|拖放文本

    Loop, 6 {
        idx := A_Index
        pref := Prefixes[idx]
        Gui, EventSettings: Tab, %idx%

        ; 提取内存变量
        curEnable := %pref%_Enable, curType := %pref%_Type, curParam := %pref%_Param
        curEnableCtrl := %pref%_Enable_ctrl, curTypeCtrl := %pref%_Type_ctrl, curParamCtrl := %pref%_Param_ctrl
        curEnableAlt := %pref%_Enable_alt, curTypeAlt := %pref%_Type_alt, curParamAlt := %pref%_Param_alt
        curEnableShift := %pref%_Enable_shift, curTypeShift := %pref%_Type_shift, curParamShift := %pref%_Param_shift

        ; --- 第 1 行：无修饰键 (Y基准下移至 80) ---
        Gui, EventSettings: Add, Text, x20 y83 c%G_FontColor% w75, 【无修饰键】
        Gui, EventSettings: Add, Checkbox, % "x95 y83 w45 v" pref "_EnableChecked " (curEnable="1" ? "Checked" : ""), 启用
        Gui, EventSettings: Add, DropDownList, % "x140 y80 w130 v" pref "_TypeChoice Choose" curType, %TypeDesc%
        Gui, EventSettings: Add, Edit, % "x275 y80 w285 h25 v" pref "_ParamEdit cBlack", %curParam%
        Gui, EventSettings: Add, Button, % "x565 y79 w30 h25 gOpenLargeEditor vBtnEdit_" pref "_ParamEdit", 📝
        Gui, EventSettings: Add, Button, % "x600 y79 w40 h25 gTestRunParam vBtnRun_" pref "_ParamEdit", ▶
        Gui, EventSettings: Add, Button, % "x645 y79 w40 h25 gTestParseParam vBtnParse_" pref "_ParamEdit", 🔍

        ; --- 第 2 行：按住 Ctrl (Y基准: 125) ---
        Gui, EventSettings: Add, Text, x20 y128 c00CCFF w75, 【按住 Ctrl】
        Gui, EventSettings: Add, Checkbox, % "x95 y128 w45 v" pref "_EnableCtrlChecked " (curEnableCtrl="1" ? "Checked" : ""), 启用
        Gui, EventSettings: Add, DropDownList, % "x140 y125 w130 v" pref "_TypeCtrlChoice Choose" curTypeCtrl, %TypeDesc%
        Gui, EventSettings: Add, Edit, % "x275 y125 w285 h25 v" pref "_ParamCtrlEdit cBlack", %curParamCtrl%
        Gui, EventSettings: Add, Button, % "x565 y124 w30 h25 gOpenLargeEditor vBtnEdit_" pref "_ParamCtrlEdit", 📝
        Gui, EventSettings: Add, Button, % "x600 y124 w40 h25 gTestRunParam vBtnRun_" pref "_ParamCtrlEdit", ▶
        Gui, EventSettings: Add, Button, % "x645 y124 w40 h25 gTestParseParam vBtnParse_" pref "_ParamCtrlEdit", 🔍

        ; --- 第 3 行：按住 Alt (Y基准: 170) ---
        Gui, EventSettings: Add, Text, x20 y173 cFFB000 w75, 【按住 Alt】
        Gui, EventSettings: Add, Checkbox, % "x95 y173 w45 v" pref "_EnableAltChecked " (curEnableAlt="1" ? "Checked" : ""), 启用
        Gui, EventSettings: Add, DropDownList, % "x140 y170 w130 v" pref "_TypeAltChoice Choose" curTypeAlt, %TypeDesc%
        Gui, EventSettings: Add, Edit, % "x275 y170 w285 h25 v" pref "_ParamAltEdit cBlack", %curParamAlt%
        Gui, EventSettings: Add, Button, % "x565 y169 w30 h25 gOpenLargeEditor vBtnEdit_" pref "_ParamAltEdit", 📝
        Gui, EventSettings: Add, Button, % "x600 y169 w40 h25 gTestRunParam vBtnRun_" pref "_ParamAltEdit", ▶
        Gui, EventSettings: Add, Button, % "x645 y169 w40 h25 gTestParseParam vBtnParse_" pref "_ParamAltEdit", 🔍

        ; --- 第 4 行：按住 Shift (Y基准: 215) ---
        Gui, EventSettings: Add, Text, x20 y218 c00FF66 w75, 【按住Shift】
        Gui, EventSettings: Add, Checkbox, % "x95 y218 w45 v" pref "_EnableShiftChecked " (curEnableShift="1" ? "Checked" : ""), 启用
        Gui, EventSettings: Add, DropDownList, % "x140 y215 w130 v" pref "_TypeShiftChoice Choose" curTypeShift, %TypeDesc%
        Gui, EventSettings: Add, Edit, % "x275 y215 w285 h25 v" pref "_ParamShiftEdit cBlack", %curParamShift%
        Gui, EventSettings: Add, Button, % "x565 y214 w30 h25 gOpenLargeEditor vBtnEdit_" pref "_ParamShiftEdit", 📝
        Gui, EventSettings: Add, Button, % "x600 y214 w40 h25 gTestRunParam vBtnRun_" pref "_ParamShiftEdit", ▶
        Gui, EventSettings: Add, Button, % "x645 y214 w40 h25 gTestParseParam vBtnParse_" pref "_ParamShiftEdit", 🔍
    }

    ; 底部保存/应用/取消按钮顺应窗口高度下移到 275
    Gui, EventSettings: Tab
    Gui, EventSettings: Add, Button, x15 y275 w110 h30 gShowPlaceholderHelp, ❓ 占位符说明
    Gui, EventSettings: Add, Button, x435 y275 w80 h30 Default gSaveEventSettings, 确定
    Gui, EventSettings: Add, Button, x530 y275 w80 h30 gApplyEventSettings, 应用
    Gui, EventSettings: Add, Button, x625 y275 w80 h30 gCancelEventSettings, 取消

    Gui, EventSettings: Show, w%W% h%H%, 悬浮球事件设置
return
; ==============================================================================
; 附加功能：呼出多行大编辑框 (已去除提示文本，布局重新自适应)
; ==============================================================================
OpenLargeEditor:
    ; 获取目标变量名并提取文本内容
    TargetEditVar := SubStr(A_GuiControl, 9)
    GuiControlGet, CurrentText, EventSettings:, %TargetEditVar%

    ; 禁用主面板
    Gui, EventSettings: +Disabled

    Gui, LargeEditor: Destroy

    Gui, LargeEditor: +OwnerEventSettings +Resize +MaximizeBox
    Gui, LargeEditor: Color, %G_BgColor%
    ; 【修改】：边距极度紧凑化 (原为 15, 15)
    Gui, LargeEditor: Margin, 4, 4

    Gui, LargeEditor: Font, s10 cBlack w400, 微软雅黑
    Gui, LargeEditor: Add, Edit, w800 h500 vLargeEditText Multi VScroll HScroll, %CurrentText%

    Gui, LargeEditor: Font, s9 c%G_FontColor% w400, 微软雅黑

    ; 【新增】：在左侧添加占位符说明按钮
    Gui, LargeEditor: Add, Button, x4 y530 w110 h30 gShowPlaceholderHelp vBtnLargeHelp, ❓ 占位符说明

    ; 【新增】：在确定按钮左侧添加执行和解析按钮 (复用原有的 g 标签)
    Gui, LargeEditor: Add, Button, x524 y530 w40 h30 gTestRunParam vBtnLargeRun, ▶
    Gui, LargeEditor: Add, Button, x572 y530 w40 h30 gTestParseParam vBtnLargeParse, 🔍

    Gui, LargeEditor: Add, Button, x620 y530 w100 h30 Default gSaveLargeEditor vBtnSave, 确定保存
    Gui, LargeEditor: Add, Button, x730 y530 w100 h30 gCancelLargeEditor vBtnCancel, 取消

    Gui, LargeEditor: Show, Center, 展开编辑
return

SaveLargeEditor:
    Gui, LargeEditor: Submit, NoHide
    ; 将大编辑框内的新文本，同步写回主面板对应的单行输入框中
    GuiControl, EventSettings:, %TargetEditVar%, %LargeEditText%

    Gui, EventSettings: -Disabled
    Gui, LargeEditor: Destroy
return

CancelLargeEditor:
LargeEditorGuiEscape:
LargeEditorGuiClose:
    Gui, EventSettings: -Disabled
    Gui, LargeEditor: Destroy
return

; ==============================================================================
; 参数实时解析与测试功能
; ==============================================================================
TestParseParam:
TestRunParam:
    ; 判断当前点击的是“解析”还是“执行”按钮
    IsRunMode := (A_ThisLabel = "TestRunParam")

    ; 【新增】判断触发来源是主面板还是大编辑框
    if (A_Gui = "LargeEditor") {
        ; 1. 如果来自大编辑框，直接获取大编辑框的内容
        Gui, LargeEditor: Submit, NoHide
        RawParam := LargeEditText

        ; 2. TargetEditVar 在 OpenLargeEditor 时已被全局记录，据此推算对应的下拉框变量
        TargetTypeVar := StrReplace(TargetEditVar, "Param", "Type")
        TargetTypeVar := StrReplace(TargetTypeVar, "Edit", "Choice")

        ; 3. 由于下拉框在 EventSettings 面板中，使用 GuiControlGet 获取其值
        GuiControlGet, RawType, EventSettings:, %TargetTypeVar%

    } else {
        ; 1. 原始逻辑：从触发控件的 vLabel (例如 vBtnRun_LBtn_ParamEdit) 提取真正的 Edit 控件名
        ActionPrefix := SubStr(A_GuiControl, 1, InStr(A_GuiControl, "_", false, 1, 1))
        TargetEditVar := SubStr(A_GuiControl, StrLen(ActionPrefix) + 1)

        ; 2. 获取该输入框的实时内容
        Gui, EventSettings: Submit, NoHide
        RawParam := %TargetEditVar%

        ; 3. 获取同级别的下拉框类型
        TargetTypeVar := StrReplace(TargetEditVar, "Param", "Type")
        TargetTypeVar := StrReplace(TargetTypeVar, "Edit", "Choice")
        RawType := %TargetTypeVar%
    }

    RegExMatch(RawType, "^\d+", CleanType) ; 提取纯数字 Type

    ; 4. 若为拖放事件，则提供一些测试桩数据 (Dummy Data) 以便测试
    dummyDropData := ""
    dummyDropType := ""
    if InStr(TargetEditVar, "DropFile") {
        dummyDropData := A_WinDir "\notepad.exe`n" A_WinDir "\explorer.exe"
        dummyDropType := "File"
    } else if InStr(TargetEditVar, "DropText") {
        dummyDropData := "【这是模拟的拖放文本片段第一行】`n【这是第二行】"
        dummyDropType := "Text"
    }

    ; 5. 调用核心引擎解析占位符
    parsedArr := ExpandPlaceholders(RawParam, dummyDropData, dummyDropType)

    ; 6. 构造输出信息
    outStr := "【原始配置参数】:`n" RawParam "`n`n"
    if (dummyDropData != "")
        outStr .= "【注入的模拟输入数据】:`n" dummyDropData "`n`n"

    outStr .= "【最终解析结果】 (共 " parsedArr.MaxIndex() " 条指令):`n"
    for k, v in parsedArr
        outStr .= k ". " v "`n"

    ; 7. 弹窗展现或执行 (支持鼠标划选复制 + 动态调整窗口大小)
    Gui, ParsePreview: Destroy

    Gui, ParsePreview: +OwnerEventSettings +Resize +MaximizeBox
    Gui, ParsePreview: Color, %G_BgColor%
    ; 【修改】：边距缩短为 4
    Gui, ParsePreview: Margin, 4, 4

    if (IsRunMode) {
        if (CleanType = "0" || CleanType = "") {
            MsgBox, 48, 提示, 当前选择的功能类型为【无】，无法执行测试。
            return
        }

        Gui, ParsePreview: Font, s11 cFF5555 w700, 微软雅黑
        Gui, ParsePreview: Add, Text, w550, ⚠️ 是否要以类型 [%CleanType%] 立即执行以下命令？

        Gui, ParsePreview: Font, s10 cBlack w400, 微软雅黑
        ; 【修改】：纵向间距从 y+10 缩小为 y+6
        Gui, ParsePreview: Add, Edit, c%G_FontColor% y+6 w550 h250 ReadOnly Multi vPreviewEdit VScroll HScroll, %outStr%

        Gui, ParsePreview: Font, s9 c%G_FontColor% w400, 微软雅黑
        ; 【修改】：纵向间距缩小为 y+8
        Gui, ParsePreview: Add, Button, x340 y+8 w100 h30 Default gConfirmRunTest vBtnPreviewConfirm, 确认执行
        Gui, ParsePreview: Add, Button, x444 yp w100 h30 gCloseParsePreview vBtnPreviewCancel, 取消
        Gui, ParsePreview: Show, Center, 测试与执行

        ; 保存参数供下方确认执行标签使用
        TestRun_Type := CleanType
        TestRun_Param := RawParam
        TestRun_DropData := dummyDropData
        TestRun_DropType := dummyDropType
    } else {
        Gui, ParsePreview: Font, s11 c%G_FontColor% w700, 微软雅黑
        Gui, ParsePreview: Add, Text, w550, 🔍 解析结果预览

        Gui, ParsePreview: Font, s10 cBlack w400, 微软雅黑
        ; 【修改】：纵向间距从 y+10 缩小为 y+6
        Gui, ParsePreview: Add, Edit, c%G_FontColor% y+6 w550 h250 ReadOnly Multi vPreviewEdit VScroll HScroll, %outStr%

        Gui, ParsePreview: Font, s9 c%G_FontColor% w400, 微软雅黑
        ; 【修改】：纵向间距缩小为 y+8
        Gui, ParsePreview: Add, Button, x444 y+8 w100 h30 Default gCloseParsePreview vBtnPreviewClose, 关闭
        Gui, ParsePreview: Show, Center, 仅解析预览
    }
return

; ==============================================================================
; 监听解析预览窗口的大小改变事件
; ==============================================================================
ParsePreviewGuiSize:
    if (A_EventInfo = 1) ; 窗口最小化时不处理
        return

    ; 【修改】：1. 动态计算 Edit 文本框的大小
    ; 宽度: 减去左右边距各4 (共8)
    ; 高度: 扣除顶边距(4)、文字高(约20)、间距(6)、按钮(30)、底边距(4)，综合偏置量约 75
    NewEditW := A_GuiWidth - 8
    NewEditH := A_GuiHeight - 75
    if (NewEditH < 50)
        NewEditH := 50 ; 防止极端缩小导致报错

    GuiControl, Move, PreviewEdit, w%NewEditW% h%NewEditH%

    ; 【修改】：2. 动态计算按钮的 Y 坐标 (距离底部 34)
    NewBtnY := A_GuiHeight - 34

    ; 【修改】：3. 动态计算按钮的 X 坐标 (靠右对齐)
    NewRightBtnX := A_GuiWidth - 104 ; 最右边按钮 (取消 / 关闭)
    NewLeftBtnX  := A_GuiWidth - 208 ; 靠左边按钮 (确认执行)

    ; 4. 执行坐标移动
    GuiControl, Move, BtnPreviewConfirm, x%NewLeftBtnX% y%NewBtnY%
    GuiControl, Move, BtnPreviewCancel, x%NewRightBtnX% y%NewBtnY%
    GuiControl, Move, BtnPreviewClose, x%NewRightBtnX% y%NewBtnY%
return

; ==============================================================================

ConfirmRunTest:
    Gui, ParsePreview: Destroy
    ExecuteAction("1", TestRun_Type, TestRun_Param, TestRun_DropData, TestRun_DropType)
return

CloseParsePreview:
ParsePreviewGuiEscape:
ParsePreviewGuiClose:
    Gui, ParsePreview: Destroy
return

; ==============================================================================
; 悬浮球内置占位符说明面板
; ==============================================================================
ShowPlaceholderHelp:
    helpText =
    (
=== 文件专用占位符 (针对拖入文件路径) ===
{$Dropped_file$}	 - 返回包含所有被拖入文件路径的原始多行文本（不循环）
{$Dropped_file_loop$}	 - 循环处理每个文件。有几个文件，外层命令就拆分并执行几次
{$Dropped_file_loop_dbl$}	 - 将斜杠替换为双斜杠（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_dbl_bs$}	 - 将斜杠替换为反斜杠（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_name$}	 - 只返回文件名（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_dir$}	 - 只返回文件所在目录（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_ext$}	 - 只返回文件后缀（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_nameNoExt$}	 - 只返回文件名不含后缀（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_drive$}	 - 只返回文件所在驱动器（循环处理每个被拖入的文件路径）
{$Dropped_file_loop_dirname$}	 - 只返回文件所在目录的文件夹名称（循环处理每个被拖入的文件路径）

{$Dropped_file_f_path$}	 - 文件完整路径（拖入多个文件时只获取第一行）
{$Dropped_file_f_name$}	 - 文件名（拖入多个文件时只获取第一行）
{$Dropped_file_f_dir$}	 - 文件所在目录（拖入多个文件时只获取第一行）
{$Dropped_file_f_ext$}	 - 文件后缀（拖入多个文件时只获取第一行）
{$Dropped_file_f_nameNoExt$}	 - 文件名不含后缀（拖入多个文件时只获取第一行）
{$Dropped_file_f_drive$}	 - 文件所在驱动器（拖入多个文件时只获取第一行）
{$Dropped_file_f_dirname$}	 - 文件所在目录的文件夹名称（拖入多个文件时只获取第一行）

{$Dropped_filetofile$}	 - 将拖入的所有文件路径的原始多行文本整体落地保存到脚本目录下 Dropped 文件夹里的临时 .txt 文件中，并返回其文件路径
{$Dropped_allfile$}	 - 将所有文件路径合并为单行，默认用空格分隔，且每个路径自带双引号防护
{$Dropped_allfile|间隔词$}	 - 将所有文件路径合并为单行，并在路径之间插入自定义的间隔词

=== 文本专用占位符 (针对拖入/剪贴板纯文本) ===
{$Dropped_text$}	 - 原地返回用户拖入的原始多行纯文本内容（不循环、不拆分）
{$Dropped_text_loop$}	 - 开启循环模式。将多行文本按行拆分，每行内容分别触发执行一次命令
{$Dropped_texttofile$}	 - 将拖入的所有文本内容整体落地保存到脚本目录下 Dropped 文件夹里的一个临时 .txt 文件中，并返回其文件路径
{$Dropped_alltext$}	 - 将多行纯文本合并为单行文本，默认行与行之间用空格进行分隔
{$Dropped_alltext|间隔词$}	 - 将多行纯文本合并为单行，行与行之间使用自定义的间隔词进行连接

=== 获取选中内容专用占位符(通过ctrl+c获取)===
{$Selected$}	 - 原地返回选中的原始多行纯文本内容（不循环、不拆分）
{$Selected_loop$}	 - 开启循环模式。将选中的内容按行拆分，每行内容分别触发执行一次命令

{$Selected_loop_dbl$}	 - 将斜杠替换为双斜杠（如果每行内容是一个文件路径时）
{$Selected_loop_dbl_bs$}	 - 将斜杠替换为反斜杠（如果每行内容是一个文件路径时）
{$Selected_loop_name$}	 - 只返回文件名（如果每行内容是一个文件路径时）
{$Selected_loop_dir$}	 - 只返回文件所在目录（如果每行内容是一个文件路径时）
{$Selected_loop_ext$}	 - 只返回文件后缀（如果每行内容是一个文件路径时）
{$Selected_loop_nameNoExt$}	 - 只返回文件名不含后缀（如果每行内容是一个文件路径时）
{$Selected_loop_drive$}	 - 只返回文件所在驱动器（如果每行内容是一个文件路径时）
{$Selected_loop_dirname$}	 - 只返回文件所在目录的文件夹名称（如果每行内容是一个文件路径时）

{$Selected_f_path$}	 - 文件完整路径（选中的内容多行只获取第一行）
{$Selected_f_name$}	 - 文件名（选中的内容多行只获取第一行）
{$Selected_f_dir$}	 - 文件所在目录（选中的内容多行只获取第一行）
{$Selected_f_ext$}	 - 文件后缀（选中的内容多行只获取第一行）
{$Selected_f_nameNoExt$}	 - 文件名不含后缀（选中的内容多行只获取第一行）
{$Selected_f_drive$}	 - 文件所在驱动器（选中的内容多行只获取第一行）
{$Selected_f_dirname$}	 - 文件所在目录的文件夹名称（选中的内容多行只获取第一行）

{$Selectedtofile$}	 - 将选中的内容整体落地保存到脚本目录下 Dropped 文件夹里的临时 .txt 文件中，并返回其文件路径
{$Selected_all$}	 - 将选中的多行纯文本合并为单行文本，每行用双引号包裹，默认行与行之间用空格进行分隔
{$Selected_all|间隔词$}	 - 将选中的多行纯文本合并为单行，每行用双引号包裹，行与行之间使用自定义的间隔词进行连接

=== 核心全局变量占位符 ===
{$AHK_Var|变量名$}	 - 动态获取并替换当前脚本中任何全局变量或 AHK 内置变量的值（例如当前年份、桌面路径等）

{$SelectFolder$}	 - 弹出文件夹选择对话框，返回选中的路径
{$ActiveWindow$}	 - 当前活动窗口标题
{$ActiveProcess$}	 - 当前活动窗口进程名（如 chrome.exe）
{$ActiveClass$}	 - 当前活动窗口的类名（如 Chrome_WidgetWin_1）
{$Env:变量名$}	 - 读取系统环境变量（例如 {$Env:USERPROFILE$} 或 {$Env:PATH$}）
{$MouseX$}	 - 鼠标当前屏幕坐标 X
{$MouseY$}	 - 鼠标当前屏幕坐标 Y
{$MouseColor$}	 - 鼠标位置像素的 RGB 颜色值（如 0xFFAA00）
{$inputbox|默认值|这是标题|这是备注$}	 - 弹出一个输入框输入指定值，并返回输入内容

=== 智能无缝占位符 (自动适配文件或文本) ===
{$Dropped$}	 - 智能版基础位。文件模式下等同于原始多行路径，文本模式下等同于原始多行文本（不循环）
{$Dropped_loop$}	 - 智能版循环位。文件模式下按文件数量循环，文本模式下按文本行数循环
{$Dropped_all$}	 - 智能版全合并。文件模式下等同于合并路径串，文本模式下等同于合并多行纯文字（默认空格分隔）
{$Dropped_all|间隔词$}	 - 智能版带词合并。自动合并多行数据，并在中间插入您自定义的间隔词
{$Droppedtofile$}	 - 智能版内容落地。无论拖入的是文件还是纯文本，都将内容整体落地为当前存储目录下的一个临时 .txt 文件（不循环）
    )

    Gui, HelpGui: Destroy
    ; 允许调整大小和最大化
    Gui, HelpGui: +OwnerEventSettings +Resize +MaximizeBox
    Gui, HelpGui: Color, %G_BgColor%

    ; 【优化】将边距从 12 缩小到 6，让编辑框极其贴近窗口边缘
    Gui, HelpGui: Margin, 4, 4

    Gui, HelpGui: Font, s10 cBlack w400, 微软雅黑
    ; 【优化】去掉了标题文本和按钮，Edit 框直接从 x6 y6 开始，填满初始窗口
    Gui, HelpGui: Add, Edit, x6 y6 w560 h720 ReadOnly vHelpEdit c%G_FontColor% Multi VScroll HScroll, %helpText%

    Gui, HelpGui: Show,, 占位符说明
return

; ==============================================================================
; 监听说明窗口大小改变事件 (极致精简版)
; ==============================================================================
HelpGuiGuiSize:
    if (A_EventInfo = 1) ; 最小化时不处理
        return

    ; 【优化】因为没有了标题和按钮，编辑框的宽高直接减去两边的边距（6 * 2 = 12）即可
    NewHelpEditW := A_GuiWidth - 12
    NewHelpEditH := A_GuiHeight - 12
    if (NewHelpEditH < 50)
        NewHelpEditH := 50

    GuiControl, Move, HelpEdit, w%NewHelpEditW% h%NewHelpEditH%
return

; 依然保留标准的关闭行为（点击右上角红叉或按 Esc 键关闭窗口）
HelpGuiGuiClose:
HelpGuiGuiEscape:
HelpGuiClose:
    Gui, HelpGui: Destroy
return

; ==============================================================================
; 监听窗口大小改变事件，实现内部控件自适应排版
; ==============================================================================
LargeEditorGuiSize:
    if (A_EventInfo = 1) ; 窗口被最小化时不作处理
        return

    NewEditW := A_GuiWidth - 8
    NewEditH := A_GuiHeight - 42
    GuiControl, Move, LargeEditText, w%NewEditW% h%NewEditH%

    NewBtnY := A_GuiHeight - 34

    NewCancelX := A_GuiWidth - 104  ; 取消按钮：靠右侧对齐 (宽100 + 右留白4)
    NewSaveX   := A_GuiWidth - 208  ; 保存按钮：紧贴取消按钮左侧

    NewParseX  := NewSaveX - 44     ; 解析按钮：宽40 + 左侧间距4
    NewRunX    := NewParseX - 44    ; 运行按钮：宽40 + 左侧间距4
    NewHelpX   := 4

    ; 4. 执行坐标移动
    GuiControl, Move, BtnSave, x%NewSaveX% y%NewBtnY%
    GuiControl, Move, BtnCancel, x%NewCancelX% y%NewBtnY%

    GuiControl, Move, BtnLargeParse, x%NewParseX% y%NewBtnY%
    GuiControl, Move, BtnLargeRun, x%NewRunX% y%NewBtnY%
    GuiControl, Move, BtnLargeHelp, x%NewHelpX% y%NewBtnY%
return
; ==============================================================================

SaveEventSettings:
    GoSub, CoreSaveEventSettings ; 执行核心保存逻辑
    ; 确认保存后执行关闭动作
    Gui, EventSettings: Destroy
return

; ==============================================================================
; --- 新增：配置管理功能逻辑 ---
; ==============================================================================

SaveUserConfig:
    FormatTime, defaultName,, yyyyMMdd_HHmmss
    InputBox, inputName, 保存配置, 请输入配置名称（不含扩展名）：, , 300, 150, , , , , %defaultName%
    if ErrorLevel
        return
    inputName := Trim(inputName)
    if (inputName = "")
        return

    if !InStr(FileExist(CfgMgr_UserConfigDir), "D")
        FileCreateDir, %CfgMgr_UserConfigDir%

    ; 💡 修复点：兜底防呆设计。如果函数被意外单独调用且文件不存在，强制生成，防止复制失败
    if !FileExist(A_ScriptDir "\Settings.ini") {
        Var_Set("1", "0", "意外删除", "基础配置", A_ScriptDir "\Settings.ini")
    }
    if (SaveSize = "1") {
        Var_Set(BallSize, "50", "BallSize", "基础配置",A_ScriptDir "\Settings.ini")
    }
    if (SavePosition = "1") {
        Gosub, 获取悬浮球坐标_调整到屏幕内
        Var_Set(nowX,"","GUI_X", "基础配置",A_ScriptDir "\Settings.ini")
        Var_Set(nowY,"","GUI_Y", "基础配置",A_ScriptDir "\Settings.ini")
    }

    FileCopy, %A_ScriptDir%\Settings.ini, %CfgMgr_UserConfigDir%\%inputName%.ini, 1

    if (CfgMgr_EnableAutoBackup = "1")
        BackupCurrentConfig()

    ToolTip, 成功保存配置：%inputName%
    SetTimer, RemoveToolTip, -1500
return

LoadUserConfig:
    targetConfig := A_ThisMenuItem
    MsgBox, 276, 警告, 是否切换到配置「%targetConfig%」？`n脚本将自动重启。
    IfMsgBox, Yes
    {
        ; 核心防御：临时关闭退出时保存大小和位置，防止重启时将当前界面的旧数据复写到新配置中
        SaveSize := 0
        SavePosition := 0

        FileCopy, %CfgMgr_UserConfigDir%\%targetConfig%.ini, %A_ScriptDir%\Settings.ini, 1
        Reload
    }
return

LoadBackupConfig:
    ; 根据显示的日期菜单项，反向还原出备份文件名
    targetName := A_ThisMenuItem
    targetName := StrReplace(targetName, "-", "")
    targetName := StrReplace(targetName, ":", "")
    targetName := StrReplace(targetName, " ", "_")
    targetFile := "Settings_" targetName ".ini"

    MsgBox, 276, 警告, 是否恢复到备份文件「%A_ThisMenuItem%」？`n脚本将自动重启。
    IfMsgBox, Yes
    {
        ; 核心防御同上
        SaveSize := 0
        SavePosition := 0

        FileCopy, %CfgMgr_UserConfigDir%\backup\%targetFile%, %A_ScriptDir%\Settings.ini, 1
        Reload
    }
return

ClearAllBackups:
    MsgBox, 292, 警告, 确定要删除所有备份配置吗？
    IfMsgBox, Yes
    {
        FileDelete, %CfgMgr_UserConfigDir%\backup\Settings_*.ini
        ToolTip, 已清空所有备份！
        SetTimer, RemoveToolTip, -1500
    }
return

OpenConfigDir:
    if !InStr(FileExist(CfgMgr_UserConfigDir), "D")
        FileCreateDir, %CfgMgr_UserConfigDir%
    Run, "%CfgMgr_UserConfigDir%"
return

ToggleAutoBackup:
    CfgMgr_EnableAutoBackup := (CfgMgr_EnableAutoBackup = "1" ? "0" : "1")
    Var_Set(CfgMgr_EnableAutoBackup, "1", "EnableAutoBackup", "基础配置", A_ScriptDir "\Settings.ini")
return

BackupCurrentConfig() {
    global CfgMgr_UserConfigDir, CfgMgr_MaxBackupCount, SaveSize, SavePosition, BallSize, nowX, nowY
    bakDir := CfgMgr_UserConfigDir "\backup"

    if !InStr(FileExist(bakDir), "D")
        FileCreateDir, %bakDir%

    ; 💡 修复点：兜底防呆设计。如果函数被意外单独调用且文件不存在，强制生成，防止复制失败
    if !FileExist(A_ScriptDir "\Settings.ini") {
        Var_Set("1", "0", "意外删除", "基础配置", A_ScriptDir "\Settings.ini")
    }

    if (SaveSize = "1") {
        Var_Set(BallSize, "50", "BallSize", "基础配置",A_ScriptDir "\Settings.ini")
    }
    if (SavePosition = "1") {
        Gosub, 获取悬浮球坐标_调整到屏幕内
        Var_Set(nowX,"","GUI_X", "基础配置",A_ScriptDir "\Settings.ini")
        Var_Set(nowY,"","GUI_Y", "基础配置",A_ScriptDir "\Settings.ini")
    }

    FormatTime, timeStr,, yyyyMMdd_HHmmss
    targetFile := bakDir "\Settings_" timeStr ".ini"
    FileCopy, %A_ScriptDir%\Settings.ini, %targetFile%, 1

    ; 清理超过最大数量的旧文件
    if (CfgMgr_MaxBackupCount <= 0)
        return

    FileList := ""
    Loop, Files, %bakDir%\Settings_*.ini
        FileList .= A_LoopFileTimeModified "`t" A_LoopFileFullPath "`n"

    Sort, FileList, R ; 按时间戳倒序排列（最新的在前面）

    Loop, Parse, FileList, `n, `r
    {
        if (A_LoopField = "")
            continue
        ; 如果当前序号超出了最大保留个数，则删除该文件
        if (A_Index > CfgMgr_MaxBackupCount) {
            delPath := SubStr(A_LoopField, InStr(A_LoopField, "`t") + 1)
            FileDelete, %delPath%
        }
    }
}

ApplyEventSettings:
    GoSub, CoreSaveEventSettings ; 仅执行核心保存逻辑，不关闭界面
return

CoreSaveEventSettings:
    ; 关键：使用 NoHide 获取界面数据但不隐藏窗口
    Gui, EventSettings: Submit, NoHide

    Prefixes := ["LBtn", "MBtn", "WheelUp", "WheelDown", "DropFile", "DropText"]
    Sections := ["左键单击事件", "中键单击事件", "滚轮向上事件", "滚轮向下事件", "拖放事件_文件", "拖放事件_文本"]

    Loop, 6 {
        pref := Prefixes[A_Index]
        sect := Sections[A_Index]

        ; 读取基础修饰键
        valEnable := %pref%_EnableChecked
        RegExMatch(%pref%_TypeChoice, "^\d+", valType)
        valParam := %pref%_ParamEdit

        ; 读取 Ctrl 修饰键
        valEnableCtrl := %pref%_EnableCtrlChecked
        RegExMatch(%pref%_TypeCtrlChoice, "^\d+", valTypeCtrl)
        valParamCtrl := %pref%_ParamCtrlEdit

        ; 读取 Alt 修饰键
        valEnableAlt := %pref%_EnableAltChecked
        RegExMatch(%pref%_TypeAltChoice, "^\d+", valTypeAlt)
        valParamAlt := %pref%_ParamAltEdit

        ; 读取 Shift 修饰键
        valEnableShift := %pref%_EnableShiftChecked
        RegExMatch(%pref%_TypeShiftChoice, "^\d+", valTypeShift)
        valParamShift := %pref%_ParamShiftEdit

        ; 写入 INI 文件
        Var_Set(valEnable, "这是默认值", "启用", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valType, "这是默认值", "功能类型", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valParam, "这是默认值", "功能参数", sect, A_ScriptDir "\Settings.ini")

        Var_Set(valEnableCtrl, "这是默认值", "启用_ctrl", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valTypeCtrl, "这是默认值", "功能类型_ctrl", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valParamCtrl, "这是默认值", "功能参数_ctrl", sect, A_ScriptDir "\Settings.ini")

        Var_Set(valEnableAlt, "这是默认值", "启用_alt", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valTypeAlt, "这是默认值", "功能类型_alt", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valParamAlt, "这是默认值", "功能参数_alt", sect, A_ScriptDir "\Settings.ini")

        Var_Set(valEnableShift, "这是默认值", "启用_shift", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valTypeShift, "这是默认值", "功能类型_shift", sect, A_ScriptDir "\Settings.ini")
        Var_Set(valParamShift, "这是默认值", "功能参数_shift", sect, A_ScriptDir "\Settings.ini")

        ; 热更新内存变量
        %pref%_Enable := valEnable, %pref%_Type := valType, %pref%_Param := valParam
        %pref%_Enable_ctrl := valEnableCtrl, %pref%_Type_ctrl := valTypeCtrl, %pref%_Param_ctrl := valParamCtrl
        %pref%_Enable_alt := valEnableAlt, %pref%_Type_alt := valTypeAlt, %pref%_Param_alt := valParamAlt
        %pref%_Enable_shift := valEnableShift, %pref%_Type_shift := valTypeShift, %pref%_Param_shift := valParamShift
    }

    ToolTip, 事件设置已保存！
    SetTimer, RemoveToolTip, -1500
return

CancelEventSettings:
EventSettingsGuiEscape:
    Gui, EventSettings: Destroy
return

; --- 逻辑函数 ---
GuiDrag:
    PostMessage, 0xA1, 2,,, A
return

; 为窗口设置圆角区域
SetWindowRgn(hwnd, w, h, r) {
    ; 创建一个圆角矩形区域 (GDI API)
    hRgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w, "Int", h, "Int", r, "Int", r)
    ; 将区域应用到窗口
    DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr", hRgn, "Int", 1)
}
; --- API 绘图辅助函数 (不依赖外置简写函数) ---
DrawRoundedBackground_API(hwnd, w, h, radius, color, borderColor) {
    Ptr := A_PtrSize ? "UPtr" : "UInt"
    hDC := DllCall("GetDC", Ptr, hwnd, Ptr)
    mDC := DllCall("CreateCompatibleDC", Ptr, hDC, Ptr)
    hBM := DllCall("CreateCompatibleBitmap", Ptr, hDC, "Int", w, "Int", h, Ptr)
    oBM := DllCall("SelectObject", Ptr, mDC, Ptr, hBM, Ptr)

    ; 启动 GDI+ 图形
    G := Gdip_GraphicsFromHDC(mDC)
    DllCall("gdiplus\GdipSetSmoothingMode", Ptr, G, "Int", 4)

    ; 绘制圆角填充 (调用 Gdip 库函数，这些通常已在 lib\Gdip_All.ahk 中)
    pBrush := Gdip_BrushCreateSolid(color)
    Gdip_FillRoundedRectangle(G, pBrush, 0, 0, w, h, radius)
    Gdip_DeleteBrush(pBrush)

    ; 绘制圆角边框
    pPen := Gdip_CreatePen(borderColor, 1)
    Gdip_DrawRoundedRectangle(G, pPen, 0, 0, w-1, h-1, radius)
    Gdip_DeletePen(pPen)

    ; 将绘制好的位图贴到窗口
    DllCall("BitBlt", Ptr, hDC, "Int", 0, "Int", 0, "Int", w, "Int", h, Ptr, mDC, "Int", 0, "Int", 0, "UInt", 0x00CC0020)

    ; 释放资源 [cite: 107]
    Gdip_DeleteGraphics(G)
    DllCall("SelectObject", Ptr, mDC, Ptr, oBM)
    DllCall("DeleteObject", Ptr, hBM)
    DllCall("DeleteDC", Ptr, mDC)
    DllCall("ReleaseDC", Ptr, hwnd, Ptr, hDC)
}

; ==============================================================================
; 新增：GIF 帧渲染定时器标签
; ==============================================================================
UpdateGifFrame:
    if (!IsGif || !pBitmap)
        return

    ; 优化性能：如果球被隐藏（贴边或全屏），则暂停绘制，节约 CPU
    if (IsHidden || IsFullScreenHidden) {
        SetTimer, UpdateGifFrame, Off
        return
    }

    ; 切换到下一活动帧
    DllCall("gdiplus\GdipImageSelectActiveFrame", "Ptr", pBitmap, "Ptr", &GifDimensionID, "Int", GifCurrentFrame)

    ; 获取当前窗口位置并重绘当前帧
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)

    ; 读取当前帧延迟，并设置单次定时器触发下一帧 (使用负数表示 One-Shot 定时器)
    currentDelay := GifDelays[GifCurrentFrame + 1]
    SetTimer, UpdateGifFrame, % "-" currentDelay

    ; 循环递增索引
    GifCurrentFrame++
    if (GifCurrentFrame >= GifFrameCount)
        GifCurrentFrame := 0
return

; ==============================================================================
; 新增：时间模式动态刷新与模式切换逻辑
; ==============================================================================
UpdateTimeLoop:
    ; 如果是流量模式，先获取最新网速
    if (DisplayMode = "NetTraffic" && !IsHidden && !IsFullScreenHidden && !IsEditMode) {
        UpdateNetworkSpeed()
        WinGetPos, curX, curY,,, ahk_id %hBall%
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    }
    ; 原有的时间模式重绘
    else if (DisplayMode = "Time" && !IsHidden && !IsFullScreenHidden && !IsEditMode) {
        WinGetPos, curX, curY,,, ahk_id %hBall%
        UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    }
return

SetDisplayMode:
    ; 如果点击的就是当前的模式，直接返回，避免无意义的闪烁重绘
    if ((A_ThisMenuItem = "图标模式" && DisplayMode = "Image")
        || (A_ThisMenuItem = "时间模式" && DisplayMode = "Time")
        || (A_ThisMenuItem = "网速模式" && DisplayMode = "NetTraffic"))
        return

    ; 根据点击的子菜单项设定新模式
    if (A_ThisMenuItem = "图标模式")
        DisplayMode := "Image"
    else if (A_ThisMenuItem = "时间模式")
        DisplayMode := "Time"
    else if (A_ThisMenuItem = "网速模式")
        DisplayMode := "NetTraffic"

    Var_Set(DisplayMode, "Image", "DisplayMode", "基础配置", A_ScriptDir "\Settings.ini")

    if (DisplayMode = "Time" || DisplayMode = "NetTraffic") {
        ; 切换到文本模式：清空留边比例，停止 GIF 渲染
        ImgPadL_Ratio := 0, ImgPadR_Ratio := 0, ImgPadT_Ratio := 0, ImgPadB_Ratio := 0
        SetTimer, UpdateGifFrame, Off
    } else {
        ; 切换回图片模式：重新计算留边，若是 GIF 则唤醒动画
        UpdateBitmapPadding()
        if (IsGif)
            GoSub, UpdateGifFrame
    }

    ; 立即刷新显示，并触发吸附校准防越界
    WinGetPos, curX, curY,,, ahk_id %hBall%
    UpdateBallDisplay(hBall, pBitmap, curX, curY, BallSize, CurrentAlpha)
    GoSub, HandleSnapping
return

; ==============================================================================
; 全局基础设置面板 (可视化 GUI)
; ==============================================================================
ShowMainSettingsGUI:
    global hMainGui

    if WinExist("ahk_id " hMainGui) {
        Gui, MainSettings: show
        return
    }

    ; 创建暗色无边框窗口
    Gui, MainSettings: New, +HwndhMainGui -Caption
    Gui, MainSettings: Color, %G_BgColor%
    Gui, MainSettings: Margin, 15, 15

    W := 620, H := 460

    ; === 【修复系统缩放裁剪问题】 获取系统 DPI，按比例放大 GDI 绘图区域 ===
    DPIScale := A_ScreenDPI / 96
    RealW := Round(W * DPIScale)
    RealH := Round(H * DPIScale)
    RealRgn := Round(20 * DPIScale)
    RealBgRadius := Round(15 * DPIScale)

    SetWindowRgn(hMainGui, RealW, RealH, RealRgn)
    DrawRoundedBackground_API(hMainGui, RealW, RealH, RealBgRadius, G_BgARGB, G_BorderARGB)
    ; ====================================================================

    ; 标题
    Gui, MainSettings: Font, s12 c%G_FontColor% w700, 微软雅黑
    Gui, MainSettings: Add, Text, x20 y10 w580 h30 BackgroundTrans gGuiDrag, ⚙️ 全局基础设置

    ; 选项卡定义 (新增第7个Tab用于悬停面板设置)
    Gui, MainSettings: Font, s9 c%G_SubFontColor% w400, 微软雅黑
    Gui, MainSettings: Add, Tab3, x15 y45 w590 h360 c%G_FontColor%, 基础与外观|行为与隐藏|透明度控制|时间模式|关闭与高阶|配置管理与备份|悬停面板

    ; --------------------------------------------------
    ; Tab 1: 基础与外观
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 1

    Gui, MainSettings: Add, Checkbox, x30 y85 w150 vGUI_AdminLaunch Checked%AdminLaunch%, 以管理员权限运行
    Gui, MainSettings: Add, Checkbox, x200 y85 w150 vGUI_AutoRun Checked%AutoRun%, 开机自动启动

    Gui, MainSettings: Add, Text, x30 y125 c%G_FontColor% w100, 悬浮球默认大小:
    Gui, MainSettings: Add, Edit, x140 y120 w80 h25 vGUI_BallSize cBlack, %BallSize%
    Gui, MainSettings: Add, Text, x30 y165 c%G_FontColor% w100, 最小限制大小:
    Gui, MainSettings: Add, Edit, x140 y160 w80 h25 vGUI_minBallSize cBlack, %minBallSize%
    Gui, MainSettings: Add, Text, x250 y165 c%G_FontColor% w100, 最大限制大小:
    Gui, MainSettings: Add, Edit, x360 y160 w80 h25 vGUI_maxBallSize cBlack, %maxBallSize%

    Gui, MainSettings: Add, Text, x30 y205 c%G_FontColor% w100, 滚轮缩放增量:
    Gui, MainSettings: Add, Edit, x140 y200 w80 h25 vGUI_BallSizeIncrement cBlack, %BallSizeIncrement%
    Gui, MainSettings: Add, Checkbox, x250 y205 w150 vGUI_EnableWheelResize Checked%EnableWheelResize%, 允许滚轮调节大小

    Gui, MainSettings: Add, Text, x30 y245 c%G_FontColor% w100, 全局显示隐藏热键:
    Gui, MainSettings: Add, Edit, x140 y240 w80 h25 vGUI_ToggleHotkey cBlack, %ToggleHotkey%
    Gui, MainSettings: Add, Checkbox, x250 y245 w150 vGUI_EnableHotkey Checked%EnableHotkey%, 启用全局热键

    Gui, MainSettings: Add, Checkbox, x30 y285 w150 vGUI_ShowTrayIcon Checked%ShowTrayIcon%, 显示系统托盘图标
    Gui, MainSettings: Add, Text, x200 y285 c%G_FontColor% w60, X 坐标:
    Gui, MainSettings: Add, Edit, x260 y280 w60 h25 vGUI_X2 cBlack, %GUI_X%
    Gui, MainSettings: Add, Text, x340 y285 c%G_FontColor% w60, Y 坐标:
    Gui, MainSettings: Add, Edit, x400 y280 w60 h25 vGUI_Y2 cBlack, %GUI_Y%

    ; 【新增】主题配色切换配置项
    Gui, MainSettings: Add, Text, x30 y325 c%G_FontColor% w80, 全局主题模式:
    ThemeStr := (ThemeMode="Light" ? "Dark|Light||Custom" : (ThemeMode="Custom" ? "Dark|Light|Custom||" : "Dark||Light|Custom"))
    Gui, MainSettings: Add, DropDownList, x120 y320 w100 vGUI_ThemeModeChoice, %ThemeStr%

    ; --------------------------------------------------
    ; Tab 2: 行为与隐藏
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 2
    Gui, MainSettings: Add, Checkbox, x30 y85 w120 vGUI_IsAlwaysOnTop Checked%IsAlwaysOnTop%, 强制置顶显示
    Gui, MainSettings: Add, Checkbox, x160 y85 w135 vGUI_IsLocked Checked%IsLocked%, 固定位置禁止拖拽
    Gui, MainSettings: Add, Checkbox, x305 y85 w135 vGUI_HideInFullScreen Checked%HideInFullScreen%, 全屏时自动隐藏

    Gui, MainSettings: Add, Checkbox, x30 y125 w120 vGUI_SavePosition Checked%SavePosition%, 退出时保存位置
    Gui, MainSettings: Add, Checkbox, x160 y125 w135 vGUI_SaveSize Checked%SaveSize%, 退出时保存大小
    Gui, MainSettings: Add, Checkbox, x305 y125 w135 vGUI_EnableEdgeHide Checked%EnableEdgeHide%, 开启贴边自动隐藏

    Gui, MainSettings: Add, Text, x30 y175 c%G_FontColor% w100, 边缘吸附感应距离:
    Gui, MainSettings: Add, Edit, x150 y170 w80 h25 vGUI_SnapRange cBlack, %SnapRange%
    Gui, MainSettings: Add, Text, x30 y215 c%G_FontColor% w100, 贴边隐藏露出宽度:
    Gui, MainSettings: Add, Edit, x150 y210 w80 h25 vGUI_HideMargin cBlack, %HideMargin%
    Gui, MainSettings: Add, Text, x270 y215 c%G_FontColor% w120, 贴边后多久开始隐藏:
    Gui, MainSettings: Add, Edit, x400 y210 w80 h25 vGUI_HideDelay cBlack, %HideDelay%

    ; --------------------------------------------------
    ; Tab 3: 透明度控制
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 3
    Gui, MainSettings: Add, Checkbox, x30 y85 w150 vGUI_EnableDynamicOpacity Checked%EnableDynamicOpacity%, 开启动态透明度调整

    Gui, MainSettings: Add, Text, x30 y125 c%G_FontColor% w100, 鼠标离开基础透明:
    Gui, MainSettings: Add, Edit, x150 y120 w80 h25 vGUI_MinOpacity cBlack, %MinOpacity%
    Gui, MainSettings: Add, Text, x270 y125 c%G_FontColor% w100, 鼠标进入最高透明:
    Gui, MainSettings: Add, Edit, x380 y120 w80 h25 vGUI_MaxOpacity cBlack, %MaxOpacity%

    Gui, MainSettings: Add, Text, x30 y165 c%G_FontColor% w100, 贴边隐藏后透明度:
    Gui, MainSettings: Add, Edit, x150 y160 w80 h25 vGUI_hideOpacity cBlack, %hideOpacity%
    Gui, MainSettings: Add, Text, x270 y165 c%G_FontColor% w100, 穿透模式固定透明度:
    Gui, MainSettings: Add, Edit, x380 y160 w80 h25 vGUI_ThroughOpacity cBlack, %ThroughOpacity%

    Gui, MainSettings: Add, Text, x30 y205 c%G_FontColor% w120, 鼠标离开后渐变延迟:
    Gui, MainSettings: Add, Edit, x150 y200 w80 h25 vGUI_MouseLeaveDelay cBlack, %MouseLeaveDelay%
    Gui, MainSettings: Add, Text, x270 y205 c%G_FontColor% w100, 渐变步长(快慢):
    Gui, MainSettings: Add, Edit, x380 y200 w80 h25 vGUI_FadeStep cBlack, %FadeStep%

    ; --------------------------------------------------
    ; Tab 4: 时间模式
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 4
    Gui, MainSettings: Add, Text, x30 y85 c%G_FontColor% w70, 时间格式:
    Gui, MainSettings: Add, Edit, x100 y80 w160 h25 vGUI_TimeFormat cBlack, %TimeFormat%

    Gui, MainSettings: Add, Text, x280 y85 c%G_FontColor% w70, 字体名称:
    Gui, MainSettings: Add, Edit, x350 y80 w100 h25 vGUI_TimeFont cBlack, %TimeFont%
    Gui, MainSettings: Add, Button, x455 y79 w30 h27 gPickFont, 🔠

    Gui, MainSettings: Add, Text, x30 y125 c%G_FontColor% w70, 字体颜色:
    Gui, MainSettings: Add, Edit, x100 y120 w80 h25 vGUI_TimeColor cBlack, %TimeColor%
    Gui, MainSettings: Add, Button, x185 y119 w30 h27 gPickTimeColor, 🎨

    Gui, MainSettings: Add, Text, x240 y125 c%G_FontColor% w70, 字体大小比:
    Gui, MainSettings: Add, Edit, x310 y120 w50 h25 vGUI_TimeFontRatio cBlack, %TimeFontRatio%
    Gui, MainSettings: Add, Text, x380 y125 c%G_FontColor% w60, Y轴微调:
    Gui, MainSettings: Add, Edit, x440 y120 w50 h25 vGUI_TimeOffsetY cBlack, %TimeOffsetY%

    Gui, MainSettings: Add, Checkbox, x30 y165 w100 vGUI_TimeFontBold Checked%TimeFontBold%, 文字加粗显示
    Gui, MainSettings: Add, Checkbox, x150 y165 w120 vGUI_EnableTimeBg Checked%EnableTimeBg%, 显示背景包裹框

    Gui, MainSettings: Add, Text, x30 y205 c%G_FontColor% w70, 背景颜色:
    Gui, MainSettings: Add, Edit, x100 y200 w80 h25 vGUI_TimeBgColor cBlack, %TimeBgColor%
    Gui, MainSettings: Add, Button, x185 y199 w30 h27 gPickBgColor, 🎨

    Gui, MainSettings: Add, Text, x240 y205 c%G_FontColor% w70, 圆角比例:
    Gui, MainSettings: Add, Edit, x310 y200 w50 h25 vGUI_TimeCornerRatio cBlack, %TimeCornerRatio%

    Gui, MainSettings: Add, Text, x30 y245 c%G_FontColor% w70, X轴留白:
    Gui, MainSettings: Add, Edit, x100 y240 w50 h25 vGUI_TimePaddingX cBlack, %TimePaddingX%
    Gui, MainSettings: Add, Text, x170 y245 c%G_FontColor% w70, Y轴留白:
    Gui, MainSettings: Add, Edit, x240 y240 w50 h25 vGUI_TimePaddingY cBlack, %TimePaddingY%

    ; --------------------------------------------------
    ; Tab 5: 关闭按钮与高阶设定
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 5
    Gui, MainSettings: Add, Checkbox, x30 y85 w120 vGUI_ShowCloseButton Checked%ShowCloseButton%, 显示关闭按钮

    CloseActionStr := (CloseBtnAction="1" ? "退出程序|隐藏悬浮球||" : "退出程序||隐藏悬浮球")
    Gui, MainSettings: Add, Text, x170 y85 c%G_FontColor% w80, 按钮左键动作:
    Gui, MainSettings: Add, DropDownList, x250 y80 w120 vGUI_CloseBtnActionChoice, %CloseActionStr%

    Gui, MainSettings: Add, Text, x30 y125 c%G_FontColor% w90, 关闭按钮 X偏移:
    Gui, MainSettings: Add, Edit, x120 y120 w50 h25 vGUI_CloseBtn_X cBlack, %CloseBtn_X%
    Gui, MainSettings: Add, Text, x190 y125 c%G_FontColor% w90, 关闭按钮 Y偏移:
    Gui, MainSettings: Add, Edit, x280 y120 w50 h25 vGUI_CloseBtn_Y cBlack, %CloseBtn_Y%
    Gui, MainSettings: Add, Text, x350 y125 c%G_FontColor% w90, 按钮消失延迟:
    Gui, MainSettings: Add, Edit, x440 y120 w50 h25 vGUI_CloseBtn_HideTime cBlack, %CloseBtn_HideTime%

    Gui, MainSettings: Add, Text, x30 y165 c%G_FontColor% w90, 关闭按钮 大小:
    Gui, MainSettings: Add, Edit, x120 y160 w50 h25 vGUI_CloseBtn_Size cBlack, %CloseBtn_Size%
    Gui, MainSettings: Add, Text, x190 y165 c%G_FontColor% w90, 叉号线条粗细:
    Gui, MainSettings: Add, Edit, x280 y160 w50 h25 vGUI_CloseBtn_Thickness cBlack, %CloseBtn_Thickness%
    Gui, MainSettings: Add, Text, x350 y165 c%G_FontColor% w90, 叉号视觉边距:
    Gui, MainSettings: Add, Edit, x440 y160 w50 h25 vGUI_CloseBtn_VisualMargin cBlack, %CloseBtn_VisualMargin%

    ; --------------------------------------------------
    ; Tab 6: 配置管理与备份
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 6
    Gui, MainSettings: Add, Text, x30 y85 c00CCFF w500, --- 占位符与内容获取设定 ---

    Gui, MainSettings: Add, Text, x30 y120 c%G_FontColor% w130, 获取选中内容快捷键:
    Gui, MainSettings: Add, Edit, x165 y115 w80 h25 vGUI_SelectedCopyKey cBlack, %SelectedCopyKey%

    Gui, MainSettings: Add, Text, x270 y120 c%G_FontColor% w130, 复制获取等待秒数:
    Gui, MainSettings: Add, Edit, x390 y115 w50 h25 vGUI_SelectedWaitTime cBlack, %SelectedWaitTime%

    Gui, MainSettings: Add, Text, x30 y160 c%G_FontColor% w130, 最多保留落地文件数:
    Gui, MainSettings: Add, Edit, x165 y155 w80 h25 vGUI_MaxTempFiles cBlack, %MaxTempFiles%

    Gui, MainSettings: Add, Text, x30 y205 c00CCFF w500, --- 配置备份与管理 ---
    Gui, MainSettings: Add, Text, x30 y240 c%G_FontColor% w100, 配置文件目录:
    Gui, MainSettings: Add, Edit, x130 y235 w320 h25 vGUI_CfgMgr_UserConfigDir cBlack, %CfgMgr_UserConfigDir%
    Gui, MainSettings: Add, Button, x455 y234 w40 h27 gPickConfigDir, 📂

    Gui, MainSettings: Add, Checkbox, x30 y285 w120 vGUI_CfgMgr_EnableAutoBackup Checked%CfgMgr_EnableAutoBackup%, 开启自动备份
    Gui, MainSettings: Add, Text, x160 y285 c%G_FontColor% w120, 最大保留备份数量:
    Gui, MainSettings: Add, Edit, x280 y280 w60 h25 vGUI_CfgMgr_MaxBackupCount cBlack, %CfgMgr_MaxBackupCount%

    ; --------------------------------------------------
    ; 【新增】Tab 7: 悬停面板
    ; --------------------------------------------------
    Gui, MainSettings: Tab, 7
    Gui, MainSettings: Add, Checkbox, x30 y85 w120 vGUI_HoverPanel_Enable Checked%HoverPanel_Enable%, 启用悬停面板
    Gui, MainSettings: Add, Checkbox, x160 y85 w160 vGUI_HoverPanel_ShowTooltip Checked%HoverPanel_ShowTooltip%, 悬停时显示项目详细提示
    Gui, MainSettings: Add, Checkbox, x330 y85 w150 vGUI_HoverPanel_ShowItemIcon Checked%HoverPanel_ShowItemIcon%, 显示菜单项图标

    Gui, MainSettings: Add, Text, x30 y125 c%G_FontColor% w90, 触发显示延迟:
    Gui, MainSettings: Add, Edit, x120 y120 w60 h25 vGUI_HoverPanel_ShowDelay cBlack, %HoverPanel_ShowDelay%
    Gui, MainSettings: Add, Text, x200 y125 c%G_FontColor% w90, 离开隐藏延迟:
    Gui, MainSettings: Add, Edit, x290 y120 w60 h25 vGUI_HoverPanel_HideDelay cBlack, %HoverPanel_HideDelay%
    Gui, MainSettings: Add, Text, x370 y125 c%G_FontColor% w90, 提示显示延迟:
    Gui, MainSettings: Add, Edit, x460 y120 w60 h25 vGUI_HoverPanel_TooltipDelay cBlack, %HoverPanel_TooltipDelay%

    Gui, MainSettings: Add, Text, x30 y165 c%G_FontColor% w90, 项目行高间距:
    Gui, MainSettings: Add, Edit, x120 y160 w60 h25 vGUI_HoverPanel_ItemHeight cBlack, %HoverPanel_ItemHeight%
    Gui, MainSettings: Add, Text, x200 y165 c%G_FontColor% w90, 单个项目宽度:
    Gui, MainSettings: Add, Edit, x290 y160 w60 h25 vGUI_HoverPanel_ItemWidth cBlack, %HoverPanel_ItemWidth%
    Gui, MainSettings: Add, Text, x370 y165 c%G_FontColor% w90, 面板全局边距:
    Gui, MainSettings: Add, Edit, x460 y160 w60 h25 vGUI_HoverPanel_Margin cBlack, %HoverPanel_Margin%

    Gui, MainSettings: Add, Text, x30 y205 c%G_FontColor% w90, 图标显示尺寸:
    Gui, MainSettings: Add, Edit, x120 y200 w60 h25 vGUI_HoverPanel_IconSize cBlack, %HoverPanel_IconSize%
    Gui, MainSettings: Add, Text, x200 y205 c%G_FontColor% w90, 菜单文字大小:
    Gui, MainSettings: Add, Edit, x290 y200 w60 h25 vGUI_HoverPanel_FontSize cBlack, %HoverPanel_FontSize%
    Gui, MainSettings: Add, Text, x370 y205 c%G_FontColor% w90, 文字垂直偏移:
    Gui, MainSettings: Add, Edit, x460 y200 w60 h25 vGUI_HoverPanel_TextOffsetY cBlack, %HoverPanel_TextOffsetY%

    Gui, MainSettings: Add, Checkbox, x30 y245 w140 vGUI_HoverPanel_EnableHoverHighlight Checked%HoverPanel_EnableHoverHighlight%, 启用项目高亮背景
    Gui, MainSettings: Add, Text, x200 y245 c%G_FontColor% w90, 高亮背景圆角:
    Gui, MainSettings: Add, Edit, x290 y240 w60 h25 vGUI_HoverPanel_HoverCornerRadius cBlack, %HoverPanel_HoverCornerRadius%
    Gui, MainSettings: Add, Text, x370 y245 c%G_FontColor% w90, 菜单项字体名:
    Gui, MainSettings: Add, Edit, x460 y240 w60 h25 vGUI_HoverPanel_FontName cBlack, %HoverPanel_FontName%

    ; ▼▼▼ 新增：复选框 ▼▼▼
    Gui, MainSettings: Add, Checkbox, x30 y285 w250 vGUI_HoverPanel_HideOnLeftClickThrough Checked%HoverPanel_HideOnLeftClickThrough%, 仅左键穿透时禁用悬停面板
    ; ▼▼▼ 原有的提示文本 Y 轴往下挪到 320 ▼▼▼
    Gui, MainSettings: Add, Text, x30 y320 c00CCFF w500, 注: 悬停面板的颜色已绑定「全局主题模式」，更改主题即可同步配色。

    ; --------------------------------------------------
    ; 底部按钮区域
    ; --------------------------------------------------
    Gui, MainSettings: Tab
    Gui, MainSettings: Add, Button, x300 y415 w110 h30 Default gSaveMainSettings, 保存并重启脚本
    Gui, MainSettings: Add, Button, x420 y415 w80 h30 gApplyMainSettings, 应用
    Gui, MainSettings: Add, Button, x510 y415 w80 h30 gCancelMainSettings, 取消

    Gui, MainSettings: Show, w%W% h%H%, 悬浮球全局设置
return

; ==================================================
; 辅助功能：目录、字体、颜色 原生系统选择器
; ==================================================
PickConfigDir:
    Gui, MainSettings: +OwnDialogs
    GuiControlGet, curDir,, GUI_CfgMgr_UserConfigDir

    ; 换用 FileSelectFile，让用户选择目标目录下的任意 .ini 文件
    FileSelectFile, selectedFile, 3, %curDir%, 请选择目标文件夹下的任意一个配置 (.ini) 文件, INI 文件 (*.ini)

    if (selectedFile != "") {
        ; 利用 SplitPath 自动剥离文件名，只保留纯粹的文件夹路径
        SplitPath, selectedFile, , outDir
        GuiControl,, GUI_CfgMgr_UserConfigDir, %outDir%
    }
return

PickFont:
    Gui, MainSettings: +OwnDialogs
    VarSetCapacity(LOGFONT, 92, 0)

    ; 动态计算 CHOOSEFONT 结构体大小和偏移，完美兼容 32位 / 64位 AHK
    is64 := (A_PtrSize = 8)
    structSize := is64 ? 104 : 60
    VarSetCapacity(CHOOSEFONT, structSize, 0)

    NumPut(structSize, CHOOSEFONT, 0, "UInt")                ; lStructSize
    NumPut(hMainGui,   CHOOSEFONT, is64 ? 8 : 4, "UPtr")     ; hwndOwner
    NumPut(&LOGFONT,   CHOOSEFONT, is64 ? 24 : 12, "UPtr")   ; lpLogFont
    NumPut(0x02000141, CHOOSEFONT, is64 ? 36 : 20, "UInt")   ; Flags (CF_SCREENFONTS | CF_EFFECTS | CF_INITTOLOGFONTSTRUCT)

    if DllCall("comdlg32\ChooseFont", "UPtr", &CHOOSEFONT) {
        ; LOGFONT 结构体中，字体名称 lfFaceName 固定从第 28 字节开始
        FontName := StrGet(&LOGFONT + 28, 32)
        GuiControl,, GUI_TimeFont, %FontName%
    }
return

PickTimeColor:
    Gosub, PickColorDialog
    if (PickedColor != "") {
        GuiControlGet, oldC,, GUI_TimeColor
        ; 保留原设定的透明度(前两位Alpha)，替换RGB部分
        newC := SubStr(oldC, 1, 2) . PickedColor
        GuiControl,, GUI_TimeColor, %newC%
    }
return

PickBgColor:
    Gosub, PickColorDialog
    if (PickedColor != "") {
        GuiControlGet, oldC,, GUI_TimeBgColor
        ; 保留原设定的透明度(前两位Alpha)，替换RGB部分
        newC := SubStr(oldC, 1, 2) . PickedColor
        GuiControl,, GUI_TimeBgColor, %newC%
    }
return

PickColorDialog:
    Gui, MainSettings: +OwnDialogs
    VarSetCapacity(CHOOSECOLOR, 9 * A_PtrSize, 0)
    VarSetCapacity(CUSTOMCOLORS, 16 * 4, 0)
    NumPut(9 * A_PtrSize, CHOOSECOLOR, 0, "UInt")
    NumPut(hMainGui, CHOOSECOLOR, A_PtrSize, "UPtr")
    NumPut(0, CHOOSECOLOR, 3 * A_PtrSize, "UInt")
    NumPut(3, CHOOSECOLOR, 5 * A_PtrSize, "UInt") ; CC_RGBINIT | CC_FULLOPEN
    NumPut(&CUSTOMCOLORS, CHOOSECOLOR, 4 * A_PtrSize, "UPtr")
    PickedColor := ""
    if DllCall("comdlg32\ChooseColor", "UPtr", &CHOOSECOLOR) {
        Color := NumGet(CHOOSECOLOR, 3 * A_PtrSize, "UInt")
        ; 转换系统返回的 BGR 格式为标准的 RGB 16进制格式
        PickedColor := Format("{:06X}", (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16))
    }
return

; ==================================================
; 保存与应用逻辑
; ==================================================
ApplyMainSettings:
    GoSub, CoreSaveMainSettings
    ToolTip, 全局设置已应用！
    SetTimer, RemoveToolTip, -1500
return

SaveMainSettings:
    GoSub, CoreSaveMainSettings
    ToolTip, 全局设置已保存，正在重启脚本生效...
    Sleep, 800
    Reload
return

CoreSaveMainSettings:
    Gui, MainSettings: Submit, NoHide

    ; 1. 复选框状态转换 (获取界面上的 1/0)
    v_AdminLaunch := GUI_AdminLaunch ? "1" : "0"
    v_AutoRun := GUI_AutoRun ? "1" : "0"
    v_ShowTrayIcon := GUI_ShowTrayIcon ? "1" : "0"
    v_EnableWheelResize := GUI_EnableWheelResize ? "1" : "0"
    v_EnableHotkey := GUI_EnableHotkey ? "1" : "0"
    v_IsAlwaysOnTop := GUI_IsAlwaysOnTop ? "1" : "0"
    v_IsLocked := GUI_IsLocked ? "1" : "0"
    v_HideInFullScreen := GUI_HideInFullScreen ? "1" : "0"
    v_SavePosition := GUI_SavePosition ? "1" : "0"
    v_SaveSize := GUI_SaveSize ? "1" : "0"
    v_EnableEdgeHide := GUI_EnableEdgeHide ? "1" : "0"
    v_EnableDynamicOpacity := GUI_EnableDynamicOpacity ? "1" : "0"
    v_TimeFontBold := GUI_TimeFontBold ? "1" : "0"
    v_EnableTimeBg := GUI_EnableTimeBg ? "1" : "0"
    v_ShowCloseButton := GUI_ShowCloseButton ? "1" : "0"
    v_CfgMgr_EnableAutoBackup := GUI_CfgMgr_EnableAutoBackup ? "1" : "0"

    ; 【新增】悬停面板的复选框转义
    v_HoverPanel_Enable := GUI_HoverPanel_Enable ? "1" : "0"
    v_HoverPanel_HideOnLeftClickThrough := GUI_HoverPanel_HideOnLeftClickThrough ? "1" : "0" ; <--- 新增这行
    v_HoverPanel_ShowTooltip := GUI_HoverPanel_ShowTooltip ? "1" : "0"
    v_HoverPanel_ShowItemIcon := GUI_HoverPanel_ShowItemIcon ? "1" : "0"
    v_HoverPanel_EnableHoverHighlight := GUI_HoverPanel_EnableHoverHighlight ? "1" : "0"

    ; 2. 下拉框处理
    v_CloseBtnAction := (GUI_CloseBtnActionChoice = "退出程序") ? "0" : "1"
    v_ThemeMode := GUI_ThemeModeChoice ; 【新增】主题模式状态获取

    ; 3. 处理特殊格式
    v_TimeFormat := StrReplace(GUI_TimeFormat, "`n", "\n")

    iniPath := A_ScriptDir "\Settings.ini"
    section := "基础配置"

    ; --- 写入基础配置 (INI 文件) ---
    Var_Set(v_AdminLaunch, "0", "AdminLaunch", section, iniPath)
    Var_Set(v_AutoRun, "0", "AutoRun", section, iniPath)
    Var_Set(GUI_BallSize, "50", "BallSize", section, iniPath)
    Var_Set(GUI_minBallSize, "20", "minBallSize", section, iniPath)
    Var_Set(GUI_maxBallSize, "300", "maxBallSize", section, iniPath)
    Var_Set(GUI_BallSizeIncrement, "5", "BallSizeIncrement", section, iniPath)
    Var_Set(GUI_ToggleHotkey, "#p", "ToggleHotkey", section, iniPath)
    Var_Set(v_ShowTrayIcon, "1", "ShowTrayIcon", section, iniPath)
    Var_Set(v_EnableWheelResize, "1", "EnableWheelResize", section, iniPath)
    Var_Set(v_EnableHotkey, "1", "EnableHotkey", section, iniPath)

    Var_Set(v_IsAlwaysOnTop, "1", "IsAlwaysOnTop", section, iniPath)
    Var_Set(v_IsLocked, "0", "IsLocked", section, iniPath)
    Var_Set(v_HideInFullScreen, "1", "HideInFullScreen", section, iniPath)
    Var_Set(v_SavePosition, "1", "SavePosition", section, iniPath)
    Var_Set(v_SaveSize, "1", "SaveSize", section, iniPath)
    Var_Set(v_EnableEdgeHide, "1", "EnableEdgeHide", section, iniPath)
    Var_Set(GUI_SnapRange, "5", "SnapRange", section, iniPath)
    Var_Set(GUI_HideMargin, "10", "HideMargin", section, iniPath)
    Var_Set(GUI_HideDelay, "800", "HideDelay", section, iniPath)

    Var_Set(v_EnableDynamicOpacity, "1", "EnableDynamicOpacity", section, iniPath)
    Var_Set(GUI_MinOpacity, "120", "MinOpacity", section, iniPath)
    Var_Set(GUI_MaxOpacity, "255", "MaxOpacity", section, iniPath)
    Var_Set(GUI_hideOpacity, "150", "hideOpacity", section, iniPath)
    Var_Set(GUI_ThroughOpacity, "120", "ThroughOpacity", section, iniPath)
    Var_Set(GUI_MouseLeaveDelay, "1000", "MouseLeaveDelay", section, iniPath)
    Var_Set(GUI_FadeStep, "15", "FadeStep", section, iniPath)

    Var_Set(v_TimeFormat, "HH:mm:ss", "TimeFormat", section, iniPath)
    Var_Set(GUI_TimeFont, "微软雅黑", "TimeFont", section, iniPath)
    Var_Set(GUI_TimeColor, "FFFFFFFF", "TimeColor", section, iniPath)
    Var_Set(GUI_TimeFontRatio, "0.4", "TimeFontRatio", section, iniPath)
    Var_Set(GUI_TimeOffsetY, "0", "TimeOffsetY", section, iniPath)
    Var_Set(v_TimeFontBold, "1", "TimeFontBold", section, iniPath)
    Var_Set(v_EnableTimeBg, "1", "EnableTimeBg", section, iniPath)
    Var_Set(GUI_TimeBgColor, "66000000", "TimeBgColor", section, iniPath)
    Var_Set(GUI_TimeCornerRatio, "0.2", "TimeCornerRatio", section, iniPath)
    Var_Set(GUI_TimePaddingX, "5", "TimePaddingX", section, iniPath)
    Var_Set(GUI_TimePaddingY, "5", "TimePaddingY", section, iniPath)

    Var_Set(v_ShowCloseButton, "0", "ShowCloseButton", section, iniPath)
    Var_Set(v_CloseBtnAction, "0", "CloseBtnAction", section, iniPath)
    Var_Set(GUI_CloseBtn_X, "18", "CloseBtn_X", section, iniPath)
    Var_Set(GUI_CloseBtn_Y, "14", "CloseBtn_Y", section, iniPath)
    Var_Set(GUI_CloseBtn_HideTime, "400", "CloseBtn_HideTime", section, iniPath)
    Var_Set(GUI_CloseBtn_Size, "20", "CloseBtn_Size", section, iniPath)
    Var_Set(GUI_CloseBtn_Thickness, "3", "CloseBtn_Thickness", section, iniPath)
    Var_Set(GUI_CloseBtn_VisualMargin, "5", "CloseBtn_VisualMargin", section, iniPath)

    Var_Set(GUI_SelectedCopyKey, "^c", "SelectedCopyKey", section, iniPath)
    Var_Set(GUI_SelectedWaitTime, "0.15", "SelectedWaitTime", section, iniPath)
    Var_Set(GUI_MaxTempFiles, "10", "MaxTempFiles", section, iniPath)

    Var_Set(GUI_CfgMgr_UserConfigDir, A_ScriptDir "\UserConfig", "UserConfigDir", "基础配置", iniPath)
    Var_Set(v_CfgMgr_EnableAutoBackup, "1", "EnableAutoBackup", "基础配置", iniPath)
    Var_Set(GUI_CfgMgr_MaxBackupCount, "10", "MaxBackupCount", "基础配置", iniPath)

    ; 【新增】主题设置写入
    Var_Set(v_ThemeMode, "Dark", "ThemeMode", "主题配置", iniPath)

    ; 【新增】悬停面板设置写入
    Var_Set(v_HoverPanel_Enable, "1", "Enable", "悬停面板", iniPath)
    Var_Set(v_HoverPanel_HideOnLeftClickThrough, "1", "HideOnLeftClickThrough", "悬停面板", iniPath) ; <--- 新增这行
    Var_Set(GUI_HoverPanel_ShowDelay, "350", "ShowDelay", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_HideDelay, "200", "HideDelay", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_ItemHeight, "23", "ItemHeight", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_ItemWidth, "155", "ItemWidth", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_Margin, "8", "Margin", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_IconSize, "20", "IconSize", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_FontSize, "10", "FontSize", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_TextOffsetY, "-6", "TextOffsetY", "悬停面板", iniPath)
    Var_Set(v_HoverPanel_EnableHoverHighlight, "1", "EnableHoverHighlight", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_HoverCornerRadius, "5", "HoverCornerRadius", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_FontName, "微软雅黑", "FontName", "悬停面板", iniPath)
    Var_Set(v_HoverPanel_ShowTooltip, "1", "ShowTooltip", "悬停面板", iniPath)
    Var_Set(v_HoverPanel_ShowItemIcon, "1", "ShowItemIcon", "悬停面板", iniPath)
    Var_Set(GUI_HoverPanel_TooltipDelay, "600", "TooltipDelay", "悬停面板", iniPath)

    ; ==============================================================================
    ; 【核心新增】：将所有修改同步到内存全局变量，并即时重绘，使配置立即生效
    ; ==============================================================================
    global ToggleHotkey, EnableHotkey, ShowTrayIcon, BallSize, minBallSize, maxBallSize, BallSizeIncrement, EnableWheelResize
    global AdminLaunch, AutoRun
    global IsAlwaysOnTop, IsLocked, HideInFullScreen, SavePosition, SaveSize, EnableEdgeHide, SnapRange, HideMargin, HideDelay
    global EnableDynamicOpacity, MinOpacity, MaxOpacity, hideOpacity, ThroughOpacity, MouseLeaveDelay, FadeStep, CurrentAlpha
    global TimeFormat, TimeFont, TimeColor, TimeFontRatio, TimeOffsetY, TimeFontBold, EnableTimeBg, TimeBgColor, TimeCornerRatio, TimePaddingX, TimePaddingY
    global ShowCloseButton, CloseBtnAction, CloseBtn_X, CloseBtn_Y, CloseBtn_HideTime, CloseBtn_Size, CloseBtn_Thickness, CloseBtn_VisualMargin
    global SelectedCopyKey, SelectedWaitTime, MaxTempFiles, CfgMgr_UserConfigDir, CfgMgr_EnableAutoBackup, CfgMgr_MaxBackupCount

    ; 【新增全局声明】：主题配置与悬停面板
    global ThemeMode
    global HoverPanel_Enable, HoverPanel_HideOnLeftClickThrough, HoverPanel_ShowDelay, HoverPanel_HideDelay, HoverPanel_ItemHeight, HoverPanel_ItemWidth, HoverPanel_Margin
    global HoverPanel_IconSize, HoverPanel_FontSize, HoverPanel_TextOffsetY, HoverPanel_EnableHoverHighlight, HoverPanel_HoverCornerRadius
    global HoverPanel_FontName, HoverPanel_ShowTooltip, HoverPanel_TooltipDelay, HoverPanel_ShowItemIcon

    ; 1. 动态刷新快捷键状态
    if (ToggleHotkey != GUI_ToggleHotkey && ToggleHotkey != "")
        Hotkey, %ToggleHotkey%, Off, UseErrorLevel
    ToggleHotkey := GUI_ToggleHotkey
    EnableHotkey := v_EnableHotkey
    if (ToggleHotkey != "") {
        if (EnableHotkey = "1")
            Hotkey, %ToggleHotkey%, ToggleBallVisibility, On UseErrorLevel
        else
            Hotkey, %ToggleHotkey%, Off, UseErrorLevel
    }

    ; 2. 托盘图标状态
    ShowTrayIcon := v_ShowTrayIcon
    if (ShowTrayIcon = "1")
        Menu, Tray, Icon
    else
        Menu, Tray, NoIcon

    ; 3. 同步全部内存变量
    AdminLaunch := v_AdminLaunch
    AutoRun := v_AutoRun
    Label_AutoRun(AutoRun)                  ; 【新增：立即触发开机自启逻辑】
    BallSize := GUI_BallSize, minBallSize := GUI_minBallSize, maxBallSize := GUI_maxBallSize
    BallSizeIncrement := GUI_BallSizeIncrement, EnableWheelResize := v_EnableWheelResize
    IsAlwaysOnTop := v_IsAlwaysOnTop, IsLocked := v_IsLocked, HideInFullScreen := v_HideInFullScreen
    SavePosition := v_SavePosition, SaveSize := v_SaveSize, EnableEdgeHide := v_EnableEdgeHide
    SnapRange := GUI_SnapRange, HideMargin := GUI_HideMargin, HideDelay := GUI_HideDelay
    EnableDynamicOpacity := v_EnableDynamicOpacity, MinOpacity := GUI_MinOpacity, MaxOpacity := GUI_MaxOpacity
    hideOpacity := GUI_hideOpacity, ThroughOpacity := GUI_ThroughOpacity, MouseLeaveDelay := GUI_MouseLeaveDelay, FadeStep := GUI_FadeStep
    TimeFormat := StrReplace(v_TimeFormat, "\n", "`n")
    TimeFont := GUI_TimeFont, TimeColor := GUI_TimeColor, TimeFontRatio := GUI_TimeFontRatio, TimeOffsetY := GUI_TimeOffsetY
    TimeFontBold := v_TimeFontBold, EnableTimeBg := v_EnableTimeBg, TimeBgColor := GUI_TimeBgColor
    TimeCornerRatio := GUI_TimeCornerRatio, TimePaddingX := GUI_TimePaddingX, TimePaddingY := GUI_TimePaddingY
    ShowCloseButton := v_ShowCloseButton, CloseBtnAction := v_CloseBtnAction
    CloseBtn_X := GUI_CloseBtn_X, CloseBtn_Y := GUI_CloseBtn_Y, CloseBtn_HideTime := GUI_CloseBtn_HideTime
    CloseBtn_Size := GUI_CloseBtn_Size, CloseBtn_Thickness := GUI_CloseBtn_Thickness, CloseBtn_VisualMargin := GUI_CloseBtn_VisualMargin
    SelectedCopyKey := GUI_SelectedCopyKey, SelectedWaitTime := GUI_SelectedWaitTime, MaxTempFiles := GUI_MaxTempFiles
    CfgMgr_UserConfigDir := GUI_CfgMgr_UserConfigDir, CfgMgr_EnableAutoBackup := v_CfgMgr_EnableAutoBackup, CfgMgr_MaxBackupCount := GUI_CfgMgr_MaxBackupCount

    ; 【新增：同步主题设置并立即重新加载色彩】
    ThemeMode := v_ThemeMode
    GoSub, LoadThemeConfig

    ; 【新增：同步悬停面板设置】
    HoverPanel_Enable := v_HoverPanel_Enable
    HoverPanel_HideOnLeftClickThrough := v_HoverPanel_HideOnLeftClickThrough ; <--- 新增这行
    HoverPanel_ShowDelay := GUI_HoverPanel_ShowDelay, HoverPanel_HideDelay := GUI_HoverPanel_HideDelay
    HoverPanel_ItemHeight := GUI_HoverPanel_ItemHeight, HoverPanel_ItemWidth := GUI_HoverPanel_ItemWidth
    HoverPanel_Margin := GUI_HoverPanel_Margin, HoverPanel_IconSize := GUI_HoverPanel_IconSize
    HoverPanel_FontSize := GUI_HoverPanel_FontSize, HoverPanel_TextOffsetY := GUI_HoverPanel_TextOffsetY
    HoverPanel_EnableHoverHighlight := v_HoverPanel_EnableHoverHighlight, HoverPanel_HoverCornerRadius := GUI_HoverPanel_HoverCornerRadius
    HoverPanel_FontName := GUI_HoverPanel_FontName, HoverPanel_ShowTooltip := v_HoverPanel_ShowTooltip
    HoverPanel_ShowItemIcon := v_HoverPanel_ShowItemIcon
    HoverPanel_TooltipDelay := GUI_HoverPanel_TooltipDelay

    ; 4. 立即生效窗口置顶属性
    WinSet, AlwaysOnTop, % (IsAlwaysOnTop = "1" ? "On" : "Off"), ahk_id %hBall%

    ; 5. 重绘悬浮球与关闭按钮视觉
    WinGetPos, curX, curY,,, ahk_id %hBall%
    targetX := (GUI_X != "") ? GUI_X : curX
    targetY := (GUI_Y != "") ? GUI_Y : curY

    CurrentAlpha := MaxOpacity ; 应用后强制高亮显示，方便查看效果
    UpdateBallDisplay(hBall, pBitmap, targetX, targetY, BallSize, CurrentAlpha)
    UpdateCloseBtnDisplay(hCloseBtn, CloseBtn_Size, CloseBtn_Thickness, CloseBtn_VisualMargin, false, CurrentAlpha)

    If (SavePosition = "0") {
        Var_Set(GUI_X2, "", "GUI_X", section, iniPath)
        Var_Set(GUI_Y2, "", "GUI_Y", section, iniPath)
    }

    ; 6. 重新执行吸附边缘判定防越界
    GoSub, HandleSnapping

    ; 【新增】如果悬停面板处于展示状态，则进行原地重绘使设置立即生效
    if (HoverPanelVisible)
        RenderHoverPanel(CurrentHoverGroup, true)
return

CancelMainSettings:
MainSettingsGuiEscape:
MainSettingsGuiClose:
    Gui, MainSettings: Destroy
return

; ==============================================================================
; 新增：开机自启逻辑处理
; ==============================================================================
Label_AutoRun(Auto_Launch:="0"){
    ; 使用 A_ScriptFullPath 兼容编译(.exe)与未编译(.ahk)环境
    RegRead, Auto_Launch_reg, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Floatyball
    Auto_Launch_reg := (Auto_Launch_reg = A_ScriptFullPath) ? 1 : 0

    If(Auto_Launch != Auto_Launch_reg){
        If(Auto_Launch){
            RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Floatyball, %A_ScriptFullPath%
        }Else{
            RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Floatyball
        }
    }
}

; ==============================================================================
; 悬浮球【关于】面板
; ==============================================================================
ShowAboutGUI:
    global hAboutGui, 当前工具版本

    ; 如果窗口已存在，直接唤醒显示
    if WinExist("ahk_id " hAboutGui) {
        Gui, AboutGui: Show
        return
    }

    ; 创建可调节大小的窗口 (+Resize)
    Gui, AboutGui: New, +HwndhAboutGui +Resize +MaximizeBox
    Gui, AboutGui: Color, %G_BgColor%
    Gui, AboutGui: Margin, 20, 20

    ; 标题
    Gui, AboutGui: Font, s14 c%G_FontColor% w700, 微软雅黑
    Gui, AboutGui: Add, Text, w360 Center vAboutTitle, Floatyball 悬浮球

    ; 简介文本
    Gui, AboutGui: Font, s10 c%G_SubFontColor% w400
    Gui, AboutGui: Add, Text, y+15 w360 vAboutDesc, 📝 简介：一款高度可自定义的多功能悬浮工具，支持动作快捷触发、文件多重拖放与动态时间显示。

    ; 作者与版本信息
    Gui, AboutGui: Font, s10 c%G_FontColor% w400
    Gui, AboutGui: Add, Text, y+20 w360 vAboutAuthor, 👤 作者：逍遥
    Gui, AboutGui: Add, Text, y+10 w360 vAboutVersion, 🏷️ 版本：%当前工具版本%

    ; Github 链接 (使用只读 Edit 控件方便复制)
    Gui, AboutGui: Add, Text, y+20 w360 vAboutGithubLabel, 🌐 GitHub 项目地址 (请直接框选复制):
    Gui, AboutGui: Font, s10 cBlack w400
    Gui, AboutGui: Add, Edit, y+5 w360 h25 ReadOnly vAboutGithubLink, https://github.com/lch319/Floatyball

    ; 初始居中显示并自动计算宽高
    Gui, AboutGui: Show, AutoSize Center, 关于 Floatyball
return

; ==============================================================================
; 监听【关于】窗口大小改变事件，实现内部文本/输入框自适应拉伸
; ==============================================================================
AboutGuiGuiSize:
    if (A_EventInfo = 1) ; 窗口最小化时不处理
        return

    ; 动态计算内部控件宽度 (总宽减去左右边距 20*2 = 40)
    NewAboutW := A_GuiWidth - 40

    ; 给个最小宽度保护，防止把窗口缩得太小导致排版崩溃
    if (NewAboutW < 200)
        NewAboutW := 200

    ; 移动并拉伸控件
    GuiControl, Move, AboutTitle, w%NewAboutW%
    GuiControl, Move, AboutDesc, w%NewAboutW%
    GuiControl, Move, AboutAuthor, w%NewAboutW%
    GuiControl, Move, AboutVersion, w%NewAboutW%
    GuiControl, Move, AboutGithubLabel, w%NewAboutW%
    GuiControl, Move, AboutGithubLink, w%NewAboutW%
return

; ==============================================================================
; 监听关闭事件销毁窗口，避免占用内存
; ==============================================================================
AboutGuiGuiClose:
AboutGuiGuiEscape:
    Gui, AboutGui: Destroy
return

; ==============================================================================
; 新增：悬停面板核心功能与 GUI 渲染
; ==============================================================================

LoadHoverItems() {
    global HoverGroups, HoverItemsData, CurrentHoverGroup
    global pDropTarget
    HoverGroups := []
    HoverItemsData := []
    cfgPath := A_ScriptDir "\HoverItems.txt"

    if !FileExist(cfgPath) {
        defaultTxt =
        (LTrim
        ; ============================================================
        ; 悬停面板配置说明 (一行一个动作)
        ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
        ; ============================================================
        )
        FileAppend, %defaultTxt%, %cfgPath%, UTF-8
    }

    FileRead, txt, *t %cfgPath%
    Loop, Parse, txt, `n, `r
    {
        if (Trim(A_LoopField) = "" || SubStr(Trim(A_LoopField), 1, 1) = ";")
            continue

        parts := StrSplit(A_LoopField, "|")
        if (parts.MaxIndex() >= 5) {
            ; 【修改】：在此处执行反转义还原真实内容
            icon := UnescapeHoverData(Trim(parts[1]))
            text := UnescapeHoverData(Trim(parts[2]))
            group := UnescapeHoverData(Trim(parts[3]))
            type := Trim(parts[4])
            param := UnescapeHoverData(Trim(parts[5]))
            remark := UnescapeHoverData(Trim(parts[6]))

            if (group = "")
                group := "默认"

            groupExists := false
            for k, v in HoverGroups {
                if (v = group)
                    groupExists := true
            }
            if (!groupExists)
                HoverGroups.Push(group)

            HoverItemsData.Push({Icon: icon, Text: text, Group: group, Type: type, Param: param, Remark: remark, LineStr: A_LoopField})
        }
    }
    if (HoverGroups.MaxIndex() > 0 && CurrentHoverGroup = "")
        CurrentHoverGroup := HoverGroups[1]
}

ShowHoverPanelGUI:
    RenderHoverPanel(CurrentHoverGroup)
return

RenderHoverPanel(TargetGroup := "", ForceRebuild := false) {
    global
    if (TargetGroup != "")
        CurrentHoverGroup := TargetGroup

    ; 核心：判断悬停面板是否已经存在
    GuiExists := WinExist("ahk_id " hHoverPanel)

    ; ▼▼▼ 新增修复：如果要求强制重建（如拖拽排序分组后），先记录坐标并销毁旧面板 ▼▼▼
    if (ForceRebuild && GuiExists) {
        WinGetPos, savedPX, savedPY,,, ahk_id %hHoverPanel%
        DllCall("ole32\RevokeDragDrop", "Ptr", hHoverPanel) ; <--- 【新增注销】
        Gui, HoverPanel: Destroy
        GuiExists := false
        HoverPanelVisible := false
    } else {
        savedPX := "", savedPY := ""
    }
    ; ▲▲▲ ==================================================================== ▲▲▲

    if (!GuiExists) {
        ; ==============================================================
        ; 【阶段一：初次创建】如果不存在，则全新构建整个 UI 框架
        ; ==============================================================
        Gui, HoverPanel: Destroy
        Gui, HoverPanel: Default
        Gui, HoverPanel: +HwndhHoverPanel -Caption +AlwaysOnTop +ToolWindow +E0x08000000

        DllCall("ole32\RegisterDragDrop", "Ptr", hHoverPanel, "Ptr", pDropTarget) ; <--- 【新增注册：复用悬浮球的底层拖拽器】

        Gui, HoverPanel: Color, %HoverPanel_BgColor%
        Gui, HoverPanel: Margin, %HoverPanel_Margin%, %HoverPanel_Margin%

        ; --- 1. 一次性创建所有顶部栏按钮 (通过隐藏/显示来切换，避免销毁) ---
        Gui, HoverPanel: Font, s10 cFF5555 w700, 微软雅黑
        Gui, HoverPanel: Add, Text, % "x" HoverPanel_Margin " y4 w150 BackgroundTrans vHP_Edit_Tip", ⚠️点击多选

        DragWidth := HoverPanel_Width - 120
        Gui, HoverPanel: Add, Text, x0 y0 w%DragWidth% h22 gHoverPanelDrag BackgroundTrans vHP_DragBar1,
        DragWidthNorm := HoverPanel_Width - 60
        Gui, HoverPanel: Add, Text, x0 y0 w%DragWidthNorm% h22 gHoverPanelDrag BackgroundTrans vHP_DragBar2,

        ConfirmX := HoverPanel_Width - 90
        Gui, HoverPanel: Font, s10 cFF5555 w700
        Gui, HoverPanel: Add, Text, x%ConfirmX% y4 w45 Right BackgroundTrans gConfirmHoverBatchDelete vHP_Edit_Del, ✅删除

        CancelX := HoverPanel_Width - 45
        Gui, HoverPanel: Font, s10 c888888 w700
        Gui, HoverPanel: Add, Text, x%CancelX% y4 w35 Right BackgroundTrans gExitHoverBatchDeleteMode vHP_Edit_Cancel, 取消

        CloseX := HoverPanel_Width - 32
        Gui, HoverPanel: Font, s10 c%HoverPanel_FontColor% w700
        Gui, HoverPanel: Add, Text, x%CloseX% y4 w20 Right BackgroundTrans gCloseHoverPanel vHP_Norm_Close, ❌

        PinX := HoverPanel_Width - 55
        Gui, HoverPanel: Add, Text, x%PinX% y4 w20 Right gToggleHoverPanelPin vHP_PinBtn BackgroundTrans, 📌
        ; --- 【新增】：右下角拖拽缩放手柄 ---
        ; 将字体放大到 s22，颜色改为动态跟随面板文字颜色，控件大小放大到 24x24
        Gui, HoverPanel: Font, s22 c%HoverPanel_FontColor%, 微软雅黑
        Gui, HoverPanel: Add, Text, x0 y0 w24 h24 BackgroundTrans Center gHoverPanelResize vHP_ResizeGrip, ◢

        ; 全局计数器：记录已创建的控件数量，以便对象池复用
        MaxCreatedGroups := 0
        MaxCreatedItems := 0

        ; 占位符横线和空提示
        Gui, HoverPanel: Font, s10 c888888, 微软雅黑
        Gui, HoverPanel: Add, Text, x12 y0 w10 h1 0x10 vHP_Line
        Gui, HoverPanel: Add, Text, x12 y0 w10 Center vHPEmptyText, (拖拽文件、网址、文本到此面板上快速添加)

        ; 悬停高亮底色块
        if (HoverPanel_EnableHoverHighlight = "1") {
            Gui, HoverPanel: Add, Progress, % "x0 y0 w" HoverPanel_ItemWidth " h" HoverPanel_ItemHeight " Background" HoverPanel_HoverBgColor " Disabled vHPHighlight HwndhHPHighlight Hidden"
            if (HoverPanel_HoverCornerRadius > 0) {
                DPIScale := A_ScreenDPI / 96
                SetWindowRgn(hHPHighlight, Round(HoverPanel_ItemWidth * DPIScale), Round(HoverPanel_ItemHeight * DPIScale), Round(HoverPanel_HoverCornerRadius * DPIScale))
            }
        }
    } else {
        Gui, HoverPanel: Default ; 如果已存在，将焦点切换过去，准备进行原地更新
    }

    ; ==============================================================
    ; 【阶段二：UI 无缝刷新】通过修改现有控件属性，瞬间切换状态
    ; ==============================================================

    ; --- 同步更新右下角缩放手柄的颜色 ---
    Gui, Font, c%HoverPanel_FontColor%, 微软雅黑
    GuiControl, Font, HP_ResizeGrip

    ; --- 1. 更新顶部栏的模式状态 ---
    if (isHoverPanelEditMode) {
        GuiControl, Show, HP_Edit_Tip
        GuiControl, Show, HP_Edit_Del
        GuiControl, Show, HP_Edit_Cancel
        GuiControl, Show, HP_DragBar1
        GuiControl, Hide, HP_Norm_Close
        GuiControl, Hide, HP_PinBtn
        GuiControl, Hide, HP_DragBar2
    } else {
        GuiControl, Hide, HP_Edit_Tip
        GuiControl, Hide, HP_Edit_Del
        GuiControl, Hide, HP_Edit_Cancel
        GuiControl, Hide, HP_DragBar1
        GuiControl, Show, HP_Norm_Close
        GuiControl, Show, HP_PinBtn
        GuiControl, Show, HP_DragBar2

        pinColor := isHoverPanelPinned ? "c00FF66" : "c" HoverPanel_FontColor
        Gui, Font, s10 w700 %pinColor%, 微软雅黑
        GuiControl, Font, HP_PinBtn
    }

    ; 每次重新排版前，隐藏高亮块
    if (HoverPanel_EnableHoverHighlight = "1")
        GuiControl, Hide, HPHighlight

    ; --- 2. 渲染和复用分组标签栏 ---
    btnX := HoverPanel_Margin
    btnY := 26  ; <--- 【修改1】从 35 改为 26，让分组栏向上靠
    for idx, grp in HoverGroups {
        isCur := (grp = CurrentHoverGroup)
        cColor := isCur ? "c00CCFF" : "c" HoverPanel_FontColor

        if (idx > MaxCreatedGroups) {
            Gui, Font, s10 w700 %cColor%, 微软雅黑
            Gui, Add, Text, x%btnX% y%btnY% gHoverPanelSwitchGroup vHPGrp_%idx% BackgroundTrans, %grp%
            MaxCreatedGroups := idx
        } else {
            Gui, Font, s10 w700 %cColor%, 微软雅黑
            GuiControl, Font, HPGrp_%idx%
            GuiControl,, HPGrp_%idx%, %grp%
            GuiControl, Move, HPGrp_%idx%, x%btnX% y%btnY%
            GuiControl, Show, HPGrp_%idx%
        }

        GuiControlGet, pos, Pos, HPGrp_%idx%
        ; ▼▼▼ 【修改2】删除了原来的 if ((posX + posW) > SafeRightBoundary) 换行判定，直接向右累加 ▼▼▼
        btnX += posW + HoverPanel_Margin
    }
    ; 删除分组时，把多余的控件藏起来而不销毁，等待下次复用
    Loop, % MaxCreatedGroups - HoverGroups.MaxIndex() {
        hideIdx := HoverGroups.MaxIndex() + A_Index
        GuiControl, Hide, HPGrp_%hideIdx%
    }

    LineY := btnY + 20  ; <--- 【修改3】从 btnY + 26 改为 20，横线离分组栏更近
    StartY := LineY + 6 ; <--- 【修改4】从 LineY + 12 改为 6，下方菜单项离横线更近
    HP_StartY := StartY

    ; 修改前: LineW := HoverPanel_Width - 24
    LineW := HoverPanel_Width - (HoverPanel_Margin * 2)
    ; 修改前: GuiControl, Move, HP_Line, x12 y%LineY% w%LineW% h1
    GuiControl, Move, HP_Line, % "x" HoverPanel_Margin " y" LineY " w" LineW " h1"
    ; 修改前: GuiControl, Move, HPEmptyText, x12 y%StartY% w%LineW%
    GuiControl, Move, HPEmptyText, % "x" HoverPanel_Margin " y" StartY " w" LineW

    ; --- 3. 渲染和复用动作项目 ---
    ItemCount := 0
    ; 修改前: AvailableWidth := HoverPanel_Width - 24
    AvailableWidth := HoverPanel_Width - (HoverPanel_Margin * 2)
    Cols := Floor(AvailableWidth / HoverPanel_ItemWidth)
    if (Cols < 1)
        Cols := 1

    for idx, item in HoverItemsData {
        isCurGroup := (item.Group = CurrentHoverGroup)

        if (isCurGroup) {
            CurRow := Floor(ItemCount / Cols)
            CurCol := Mod(ItemCount, Cols)
            ; 修改前: curX := 12 + (CurCol * HoverPanel_ItemWidth)
            curX := HoverPanel_Margin + (CurCol * HoverPanel_ItemWidth)
            curY := StartY + (CurRow * HoverPanel_ItemHeight)
            item.RenderX := curX
            item.RenderY := curY
            ItemCount++
        } else {
            curX := -1000
            curY := -1000
        }

        realIconPath := item.Icon
        while RegExMatch(realIconPath, "i)%([^%]+)%", match) {
            EnvGet, envVal, %match1%
            realIconPath := StrReplace(realIconPath, match, envVal)
        }

        ; --- 1. 解析 DLL/EXE 系统资源图标 (例如 shell32.dll,15) ---
        isDllIcon := false, dllOpt := "", dllFile := "", dllIconNum := "1"
        if RegExMatch(realIconPath, "i)^([^,:]+\.(dll|exe|icl))[,:]\s*(\d+)$", match) {
            dllFile := match1
            dllIconNum := match3
            if (FileExist(dllFile) || FileExist(A_WinDir "\System32\" dllFile)) {
                isDllIcon := true
                dllOpt := "*Icon" dllIconNum " "
            }
        }

        ; --- 2. 核心新增：调用 Windows API 解析任意文件/文件夹的系统原生图标 ---
        sysIconHandle := 0
        if (!isDllIcon && FileExist(realIconPath)) {
            SplitPath, realIconPath,,, ext
            ; 若为常规图片，直接走底层图片加载；否则调用 Windows API 提取资源管理器图标
            if !(ext ~= "i)^(png|jpg|jpeg|gif|bmp|ico)$") {
                VarSetCapacity(sfi, A_PtrSize = 8 ? 696 : 692, 0)
                ; 0x100 = SHGFI_ICON (获取大图标)
                if DllCall("Shell32\SHGetFileInfo" . (A_IsUnicode ? "W" : "A")
                    , "Str", realIconPath, "UInt", 0
                    , "Ptr", &sfi, "UInt", A_PtrSize = 8 ? 696 : 692
                    , "UInt", 0x100) {
                    sysIconHandle := NumGet(sfi, 0, "Ptr")
                }
            }
        }

        ; 判断当前项目最终是否是以 图片/系统图标 的方式渲染
        renderAsPic := (isDllIcon || sysIconHandle || (!isDllIcon && !sysIconHandle && FileExist(realIconPath)))

        if (isHoverPanelEditMode && HoverPanelSelectedItems[idx])
            fontColor := "cFF5555"
        else
            fontColor := "c" HoverPanel_FontColor

        textW := HoverPanel_ItemWidth - HoverPanel_IconSize - 8
        textX := curX + HoverPanel_IconSize + 8
        textY := curY + (HoverPanel_IconSize/2) - (HoverPanel_FontSize/2) + HoverPanel_TextOffsetY

        if (idx > MaxCreatedItems) {
            ; 没有可用缓存时，新建项目控件
            if (renderAsPic) {
                if (sysIconHandle) {
                    ; 💡 重点：HICON:* (带星号) 会让 AHK 自动接管系统句柄并在替换/销毁时自动释放内存，绝不漏存
                    targetPath := "HICON:*" . sysIconHandle
                    addOpt := ""
                } else if (isDllIcon) {
                    targetPath := dllFile
                    addOpt := "Icon" dllIconNum
                } else {
                    targetPath := realIconPath
                    addOpt := ""
                }
                Gui, Add, Picture, x%curX% y%curY% w%HoverPanel_IconSize% h%HoverPanel_IconSize% AltSubmit %addOpt% gOnHoverItemClick vHPPic_%idx%, % targetPath
                Gui, Add, Text, x-1000 y-1000 w%HoverPanel_IconSize% h%HoverPanel_IconSize% Center gOnHoverItemClick vHPIco_%idx% BackgroundTrans,
            } else {
                ; 纯文本 Emoji 图标兜底
                Gui, Font, s%HoverPanel_FontSize% c%HoverPanel_FontColor% w400, %HoverPanel_FontName%
                Gui, Add, Text, x%curX% y%curY% w%HoverPanel_IconSize% h%HoverPanel_IconSize% Center gOnHoverItemClick vHPIco_%idx% BackgroundTrans, % item.Icon
                Gui, Add, Picture, x-1000 y-1000 w%HoverPanel_IconSize% h%HoverPanel_IconSize% AltSubmit gOnHoverItemClick vHPPic_%idx%,
            }
            Gui, Font, s%HoverPanel_FontSize% %fontColor% w400, %HoverPanel_FontName%
            Gui, Add, Text, x%textX% y%textY% w%textW% h%HoverPanel_IconSize% -Wrap +0x4000 gOnHoverItemClick vHPItem_%idx% BackgroundTrans, % item.Text
            MaxCreatedItems := idx
        } else {
            ; 核心防闪烁：直接原地复用控件，替换图标、改写文字、更换位置
            if (renderAsPic) {
                if (sysIconHandle) {
                    targetPath := "HICON:*" . sysIconHandle
                } else if (isDllIcon) {
                    targetPath := dllOpt . dllFile
                } else {
                    targetPath := realIconPath
                }
                GuiControl,, HPPic_%idx%, % targetPath
                GuiControl, Move, HPPic_%idx%, x%curX% y%curY%
                GuiControl, Move, HPIco_%idx%, x-1000 y-1000
            } else {
                Gui, Font, s%HoverPanel_FontSize% c%HoverPanel_FontColor% w400, %HoverPanel_FontName%
                GuiControl, Font, HPIco_%idx%
                GuiControl,, HPIco_%idx%, % item.Icon
                GuiControl, Move, HPIco_%idx%, x%curX% y%curY%
                GuiControl, Move, HPPic_%idx%, x-1000 y-1000
            }
            Gui, Font, s%HoverPanel_FontSize% %fontColor% w400, %HoverPanel_FontName%
            GuiControl, Font, HPItem_%idx%
            GuiControl,, HPItem_%idx%, % item.Text
            GuiControl, Move, HPItem_%idx%, x%textX% y%textY%
        }

        ; 将属于当前组的项目展示，非当前组的隐藏
        if (isCurGroup) {
            if (renderAsPic)
                GuiControl, Show, HPPic_%idx%
            else
                GuiControl, Show, HPIco_%idx%
            GuiControl, Show, HPItem_%idx%
        } else {
            GuiControl, Hide, HPPic_%idx%
            GuiControl, Hide, HPIco_%idx%
            GuiControl, Hide, HPItem_%idx%
        }
    }
    ; 同样，删减项目后把多余的老控件缓存雪藏起来
    Loop, % MaxCreatedItems - HoverItemsData.MaxIndex() {
        hideIdx := HoverItemsData.MaxIndex() + A_Index
        GuiControl, Hide, HPPic_%hideIdx%
        GuiControl, Hide, HPIco_%hideIdx%
        GuiControl, Hide, HPItem_%hideIdx%
    }

    ; --- 4. 智能高度计算 ---
    if (ItemCount = 0) {
        GuiControl, Show, HPEmptyText
        GridHeight := 40
    } else {
        GuiControl, Hide, HPEmptyText
        TotalRows := Floor((ItemCount - 1) / Cols) + 1
        GridHeight := TotalRows * HoverPanel_ItemHeight
    }

    ; 计算当前内容所需的绝对最小高度 (底部再留白 15 像素防遮挡)
    MinRequiredHeight := StartY + GridHeight + 15

    ; 优先使用用户拖拽保存的高度，但绝不允许小于内容所需的最小高度
    actualHeight := HoverPanel_GUIHeight
    if (actualHeight < MinRequiredHeight)
        actualHeight := MinRequiredHeight
    ; --- 5. 坐标计算与圆角渲染 ---
    SysGet, Mon, MonitorWorkArea
    DPIScale := A_ScreenDPI / 96
    RealW := Round(HoverPanel_Width * DPIScale)
    RealH := Round(actualHeight * DPIScale)
    RealRgn := Round(15 * DPIScale)

    if (GuiExists) {
        ; 窗口存在时，绝对锁定它的老位置，再也不会乱跑
        WinGetPos, px, py,,, ahk_id %hHoverPanel%
    } else {
        ; ▼▼▼ 修改：如果有强制重建前保存的坐标，则原地恢复，防止弹回悬浮球 ▼▼▼
        if (savedPX != "" && savedPY != "") {
            px := savedPX
            py := savedPY
        } else {
            WinGetPos, bx, by, bw, bh, ahk_id %hBall%
            px := bx + bw + 10
            py := by
            if (px + RealW > MonRight)  ; 【修复】使用真实物理宽度判断，防止越界
                px := bx - RealW - 10
        }
        ; ▲▲▲ ========================================================== ▲▲▲
    }
    if (py + RealH > MonBottom)     ; 【修复】使用真实物理高度判断，防止越界
        py := MonBottom - RealH

    ; 【修复】带 DPI 缩放的圆角裁切
    SetWindowRgn(hHoverPanel, RealW, RealH, RealRgn)

    if (!GuiExists) {
        ; ▼▼▼ 核心修复：先换算回逻辑坐标安抚 AHK，再用物理坐标精准定位 ▼▼▼
        logX := Round(px / DPIScale)
        logY := Round(py / DPIScale)

        ; 告诉 AHK 初始位置，防止它自作主张居中
        Gui, HoverPanel: Show, Hide x%logX% y%logY% w%HoverPanel_Width% h%actualHeight%
        Gui, HoverPanel: Show, NoActivate

        ; 强制使用物理像素进行微调覆盖，确保高分屏下边缘无缝贴合
        WinMove, ahk_id %hHoverPanel%,, %px%, %py%, %RealW%, %RealH%
        HoverPanelVisible := true
        ; ▲▲▲ ======================================================== ▲▲▲
    } else {
        ; 无缝拉伸/缩短窗口底边 (WinMove 必须使用物理尺寸)
        WinMove, ahk_id %hHoverPanel%,, %px%, %py%, %RealW%, %RealH%
    }
}

; 图钉锁定切换事件
ToggleHoverPanelPin:
    Gui, HoverPanel: Default
    isHoverPanelPinned := !isHoverPanelPinned

    newPinColor := isHoverPanelPinned ? "cFF0000" : "c" HoverPanel_FontColor

    ; 【修复】：同样补全字体参数并强制重绘
    Gui, Font, s10 w700 %newPinColor%, 微软雅黑
    GuiControl, Font, HP_PinBtn
    GuiControl, MoveDraw, HP_PinBtn
return

; ==============================================================================
; 动作项目点击分发器 (已去除错误 ToolTip 提示)
; ==============================================================================
OnHoverItemClick:
    ToolTip ; 清除悬停提示
    SetTimer, ShowHoverTooltip, Off

    ; 从触发的控件名中提取当前点击的项目索引
    itemIdx := RegExReplace(A_GuiControl, "\D", "")
    item := HoverItemsData[itemIdx]

    CoordMode, Mouse, Screen
    MouseGetPos, startX, startY
    isDragging := false
    dragTargetIdx := itemIdx
    isValidZone := true

    ; 【预处理】：提取当前所有有效的分组名，用于跨分组检测
    uniqueGroups := {}
    for i, itm in HoverItemsData {
        if (itm.Group != "")
            uniqueGroups[itm.Group] := true
    }

    WinGetPos, wx, wy, ww, wh, ahk_id %hHoverPanel%

    ; 动态计算当前分组所有菜单项的整体显示边界
    minY := 99999, maxY := 0, minX := 99999, maxX := 0
    for idx, testItem in HoverItemsData {
        if (testItem.Group != CurrentHoverGroup)
            continue
        if (testItem.RenderY != "" && testItem.RenderY < minY)
            minY := testItem.RenderY
        if (testItem.RenderY != "" && testItem.RenderY + HoverPanel_ItemHeight > maxY)
            maxY := testItem.RenderY + HoverPanel_ItemHeight
        if (testItem.RenderX != "" && testItem.RenderX < minX)
            minX := testItem.RenderX
        if (testItem.RenderX != "" && testItem.RenderX + HoverPanel_ItemWidth > maxX)
            maxX := testItem.RenderX + HoverPanel_ItemWidth
    }

    Gui, HoverDrag: Destroy
    Gui, HoverDrag: +AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner%hHoverPanel%
    Gui, HoverDrag: Color, % HoverPanel_BgColor ? HoverPanel_BgColor : G_BgColor
    Gui, HoverDrag: Font, % "s" HoverPanel_FontSize " c" HoverPanel_FontColor, %HoverPanel_FontName%
    Gui, HoverDrag: Add, Text, x8 y6, % "📦 " item.Text

    While GetKeyState("LButton", "P") {
        MouseGetPos, curX, curY, curWin, curCtrlHwnd, 2

        if (!isDragging && (Abs(curX - startX) > 5 || Abs(curY - startY) > 5)) {
            isDragging := true
            Gui, HoverDrag: Show, % "x" (curX + 12) " y" (curY + 12) " w140 h32 NA"
            if (HoverPanel_EnableHoverHighlight = "1")
                GuiControl, HoverPanel: Show, HPHighlight
        }

        if (isDragging) {
            Gui, HoverDrag: Show, % "x" (curX + 12) " y" (curY + 12) " NA"

            ControlGetText, ctrlText, , ahk_id %curCtrlHwnd%
            ctrlText := Trim(ctrlText)

            ; 【跨分组判定】
            if (curWin == hHoverPanel && uniqueGroups.HasKey(ctrlText) && ctrlText != CurrentHoverGroup) {
                targetGrp := ctrlText

                itemToMove := HoverItemsData.RemoveAt(itemIdx)
                itemToMove.Group := targetGrp

                insertPos := HoverItemsData.MaxIndex() + 1
                for i, testItm in HoverItemsData {
                    if (testItm.Group == targetGrp)
                        insertPos := i + 1
                }
                HoverItemsData.InsertAt(insertPos, itemToMove)

                cfgPath := A_ScriptDir "\HoverItems.txt"
                newContent =
                (LTrim
                ; ============================================================
                ; 悬停面板配置说明 (一行一个动作)
                ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
                ; ============================================================
                )
                newContent .= "`n"
                for i, itm in HoverItemsData {
                    newContent .= EscapeHoverData(itm.Icon) "|" EscapeHoverData(itm.Text) "|" EscapeHoverData(itm.Group) "|" itm.Type "|" EscapeHoverData(itm.Param) "|" EscapeHoverData(itm.Remark) "`n"
                }
                FileDelete, %cfgPath%
                FileAppend, %newContent%, %cfgPath%, UTF-8

                LoadHoverItems()
                CurrentHoverGroup := targetGrp
                ; ▼▼▼ 修改：强制重建 ▼▼▼
                RenderHoverPanel(CurrentHoverGroup, true)

                itemIdx := insertPos
                dragTargetIdx := insertPos
                item := HoverItemsData[itemIdx]

                WinGetPos, wx, wy, ww, wh, ahk_id %hHoverPanel%
                minY := 99999, maxY := 0, minX := 99999, maxX := 0
                for idx, testItem in HoverItemsData {
                    if (testItem.Group != CurrentHoverGroup)
                        continue
                    if (testItem.RenderY != "" && testItem.RenderY < minY)
                        minY := testItem.RenderY
                    if (testItem.RenderY != "" && testItem.RenderY + HoverPanel_ItemHeight > maxY)
                        maxY := testItem.RenderY + HoverPanel_ItemHeight
                    if (testItem.RenderX != "" && testItem.RenderX < minX)
                        minX := testItem.RenderX
                    if (testItem.RenderX != "" && testItem.RenderX + HoverPanel_ItemWidth > maxX)
                        maxX := testItem.RenderX + HoverPanel_ItemWidth
                }

                if (HoverPanel_EnableHoverHighlight = "1")
                    GuiControl, HoverPanel: Hide, HPHighlight

                isValidZone := true
                Sleep, 100
                Continue
            }

            relX := curX - wx
            relY := curY - wy
            isOverGroupTab := (curWin == hHoverPanel && uniqueGroups.HasKey(ctrlText))

            ; 【移除非法区域 ToolTip，只保留静默隐藏高亮条】
            if (!isOverGroupTab && (curX < wx || curX > wx + ww || curY < wy || curY > wy + wh || relY < minY || relY > maxY || relX < minX || relX > maxX)) {
                if (isValidZone) {
                    isValidZone := false
                    if (HoverPanel_EnableHoverHighlight = "1")
                        GuiControl, HoverPanel: Hide, HPHighlight
                }
            }
            else {
                if (!isValidZone)
                    isValidZone := true

                if (isOverGroupTab) {
                    if (HoverPanel_EnableHoverHighlight = "1")
                        GuiControl, HoverPanel: Hide, HPHighlight
                } else {
                    hoveredIdx := dragTargetIdx
                    for idx, testItem in HoverItemsData {
                        if (testItem.Group != CurrentHoverGroup)
                            continue
                        ix := testItem.RenderX
                        iy := testItem.RenderY
                        iw := HoverPanel_ItemWidth
                        ih := HoverPanel_ItemHeight

                        if (relX >= ix && relX <= ix + iw && relY >= iy && relY <= iy + ih) {
                            hoveredIdx := idx
                            break
                        }
                    }

                    if (hoveredIdx != dragTargetIdx) {
                        dragTargetIdx := hoveredIdx
                        hX := HoverItemsData[hoveredIdx].RenderX
                        hY := HoverItemsData[hoveredIdx].RenderY
                        if (HoverPanel_EnableHoverHighlight = "1" && hX != "" && hY != "") {
                            GuiControl, HoverPanel: Show, HPHighlight
                            GuiControl, HoverPanel: Move, HPHighlight, % "x" hX " y" hY
                        }
                    }
                }
            }
        }
        Sleep, 15
    }

    Gui, HoverDrag: Destroy

    if (isDragging) {
        if (HoverPanel_EnableHoverHighlight = "1")
            GuiControl, HoverPanel: Hide, HPHighlight

        if (isValidZone && dragTargetIdx != itemIdx) {
            itemToMove := HoverItemsData.RemoveAt(itemIdx)
            HoverItemsData.InsertAt(dragTargetIdx, itemToMove)

            cfgPath := A_ScriptDir "\HoverItems.txt"
            newContent =
            (LTrim
            ; ============================================================
            ; 悬停面板配置说明 (一行一个动作)
            ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
            ; ============================================================
            )
            newContent .= "`n"
            for i, itm in HoverItemsData {
                newContent .= EscapeHoverData(itm.Icon) "|" EscapeHoverData(itm.Text) "|" EscapeHoverData(itm.Group) "|" itm.Type "|" EscapeHoverData(itm.Param) "|" EscapeHoverData(itm.Remark) "`n"
            }
            FileDelete, %cfgPath%
            FileAppend, %newContent%, %cfgPath%, UTF-8

            ToolTip, ✅ 排序已更新
            SetTimer, RemoveToolTip, -1500

            LoadHoverItems()
            RenderHoverPanel(CurrentHoverGroup)
        }
        return
    }

    if (isHoverPanelEditMode) {
        Gui, HoverPanel: Default
        if (HoverPanelSelectedItems.HasKey(itemIdx)) {
            HoverPanelSelectedItems.Delete(itemIdx)
            Gui, Font, % "s" HoverPanel_FontSize " w400 c" HoverPanel_FontColor, %HoverPanel_FontName%
        } else {
            HoverPanelSelectedItems[itemIdx] := true
            Gui, Font, % "s" HoverPanel_FontSize " w400 cFF5555", %HoverPanel_FontName%
        }
        GuiControl, Font, HPItem_%itemIdx%
        GuiControl, MoveDraw, HPItem_%itemIdx%
        return
    }

    if (!isHoverPanelPinned) {
        Gui, HoverPanel: Destroy
        HoverPanelVisible := false
    }
    ExecuteAction("1", item.Type, item.Param)
return

; ==============================================================================
; 分组栏点击分发器 (已整合横向拖拽排序)
; ==============================================================================
HoverPanelSwitchGroup:
    ToolTip ; 清除悬停提示
    SetTimer, ShowHoverTooltip, Off

    ; 获取被点击的分组名和索引
    grpIdx := RegExReplace(A_GuiControl, "\D", "")
    draggedGrpName := HoverGroups[grpIdx]

    CoordMode, Mouse, Screen
    MouseGetPos, startX, startY
    isDragging := false
    dragTargetIdx := grpIdx
    isValidZone := true

    WinGetPos, wx, wy, ww, wh, ahk_id %hHoverPanel%

    ; 动态计算分组栏的极值边界，并记录每个标签的实际位置
    minY := 99999, maxY := 0, minX := 99999, maxX := 0
    GrpPos := []
    for i, gName in HoverGroups {
        GuiControlGet, pos, Pos, HPGrp_%i%
        GrpPos[i] := {x: posX, y: posY, w: posW, h: posH}
        if (posY < minY)
            minY := posY
        if (posY + posH > maxY)
            maxY := posY + posH
        if (posX < minX)
            minX := posX
        if (posX + posW > maxX)
            maxX := posX + posW
    }
    ; 稍微放宽 Y 轴容错，防止手抖出界
    minY -= 15
    maxY += 15

    ; 创建分组的影子跟手窗体
    Gui, GrpDrag: Destroy
    Gui, GrpDrag: +AlwaysOnTop -Caption +ToolWindow +E0x20 +Owner%hHoverPanel%
    Gui, GrpDrag: Color, % HoverPanel_BgColor ? HoverPanel_BgColor : G_BgColor
    Gui, GrpDrag: Font, s10 w700 c00CCFF, 微软雅黑
    Gui, GrpDrag: Add, Text, x8 y6, % draggedGrpName

    While GetKeyState("LButton", "P") {
        MouseGetPos, curX, curY

        if (!isDragging && (Abs(curX - startX) > 5 || Abs(curY - startY) > 5)) {
            isDragging := true
            Gui, GrpDrag: Show, % "x" (curX + 12) " y" (curY + 12) " h32 NA"
        }

        if (isDragging) {
            Gui, GrpDrag: Show, % "x" (curX + 12) " y" (curY + 12) " NA"

            relX := curX - wx
            relY := curY - wy

            ; 限制拖拽必须在分组栏这一行移动
            if (curX < wx || curX > wx + ww || relY < minY || relY > maxY) {
                isValidZone := false
            } else {
                isValidZone := true

                ; 探测鼠标目前悬停在哪个分组上
                hoveredIdx := dragTargetIdx
                for i, pos in GrpPos {
                    if (relX >= pos.x - 5 && relX <= pos.x + pos.w + 5 && relY >= pos.y - 10 && relY <= pos.y + pos.h + 10) {
                        hoveredIdx := i
                        break
                    }
                }

                if (hoveredIdx != dragTargetIdx) {
                    dragTargetIdx := hoveredIdx
                }
            }
        }
        Sleep, 15
    }

    Gui, GrpDrag: Destroy

    if (isDragging) {
        if (isValidZone && dragTargetIdx != grpIdx) {
            ; 1. 交换分组名称
            grpToMove := HoverGroups.RemoveAt(grpIdx)
            HoverGroups.InsertAt(dragTargetIdx, grpToMove)

            ; 2. 依据新的分组顺序，整体重组底层数据数组...
            NewHoverItemsData := []
            for _, gName in HoverGroups {
                for _, itm in HoverItemsData {
                    if (itm.Group == gName)
                        NewHoverItemsData.Push(itm)
                }
            }
            HoverItemsData := NewHoverItemsData

            ; 3. 重写到文本文件保存
            cfgPath := A_ScriptDir "\HoverItems.txt"
            newContent =
            (LTrim
            ; ============================================================
            ; 悬停面板配置说明 (一行一个动作)
            ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
            ; ============================================================
            )
            newContent .= "`n"
            for i, itm in HoverItemsData {
                newContent .= EscapeHoverData(itm.Icon) "|" EscapeHoverData(itm.Text) "|" EscapeHoverData(itm.Group) "|" itm.Type "|" EscapeHoverData(itm.Param) "|" EscapeHoverData(itm.Remark) "`n"
            }
            FileDelete, %cfgPath%
            FileAppend, %newContent%, %cfgPath%, UTF-8

            ToolTip, ✅ 分组排序已更新
            SetTimer, RemoveToolTip, -1500

            LoadHoverItems()

            ; ▼▼▼ 修改：拖拽交换成功后，强制重建面板，修复文本宽度截断BUG ▼▼▼
            CurrentHoverGroup := draggedGrpName
            RenderHoverPanel(CurrentHoverGroup, true)
            return
        }

        ; 拖拽完成（无论是否成功改变位置），确保展示当前被拖拽的组
        CurrentHoverGroup := draggedGrpName
        RenderHoverPanel(CurrentHoverGroup)
        return
    }

    ; 原有的常规点击切换逻辑
    GuiControlGet, clickedText,, %A_GuiControl%
    if (clickedText = CurrentHoverGroup)
        return
    CurrentHoverGroup := clickedText
    RenderHoverPanel(CurrentHoverGroup)
return

; ==============================================================================
; 新增：悬停面板全局拖放接管引擎 (支持文件、网址、文本智能解析与落地)
; ==============================================================================
HoverPanelAddFromDrop(DropData, DropType, ExtractedTitle:="") {
    global CurrentHoverGroup
    if (CurrentHoverGroup = "")
        CurrentHoverGroup := "默认"

    AddedCount := 0
    cfgPath := A_ScriptDir "\HoverItems.txt"

    ; 保护机制：读取当前文件末尾，确保追加内容不会和上一行粘连
    FileRead, currentContent, %cfgPath%
    if (currentContent != "" && SubStr(currentContent, 0) != "`n")
        FileAppend, `n, %cfgPath%, UTF-8

    if (DropType = "File") {
        Loop, Parse, DropData, `n, `r
        {
            if (A_LoopField = "")
                continue
            SplitPath, A_LoopField, fileName, filedir, fileext, filename_no_ext
            ; 【修改】：进行转义
            appendLine := EscapeHoverData(A_LoopField) . "|" . EscapeHoverData(filename_no_ext) . "|" . EscapeHoverData(CurrentHoverGroup) . "|1|" . EscapeHoverData(A_LoopField) . "|拖入文件添加`n"
            FileAppend, %appendLine%, %cfgPath%, UTF-8
            AddedCount++
        }
    }
    else if (DropType = "Text") {
        DropData := Trim(DropData, "`r`n`t ")
        if (DropData = "")
            return

        isUrl := false
        if RegExMatch(DropData, "i)^(https?://|www\.)[^\r\n]+$")
            isUrl := true
        else if (ExtractedTitle != "" && RegExMatch(DropData, "i)^(https?://|www\.)"))
            isUrl := true

        if (isUrl) {
            icon := "shell32.dll,14" ; 原生系统地球网络图标
            title := ExtractedTitle != "" ? ExtractedTitle : RegExReplace(DropData, "^https?://(www\.)?", "")
            if (ExtractedTitle == "" && StrLen(title) > 18)
                title := SubStr(title, 1, 15) . "..."
            type := "1"

            ; 【修改】：进行转义
            appendLine := icon . "|" . EscapeHoverData(title) . "|" . EscapeHoverData(CurrentHoverGroup) . "|" . type . "|" . EscapeHoverData(DropData) . "|拖拽网址添加`n"
            FileAppend, %appendLine%, %cfgPath%, UTF-8
            AddedCount++
        }
        else {
            TargetDir := A_ScriptDir "\Dropped"
            if !InStr(FileExist(TargetDir), "D")
                FileCreateDir, %TargetDir%

            FormatTime, timeStr,, yyyyMMdd_HHmmss
            fileName := "HoverText_" timeStr "_" A_TickCount ".txt"

            txtFileAbs := TargetDir "\" fileName
            txtFileRel := "Dropped\" fileName

            FileAppend, %DropData%, %txtFileAbs%, UTF-8

            previewText := RegExReplace(DropData, "[\r\n]+", " ")
            title := SubStr(previewText, 1, 12)
            if (StrLen(previewText) > 12)
                title .= "..."

            icon := "shell32.dll,71" ; 原生系统文本文件图标
            type := "1"

            ; 【修改】：进行转义
            appendLine := icon . "|" . EscapeHoverData(title) . "|" . EscapeHoverData(CurrentHoverGroup) . "|" . type . "|" . EscapeHoverData(txtFileRel) . "|拖拽文本落地添加`n"
            FileAppend, %appendLine%, %cfgPath%, UTF-8
            AddedCount++
        }
    }

    if (AddedCount > 0) {
        LoadHoverItems()
        RenderHoverPanel(CurrentHoverGroup, true) ; 强制重建刷新界面
        ToolTip, 成功添加项目到「%CurrentHoverGroup%」！
        SetTimer, RemoveToolTip, -2500
    }
}

; ==============================================================================
; 悬停面板专属拖拽逻辑 (无视焦点抢夺)
; ==============================================================================
HoverPanelDrag:
    ; 直接精准抓取悬停面板的句柄 hHoverPanel 进行拖拽，而不使用 A (ActiveWindow)
    PostMessage, 0xA1, 2,,, ahk_id %hHoverPanel%
return
; ==============================================================================
; 悬停面板右键菜单与批量删除核心逻辑
; ==============================================================================
HoverPanelGuiContextMenu:
    ; 【检测是否右键点击了顶部“分组标签”】
    if RegExMatch(A_GuiControl, "^HPGrp_(\d+)$", match) {
        global RClickGrpIdx := match1
        Menu, HoverGrpMenu, Add
        Menu, HoverGrpMenu, DeleteAll

        Menu, HoverGrpMenu, Add, 重命名分组, RenameHoverGroup
        Menu, HoverGrpMenu, Icon, 重命名分组, shell32.dll, 133 ; 使用系统编辑图标

        Menu, HoverGrpMenu, Add, 删除该分组, DeleteHoverGroup
        Menu, HoverGrpMenu, Icon, 删除该分组, shell32.dll, 132 ; 使用系统删除图标

        IsMenuOpen := true
        Menu, HoverGrpMenu, Show
        IsMenuOpen := false
        return
    }

    ; 【检测是否右键点击了“动作项目”】
    if RegExMatch(A_GuiControl, "^HP(Pic|Ico|Item)_(\d+)$", match) {
        global RClickItemIdx := match2
        Menu, HoverItemMenu, Add
        Menu, HoverItemMenu, DeleteAll

        ; 👇 新增：在此项后面新建菜单项
        Menu, HoverItemMenu, Add, 新建菜单项, AddHoverItemSingle
        Menu, HoverItemMenu, Icon, 新建菜单项, shell32.dll, 114
        Menu, HoverItemMenu, Add ; 分割线

        Menu, HoverItemMenu, Add, 编辑此项, EditHoverItemSingle
        Menu, HoverItemMenu, Icon, 编辑此项, shell32.dll, 133

        Menu, HoverItemMenu, Add, 删除此项 (单删), DeleteHoverItemSingle
        Menu, HoverItemMenu, Icon, 删除此项 (单删), shell32.dll, 132
        Menu, HoverItemMenu, Add ; 分割线

        Menu, HoverItemMenu, Add, 进入批量删除模式, EnterHoverBatchDeleteMode
        Menu, HoverItemMenu, Icon, 进入批量删除模式, shell32.dll, 238

        IsMenuOpen := true
        Menu, HoverItemMenu, Show
        IsMenuOpen := false
        return ; 拦截结束
    }

    ; 👇 【新增】：检测是否右键点击了面板的空白区域或辅助线
    if (A_GuiControl = "" || RegExMatch(A_GuiControl, "^(HPEmptyText|HP_Line|HP_DragBar1|HP_DragBar2|HPHighlight)$")) {
        global RClickItemIdx := 0 ; 设为0代表插入到当前分组的最后面
        Menu, HoverBgMenu, Add
        Menu, HoverBgMenu, DeleteAll

        Menu, HoverBgMenu, Add, 新建菜单项, AddHoverItemSingle
        Menu, HoverBgMenu, Icon, 新建菜单项, shell32.dll, 114

        IsMenuOpen := true
        Menu, HoverBgMenu, Show
        IsMenuOpen := false
        return
    }
return
RenameHoverGroup:
    oldGrpName := HoverGroups[RClickGrpIdx]
    ; 【新增锁定逻辑】：记录当前是否被图钉固定，然后强制锁定，防止鼠标移出导致面板自动销毁
    tempPinStatus := isHoverPanelPinned
    isHoverPanelPinned := true

    ; 【核心新增】：声明后续弹出的 MsgBox/InputBox 归属于悬停面板，强制显示在其上层
    Gui, HoverPanel: +OwnDialogs
    ; 弹出输入框要求输入新名称
    InputBox, newGrpName, 重命名分组, 请输入「%oldGrpName%」的新名称：, , 300, 150, , , , , %oldGrpName%

    ; 【新增还原逻辑】：无论用户是点击了确定还是取消，第一时间还原先前的图钉状态
    isHoverPanelPinned := tempPinStatus

    if ErrorLevel
        return

    newGrpName := Trim(newGrpName)

    ; 如果为空或者没修改，则直接退出
    if (newGrpName = "" || newGrpName = oldGrpName)
        return

    ; 检查是否与现有分组重名，防止数据混乱
    for k, v in HoverGroups {
        if (v = newGrpName) {
            MsgBox, 48, 提示, 分组名「%newGrpName%」已存在，请换一个名称！
            return
        }
    }

    ; 1. 更新内存中的分组名
    HoverGroups[RClickGrpIdx] := newGrpName

    ; 2. 遍历所有动作项目，将旧分组名替换为新分组名
    for idx, itm in HoverItemsData {
        if (itm.Group = oldGrpName)
            itm.Group := newGrpName
    }

    ; 3. 重新拼接并覆盖写入 HoverItems.txt 配置文件
    cfgPath := A_ScriptDir "\HoverItems.txt"
    newContent =
    (LTrim
    ; ============================================================
    ; 悬停面板配置说明 (一行一个动作)
    ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
    ; ============================================================
    )
    newContent .= "`n"
    for i, itm in HoverItemsData {
        newContent .= EscapeHoverData(itm.Icon) "|" EscapeHoverData(itm.Text) "|" EscapeHoverData(itm.Group) "|" itm.Type "|" EscapeHoverData(itm.Param) "|" EscapeHoverData(itm.Remark) "`n"
    }
    FileDelete, %cfgPath%
    FileAppend, %newContent%, %cfgPath%, UTF-8

    ToolTip, ✅ 分组已重命名为「%newGrpName%」
    SetTimer, RemoveToolTip, -1500

    ; 4. 重新加载数据并强制重建整个悬停面板 UI，防止文字宽度截断 BUG
    LoadHoverItems()
    CurrentHoverGroup := newGrpName
    RenderHoverPanel(CurrentHoverGroup, true)
return

; ==============================================================================
; 新增功能：删除整个分组及其包含的所有动作项
; ==============================================================================
DeleteHoverGroup:
    delGrpName := HoverGroups[RClickGrpIdx]

    ; 临时锁定面板防止因弹窗失去焦点而关闭
    tempPinStatus := isHoverPanelPinned
    isHoverPanelPinned := true
    Gui, HoverPanel: +OwnDialogs

    MsgBox, 292, 警告, 确定要删除分组「%delGrpName%」及其包含的所有动作项目吗？`n此操作不可逆！

    isHoverPanelPinned := tempPinStatus

    IfMsgBox, No
        return

    ; 1. 过滤掉被删除分组下的所有项目，重组数据
    NewHoverItemsData := []
    for idx, itm in HoverItemsData {
        if (itm.Group != delGrpName)
            NewHoverItemsData.Push(itm)
    }
    HoverItemsData := NewHoverItemsData

    ; 2. 从分组列表中移除
    HoverGroups.RemoveAt(RClickGrpIdx)

    ; 3. 将新数据写回配置文件
    cfgPath := A_ScriptDir "\HoverItems.txt"
    newContent =
    (LTrim
    ; ============================================================
    ; 悬停面板配置说明 (一行一个动作)
    ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
    ; ============================================================
    )
    newContent .= "`n"
    for i, itm in HoverItemsData {
        newContent .= EscapeHoverData(itm.Icon) "|" EscapeHoverData(itm.Text) "|" EscapeHoverData(itm.Group) "|" itm.Type "|" EscapeHoverData(itm.Param) "|" EscapeHoverData(itm.Remark) "`n"
    }
    FileDelete, %cfgPath%
    FileAppend, %newContent%, %cfgPath%, UTF-8

    ToolTip, ✅ 分组「%delGrpName%」已删除
    SetTimer, RemoveToolTip, -1500

    ; 4. 重新加载并刷新 UI
    LoadHoverItems()

    ; 如果当前分组被删，尝试跳转到第一个分组，若全空则默认回到“默认”分组
    if (HoverGroups.MaxIndex() > 0)
        CurrentHoverGroup := HoverGroups[1]
    else
        CurrentHoverGroup := "默认"

    RenderHoverPanel(CurrentHoverGroup, true)
return

; ==============================================================================
; 新增功能：新建/编辑 单个菜单项 (精美 GUI 公用核心)
; ==============================================================================
AddHoverItemSingle:
    global tempPinStatus := isHoverPanelPinned
    isHoverPanelPinned := true
    global IsNewHoverItem := true
    global EditorTitle := "✨ 新建菜单项"

    ; 初始化为空白和默认状态
    global EditItm_Icon := "📝"
    global EditItm_Text := "新建动作"
    global EditItm_Group := CurrentHoverGroup
    global EditItm_Type := "1"
    global EditItm_Param := ""
    global EditItm_Remark := "手动新建"

    GoSub, BuildHoverItemEditor
return

EditHoverItemSingle:
    global tempPinStatus := isHoverPanelPinned
    isHoverPanelPinned := true
    global IsNewHoverItem := false
    global EditorTitle := "📝 编辑菜单项"

    ; 提取当前待编辑项目的属性
    itm := HoverItemsData[RClickItemIdx]
    global EditItm_Icon := itm.Icon
    global EditItm_Text := itm.Text
    global EditItm_Group := itm.Group
    global EditItm_Type := itm.Type
    global EditItm_Param := itm.Param
    global EditItm_Remark := itm.Remark

    GoSub, BuildHoverItemEditor
return

BuildHoverItemEditor:
    Gui, HoverItemEditor: Destroy
    Gui, HoverItemEditor: -Caption +AlwaysOnTop +Owner%hHoverPanel% +HwndhHoverItemEditor
    Gui, HoverItemEditor: Color, %G_BgColor%
    Gui, HoverItemEditor: Margin, 20, 20

    ; 【修改】：高度从 400 增加到 430，为多行输入框留出空间
    W := 420, H := 430

    DPIScale := A_ScreenDPI / 96
    RealW := Round(W * DPIScale)
    RealH := Round(H * DPIScale)
    RealRgn := Round(15 * DPIScale)
    SetWindowRgn(hHoverItemEditor, RealW, RealH, RealRgn)
    DrawRoundedBackground_API(hHoverItemEditor, RealW, RealH, RealRgn, G_BgARGB, G_BorderARGB)

    Gui, HoverItemEditor: Font, s12 c%G_FontColor% w700, 微软雅黑
    Gui, HoverItemEditor: Add, Text, x20 y15 w380 h25 BackgroundTrans gGuiDrag, %EditorTitle%

    Gui, HoverItemEditor: Font, s10 c%G_SubFontColor% w400, 微软雅黑

    Gui, HoverItemEditor: Add, Text, x25 y65 w70 h25, 🖼️ 图 标:
    Gui, HoverItemEditor: Add, Edit, x100 y60 w290 h25 vEditItm_Icon cBlack, %EditItm_Icon%

    Gui, HoverItemEditor: Add, Text, x25 y115 w70 h25, 🏷️ 文 字:
    Gui, HoverItemEditor: Add, Edit, x100 y110 w290 h25 vEditItm_Text cBlack, %EditItm_Text%

    Gui, HoverItemEditor: Add, Text, x25 y165 w70 h25, 📁 分 组:
    Gui, HoverItemEditor: Add, Edit, x100 y160 w290 h25 vEditItm_Group cBlack, %EditItm_Group%

    Gui, HoverItemEditor: Add, Text, x25 y215 w70 h25, ⚡ 类 型:
    TypeDesc := "1 - 运行程序 / 打开文件夹|2 - 发送按键|3 - 发送文本|4 - 调用RunAny|5 - 内部命令|6 - 执行AHK代码"
    Gui, HoverItemEditor: Add, DropDownList, x100 y210 w290 vEditItm_TypeChoice Choose%EditItm_Type%, %TypeDesc%

    ; 【修改】：将单行 Edit 改为多行 Multi VScroll，高度设为 50
    Gui, HoverItemEditor: Add, Text, x25 y265 w70 h25, ⚙️ 参 数:
    Gui, HoverItemEditor: Add, Edit, x100 y260 w290 h50 Multi VScroll vEditItm_Param cBlack, %EditItm_Param%

    ; 【修改】：下方控件 Y 轴整体下移 25 像素
    Gui, HoverItemEditor: Add, Text, x25 y340 w70 h25, 📌 备 注:
    Gui, HoverItemEditor: Add, Edit, x100 y335 w290 h25 vEditItm_Remark cBlack, %EditItm_Remark%

    Gui, HoverItemEditor: Add, Button, x100 y380 w120 h30 Default gSaveHoverItemEdit, 保存
    Gui, HoverItemEditor: Add, Button, x240 y380 w120 h30 gCancelHoverItemEdit, 取消

    Gui, HoverItemEditor: Show, w%W% h%H% Center, %EditorTitle%
return

SaveHoverItemEdit:
    Gui, HoverItemEditor: Submit, NoHide

    RegExMatch(EditItm_TypeChoice, "^\d+", finalType)

    if (Trim(EditItm_Text) = "" || Trim(EditItm_Param) = "") {
        Gui, HoverItemEditor: +OwnDialogs
        MsgBox, 48, 提示, 【文字】和【参数】不能为空！
        return
    }

    ; 【修改】：移除旧的强行过滤换行符逻辑，允许保留回车
    cleanParam := Trim(EditItm_Param)

    groupName := Trim(EditItm_Group)
    if (groupName = "")
        groupName := "默认"

    if (IsNewHoverItem) {
        newItem := {}
        newItem.Icon := Trim(EditItm_Icon)
        newItem.Text := Trim(EditItm_Text)
        newItem.Group := groupName
        newItem.Type := finalType
        newItem.Param := cleanParam
        newItem.Remark := Trim(EditItm_Remark)

        if (RClickItemIdx > 0 && HoverItemsData.MaxIndex() != "")
            HoverItemsData.InsertAt(RClickItemIdx + 1, newItem)
        else
            HoverItemsData.Push(newItem)

        NoticeMsg := "✅ 新建菜单项成功！"
    } else {
        itm := HoverItemsData[RClickItemIdx]
        itm.Icon := Trim(EditItm_Icon)
        itm.Text := Trim(EditItm_Text)
        itm.Group := groupName
        itm.Type := finalType
        itm.Param := cleanParam
        itm.Remark := Trim(EditItm_Remark)

        NoticeMsg := "✅ 菜单项已更新！"
    }

    cfgPath := A_ScriptDir "\HoverItems.txt"
    newContent =
    (LTrim
    ; ============================================================
    ; 悬停面板配置说明 (一行一个动作)
    ; 格式：图标(可纯文本或文件路径)|文字|分组名|功能类型|功能参数|备注
    ; ============================================================
    )
    newContent .= "`n"
    for i, itemData in HoverItemsData {
        ; 【修改】：保存文件时，进行转义编码
        newContent .= EscapeHoverData(itemData.Icon) "|" EscapeHoverData(itemData.Text) "|" EscapeHoverData(itemData.Group) "|" itemData.Type "|" EscapeHoverData(itemData.Param) "|" EscapeHoverData(itemData.Remark) "`n"
    }
    FileDelete, %cfgPath%
    FileAppend, %newContent%, %cfgPath%, UTF-8

    ToolTip, %NoticeMsg%
    SetTimer, RemoveToolTip, -1500

    Gui, HoverItemEditor: Destroy
    isHoverPanelPinned := tempPinStatus
    RClickItemIdx := 0

    LoadHoverItems()
    CurrentHoverGroup := groupName
    RenderHoverPanel(CurrentHoverGroup, true)
return

CancelHoverItemEdit:
HoverItemEditorGuiEscape:
HoverItemEditorGuiClose:
    Gui, HoverItemEditor: Destroy
    ; 用户取消时也必须还原图钉状态，避免面板无法关闭
    isHoverPanelPinned := tempPinStatus
return

DeleteHoverItemSingle:
    HoverPanelSelectedItems := {}
    HoverPanelSelectedItems[RClickItemIdx] := true
    GoSub, ConfirmHoverBatchDelete ; 复用批量删除核心
return

EnterHoverBatchDeleteMode:
    isHoverPanelEditMode := true
    HoverPanelSelectedItems := {}
    isHoverPanelPinned := true ; 强制打上图钉，防止点击时面板误关
    RenderHoverPanel(CurrentHoverGroup)
return

ExitHoverBatchDeleteMode:
    isHoverPanelEditMode := false
    HoverPanelSelectedItems := {}
    RenderHoverPanel(CurrentHoverGroup)
return

CloseHoverPanel:
    ToolTip ; 动作触发/面板关闭时清除悬停提示
    SetTimer, ShowHoverTooltip, Off
    DllCall("ole32\RevokeDragDrop", "Ptr", hHoverPanel) ; <--- 新增
    Gui, HoverPanel: Destroy
    HoverPanelVisible := false
    isHoverPanelPinned := false
return

ConfirmHoverBatchDelete:
    ; 计算一共选中了多少项
    delCount := 0
    for k, v in HoverPanelSelectedItems
        delCount++

    if (delCount == 0) {
        GoSub, ExitHoverBatchDeleteMode
        return
    }

    tempPinStatus := isHoverPanelPinned
    isHoverPanelPinned := true
    Gui, HoverPanel: +OwnDialogs

    MsgBox, 292, 批量删除, % "确定要永久删除选中的 " delCount " 个动作吗？"

    isHoverPanelPinned := tempPinStatus
    IfMsgBox, No
        return

    ; 将所有选中的原始文本存入字典，以便比对
    linesToDelete := {}
    for idx, _ in HoverPanelSelectedItems {
        itm := HoverItemsData[idx]

        ; ▼▼▼ 新增：自动清理落地的 txt 垃圾文件 ▼▼▼
        ; 安全判定：确保是类型1，且路径中包含 Dropped\ 文件夹
        if (itm.Type = "1" && InStr(itm.Param, "Dropped\")) {
            ; 双重保险：优先尝试直接删除，如果相对路径不通，则补全脚本目录后删除
            if FileExist(itm.Param)
                FileDelete, % itm.Param
            else if FileExist(A_ScriptDir "\" itm.Param)
                FileDelete, % A_ScriptDir "\" itm.Param
        }
        ; ▲▲▲ ====================================== ▲▲▲

        linesToDelete[itm.LineStr] := true
    }

    cfgPath := A_ScriptDir "\HoverItems.txt"
    FileRead, fileContent, *t %cfgPath%
    newContent := ""

    Loop, Parse, fileContent, `n, `r
    {
        ; 如果这一行在待删除字典里，则跳过不写（并删除记录防止完全相同的重名行被误伤多删）
        if (linesToDelete.HasKey(A_LoopField)) {
            linesToDelete.Delete(A_LoopField)
            continue
        }
        newContent .= A_LoopField . "`n"
    }

    ; 清理末尾多余空行并覆写文件
    newContent := RegExReplace(newContent, "`n$")
    FileDelete, %cfgPath%
    FileAppend, %newContent%, %cfgPath%, UTF-8

    ToolTip, % "成功删除 " delCount " 个动作并清理了相关缓存文件！"
    SetTimer, RemoveToolTip, -2000

    ; 退出模式并刷新界面
    isHoverPanelEditMode := false
    HoverPanelSelectedItems := {}
    LoadHoverItems()
    ; ▼▼▼ 修改：强制重建 ▼▼▼
    RenderHoverPanel(CurrentHoverGroup, true)
return

; ==============================================================================
; 新增：处理悬停面板的鼠标移动事件（用于触发工具提示）
; ==============================================================================
WM_MOUSEMOVE(wParam, lParam, msg, hwnd) {
    global HoverPanel_ShowTooltip, HoverPanel_TooltipDelay
    global CurrentTooltipControl, HoverTooltipLastCtrl
    global HoverItemsData, HoverPanel_EnableHoverHighlight ; 引入高亮开关全局变量

    ; 如果提示和高亮都没开，直接拦截节省性能
    if (HoverPanel_ShowTooltip != "1" && HoverPanel_EnableHoverHighlight != "1")
        return

    ; 只处理悬停面板界面的鼠标移动
    if (A_Gui = "HoverPanel") {
        ; 【防抖设计】：只有当鼠标跨越到不同的控件时，才执行代码
        if (A_GuiControl != HoverTooltipLastCtrl) {
            HoverTooltipLastCtrl := A_GuiControl
            ToolTip ; 鼠标换了控件，立即清除旧提示
            SetTimer, ShowHoverTooltip, Off ; 取消待执行的定时器

            ; 判断当前鼠标是否在动作项上 (通过正则匹配控件的 vLabel)
            if RegExMatch(A_GuiControl, "^HP(Pic|Ico|Item)_(\d+)$", match) {
                CurrentTooltipControl := match2 ; 记录被悬停的项目索引
                itemIdx := match2

                ; ▼▼▼ 移动底层高亮色块并显示 ▼▼▼
                if (HoverPanel_EnableHoverHighlight = "1") {
                    hX := HoverItemsData[itemIdx].RenderX
                    hY := HoverItemsData[itemIdx].RenderY
                    if (hX != "" && hY != "") {
                        GuiControl, HoverPanel: Move, HPHighlight, % "x" hX " y" hY
                        GuiControl, HoverPanel: Show, HPHighlight

                        ; 强制重绘顶层的文字和图标，彻底清除抗锯齿产生的透明黑边残影
                        GuiControl, HoverPanel: MoveDraw, HPPic_%itemIdx%
                        GuiControl, HoverPanel: MoveDraw, HPIco_%itemIdx%
                        GuiControl, HoverPanel: MoveDraw, HPItem_%itemIdx%
                    }
                }

                ; 启动一次性负数定时器
                SetTimer, ShowHoverTooltip, % "-" . HoverPanel_TooltipDelay

            } else {
                CurrentTooltipControl := ""

                ; ▼▼▼ 鼠标离开动作项（或挪到空白处）时，隐藏高亮块 ▼▼▼
                if (HoverPanel_EnableHoverHighlight = "1") {
                    GuiControl, HoverPanel: Hide, HPHighlight
                }
            }
        }
    }
}

ShowHoverTooltip:
    global HoverItemsData
    if (CurrentTooltipControl != "" && HoverPanelVisible) {
        item := HoverItemsData[CurrentTooltipControl]
        if (item) {
            ; 解析动作类型以便更直观地阅读
            typeDesc := ""
            if (item.Type = "1")
                typeDesc := "1-运行程序/打开文件夹"
            else if (item.Type = "2")
                typeDesc := "2-发送按键"
            else if (item.Type = "3")
                typeDesc := "3-发送文本"
            else if (item.Type = "4")
                typeDesc := "4-调用RunAny"
            else if (item.Type = "5")
                typeDesc := "5-内部命令"
            else if (item.Type = "6")
                typeDesc := "6-执行AHK代码"
            else
                typeDesc := item.Type

            ; 拼装多行提示文本
            tipText := "名称: " item.Text "`n"
                . "类型: " typeDesc "`n"
                . "参数: " item.Param "`n"
                . "备注: " item.Remark

            ToolTip, %tipText%
        }
    }
return

IDropTarget_QueryInterface(this, riid, ppvObj) {
    NumPut(this, ppvObj+0, "Ptr")
    return 0 ; S_OK
}
IDropTarget_AddRef(this) {
    return 1
}
IDropTarget_Release(this) {
    return 0
}
IDropTarget_DragEnter(this, pDataObj, grfKeyState, p4, p5, p6="") {
    global hBall, HoverPanel_Enable, HoverPanelVisible, isHoverPanelPinned
    pdwEffect := (A_PtrSize == 8) ? p5 : p6
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1

    ; ▼▼▼ 新增：拖拽文件/文本进入时，自动展开悬停面板 ▼▼▼
    if (HoverPanel_Enable = "1" && !HoverPanelVisible && !isHoverPanelPinned) {
        MouseGetPos,,, dragHwnd
        if (dragHwnd = hBall) {
            SetTimer, ShowHoverPanelGUI, -10 ; 异步触发防卡顿
        }
    }
    ; ▲▲▲ ================================================= ▲▲▲
    return 0
}

IDropTarget_DragOver(this, grfKeyState, p3, p4, p5="") {
    global hBall, HoverPanel_Enable, HoverPanelVisible, isHoverPanelPinned
    pdwEffect := (A_PtrSize == 8) ? p4 : p5
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1

    ; ▼▼▼ 新增：在悬浮球上持续拖拽游走时，也确保面板保持展开 ▼▼▼
    if (HoverPanel_Enable = "1" && !HoverPanelVisible && !isHoverPanelPinned) {
        MouseGetPos,,, dragHwnd
        if (dragHwnd = hBall) {
            SetTimer, ShowHoverPanelGUI, -10
        }
    }
    ; ▲▲▲ ================================================= ▲▲▲
    return 0
}
IDropTarget_DragLeave(this) {
    return 0
}
IDropTarget_Drop(this, pDataObj, grfKeyState, p4, p5, p6="") {
    pdwEffect := (A_PtrSize == 8) ? p5 : p6
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1

    ; ▼▼▼ 新增：获取当前释放鼠标时所在的窗口句柄 ▼▼▼
    MouseGetPos,,, dropHwnd

    ; 核心：解析释放时的 IDataObject 内存数据
    ParseDataObject(pDataObj, dropHwnd)
    return 0
}

; =================================================================
; 数据解析核心：支持区分主悬浮球和悬停面板，并深度解析浏览器原生标题
; =================================================================
ParseDataObject(pDataObj, dropHwnd:="") {
    global hBall, hHoverPanel
    IDataObject_GetData := NumGet(NumGet(pDataObj+0, "Ptr") + 3*A_PtrSize, "Ptr")

    ; --- 1. 尝试获取 FileGroupDescriptorW (提取浏览器拖拽的原生网页标题) ---
    cf_fgd := DllCall("RegisterClipboardFormat", "Str", "FileGroupDescriptorW")
    VarSetCapacity(FMT_FGD, A_PtrSize == 8 ? 32 : 20, 0)
    NumPut(cf_fgd, FMT_FGD, 0, "UShort")
    NumPut(1, FMT_FGD, A_PtrSize == 8 ? 16 : 8, "UInt")   ; DVASPECT_CONTENT
    NumPut(-1, FMT_FGD, A_PtrSize == 8 ? 20 : 12, "Int")  ; lindex
    NumPut(1, FMT_FGD, A_PtrSize == 8 ? 24 : 16, "UInt")  ; TYMED_HGLOBAL
    VarSetCapacity(STG_FGD, A_PtrSize == 8 ? 24 : 12, 0)

    pageTitle := ""
    if (DllCall(IDataObject_GetData, "Ptr", pDataObj, "Ptr", &FMT_FGD, "Ptr", &STG_FGD) = 0) {
        hGlobal := NumGet(STG_FGD, A_PtrSize == 8 ? 8 : 4, "Ptr")
        pData := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
        ; 核心解包：FILEDESCRIPTORW 结构中，文件名固定在偏移 76 字节处
        pageTitle := StrGet(pData + 76, "UTF-16")
        pageTitle := RegExReplace(pageTitle, "(?i)\.url$", "") ; 去除结尾的 .url 后缀
        DllCall("GlobalUnlock", "Ptr", hGlobal)
        DllCall("ole32\ReleaseStgMedium", "Ptr", &STG_FGD)
    }

    ; --- 2. 尝试读取 文本/网址 (CF_UNICODETEXT = 13) ---
    VarSetCapacity(FORMATETC, A_PtrSize == 8 ? 32 : 20, 0)
    NumPut(13, FORMATETC, 0, "UShort")
    NumPut(1, FORMATETC, A_PtrSize == 8 ? 16 : 8, "UInt")
    NumPut(-1, FORMATETC, A_PtrSize == 8 ? 20 : 12, "Int")
    NumPut(1, FORMATETC, A_PtrSize == 8 ? 24 : 16, "UInt")
    VarSetCapacity(STGMEDIUM, A_PtrSize == 8 ? 24 : 12, 0)

    if (DllCall(IDataObject_GetData, "Ptr", pDataObj, "Ptr", &FORMATETC, "Ptr", &STGMEDIUM) = 0) {
        hGlobal := NumGet(STGMEDIUM, A_PtrSize == 8 ? 8 : 4, "Ptr")
        pData := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
        droppedText := StrGet(pData, "UTF-16")
        DllCall("GlobalUnlock", "Ptr", hGlobal)
        DllCall("ole32\ReleaseStgMedium", "Ptr", &STGMEDIUM)

        ; ▼ 分发逻辑 ▼
        if (dropHwnd = hHoverPanel)
            HoverPanelAddFromDrop(droppedText, "Text", pageTitle) ; <--- 将原生提取到的标题传进去
        else
            OnDropText(droppedText)
        return
    }

    ; --- 3. 尝试读取 文件/文件夹 (CF_HDROP = 15) ---
    NumPut(15, FORMATETC, 0, "UShort")
    VarSetCapacity(STGMEDIUM, A_PtrSize == 8 ? 24 : 12, 0)
    if (DllCall(IDataObject_GetData, "Ptr", pDataObj, "Ptr", &FORMATETC, "Ptr", &STGMEDIUM) = 0) {
        hGlobal := NumGet(STGMEDIUM, A_PtrSize == 8 ? 8 : 4, "Ptr")
        fileCount := DllCall("shell32\DragQueryFileW", "Ptr", hGlobal, "UInt", 0xFFFFFFFF, "Ptr", 0, "UInt", 0)
        droppedFiles := ""
        Loop, % fileCount {
            len := DllCall("shell32\DragQueryFileW", "Ptr", hGlobal, "UInt", A_Index-1, "Ptr", 0, "UInt", 0)
            VarSetCapacity(filePath, (len + 1) * 2, 0)
            DllCall("shell32\DragQueryFileW", "Ptr", hGlobal, "UInt", A_Index-1, "Str", filePath, "UInt", len + 1)
            droppedFiles .= filePath . "`n"
        }
        droppedFiles := RTrim(droppedFiles, "`n")
        DllCall("ole32\ReleaseStgMedium", "Ptr", &STGMEDIUM)

        ; ▼ 分发逻辑 ▼
        if (dropHwnd = hHoverPanel)
            HoverPanelAddFromDrop(droppedFiles, "File")
        else
            OnDropFiles(droppedFiles)
        return
    }
}

; ==============================================================================
; 监听悬停面板大小改变事件，实现内部控件自适应排版与圆角更新
; ==============================================================================
HoverPanelGuiSize:
    if (A_EventInfo = 1) ; 窗口最小化时不处理
        return

    NewPanelW := A_GuiWidth
    NewPanelH := A_GuiHeight

    ; 1. 实时更新圆角裁剪区域
    DPIScale := A_ScreenDPI / 96
    SetWindowRgn(hHoverPanel, Round(NewPanelW * DPIScale), Round(NewPanelH * DPIScale), Round(15 * DPIScale))

    ; 2. 更新顶部栏各按钮位置 (靠右对齐)
    GuiControl, Move, HP_Edit_Del, % "x" (NewPanelW - 90)
    GuiControl, Move, HP_Edit_Cancel, % "x" (NewPanelW - 45)
    GuiControl, Move, HP_Norm_Close, % "x" (NewPanelW - 32)
    GuiControl, Move, HP_PinBtn, % "x" (NewPanelW - 55)
    GuiControl, Move, HP_DragBar1, % "w" (NewPanelW - 120)
    GuiControl, Move, HP_DragBar2, % "w" (NewPanelW - 60)

    ; 更新右下角拖拽缩放手柄的位置 (扣除变大后的 24 像素)
    GuiControl, Move, HP_ResizeGrip, % "x" (NewPanelW - 24) " y" (NewPanelH - 24)

    ; 3. 更新分组标签栏 (取消自动换行)
    btnX := HoverPanel_Margin
    btnY := 26 ; <--- 同步改为 26
    for idx, grp in HoverGroups {
        GuiControlGet, pos, Pos, HPGrp_%idx%
        if (posW > 0) {
            ; ▼▼▼ 删除了原来的 宽度越界换行 判定 ▼▼▼
            GuiControl, Move, HPGrp_%idx%, x%btnX% y%btnY%
            btnX += posW + HoverPanel_Margin
        }
    }

    ; 4. 更新分割线与空提示
    LineY := btnY + 20  ; <--- 同步改为 20
    StartY := LineY + 6 ; <--- 同步改为 6
    GuiControl, Move, HP_Line, % "y" LineY " w" (NewPanelW - 24)
    GuiControl, Move, HPEmptyText, % "y" StartY " w" (NewPanelW - 24)

    ; 4. 更新分割线与空提示
    LineY := btnY + 26
    StartY := LineY + 12
    GuiControl, Move, HP_Line, % "y" LineY " w" (NewPanelW - 24)
    GuiControl, Move, HPEmptyText, % "y" StartY " w" (NewPanelW - 24)

    ; 5. 更新所有动作项目 (网格瀑布流排版)
    ; 修改前: AvailableWidth := NewPanelW - 24
    AvailableWidth := NewPanelW - (HoverPanel_Margin * 2)
    Cols := Floor(AvailableWidth / HoverPanel_ItemWidth)
    if (Cols < 1)
        Cols := 1

    ItemCount := 0
    for idx, item in HoverItemsData {
        if (item.Group = CurrentHoverGroup) {
            CurRow := Floor(ItemCount / Cols)
            CurCol := Mod(ItemCount, Cols)
            ; 修改前: curX := 12 + (CurCol * HoverPanel_ItemWidth)
            curX := HoverPanel_Margin + (CurCol * HoverPanel_ItemWidth)
            curY := StartY + (CurRow * HoverPanel_ItemHeight)

            item.RenderX := curX
            item.RenderY := curY

            textW := HoverPanel_ItemWidth - HoverPanel_IconSize - 8
            textX := curX + HoverPanel_IconSize + 8
            textY := curY + (HoverPanel_IconSize/2) - (HoverPanel_FontSize/2) + HoverPanel_TextOffsetY

            ; 瞬间重置位置
            GuiControl, Move, HPPic_%idx%, x%curX% y%curY%
            GuiControl, Move, HPIco_%idx%, x%curX% y%curY%
            GuiControl, Move, HPItem_%idx%, x%textX% y%textY% w%textW%

            if (HoverPanel_EnableHoverHighlight = "1" && CurrentTooltipControl = idx)
                GuiControl, HoverPanel: Move, HPHighlight, % "x" curX " y" curY

            ItemCount++
        }
    }

    ; 6. 更新全局变量，设置防抖定时器保存配置 (延迟800毫秒防止高频写盘)
    HoverPanel_Width := NewPanelW
    HoverPanel_GUIHeight := NewPanelH
    SetTimer, SaveHoverPanelSize, -800
return

; ==============================================================================
; 右下角拖拽缩放逻辑 (带动态最小高度限制)
; ==============================================================================
HoverPanelResize:
    CoordMode, Mouse, Screen
    MouseGetPos, startMX, startMY
    WinGetPos, winX, winY, winW, winH, ahk_id %hHoverPanel%

    DPIScale := A_ScreenDPI / 96

    While GetKeyState("LButton", "P") {
        MouseGetPos, curMX, curMY
        deltaX := curMX - startMX
        deltaY := curMY - startMY

        PhysicalNewW := winW + deltaX
        PhysicalNewH := winH + deltaY

        ; === 修改开始：动态计算最小宽度，使其紧贴单列菜单项 ===
        ; 计算单列所需的最窄逻辑宽度：单个项目宽度 + 两侧的全局边缘间距
        MinLogicalW := HoverPanel_ItemWidth + (HoverPanel_Margin * 2)

        ; 兜底防错：为顶部按钮（关闭、图钉等）保留一个视觉底线，防止 UI 重叠
        if (MinLogicalW < 150)
            MinLogicalW := 150

        MinPhysicalW := Round(MinLogicalW * DPIScale)

        ; 限制绝对最小物理宽度（替代原有的固定 220）
        if (PhysicalNewW < MinPhysicalW)
            PhysicalNewW := MinPhysicalW
        ; === 修改结束 ===

        ; === 核心：实时模拟计算当前宽度下，所有内容排布所需的最小高度 ===
        LogicalW := PhysicalNewW / DPIScale

        ; 1. 模拟计算顶部“分组标签栏” 不换行 后的实际高度
        btnX := HoverPanel_Margin
        btnY := 26 ; <--- 同步改为 26
        for idx, grp in HoverGroups {
            GuiControlGet, pos, Pos, HPGrp_%idx%
            if (posW > 0) {
                ; ▼▼▼ 删除了换行高度累加计算 ▼▼▼
                btnX += posW + HoverPanel_Margin
            }
        }
        StartY := btnY + 26 ; <--- 【修改】20+6=26，原为 38

        ; 2. 模拟计算“动作项目”网格瀑布流所需的行数
        ; 修改前: AvailableWidth := LogicalW - 24
        AvailableWidth := LogicalW - (HoverPanel_Margin * 2)
        Cols := Floor(AvailableWidth / HoverPanel_ItemWidth)
        if (Cols < 1)
            Cols := 1

        ItemCount := 0
        for idx, item in HoverItemsData {
            if (item.Group = CurrentHoverGroup)
                ItemCount++
        }

        ; 3. 算出逻辑最小高度
        if (ItemCount = 0) {
            MinRequiredH := StartY + 40
        } else {
            TotalRows := Floor((ItemCount - 1) / Cols) + 1
            MinRequiredH := StartY + (TotalRows * HoverPanel_ItemHeight)
        }
        MinRequiredH += 15 ; 底部边缘留白

        ; 将逻辑高度转换为物理像素高度
        PhysicalReqH := MinRequiredH * DPIScale

        ; === 碰撞拦截：如果鼠标往上拖的高度小于所需最小高度，则强制锁死底边 ===
        if (PhysicalNewH < PhysicalReqH)
            PhysicalNewH := PhysicalReqH

        ; WinMove 实时调整大小，AHK 自动触发 HoverPanelGuiSize 完成平滑重排
        WinMove, ahk_id %hHoverPanel%,,,, %PhysicalNewW%, %PhysicalNewH%
        Sleep, 15
    }
return

SaveHoverPanelSize:
    Var_Set(HoverPanel_Width, "330", "Width", "悬停面板", A_ScriptDir "\Settings.ini")
    Var_Set(HoverPanel_GUIHeight, "300", "GUIHeight", "悬停面板", A_ScriptDir "\Settings.ini")
return

; ==============================================================================
; 新增：深浅主题与自定义配色核心加载引擎
; ==============================================================================
LoadThemeConfig:
    ThemeMode := Var_Read("ThemeMode", "Dark", "主题配置", A_ScriptDir "\Settings.ini", "否")

    if (ThemeMode = "Light") {
        G_BgColor := Var_Read("Light_BgColor", "F3F3F3", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_FontColor := Var_Read("Light_FontColor", "000000", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_SubFontColor := Var_Read("Light_SubFontColor", "555555", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BgARGB := Var_Read("Light_BgARGB", "0xFFF3F3F3", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BorderARGB := Var_Read("Light_BorderARGB", "0xFFCCCCCC", "主题配置", A_ScriptDir "\Settings.ini", "否")

        ; 覆写悬停面板配色
        HoverPanel_BgColor := Var_Read("Light_HoverPanelBg", "E9E9E9", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_FontColor := Var_Read("Light_HoverPanelFont", "000000", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_HoverBgColor := Var_Read("Light_HoverPanelHighlight", "E0E0E0", "主题配置", A_ScriptDir "\Settings.ini", "否")
    } else if (ThemeMode = "Custom") {
        G_BgColor := Var_Read("Custom_BgColor", "2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_FontColor := Var_Read("Custom_FontColor", "FFFFFF", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_SubFontColor := Var_Read("Custom_SubFontColor", "AAAAAA", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BgARGB := Var_Read("Custom_BgARGB", "0xFF2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BorderARGB := Var_Read("Custom_BorderARGB", "0xFF3D3D3D", "主题配置", A_ScriptDir "\Settings.ini", "否")

        HoverPanel_BgColor := Var_Read("Custom_HoverPanelBg", "2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_FontColor := Var_Read("Custom_HoverPanelFont", "FFFFFF", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_HoverBgColor := Var_Read("Custom_HoverPanelHighlight", "404040", "主题配置", A_ScriptDir "\Settings.ini", "否")
    } else { ; 默认深色 Dark
        G_BgColor := Var_Read("Dark_BgColor", "2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_FontColor := Var_Read("Dark_FontColor", "FFFFFF", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_SubFontColor := Var_Read("Dark_SubFontColor", "AAAAAA", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BgARGB := Var_Read("Dark_BgARGB", "0xFF2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        G_BorderARGB := Var_Read("Dark_BorderARGB", "0xFF3D3D3D", "主题配置", A_ScriptDir "\Settings.ini", "否")

        HoverPanel_BgColor := Var_Read("Dark_HoverPanelBg", "2B2B2B", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_FontColor := Var_Read("Dark_HoverPanelFont", "FFFFFF", "主题配置", A_ScriptDir "\Settings.ini", "否")
        HoverPanel_HoverBgColor := Var_Read("Dark_HoverPanelHighlight", "404040", "主题配置", A_ScriptDir "\Settings.ini", "否")
    }
return

ToggleThemeMode:
    ThemeMode := (ThemeMode = "Dark") ? "Light" : "Dark"
    Var_Set(ThemeMode, "Dark", "ThemeMode", "主题配置", A_ScriptDir "\Settings.ini")
    GoSub, LoadThemeConfig

    ; 立即刷新悬停面板与正在打开的工具栏
    if (HoverPanelVisible)
        RenderHoverPanel(CurrentHoverGroup, true)

    ToolTip, % "🎨 主题已切换为: " (ThemeMode = "Dark" ? "深色" : "浅色") "，部分设置界面需重新打开生效。"
    SetTimer, RemoveToolTip, -2000
return

; ==============================================================================
; 悬停面板数据转义与还原函数 (解决 | 与换行符冲突)
; ==============================================================================
EscapeHoverData(str) {
    str := StrReplace(str, "`r`n", "[CRLF]")
    str := StrReplace(str, "`n", "[CRLF]")
    str := StrReplace(str, "|", "[PIPE]")
    return str
}

UnescapeHoverData(str) {
    str := StrReplace(str, "[CRLF]", "`n")
    str := StrReplace(str, "[PIPE]", "|")
    return str
}

; ==============================================================================
; 新增：获取实时网络流量速度 (已过滤虚拟网卡与本地环回，杜绝翻倍)
; ==============================================================================
; ==============================================================================
; 新增：获取实时网络流量速度 (加入专业级虚拟网卡黑名单过滤，精准对标火绒)
; ==============================================================================
; ==============================================================================
; 新增：获取实时网络流量速度 (终极防翻倍版：独立计算，只取最高值)
; ==============================================================================
UpdateNetworkSpeed() {
    global NetRxSpeed, NetTxSpeed
    static lastStats := {}  ; 使用对象独立记录【每一张】网卡的上次数据
    static lastTick := 0

    DllCall("Iphlpapi.dll\GetIfTable", "Ptr", 0, "UIntP", size, "Int", 0)
    VarSetCapacity(buf, size, 0)
    if DllCall("Iphlpapi.dll\GetIfTable", "Ptr", &buf, "UIntP", size, "Int", 0)
        return

    entries := NumGet(buf, 0, "UInt")
    offset := 4

    currentTick := A_TickCount
    timeDiff := (lastTick > 0) ? (currentTick - lastTick) / 1000.0 : 0

    maxRxSpeed := 0
    maxTxSpeed := 0

    Loop % entries {
        idx := NumGet(buf, offset + 512, "UInt")          ; 获取网卡的唯一 ID
        dwType := NumGet(buf, offset + 516, "UInt")       ; 网卡类型
        dwOperStatus := NumGet(buf, offset + 544, "UInt") ; 工作状态

        ; 仅统计处于工作状态 (5) 且绝对不是本地环回测试 (24) 的网卡
        if (dwOperStatus == 5 && dwType != 24) {
            rx := NumGet(buf, offset + 552, "UInt")
            tx := NumGet(buf, offset + 576, "UInt")

            if (timeDiff > 0 && lastStats.HasKey(idx)) {
                lastRx := lastStats[idx].rx
                lastTx := lastStats[idx].tx

                ; 处理 32 位无符号整数溢出翻转
                diffRx := (rx < lastRx) ? (rx + 4294967296 - lastRx) : (rx - lastRx)
                diffTx := (tx < lastTx) ? (tx + 4294967296 - lastTx) : (tx - lastTx)

                curRxSpeed := diffRx / timeDiff
                curTxSpeed := diffTx / timeDiff

                ; 🔥 核心精髓：抛弃无脑相加！只保留所有网卡中跑得最快的那一个速度！
                if (curRxSpeed > maxRxSpeed)
                    maxRxSpeed := curRxSpeed
                if (curTxSpeed > maxTxSpeed)
                    maxTxSpeed := curTxSpeed
            }

            ; 独立更新当前这张网卡的记录
            lastStats[idx] := {rx: rx, tx: tx}
        }
        offset += 860
    }

    if (timeDiff > 0) {
        NetRxSpeed := FormatNetworkBytes(maxRxSpeed)
        NetTxSpeed := FormatNetworkBytes(maxTxSpeed)
    } else {
        NetRxSpeed := "0 B/s"
        NetTxSpeed := "0 B/s"
    }

    lastTick := currentTick
}
; ==============================================================================
; 智能网速格式化：最多显示 3 位数字（如 9.5, 99.9, 105）
; ==============================================================================
FormatNetworkBytes(bytes) {
    if (bytes >= 1048576) {
        val := bytes / 1048576.0
        unit := " MB/s"
    } else if (bytes >= 1024) {
        val := bytes / 1024.0
        unit := " KB/s"
    } else {
        return Round(bytes) " B/s"
    }

    ; 动态控制小数位数：
    ; 如果达到或超过 99.5 (四舍五入后是100)，就不保留小数，显示 100 ~ 999
    if (val >= 99.5)
        return Round(val) . unit
    ; 如果小于 99.5，则保留 1 位小数，显示 0.0 ~ 99.4
    else
        return Format("{:.1f}", val) . unit
}