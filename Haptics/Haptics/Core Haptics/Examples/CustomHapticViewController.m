//
//  CustomHapticViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/12/10.
//

#import "CustomHapticViewController.h"
#import "CoreHapticsUtil.h"
#import <AVFoundation/AVFoundation.h>

@interface CustomHapticViewController ()

@property (nonatomic, assign) CGFloat windowWidth;
@property (nonatomic, assign) CGFloat windowHeight;

// 触觉引擎
@property (nonatomic, strong) CHHapticEngine *engine;

@property (nonatomic, strong) NSArray *ahapFilenames;

@end

@implementation CustomHapticViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Custom Haptic";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    
    [self layoutButtons];
    
    // 创建并启动触觉引擎
    [self createAndStartHapticEngine];
}

- (void)initData {
    self.windowWidth = [UIScreen mainScreen].bounds.size.width;
    self.windowHeight = [UIScreen mainScreen].bounds.size.height - 88;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.ahapFilenames = @[
        @"Sparkle", @"Boing", @"Gravel", @"Oscillate",
        @"Heartbeats", @"Inflate", @"Rumble", @"Drums"
    ];
}


// MARK: - Haptic

/// 创建并启动触觉引擎
- (void)createAndStartHapticEngine {
    if (@available(iOS 13.0, *)) {
        if (!CoreHapticsUtilShared.supportsHaptics) {
            NSLog(@"触觉引擎_设备不支持");
            return;
        }
        
        // 1. 创建触觉引擎
        __weak typeof(self) weakSelf = self;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        
        NSError *error = nil;
        self.engine = [[CHHapticEngine alloc] initWithAudioSession:session error:&error];
        if (error) {
            NSLog(@"触觉引擎_创建失败: %@", error.localizedDescription);
            return;
        }
        
        // 2. 设置触觉引擎
        // 触觉引擎重置的回调
        self.engine.resetHandler = ^{
            [weakSelf.engine startWithCompletionHandler:nil];
        };
        // 触觉引擎停止运行的回调
        self.engine.stoppedHandler = ^(CHHapticEngineStoppedReason stoppedReason) {
            switch (stoppedReason) {
                case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                    NSLog(@"触觉引擎_停止运行: audio session interrupt");
                    break;
                    
                case CHHapticEngineStoppedReasonApplicationSuspended:
                    NSLog(@"触觉引擎_停止运行: application suspended");
                    break;
                        
                case CHHapticEngineStoppedReasonIdleTimeout:
                    NSLog(@"触觉引擎_停止运行: idle timeout");
                    break;
                        
                case CHHapticEngineStoppedReasonNotifyWhenFinished:
                    NSLog(@"触觉引擎_停止运行: notify when finished");
                    break;
                    
                case CHHapticEngineStoppedReasonEngineDestroyed:
                    NSLog(@"触觉引擎_停止运行: engine destroyed");
                    break;
                    
                case CHHapticEngineStoppedReasonGameControllerDisconnect:
                    NSLog(@"触觉引擎_停止运行: game controller disconnect");
                    break;
                    
                case CHHapticEngineStoppedReasonSystemError:
                    NSLog(@"触觉引擎_停止运行: system error");
                    break;
                    
                default:
                    NSLog(@"触觉引擎_停止运行: unknown error");
                    break;
            }
        };
        
        // 3. 启动触觉引擎
        [CoreHapticsUtil startHapticEngine:self.engine completion:nil];
    }
}

- (void)playHapticsFile:(NSString *)filename {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"ahap"];
    if (!filePath) {
        NSLog(@"触觉引擎_ %@.ahap 文件未找到", filename);
        return;
    }
    
    NSError *error = nil;
    [self.engine playPatternFromURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        NSLog(@"触觉引擎_从文件播放模式失败: %@", error.localizedDescription);
        return;
    }
}


// MARK: - Event

- (void)tapButtonEvent:(UIButton *)sender {
    NSInteger tag = sender.tag - 1000;
    if (tag >= self.ahapFilenames.count) {
        return;
    }
    
    NSString *filename = self.ahapFilenames[tag];
    [self playHapticsFile:filename];
}


// MARK: - UI

- (void)layoutButtons {
    UIStackView *stackView = [[UIStackView alloc] initWithFrame:CGRectMake(20, 88 + 30, self.windowWidth - 40, self.windowHeight - 60)];
    stackView.axis = UILayoutConstraintAxisHorizontal;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 30;
    [self.view addSubview:stackView];
    
    
    UIStackView *stackVerView1 = [[UIStackView alloc] init];
    stackVerView1.axis = UILayoutConstraintAxisVertical;
    stackVerView1.distribution = UIStackViewDistributionFillEqually;
    stackVerView1.alignment = UIStackViewAlignmentFill;
    stackVerView1.spacing = 30;
    NSArray *titles1 = @[@"Sparkle", @"Boing", @"Gravel", @"Oscillate"];
    for (int i = 0; i < titles1.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = 1000 + i;
        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0];
        button.titleLabel.font = [UIFont systemFontOfSize:22];
        [button setTitle:titles1[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [stackVerView1 addArrangedSubview:button];
    }

    UIStackView *stackVerView2 = [[UIStackView alloc] init];
    stackVerView2.axis = UILayoutConstraintAxisVertical;
    stackVerView2.distribution = UIStackViewDistributionFillEqually;
    stackVerView2.alignment = UIStackViewAlignmentFill;
    stackVerView2.spacing = 30;
    NSArray *titles2 = @[@"Heartbeats", @"Inflate", @"Rumble", @"Drums (♫) "];
    for (int i = 0; i < titles2.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = (1000 + titles1.count) + i;
        button.layer.cornerRadius = 20;
        button.layer.masksToBounds = YES;
        button.backgroundColor = [UIColor colorWithRed:239 / 255.0 green:239 / 255.0 blue:239 / 255.0 alpha:1.0];
        button.titleLabel.font = [UIFont systemFontOfSize:22];
        [button setTitle:titles2[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tapButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        [stackVerView2 addArrangedSubview:button];
    }
    
    [stackView addArrangedSubview:stackVerView1];
    [stackView addArrangedSubview:stackVerView2];
}


// MARK: - Notifications

- (void)appDidEnterBackgroundNotification {
    if (@available(iOS 13.0, *)) {
        // 进入后台后,停止触觉引擎
        [CoreHapticsUtil stopHapticEngine:self.engine completion:nil];
    }
}

- (void)appWillEnterForegroundNotification {
    if (@available(iOS 13.0, *)) {
        // 进入前台后,启动触觉引擎
        [CoreHapticsUtil startHapticEngine:self.engine completion:nil];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
