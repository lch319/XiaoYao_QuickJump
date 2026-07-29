; WPS custom file dialog support through Microsoft UI Automation.

WPS_IsSupportedProcess(Hwnd) {
    WinGet, ProcessName, ProcessName, % "ahk_id " Hwnd
    StringLower, ProcessName, ProcessName
    Return (ProcessName = "wps.exe"
        or ProcessName = "et.exe"
        or ProcessName = "wpp.exe"
        or ProcessName = "wpspdf.exe")
}

WPS_AddFileDialogWindowRules(ByRef Windows) {
    for _, ProcessName in ["wps.exe", "et.exe", "wpp.exe", "wpspdf.exe"]
        Windows.Push("ahk_class Qt5QWindowIcon ahk_exe " ProcessName)
}

WPS_GetUIA() {
    static UIA := ""
    if !IsObject(UIA)
        UIA := UIA_Interface()
    Return UIA
}

WPS_GetFileDialogElement(Hwnd, ByRef DialogHwnd := "") {
    DialogHwnd := ""
    if (!Hwnd || !WPS_IsSupportedProcess(Hwnd))
        Return

    Candidates := [Hwnd]
    OwnerHwnd := DllCall("user32\GetWindow", "Ptr", Hwnd, "UInt", 4, "Ptr") ; GW_OWNER
    ParentHwnd := DllCall("user32\GetParent", "Ptr", Hwnd, "Ptr")
    if OwnerHwnd
        Candidates.Push(OwnerHwnd)
    if ParentHwnd
        Candidates.Push(ParentHwnd)

    try UIA := WPS_GetUIA()
    catch e
        Return

    for _, CandidateHwnd in Candidates {
        if (!CandidateHwnd || !WPS_IsSupportedProcess(CandidateHwnd))
            Continue
        try DialogElement := UIA.ElementFromHandle(CandidateHwnd, false)
        catch e
            Continue
        if !IsObject(DialogElement)
            Continue
        try ClassName := DialogElement.CurrentClassName
        catch e
            Continue
        if (ClassName = "KcfdFileDialog") {
            DialogHwnd := CandidateHwnd
            Return DialogElement
        }
    }
}

WPS_IsFileDialog(Hwnd) {
    static LastHwnd := "", LastCheckTime := 0, LastResult := false
    if ((Hwnd = LastHwnd) && ((A_TickCount - LastCheckTime) < 150))
        Return LastResult

    DialogElement := WPS_GetFileDialogElement(Hwnd, DialogHwnd)
    LastHwnd := Hwnd
    LastCheckTime := A_TickCount
    LastResult := IsObject(DialogElement) && DialogHwnd
    Return LastResult
}

WPS_FindFileNameEdit(DialogElement, TimeoutMs := 500) {
    if !IsObject(DialogElement)
        Return

    StartTime := A_TickCount
    Conditions := ["ClassName=QLineEdit", "ClassName=kd::KDTextField", "ControlType=Edit"]
    Loop {
        try FilterWidget := DialogElement.FindFirst("ClassName=KcfdFilterWidget")
        catch e
            FilterWidget := ""

        if IsObject(FilterWidget) {
            for _, Condition in Conditions {
                try Editor := FilterWidget.FindFirst(Condition)
                catch e
                    Editor := ""
                if IsObject(Editor) {
                    try IsEnabled := Editor.CurrentIsEnabled
                    catch e
                        IsEnabled := false
                    if IsEnabled
                        Return Editor
                }
            }
        }

        if ((A_TickCount - StartTime) >= TimeoutMs)
            Break
        Sleep, 50
    }
}

WPS_RestoreFileName(DialogHwnd, OldText, SelectedPath) {
    Sleep, 100
    Loop, 20 {
        if !WinExist("ahk_id " DialogHwnd)
            Return

        DialogElement := WPS_GetFileDialogElement(DialogHwnd, CurrentDialogHwnd)
        Editor := WPS_FindFileNameEdit(DialogElement, 0)
        if IsObject(Editor) {
            try CurrentText := Editor.CurrentValue
            catch e
                CurrentText := SelectedPath

            if ((CurrentText != SelectedPath) || (A_Index = 20)) {
                try Editor.SetValue(OldText)
                Return
            }
        }
        Sleep, 50
    }
}

FeedDialogWPS(DialogHwnd, SelectedPath) {
    if (SelectedPath = "")
        Return false

    DialogElement := WPS_GetFileDialogElement(DialogHwnd, ActualDialogHwnd)
    if !IsObject(DialogElement) {
        ttip("WPS 文件浏览框识别失败", 3000)
        Return false
    }

    Editor := WPS_FindFileNameEdit(DialogElement)
    if !IsObject(Editor) {
        ttip("WPS 文件名输入框识别失败", 3000)
        Return false
    }

    try {
        OldText := Editor.CurrentValue
        Editor.SetValue(SelectedPath)
        if (Editor.CurrentValue != SelectedPath)
            throw Exception("Failed to set WPS file name edit")

        WinActivate, % "ahk_id " ActualDialogHwnd
        WinWaitActive, % "ahk_id " ActualDialogHwnd, , 1
        if !WinActive("ahk_id " ActualDialogHwnd)
            throw Exception("WPS file dialog is not active")

        DialogElement.SetFocus()
        Editor.SetFocus()
        SendInput, {Enter}
        WPS_RestoreFileName(ActualDialogHwnd, OldText, SelectedPath)
        Return true
    } catch e {
        ttip("WPS 文件浏览框跳转失败", 3000)
        Return false
    }
}
