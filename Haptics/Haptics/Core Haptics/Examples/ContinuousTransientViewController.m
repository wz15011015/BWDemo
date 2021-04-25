//
//  ContinuousTransientViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/12/9.
//

#import "ContinuousTransientViewController.h"
#import "CoreHapticsUtil.h"

static const CGFloat PaletteMargin = 16;
static const CGFloat LabelHeight = 24;
static const CGFloat TouchIndicatorSize = 50;

static const CGFloat InitialIntensity = 1.0;
static const CGFloat InitialSharpness = 0.5;

@interface ContinuousTransientViewController ()

@property (nonatomic, assign) CGFloat windowWidth;
@property (nonatomic, assign) CGFloat windowHeight;

@property (nonatomic, strong) UIView *transientPalette; // 短暂事件面板
@property (nonatomic, strong) UIView *continuousPalette; // 持续事件面板
@property (nonatomic, assign) CGFloat paletteSize;
@property (nonatomic, strong) UIImageView *transientTouchView; // 短暂事件触摸圆点
@property (nonatomic, strong) UIImageView *continuousTouchView; // 持续事件触摸圆点 beating_heart

@property (nonatomic, strong) UILabel *transientTitleLabel;
@property (nonatomic, strong) UILabel *transientValueLabel;
@property (nonatomic, strong) UILabel *continuousTitleLabel;
@property (nonatomic, strong) UILabel *continuousValueLabel;

@property (nonatomic, strong) UIColor *padColor; // 面板颜色
@property (nonatomic, strong) UIColor *flashColor; // 闪烁颜色

// 触觉引擎
@property (nonatomic, strong) CHHapticEngine *engine;
@property (nonatomic, assign) BOOL engineNeedStart; // 是否需要启动触觉引擎
@property (nonatomic, strong) id<CHHapticAdvancedPatternPlayer> continuousPlayer;

// 定时器
@property (nonatomic, strong) dispatch_source_t transientTimer;

@end

@implementation ContinuousTransientViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Continuous & Transient Haptic";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    
    // 创建并启动触觉引擎
    [self createAndStartHapticEngine];
    
    // 创建持续触觉模式播放器
    [self createContinuousHapticPlayer];
    
    // 布局视图
    [self layoutPaletteViews];
    [self layoutTouchIndicators];
    [self addGestureRecognizers];
    [self layoutTitleLabels];
    [self layoutValueLabels];
}

- (void)initData {
    self.windowWidth = [UIScreen mainScreen].bounds.size.width;
    self.windowHeight = [UIScreen mainScreen].bounds.size.height - 88;
    
    CGFloat width = self.windowWidth - 2 * PaletteMargin;
    CGFloat height = self.windowHeight - 4 * LabelHeight - 2 * PaletteMargin;
    self.paletteSize = MIN(width, height / 2);
    
    if (@available(iOS 13.0, *)) {
        self.padColor = [UIColor systemGray3Color];
        self.flashColor = [UIColor systemGray2Color];
    } else {
        self.padColor = [UIColor colorWithRed:198 / 255.0 green:199 / 255.0 blue:203 / 255.0 alpha:1.0];
        self.flashColor = [UIColor colorWithRed:173 / 255.0 green:173 / 255.0 blue:178 / 255.0 alpha:1.0];
    }
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}


// MARK: - Haptic

/// 创建并启动触觉引擎
- (void)createAndStartHapticEngine {
    if (@available(iOS 13.0, *)) {
        __weak typeof(self) weakSelf = self;
        
        // 创建触觉引擎
        self.engine = [CoreHapticsUtil createHapticEngineWithResetHandler:^{
            weakSelf.engineNeedStart = YES;
        } stoppedHandler:nil];
        
        // 启动触觉引擎
        [CoreHapticsUtil startHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            // engineNeedStart设置为NO,表示下次需要使用触觉引擎时,不用再去启动了
            weakSelf.engineNeedStart = NO;
        }];
    }
}

- (void)createContinuousHapticPlayer {
    if (@available(iOS 13.0, *)) {
        // 强度参数
        CHHapticEventParameter *intensity = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:InitialIntensity];
        // 锐度参数
        CHHapticEventParameter *sharpness = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:InitialSharpness];
        
        // 持续触觉事件
        CHHapticEvent *continuousEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticContinuous parameters:@[intensity, sharpness] relativeTime:0 duration:100];
        
        // 根据事件创建触觉模式
        NSError *error = nil;
        CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[continuousEvent] parameters:@[] error:&error];
        if (error) {
            NSLog(@"触觉引擎_模式创建出错: %@", error.localizedDescription);
        }
        
        // 创建触觉模式播放器
        __weak typeof(self) weakSelf = self;
        self.continuousPlayer = [CoreHapticsUtil createAdvancedPatternPlayerWithEngine:self.engine pattern:pattern];
        // 播放完成的回调
        self.continuousPlayer.completionHandler = ^(NSError * _Nullable error) {
            // 重置面板颜色
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.continuousPalette.backgroundColor = weakSelf.padColor;
            });
        };
    }
}

- (void)playHapticTransientAtTime:(NSTimeInterval)time intensity:(CGFloat)intensity sharpness:(CGFloat)sharpness {
    if (@available(iOS 13.0, *)) {
        // 让面板闪烁
        [self flashBackgroundIn:self.transientPalette];
        
        
        // 强度参数
        CHHapticEventParameter *intensityParameter = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensity];
        // 锐度参数
        CHHapticEventParameter *sharpnessParameter = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:sharpness];
        
        // 短暂触觉事件
        CHHapticEvent *transientEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[intensityParameter, sharpnessParameter] relativeTime:0 duration:100];
        
        // 根据事件创建触觉模式
        NSError *error = nil;
        CHHapticPattern *pattern = [[CHHapticPattern alloc] initWithEvents:@[transientEvent] parameters:@[] error:&error];
        if (error) {
            NSLog(@"触觉引擎_模式创建出错: %@", error.localizedDescription);
        }
        
        // 创建触觉模式播放器
        id<CHHapticPatternPlayer> player = [CoreHapticsUtil createPatternPlayerWithEngine:self.engine pattern:pattern];
        // 开始播放
        [CoreHapticsUtil startPatternPlayer:player atTime:CHHapticTimeImmediate];
    }
}


- (dispatch_source_t)scheduledRecurringTimerWithQueue:(dispatch_queue_t)queue start:(NSTimeInterval)time interval:(NSTimeInterval)interval handler:(dispatch_block_t)handler {
    if (!queue) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    }
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, time * NSEC_PER_SEC), interval * NSEC_PER_SEC, 0.0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        if (handler) {
            handler();
        }
    });
    dispatch_resume(timer);
    return timer;
}

- (void)cancelTimer:(dispatch_source_t)timer {
   if (timer) {
       dispatch_source_cancel(timer);
       timer = nil;
   }
}


// MARK: - Events

- (void)continuousPalettePressed:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.continuousPalette];
    // 处理触摸点
    CGPoint clippedLocation = [self clipLocation:location toView:self.continuousPalette];
    CGPoint normalizedLocation = [self normalizeCoordinates:clippedLocation toView:self.continuousPalette];
    
    // 更新触摸圆点位置
    self.continuousTouchView.center = clippedLocation;
    
    // x轴代表锐度,越往右值越大; y轴代表强度,越往上值越大
    // 锐度动态参数范围从 -0.5 到 0.5，可将最终锐度映射到 [0，1] 范围
    CGFloat dynamicSharpness = normalizedLocation.x - 0.5;
    CGFloat dynamicIntensity = 1.0 - normalizedLocation.y;
    
    CGFloat perceivedSharpness = InitialSharpness + dynamicSharpness;
    CGFloat perceivedIntensity = InitialIntensity * dynamicIntensity;
    
    // 更新数值显示
    [self updateLabelText:self.continuousValueLabel sharpness:perceivedSharpness intensity:perceivedIntensity];
    
    // 更新模式播放器数值
    if (CoreHapticsUtilShared.supportsHaptics) {
        if (@available(iOS 13.0, *)) {
            // 强度参数
            CHHapticDynamicParameter *intensityParameter = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticIntensityControl value:perceivedIntensity relativeTime:0];
            // 锐度参数
            CHHapticDynamicParameter *sharpnessParameter = [[CHHapticDynamicParameter alloc] initWithParameterID:CHHapticDynamicParameterIDHapticSharpnessControl value:perceivedSharpness relativeTime:0];
            
            NSError *error = nil;
            [self.continuousPlayer sendParameters:@[intensityParameter, sharpnessParameter] atTime:0 error:&error];
            if (error) {
                NSLog(@"触觉引擎_给模式播放器发送参数出错: %@", error.localizedDescription);
            }
            
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                    self.continuousTouchView.alpha = 1;
                    [self.continuousPlayer startAtTime:CHHapticTimeImmediate error:nil];
                    self.continuousPalette.backgroundColor = self.flashColor;
                    break;
                    
                case UIGestureRecognizerStateEnded:
                    [self.continuousPlayer stopAtTime:CHHapticTimeImmediate error:nil];
                    break;
                    
                case UIGestureRecognizerStateCancelled:
                    [self.continuousPlayer stopAtTime:CHHapticTimeImmediate error:nil];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)transientPalettePressed:(UILongPressGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self.transientPalette];
    // 处理触摸点
    CGPoint clippedLocation = [self clipLocation:location toView:self.transientPalette];
    CGPoint normalizedLocation = [self normalizeCoordinates:clippedLocation toView:self.transientPalette];
    
    // 更新触摸圆点位置
    self.transientTouchView.center = clippedLocation;
    
    CGFloat eventIntensity = 1.0 - normalizedLocation.y;
    CGFloat eventSharpness = normalizedLocation.x;
    
    // 更新数值显示
    [self updateLabelText:self.transientValueLabel sharpness:eventSharpness intensity:eventIntensity];
    
    
    __weak typeof(self) weakSelf = self;
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.transientTouchView.alpha = 1;
            
            [self playHapticTransientAtTime:0 intensity:eventIntensity sharpness:eventSharpness];
            
            // 定时循环执行短暂触觉事件
            [self cancelTimer:self.transientTimer];
            self.transientTimer = [self scheduledRecurringTimerWithQueue:dispatch_get_main_queue() start:0.75 interval:0.6 handler:^{
                CGPoint newLocation = [gesture locationInView:weakSelf.transientPalette];
                // 处理触摸点
                CGPoint clippedLocation = [weakSelf clipLocation:newLocation toView:weakSelf.transientPalette];
                CGPoint normalizedLocation = [weakSelf normalizeCoordinates:clippedLocation toView:weakSelf.transientPalette];
                
                CGFloat eventIntensity = 1.0 - normalizedLocation.y;
                CGFloat eventSharpness = normalizedLocation.x;
                [weakSelf playHapticTransientAtTime:0 intensity:eventIntensity sharpness:eventSharpness];
            }];
        }
            break;
             
        case UIGestureRecognizerStateEnded:
            [self cancelTimer:self.transientTimer];
            break;
            
        case UIGestureRecognizerStateCancelled:
            [self cancelTimer:self.transientTimer];
            break;
            
        default:
            break;
    }
}


// MARK: - UI

- (void)layoutPaletteViews {
    CGFloat x = (self.windowWidth - self.paletteSize) / 2;
    CGFloat y = 88 + (self.windowHeight / 2 - PaletteMargin - LabelHeight - self.paletteSize);
    self.continuousPalette = [[UIView alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, self.paletteSize)];
    self.continuousPalette.backgroundColor = self.padColor;
    self.continuousPalette.layer.cornerRadius = 16;
    self.continuousPalette.clipsToBounds = YES;
    
    y = y + self.paletteSize + LabelHeight + 2 * PaletteMargin;
    self.transientPalette = [[UIView alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, self.paletteSize)];
    self.transientPalette.backgroundColor = self.padColor;
    self.transientPalette.layer.cornerRadius = 16;
    self.transientPalette.clipsToBounds = YES;
    
    [self.view addSubview:self.continuousPalette];
    [self.view addSubview:self.transientPalette];
}

- (void)layoutTouchIndicators {
    CGFloat x = (self.paletteSize - TouchIndicatorSize) / 2;
    CGRect frame = CGRectMake(x, x, TouchIndicatorSize, TouchIndicatorSize);
    self.continuousTouchView = [[UIImageView alloc] initWithFrame:frame];
//    self.continuousTouchView.backgroundColor = [UIColor colorWithRed:246 / 255.0 green:168 / 255.0 blue:151 / 255.0 alpha:1.0];
//    self.continuousTouchView.layer.cornerRadius = TouchIndicatorSize / 2;
//    self.continuousTouchView.clipsToBounds = YES;
    self.continuousTouchView.image = [UIImage imageNamed:@"vibration_mode"];
    
    self.transientTouchView = [[UIImageView alloc] initWithFrame:frame];
//    self.transientTouchView.backgroundColor = self.continuousTouchView.backgroundColor;
//    self.transientTouchView.layer.cornerRadius = TouchIndicatorSize / 2;
//    self.transientTouchView.clipsToBounds = YES;
    self.transientTouchView.image = [UIImage imageNamed:@"beating_heart"];
    
    [self.continuousPalette addSubview:self.continuousTouchView];
    [self.transientPalette addSubview:self.transientTouchView];
}

- (void)layoutTitleLabels {
    CGFloat x = CGRectGetMinX(self.continuousPalette.frame);
    CGFloat y = CGRectGetMinY(self.continuousPalette.frame) - 2 - LabelHeight;
    
    self.continuousTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, LabelHeight)];
    self.continuousTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.continuousTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.continuousTitleLabel.text = @"Continuous";
    
    y = CGRectGetMinY(self.transientPalette.frame) - 2 - LabelHeight;
    self.transientTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, LabelHeight)];
    self.transientTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.transientTitleLabel.font = self.continuousTitleLabel.font;
    self.transientTitleLabel.text = @"Transient";
    
    [self.view addSubview:self.continuousTitleLabel];
    [self.view addSubview:self.transientTitleLabel];
}

- (void)layoutValueLabels {
    CGFloat x = CGRectGetMinX(self.continuousPalette.frame);
    CGFloat y = CGRectGetMaxY(self.continuousPalette.frame) + 2;
    
    self.continuousValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, LabelHeight)];
    self.continuousValueLabel.textAlignment = NSTextAlignmentCenter;
    self.continuousValueLabel.font = [UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightRegular];
    [self updateLabelText:self.continuousValueLabel sharpness:0.5 intensity:0.5];
    
    y = CGRectGetMaxY(self.transientPalette.frame) + 2;
    self.transientValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, self.paletteSize, LabelHeight)];
    self.transientValueLabel.textAlignment = NSTextAlignmentCenter;
    self.transientValueLabel.font = self.continuousValueLabel.font;
    [self updateLabelText:self.transientValueLabel sharpness:0.5 intensity:0.5];
    
    [self.view addSubview:self.continuousValueLabel];
    [self.view addSubview:self.transientValueLabel];
}

- (void)addGestureRecognizers {
    UILongPressGestureRecognizer *continuousLongPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(continuousPalettePressed:)];
    continuousLongPressGR.minimumPressDuration = 0;
    [self.continuousPalette addGestureRecognizer:continuousLongPressGR];
    
    UILongPressGestureRecognizer *transientLongPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(transientPalettePressed:)];
    transientLongPressGR.minimumPressDuration = 0;
    [self.transientPalette addGestureRecognizer:transientLongPressGR];
}

- (void)updateLabelText:(UILabel *)label sharpness:(CGFloat)sharpness intensity:(CGFloat)intensity {
    label.text = [NSString stringWithFormat:@"Sharpness %.2f, Intensity %.2f", sharpness, intensity];
}

/// 闪烁面板
/// @param viewToFlash 面板视图
- (void)flashBackgroundIn:(UIView *)viewToFlash {
    viewToFlash.backgroundColor = self.flashColor;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        viewToFlash.backgroundColor = self.padColor;
    });
}


// MARK: - Notifications

- (void)appDidEnterBackgroundNotification {
    if (@available(iOS 13.0, *)) {
        // 进入后台后,停止触觉引擎
        [CoreHapticsUtil stopHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            self.engineNeedStart = YES;
        }];
    }
}

- (void)appWillEnterForegroundNotification {
    if (@available(iOS 13.0, *)) {
        // 进入前台后,启动触觉引擎
        [CoreHapticsUtil startHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            self.engineNeedStart = NO;
        }];
    }
}


// MARK: - Tool Methods

- (CGPoint)clipLocation:(CGPoint)point toView:(UIView *)clipView {
    CGPoint clippedLocation = point;
    
    if (point.x < 0) {
        clippedLocation.x = 0;
    } else if (point.x > clipView.bounds.size.width) {
        clippedLocation.x = clipView.bounds.size.width;
    }
    
    if (point.y < 0) {
        clippedLocation.y = 0;
    } else if (point.y > clipView.bounds.size.height) {
        clippedLocation.y = clipView.bounds.size.height;
    }
    
    return clippedLocation;
}

- (CGPoint)normalizeCoordinates:(CGPoint)point toView:(UIView *)paletteView {
    CGFloat width = CGRectGetWidth(paletteView.frame);
    CGFloat height = CGRectGetHeight(paletteView.frame);
    return CGPointMake(point.x / width, point.y / height);
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
