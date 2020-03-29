//
//  ViewController.m
//  BWSwitchServer
//
//  Created by wangzhi. on 2020/3/29.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import "ViewController.h"
#import <SafariServices/SafariServices.h>
#import "Common.h"

@interface ViewController () <SFSafariViewControllerDelegate>

@property (nonatomic, strong) UILabel *environmentLabel;
@property (nonatomic, strong) UILabel *urlStringLabel;
@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UIButton *switchButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [self setupUI];
    
    // 宏定义 APP_URL_HEAD 为服务器地址,就是你想要通过 设置束 来进行切换控制的值,
    // 当然你也可以自己决定要切换控制什么值.
    self.urlStringLabel.text = APP_URL_HEAD;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat x = 10;
    CGFloat y = 90;
    CGFloat w = width - 2 * x;
    
    self.environmentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, 24)];
    self.environmentLabel.textColor = [UIColor blackColor];
    self.environmentLabel.text = @"当前服务器环境(URL String):";
    
    y = CGRectGetMaxY(self.environmentLabel.frame) + 20;
    self.urlStringLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, 24)];
    self.urlStringLabel.textColor = [UIColor blackColor];
    self.urlStringLabel.textAlignment = NSTextAlignmentCenter;
    
    y = CGRectGetMaxY(self.urlStringLabel.frame) + 50;
    self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake((width - 200) * 0.5, y, 200, 44)];
    [self.checkButton setTitle:@"验证服务器环境" forState:UIControlStateNormal];
    [self.checkButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.checkButton.backgroundColor = [UIColor colorWithRed:9 / 255.0 green:143 / 255.0 blue:235 / 255.0 alpha:1.0];
    [self.checkButton addTarget:self action:@selector(checkServerEnvironmentEvent) forControlEvents:UIControlEventTouchUpInside];
    
    y = CGRectGetMaxY(self.checkButton.frame) + 20;
    self.switchButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.checkButton.frame), y, CGRectGetWidth(self.checkButton.frame), CGRectGetHeight(self.checkButton.frame))];
    [self.switchButton setTitle:@"去切换服务器环境" forState:UIControlStateNormal];
    [self.switchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.switchButton.backgroundColor = self.checkButton.backgroundColor;
    [self.switchButton addTarget:self action:@selector(switchServerEnvironmentEvent) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.environmentLabel];
    [self.view addSubview:self.urlStringLabel];
    [self.view addSubview:self.checkButton];
    [self.view addSubview:self.switchButton];
}


#pragma mark - Events

/// 验证服务器环境
- (void)checkServerEnvironmentEvent {
    NSString *urlString = APP_URL_HEAD;
    
    SFSafariViewControllerConfiguration *config = [[SFSafariViewControllerConfiguration alloc] init];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString] configuration:config];
    safariVC.delegate = self;
    [self presentViewController:safariVC animated:YES completion:nil];
}

/// 去设置页面切换服务器环境
- (void)switchServerEnvironmentEvent {
    [ViewController jumpToApplicationSettingPage];
}



#pragma mark - NSNotifications

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    self.urlStringLabel.text = APP_URL_HEAD;
}


#pragma mark - SFSafariViewControllerDelegate

- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    NSLog(@"SafariViewController did complete initial load: %@", didLoadSuccessfully ? @"YES" : @"NO");
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    // 点击完成按钮,退出了SFSafariViewController
}



#pragma mark - Tool Methods

/// 跳转到应用的设置页面
+ (void)jumpToApplicationSettingPage {
    NSURL *settingURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if (@available(iOS 10.0, *)) { // iOS 10及其以后系统运行
        [[UIApplication sharedApplication] openURL:settingURL options:@{} completionHandler:nil];
    } else {
//        [[UIApplication sharedApplication] openURL:settingURL];
    }
}

@end
