#NoEnv
;#Persistent ;~让脚本持久运行
#NoTrayIcon ;~不显示托盘图标
#SingleInstance,Force ;~运行替换旧实例

run,"%A_ScriptDir%\XiaoYao_快速跳转.exe" "%A_ScriptDir%\主程序.ahk"
/*
OnExit, 退出时运行
Return

退出时运行:
    run,%comSpec% /c taskkill /f /im XiaoYao_快速跳转.exe,,Hide
ExitApp
Return
*/