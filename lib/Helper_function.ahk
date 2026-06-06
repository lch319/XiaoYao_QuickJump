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
    pdwEffect := (A_PtrSize == 8) ? p5 : p6
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1
    return 0
}
IDropTarget_DragOver(this, grfKeyState, p3, p4, p5="") {
    pdwEffect := (A_PtrSize == 8) ? p4 : p5
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1
    return 0
}
IDropTarget_DragLeave(this) {
    return 0
}
IDropTarget_Drop(this, pDataObj, grfKeyState, p4, p5, p6="") {
    pdwEffect := (A_PtrSize == 8) ? p5 : p6
    NumPut(1, pdwEffect+0, "UInt") ; DROPEFFECT_COPY = 1
    
    ; 核心：解析释放时的 IDataObject 内存数据
    ParseDataObject(pDataObj)
    return 0
}

; 7. 数据解析核心：直接读取系统 OLE 内存，绝不触碰 Clipboard
; =================================================================
ParseDataObject(pDataObj) {
    ; IDataObject::GetData 位于虚函数表的第 4 个位置 (Index 3)
    IDataObject_GetData := NumGet(NumGet(pDataObj+0, "Ptr") + 3*A_PtrSize, "Ptr")
    
    ; --- 尝试读取 文本 (CF_UNICODETEXT = 13) ---
    VarSetCapacity(FORMATETC, A_PtrSize == 8 ? 32 : 20, 0)
    NumPut(13, FORMATETC, 0, "UShort")
    NumPut(1, FORMATETC, A_PtrSize == 8 ? 16 : 8, "UInt")   ; DVASPECT_CONTENT
    NumPut(-1, FORMATETC, A_PtrSize == 8 ? 20 : 12, "Int")  ; lindex
    NumPut(1, FORMATETC, A_PtrSize == 8 ? 24 : 16, "UInt")  ; TYMED_HGLOBAL
    VarSetCapacity(STGMEDIUM, A_PtrSize == 8 ? 24 : 12, 0)
    
    if (DllCall(IDataObject_GetData, "Ptr", pDataObj, "Ptr", &FORMATETC, "Ptr", &STGMEDIUM) = 0) {
        hGlobal := NumGet(STGMEDIUM, A_PtrSize == 8 ? 8 : 4, "Ptr")
        pData := DllCall("GlobalLock", "Ptr", hGlobal, "Ptr")
        droppedText := StrGet(pData, "UTF-16")
        DllCall("GlobalUnlock", "Ptr", hGlobal)
        DllCall("ole32\ReleaseStgMedium", "Ptr", &STGMEDIUM)
        
        OnDropText(droppedText)
        return
    }
    
    ; --- 尝试读取 文件/文件夹 (CF_HDROP = 15) ---
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
        
        OnDropFiles(droppedFiles)
        return
    }
}