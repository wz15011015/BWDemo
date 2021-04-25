//
//  SingleTapViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/11/24.
//

#import "SingleTapViewController.h"
#import "CoreHapticsUtil.h"

@interface SingleTapViewController ()

@property (nonatomic, strong) CHHapticEngine *engine;
@property (nonatomic, assign) BOOL engineNeedStart; // 是否需要启动触觉引擎

@property (nonatomic, strong) UIButton *tapButton;

@end

@implementation SingleTapViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Single-Tap Haptic";
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.tapButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.tapButton.frame = CGRectMake(0, 0, 100, 100);
    self.tapButton.center = self.view.center;
    [self.tapButton setImage:[[UIImage imageNamed:@"single_tap"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [self.tapButton addTarget:self action:@selector(singleTapEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.tapButton];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    // 创建并启动触觉引擎
    [self createAndStartHapticEngine];
}


// MARK: - Haptic

/// 创建并启动触觉引擎
- (void)createAndStartHapticEngine {
    if (@available(iOS 13.0, *)) {
        self.engineNeedStart = YES;
        
        // 创建触觉引擎
        __weak typeof(self) weakSelf = self;
        self.engine = [CoreHapticsUtil createHapticEngineWithResetHandler:^{
            weakSelf.engineNeedStart = YES;
        } stoppedHandler:nil];
        
        // 启动触觉引擎
//        [CoreHapticsUtil startHapticEngine:self.engine completion:^(NSError * _Nullable error) {
//            // engineNeedStart设置为NO,表示下次需要使用触觉引擎时,不用再去启动了
//            weakSelf.engineNeedStart = NO;
//        }];
    }
}

/// 创建点击事件的模式播放器
- (nullable id<CHHapticPatternPlayer>)patternPlayerForSingleTap API_AVAILABLE(ios(13.0)) {
    // 触觉事件/音频事件的类型
    // CHHapticEventType :
    // 1. CHHapticEventTypeHapticTransient    短暂触觉
    // 2. CHHapticEventTypeHapticContinuous   持续触觉
    // 3. CHHapticEventTypeAudioContinuous    持续音频
    // 4. CHHapticEventTypeAudioCustom        自定义音频
    
    
    if (@available(iOS 13.0, *)) {
        // 1. 创建触觉模式
        
        // 1.1 触觉事件
        // 强度参数
        CHHapticEventParameter *intensity0 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:1.0];
        // 锐度参数
        CHHapticEventParameter *sharpness0 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:1.0];
        // hapticEvent0
        CHHapticEvent *hapticEvent0 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[intensity0, sharpness0] relativeTime:0 duration:1.0];
        
        // hapticEvent1
        CHHapticEventParameter *intensity1 = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:0.6];
        CHHapticEvent *hapticEvent1 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intensity1] relativeTime:1.0 duration:1.0];

        // 1.2 音频事件
        // 音高
        CHHapticEventParameter *audioPitch = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDAudioPitch value:0.1];
        // 音量参数
        CHHapticEventParameter *audioVolume = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDAudioVolume value:0.5];
        // 衰减参数
        CHHapticEventParameter *decayTime = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDDecayTime value:0.6];
        // 持续参数
        CHHapticEventParameter *sustained = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDSustained value:0.0];
        CHHapticEvent *audioEvent0 = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeAudioContinuous parameters:@[audioPitch, audioVolume, decayTime, sustained] relativeTime:0.0 duration:0.5];

        // 根据事件创建触觉模式
        NSError *createPatternError = nil;
        CHHapticPattern *hapticPattern = [[CHHapticPattern alloc] initWithEvents:@[hapticEvent0, audioEvent0] parameters:@[] error:&createPatternError];
        if (createPatternError) {
            NSLog(@"触觉引擎_模式创建出错: %@", createPatternError.localizedDescription);
        }
        
        
        
        //******************* 根据字典创建触觉模式 ********************
        
//        // 创建触觉模式字典
//        NSDictionary *hapticDict = @{
//
//            CHHapticPatternKeyPattern : @[
//                // 第一个事件
//                @{
//                    CHHapticPatternKeyEvent : @{
//                        CHHapticPatternKeyEventType : CHHapticEventTypeHapticTransient, // 事件类型
//                        CHHapticPatternKeyTime : @(0.0), // 事件开始时间
//                        CHHapticPatternKeyEventDuration : @(1.0), // 事件持续时间
////                        CHHapticPatternKeyEventParameters : @[
////                            @{
////                                CHHapticPatternKeyParameter : @{
////                                    CHHapticPatternKeyParameterID : CHHapticEventParameterIDHapticIntensity,
////                                    CHHapticPatternKeyParameterValue : @(0.5)
////                                }
////                            }
////                        ]
//                    }
//                },
//
//                // 第二个事件
//                @{
//                    CHHapticPatternKeyEvent : @{
//                        CHHapticPatternKeyEventType : CHHapticEventTypeHapticContinuous,
//                        CHHapticPatternKeyTime : @(1.0),
//                        CHHapticPatternKeyEventDuration : @(1.0) // 事件持续时间
//                    }
//                }
//
//            ]
//
//        };
//
//        // 根据字典创建触觉模式
//        NSError *createPatternError = nil;
//        CHHapticPattern *hapticPattern = [[CHHapticPattern alloc] initWithDictionary:hapticDict error:&createPatternError];
//        if (createPatternError) {
//            NSLog(@"触觉引擎_模式创建出错: %@", createPatternError.localizedDescription);
//        }
        
        //******************* 根据字典创建触觉模式 ********************
        
        
        
        // 2. 创建触觉模式播放器
        id<CHHapticPatternPlayer> patternPlayer = [CoreHapticsUtil createPatternPlayerWithEngine:self.engine pattern:hapticPattern];
        
        // 3. 返回触觉模式播放器
        return patternPlayer;
    }
    
    return nil;
}


#pragma mark - Events

- (void)singleTapEvent {
    if (@available(iOS 13.0, *)) {
        // 判断是否需要启动触觉引擎
        if (self.engineNeedStart) {
            [CoreHapticsUtil startHapticEngine:self.engine completion:nil];
            self.engineNeedStart = NO;
        }
        
        // 加载模式播放器并开启
        id<CHHapticPatternPlayer> patternPlayer = [self patternPlayerForSingleTap];
        [CoreHapticsUtil startPatternPlayer:patternPlayer atTime:CHHapticTimeImmediate];
        
        // 停止触觉引擎
        [CoreHapticsUtil stopHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            self.engineNeedStart = YES;
        }];
    }
}


// MARK: - Notifications

- (void)appDidEnterBackgroundNotification {
    // 进入后台后,停止触觉引擎
    if (@available(iOS 13.0, *)) {
        [CoreHapticsUtil stopHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            self.engineNeedStart = YES;
        }];
    }
}

- (void)appWillEnterForegroundNotification {
    // 进入前台后,启动触觉引擎
    if (@available(iOS 13.0, *)) {
        [CoreHapticsUtil startHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            self.engineNeedStart = NO;
        }];
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
