<p align="center">
    <img src="https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/logo.png" alt="BOpenliveSDK-AIR" width="128">
</p>

[![License](https://img.shields.io/badge/Version-1.0.0-orange)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![AIR Version](https://img.shields.io/badge/AIR-51.0+-darkred.svg)](https://airsdk.harman.com)

# BOpenliveSDK-AIR

BOpenliveSDK-AIR是用于<b>AIR项目接入哔哩哔哩直播开放平台</b>的SDK。

---

## 环境与依赖项

* [AIR SDK](https://airsdk.harman.com/release_notes) 51.0或更高版本

## 开发者文档

[BOpenliveSDK-AIR 1.0 API 参考文档](https://shaucky.github.io/BOpenliveSDK-AIR/)

## 快速开始

项目目录下包含一个`demo`目录，该目录下提供的示例依赖于Adobe Animate工具，但也可以提取其中部分资源仅依靠AIR SDK自行开发。

该目录下已包含`BOpenliveSDK.swc`，即BOpenliveSDK-AIR的程序集。

### 使用Animate开始

首先需要确保Animate已经配置了51.0或更高版本的AIR SDK。在管理AIR SDK面板（`Help` > `Manage AIR SDK`）中添加AIR SDK的路径，并点击确定。

通过Animate打开`demo/Demo.fla`文档。

在时间轴面板（`Window` > `Timeline`）中选中文档场景的第1帧，然后打开动作面板（`Window` > `Actions`），在脚本中填入key、secret和项目ID。

![](https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/quickstartwithanimate_1.png)

测试影片（`Control` > `Test Movie` > `Test`）。

![](https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/quickstartwithanimate_2.png)

### 使用AIR SDK开始

在`demo`目录下提供的`bOpenliveAuthPanel.swf`可供其它AIR项目加载使用，其中包含一个显示对象，并提供了用户交互相关的事件派发。具体来说：

1. 用户点击开始游戏按钮派发`Event.CONNECT`；
2. 用户点击记住身份码单选框派发`Event.CHANGE`；
3. 面板过渡动画播放完毕派发`Event.COMPLETE`；
4. 更多事件遵循AIR运行时API的派发约定。
