# BWDemo

存放一些示例工程。


## 1. BWSwitchServer - 切换服务器环境

在App的系统设置页面（设置 -> Demo -> "Demo"设置）中添加切换服务器环境的开关。

<img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/Switch_Server.gif" width="255" height="453">


## 2. LogExportDemo - 日志导出

两行代码实现在页面控制器```ViewController```中导出日志。

```
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 开始日志记录
    [BWLogExportManagerShared addExportButtonInViewController:self];
    [BWLogExportManagerShared startLogRecord];
}

```

<img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/Log_Export.gif" width="255" height="453">  <img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/Log_View.gif" width="255" height="453">


## 3. LocationDemo - iOS14定位问题导致WiFi名称获取不到的情况

<img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/LocationDemo_1.PNG" width="255" height="552">    <img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/LocationDemo_2.PNG" width="255" height="552">


## 4. Haptics - Core Haptics 触觉引擎的使用

```
# 产生触感反馈，该方法默认为中度反馈
[FeedbackGeneatorUtil generateImpactFeedback];

# 根据传入的触感反馈类型产生触感反馈
[FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
```

<img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/CoreHaptics_01.PNG" width="255" height="552">  <img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/CoreHaptics_02.PNG" width="255" height="552">
<img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/CoreHaptics_03.gif" width="255" height="552">  <img src="https://github.com/wz15011015/BWDemo/blob/master/Resources/Screenshots/CoreHaptics_04.gif" width="255" height="552">