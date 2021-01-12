## iOS 触觉体验的使用

### 1. 触感反馈的使用（UIFeedbackGenerator）
> #### 提示：UIFeedbackGenerator 在 iOS 10.0 及以后可用。


#### 1.1 触感反馈工具类 FeedbackGeneatorUtil 的使用流程
1. 导入```FeedbackGeneatorUtil```类；
2. 确定需要触感反馈的操作；
3. 在操作事件中调用```FeedbackGeneatorUtil```的方法即可产生触感反馈，代码如下:

```
# 产生触感反馈，该方法默认为中度反馈
[FeedbackGeneatorUtil generateImpactFeedback];

# 根据传入的触感反馈类型产生触感反馈
[FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
```

#### 1.2 触感反馈使用建议

| 触感反馈强度 | 建议的操作 | 示例使用场景 |
|:----------:|:---------|:----------:|
| UIImpactFeedbackStyleLight <br> 轻度反馈 | 1. 选中操作 | ↴ |
| | | UITableView列表选中某一行时 |
| | | 登录、注册等页面，点击密码显示/隐藏按钮时 |
| | 2. 成功操作 | ↴ |
| | | 设备打开/关闭时 |
| | 3. 失败操作 | ↴ |
| | | 接口获取数据失败时 |
| UIImpactFeedbackStyleMedium <br> 中度反馈 | 1. 一般弹窗提示操作 | ↴ |
| | | 点击退出登录按钮，弹出提示弹窗时 |
| | | 两次密码输入不一致，弹出提示弹窗时 |
| | 2. 成功操作 | ↴ |
| | | 扫码识别成功时 |
| UIImpactFeedbackStyleHeavy <br> 重度反馈 | 1. 删除操作 | ↴ |
| | | 点击删除设备按钮，弹出提示弹窗时 |
| | | 点击注销账户按钮，弹出提示弹窗时 |

> 示例使用场景，并不是每个场景都需要使用，可根据App使用体验自行决定何时、何地使用。

### 2. 触觉引擎的使用（CoreHaptic）
> #### 提示：CoreHaptic 在 iOS 13.0 及以后可用。

#### 2.1 触觉引擎的使用流程

1. 判断设备是否支持触觉引擎；
2. 创建触觉引擎；
3. 创建触觉事件模式；
4. 创建模式播放器；
5. 启动触觉引擎；
6. 开启模式播放器,开始产生触觉体验；
7. 停止触觉引擎；

> 具体代码参考 CoreHapticsUtil 类 及 Core Haptics -> Examples 中的代码。
> 