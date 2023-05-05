//
//  CoreHapticsUtil.m
//  Haptics
//
//  Created by hadlinks on 2020/11/24.
//

#import "CoreHapticsUtil.h"

@implementation CoreHapticsUtil

#pragma mark - Singleton

API_AVAILABLE(ios(13.0))
static CoreHapticsUtil *_instance = nil;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}


#pragma mark - Init

- (instancetype)init {
    if (self = [super init]) {
        if (@available(iOS 13.0, *)) {
            _supportsHaptics = CHHapticEngine.capabilitiesForHardware.supportsHaptics;
        } else {
            _supportsHaptics = NO;
        }
    }
    return self;
}


#pragma mark - Getters

- (CHHapticEngine *)sharedEngine {
    if (!_sharedEngine) {
        if (!CHHapticEngine.capabilitiesForHardware.supportsHaptics) {
            NSLog(@"触觉引擎_共享引擎_设备不支持");
            return nil;
        }
        
        // 1. 创建触觉引擎
        NSError *error = nil;
        _sharedEngine = [[CHHapticEngine alloc] initAndReturnError:&error];
        if (error) {
            NSLog(@"触觉引擎_共享引擎_创建失败: %@", error.localizedDescription);
            return nil;
        }
        
        // 2. 设置触觉引擎
        // 触觉引擎重置的回调
        _sharedEngine.resetHandler = ^{
            NSLog(@"触觉引擎_共享引擎_重置");
        };
        // 触觉引擎停止运行的回调
        _sharedEngine.stoppedHandler = ^(CHHapticEngineStoppedReason stoppedReason) {
            switch (stoppedReason) {
                case CHHapticEngineStoppedReasonAudioSessionInterrupt:
                    NSLog(@"触觉引擎_共享引擎_停止运行: audio session interrupt");
                    break;
                    
                case CHHapticEngineStoppedReasonApplicationSuspended:
                    NSLog(@"触觉引擎_共享引擎_停止运行: application suspended");
                    break;
                        
                case CHHapticEngineStoppedReasonIdleTimeout:
                    NSLog(@"触觉引擎_共享引擎_停止运行: idle timeout");
                    break;
                        
                case CHHapticEngineStoppedReasonNotifyWhenFinished:
                    NSLog(@"触觉引擎_共享引擎_停止运行: notify when finished");
                    break;
                    
                case CHHapticEngineStoppedReasonEngineDestroyed:
                    NSLog(@"触觉引擎_共享引擎_停止运行: engine destroyed");
                    break;
                    
                case CHHapticEngineStoppedReasonGameControllerDisconnect:
                    NSLog(@"触觉引擎_共享引擎_停止运行: game controller disconnect");
                    break;
                    
                case CHHapticEngineStoppedReasonSystemError:
                    NSLog(@"触觉引擎_共享引擎_停止运行: system error");
                    break;
                    
                default:
                    NSLog(@"触觉引擎_共享引擎_停止运行: unknown error");
                    break;
            }
        };
    }
    return _sharedEngine;
}


#pragma mark - Setters

- (void)setEngineResetHandler:(CHHapticEngineResetHandler)engineResetHandler {
    _engineResetHandler = engineResetHandler;
    
    self.sharedEngine.resetHandler = engineResetHandler;
}

- (void)setEngineStoppedHandler:(CHHapticEngineStoppedHandler)engineStoppedHandler {
    _engineStoppedHandler = engineStoppedHandler;
    
    self.sharedEngine.stoppedHandler = engineStoppedHandler;
}


// MARK: - 触觉引擎

/// 创建触觉引擎
/// @param resetHandler 触觉引擎重置的回调
/// @param stoppedHandler 触觉引擎停止运行的回调
+ (CHHapticEngine *)createHapticEngineWithResetHandler:(CHHapticEngineResetHandler _Nullable)resetHandler stoppedHandler:(CHHapticEngineStoppedHandler _Nullable)stoppedHandler API_AVAILABLE(ios(13.0)) {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return nil;
    }
    
    // 1. 创建触觉引擎
    NSError *error = nil;
    CHHapticEngine *engine = [[CHHapticEngine alloc] initAndReturnError:&error];
    if (error) {
        NSLog(@"触觉引擎_创建失败: %@", error.localizedDescription);
        return nil;
    }
    
    // 2. 设置触觉引擎
    // 触觉引擎重置的回调
    if (resetHandler) {
        engine.resetHandler = resetHandler;
    } else {
        engine.resetHandler = ^{
            NSLog(@"触觉引擎_重置");
        };
    }
    // 触觉引擎停止运行的回调
    if (stoppedHandler) {
        engine.stoppedHandler = stoppedHandler;
    } else {
        engine.stoppedHandler = ^(CHHapticEngineStoppedReason stoppedReason) {
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
    }
    return engine;
}

/// 启动触觉引擎以准备使用
/// @param engine 触觉引擎
/// @param completion 完成回调
+ (void)startHapticEngine:(CHHapticEngine *)engine completion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0)) {
    if (!engine) {
        NSLog(@"触觉引擎_触觉引擎不存在!");
        return;
    }
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }
    
    if (completion) {
        [engine startWithCompletionHandler:completion];
    } else {
        [engine startWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"触觉引擎_启动出错: %@", error.localizedDescription);
            } else {
                NSLog(@"触觉引擎_启动成功!");
            }
        }];
    }
}

/// 停止触觉引擎
/// @param engine 触觉引擎
/// @param completion 完成回调
+ (void)stopHapticEngine:(CHHapticEngine *)engine completion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0)) {
    if (!engine) {
        NSLog(@"触觉引擎_触觉引擎不存在!");
        return;
    }
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }
    
    if (completion) {
        [engine stopWithCompletionHandler:completion];
    } else {
        [engine stopWithCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                NSLog(@"触觉引擎_停止出错: %@", error.localizedDescription);
            } else {
                NSLog(@"触觉引擎_停止成功!");
            }
        }];
    }
}

/// 启动共享触觉引擎以准备使用
/// @param completion 完成回调
- (void)startSharedEngineCompletion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0)) {
    [CoreHapticsUtil startHapticEngine:self.sharedEngine completion:completion];
}

/// 停止共享触觉引擎
/// @param completion 完成回调
- (void)stopSharedEngineCompletion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0)) {
    [CoreHapticsUtil stopHapticEngine:self.sharedEngine completion:completion];
}


// MARK: - 触觉引擎模式播放器

// MARK: CHHapticPatternPlayer

/// 创建触觉引擎模式播放器
/// @param engine 触觉引擎
/// @param pattern 模式
+ (id<CHHapticPatternPlayer>)createPatternPlayerWithEngine:(CHHapticEngine *)engine pattern:(CHHapticPattern *)pattern API_AVAILABLE(ios(13.0)) {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return nil;
    }
    
    // 创建模式播放器
    NSError *error = nil;
    id<CHHapticPatternPlayer> player = [engine createPlayerWithPattern:pattern error:&error];
    if (error) {
        NSLog(@"触觉引擎_模式播放器创建出错: %@", error.localizedDescription);
        return nil;
    }
    return player;
}

// MARK: CHHapticAdvancedPatternPlayer

/// 创建触觉引擎高级模式播放器
/// @param engine 触觉引擎
/// @param pattern 模式
+ (id<CHHapticAdvancedPatternPlayer>)createAdvancedPatternPlayerWithEngine:(CHHapticEngine *)engine pattern:(CHHapticPattern *)pattern API_AVAILABLE(ios(13.0)) {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return nil;
    }
    
    // 创建模式播放器
    NSError *error = nil;
    id<CHHapticAdvancedPatternPlayer> player = [engine createAdvancedPlayerWithPattern:pattern error:&error];
    if (error) {
        NSLog(@"触觉引擎_高级模式播放器创建出错: %@", error.localizedDescription);
        return nil;
    }
    return player;
}

/// 开启模式播放器
/// @param player 模式播放器
/// @param time 开启时间 (传入 CHHapticTimeImmediate 或 0 表示立即开启)
+ (void)startPatternPlayer:(id<CHHapticPatternPlayer>)player atTime:(NSTimeInterval)time API_AVAILABLE(ios(13.0)) {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }
    
    NSError *error = nil;
    [player startAtTime:time error:&error];
    if (error) {
        NSLog(@"触觉引擎_模式播放器开启出错: %@", error.localizedDescription);
    }
}

/// 停止模式播放器
/// @param player 模式播放器
/// @param time 停止时间 (传入 CHHapticTimeImmediate 或 0 表示立即停止)
+ (void)stopPatternPlayer:(id<CHHapticPatternPlayer>)player atTime:(NSTimeInterval)time API_AVAILABLE(ios(13.0)) {
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }
    
    NSError *error = nil;
    [player stopAtTime:time error:&error];
    if (error) {
        NSLog(@"触觉引擎_模式播放器停止出错: %@", error.localizedDescription);
    }
}

// MARK: Play Pattern

/// 使用触觉引擎从文件播放触觉模式
/// @param engine 触觉引擎
/// @param filename 触觉模式文件
+ (void)useHapticEngine:(CHHapticEngine *)engine playHapticsWithAHAPFile:(NSString *)filename API_AVAILABLE(ios(13.0)) {
    if (!engine) {
        NSLog(@"触觉引擎_触觉引擎不存在!");
        return;
    }
    if (!CoreHapticsUtilShared.supportsHaptics) {
        NSLog(@"触觉引擎_设备不支持");
        return;
    }

    NSString *type = nil;
    if (![filename hasSuffix:@".ahap"]) {
        type = @"ahap";
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:type];
    if (!filePath) {
        NSLog(@"触觉引擎_%@%@文件未找到", filename, type ? @".ahap" : @"");
        return;
    }
    NSError *error = nil;
    [engine playPatternFromURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        NSLog(@"触觉引擎_从文件播放模式失败: %@", error.localizedDescription);
    }
}

/// 使用共享触觉引擎从文件播放触觉模式
/// @param filename 触觉模式文件
- (void)useSharedEnginePlayHapticsWithAHAPFile:(NSString *)filename API_AVAILABLE(ios(13.0)) {
    [CoreHapticsUtil useHapticEngine:self.sharedEngine playHapticsWithAHAPFile:filename];
}

@end
