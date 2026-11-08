;======================================================================================
; XY Modern UI Kit  ·  XiaoYao_快速跳转 现代界面引擎
;--------------------------------------------------------------------------------------
; AHK v1.1 Unicode / 纯 GDI 自绘，不依赖任何第三方 DLL、不依赖外部字体或图片资源。
;
; 设计目标：
;   1) 完全抛弃原生 ListView（含丑陋的系统滚动条），改用「离屏位图 + 虚拟列表」绘制；
;   2) 自绘标签栏、搜索框边框、两行式列表项、极细滚动条、无边框窗口标题栏；
;   3) 所有交互（点击/双击/悬停/滚轮/拖动/缩放/右键）统一由窗口消息命中测试完成；
;   4) 只负责「显示与交互」，业务数据仍由 常驻跟随窗口_现代.ahk 提供。
;
; 对外接口（由宿主脚本调用）：
;   MUI_初始化(窗口句柄, 画布句柄, 编辑框句柄, 宽, 高)
;   MUI_主题(是否深色, 自定义背景, 自定义文字, 强调色)
;   MUI_添加标签(显示文本, 回调标签名)
;   MUI_消息注册()
;   MUI_设置列表(竖杠分隔的字符串, 分隔符)
;   MUI_取路径(行号) / MUI_选中路径() / MUI_选择行(行号)
;   MUI_滚动(行数) / MUI_标签滚动(像素) / MUI_重绘()
;   MUI_尺寸变化(宽, 高) / MUI_鼠标在窗口内() / MUI_鼠标在标签区()
;   MUI_销毁()
;
; 宿主需要提供的全局变量：Gui_winID、搜索框ID、当前视图标签、文件夹名显示在前
; 宿主需要提供的标签（回调）：各视图标签、更多功能设置、GuiClose、打开跳转事件
;======================================================================================

;--------------------------------------------------------------------------------------
; 状态与主题
;--------------------------------------------------------------------------------------
MUI_初始化(窗口句柄, 画布句柄, 编辑框句柄, 初始宽, 初始高) {
    global MUI, MUI_T
    MUI := {}
    MUI.窗口 := 窗口句柄
    MUI.画布 := 画布句柄
    MUI.搜索框 := 编辑框句柄
    MUI.子类化回调 := ""
    MUI.原窗口过程 := ""
    MUI.宽 := 初始宽
    MUI.高 := 初始高

    ; 画布是 SS_BITMAP 的 Static 控件，每次换位图（滚动、悬停、缩放都会换）它都会
    ; 整块重画自己的客户区。搜索框是它的「同层兄弟窗口」，默认没有 WS_CLIPSIBLINGS 时
    ; Static 重画不会避让兄弟窗口，直接把搜索框那块糊成画布底色——表现出来就是
    ; 「搜索框里的文字时不时消失」。加上这个标志后，Static 会自动把自己被上层兄弟
    ; 窗口（搜索框）挡住的部分裁掉，不再盖过去。
    if (画布句柄) {
        if (A_PtrSize = 8)
            窗口样式 := DllCall("user32\GetWindowLongPtrW", "Ptr", 画布句柄, "Int", -16, "Ptr")
        else
            窗口样式 := DllCall("user32\GetWindowLongW", "Ptr", 画布句柄, "Int", -16, "Int")
        if !(窗口样式 & 0x04000000) {
            if (A_PtrSize = 8)
                DllCall("user32\SetWindowLongPtrW", "Ptr", 画布句柄, "Int", -16, "Ptr", 窗口样式 | 0x04000000, "Ptr")
            else
                DllCall("user32\SetWindowLongW", "Ptr", 画布句柄, "Int", -16, "Int", 窗口样式 | 0x04000000)
        }
    }

    ; 搜索框必须压在画布「上面」。
    ; 画布是先 Add 的 Static，它在兄弟窗口的 Z 序里排在更靠前（更上层）的位置：
    ; 鼠标点击能穿透到下面的 Edit（SS_BITMAP 不接收鼠标），但画布绘制时会盖住
    ; Edit 自己画的东西，包括选中文字的蓝底和闪烁的插入光标——用户看到的现象就是
    ; 「能拖但看不出选中了什么、右键也没反应」。把 Edit 显式提到最顶层，
    ; 画布沉到它下面，之后画布怎么重绘都碰不到搜索框。
    if (编辑框句柄) {
        MUI_搜索框置顶()
        MUI_搜索框子类化()
    }

    MUI.名称 := []
    MUI.路径 := []
    MUI.数量 := 0
    MUI.选中行 := 0
    MUI.顶部行 := 1
    MUI.可见行数 := 1

    MUI.标签 := []
    MUI.标签总宽 := 0
    MUI.标签滚动 := 0
    MUI.布局 := {}

    MUI.悬停标识 := ""
    MUI.悬停行 := 0
    MUI.悬停标签 := 0
    MUI.悬停按钮 := ""
    MUI.右键行 := 0
    MUI.提示行 := 0

    MUI.行高 := 40
    MUI.单行 := 0              ; 1 = 每个条目只画一行（「目录名在前」关闭时）
    MUI.用户行距 := 20         ; 个人配置里的「窗口文本行距」，只作为行高微调量
    MUI.字体 := "Microsoft YaHei UI"
    MUI.字号 := 10
    MUI.标签字号 := 9          ; 标签栏单独字号，比列表小一号才装得下全部按钮
    MUI.路径字号 := 9
    MUI.标题字号 := 11
    MUI.说明字号 := 9
    MUI.缩放 := ((A_ScreenDPI != "" and A_ScreenDPI > 0) ? A_ScreenDPI : 96) / 72
    MUI.边距 := 6              ; 可拖动缩放的边缘宽度
    MUI._AA图形 := 0           ; 1 = 当前处于几何绘制阶段
    MUI._AA倍率 := 3           ; 超采样倍率，3x 足够平滑且开销可接受
    MUI._AA实际倍率 := 3
    MUI._AADC := 0             ; 超采样离屏 DC
    MUI._AA位图 := 0
    MUI._AA主DC := 0
    MUI._AA旧位图 := 0
    MUI.显示标题栏 := 1
    MUI.悬停提示 := 1
    MUI.提示延迟 := 300
    MUI.单击跳转 := 0

    MUI.拖动模式 := ""
    MUI.拖动偏移X := 0
    MUI.拖动偏移Y := 0
    MUI.缩放方向名 := ""
    MUI.缩放起点X := 0
    MUI.缩放起点Y := 0
    MUI.缩放窗X := 0
    MUI.缩放窗Y := 0
    MUI.缩放窗W := 0
    MUI.缩放窗H := 0
    MUI.滚动条拇指高 := 30
    MUI.上次点击时间 := 0
    MUI.上次点击行 := 0
    MUI.待执行标签 := ""
    ; 这里必须是「标签名字符串」：SetTimer 命令行传 Func 对象会被判为非法参数
    MUI.提示函数 := "MUI_显示提示"
    MUI.就绪 := 0

    MUI_T := {}
    MUI_主题(0)
    MUI_布局计算()
    MUI.就绪 := 1
}

MUI_主题(是否深色, 自定义背景 := "", 自定义文字 := "", 强调色 := "") {
    global MUI_T
    if (是否深色) {
        MUI_T := {"背景":"1E2128", "表面":"262B34", "选中":"2C3654", "悬停":"2A2F39"
            , "文字":"E7EAF0", "次要":"8B94A5", "强调":"7C93FF", "柔化":"35406B"
            , "边框":"333946", "滚动":"4A5262", "滚动亮":"74809A", "页脚":"7B8494"
            , "空白":"666E7C", "图标":"465173"}
    } Else {
        MUI_T := {"背景":"F7F8FA", "表面":"FFFFFF", "选中":"E9EEFF", "悬停":"EFF1F6"
            , "文字":"1F2329", "次要":"8A94A6", "强调":"4F6BFF", "柔化":"DCE4FF"
            , "边框":"E5E8EF", "滚动":"C6CDDB", "滚动亮":"8E9AB3", "页脚":"9BA3B2"
            , "空白":"A8B0BE", "图标":"C3CDEA"}
    }
    if (强调色 := MUI_规范化颜色(强调色))
        MUI_T.强调 := 强调色
    if (自定义背景 := MUI_规范化颜色(自定义背景))
        MUI_T.背景 := 自定义背景
    if (自定义文字 := MUI_规范化颜色(自定义文字))
        MUI_T.文字 := 自定义文字
}

MUI_规范化颜色(值) {
    值 := StrReplace(Trim(值), "#", "")
    if (SubStr(值, 1, 2) = "0x")
        值 := SubStr(值, 3)
    if RegExMatch(值, "i)^[0-9A-F]{6}$")
        return 值
    return ""
}

MUI_添加标签(显示文本, 回调标签) {
    global MUI
    if (显示文本 = "")
        显示文本 := "·"
    标签宽 := MUI_标签宽度(显示文本)
    MUI.标签.Push({"文本":显示文本, "回调":回调标签, "宽":标签宽, "起点":MUI.标签总宽})
    MUI.标签总宽 += 标签宽 + 1
}

; 标签宽度：按真实字形测量 + 紧凑内边距，保证 360 宽窗口也能排下全部按钮
MUI_标签宽度(文本) {
    global MUI
    宽 := MUI_测量文本宽(文本, MUI.标签字号) + 12
    if (宽 < 30)
        宽 := 30
    if (宽 > 120)
        宽 := 120
    return 宽
}

; 字号体系：以列表主字号为基准派生其它层级，任何配置下层级关系都稳定，
; 不会出现「路径比标题还大」「标签挤成小字糊一团」这类比例失衡。
MUI_派生字号() {
    global MUI
    主 := MUI.字号
    if (主 = "" or 主 = "ERROR" or !(主 is number) or 主 < 8)
        主 := 10
    if (主 > 16)
        主 := 16
    MUI.字号 := 主
    ; 主字号本身就不大时不再往下缩小：8pt 在 96DPI 下只有 11px，ClearType 会发糊
    MUI.路径字号 := (主 > 10) ? 主 - 1 : 主
    MUI.标签字号 := (主 > 11) ? 主 - 1 : 主
    MUI.标题字号 := 主 + 1
    MUI.说明字号 := (主 > 10) ? 主 - 1 : 主
}

; 显示模式：跟随设置里的「目录名在前」（配置文件键名 文件夹名显示在前）
;   开启 → 两行：第一行文件夹名，第二行完整路径
;   关闭 → 一行：只显示完整路径（经典界面此时也只用一列「完整路径」）
; 关闭后如果还按两行画，第二行画的是完整路径，与第一行完全相同，
; 于是同一行文字上下重复两遍——这就是「两行重复内容」的根因。
MUI_单行模式() {
    global 文件夹名显示在前
    return (文件夹名显示在前 = "开启") ? 0 : 1
}

; 行高：单行 / 双行分别按真实字高计算，只留必要的呼吸位。
; 旧公式 名称高 + 路径高 + 8 + 10 是按两行算的，9pt 下高达 56px，
; 360 高的窗口里只放得下 3 条；单行模式按一行字高算，约 25px。
MUI_推荐行高(用户行距 := "", 单行 := 0) {
    global MUI
    基础 := 20
    if (用户行距 != "" and 用户行距 != "ERROR" and 用户行距 is number) {
        基础 := Round(用户行距)
        if (基础 < 12)
            基础 := 12
        if (基础 > 40)
            基础 := 40
    }
    ; 「窗口文本行距」不再直接乘 2 当行高，只做微调：每多 2px 行距，行高多 1px
    微调 := Round((基础 - 20) / 2)
    ; 上下限一律由字高推导，而不是写死像素：高 DPI 下字体整体变大，
    ; 写死的 22~34 会把行高卡死，文字上下会被切掉。
    if (单行) {
        名称高 := MUI_文字行高(MUI.字号, 400)
        行高 := 名称高 + 6 + 微调
        if (行高 < 名称高 + 3)
            行高 := 名称高 + 3
        if (行高 > 名称高 + 16)
            行高 := 名称高 + 16
    } Else {
        名称高 := MUI_文字行高(MUI.字号, 700)
        路径高 := MUI_文字行高(MUI.路径字号)
        行高 := 名称高 + 路径高 + 4 + 微调
        if (行高 < 名称高 + 路径高 + 2)
            行高 := 名称高 + 路径高 + 2
        if (行高 > 名称高 + 路径高 + 16)
            行高 := 名称高 + 路径高 + 16
    }
    return 行高
}

; 宿主设置完字号后调用：记住用户行距 → 判定显示模式 → 算出最终行高
MUI_设置行距(用户行距 := "") {
    global MUI
    MUI.用户行距 := 用户行距
    MUI.单行 := MUI_单行模式()
    MUI.行高 := MUI_推荐行高(用户行距, MUI.单行)
}

;--------------------------------------------------------------------------------------
; 字体：字号统一按 pt（磅）理解，按屏幕 DPI 换算成像素，避免小字号发虚
;--------------------------------------------------------------------------------------
MUI_创建字体(字号, 粗细 := 400) {
    global MUI
    像素高 := -Round(字号 * MUI.缩放)
    if (像素高 = 0)
        像素高 := -12
    return DllCall("gdi32\CreateFontW", "Int", 像素高, "Int", 0, "Int", 0, "Int", 0
        , "Int", 粗细, "UInt", 0, "UInt", 0, "UInt", 0, "UInt", 1, "UInt", 0, "UInt", 0
        , "UInt", 5, "UInt", 0, "Str", MUI.字体, "Ptr")   ; 5 = CLEARTYPE_QUALITY
}

MUI_测量文本宽(文本, 字号, 粗细 := 400) {
    global MUI
    static 缓存 := {}
    键 := MUI.字体 "|" 字号 "|" 粗细 "|" 文本
    if 缓存.HasKey(键)
        return 缓存[键]
    屏幕DC := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
    字体 := MUI_创建字体(字号, 粗细)
    if (字体 and 屏幕DC) {
        旧字体 := DllCall("gdi32\SelectObject", "Ptr", 屏幕DC, "Ptr", 字体, "Ptr")
        VarSetCapacity(尺寸, 8, 0)
        DllCall("gdi32\GetTextExtentPoint32W", "Ptr", 屏幕DC, "Str", 文本, "Int", StrLen(文本), "Ptr", &尺寸)
        宽 := NumGet(尺寸, 0, "Int")
        DllCall("gdi32\SelectObject", "Ptr", 屏幕DC, "Ptr", 旧字体, "Ptr")
        DllCall("gdi32\DeleteObject", "Ptr", 字体)
    } Else
        宽 := 0
    if (屏幕DC)
        DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", 屏幕DC)
    if (宽 < 1)
        宽 := StrLen(文本) * 8
    缓存[键] := 宽
    return 宽
}

;--------------------------------------------------------------------------------------
; 布局
;--------------------------------------------------------------------------------------
MUI_布局计算() {
    global MUI
    L := MUI.布局 := {}
    ; 各条带高度由真实字高推出：用户在设置里把字号调大时，标题栏/标签/搜索框
    ; 会一起变高，不会出现「字变大、控件还是老尺寸」的割裂感
    主行 := MUI_文字行高(MUI.字号, 700)
    次行 := MUI_文字行高(MUI.说明字号)
    L.头Y := 0
    L.头H := MUI.显示标题栏 ? (主行 + 22) : 0
    L.标签Y := MUI.显示标题栏 ? L.头H + 2 : 6
    L.标签H := 主行 + 12
    L.搜索Y := L.标签Y + L.标签H + 4
    L.搜索H := 主行 + 18
    L.搜索X := 12
    L.搜索W := MUI.宽 - 24
    L.段Y := L.搜索Y + L.搜索H + 4
    L.段H := 次行
    L.列表Y := L.段Y + L.段H + 2
    L.页脚H := 次行 + 8
    L.页脚Y := MUI.高 - L.页脚H
    L.列表X := 10
    L.列表W := MUI.宽 - 20
    L.列表H := MUI.高 - L.列表Y - L.页脚H
    if (L.列表H < MUI.行高)
        L.列表H := MUI.行高
    MUI.可见行数 := Floor(L.列表H / MUI.行高)
    if (MUI.可见行数 < 1)
        MUI.可见行数 := 1
    MUI_修正顶部行()
}

MUI_编辑框位置() {
    global MUI
    L := MUI.布局
    ; 原来左侧给放大镜留了 32px，图标去掉后这段空档没有意义，
    ; 只留 14 的圆角内缩，输入区整体左移并加宽
    return {"X":L.搜索X + 14, "Y":L.搜索Y + 3, "W":L.搜索W - 14 - 10, "H":L.搜索H - 6}
}

; 把搜索框提到所有兄弟窗口的最顶层（HWND_TOP = 0）。不移动、不改尺寸、不抢焦点：
; 0x13 = SWP_NOSIZE(0x1) | SWP_NOMOVE(0x2) | SWP_NOACTIVATE(0x10)
MUI_搜索框置顶() {
    global MUI
    if (!MUI.搜索框)
        return
    DllCall("user32\SetWindowPos", "Ptr", MUI.搜索框, "Ptr", 0
        , "Int", 0, "Int", 0, "Int", 0, "Int", 0, "UInt", 0x13)
}

MUI_尺寸变化(新宽, 新高) {
    global MUI, Gui_winID, 搜索框ID
    if (!MUI.就绪) or (新宽 < 100) or (新高 < 100)
        return
    MUI.宽 := 新宽
    MUI.高 := 新高
    GuiControl, MoveDraw, % MUI.画布, % "x0 y0 W" 新宽 " H" 新高
    P := MUI_编辑框位置()
    GuiControl, MoveDraw, %搜索框ID%, % "X" P.X " Y" P.Y " W" P.W " H" P.H
    ; MoveDraw 只改位置尺寸，正常不会动 Z 序；这里再压一次是防止某些系统上
    ; 控件重建后把 Static 又排回上层
    MUI_搜索框置顶()
    MUI_布局计算()
    MUI_应用圆角()
    MUI_重绘()
}

MUI_应用圆角() {
    global MUI, Gui_winID
    ; 圆角半径不宜过大：Region 会把圆角外区域裁掉，右下角的缩放热区会被削掉
    区域参数 := "0-0 W" MUI.宽 " H" MUI.高 " R7-7"
    WinSet, Region, %区域参数%, % "ahk_id " Gui_winID
}

MUI_添加阴影(窗口句柄) {
    ; CS_DROPSHADOW：给无标题栏窗口补一层系统阴影（不支持的系统会静默跳过）
    static 阴影样式 := 0x20000
    原样式 := DllCall("user32\GetClassLongPtrW", "Ptr", 窗口句柄, "Int", -26, "Ptr")
    if (原样式)
        DllCall("user32\SetClassLongPtrW", "Ptr", 窗口句柄, "Int", -26, "Ptr", 原样式 | 阴影样式, "Ptr")
}

MUI_销毁() {
    global MUI
    if (!IsObject(MUI))
        return
    ; 先把搜索框的窗口过程还原，再让窗口销毁，避免回调挂在已释放的窗口上
    if (MUI.搜索框 and MUI.原窗口过程 and MUI.子类化回调) {
        if (A_PtrSize = 8)
            DllCall("user32\SetWindowLongPtrW", "Ptr", MUI.搜索框, "Int", -4, "Ptr", MUI.原窗口过程, "Ptr")
        else
            DllCall("user32\SetWindowLongW", "Ptr", MUI.搜索框, "Int", -4, "Int", MUI.原窗口过程, "Int")
    }
    DllCall("user32\ReleaseCapture")
    if (MUI.提示函数 != "")
        SetTimer, % MUI.提示函数, Off
    ToolTip
    MUI.就绪 := 0
}

;--------------------------------------------------------------------------------------
; 数据（替代原 ListView 的 LV_Add / LV_GetText）
;--------------------------------------------------------------------------------------
MUI_设置列表(内容, 分隔符 := "|") {
    global MUI, 文件夹名显示在前
    ; 每次重填列表都同步一次显示模式：运行中改了「目录名在前」也能立刻生效，
    ; 不需要重启脚本；模式变化时行高要跟着重算，可见行数才会同步变化。
    新单行 := MUI_单行模式()
    if (新单行 != MUI.单行) {
        MUI.单行 := 新单行
        MUI.行高 := MUI_推荐行高(MUI.用户行距, MUI.单行)
        MUI_布局计算()
    }
    MUI.名称 := []
    MUI.路径 := []
    MUI.数量 := 0
    Loop, Parse, 内容, %分隔符%
    {
        if RegExMatch(A_LoopField, "^\s*$")
            Continue
        真实路径 := A_LoopField
        自定义名称 := ""
        if (分隔符位置 := InStr(真实路径, "?")) {
            自定义名称 := SubStr(真实路径, 分隔符位置 + 1)
            真实路径 := SubStr(真实路径, 1, 分隔符位置 - 1)
        }
        if (文件夹名显示在前 = "开启") {
            if (自定义名称 != "")
                显示名 := 自定义名称
            Else {
                SplitPath, 真实路径, 显示名
                if (显示名 = "")
                    显示名 := 真实路径
            }
        } Else
            显示名 := 真实路径
        MUI.数量++
        MUI.名称[MUI.数量] := 显示名
        MUI.路径[MUI.数量] := 真实路径
    }
    MUI.选中行 := 0
    MUI.顶部行 := 1
    MUI.悬停行 := 0
    MUI_修正顶部行()
    MUI_重绘()
}

MUI_取显示名(行号) {
    global MUI
    if (行号 >= 1 and 行号 <= MUI.数量)
        return MUI.名称[行号]
    return ""
}

MUI_取路径(行号) {
    global MUI
    if (行号 >= 1 and 行号 <= MUI.数量)
        return MUI.路径[行号]
    return ""
}

MUI_选中路径() {
    global MUI
    return MUI_取路径(MUI.选中行)
}

MUI_修正顶部行() {
    global MUI
    最大顶部 := MUI.数量 - MUI.可见行数 + 1
    if (最大顶部 < 1)
        最大顶部 := 1
    if (MUI.顶部行 < 1)
        MUI.顶部行 := 1
    if (MUI.顶部行 > 最大顶部)
        MUI.顶部行 := 最大顶部
}

MUI_设置顶部(值) {
    global MUI
    MUI.顶部行 := 值
    MUI_修正顶部行()
}

MUI_确保选中可见() {
    global MUI
    if (MUI.选中行 < 1)
        return
    if (MUI.选中行 < MUI.顶部行)
        MUI_设置顶部(MUI.选中行)
    Else if (MUI.选中行 >= MUI.顶部行 + MUI.可见行数)
        MUI_设置顶部(MUI.选中行 - MUI.可见行数 + 1)
}

MUI_选择行(行号) {
    global MUI
    if (MUI.数量 < 1)
        return
    if (行号 < 1)
        行号 := 1
    if (行号 > MUI.数量)
        行号 := MUI.数量
    MUI.选中行 := 行号
    MUI_确保选中可见()
    MUI_重绘()
}

MUI_滚动(行数) {
    global MUI
    MUI_设置顶部(MUI.顶部行 + 行数)
    MUI_重绘()
}

MUI_标签滚动(像素) {
    global MUI
    最大 := MUI.标签总宽 - (MUI.宽 - 24)
    if (最大 < 0)
        最大 := 0
    MUI.标签滚动 += 像素
    if (MUI.标签滚动 < 0)
        MUI.标签滚动 := 0
    if (MUI.标签滚动 > 最大)
        MUI.标签滚动 := 最大
    MUI_重绘()
}

MUI_确保标签可见() {
    global MUI, 当前视图标签
    可视宽 := MUI.宽 - 24
    for 序号, 标签项 in MUI.标签 {
        if (标签项.回调 = 当前视图标签) {
            左 := 标签项.起点 - MUI.标签滚动
            右 := 左 + 标签项.宽
            if (左 < 0)
                MUI.标签滚动 := 标签项.起点 - 6
            Else if (右 > 可视宽)
                MUI.标签滚动 := 标签项.起点 + 标签项.宽 - 可视宽 + 6
            if (MUI.标签滚动 < 0)
                MUI.标签滚动 := 0
            Break
        }
    }
}

;--------------------------------------------------------------------------------------
; GDI 超采样抗锯齿层
;   GDI 自带的 RoundRect / Ellipse 没有抗锯齿，圆角方块、文件夹图标放大看全是硬阶梯。
;   这里把几何图形画到 3 倍尺寸的离屏位图上，再用 HALFTONE 缩回原尺寸，
;   等价于 3x3 超采样抗锯齿，边缘平滑度接近 GDI+，但全程只用 GDI。
;
;   为什么不用 GDI+：Graphics 一旦绑定这个 DC，同一 DC 上的 GDI 文字会完全画不出来
;   （不报错、不输出、整片消失）；而 GDI+ 自己画文字只有灰度抗锯齿，会发虚。
;   超采样只处理几何，文字仍由 GDI + ClearType 画在主位图上，两者互不干扰。
;--------------------------------------------------------------------------------------
MUI_AA开始(hdc) {
    global MUI, MUI_T
    MUI._AADC := 0
    MUI._AA位图 := 0
    倍 := MUI._AA倍率
    ; 大窗口降到 2x：离屏位图从 9 倍降到 4 倍面积，缩放开销明显下降，
    ; 而 2x 对圆角、图标的平滑度提升已经足够肉眼分辨
    if (MUI.宽 * MUI.高 > 180000 and 倍 > 2)
        倍 := 2
    if (倍 < 2)
        倍 := 3
    宽 := MUI.宽 * 倍
    高 := MUI.高 * 倍
    dc := DllCall("gdi32\CreateCompatibleDC", "Ptr", hdc, "Ptr")
    位图 := DllCall("gdi32\CreateCompatibleBitmap", "Ptr", hdc, "Int", 宽, "Int", 高, "Ptr")
    if (!dc or !位图) {
        if (dc)
            DllCall("gdi32\DeleteDC", "Ptr", dc)
        if (位图)
            DllCall("gdi32\DeleteObject", "Ptr", 位图)
        return 0
    }
    旧位图 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 位图, "Ptr")
    ; 逻辑坐标 → 设备坐标放大 N 倍：后面所有绘制照旧用原坐标
    DllCall("gdi32\SetMapMode", "Ptr", dc, "Int", 8)                 ; MM_ANISOTROPIC
    DllCall("gdi32\SetWindowExtEx", "Ptr", dc, "Int", 1, "Int", 1, "Ptr", 0)
    DllCall("gdi32\SetViewportExtEx", "Ptr", dc, "Int", 倍, "Int", 倍, "Ptr", 0)
    DllCall("gdi32\SetBkMode", "Ptr", dc, "Int", 1)
    ; 先铺一层窗口底色，否则没画到的区域缩小后会留黑边
    画刷 := DllCall("gdi32\CreateSolidBrush", "UInt", MUI_G_BGR(MUI_T.背景), "Ptr")
    VarSetCapacity(底色区, 16, 0)
    NumPut(0, 底色区, 0, "Int")
    NumPut(0, 底色区, 4, "Int")
    NumPut(MUI.宽, 底色区, 8, "Int")
    NumPut(MUI.高, 底色区, 12, "Int")
    DllCall("user32\FillRect", "Ptr", dc, "Ptr", &底色区, "Ptr", 画刷)
    DllCall("gdi32\DeleteObject", "Ptr", 画刷)

    MUI._AA主DC := hdc
    MUI._AADC := dc
    MUI._AA位图 := 位图
    MUI._AA旧位图 := 旧位图
    MUI._AA实际倍率 := 倍
    MUI._AA图形 := 1
    return 1
}

MUI_AA结束() {
    global MUI
    if (!MUI._AADC)
        return
    倍 := MUI._AA实际倍率
    DllCall("gdi32\SetMapMode", "Ptr", MUI._AADC, "Int", 1)          ; 复位成 MM_TEXT
    ; 注意顺序：位图必须还选在这个 DC 里的时候做 StretchBlt，
    ; 先 SelectObject 回旧位图的话，源就变成 1x1 默认位图，整层内容会凭空消失。
    DllCall("gdi32\SetStretchBltMode", "Ptr", MUI._AA主DC, "Int", 4) ; HALFTONE
    VarSetCapacity(旧原点, 8, 0)
    DllCall("gdi32\SetBrushOrgEx", "Ptr", MUI._AA主DC, "Int", 0, "Int", 0, "Ptr", &旧原点)
    DllCall("gdi32\StretchBlt", "Ptr", MUI._AA主DC, "Int", 0, "Int", 0, "Int", MUI.宽, "Int", MUI.高
        , "Ptr", MUI._AADC, "Int", 0, "Int", 0, "Int", MUI.宽 * 倍, "Int", MUI.高 * 倍, "UInt", 0x00CC0020)
    DllCall("gdi32\SetStretchBltMode", "Ptr", MUI._AA主DC, "Int", 0)
    DllCall("gdi32\SelectObject", "Ptr", MUI._AADC, "Ptr", MUI._AA旧位图, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", MUI._AA位图)
    DllCall("gdi32\DeleteDC", "Ptr", MUI._AADC)
    MUI._AADC := 0
    MUI._AA位图 := 0
    MUI._AA图形 := 0
}

MUI_G_AA线(x1, y1, x2, y2, 线宽, 色值) {
    global MUI
    目标 := MUI._AADC ? MUI._AADC : MUI._AA主DC
    if (!目标)
        return 0
    笔宽 := Round(线宽)
    if (笔宽 < 1)
        笔宽 := 1
    画笔 := DllCall("gdi32\CreatePen", "Int", 0, "Int", 笔宽, "UInt", MUI_G_BGR(色值), "Ptr")
    旧笔 := DllCall("gdi32\SelectObject", "Ptr", 目标, "Ptr", 画笔, "Ptr")
    DllCall("gdi32\MoveToEx", "Ptr", 目标, "Int", Round(x1), "Int", Round(y1), "Ptr", 0)
    DllCall("gdi32\LineTo", "Ptr", 目标, "Int", Round(x2), "Int", Round(y2))
    DllCall("gdi32\SelectObject", "Ptr", 目标, "Ptr", 旧笔, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", 画笔)
    return 1
}

;--------------------------------------------------------------------------------------
; GDI 基础绘制
;--------------------------------------------------------------------------------------
MUI_G_BGR(色值) {
    r := "0x" SubStr(色值, 1, 2)
    g := "0x" SubStr(色值, 3, 2)
    b := "0x" SubStr(色值, 5, 2)
    return (b << 16) | (g << 8) | r
}

MUI_G_矩形(dc, px, py, pw, ph, 色值) {
    VarSetCapacity(区域, 16, 0)
    NumPut(px, 区域, 0, "Int")
    NumPut(py, 区域, 4, "Int")
    NumPut(px + pw, 区域, 8, "Int")
    NumPut(py + ph, 区域, 12, "Int")
    画刷 := DllCall("gdi32\CreateSolidBrush", "UInt", MUI_G_BGR(色值), "Ptr")
    DllCall("user32\FillRect", "Ptr", dc, "Ptr", &区域, "Ptr", 画刷)
    DllCall("gdi32\DeleteObject", "Ptr", 画刷)
}

MUI_G_圆角(dc, px, py, pw, ph, 半径, 色值) {
    global MUI
    if (pw <= 0 or ph <= 0)
        return
    ; 几何一律画到 3 倍超采样位图上，缩小后天然带抗锯齿
    if (MUI._AADC)
        dc := MUI._AADC
    颜色 := MUI_G_BGR(色值)
    画刷 := DllCall("gdi32\CreateSolidBrush", "UInt", 颜色, "Ptr")
    画笔 := DllCall("gdi32\CreatePen", "Int", 5, "Int", 0, "UInt", 颜色, "Ptr")
    旧刷 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 画刷, "Ptr")
    旧笔 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 画笔, "Ptr")
    DllCall("gdi32\RoundRect", "Ptr", dc, "Int", px, "Int", py, "Int", px + pw, "Int", py + ph, "Int", 半径 * 2, "Int", 半径 * 2)
    DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 旧刷, "Ptr")
    DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 旧笔, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", 画刷)
    DllCall("gdi32\DeleteObject", "Ptr", 画笔)
}

; 圆角描边（1px 边框）：同样画进超采样层，圆角处不会有硬阶梯
MUI_G_圆角边框(dc, px, py, pw, ph, 半径, 线宽, 色值) {
    global MUI
    if (MUI._AADC)
        dc := MUI._AADC
    颜色 := MUI_G_BGR(色值)
    画笔 := DllCall("gdi32\CreatePen", "Int", 0, "Int", 线宽, "UInt", 颜色, "Ptr")
    空刷 := DllCall("gdi32\GetStockObject", "Int", 5, "Ptr")   ; NULL_BRUSH
    旧刷 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 空刷, "Ptr")
    旧笔 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 画笔, "Ptr")
    DllCall("gdi32\RoundRect", "Ptr", dc, "Int", px, "Int", py, "Int", px + pw, "Int", py + ph, "Int", 半径 * 2, "Int", 半径 * 2)
    DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 旧刷, "Ptr")
    DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 旧笔, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", 画笔)
}

; 字体度量：字号按 pt 传入，这里换算出真实字高与上沿高度，
; 用于把文字在任意高低的矩形里「精确」垂直居中（DrawText 的 DT_VCENTER 会把
; tmExternalLeading 也算进去，多行/多字号并排时容易出现 1~2px 的错位）。
MUI_文字度量(字号, 粗细 := 400) {
    global MUI
    static 缓存 := {}
    键 := MUI.字体 "|" 字号 "|" 粗细 "|" Round(MUI.缩放 * 100)
    if 缓存.HasKey(键)
        return 缓存[键]
    结果 := {"高":Round(字号 * MUI.缩放), "上沿":Round(字号 * MUI.缩放 * 0.75)}
    屏幕DC := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
    字体 := MUI_创建字体(字号, 粗细)
    if (字体 and 屏幕DC) {
        旧字体 := DllCall("gdi32\SelectObject", "Ptr", 屏幕DC, "Ptr", 字体, "Ptr")
        VarSetCapacity(度量, 60, 0)
        if (DllCall("gdi32\GetTextMetricsW", "Ptr", 屏幕DC, "Ptr", &度量)) {
            高 := NumGet(度量, 0, "Int")      ; tmHeight
            上沿 := NumGet(度量, 4, "Int")    ; tmAscent
            if (高 > 0)
                结果 := {"高":高, "上沿":上沿}
        }
        DllCall("gdi32\SelectObject", "Ptr", 屏幕DC, "Ptr", 旧字体, "Ptr")
        DllCall("gdi32\DeleteObject", "Ptr", 字体)
    }
    if (屏幕DC)
        DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", 屏幕DC)
    缓存[键] := 结果
    return 结果
}

; 一行文字所需的高度（含上下各 1px 余量），布局计算时用它来排行距
MUI_文字行高(字号, 粗细 := 400) {
    度量 := MUI_文字度量(字号, 粗细)
    return 度量.高 + 2
}

; 省略 := 0x8000(DT_END_ELLIPSIS，默认截尾部) / 0x4000(DT_PATH_ELLIPSIS，按 \ 截中间)
MUI_G_文字(dc, px, py, pw, ph, 文本, 色值, 字号, 粗细 := 400, 对齐 := 0, 省略 := 0x8000) {
    global MUI
    if (pw <= 0 or ph <= 0)
        return
    字体 := MUI_创建字体(字号, 粗细)
    if (!字体)
        return
    度量 := MUI_文字度量(字号, 粗细)
    文字Y := py + Floor((ph - 度量.高) / 2)
    旧字体 := DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 字体, "Ptr")
    DllCall("gdi32\SetBkMode", "Ptr", dc, "Int", 1)
    DllCall("gdi32\SetTextColor", "Ptr", dc, "UInt", MUI_G_BGR(色值))
    VarSetCapacity(区域, 16, 0)
    NumPut(px, 区域, 0, "Int")
    NumPut(文字Y, 区域, 4, "Int")
    NumPut(px + pw, 区域, 8, "Int")
    NumPut(py + ph, 区域, 12, "Int")
    标志 := 0x0 | 0x20 | 0x800 | 省略 | 对齐      ; 顶部对齐 / 单行 / 不解析& / 省略号方式
    DllCall("user32\DrawTextW", "Ptr", dc, "Str", 文本, "Int", -1, "Ptr", &区域, "UInt", 标志)
    DllCall("gdi32\SelectObject", "Ptr", dc, "Ptr", 旧字体, "Ptr")
    DllCall("gdi32\DeleteObject", "Ptr", 字体)
}

MUI_G_裁剪(dc, px, py, pw, ph) {
    global MUI
    ; Region 用的是设备坐标，画在 3 倍位图上就要乘 3
    目标 := MUI._AADC ? MUI._AADC : dc
    倍 := MUI._AADC ? MUI._AA倍率 : 1
    区域 := DllCall("gdi32\CreateRectRgn", "Int", px * 倍, "Int", py * 倍, "Int", (px + pw) * 倍, "Int", (py + ph) * 倍, "Ptr")
    DllCall("gdi32\SelectClipRgn", "Ptr", 目标, "Ptr", 区域)
    DllCall("gdi32\DeleteObject", "Ptr", 区域)
}

MUI_G_取消裁剪(dc) {
    global MUI
    目标 := MUI._AADC ? MUI._AADC : dc
    DllCall("gdi32\SelectClipRgn", "Ptr", 目标, "Ptr", 0)
}

;--------------------------------------------------------------------------------------
; 主绘制
;--------------------------------------------------------------------------------------
MUI_重绘() {
    global MUI, MUI_T, Gui_winID
    if (!MUI.就绪) or (!MUI.画布) or !WinExist("ahk_id " Gui_winID)
        return
    if (MUI.宽 < 60 or MUI.高 < 60)
        return
    MUI_确保标签可见()
    屏幕DC := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
    内存DC := DllCall("gdi32\CreateCompatibleDC", "Ptr", 屏幕DC, "Ptr")
    位图 := DllCall("gdi32\CreateCompatibleBitmap", "Ptr", 屏幕DC, "Int", MUI.宽, "Int", MUI.高, "Ptr")
    if (!位图) {
        DllCall("gdi32\DeleteDC", "Ptr", 内存DC)
        DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", 屏幕DC)
        return
    }
    旧位图 := DllCall("gdi32\SelectObject", "Ptr", 内存DC, "Ptr", 位图, "Ptr")

    MUI_G_矩形(内存DC, 0, 0, MUI.宽, MUI.高, MUI_T.背景)
    ; 第一遍：几何（画在 3 倍位图上再缩小，等效抗锯齿）
    MUI_AA开始(内存DC)
    MUI_绘制几何(内存DC)
    MUI_AA结束()
    ; 第二遍：文字（1:1 主位图 + GDI ClearType，保证清晰锐利）
    MUI_绘制文字(内存DC)

    DllCall("gdi32\SelectObject", "Ptr", 内存DC, "Ptr", 旧位图, "Ptr")
    旧句柄 := DllCall("user32\SendMessage", "Ptr", MUI.画布, "UInt", 0x172, "Ptr", 0, "Ptr", 位图, "Ptr")
    if (旧句柄)
        DllCall("gdi32\DeleteObject", "Ptr", 旧句柄)
    DllCall("gdi32\DeleteDC", "Ptr", 内存DC)
    DllCall("user32\ReleaseDC", "Ptr", 0, "Ptr", 屏幕DC)

    ; 换完位图立刻把搜索框同步重画一次。
    ; WS_CLIPSIBLINGS 已经能防止画布盖住搜索框，但 Static 贴图那一帧和搜索框重画
    ; 之间仍可能有一瞬间的重叠（不同系统上表现不同），补这一下就彻底看不到闪空了。
    if (MUI.搜索框)
        DllCall("user32\RedrawWindow", "Ptr", MUI.搜索框, "Ptr", 0, "Ptr", 0, "UInt", 0x0001|0x0100|0x0080)
}

;--------------------------------------------------------------------------------------
; 绘制分两遍，顺序不能合并
;   第一遍只画几何（3 倍超采样，缩小后自然带抗锯齿）；
;   第二遍只画文字（1:1 主位图 + ClearType）。
; 分开是为了让文字始终落在原始分辨率上：若把文字也画进超采样层，缩小后笔画会被糊掉。
;--------------------------------------------------------------------------------------
MUI_绘制几何(dc) {
    global MUI
    MUI_绘制标题栏几何(dc)
    MUI_绘制标签栏几何(dc)
    MUI_绘制搜索框几何(dc)
    MUI_绘制列表几何(dc)
    MUI_绘制页脚几何(dc)
    MUI_绘制缩放手柄(dc)
}

MUI_绘制文字(dc) {
    MUI_绘制标题栏文字(dc)
    MUI_绘制标签栏文字(dc)
    MUI_绘制区段标题(dc)
    MUI_绘制列表文字(dc)
    MUI_绘制页脚文字(dc)
}

;------------------------------ 标题栏 ------------------------------
MUI_绘制标题栏几何(dc) {
    global MUI, MUI_T
    if (!MUI.显示标题栏)
        return
    L := MUI.布局
    图标Y := L.头Y + Floor((L.头H - 24) / 2)
    MUI_G_圆角(dc, 12, 图标Y, 24, 24, 7, MUI_T.强调)
    按钮Y := L.头Y + Floor((L.头H - 24) / 2)
    if (MUI.悬停按钮 = "更多")
        MUI_G_圆角(dc, MUI.宽 - 62, 按钮Y, 24, 24, 6, MUI_T.悬停)
    if (MUI.悬停按钮 = "关闭")
        MUI_G_圆角(dc, MUI.宽 - 34, 按钮Y, 24, 24, 6, MUI_T.悬停)
}

MUI_绘制标题栏文字(dc) {
    global MUI, MUI_T
    if (!MUI.显示标题栏)
        return
    L := MUI.布局
    图标Y := L.头Y + Floor((L.头H - 24) / 2)
    MUI_G_文字(dc, 12, 图标Y, 24, 24, "⇥", "FFFFFF", MUI.标题字号, 700, 1)

    ; 主标题 + 副标题作为一整块在标题栏内垂直居中，两块之间固定间距
    主高 := MUI_文字行高(MUI.标题字号, 700)
    副字号 := MUI.说明字号 - 1
    if (副字号 < 7)
        副字号 := 7
    副高 := MUI_文字行高(副字号)
    块高 := 主高 + 副高 + 1
    块Y := L.头Y + Floor((L.头H - 块高) / 2)
    文字宽 := MUI.宽 - 76 - 74
    if (文字宽 < 40)
        文字宽 := 40
    MUI_G_文字(dc, 44, 块Y, 文字宽, 主高, "快速跳转", MUI_T.文字, MUI.标题字号, 700)
    MUI_G_文字(dc, 44, 块Y + 主高 + 1, 文字宽, 副高, "XiaoYao QuickJump · Modern", MUI_T.次要, 副字号)

    按钮Y := L.头Y + Floor((L.头H - 24) / 2)
    MUI_G_文字(dc, MUI.宽 - 62, 按钮Y, 24, 24, "⋯", MUI_T.次要, MUI.标题字号, 400, 1)
    MUI_G_文字(dc, MUI.宽 - 34, 按钮Y, 24, 24, "×", MUI_T.次要, MUI.标题字号, 400, 1)
}

;------------------------------ 标签栏 ------------------------------
MUI_绘制标签栏几何(dc) {
    global MUI, MUI_T, 当前视图标签
    L := MUI.布局
    MUI_G_矩形(dc, 0, L.标签Y + L.标签H - 1, MUI.宽, 1, MUI_T.边框)
    胶囊高 := L.标签H - 5
    胶囊Y := L.标签Y + 1
    MUI_G_裁剪(dc, 12, L.标签Y, MUI.宽 - 24, L.标签H)
    for 序号, 标签项 in MUI.标签 {
        起点 := 12 + 标签项.起点 - MUI.标签滚动
        if (起点 + 标签项.宽 < 0) or (起点 > MUI.宽)
            Continue
        if (标签项.回调 = 当前视图标签) {
            MUI_G_圆角(dc, 起点 + 1, 胶囊Y, 标签项.宽 - 2, 胶囊高, 6, MUI_T.柔化)
            ; 活动标签底部的高亮小条
            MUI_G_圆角(dc, 起点 + 8, L.标签Y + L.标签H - 3, 标签项.宽 - 16, 2, 1, MUI_T.强调)
        } Else if (MUI.悬停标签 = 序号) {
            MUI_G_圆角(dc, 起点 + 1, 胶囊Y, 标签项.宽 - 2, 胶囊高, 6, MUI_T.悬停)
        }
    }
    MUI_G_取消裁剪(dc)
}

MUI_绘制标签栏文字(dc) {
    global MUI, MUI_T, 当前视图标签
    L := MUI.布局
    文字框H := L.标签H - 3
    MUI_G_裁剪(dc, 12, L.标签Y, MUI.宽 - 24, L.标签H)
    for 序号, 标签项 in MUI.标签 {
        起点 := 12 + 标签项.起点 - MUI.标签滚动
        if (起点 + 标签项.宽 < 0) or (起点 > MUI.宽)
            Continue
        是活动 := (标签项.回调 = 当前视图标签)
        是悬停 := (MUI.悬停标签 = 序号)
        文字色 := 是活动 ? MUI_T.强调 : (是悬停 ? MUI_T.文字 : MUI_T.次要)
        MUI_G_文字(dc, 起点, L.标签Y, 标签项.宽, 文字框H, 标签项.文本, 文字色, MUI.标签字号, 是活动 ? 700 : 400, 1)
    }
    MUI_G_取消裁剪(dc)
    ; 标签放不下时给左右滚动提示箭头
    if (MUI.标签总宽 > MUI.宽 - 24) {
        if (MUI.标签滚动 > 0) {
            MUI_G_矩形(dc, 0, L.标签Y, 14, L.标签H, MUI_T.背景)
            MUI_G_文字(dc, 0, L.标签Y, 13, L.标签H, "‹", MUI_T.次要, MUI.标题字号, 700, 1)
        }
        最大滚动 := MUI.标签总宽 - (MUI.宽 - 24)
        if (MUI.标签滚动 < 最大滚动) {
            MUI_G_矩形(dc, MUI.宽 - 16, L.标签Y, 16, L.标签H, MUI_T.背景)
            MUI_G_文字(dc, MUI.宽 - 17, L.标签Y, 14, L.标签H, "›", MUI_T.次要, MUI.标题字号, 700, 1)
        }
    }
}

;------------------------------ 搜索框 ------------------------------
MUI_绘制搜索框几何(dc) {
    global MUI, MUI_T
    L := MUI.布局
    ; 先铺满，再描一圈 1px 边框：比「外圈填边框色 + 内嵌矩形」干净
    MUI_G_圆角(dc, L.搜索X, L.搜索Y, L.搜索W, L.搜索H, 9, MUI_T.表面)
    MUI_G_圆角边框(dc, L.搜索X + 0.5, L.搜索Y + 0.5, L.搜索W - 1, L.搜索H - 1, 9, 1, MUI_T.边框)
}
; 注：原来这里画过搜索框左侧的放大镜图标（MUI_绘制搜索框文字），已按需求删除，
; 输入框相应左移加宽，见 MUI_编辑框位置()。


;------------------------------ 区段标题 ------------------------------
MUI_绘制区段标题(dc) {
    global MUI, MUI_T, 当前视图标签
    L := MUI.布局
    标题 := 当前视图标签
    if (标题 = "")
        标题 := "路径列表"
    MUI_G_文字(dc, 14, L.段Y, MUI.宽 - 28, L.段H, 标题 "  ·  " MUI.数量 " 项", MUI_T.次要, MUI.说明字号)
}

;------------------------------ 列表 ------------------------------
MUI_绘制列表几何(dc) {
    global MUI, MUI_T
    L := MUI.布局
    if (MUI.数量 = 0)
        return
    MUI_G_裁剪(dc, L.列表X, L.列表Y, L.列表W, L.列表H)
    结束行 := MUI.顶部行 + MUI.可见行数
    if (结束行 > MUI.数量)
        结束行 := MUI.数量
    Loop, % 结束行 - MUI.顶部行 + 1
    {
        行号 := MUI.顶部行 + A_Index - 1
        行Y := L.列表Y + (A_Index - 1) * MUI.行高
        是选中 := (行号 = MUI.选中行)
        是悬停 := (行号 = MUI.悬停行 and !是选中)
        if (是选中)
            MUI_G_圆角(dc, L.列表X + 2, 行Y + 1, L.列表W - 4, MUI.行高 - 2, 7, MUI_T.选中)
        Else if (是悬停)
            MUI_G_圆角(dc, L.列表X + 2, 行Y + 1, L.列表W - 4, MUI.行高 - 2, 7, MUI_T.悬停)
        if (是选中) {
            ; 选中态左侧高亮条：高度按行高的 60% 取，行高收窄后不会被挤成一条缝
            条高 := Round(MUI.行高 * 0.6)
            MUI_G_圆角(dc, L.列表X + 2, 行Y + Floor((MUI.行高 - 条高) / 2), 3, 条高, 1.5, MUI_T.强调)
        }

        图标宽 := 16
        图标高 := 13
        图标X := L.列表X + 14
        图标Y := 行Y + Floor((MUI.行高 - 图标高) / 2)
        图标色 := 是选中 ? MUI_T.强调 : MUI_T.图标
        ; 文件夹：上方凸起 + 主体，两段都是圆角，超采样缩小后边缘平滑无阶梯
        MUI_G_圆角(dc, 图标X, 图标Y, 8, 6, 2, 图标色)
        MUI_G_圆角(dc, 图标X, 图标Y + 4, 图标宽, 图标高 - 4, 2.5, 图标色)
    }
    MUI_G_取消裁剪(dc)
    MUI_绘制滚动条(dc)
}

MUI_绘制列表文字(dc) {
    global MUI, MUI_T
    L := MUI.布局
    if (MUI.数量 = 0) {
        主行 := MUI_文字行高(MUI.字号)
        次行 := MUI_文字行高(MUI.说明字号)
        提示Y := L.列表Y + Floor((L.列表H - 主行 - 次行 - 2) / 2)
        MUI_G_文字(dc, 14, 提示Y, MUI.宽 - 28, 主行, "没有可显示的路径", MUI_T.空白, MUI.字号, 400, 1)
        MUI_G_文字(dc, 14, 提示Y + 主行 + 2, MUI.宽 - 28, 次行, "换个视图，或在上方输入关键字搜索", MUI_T.空白, MUI.说明字号, 400, 1)
        return
    }
    MUI_G_裁剪(dc, L.列表X, L.列表Y, L.列表W, L.列表H)
    结束行 := MUI.顶部行 + MUI.可见行数
    if (结束行 > MUI.数量)
        结束行 := MUI.数量
    Loop, % 结束行 - MUI.顶部行 + 1
    {
        行号 := MUI.顶部行 + A_Index - 1
        行Y := L.列表Y + (A_Index - 1) * MUI.行高
        是选中 := (行号 = MUI.选中行)
        主色 := 是选中 ? MUI_T.强调 : MUI_T.文字
        ; 两行作为一整块在行内垂直居中：换字号 / 换行高都不会一行贴顶一行贴底
        名称高 := MUI_文字行高(MUI.字号, 是选中 ? 700 : 400)
        路径高 := MUI_文字行高(MUI.路径字号)
        文字X := L.列表X + 42
        文字W := L.列表W - 42 - 14
        if (文字W < 20)
            文字W := 20
        ; 单行模式（「目录名在前」关闭）只画一行；双行模式里名称恰好等于路径时
        ; （如盘符根目录 D:\）也只画一行，避免同一段文字上下重复。
        if (MUI.单行 or MUI.名称[行号] = MUI.路径[行号]) {
            文字Y := 行Y + Floor((MUI.行高 - 名称高) / 2)
            ; 只有一行时宽度更紧张，省略号放在路径中间（保留盘符和最后一级目录名），
            ; 否则尾部省略会把最关键的文件夹名截掉，只剩一串上级路径。
            MUI_G_文字(dc, 文字X, 文字Y, 文字W, 名称高, MUI.名称[行号], 主色, MUI.字号, 是选中 ? 700 : 400, 0, 0x4000)
        } Else {
            块高 := 名称高 + 路径高 + 3
            块Y := 行Y + Floor((MUI.行高 - 块高) / 2)
            MUI_G_文字(dc, 文字X, 块Y, 文字W, 名称高, MUI.名称[行号], 主色, MUI.字号, 是选中 ? 700 : 400)
            MUI_G_文字(dc, 文字X, 块Y + 名称高 + 3, 文字W, 路径高, MUI.路径[行号], MUI_T.次要, MUI.路径字号)
        }
    }
    MUI_G_取消裁剪(dc)
}

MUI_绘制滚动条(dc) {
    global MUI, MUI_T
    L := MUI.布局
    if (MUI.数量 <= MUI.可见行数)
        return
    轨道高 := L.列表H - 8
    拇指高 := Round(轨道高 * MUI.可见行数 / MUI.数量)
    if (拇指高 < 28)
        拇指高 := 28
    if (拇指高 > 轨道高)
        拇指高 := 轨道高
    MUI.滚动条拇指高 := 拇指高
    最大顶部 := MUI.数量 - MUI.可见行数
    if (最大顶部 < 1)
        最大顶部 := 1
    拇指Y := L.列表Y + 4 + Round((轨道高 - 拇指高) * (MUI.顶部行 - 1) / 最大顶部)
    颜色 := (MUI.拖动模式 = "滚动条" or MUI.悬停按钮 = "滚动条") ? MUI_T.滚动亮 : MUI_T.滚动
    MUI_G_圆角(dc, MUI.宽 - 12, 拇指Y, 4, 拇指高, 2, 颜色)
}

;------------------------------ 页脚 ------------------------------
MUI_绘制页脚几何(dc) {
    global MUI, MUI_T
    L := MUI.布局
    MUI_G_矩形(dc, 0, L.页脚Y, MUI.宽, 1, MUI_T.边框)
}

MUI_绘制页脚文字(dc) {
    global MUI, MUI_T
    L := MUI.布局
    ; 右侧留出 16px 给缩放手柄提示，避免键位提示与抓握纹重叠
    MUI_G_文字(dc, 14, L.页脚Y + 1, MUI.宽 - 28 - 16, L.页脚H - 1
        , "↑↓ 选择    ↵ 跳转    Esc 关闭    右键更多", MUI_T.页脚, MUI.说明字号)
}

;------------------------------ 缩放手柄 ------------------------------
; 右下角的三道斜纹：告诉用户这里可以拖动改变大小。
; 四边四角都能拖（见 MUI_缩放方向），这个纹路只是可发现性提示。
MUI_绘制缩放手柄(dc) {
    global MUI, MUI_T
    提示色 := (MUI.悬停标识 = "缩放手柄") ? MUI_T.强调 : MUI_T.滚动亮
    右 := MUI.宽 - 5
    下 := MUI.高 - 5
    ; 线宽必须 ≥2：GDI 里 1px 宽的是「装饰笔」，永远只画 1 个设备像素，
    ; 不参与超采样放大，缩小后就成了点状虚线。2px 才能真正被平滑。
    ; 斜线间距取 6，保证缩到 1:1 后三条线之间还留得出空隙，不会糊成一团。
    for 序号, 长度 in [4, 10, 16] {
        MUI_G_AA线(右 - 长度, 下, 右, 下 - 长度, 2, 提示色)
    }
}

MUI_双击间隔() {
    ; 双击判定阈值跟随系统设置。写死 400 会把手慢的用户挡在外面。
    static 值 := 0
    if (!值) {
        值 := DllCall("user32\GetDoubleClickTime", "UInt")
        if (!值 or 值 < 200 or 值 > 1000)
            值 := 500
    }
    return 值
}

MUI_命中(px, py) {
    global MUI
    L := MUI.布局
    if (MUI.显示标题栏 and py >= 6 and py <= 32) {
        if (px >= MUI.宽 - 34 and px <= MUI.宽 - 10)
            return "关闭"
        if (px >= MUI.宽 - 62 and px <= MUI.宽 - 38)
            return "更多"
    }
    ; 四边 + 四角都能拖动缩放
    方向 := MUI_缩放方向(px, py)
    if (方向 != "")
        return "缩放" 方向
    ; 手柄内圈只用于悬停高亮（视觉提示）
    if (px >= MUI.宽 - 18 and py >= MUI.高 - 18)
        return "缩放手柄"
    if (MUI.显示标题栏 and py < L.标签Y and !(px >= MUI.宽 - 66))
        return "拖动"
    if (py >= L.标签Y and py < L.标签Y + L.标签H) {
        if (MUI.标签总宽 > MUI.宽 - 24 and px >= MUI.宽 - 18)
            return "标签右"
        if (MUI.标签滚动 > 0 and px <= 14)
            return "标签左"
        相对X := px - 12 + MUI.标签滚动
        for 序号, 标签项 in MUI.标签 {
            if (相对X >= 标签项.起点 and 相对X < 标签项.起点 + 标签项.宽)
                return "标签:" 序号
        }
        return "标签区"
    }
    if (py >= L.列表Y and py < L.列表Y + L.列表H) {
        if (px >= MUI.宽 - 18 and MUI.数量 > MUI.可见行数)
            return "滚动条"
        行号 := MUI.顶部行 + Floor((py - L.列表Y) / MUI.行高)
        if (行号 >= 1 and 行号 <= MUI.数量)
            return "行:" 行号
        return "列表空白"
    }
    return ""
}

MUI_鼠标在窗口内() {
    global Gui_winID, MUI
    if (!Gui_winID or !WinExist("ahk_id " Gui_winID))
        return false
    CoordMode, Mouse, Screen
    MouseGetPos, 鼠标X, 鼠标Y
    WinGetPos, 窗口X, 窗口Y, 窗口W, 窗口H, ahk_id %Gui_winID%
    return (鼠标X >= 窗口X and 鼠标X <= 窗口X + 窗口W and 鼠标Y >= 窗口Y and 鼠标Y <= 窗口Y + 窗口H)
}

MUI_鼠标在标签区() {
    global Gui_winID, MUI
    if (!MUI.就绪 or !MUI_鼠标在窗口内())
        return false
    CoordMode, Mouse, Screen
    MouseGetPos, 鼠标X, 鼠标Y
    WinGetPos, 窗口X, 窗口Y, , , ahk_id %Gui_winID%
    return (鼠标Y - 窗口Y >= MUI.布局.标签Y and 鼠标Y - 窗口Y < MUI.布局.标签Y + MUI.布局.标签H)
}

;--------------------------------------------------------------------------------------
; 窗口消息：鼠标移动 / 按下 / 抬起 / 右键
;--------------------------------------------------------------------------------------
MUI_消息注册() {
    OnMessage(0x200, "MUI_WM_MOUSEMOVE")
    OnMessage(0x201, "MUI_WM_LBUTTONDOWN")
    OnMessage(0x203, "MUI_WM_LBUTTONDBLCLK")
    OnMessage(0x202, "MUI_WM_LBUTTONUP")
    OnMessage(0x204, "MUI_WM_RBUTTONDOWN")
    OnMessage(0x20, "MUI_WM_SETCURSOR")        ; 各方向缩放 / 拖动用的鼠标指针
}

;--------------------------------------------------------------------------------------
; 八向缩放方向判定
;   四边各留 MUI.边距(6px)、四角留 10px 热区；命中返回 "左/右/上/下/左上/右上/左下/右下"。
;   这里是自己用 SetCapture 追踪鼠标实现的，而不是 WS_THICKFRAME + WM_NCHITTEST：
;   后者会给无边框窗口加一圈 7px 的真实边框，窗口外框与客户区不等，圆角 Region 会错位。
;--------------------------------------------------------------------------------------
MUI_缩放方向(px, py) {
    global MUI
    边 := MUI.边距
    角 := 边 + 4
    在左 := (px < 边)
    在右 := (px >= MUI.宽 - 边)
    在上 := (py < 边)
    在下 := (py >= MUI.高 - 边)
    ; 标题栏右上角是「更多 / 关闭」按钮，这段上边框让位给按钮；
    ; 但最外侧 10px 仍保留缩放，否则右上角就拖不动了
    if (在上 and px >= MUI.宽 - 70 and px < MUI.宽 - 10)
        在上 := 0
    ; 右上最外侧允许斜向缩放
    if (在右 and py < 角 and px >= MUI.宽 - 10)
        在上 := 1
    if (在上 and 在左)
        return "左上"
    if (在上 and 在右)
        return "右上"
    if (在下 and 在左)
        return "左下"
    if (在下 and 在右)
        return "右下"
    ; 四角热区比四边略宽，贴着角点也能斜向缩放
    if (px < 角 and py < 角)
        return "左上"
    if (px >= MUI.宽 - 10 and py < 角)
        return "右上"
    if (px < 角 and py >= MUI.高 - 角)
        return "左下"
    if (px >= MUI.宽 - 角 and py >= MUI.高 - 角)
        return "右下"
    if (在上)
        return "上"
    if (在下)
        return "下"
    if (在左)
        return "左"
    if (在右)
        return "右"
    return ""
}

MUI_缩放光标(方向) {
    ; 32642=IDC_SIZENWSE  32643=IDC_SIZENESW  32644=IDC_SIZEWE  32645=IDC_SIZENS  32646=IDC_SIZEALL
    if (方向 = "左" or 方向 = "右")
        return 32644
    if (方向 = "上" or 方向 = "下")
        return 32645
    if (方向 = "左上" or 方向 = "右下")
        return 32642
    if (方向 = "右上" or 方向 = "左下")
        return 32643
    return 0
}

MUI_光标(编号) {
    static 缓存 := {}
    if 缓存.HasKey(编号)
        return 缓存[编号]
    句柄 := DllCall("user32\LoadCursorW", "Ptr", 0, "Ptr", 编号, "Ptr")
    缓存[编号] := 句柄
    return 句柄
}

MUI_WM_SETCURSOR(w参数, l参数, 消息号, 句柄) {
    global MUI, Gui_winID
    if (!MUI.就绪 or 句柄 != Gui_winID)
        return
    CoordMode, Mouse, Screen
    MouseGetPos, 屏幕X, 屏幕Y
    WinGetPos, 窗口X, 窗口Y, , , ahk_id %Gui_winID%
    命中 := MUI_命中(屏幕X - 窗口X, 屏幕Y - 窗口Y)
    if (SubStr(命中, 1, 2) = "缩放") {
        光标号 := MUI_缩放光标(SubStr(命中, 3))
        if (光标号)
            DllCall("user32\SetCursor", "Ptr", MUI_光标(光标号))
        return 1
    }
    if (命中 = "缩放手柄") {
        DllCall("user32\SetCursor", "Ptr", MUI_光标(32642))   ; IDC_SIZENWSE
        return 1
    }
    if (命中 = "拖动") {
        DllCall("user32\SetCursor", "Ptr", MUI_光标(32646))   ; IDC_SIZEALL
        return 1
    }
}

MUI_WM_MOUSEMOVE(w参数, l参数, 消息号, 句柄) {
    global MUI, Gui_winID
    if (!MUI.就绪 or 句柄 != Gui_winID)
        return 0
    鼠标X := l参数 & 0xFFFF
    鼠标Y := (l参数 >> 16) & 0xFFFF
    if (MUI.拖动模式 = "拖动") {
        CoordMode, Mouse, Screen
        MouseGetPos, 绝对X, 绝对Y
        WinMove, ahk_id %Gui_winID%, , % 绝对X - MUI.拖动偏移X, % 绝对Y - MUI.拖动偏移Y
        return 0
    }
    if (MUI.拖动模式 = "缩放") {
        CoordMode, Mouse, Screen
        MouseGetPos, 绝对X, 绝对Y
        位移X := 绝对X - MUI.缩放起点X
        位移Y := 绝对Y - MUI.缩放起点Y
        新X := MUI.缩放窗X
        新Y := MUI.缩放窗Y
        新W := MUI.缩放窗W
        新高 := MUI.缩放窗H
        if InStr(MUI.缩放方向名, "左") {
            新W := MUI.缩放窗W - 位移X
            if (新W < 300) {
                新W := 300
                新X := MUI.缩放窗X + MUI.缩放窗W - 300
            } Else
                新X := MUI.缩放窗X + 位移X
        } Else if InStr(MUI.缩放方向名, "右")
            新W := MUI.缩放窗W + 位移X
        if InStr(MUI.缩放方向名, "上") {
            新高 := MUI.缩放窗H - 位移Y
            if (新高 < 240) {
                新高 := 240
                新Y := MUI.缩放窗Y + MUI.缩放窗H - 240
            } Else
                新Y := MUI.缩放窗Y + 位移Y
        } Else if InStr(MUI.缩放方向名, "下")
            新高 := MUI.缩放窗H + 位移Y
        if (新W < 300)
            新W := 300
        if (新高 < 240)
            新高 := 240
        WinMove, ahk_id %Gui_winID%, , %新X%, %新Y%, %新W%, %新高%
        return 0
    }
    if (MUI.拖动模式 = "滚动条") {
        MUI_按位置滚动(鼠标Y)
        return 0
    }

    命中 := MUI_命中(鼠标X, 鼠标Y)
    新悬停行 := 0
    新悬停标签 := 0
    新悬停按钮 := ""
    if (SubStr(命中, 1, 2) = "行:")
        新悬停行 := SubStr(命中, 3) + 0
    Else if (SubStr(命中, 1, 3) = "标签:")
        新悬停标签 := SubStr(命中, 4) + 0
    Else if (命中 = "关闭" or 命中 = "更多" or 命中 = "滚动条")
        新悬停按钮 := 命中

    if (新悬停行 != MUI.悬停行) {
        MUI.提示行 := 新悬停行
        if (MUI.提示函数 != "") {
            SetTimer, % MUI.提示函数, Off
            ToolTip
            if (MUI.悬停提示 = 1 and 新悬停行 > 0) {
                提示延迟参数 := "-" MUI.提示延迟
                SetTimer, % MUI.提示函数, %提示延迟参数%
            }
        }
    }
    if (命中 != MUI.悬停标识 or 新悬停行 != MUI.悬停行 or 新悬停标签 != MUI.悬停标签 or 新悬停按钮 != MUI.悬停按钮) {
        MUI.悬停标识 := 命中
        MUI.悬停行 := 新悬停行
        MUI.悬停标签 := 新悬停标签
        MUI.悬停按钮 := 新悬停按钮
        MUI_重绘()
    }
    return 0
}

MUI_WM_LBUTTONDOWN(w参数, l参数, 消息号, 句柄) {
    global MUI, Gui_winID
    if (!MUI.就绪 or 句柄 != Gui_winID)
        return 0
    鼠标X := l参数 & 0xFFFF
    鼠标Y := (l参数 >> 16) & 0xFFFF
    命中 := MUI_命中(鼠标X, 鼠标Y)

    if (命中 = "关闭") {
        MUI_触发回调("GuiClose")
        return 0
    }
    if (命中 = "更多") {
        MUI_触发回调("更多功能设置")
        return 0
    }
    if (SubStr(命中, 1, 2) = "缩放" and MUI_缩放光标(SubStr(命中, 3))) {
        CoordMode, Mouse, Screen
        MouseGetPos, 绝对X, 绝对Y
        WinGetPos, 窗口X, 窗口Y, 窗口W, 窗口H, ahk_id %Gui_winID%
        MUI.缩放方向名 := SubStr(命中, 3)
        MUI.缩放起点X := 绝对X
        MUI.缩放起点Y := 绝对Y
        MUI.缩放窗X := 窗口X
        MUI.缩放窗Y := 窗口Y
        MUI.缩放窗W := 窗口W
        MUI.缩放窗H := 窗口H
        MUI.拖动模式 := "缩放"
        DllCall("user32\SetCapture", "Ptr", Gui_winID)
        return 0
    }
    if (命中 = "拖动") {
        CoordMode, Mouse, Screen
        MouseGetPos, 绝对X, 绝对Y
        WinGetPos, 窗口X, 窗口Y, , , ahk_id %Gui_winID%
        MUI.拖动偏移X := 绝对X - 窗口X
        MUI.拖动偏移Y := 绝对Y - 窗口Y
        MUI.拖动模式 := 命中
        DllCall("user32\SetCapture", "Ptr", Gui_winID)
        return 0
    }
    if (命中 = "标签右") {
        MUI_标签滚动(60)
        return 0
    }
    if (命中 = "标签左") {
        MUI_标签滚动(-60)
        return 0
    }
    if (SubStr(命中, 1, 3) = "标签:") {
        序号 := SubStr(命中, 4) + 0
        if (MUI.标签.HasKey(序号))
            MUI_触发回调(MUI.标签[序号].回调)
        return 0
    }
    if (命中 = "滚动条") {
        MUI.拖动模式 := "滚动条"
        DllCall("user32\SetCapture", "Ptr", Gui_winID)
        MUI_按位置滚动(鼠标Y)
        return 0
    }
    if (SubStr(命中, 1, 2) = "行:") {
        行号 := SubStr(命中, 3) + 0
        现在 := A_TickCount
        ; 正常的双击第二下会被系统转成 WM_LBUTTONDBLCLK（下面单独有处理器），
        ; 这里只是兜底：万一某环境下没收到 DBLCLK，两次按下也能拼成双击。
        上次 := MUI.上次点击时间
        if (上次 = "" or !(上次 is number))
            上次 := 0
        是双击 := (上次 > 0 and 行号 = MUI.上次点击行 and (现在 - 上次) <= MUI_双击间隔())
        MUI.上次点击行 := 行号
        MUI.上次点击时间 := 现在
        MUI_选择行(行号)
        if (是双击 or MUI.单击跳转 = 1)
            MUI_触发回调("打开跳转事件")
        return 0
    }
    return 0
}

; 关键：Windows 把快速连按的第二次按下转成 WM_LBUTTONDBLCLK(0x203)，不再发 0x201。
; 只挂 0x201 的话双击永远收不到第二下，表现就是「点了没反应」。经典界面由
; ListView 的 A_GuiEvent=DoubleClick 兜着，自绘界面必须自己接这个消息。
MUI_WM_LBUTTONDBLCLK(w参数, l参数, 消息号, 句柄) {
    global MUI, Gui_winID
    if (!MUI.就绪 or 句柄 != Gui_winID)
        return 0
    鼠标X := l参数 & 0xFFFF
    鼠标Y := (l参数 >> 16) & 0xFFFF
    命中 := MUI_命中(鼠标X, 鼠标Y)
    if (SubStr(命中, 1, 2) = "行:") {
        行号 := SubStr(命中, 3) + 0
        ; 清掉计时，免得紧跟着的第三次点击又被判成一次双击
        MUI.上次点击行 := 行号
        MUI.上次点击时间 := 0
        MUI_选择行(行号)
        MUI_触发回调("打开跳转事件")
    }
    return 0
}

MUI_WM_LBUTTONUP(w参数, l参数, 消息号, 句柄) {
    global MUI
    if (!MUI.就绪)
        return 0
    if (MUI.拖动模式 != "") {
        MUI.拖动模式 := ""
        DllCall("user32\ReleaseCapture")
        MUI_重绘()
    }
    return 0
}

MUI_WM_RBUTTONDOWN(w参数, l参数, 消息号, 句柄) {
    global MUI, Gui_winID
    if (!MUI.就绪 or 句柄 != Gui_winID)
        return 0
    鼠标X := l参数 & 0xFFFF
    鼠标Y := (l参数 >> 16) & 0xFFFF
    命中 := MUI_命中(鼠标X, 鼠标Y)
    if (SubStr(命中, 1, 2) = "行:") {
        MUI.右键行 := SubStr(命中, 3) + 0
        MUI_选择行(MUI.右键行)
    } Else
        MUI.右键行 := MUI.选中行
    return 0
}

;--------------------------------------------------------------------------------------
; 搜索框：子类化 + 右键菜单
;   Windows 的 Edit 控件本身不带右键菜单（记事本那个是记事本自己写的），
;   要「剪切 / 复制 / 粘贴 / 全选」就得自己接管 WM_CONTEXTMENU。
;
;   这里不能用 OnMessage(0x7B)：那个消息是 EDIT 的默认窗口过程在「同一线程内」
;   直接 SendMessage 给父窗口的，属于同步直呼，不经过消息队列；而 AHK 的 OnMessage
;   只在脚本的消息泵里分发，所以永远收不到。必须直接子类化 EDIT 的窗口过程。
;--------------------------------------------------------------------------------------
MUI_搜索框子类化() {
    global MUI
    if (!MUI.搜索框 or MUI.子类化回调)
        return
    MUI.子类化回调 := RegisterCallback("MUI_搜索框窗口过程", "", 4)
    if (!MUI.子类化回调)
        return
    if (A_PtrSize = 8)
        MUI.原窗口过程 := DllCall("user32\SetWindowLongPtrW", "Ptr", MUI.搜索框, "Int", -4, "Ptr", MUI.子类化回调, "Ptr")
    else
        MUI.原窗口过程 := DllCall("user32\SetWindowLongW", "Ptr", MUI.搜索框, "Int", -4, "Int", MUI.子类化回调, "Int")
}

MUI_搜索框窗口过程(hwnd, 消息号, w参数, l参数) {
    global MUI
    ; 绝大多数消息原样透传，只让右键那一条走下面的分支
    if (消息号 != 0x0205)
        return DllCall("user32\CallWindowProcW", "Ptr", MUI.原窗口过程
            , "Ptr", hwnd, "UInt", 消息号, "Ptr", w参数, "Ptr", l参数, "Ptr")

    ; 先让 EDIT 自己处理一次右键抬起：它会按点击位置挪光标、调整选区，
    ; 菜单里的「剪切 / 复制」要作用在「点下去之后」的选区上，顺序不能反。
    DllCall("user32\CallWindowProcW", "Ptr", MUI.原窗口过程
        , "Ptr", hwnd, "UInt", 消息号, "Ptr", w参数, "Ptr", l参数, "Ptr")

    客户X := l参数 & 0xFFFF
    客户Y := (l参数 >> 16) & 0xFFFF
    VarSetCapacity(坐标点, 8, 0)
    NumPut(客户X, 坐标点, 0, "Int")
    NumPut(客户Y, 坐标点, 4, "Int")
    DllCall("user32\ClientToScreen", "Ptr", hwnd, "Ptr", &坐标点)
    MUI_搜索框菜单(NumGet(坐标点, 0, "Int"), NumGet(坐标点, 4, "Int"))
    return 0
}

MUI_搜索框菜单(屏幕X, 屏幕Y) {
    global MUI, Gui_winID
    编辑框 := MUI.搜索框
    if (!编辑框)
        return

    ; EM_GETSEL：返回值低 16 位是选区起点、高 16 位是终点
    选区 := DllCall("user32\SendMessageW", "Ptr", 编辑框, "UInt", 0x00B0, "Ptr", 0, "Ptr", 0, "Ptr")
    起点 := 选区 & 0xFFFF
    终点 := (选区 >> 16) & 0xFFFF
    有选中 := (终点 > 起点) ? 1 : 0

    ; 剪贴板里得有文本，「粘贴」才可用（CF_UNICODETEXT = 13 / CF_TEXT = 1）
    有剪贴板 := DllCall("user32\IsClipboardFormatAvailable", "UInt", 13) || DllCall("user32\IsClipboardFormatAvailable", "UInt", 1)

    菜单 := DllCall("user32\CreatePopupMenu", "Ptr")
    if (!菜单)
        return
    ; 第三参数：0x1 = MF_GRAYED（灰掉不可点）
    DllCall("user32\AppendMenuW", "Ptr", 菜单, "UInt", 有选中 ? 0 : 0x1, "Ptr", 1, "Str", "剪切`tCtrl+X")
    DllCall("user32\AppendMenuW", "Ptr", 菜单, "UInt", 有选中 ? 0 : 0x1, "Ptr", 2, "Str", "复制`tCtrl+C")
    DllCall("user32\AppendMenuW", "Ptr", 菜单, "UInt", 有剪贴板 ? 0 : 0x1, "Ptr", 3, "Str", "粘贴`tCtrl+V")
    DllCall("user32\AppendMenuW", "Ptr", 菜单, "UInt", 0x800, "Ptr", 0, "Ptr", 0)   ; MF_SEPARATOR
    DllCall("user32\AppendMenuW", "Ptr", 菜单, "UInt", 0, "Ptr", 4, "Str", "全选`tCtrl+A")

    ; 弹菜单前必须把面板设为前台窗口，否则点菜单外面它不会消失（微软文档的老规矩）
    DllCall("user32\SetForegroundWindow", "Ptr", Gui_winID)
    ; 0x102 = TPM_RETURNCMD(0x100) | TPM_RIGHTBUTTON(0x2)
    命令 := DllCall("user32\TrackPopupMenu", "Ptr", 菜单, "UInt", 0x102
        , "Int", 屏幕X, "Int", 屏幕Y, "Int", 0, "Ptr", Gui_winID, "UInt")
    DllCall("user32\DestroyMenu", "Ptr", 菜单)

    if (命令 = 1)
        DllCall("user32\SendMessageW", "Ptr", 编辑框, "UInt", 0x0300, "Ptr", 0, "Ptr", 0)      ; WM_CUT
    else if (命令 = 2)
        DllCall("user32\SendMessageW", "Ptr", 编辑框, "UInt", 0x0301, "Ptr", 0, "Ptr", 0)      ; WM_COPY
    else if (命令 = 3)
        DllCall("user32\SendMessageW", "Ptr", 编辑框, "UInt", 0x0302, "Ptr", 0, "Ptr", 0)      ; WM_PASTE
    else if (命令 = 4)
        DllCall("user32\SendMessageW", "Ptr", 编辑框, "UInt", 0x00B1, "Ptr", 0, "Int", -1)     ; EM_SETSEL 全选
    else
        return

    ; 剪切 / 粘贴动了文字，通知业务层重新过滤一次列表。
    ; 这条路走不到 WM_KEYDOWN，所以 searchbox() 不会被触发，必须自己补一次。
    if (命令 = 1 or 命令 = 3)
        MUI_触发回调("搜索框内容变更")
}

MUI_按位置滚动(鼠标Y) {
    global MUI
    L := MUI.布局
    轨道高 := L.列表H - 8
    拇指高 := MUI.滚动条拇指高
    可用 := 轨道高 - 拇指高
    if (可用 < 1)
        可用 := 1
    最大顶部 := MUI.数量 - MUI.可见行数
    if (最大顶部 < 1)
        最大顶部 := 1
    相对 := 鼠标Y - L.列表Y - 4 - 拇指高 / 2
    新顶部 := Round(相对 / 可用 * 最大顶部) + 1
    MUI_设置顶部(新顶部)
    MUI_重绘()
}

;--------------------------------------------------------------------------------------
; 回调与悬停提示
;--------------------------------------------------------------------------------------
MUI_触发回调(标签名) {
    global MUI
    if (标签名 = "")
        return
    MUI.待执行标签 := 标签名
    static 回调定时器 := ""
    if (!回调定时器)
        回调定时器 := Func("MUI_执行回调")
    SetTimer, %回调定时器%, -1
}

MUI_执行回调() {
    global MUI
    标签名 := MUI.待执行标签
    MUI.待执行标签 := ""
    if (标签名 != "")
        Gosub, %标签名%
    return
}

MUI_显示提示() {
    global MUI
    if (MUI.提示函数 != "")
        SetTimer, % MUI.提示函数, Off
    if (!MUI.就绪 or !MUI_鼠标在窗口内() or MUI.提示行 < 1 or MUI.提示行 > MUI.数量)
        return
    行号 := MUI.提示行
    名称 := MUI.名称[行号]
    路径 := MUI.路径[行号]
    FileGetTime, 修改时间, %路径%
    if (修改时间)
        FormatTime, 时间文本, %修改时间%, yyyy/MM/dd HH:mm:ss
    Else
        时间文本 := "not found"
    ; 单行模式下名称就是完整路径，不再把同一条路径打印两遍
    if (名称 = 路径)
        ToolTip, % "路径: " 路径 "`n修改时间: " 时间文本
    Else
        ToolTip, % "名称: " 名称 "`n路径: " 路径 "`n修改时间: " 时间文本
    return
}
