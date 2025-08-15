; 计算字符串表达式（支持加减乘除）
;MsgBox, % Calculate("3+4*5-6/2")  ; 输出 20
;MsgBox, % Calculate("10/2 + 3*4")  ; 输出 17
;MsgBox, % Calculate("7-2*3")       ; 输出 1
Calculate(expression) {
    ; 1. 去除所有空格
    expression := StrReplace(expression, " ", "")

    ; 2. 解析表达式为 tokens（数字和运算符）
    tokens := []
    i := 1
    while (i <= StrLen(expression)) {
        char := SubStr(expression, i, 1)
        if (char >= "0" && char <= "9") {  ; 数字
            j := i
            while (j <= StrLen(expression) && (SubStr(expression, j, 1) >= "0" && SubStr(expression, j, 1) <= "9")) {
                j++
            }
            num_str := SubStr(expression, i, j - i)
            tokens.Push(num_str + 0)  ; 转换为数值
            i := j
        } else if (char == "+" || char == "-" || char == "*" || char == "/") {  ; 运算符
            tokens.Push(char)
            i++
        } else {  ; 非法字符
            MsgBox, 非法字符: %char%
            return ""
        }
    }

    ; 空表达式处理
    if (tokens.Length() = 0) {
        return 0
    }

    ; 3. 先处理乘除运算
    i := 2  ; 从第一个运算符开始（索引2）
    while (i <= tokens.Length()) {
        op := tokens[i]
        if (op == "*" || op == "/") {
            left := tokens[i - 1]
            right := tokens[i + 1]
            if (op == "*") {
                result := left * right
            } else if (right == 0) {  ; 处理除零错误
                MsgBox, 错误：除零运算
                return ""
            } else {
                result := left / right
            }
            ; 更新数字并删除运算符和右操作数
            tokens[i - 1] := result
            tokens.RemoveAt(i, 2)  ; 删除 i 和 i+1 位置（运算符和右操作数）
        } else {  ; 加减运算符跳过
            i += 2
        }
    }

    ; 4. 再处理加减运算
    i := 2
    while (i <= tokens.Length()) {
        op := tokens[i]
        if (op == "+") {
            tokens[i - 1] := tokens[i - 1] + tokens[i + 1]
            tokens.RemoveAt(i, 2)
        } else if (op == "-") {
            tokens[i - 1] := tokens[i - 1] - tokens[i + 1]
            tokens.RemoveAt(i, 2)
        }
    }

    ; 5. 返回最终结果
    return tokens[1]
}
;================当前鼠标所指的窗口 =====================
MouseIsOver(WinTitle) {
    MouseGetPos,,, Win
    return WinExist(WinTitle . " ahk_id " . Win)
}

;跳转方式1------------------------------------------------------------------------------
FeedDialogGENERAL( _thisID, _thisFOLDER ){
    Global $DialogType
    WinActivate, ahk_id %_thisID%
    sleep 50
    ControlFocus Edit1, ahk_id %_thisID%
    WinGet, ActivecontrolList, ControlList, ahk_id %_thisID%
    Loop, Parse, ActivecontrolList, `n	; which addressbar and "Enter" controls to use
    {
        If InStr(A_LoopField, "ToolbarWindow32")
        {
            ;	ControlGetText _thisToolbarText , %A_LoopField%, ahk_id %_thisID%
            ControlGet, _ctrlHandle, Hwnd,, %A_LoopField%, ahk_id %_thisID%

            ;	Get handle of parent control
            _parentHandle := DllCall("GetParent", "Ptr", _ctrlHandle)

            ;	Get class of parent control
            WinGetClass, _parentClass, ahk_id %_parentHandle%

            If InStr( _parentClass, "Breadcrumb Parent" )
            {
                _UseToolbar := A_LoopField
            }

            If Instr( _parentClass, "msctls_progress32" )
            {
                _EnterToolbar := A_LoopField
            }
        }

        ;	Start next round clean
        _ctrlHandle			:= ""
        _parentHandle		:= ""
        _parentClass		:= ""

    }

    If ( _UseToolbar AND _EnterToolbar )
    {
        Loop, 5
        {
            SendInput ^l
            sleep 100

            ;	Check and insert folder
            ControlGetFocus, _ctrlFocus,A

            If ( InStr( _ctrlFocus, "Edit" ) AND ( _ctrlFocus != "Edit1" ) )
            {
                Control, EditPaste, %_thisFOLDER%, %_ctrlFocus%, A
                ControlGetText, _editAddress, %_ctrlFocus%, ahk_id %_thisID%
                If (_editAddress = _thisFOLDER )
                {
                    _FolderSet := TRUE
                }
            }
            ;	else: 	Try it in the next round

            ;	Start next round clean
            _ctrlFocus := ""
            _editAddress := ""

        }	Until _FolderSet

        If (_FolderSet)
        {
            ;	Click control to "execute" new folder
            ControlClick, %_EnterToolbar%, ahk_id %_thisID%

            ;	Focus file name
            Sleep, 15
            ControlFocus Edit1, ahk_id %_thisID%
        }
        Else
        {
            ;	What to do if folder is not set?
        }
    }
    Else ; unsupported dialog. At least one of the needed controls is missing
    {
        MsgBox This type of dialog can not be handled (yet).`nPlease report it!
    }

    ;	Clean up; probably not needed

    _UseToolbar := ""
    _EnterToolbar := ""
    _editAddress := ""
    _FolderSet := ""
    _ctrlFocus := ""

    Return
}

FeedDialogSYSLISTVIEW( _thisID, _thisFOLDER ){
    Global $DialogType

    WinActivate, ahk_id %_thisID%
    ;	Sleep, 50

    ;	Read the current text in the "File Name:" box (= $OldText)

    ControlGetText _oldText, Edit1, ahk_id %_thisID%
    Sleep, 20

    ;	Make sure there exactly 1 \ at the end.

    _thisFOLDER := RTrim( _thisFOLDER , "\")
    _thisFOLDER := _thisFOLDER . "\"

    Loop, 20
    {
        Sleep, 10
        ControlSetText, Edit1, %_thisFOLDER%, ahk_id %_thisID%
        ControlGetText, _Edit1, Edit1, ahk_id %_thisID%
        If ( _Edit1 = _thisFOLDER )
            _FolderSet := TRUE

    } Until _FolderSet

    If _FolderSet
    {
        Sleep, 20
        ControlFocus Edit1, ahk_id %_thisID%
        ControlSend Edit1, {Enter}, ahk_id %_thisID%

        ;	Restore  original filename / make empty in case of previous folder

        Sleep, 15

        ControlFocus Edit1, ahk_id %_thisID%
        Sleep, 20

        Loop, 5
        {
            ControlSetText, Edit1, %_oldText%, ahk_id %_thisID%		; set
            Sleep, 15
            ControlGetText, _2thisCONTROLTEXT, Edit1, ahk_id %_thisID%		; check
            If ( _2thisCONTROLTEXT = _oldText )
                Break
        }
    }
    Return
}

;跳转方式2------------------------------------------------------------------------------
跳转方式2(thisID2, thisFOLDER2){
    WinActivate, ahk_id %thisID2%
    Sleep, 50
    ControlGetText $OldText, Edit1, ahk_id %thisID2%
    ControlFocus Edit1, ahk_id %thisID2%
    Loop, 5
    {
        ControlSetText, Edit1, %thisFOLDER2%, ahk_id %thisID2%		; set
        Sleep, 50
        ControlGetText, $CurControlText, Edit1, ahk_id %thisID2%		; check
        if ($CurControlText = thisFOLDER2)
            break
    }
    Sleep, 50
    ControlSend Edit1, {Enter}, ahk_id %thisID2%
    Sleep, 50
    If !$OldText
        return
    Loop, 5
    {
        ControlSetText, Edit1, %$OldText%, ahk_id %thisID2%		; set
        Sleep, 50
        ControlGetText, $CurControlText, Edit1, ahk_id %thisID2%		; check
        if ($CurControlText = $OldText)
            break
    }
}

;跳转方式3------------------------------------------------------------------------------
跳转方式3(thisID3, thisFOLDER3){
    WinActivate, ahk_id %thisID3%
    Sleep, 50
    WinGetTitle, this_title, ahk_id %thisID3%
    WinGetClass,this_class,ahk_id %thisID3%
    if(this_class="#32770") { ;保存/打开对话框
        If(instr(this_title,"存") or instr(this_title,"Save") or instr(this_title,"文件")) {
            ChangePath(thisFOLDER3,thisID3)
        }else if(instr(this_title,"开") or instr(this_title,"Open")) {
            ChangePath(thisFOLDER3,thisID3)
        }
    }
}
ChangePath(_dir,this_id){
    WinActivate,ahk_id %this_id%
    ControlFocus,ReBarWindow321,ahk_id %this_id%
    ControlSend,ReBarWindow321,{f4},ahk_id %this_id%
    Loop{
        ControlFocus,Edit2,ahk_id %this_id%
        ControlGetFocus,f,ahk_id %this_id%
        if A_index>50
            break
    }until (f="Edit2")
    ControlSetText,edit2,%_dir%,ahk_id %this_id%
    ControlSend,edit2,{Enter},ahk_id %this_id%
}

;-------------------------------------------
;只有在下列情况下，才将此对话框视为可能的文件对话框
SmellsLikeAFileDialog(_thisID ){
    WinGet, _controlList, ControlList, ahk_id %_thisID%
    Loop, Parse, _controlList, `n
    {
        If ( A_LoopField = "SysListView321" )
            _SysListView321 := 1
        If ( A_LoopField = "ToolbarWindow321")
            _ToolbarWindow321 := 1
        If ( A_LoopField = "DirectUIHWND1" )
            _DirectUIHWND1 := 1
        If ( A_LoopField = "Edit1" )
            _Edit1 := 1
    }
    If ( _DirectUIHWND1 and _ToolbarWindow321 and _Edit1 )
        Return "GENERAL"
    Else If ( _SysListView321 and _ToolbarWindow321 and _Edit1 )
        Return "SYSLISTVIEW"
    else
        Return FALSE
}

;获取资源管理器路径------------------------------------------------------------------------------

;--------获取q-dir标签页的路径---------------------------------------
Q_Dir_Path(){
    DetectHiddenWindows, off
    allpath:=""

    SetTitleMatchMode RegEx
    if WinExist("ahk_class i)^ATL: ahk_exe Q-Dir.*\.exe"){
        WinGet, windowList11, List, ahk_class i)^ATL: ahk_exe Q-Dir.*\.exe
        Loop, %windowList11%
        {
            windowID11 := windowList11%A_Index%
            WinGetText, OutputVar,ahk_id %windowID11%

            Loop, Parse, OutputVar , `n, `r
            {
                if FileExist(A_LoopField)
                {
                    allpath.= Rtrim(A_LoopField,"\") "`n"
                }
            }
        }
    }
    SetTitleMatchMode 1

    return RemoveDuplicateLines(移除空白行(Trim(allpath,"`n")))
}
;--------获取XYplorer标签页的路径---------------------------------------
XYplorer_Path(获取:="0"){  ;获取=1是获取当前路径，获取=2是获取选中路径，获取=0是两者都获取
    DetectHiddenWindows, off
    allpath:=""
    if WinExist("ahk_class ThunderRT6FormDC ahk_exe XYplorer.exe"){
        WinGet, windowList11, List, ahk_class ThunderRT6FormDC ahk_exe XYplorer.exe
        Loop, %windowList11%
        {
            windowID11 := windowList11%A_Index%

            ClipSaved := ClipboardAll
            Clipboard := ""

            if (获取="1" or 获取="0"){
                Send_XYPlorer_Message(windowID11, "::copytext get('path', a);")
                If (ErrorLevel = 0) AND ( InStr(FileExist(clipboard), "D"))
                    allpath.= clipboard "`n"
            }

            if (获取="2" or 获取="0"){
                Send_XYPlorer_Message(windowID11, "::copytext get('path', i);")
                If (ErrorLevel = 0) AND ( InStr(FileExist(clipboard), "D"))
                    allpath.= clipboard "`n"
            }

            Clipboard := ClipSaved
            ClipSaved := ""
        }
    }

    return RemoveDuplicateLines(移除空白行(Trim(allpath,"`n")))

}

Send_XYPlorer_Message(xyHwnd, message){
    size := StrLen(message)
    If !(A_IsUnicode)
    {
        VarSetCapacity(data, size * 2, 0)
        StrPut(message, &data, "UTF-16")
    } Else
    {
        data := message
    }

    VarSetCapacity(COPYDATA, A_PtrSize * 3, 0)
    NumPut(4194305, COPYDATA, 0, "Ptr")
    NumPut(size * 2, COPYDATA, A_PtrSize, "UInt")
    NumPut(&data, COPYDATA, A_PtrSize * 2, "Ptr")
    result := DllCall("User32.dll\SendMessageW", "Ptr", xyHwnd, "UInt", 74, "Ptr", 0, "Ptr", &COPYDATA, "Ptr")
    Return
}

;--------获取所有do窗口标签页的路径---------------------------------------
DirectoryOpusgetinfo(){
    do所以标签路径:=""
    DetectHiddenWindows, on
    if WinExist("ahk_exe dopus.exe"){
        WinGet, dopath, ProcessPath,ahk_exe dopus.exe
        SplitPath, dopath,,dir
        RunWait,"%dir%\dopusrt.exe" /info %A_Temp%\pathlist.txt`,paths
        FileRead, doinfo信息列表, %A_Temp%\pathlist.txt
        正则:=">([^<]+)<\/path>"
        Loop, parse, doinfo信息列表 , `n
        {
            if (RegExMatch(A_LoopField, 正则, do标签路径)){
                if not FileExist(do标签路径1)
                    do标签路径1:=StrReplace(do标签路径1, "`&amp`;", "`&")
                do标签路径1:=Trim(do标签路径1,"\")
                do所以标签路径 .= do标签路径1 "`n"
            }
        }
        do所以标签路径:= Trim(do所以标签路径,"`n")
    }
    Return do所以标签路径
}
;--------获取do收藏夹的的所有路径---------------------------------------
DirectoryOpusgetfa(){
    DetectHiddenWindows,Off
    do所有路径:=""
    do收藏夹路径1:=""
    收藏夹文件 := A_AppData "\GPSoftware\Directory Opus\ConfigFiles\favorites.ofv"
    if WinExist("ahk_exe dopus.exe")
        收藏夹文件 := DirectoryOpus_path2("Clipboard COPYNAMES FILE """"/dopusdata""""") "\ConfigFiles\favorites.ofv"
    ;MsgBox, %收藏夹文件%
    if not FileExist(收藏夹文件)
        return ""

    FileRead,收藏夹列表,%收藏夹文件%
    正则:=">([^<]+)<\/pathstring>"
    Loop, parse, 收藏夹列表 , `n
    {
        if (RegExMatch(A_LoopField, 正则, do收藏夹路径)){
            if not FileExist(do收藏夹路径1){
                do收藏夹路径1:=StrReplace(do收藏夹路径1, "`&amp`;", "`&")
                if (SubStr(do收藏夹路径1, 1, 6) = "lib://") or (SubStr(do收藏夹路径1, 1, 1) = "/"){
                    if WinExist("ahk_exe dopus.exe"){
                        command:="Clipboard COPYNAMES FILE """ do收藏夹路径1 """"
                        do收藏夹路径1:= DirectoryOpus_path2(command)
                    }Else
                        do收藏夹路径1:= ""
                }
            }
            do收藏夹路径1:=Trim(do收藏夹路径1,"\")
            do所有收藏夹路径 .= do收藏夹路径1 "`n"
        }
    }
    do所有收藏夹路径:= Trim(do所有收藏夹路径,"`n")

    Return do所有收藏夹路径
}

;--------获取Directory Opus当前路径---------------------------------------
;获取do的各个值
;command:="Clipboard SET {sourcepath}"
DirectoryOpusget2(command){
    do路径:=""
    DetectHiddenWindows, on
    if WinExist("ahk_exe dopus.exe"){
        ClipSaved := ClipboardAll
        ;clipboard := ""
        WinGet, dopath, ProcessPath,ahk_exe dopus.exe
        SplitPath, dopath,,dir
        RunWait,"%dir%\dopusrt.exe" /acmd %command%
        ;ClipWait, 1
        do路径:= Clipboard
        Clipboard := ClipSaved
        ClipSaved := ""
    }
    Return do路径
}
DirectoryOpus_path(command){
    do路径:=""
    do路径2:= DirectoryOpusget2(command)
    do路径2:=Trim(do路径2,"""")
    if FileExist(do路径2)
        do路径:= do路径2
    Return do路径
}

DirectoryOpusget3(command){
    do路径:=""
    DetectHiddenWindows, on
    if WinExist("ahk_exe dopus.exe"){
        ClipSaved := ClipboardAll
        clipboard := ""
        WinGet, dopath, ProcessPath,ahk_exe dopus.exe
        SplitPath, dopath,,dir
        RunWait,"%dir%\dopusrt.exe" /acmd %command%
        ClipWait, 1
        do路径:= Clipboard
        Clipboard := ClipSaved
        ClipSaved := ""
    }
    Return do路径
}
DirectoryOpus_path2(command){
    do路径:=""
    do路径2:= DirectoryOpusget3(command)
    do路径2:=Trim(do路径2,"""")
    if FileExist(do路径2)
        do路径:= do路径2
    Return do路径
}

;------------------ 获取File Explorer路径 ------------------
;win11资源管理器中获取路径
Explorer_Path(){
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass"){
        WinGet, hwnd, ID, ahk_exe explorer.exe ahk_class CabinetWClass
        ;hwnd := WinActive("ahk_exe explorer.exe ahk_class CabinetWClass")
        ;MsgBox, %hwnd%
        activeTab := 0
        try ControlGet, activeTab, Hwnd,, % "ShellTabWindowClass1", % "ahk_id" hwnd
        for w in ComObjCreate("Shell.Application").Windows {
            try hwnd2 := w.hwnd
            if (hwnd2 != hwnd)
                continue
            if activeTab {
                static IID_IShellBrowser := "{000214E2-0000-0000-C000-000000000046}"
                shellBrowser := ComObjQuery(w, IID_IShellBrowser, IID_IShellBrowser)
                DllCall(NumGet(numGet(shellBrowser+0)+3*A_PtrSize), "Ptr", shellBrowser, "UInt*", thisTab)
                if (thisTab != activeTab)
                    continue
                ObjRelease(shellBrowser)
            }
            return w.Document.Folder.Self.Path
        }
    }
    Return ""
}
Explorer_Path全部(){
    folder汇总:= ""
    if WinExist("ahk_exe explorer.exe ahk_class CabinetWClass"){
        For $Exp in ComObjCreate("Shell.Application").Windows{
            try folder := $Exp.Document.Folder.Self.Path
            if(!folder){
                Continue
            }
            folder汇总.= folder "`n"
        }
        $Exp := ""
    }
    Return Trim(folder汇总, "`n")
}
;--------获取Total Commander路径---------------------------------------
;指定栏: 填1是获取来源栏,填2是目标栏
TotalCommander_path(指定栏:="1"){
    tc路径:=""
    DetectHiddenWindows,On
    cm_CopySrcPathToClip := 2029
    cm_CopyTrgPathToClip := 2030
    ClipSaved := ClipboardAll
    Clipboard := ""

    SendMessage 1075, %cm_CopySrcPathToClip%, 0, , ahk_class TTOTAL_CMD
    folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
    If (ErrorLevel = 0 && folder && (指定栏="1" or 指定栏="0"))
        tc路径:= folder

    SendMessage 1075, %cm_CopyTrgPathToClip%, 0, , ahk_class TTOTAL_CMD
    folder:=RegExReplace(clipboard,"S)^\\\\(?!file)")
    If (ErrorLevel = 0 && folder && (指定栏="2" or 指定栏="0"))
        tc路径:= folder

    Clipboard := ClipSaved
    ClipSaved := ""
    Return tc路径
}

;-----------历史打开路径------------------------------------------------
HistoryOpenPath(软件安装路径2:=""){
    folder汇总:=""
    if FileExist(软件安装路径2 "\ICO\历史跳转.ini"){
        FileRead, 历史跳转路径, %软件安装路径2%\ICO\历史跳转.ini
        if (历史跳转路径 !=""){
            Loop, parse, 历史跳转路径, `n, `r
            {
                if !(RegExMatch(A_LoopField, "^\s*$")) ;判断是否是空白行
                    folder汇总.= A_LoopField "`n"
            }
        }
    }
    Return Trim(folder汇总, "`n")  ; 去掉末尾的换行符
}

;═════════════════════════════════合并重复行只保留一组═════════════════════════════════════════════════
;合并重复行只保留一组
RemoveDuplicateLines(str,jiangeci:="`n",yange:="0"){
    ; 将文本按行分割
    lines := StrSplit(str, jiangeci)
    ; 创建一个空的关联数组，用于存储唯一的行
    uniqueLines := []
    ; 遍历每一行，检查是否已存在于uniqueLines中
    result := ""
    for index, line in lines {
        if (yange="1")
            ;trimmedLine := line  ; 不移除空白字符
            trimmedLine := RegExReplace(line, "m)^\s*|\s*$") ;首尾空白字符的正则表达式
        Else
            trimmedLine := Trim(line," `t`r")  ; 去掉行首尾的空白字符
        if (uniqueLines[trimmedLine] = "") {
            uniqueLines[trimmedLine] := true  ; 如果该行还没有出现过，标记为已出现
            result .= trimmedLine . "`n"  ; 将唯一行添加到结果中
        }
    }
    Return RTrim(result,"`n")
}

;=============================换行转换为|分隔=======================
换行符转换为竖杠(str){
    ; 将字符串中的换行符转换为竖杠
    str := StrReplace(str, "`n", "|")
    str := StrReplace(str, "`r", "|")  ; 处理回车符
    Return str
}
;=============================移除空白行=======================
移除空白行(str) {
    ; 使用正则表达式移除空白行
    str := RegExReplace(str, "m)^\s*$\r?\n", "")
    Return str
}

;---------------------------------------------------------------------
写入文本到(菜单项名,路径名,保留个数){
    If (RegExMatch(菜单项名, "^\((.*?)\)")){
        If (RegExMatch(菜单项名, "^\(&A\)")){
            菜单项名:=RegExReplace(菜单项名, "^\((.*?)\)")
            判断文本内容是否已存在(菜单项名,路径名,保留个数)
        }
    }Else
        判断文本内容是否已存在(菜单项名,路径名,保留个数)
}
;------------------------------------------------------------------------------
判断文本内容是否已存在(写入的内容,文件路径,保留个数:="5"){
    if not FileExist(文件路径)
        Return

    xieruneirong:=""
    FileRead, duquneirong,%文件路径%
    zongneirong:=写入的内容 "`n" duquneirong
    zongneirong:=RemoveDuplicateLines(zongneirong)
    Loop, parse, zongneirong, `n, `r
    {
        xieruneirong .= A_LoopField "`n"
        if (A_Index >= 保留个数){ ;设置最多储存多少个
            Break
        }
    }
    FileDelete,%文件路径%
    FileAppend,%xieruneirong%,%文件路径%
    Return
}

;删除匹配行-----------------------------------------------------------------------------
DeleteMatchingLines(content, matchStr) {
    result := ""
    Loop, Parse, content, `n, `r  ; 处理各种换行符（\n 和 \r\n）
    {
        if (A_LoopField != matchStr) {
            result .= A_LoopField "`n"  ; 用换行符重新连接
        }
    }
    return RTrim(result, "`n")  ; 移除末尾多余的换行符
}

;将字符串中的 %变量名% 替换为变量值----------------------------------------------------------------
ReplaceVars(str) {
    ; 创建新字符串避免修改原始数据
    result := str

    ; 使用更可靠的正则表达式匹配 %变量名%
    pos := 1
    While (pos := RegExMatch(result, "OiU)%([\w#@$]+)%", match, pos)) {
        varName := match.Value(1)  ; 提取变量名

        ; 检查是否是内置变量或全局变量
        if IsLabel(varName) || (%varName% != "") {
            varValue := %varName%  ; 获取变量值

            ; 替换匹配部分
            result := RegExReplace(result, "U)\Q" match.Value() "\E", varValue, , 1, pos)
            pos += StrLen(varValue)  ; 调整位置
        } else {
            ; 如果不是有效变量，跳过
            pos += match.Len
        }
    }

    ; 处理转义的 %% 为 %
    result := StrReplace(result, "``%``%", "``%")
    return result
}

;给行首加[文件名]-----------------------------------------------------------------------------
给行首加文件名(str) {
    result := ""
    Loop, Parse, str, `n, `r  ; 处理各种换行符（\n 和 \r\n）
    {
        if  not (RegExMatch(A_LoopField, "^\s*$")){ ;不匹配空白行
            移除末尾斜杠:= RTrim(A_LoopField, "\")  ; 移除行尾的斜杠
            SplitPath, 移除末尾斜杠 , OutFileName, OutDir
            If (OutFileName =""){
                result .= "<" A_LoopField ">" A_LoopField "`n"
            }Else
                result .= "<" OutFileName ">" A_LoopField "`n"  ; 在行首添加文件名
        }
    }
    return RTrim(result, "`n")  ; 移除末尾多余的换行符
}

;══════════════════════════════════════════════════════════════════════════════════
;ToolTip提示，不使用 Sleep(它会停止当前线程).
;text内容，time显示时间,at显示长度, at显示宽度，divider省略词
ttip(text:="",time:="5000",at:="100", ay:="20",divider="......"){
    time:= - time
    ;MsgBox, %time%
    text2:=""
    if InStr(text, "`n"){
        Loop, parse, text, `n, `r
        {
            if (RegExMatch(A_LoopField, "^\s*$")) ;匹配空白行
                Continue
            if (strLen(A_LoopField) > at)
                text2 :=text2 . A_Index " " subStr(A_LoopField, 1, at/2) . divider . subStr(A_LoopField, -at/2) "`n"
            Else
                text2 :=text2 . A_Index " " A_LoopField "`n"
            if (A_Index > ay)
                Break
        }
    }Else
        text2:=分割字符串(text,at,"`n")
    ToolTip,%text2%
    SetTimer, RemoveToolTip, %time%
    return
}

;══════════════════════════════════════════════════════════════════════════════════
分割字符串(字符串:="",间隔长度:="50",间隔词:="`n"){
    pattern := ".{1," 间隔长度 "}"
    ; 创建一个空数组来存储匹配的结果
    matches := []
    ; 使用循环提取每10个字符
    while (RegExMatch(字符串, pattern, match)) {
        matches.Push(match) ; 将匹配的结果添加到数组中
        字符串 := SubStr(字符串, StrLen(match) + 1) ; 从文本中去掉已匹配的部分
    }
    ; 输出结果
    result:=""
    for index, value in matches {
        ;MsgBox, % "匹配结果 " index ": " value
        result:=result . index " " value . 间隔词
        if (index>20)
            Break
    }
    ;MsgBox, % result
    Return result
}

;══════════════════════════════════════════════════════════════════════════════════
Single(flag) { ;,返回1为重复,返回0为第一个运行
    DllCall("CreateMutex", "Ptr",0, "int",0, "str", "Ahk_Single_" flag)
    return A_LastError=0xB7 ? true : false
}

;---------------------------------------------------
跳转方式4(DialogHwnd,SelectedPath,是否按下确定 :="否") {
    ControlGet, hctl, Hwnd,, SysTreeView321, % "ahk_id" DialogHwnd
    ;MsgBox,%hctl%
    ;Clipboard := hctl
    if hctl {
        RTV := new RemoteTreeview(hctl)

        PathTree := GetExplorerPathTree(SelectedPath)
        Loop, Parse, PathTree, `n, `r
        {
            Level := A_LoopField

            loop
            {
                重复次数:= A_Index

                指定句柄 := RTV.GetHandleByText(Level,重复次数)
                if !(指定句柄) {
                    Loop, 15
                    {
                        指定句柄 := RTV.GetHandleByText(Level,重复次数)
                        Sleep, 10
                        if 指定句柄
                            Break
                    }
                }

                ;MsgBox, 测试 %Level% %指定句柄%

                if 指定句柄 {

                    父节点句柄:= RTV.GetParent(指定句柄)
                    If 父节点句柄{
                        if (父节点句柄 = 上一层句柄) {
                            最终选中句柄 := 指定句柄
                            RTV.SetSelection(最终选中句柄, 0)
                            RTV.Expand(最终选中句柄)
                            if ErrorLevel
                                RTV.Expand(最终选中句柄)
                            Break
                        }
                    }Else{
                        最终选中句柄 := 指定句柄
                        RTV.SetSelection(最终选中句柄, 0)
                        RTV.Expand(最终选中句柄)
                        if ErrorLevel
                            RTV.Expand(最终选中句柄)
                        Break
                    }

                }Else{
                    Break
                }
            }
            上一层level := Level
            上一层句柄 := 指定句柄
        }

        if (是否按下确定 = "是"){
            ;MsgBox, 1
            WinActivate % "ahk_id" DialogHwnd
            WinWaitActive % "ahk_id" DialogHwnd, , 2
            ;Sleep, 500
            ControlFocus, SysTreeView321, % "ahk_id" DialogHwnd
            ControlSend, SysTreeView321, {enter},% "ahk_id" DialogHwnd
            ;RTV.Check(最终选中句柄, true)
            ;RTV.SetSelection(最终选中句柄)
        }
        ;MsgBox, %最终选中句柄%
        最终选中句柄:=""

    }else{
        $DialogType := SmellsLikeAFileDialog(DialogHwnd)
        FeedDialog%$DialogType%(DialogHwnd, SelectedPath)
    }
}

; ==================================================================================================================================
;获取路径的树结构
GetExplorerPathTree(FolderPath) {
    Shell := ComObjCreate("Shell.Application")
    Folder := Shell.NameSpace(FolderPath)
    PathTree := ""
    Loop
        PathTree := Folder.Self.Name "`n" PathTree
    Until !(Folder := Folder.ParentFolder)
    Return trim(PathTree, "`n")
}

;--------------------------------------------------------------------------------------------------
; Title:  Remote TreeView class
;         This class allows a script to work with TreeViews controlled by a third party process.
;
;         8/30/2012  Released for beta testing
;
;         8/31/2012  Added a wait parameter to SetSelection
;                    Changed name of ExpandCollapse to Expand
;                    Changed default WaitTime of Expand to 0
;
;         9/2/2012	 Removed GetState method and replaced it with the IsBold, IsChecked, IsExpanded
; 					 and IsSelected methods.
;
;         9/7/2012   Added Check method.
;                    For ease of use, changed parameters of SetSelection, Expand and IsChecked methods.
;
;         9/17/2012  Extended the "Full" option of GetNext() to allow it to transverse sub-trees.
;                    Given a starting node, all decendents of that node will be  transversed depth
;                    first. Those nodes which are not descendants of the starting node will NOT be
;                    visited. To traverse the entire tree, including the real root, pass zero as the
;                    starting node.
;
;         11/02/2014 Fix for GetText and ddditional function from just me
;                    See http://ahkscript.org/boards/viewtopic.php?f=5&t=4998#p29339
;
class RemoteTreeView
{
    ; ======================================================================================================================
    ; Function:         Constants for TreeView controls
    ; Version:          1.0.00.00/2012-04-01/just me
    ; ======================================================================================================================
    ; CCM_FIRST = 0x2000
    ; TV_FIRST  = 0x1100
    ; TVN_FIRST = -400
    ; ======================================================================================================================
    ; Class ================================================================================================================
    WC_TREEVIEW             := "SysTreeView32"
    ; Messages =============================================================================================================
    TVM_CREATEDRAGIMAGE     := 0x1112 ; (TV_FIRST + 18)
    TVM_DELETEITEM          := 0x1101 ; (TV_FIRST + 1)
    TVM_EDITLABELA          := 0x110E ; (TV_FIRST + 14)
    TVM_EDITLABELW          := 0x1141 ; (TV_FIRST + 65)
    TVM_ENDEDITLABELNOW     := 0x1116 ; (TV_FIRST + 22)
    TVM_ENSUREVISIBLE       := 0x1114 ; (TV_FIRST + 20)
    TVM_EXPAND              := 0x1102 ; (TV_FIRST + 2)
    TVM_GETBKCOLOR          := 0x112F ; (TV_FIRST + 31)
    TVM_GETCOUNT            := 0x1105 ; (TV_FIRST + 5)
    TVM_GETEDITCONTROL      := 0x110F ; (TV_FIRST + 15)
    TVM_GETEXTENDEDSTYLE    := 0x112D ; (TV_FIRST + 45)
    TVM_GETIMAGELIST        := 0x1108 ; (TV_FIRST + 8)
    TVM_GETINDENT           := 0x1106 ; (TV_FIRST + 6)
    TVM_GETINSERTMARKCOLOR  := 0x1126 ; (TV_FIRST + 38)
    TVM_GETISEARCHSTRINGA   := 0x1117 ; (TV_FIRST + 23)
    TVM_GETISEARCHSTRINGW   := 0x1140 ; (TV_FIRST + 64)
    TVM_GETITEMA            := 0x110C ; (TV_FIRST + 12)
    TVM_GETITEMHEIGHT       := 0x111C ; (TV_FIRST + 28)
    TVM_GETITEMPARTRECT     := 0x1148 ; (TV_FIRST + 72) ; >= Vista
    TVM_GETITEMRECT         := 0x1104 ; (TV_FIRST + 4)
    TVM_GETITEMSTATE        := 0x1127 ; (TV_FIRST + 39)
    TVM_GETITEMW            := 0x113E ; (TV_FIRST + 62)
    TVM_GETLINECOLOR        := 0x1129 ; (TV_FIRST + 41)
    TVM_GETNEXTITEM         := 0x110A ; (TV_FIRST + 10)
    TVM_GETSCROLLTIME       := 0x1122 ; (TV_FIRST + 34)
    TVM_GETSELECTEDCOUNT    := 0x1146 ; (TV_FIRST + 70) ; >= Vista
    TVM_GETTEXTCOLOR        := 0x1120 ; (TV_FIRST + 32)
    TVM_GETTOOLTIPS         := 0x1119 ; (TV_FIRST + 25)
    TVM_GETUNICODEFORMAT    := 0x2006 ; (CCM_FIRST + 6) CCM_GETUNICODEFORMAT
    TVM_GETVISIBLECOUNT     := 0x1110 ; (TV_FIRST + 16)
    TVM_HITTEST             := 0x1111 ; (TV_FIRST + 17)
    TVM_INSERTITEMA         := 0x1100 ; (TV_FIRST + 0)
    TVM_INSERTITEMW         := 0x1142 ; (TV_FIRST + 50)
    TVM_MAPACCIDTOHTREEITEM := 0x112A ; (TV_FIRST + 42)
    TVM_MAPHTREEITEMTOACCID := 0x112B ; (TV_FIRST + 43)
    TVM_SELECTITEM          := 0x110B ; (TV_FIRST + 11)
    TVM_SETAUTOSCROLLINFO   := 0x113B ; (TV_FIRST + 59)
    TVM_SETBKCOLOR          := 0x111D ; (TV_FIRST + 29)
    TVM_SETEXTENDEDSTYLE    := 0x112C ; (TV_FIRST + 44)
    TVM_SETIMAGELIST        := 0x1109 ; (TV_FIRST + 9)
    TVM_SETINDENT           := 0x1107 ; (TV_FIRST + 7)
    TVM_SETINSERTMARK       := 0x111A ; (TV_FIRST + 26)
    TVM_SETINSERTMARKCOLOR  := 0x1125 ; (TV_FIRST + 37)
    TVM_SETITEMA            := 0x110D ; (TV_FIRST + 13)
    TVM_SETITEMHEIGHT       := 0x111B ; (TV_FIRST + 27)
    TVM_SETITEMW            := 0x113F ; (TV_FIRST + 63)
    TVM_SETLINECOLOR        := 0x1128 ; (TV_FIRST + 40)
    TVM_SETSCROLLTIME       := 0x1121 ; (TV_FIRST + 33)
    TVM_SETTEXTCOLOR        := 0x111E ; (TV_FIRST + 30)
    TVM_SETTOOLTIPS         := 0x1118 ; (TV_FIRST + 24)
    TVM_SETUNICODEFORMAT    := 0x2005 ; (CCM_FIRST + 5) ; CCM_SETUNICODEFORMAT
    TVM_SHOWINFOTIP         := 0x1147 ; (TV_FIRST + 71) ; >= Vista
    TVM_SORTCHILDREN        := 0x1113 ; (TV_FIRST + 19)
    TVM_SORTCHILDRENCB      := 0x1115 ; (TV_FIRST + 21)
    ; Notifications ========================================================================================================
    TVN_ASYNCDRAW           := -420 ; (TVN_FIRST - 20) >= Vista
    TVN_BEGINDRAGA          := -427 ; (TVN_FIRST - 7)
    TVN_BEGINDRAGW          := -456 ; (TVN_FIRST - 56)
    TVN_BEGINLABELEDITA     := -410 ; (TVN_FIRST - 10)
    TVN_BEGINLABELEDITW     := -456 ; (TVN_FIRST - 59)
    TVN_BEGINRDRAGA         := -408 ; (TVN_FIRST - 8)
    TVN_BEGINRDRAGW         := -457 ; (TVN_FIRST - 57)
    TVN_DELETEITEMA         := -409 ; (TVN_FIRST - 9)
    TVN_DELETEITEMW         := -458 ; (TVN_FIRST - 58)
    TVN_ENDLABELEDITA       := -411 ; (TVN_FIRST - 11)
    TVN_ENDLABELEDITW       := -460 ; (TVN_FIRST - 60)
    TVN_GETDISPINFOA        := -403 ; (TVN_FIRST - 3)
    TVN_GETDISPINFOW        := -452 ; (TVN_FIRST - 52)
    TVN_GETINFOTIPA         := -412 ; (TVN_FIRST - 13)
    TVN_GETINFOTIPW         := -414 ; (TVN_FIRST - 14)
    TVN_ITEMCHANGEDA        := -418 ; (TVN_FIRST - 18) ; >= Vista
    TVN_ITEMCHANGEDW        := -419 ; (TVN_FIRST - 19) ; >= Vista
    TVN_ITEMCHANGINGA       := -416 ; (TVN_FIRST - 16) ; >= Vista
    TVN_ITEMCHANGINGW       := -417 ; (TVN_FIRST - 17) ; >= Vista
    TVN_ITEMEXPANDEDA       := -406 ; (TVN_FIRST - 6)
    TVN_ITEMEXPANDEDW       := -455 ; (TVN_FIRST - 55)
    TVN_ITEMEXPANDINGA      := -405 ; (TVN_FIRST - 5)
    TVN_ITEMEXPANDINGW      := -454 ; (TVN_FIRST - 54)
    TVN_KEYDOWN             := -412 ; (TVN_FIRST - 12)
    TVN_SELCHANGEDA         := -402 ; (TVN_FIRST - 2)
    TVN_SELCHANGEDW         := -451 ; (TVN_FIRST - 51)
    TVN_SELCHANGINGA        := -401 ; (TVN_FIRST - 1)
    TVN_SELCHANGINGW        := -450 ; (TVN_FIRST - 50)
    TVN_SETDISPINFOA        := -404 ; (TVN_FIRST - 4)
    TVN_SETDISPINFOW        := -453 ; (TVN_FIRST - 53)
    TVN_SINGLEEXPAND        := -415 ; (TVN_FIRST - 15)
    ; Styles ===============================================================================================================
    TVS_CHECKBOXES          := 0x0100
    TVS_DISABLEDRAGDROP     := 0x0010
    TVS_EDITLABELS          := 0x0008
    TVS_FULLROWSELECT       := 0x1000
    TVS_HASBUTTONS          := 0x0001
    TVS_HASLINES            := 0x0002
    TVS_INFOTIP             := 0x0800
    TVS_LINESATROOT         := 0x0004
    TVS_NOHSCROLL           := 0x8000 ; TVS_NOSCROLL overrides this
    TVS_NONEVENHEIGHT       := 0x4000
    TVS_NOSCROLL            := 0x2000
    TVS_NOTOOLTIPS          := 0x0080
    TVS_RTLREADING          := 0x0040
    TVS_SHOWSELALWAYS       := 0x0020
    TVS_SINGLEEXPAND        := 0x0400
    TVS_TRACKSELECT         := 0x0200
    ; Exstyles =============================================================================================================
    TVS_EX_AUTOHSCROLL         := 0x0020 ; >= Vista
    TVS_EX_DIMMEDCHECKBOXES    := 0x0200 ; >= Vista
    TVS_EX_DOUBLEBUFFER        := 0x0004 ; >= Vista
    TVS_EX_DRAWIMAGEASYNC      := 0x0400 ; >= Vista
    TVS_EX_EXCLUSIONCHECKBOXES := 0x0100 ; >= Vista
    TVS_EX_FADEINOUTEXPANDOS   := 0x0040 ; >= Vista
    TVS_EX_MULTISELECT         := 0x0002 ; >= Vista - Not supported. Do not use.
    TVS_EX_NOINDENTSTATE       := 0x0008 ; >= Vista
    TVS_EX_NOSINGLECOLLAPSE    := 0x0001 ; >= Vista - Intended for internal use; not recommended for use in applications.
    TVS_EX_PARTIALCHECKBOXES   := 0x0080 ; >= Vista
    TVS_EX_RICHTOOLTIP         := 0x0010 ; >= Vista
    ; Others ===============================================================================================================
    ; Item flags
    TVIF_CHILDREN           := 0x0040
    TVIF_DI_SETITEM         := 0x1000
    TVIF_EXPANDEDIMAGE      := 0x0200 ; >= Vista
    TVIF_HANDLE             := 0x0010
    TVIF_IMAGE              := 0x0002
    TVIF_INTEGRAL           := 0x0080
    TVIF_PARAM              := 0x0004
    TVIF_SELECTEDIMAGE      := 0x0020
    TVIF_STATE              := 0x0008
    TVIF_STATEEX            := 0x0100 ; >= Vista
    TVIF_TEXT               := 0x0001
    ; Item states
    TVIS_BOLD               := 0x0010
    TVIS_CUT                := 0x0004
    TVIS_DROPHILITED        := 0x0008
    TVIS_EXPANDED           := 0x0020
    TVIS_EXPANDEDONCE       := 0x0040
    TVIS_EXPANDPARTIAL      := 0x0080
    TVIS_OVERLAYMASK        := 0x0F00
    TVIS_SELECTED           := 0x0002
    TVIS_STATEIMAGEMASK     := 0xF000
    TVIS_USERMASK           := 0xF000
    ; TVITEMEX uStateEx
    TVIS_EX_ALL             := 0x0002 ; not documented
    TVIS_EX_DISABLED        := 0x0002 ; >= Vista
    TVIS_EX_FLAT            := 0x0001
    ; TVINSERTSTRUCT hInsertAfter
    TVI_FIRST               := -65535 ; (-0x0FFFF)
    TVI_LAST                := -65534 ; (-0x0FFFE)
    TVI_ROOT                := -65536 ; (-0x10000)
    TVI_SORT                := -65533 ; (-0x0FFFD)
    ; TVM_EXPAND wParam
    TVE_COLLAPSE            := 0x0001
    TVE_COLLAPSERESET       := 0x8000
    TVE_EXPAND              := 0x0002
    TVE_EXPANDPARTIAL       := 0x4000
    TVE_TOGGLE              := 0x0003
    ; TVM_GETIMAGELIST wParam
    TVSIL_NORMAL            := 0
    TVSIL_STATE             := 2
    ; TVM_GETNEXTITEM wParam
    TVGN_CARET              := 0x0009
    TVGN_CHILD              := 0x0004
    TVGN_DROPHILITE         := 0x0008
    TVGN_FIRSTVISIBLE       := 0x0005
    TVGN_LASTVISIBLE        := 0x000A
    TVGN_NEXT               := 0x0001
    TVGN_NEXTSELECTED       := 0x000B ; >= Vista (MSDN)
    TVGN_NEXTVISIBLE        := 0x0006
    TVGN_PARENT             := 0x0003
    TVGN_PREVIOUS           := 0x0002
    TVGN_PREVIOUSVISIBLE    := 0x0007
    TVGN_ROOT               := 0x0000
    ; TVM_SELECTITEM wParam
    TVSI_NOSINGLEEXPAND     := 0x8000 ; Should not conflict with TVGN flags.
    ; TVHITTESTINFO flags
    TVHT_ABOVE              := 0x0100
    TVHT_BELOW              := 0x0200
    TVHT_NOWHERE            := 0x0001
    TVHT_ONITEMBUTTON       := 0x0010
    TVHT_ONITEMICON         := 0x0002
    TVHT_ONITEMINDENT       := 0x0008
    TVHT_ONITEMLABEL        := 0x0004
    TVHT_ONITEMRIGHT        := 0x0020
    TVHT_ONITEMSTATEICON    := 0x0040
    TVHT_TOLEFT             := 0x0800
    TVHT_TORIGHT            := 0x0400
    TVHT_ONITEM             := 0x0046 ; (TVHT_ONITEMICON | TVHT_ONITEMLABEL | TVHT_ONITEMSTATEICON)
    ; TVGETITEMPARTRECTINFO partID (>= Vista)
    TVGIPR_BUTTON           := 0x0001
    ; NMTREEVIEW action
    TVC_BYKEYBOARD          := 0x0002
    TVC_BYMOUSE             := 0x0001
    TVC_UNKNOWN             := 0x0000
    ; TVN_SINGLEEXPAND return codes
    TVNRET_DEFAULT          := 0
    TVNRET_SKIPOLD          := 1
    TVNRET_SKIPNEW          := 2
    ; ======================================================================================================================

    PAGE_NOACCESS          := 0x01
    PAGE_READONLY          := 0x02
    PAGE_READWRITE         := 0x04
    PAGE_WRITECOPY         := 0x08
    PAGE_EXECUTE           := 0x10
    PAGE_EXECUTE_READ      := 0x20
    PAGE_EXECUTE_READWRITE := 0x40
    PAGE_EXECUTE_WRITECOPY := 0x80
    PAGE_GUARD            := 0x100
    PAGE_NOCACHE          := 0x200
    PAGE_WRITECOMBINE     := 0x400
    MEM_COMMIT           := 0x1000
    MEM_RESERVE          := 0x2000
    MEM_DECOMMIT         := 0x4000
    MEM_RELEASE          := 0x8000
    MEM_FREE            := 0x10000
    MEM_PRIVATE         := 0x20000
    MEM_MAPPED          := 0x40000
    MEM_RESET           := 0x80000
    MEM_TOP_DOWN       := 0x100000
    MEM_WRITE_WATCH    := 0x200000
    MEM_PHYSICAL       := 0x400000
    MEM_ROTATE         := 0x800000
    MEM_LARGE_PAGES  := 0x20000000
    MEM_4MB_PAGES    := 0x80000000

    PROCESS_TERMINATE                  := (0x0001)
    PROCESS_CREATE_THREAD              := (0x0002)
    PROCESS_SET_SESSIONID              := (0x0004)
    PROCESS_VM_OPERATION               := (0x0008)
    PROCESS_VM_READ                    := (0x0010)
    PROCESS_VM_WRITE                   := (0x0020)
    PROCESS_DUP_HANDLE                 := (0x0040)
    PROCESS_CREATE_PROCESS             := (0x0080)
    PROCESS_SET_QUOTA                  := (0x0100)
    PROCESS_SET_INFORMATION            := (0x0200)
    PROCESS_QUERY_INFORMATION          := (0x0400)
    PROCESS_SUSPEND_RESUME             := (0x0800)
    PROCESS_QUERY_LIMITED_INFORMATION  := (0x1000)

    ;----------------------------------------------------------------------------------------------
    ; Method: __New
    ;         Stores the TreeView's Control HWnd in the object for later use
    ;
    ; Parameters:
    ;         TVHwnd			- HWND of the TreeView control
    ;
    ; Returns:
    ;         Nothing
    ;
    __New(TVHwnd){
        this.TVHwnd := TVHwnd
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetHandleByText
    ;         Retrieves the currently item with a specific text
    ;
    ; Parameters:
    ;         text			- Text of the item
    ;         index			- Index of item if you do not want to use the first item
    ;
    ; Returns:
    ;         Handle of Item
    ;
    GetHandleByText(Text, index := 1) {
        hItem := "0"    ; Causes the loop's first iteration to start the search at the top of the tree.
        i := 0
        Loop {
            hItem := this.GetNext(hItem, "Full")
            if !hItem{ ; No more items in tree.
                return false
            }
            if (this.GetText(hItem)=Text){
                i++
                if (index = i){
                    return hItem
                }
            }
        }
        return false
    }
    ;----------------------------------------------------------------------------------------------
    ; Method: SetSelection
    ;         Makes the given item selected and expanded. Optionally scrolls the
    ;         TreeView so the item is visible.
    ;
    ; Parameters:
    ;         pItem			    - Handle to the item you wish selected
    ;         defaultAction     - Determines of the default action is activated
    ;                         true : Send an Enter (default)
    ;                         false : do noting
    ;
    ; Returns:
    ;         TRUE if successful, or FALSE otherwise
    ;
    SetSelection(pItem, defaultAction := true){
        ; ORI SendMessage this.TVM_SELECTITEM, this.TVGN_CARET|this.TVSI_NOSINGLEEXPAND, pItem, , % "ahk_id " this.TVHwnd
        ; sle118 :
        ; SendMessage this.TVM_SELECTITEM, this.TVGN_FIRSTVISIBLE, pItem, , % "ahk_id " this.TVHwnd
        SendMessage this.TVM_SELECTITEM, this.TVGN_CARET, pItem, , % "ahk_id " this.TVHwnd
        if (defaultAction){
            Controlsend,  , {Enter}, % "ahk_id " this.TVHwnd
        }
        return ErrorLevel
    }
    ;----------------------------------------------------------------------------------------------
    ; Method: SetSelectionByText
    ;         Makes the given item selected and expanded. Optionally scrolls the
    ;         TreeView so the item is visible.
    ;
    ; Parameters:
    ;         text			    - Text of the item you wish selected
    ;         defaultAction     - Determines of the default action is activated
    ;                               true : Send an Enter (default)
    ;                               false : do noting
    ;         index			    - Index of item if you do not want to use the first item
    ;
    ; Returns:
    ;         TRUE if successful, or FALSE otherwise
    ;
    SetSelectionByText(text, defaultAction := true, index := 1) {
        ; hItem := "0"    ; Causes the loop's first iteration to start the search at the top of the tree.
        hItem := this.GetHandleByText(text, index)
        if hItem{
            return this.SetSelection(hItem, defaultAction)
        }
        return false
    }
    ;----------------------------------------------------------------------------------------------
    ; Method: GetSelection
    ;         Retrieves the currently selected item
    ;
    ; Parameters:
    ;         None
    ;
    ; Returns:
    ;         Handle to the selected item if successful, Null otherwise.
    ;
    GetSelection(){
        SendMessage this.TVM_GETNEXTITEM, this.TVGN_CARET, 0, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetRoot
    ;         Retrieves the root item of the treeview
    ;
    ; Parameters:
    ;         None
    ;
    ; Returns:
    ;         Handle to the topmost or very first item of the tree-view control
    ;         if successful, NULL otherwise.
    ;
    GetRoot(){
        SendMessage this.TVM_GETNEXTITEM, this.TVGN_ROOT, 0, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetParent
    ;         Retrieves an item's parent
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Handle to the parent of the specified item. Returns
    ;         NULL if the item being retrieved is the root node of the tree.
    ;
    GetParent(pItem){
        SendMessage this.TVM_GETNEXTITEM, this.TVGN_PARENT, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetChild
    ;         Retrieves an item's first child
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Handle to the first Child of the specified item, NULL otherwise.
    ;
    GetChild(pItem){
        SendMessage this.TVM_GETNEXTITEM, this.TVGN_CHILD, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetNext
    ;         Returns the handle of the sibling below the specified item (or 0 if none).
    ;
    ; Parameters:
    ;         pItem			- (Optional) Handle to the item
    ;
    ;         flag          - (Optional) "FULL" or "F"
    ;
    ; Returns:
    ;         This method has the following modes:
    ;              1. When all parameters are omitted, it returns the handle
    ;                 of the first/top item in the TreeView (or 0 if none).
    ;
    ;              2. When the only first parameter (pItem) is present, it returns the
    ;                 handle of the sibling below the specified item (or 0 if none).
    ;                 If the first parameter is 0, it returns the handle of the first/top
    ;                 item in the TreeView (or 0 if none).
    ;
    ;              3. When the second parameter is "Full" or "F", the first time GetNext()
    ;                 is called the hItem passed is considered the "root" of a sub-tree that
    ;                 will be transversed in a depth first manner. No nodes except the
    ;                 decendents of that "root" will be visited. To traverse the entire tree,
    ;                 including the real root, pass zero in the first call.
    ;
    ;                 When all descendants have benn visited, the method returns zero.
    ;
    ; Example:
    ;				hItem = 0  ; Start the search at the top of the tree.
    ;				Loop
    ;				{
    ;					hItem := MyTV.GetNext(hItem, "Full")
    ;					if not hItem  ; No more items in tree.
    ;						break
    ;					ItemText := MyTV.GetText(hItem)
    ;					MsgBox The next Item is %hItem%, whose text is "%ItemText%".
    ;				}
    ;
    GetNext(pItem = 0, flag = ""){
        static Root := -1

        if (RegExMatch(flag, "i)^\s*(F|Full)\s*$")) {
            if (Root = -1) {
                Root := pItem
            }
            SendMessage this.TVM_GETNEXTITEM, this.TVGN_CHILD, pItem, , % "ahk_id " this.TVHwnd
            if (ErrorLevel = 0) {
                SendMessage this.TVM_GETNEXTITEM, this.TVGN_NEXT, pItem, , % "ahk_id " this.TVHwnd
                if (ErrorLevel = 0) {
                    Loop {
                        SendMessage this.TVM_GETNEXTITEM, this.TVGN_PARENT, pItem, , % "ahk_id " this.TVHwnd
                        if (ErrorLevel = Root) {
                            Root := -1
                            return 0
                        }
                        pItem := ErrorLevel
                        SendMessage this.TVM_GETNEXTITEM, this.TVGN_NEXT, pItem, , % "ahk_id " this.TVHwnd
                    } until ErrorLevel
                }
            }
            return ErrorLevel
        }

        Root := -1
        if (!pItem)
            SendMessage this.TVM_GETNEXTITEM, this.TVGN_ROOT, 0, , % "ahk_id " this.TVHwnd
        else
            SendMessage this.TVM_GETNEXTITEM, this.TVGN_NEXT, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetPrev
    ;         Returns the handle of the sibling above the specified item (or 0 if none).
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Handle of the sibling above the specified item (or 0 if none).
    ;
    GetPrev(pItem){
        SendMessage this.TVM_GETNEXTITEM, this.TVGN_PREVIOUS, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: Expand
    ;         Expands or collapses the specified tree node
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ;         flag			- Determines whether the node is expanded or collapsed.
    ;                         true : expand the node (default)
    ;                         false : collapse the node
    ;
    ;
    ; Returns:
    ;         Nonzero if the operation was successful, or zero otherwise.
    ;
    Expand(pItem, DoExpand = true){
        flag := DoExpand ? this.TVE_EXPAND : this.TVE_COLLAPSE
        SendMessage this.TVM_EXPAND, flag, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: Check
    ;         Changes the state of a treeview item's check box
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ;         fCheck        - If true, check the node
    ;                         If false, uncheck the node
    ;
    ;         Force			- If true (default), prevents this method from failing due to
    ;                         the node having an invalid initial state. See IsChecked
    ;                         method for more info.
    ;
    ; Returns:
    ;         Returns true if if successful, otherwise false
    ;
    ; Remarks:
    ;         This method makes pItem the current selection.
    ;
    Check(pItem, fCheck, Force = true){
        SavedDelay := A_KeyDelay
        SetKeyDelay 30

        CurrentState := this.IsChecked(pItem, false)
        if (CurrentState = -1)
            if (Force) {
                ControlSend, , {Space}, % "ahk_id " this.TVHwnd
                CurrentState := this.IsChecked(pItem, false)
            }
            else
                return false

        if (CurrentState and not fCheck) or (not CurrentState and fCheck )
            ControlSend, , {Space}, % "ahk_id " this.TVHwnd

        SetKeyDelay %SavedDelay%
        return true
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetText
    ;         Retrieves the text/name of the specified node
    ;
    ; Parameters:
    ;         pItem         - Handle to the item
    ;
    ; Returns:
    ;         The text/name of the specified Item. If the text is longer than 127, only
    ;         the first 127 characters are retrieved.
    ;
    ; Fix from just me (http://ahkscript.org/boards/viewtopic.php?f=5&t=4998#p29339)
    ;
    GetText(pItem){
        this.TVM_GETITEM := A_IsUnicode ? this.TVM_GETITEMW : this.TVM_GETITEMA

        WinGet, ProcessId, pid, % "ahk_id " this.TVHwnd
        hProcess := this.OpenProcess(this.PROCESS_VM_OPERATION|this.PROCESS_VM_READ
            |this.PROCESS_VM_WRITE|this.PROCESS_QUERY_INFORMATION
            , false, ProcessId)

        ; Try to determine the bitness of the remote tree-view's process
        ProcessIs32Bit := A_PtrSize = 8 ? False : True
        If (A_Is64bitOS) && DllCall("Kernel32.dll\IsWow64Process", "Ptr", hProcess, "UIntP", WOW64)
            ProcessIs32Bit := WOW64

        Size := ProcessIs32Bit ?  60 : 80 ; Size of a TVITEMEX structure

        _tvi := this.VirtualAllocEx(hProcess, 0, Size, this.MEM_COMMIT, this.PAGE_READWRITE)
        _txt := this.VirtualAllocEx(hProcess, 0, 256,  this.MEM_COMMIT, this.PAGE_READWRITE)

        ; TVITEMEX Structure
        VarSetCapacity(tvi, Size, 0)
        NumPut(this.TVIF_TEXT|this.TVIF_HANDLE, tvi, 0, "UInt")
        If (ProcessIs32Bit){
            NumPut(pItem, tvi,  4, "UInt")
            NumPut(_txt , tvi, 16, "UInt")
            NumPut(127  , tvi, 20, "UInt")
        } Else {
            NumPut(pItem, tvi,  8, "UInt64")
            NumPut(_txt , tvi, 24, "UInt64")
            NumPut(127  , tvi, 32, "UInt")
        }

        VarSetCapacity(txt, 256, 0)
        this.WriteProcessMemory(hProcess, _tvi, &tvi, Size)
        SendMessage this.TVM_GETITEM, 0, _tvi, ,  % "ahk_id " this.TVHwnd
        this.ReadProcessMemory(hProcess, _txt, txt, 256)

        this.VirtualFreeEx(hProcess, _txt, 0, this.MEM_RELEASE)
        this.VirtualFreeEx(hProcess, _tvi, 0, this.MEM_RELEASE)
        this.CloseHandle(hProcess)

        return txt
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: EditLabel
    ;         Begins in-place editing of the specified item's text, replacing the text of the
    ;         item with a single-line edit control containing the text. This method implicitly
    ;         selects and focuses the specified item.
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Returns the handle to the edit control used to edit the item text if successful,
    ;         or NULL otherwise. When the user completes or cancels editing, the edit control
    ;         is destroyed and the handle is no longer valid.
    ;
    EditLabel(pItem){
        this.TVM_EDITLABEL := A_IsUnicode ? this.TVM_EDITLABELW : this.TVM_EDITLABELA
        SendMessage this.TVM_EDITLABEL, 0, pItem, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetCount
    ;         Returns the total number of expanded items in the control
    ;
    ; Parameters:
    ;         None
    ;
    ; Returns:
    ;         Returns the total number of expanded items in the control
    ;
    GetCount(){
        SendMessage this.TVM_GETCOUNT, 0, 0, , % "ahk_id " this.TVHwnd
        return ErrorLevel
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: IsChecked
    ;         Retrieves an item's checked status
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ;         Force			- If true (default), forces the node to return a valid state.
    ;                         Since this involves toggling the state of the check box, it
    ;                         can have undesired side effects. Make this false to disable
    ;                         this feature.
    ; Returns:
    ;         Returns 1 if the item is checked, 0 if unchecked.
    ;
    ;         Returns -1 if the checkbox state cannot be determined because no checkbox
    ;         image is currently associated with the node and Force is false.
    ;
    ; Remarks:
    ;         Due to a "feature" of Windows, a checkbox can be displayed even if no checkbox image
    ;         is associated with the node. It is important to either check the actual value returned
    ;         or make the Force parameter true.
    ;
    ;         This method makes pItem the current selection.
    ;
    IsChecked(pItem, Force = true){
        SavedDelay := A_KeyDelay
        SetKeyDelay 30

        this.SetSelection(pItem)
        SendMessage this.TVM_GETITEMSTATE, pItem, 0, , % "ahk_id " this.TVHwnd
        State := ((ErrorLevel & this.TVIS_STATEIMAGEMASK) >> 12) - 1

        if (State = -1 and Force) {
            ControlSend, , {Space 2}, % "ahk_id " this.TVHwnd
            SendMessage this.TVM_GETITEMSTATE, pItem, 0, , % "ahk_id " this.TVHwnd
            State := ((ErrorLevel & this.TVIS_STATEIMAGEMASK) >> 12) - 1
        }

        SetKeyDelay %SavedDelay%
        return State
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: IsBold
    ;         Check if a node is in bold font
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Returns true if the item is in bold, false otherwise.
    ;
    IsBold(pItem){
        SendMessage this.TVM_GETITEMSTATE, pItem, 0, , % "ahk_id " this.TVHwnd
        return (ErrorLevel & this.TVIS_BOLD) >> 4
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: IsExpanded
    ;         Check if a node has children and is expanded
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Returns true if the item has children and is expanded, false otherwise.
    ;
    IsExpanded(pItem){
        SendMessage this.TVM_GETITEMSTATE, pItem, 0, , % "ahk_id " this.TVHwnd
        return (ErrorLevel & this.TVIS_EXPANDED) >> 5
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: IsSelected
    ;         Check if a node is Selected
    ;
    ; Parameters:
    ;         pItem			- Handle to the item
    ;
    ; Returns:
    ;         Returns true if the item is selected, false otherwise.
    ;
    IsSelected(pItem){
        SendMessage, this.TVM_GETITEMSTATE, pItem, 0, , % "ahk_id " this.TVHwnd
        return (ErrorLevel & this.TVIS_SELECTED) >> 1
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: GetControlContent
    ;     Returns a text representation of the control content, indented with tabs.
    ;
    ; Parameters:
    ;         Level         - (Optional) Indention level
    ;         pItem   - (Optional) Handle to the starting item
    ;
    ; Returns:
    ;         A text representation of the control content

    GetControlContent(Level:=0, pItem:=0){
        passed := false
        ControlText =

        loop {
            SendMessage this.TVM_GETNEXTITEM, passed ? this.TVGN_NEXT : this.TVGN_CHILD , pItem, , % "ahk_id " this.TVHwnd
            if(ErrorLevel != 0){
                pItem := ErrorLevel

                while (A_Index < Level) {
                    ControlText .= "`t"
                }
                ControlText .= this.GetText(pItem) "`n"
                ; ControlText .= RegexReplace(this.GetText(pItem),"[-\.]","`t",donechanges,1) . "`n"
                NextLevel := Level+1

                ControlText .= this.GetControlContent(NextLevel,pItem, LowestLevel)
                passed=true
            } else {
                break
            }
        }

        return ControlText
    }

    ;==================================================================================================
    ;
    ;	Functions
    ;
    ;==================================================================================================

    ;----------------------------------------------------------------------------------------------
    ; Method: OpenProcess
    ;         Opens an existing local process object.
    ;
    ; Parameters:
    ;         DesiredAccess - The desired access to the process object.
    ;
    ;         InheritHandle - If this value is TRUE, processes created by this process will inherit
    ;                         the handle. Otherwise, the processes do not inherit this handle.
    ;
    ;         ProcessId     - The Process ID of the local process to be opened.
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is an open handle to the specified process.
    ;         If the Method fails, the return value is NULL.
    ;
    OpenProcess(DesiredAccess, InheritHandle, ProcessId){
        return DllCall("OpenProcess"
            , "Int", DesiredAccess
            , "Int", InheritHandle
            , "Int", ProcessId
            , "Ptr")
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: CloseHandle
    ;         Closes an open object handle.
    ;
    ; Parameters:
    ;         hObject       - A valid handle to an open object
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is nonzero.
    ;         If the Method fails, the return value is zero.
    ;
    CloseHandle(hObject){
        return DllCall("CloseHandle"
            , "Ptr", hObject
            , "Int")
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: VirtualAllocEx
    ;         Reserves or commits a region of memory within the virtual address space of the
    ;         specified process, and specifies the NUMA node for the physical memory.
    ;
    ; Parameters:
    ;         hProcess      - A valid handle to an open object. The handle must have the
    ;                         PROCESS_VM_OPERATION access right.
    ;
    ;         Address       - The pointer that specifies a desired starting address for the region
    ;                         of pages that you want to allocate.
    ;
    ;                         If you are reserving memory, the Method rounds this address down to
    ;                         the nearest multiple of the allocation granularity.
    ;
    ;                         If you are committing memory that is already reserved, the Method rounds
    ;                         this address down to the nearest page boundary. To determine the size of a
    ;                         page and the allocation granularity on the host computer, use the GetSystemInfo
    ;                         function.
    ;
    ;                         If Address is NULL, the function determines where to allocate the region.
    ;
    ;         Size          - The size of the region of memory to be allocated, in bytes.
    ;
    ;         AllocationType - The type of memory allocation. This parameter must contain ONE of the
    ;                          following values:
    ;								MEM_COMMIT
    ;								MEM_RESERVE
    ;								MEM_RESET
    ;
    ;         ProtectType   - The memory protection for the region of pages to be allocated. If the
    ;                         pages are being committed, you can specify any one of the memory protection
    ;                         constants:
    ;								 PAGE_NOACCESS
    ;								 PAGE_READONLY
    ;								 PAGE_READWRITE
    ;								 PAGE_WRITECOPY
    ;								 PAGE_EXECUTE
    ;								 PAGE_EXECUTE_READ
    ;								 PAGE_EXECUTE_READWRITE
    ;								 PAGE_EXECUTE_WRITECOPY
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is the base address of the allocated region of pages.
    ;         If the Method fails, the return value is NULL.
    ;
    VirtualAllocEx(hProcess, Address, Size, AllocationType, ProtectType){
        return DllCall("VirtualAllocEx"
            , "Ptr", hProcess
            , "Ptr", Address
            , "UInt", Size
            , "UInt", AllocationType
            , "UInt", ProtectType
            , "Ptr")
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: VirtualFreeEx
    ;         Releases, decommits, or releases and decommits a region of memory within the
    ;         virtual address space of a specified process
    ;
    ; Parameters:
    ;         hProcess      - A valid handle to an open object. The handle must have the
    ;                         PROCESS_VM_OPERATION access right.
    ;
    ;         Address       - The pointer that specifies a desired starting address for the region
    ;                         to be freed. If the dwFreeType parameter is MEM_RELEASE, lpAddress
    ;                         must be the base address returned by the VirtualAllocEx Method when
    ;                         the region is reserved.
    ;
    ;         Size          - The size of the region of memory to be allocated, in bytes.
    ;
    ;                         If the FreeType parameter is MEM_RELEASE, dwSize must be 0 (zero). The Method
    ;                         frees the entire region that is reserved in the initial allocation call to
    ;                         VirtualAllocEx.
    ;
    ;                         If FreeType is MEM_DECOMMIT, the Method decommits all memory pages that
    ;                         contain one or more bytes in the range from the Address parameter to
    ;                         (lpAddress+dwSize). This means, for example, that a 2-byte region of memory
    ;                         that straddles a page boundary causes both pages to be decommitted. If Address
    ;                         is the base address returned by VirtualAllocEx and dwSize is 0 (zero), the
    ;                         Method decommits the entire region that is allocated by VirtualAllocEx. After
    ;                         that, the entire region is in the reserved state.
    ;
    ;         FreeType      - The type of free operation. This parameter can be one of the following values:
    ;								MEM_DECOMMIT
    ;								MEM_RELEASE
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is a nonzero value.
    ;         If the Method fails, the return value is 0 (zero).
    ;
    VirtualFreeEx(hProcess, Address, Size, FType){
        return DllCall("VirtualFreeEx"
            , "Ptr", hProcess
            , "Ptr", Address
            , "UINT", Size
            , "UInt", FType
            , "Int")
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: WriteProcessMemory
    ;         Writes data to an area of memory in a specified process. The entire area to be written
    ;         to must be accessible or the operation fails
    ;
    ; Parameters:
    ;         hProcess      - A valid handle to an open object. The handle must have the
    ;                         PROCESS_VM_WRITE and PROCESS_VM_OPERATION access right.
    ;
    ;         BaseAddress   - A pointer to the base address in the specified process to which data
    ;                         is written. Before data transfer occurs, the system verifies that all
    ;                         data in the base address and memory of the specified size is accessible
    ;                         for write access, and if it is not accessible, the Method fails.
    ;
    ;         Buffer        - A pointer to the buffer that contains data to be written in the address
    ;                         space of the specified process.
    ;
    ;         Size          - The number of bytes to be written to the specified process.
    ;
    ;         NumberOfBytesWritten
    ;                       - A pointer to a variable that receives the number of bytes transferred
    ;                         into the specified process. This parameter is optional. If NumberOfBytesWritten
    ;                         is NULL, the parameter is ignored.
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is a nonzero value.
    ;         If the Method fails, the return value is 0 (zero).
    ;
    WriteProcessMemory(hProcess, BaseAddress, Buffer, Size, ByRef NumberOfBytesWritten = 0){
        return DllCall("WriteProcessMemory"
            , "Ptr", hProcess
            , "Ptr", BaseAddress
            , "Ptr", Buffer
            , "Uint", Size
            , "UInt*", NumberOfBytesWritten
            , "Int")
    }

    ;----------------------------------------------------------------------------------------------
    ; Method: ReadProcessMemory
    ;         Reads data from an area of memory in a specified process. The entire area to be read
    ;         must be accessible or the operation fails
    ;
    ; Parameters:
    ;         hProcess      - A valid handle to an open object. The handle must have the
    ;                         PROCESS_VM_READ access right.
    ;
    ;         BaseAddress   - A pointer to the base address in the specified process from which to
    ;                         read. Before any data transfer occurs, the system verifies that all data
    ;                         in the base address and memory of the specified size is accessible for read
    ;                         access, and if it is not accessible the Method fails.
    ;
    ;         Buffer        - A pointer to a buffer that receives the contents from the address space
    ;                         of the specified process.
    ;
    ;         Size          - The number of bytes to be read from the specified process.
    ;
    ;         NumberOfBytesWritten
    ;                       - A pointer to a variable that receives the number of bytes transferred
    ;                         into the specified buffer. If lpNumberOfBytesRead is NULL, the parameter
    ;                         is ignored.
    ;
    ; Returns:
    ;         If the Method succeeds, the return value is a nonzero value.
    ;         If the Method fails, the return value is 0 (zero).
    ;
    ReadProcessMemory(hProcess, BaseAddress, ByRef Buffer, Size, ByRef NumberOfBytesRead = 0){
        return DllCall("ReadProcessMemory"
            , "Ptr", hProcess
            , "Ptr", BaseAddress
            , "Ptr", &Buffer
            , "UInt", Size
            , "UInt*", NumberOfBytesRead
            , "Int")
    }

}