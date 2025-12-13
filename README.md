# XiaoYao_快速跳转 - 文件对话框路径直达利器

> 在打开或保存对话框中，快速跳转到当前 资源管理器/TC/DO/XY/Q-Dir中打开的文件夹路径

<p align="center">
  <img src="https://raw.githubusercontent.com/lch319/cangku1/refs/heads/master/%E6%BC%94%E7%A4%BA%E5%9B%BE.gif" alt="功能演示" width="100%">
  <br>
  <a href="https://www.bilibili.com/video/BV1Q9tZzzEP6/">▶️ 视频演示</a> | 
  <a href="https://qm.qq.com/q/nXfaKokxEI">💬 QQ群</a>  
</p>


##  核心功能
在 **打开/保存对话框** 中一键直达：
- 资源管理器 / Total Commander (TC) / Double Commander (DC) / **Directory Opus (DO)** / XYplorer / Q-Dir 的当前路径  
- ⭐ 特别适配 DO 文件管理器的收藏夹功能

##  功能亮点

### 智能跟随
 - 在文件对话框激活时，自动弹出路径跳转窗口（可设置）。

###  快捷键操作
- 仅文件对话框生效的快捷键。可在“设置”中自由修改快捷键。
- 支持设置全局快捷键，随时可用。

| 快捷键     | 功能描述                                                 |
| ---------- | -------------------------------------------------------- |
| `Ctrl + G` | 呼出路径菜单（包含常用路径、资源管理器路径、DO收藏夹等） |
| `Ctrl + F` | 直接跳转到当前活动路径                                   |
| `Ctrl + D` | 呼出常驻跟随窗口                                         |

###  智能特性

- **路径记忆**： 可设置每次打开“另存为”对话框时，自动跳转到上次使用的路径或固定的默认路径。([自动跳转默认路径 图])

![自动跳转默认路径 图](https://raw.githubusercontent.com/lch319/cangku1/refs/heads/master/%E8%87%AA%E5%8A%A8%E8%B7%B3%E8%BD%AC%E5%88%B0%E9%BB%98%E8%AE%A4.jpg)

- **广泛兼容**： 支持多种常见文件对话框类型（[支持的窗口类型图]）。

![支持窗口类型 图](https://raw.githubusercontent.com/lch319/cangku1/refs/heads/master/%E6%94%AF%E6%8C%81%E7%AA%97%E5%8F%A3%E6%8B%BC%E5%9B%BE.jpg)

- **灵活扩展**： 对于不支持自动弹出的特殊对话框，支持在设置中手动添加窗口规则（[手动添加窗口动态图]）。

![手动添加窗口动态图](https://github.com/lch319/cangku1/blob/master/%E6%89%8B%E5%8A%A8%E6%B7%BB%E5%8A%A0%E7%AA%97%E5%8F%A3.gif?raw=true)

- **专属常用路径**：仅在指定程序才显示的常用路径，达到不同程序显示不同路径的目的

  ![专属路径](https://github.com/user-attachments/assets/a5b439bc-0575-469b-8017-362d7d5c5da6)


- **支持深色主题**：可设置跟随系统自动切换

<img width="1163" height="590" alt="暗色主题" src="https://github.com/user-attachments/assets/824a2783-a6f9-4662-855d-46277a9a64cf" />

###  使用说明

**在Double Commander中的设置步骤**：
		1.进入【配置】-【选项】-【工具栏】，点击“插入新的按钮”
		2.命令选择 cm_ExecuteScript，参数填写 get_tabs.lua 的完整路径（例如 D:\XiaoYao_快速跳转\辅助\get_tabs.lua），热键可设置为 Ctrl+Shift+F12
		3.在【配置】-【选项】-【杂项】中，勾选“在主窗口标题栏中显示当前目录”

# 致谢 (灵感与参考)：

本工具的开发借鉴或使用了以下优秀项目的思路和代码，在此深表感谢：

- RunAny: https://github.com/hui-Zz/RunAny

- QuickSwitch: https://github.com/gepruts/QuickSwitch

- Autohotkey 社区讨论: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=124771
