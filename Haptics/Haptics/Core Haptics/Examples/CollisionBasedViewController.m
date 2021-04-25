//
//  CollisionBasedViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/12/8.
//

#import "CollisionBasedViewController.h"
#import "CoreHapticsUtil.h"
#import <CoreMotion/CoreMotion.h>

#define IS_IPHONE_X_SERIES \
({ \
    BOOL iPhoneX = NO; \
    if (@available(iOS 11.0, *)) { \
        iPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0; \
    } \
    (iPhoneX); \
}) \

static const CGFloat kSphereRadius = 72;
static const CGFloat kMaxVelocity = 500;

@interface CollisionBasedViewController () <UICollisionBehaviorDelegate>

@property (nonatomic, assign) CGFloat windowWidth;
@property (nonatomic, assign) CGFloat windowHeight;

// 小球
@property (nonatomic, strong) UIImageView *sphereView;
@property (nonatomic, strong) UIView *deskView;

// 物理仿真器(动画器)
@property (nonatomic, strong) UIDynamicAnimator *animator;

// 物理仿真特性
@property (nonatomic, strong) UIGravityBehavior *gravity; // 重力特性
@property (nonatomic, strong) UICollisionBehavior *wallCollisions; // 碰撞特性
@property (nonatomic, strong) UIDynamicItemBehavior *bounce; // 弹性特性

// 运动管理者
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, strong) NSOperationQueue *motionQueue;
@property (nonatomic, strong) CMAccelerometerData *motionData;

// 触觉引擎
@property (nonatomic, strong) CHHapticEngine *engine;
@property (nonatomic, assign) BOOL engineNeedStart; // 是否需要启动触觉引擎

@end

@implementation CollisionBasedViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Collision-Based Haptic";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.windowWidth = [UIScreen mainScreen].bounds.size.width;
    self.windowHeight = [UIScreen mainScreen].bounds.size.height;
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(appDidEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [center addObserver:self selector:@selector(appWillEnterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    
    // 创建并启动触觉引擎
    [self createAndStartHapticEngine];
    
    // 初始化小球
    [self initializeSphere];
    
    // 给小球添加物理仿真特性
    [self initializeWalls];
    [self initializeBounce];
    [self initializeGravity];
    // 初始化物理仿真器
    [self initializeAnimator];
    
    [self activateAccelerometer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.motionManager stopDeviceMotionUpdates];
    
    if (@available(iOS 13.0, *)) {
        // 停止触觉引擎
        [CoreHapticsUtil stopHapticEngine:self.engine completion:nil];
    }
}


// MARK: - Haptic

/// 创建并启动触觉引擎
- (void)createAndStartHapticEngine {
    if (@available(iOS 13.0, *)) {
        if (!CoreHapticsUtilShared.supportsHaptics) {
            NSLog(@"设备不支持触觉引擎");
            return;
        }
        
        // 1. 创建触觉引擎
        __weak typeof(self) weakSelf = self;
        self.engine = [CoreHapticsUtil createHapticEngineWithResetHandler:^{
            weakSelf.engineNeedStart = YES;
        } stoppedHandler:^(CHHapticEngineStoppedReason stoppedReason) {
            switch (stoppedReason) {
                case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                    NSLog(@"Haptic engine stopped reason: audio session interrupt");
                    break;
                    
                case CHHapticEngineStoppedReasonApplicationSuspended:
                    NSLog(@"Haptic engine stopped reason: application suspended");
                    break;
                        
                case CHHapticEngineStoppedReasonIdleTimeout:
                    NSLog(@"Haptic engine stopped reason: idle timeout");
                    break;
                        
                case CHHapticEngineStoppedReasonNotifyWhenFinished:
                    NSLog(@"Haptic engine stopped reason: notify when finished");
                    break;
                    
                case CHHapticEngineStoppedReasonEngineDestroyed:
                    NSLog(@"Haptic engine stopped reason: engine destroyed");
                    break;
                    
                case CHHapticEngineStoppedReasonGameControllerDisconnect:
                    NSLog(@"Haptic engine stopped reason: game controller disconnect");
                    break;
                    
                case CHHapticEngineStoppedReasonSystemError:
                    NSLog(@"Haptic engine stopped reason: system error");
                    break;
                    
                default:
                    NSLog(@"Haptic engine stopped reason: unknown error");
                    break;
            }
            weakSelf.engineNeedStart = YES;
        }];
        
        // 2. 启动触觉引擎以准备使用
        [CoreHapticsUtil startHapticEngine:self.engine completion:^(NSError * _Nullable error) {
            // engineNeedStart设置为NO,表示下次需要使用触觉引擎时,不用再去启动了
            self.engineNeedStart = NO;
        }];
    }
}

- (id<CHHapticPatternPlayer>)playerForMagnitude:(CGFloat)magnitude API_AVAILABLE(ios(13.0)) {
    // 1. 创建触觉模式
    
    // 1.1 音频事件
    CGFloat volume = [self linearInterpolation:magnitude min:0.1 max:0.4];
    CGFloat decay = [self linearInterpolation:magnitude min:0.0 max:0.1];
    // 音高
    CHHapticEventParameter *audioPitch = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDAudioPitch value:-0.15];
    // 音量参数
    CHHapticEventParameter *audioVolume = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDAudioVolume value:volume];
    // 衰减参数
    CHHapticEventParameter *decayTime = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDDecayTime value:decay];
    // 持续参数
    CHHapticEventParameter *sustained = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDSustained value:0.0];
    CHHapticEvent *audioEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeAudioContinuous parameters:@[audioPitch, audioVolume, decayTime, sustained] relativeTime:0.0];
    
    // 1.2 触觉事件
    CGFloat sharpnessValue = [self linearInterpolation:magnitude min:0.9 max:0.5];
    CGFloat intensityValue = [self linearInterpolation:magnitude min:0.375 max:1.0];
    // 锐度参数
    CHHapticEventParameter *sharpness = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticSharpness value:sharpnessValue];
    // 强度参数
    CHHapticEventParameter *intensity = [[CHHapticEventParameter alloc] initWithParameterID:CHHapticEventParameterIDHapticIntensity value:intensityValue];
    // hapticEvent
    CHHapticEvent *hapticEvent = [[CHHapticEvent alloc] initWithEventType:CHHapticEventTypeHapticTransient parameters:@[sharpness, intensity] relativeTime:0];
    
    // 根据事件创建触觉模式
    NSError *createPatternError = nil;
    CHHapticPattern *hapticPattern = [[CHHapticPattern alloc] initWithEvents:@[audioEvent, hapticEvent] parameters:@[] error:&createPatternError];
    if (createPatternError) {
        NSLog(@"Haptic pattern creation error: %@", createPatternError.localizedDescription);
    }
    
    // 2. 创建触觉模式播放器
    id patternPlayer = [CoreHapticsUtil createPatternPlayerWithEngine:self.engine pattern:hapticPattern];
    
    // 3. 返回触觉模式播放器
    return patternPlayer;
}


// MARK: - UI

- (void)initializeSphere {
    // 把小球放置到屏幕中心以便开始
    CGFloat w = kSphereRadius;
    CGFloat x = floor((self.windowWidth - w) / 2);
    CGFloat y = floor((self.windowHeight - w) / 2);
    
    self.sphereView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, w, w)];
    self.sphereView.layer.cornerRadius = w / 2;
    self.sphereView.image = [UIImage imageNamed:@"tennis_ball"];
    [self.view addSubview:self.sphereView];
    
    self.deskView = [[UIView alloc] initWithFrame:CGRectMake((self.windowWidth - 120) / 2, self.windowHeight - w - 30, 120, 20)];
    self.deskView.layer.backgroundColor = [UIColor colorWithRed:236 / 255.0 green:203 / 255.0 blue:153 / 255.0 alpha:1.0].CGColor;
    [self.view addSubview:self.deskView];
}

- (void)initializeWalls {
    self.wallCollisions = [[UICollisionBehavior alloc] initWithItems:@[self.sphereView]];
    self.wallCollisions.collisionDelegate = self;
    
    CGFloat top = 64;
    if ([self iSiPhoneXSeries]) {
        top += 24;
    }
    // 设置边界
    CGPoint upperLeft = CGPointMake(-1, top);
    CGPoint upperRight = CGPointMake(self.windowWidth + 1, top);
    CGPoint lowerLeft = CGPointMake(-1, self.windowHeight + 1);
    CGPoint lowerRight = CGPointMake(self.windowWidth + 1, self.windowHeight + 1);
    [self.wallCollisions addBoundaryWithIdentifier:@"leftWall" fromPoint:upperLeft toPoint:lowerLeft];
    [self.wallCollisions addBoundaryWithIdentifier:@"rightWall" fromPoint:upperRight toPoint:lowerRight];
    [self.wallCollisions addBoundaryWithIdentifier:@"topWall" fromPoint:upperLeft toPoint:upperRight];
    [self.wallCollisions addBoundaryWithIdentifier:@"bottomWall" fromPoint:lowerLeft toPoint:lowerRight];
    
    CGFloat deskX = CGRectGetMinX(self.deskView.frame);
    CGFloat deskY = CGRectGetMinY(self.deskView.frame);
    CGFloat deskW = CGRectGetWidth(self.deskView.frame);
    CGFloat deskH = CGRectGetHeight(self.deskView.frame);
    UIBezierPath *deskBoundaryPath = [[UIBezierPath alloc] init];
    [deskBoundaryPath moveToPoint:CGPointMake(deskX, deskY)];
    [deskBoundaryPath addLineToPoint:CGPointMake(deskX, deskY + deskH)];
    [deskBoundaryPath addLineToPoint:CGPointMake(deskX + deskW, deskY + deskH)];
    [deskBoundaryPath addLineToPoint:CGPointMake(deskX + deskW, deskY)];
    [deskBoundaryPath closePath];
    [self.wallCollisions addBoundaryWithIdentifier:@"DeskBoundary" forPath:deskBoundaryPath];
}

- (void)initializeBounce {
    self.bounce = [[UIDynamicItemBehavior alloc] initWithItems:@[self.sphereView]];
    self.bounce.elasticity = 0.5; // 弹性
    self.bounce.allowsRotation = YES; // 允许旋转
}

- (void)initializeGravity {
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.sphereView]];
}

- (void)initializeAnimator {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    // 添加物理仿真特性
    [self.animator addBehavior:self.bounce];
    [self.animator addBehavior:self.gravity];
    [self.animator addBehavior:self.wallCollisions];
}

- (void)activateAccelerometer {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionData = [[CMAccelerometerData alloc] init];
    self.motionQueue = [[NSOperationQueue alloc] init];
    
    [self.motionManager startDeviceMotionUpdatesToQueue:self.motionQueue withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
        CMAcceleration gravity = motion.gravity;
        double rotation = atan2(motion.attitude.pitch, motion.attitude.roll);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gravity.gravityDirection = CGVectorMake(gravity.x * 3.5, -gravity.y * 3.5);
            self.gravity.angle = rotation; // 重力特性的角度
        });
    }];
}


// MARK: - UICollisionBehaviorDelegate

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
    if (@available(iOS 13.0, *)) {
        if (!CoreHapticsUtilShared.supportsHaptics) {
            NSLog(@"设备不支持触觉引擎");
            return;
        }
        
        // 判断是否需要启动触觉引擎
        if (self.engineNeedStart) {
            [CoreHapticsUtil startHapticEngine:self.engine completion:nil];
            self.engineNeedStart = NO;
        }
        
        CGPoint velocity = [self.bounce linearVelocityForItem:item];
        CGFloat xVelocity = velocity.x;
        CGFloat yVelocity = velocity.y;
        
        CGFloat magnitude = sqrtf(xVelocity * xVelocity + yVelocity * yVelocity);
        CGFloat normalizedMagnitude = MIN(MAX(magnitude / kMaxVelocity, 0.0), 1.0);
        
        id patternPlayer = [self playerForMagnitude:normalizedMagnitude];
        [CoreHapticsUtil startPatternPlayer:patternPlayer atTime:CHHapticTimeImmediate];
    }
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

- (CGFloat)linearInterpolation:(CGFloat)alpha min:(CGFloat)min max:(CGFloat)max {
    return min + alpha * (max - min);
}

- (BOOL)iSiPhoneXSeries {
    BOOL iPhoneX = NO;
    
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *scenes = UIApplication.sharedApplication.connectedScenes;
        if (scenes.count) {
            for (UIScene *scene in scenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive ||
                    scene.activationState == UISceneActivationStateForegroundInactive) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [[UIApplication sharedApplication] delegate].window;
        }
    } else {
        window = [[UIApplication sharedApplication] delegate].window;
    }
    
    if (window) {
        if (@available(iOS 11.0, *)) {
            iPhoneX = window.safeAreaInsets.bottom > 0.0;
        }
    }
    return iPhoneX;
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
