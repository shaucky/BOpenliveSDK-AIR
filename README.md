<p align="center">
    <img src="https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/logo.png" alt="BOpenliveSDK-AIR" width="128">
</p>

[![Project Version](https://img.shields.io/badge/Version-1.0.1-orange)]()
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

项目目录下包含一个`demo`目录，该目录下提供的示例依赖于Adobe Animate工具，但也可以提取其中部分资源仅依靠AIR SDK自行集成。

`demo`目录下也包含`BOpenliveSDK.swc`，即BOpenliveSDK-AIR的程序集。

### 使用Animate开始

首先需要确保Animate已经配置了51.0或更高版本的AIR SDK。在管理AIR SDK面板（`Help` > `Manage AIR SDK`）中添加AIR SDK的路径，并点击确定。

通过Animate打开`demo/Demo.fla`文档。

在时间轴面板（`Window` > `Timeline`）中选中文档场景的第1帧，然后打开动作面板（`Window` > `Actions`），在脚本中填入key、secret和项目ID。

![](https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/quickstartwithanimate_1.png)

测试影片（`Control` > `Test Movie` > `Test`）。

![](https://raw.githubusercontent.com/shaucky/BOpenliveSDK-AIR/refs/heads/v2/readme/quickstartwithanimate_2.png)

### 使用AIR SDK开始

有许多支持使用AIR SDK开发的工具，例如VS Code、IDEA等。它们支持纯ActionScript代码开发而不依赖Animate的FLA文档动画。如何使用这些工具开发AIR项目并不在本文档的职能之内。此处只简单说明这些工具接入BOpenliveSDK-AIR的思路。

（以下示例默认VS Code已安装ActionScript & MXML扩展）

将该仓库克隆或下载到本地，然后将根目录下的`src`目录设为编译路径。例如在VS Code中，需要在`asconfig.json`的`compilerOptions`对象内的`source-path`数组中正确添加`src`的路径。

或者，也可以提取`demo`目录下的`BOpenliveSDK.swc`，然后将其设为库路径。例如在VS Code中，需要在`asconfig.json`的`compilerOptions`对象内的`library-path`数组中正确添加`BOpenliveSDK.swc`的路径。

完成上述步骤后，BOpenliveSDK-AIR的核心库已经可以编译至项目中。

如果还需要使用遵循官方身份码界面设计规范的显示对象，在`demo`目录下提供的`bOpenliveAuthPanel.swf`可作为认证面板界面加载使用。其中包含一个显示对象，提供用户交互相关的事件派发，但不包含任何实际业务。具体来说：

1. 用户点击开始游戏按钮派发`Event.CONNECT`，可通过公共变量`code`获取填写的身份码；
2. 用户点击记住身份码选框派发`Event.CHANGE`，可通过公共变量`checkmark`获取勾选状态；
3. 面板过渡动画播放完毕派发`Event.COMPLETE`；
4. 更多事件遵循AIR运行时API的派发约定。

更多使用方式可参考`demo/biliopenlive/display/BOpenliveAuthPanel.as`的实现。