//
//  CoreHapticsUtil.h
//  Haptics
//
//  Created by hadlinks on 2020/11/24.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreHaptics/CoreHaptics.h>


/// 使用触觉体验(CoreHaptics)的流程:
///
/// 1. 判断设备是否支持触觉引擎
/// 2. 创建触觉引擎
/// 3. 创建触觉事件模式
/// 4. 创建模式播放器
/// 5. 启动触觉引擎
/// 6. 开启模式播放器,开始产生触觉体验
/// 7. 停止触觉引擎


#define CoreHapticsUtilShared [CoreHapticsUtil sharedInstance]


NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(13.0))
@interface CoreHapticsUtil : NSObject

/// 设备是否支持触觉引擎
@property (nonatomic, assign) BOOL supportsHaptics;

/// 共享触觉引擎
@property (nonatomic, strong) CHHapticEngine *sharedEngine;

/// 共享触觉引擎重置的回调
@property (nonatomic, copy) CHHapticEngineResetHandler engineResetHandler;

/// 共享触觉引擎停止运行的回调
@property (nonatomic, copy) CHHapticEngineStoppedHandler engineStoppedHandler;


- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

+ (instancetype)sharedInstance;


// MARK: - 触觉引擎

/// 创建触觉引擎
/// @param resetHandler 触觉引擎重置的回调
/// @param stoppedHandler 触觉引擎停止运行的回调
+ (CHHapticEngine *)createHapticEngineWithResetHandler:(CHHapticEngineResetHandler _Nullable)resetHandler stoppedHandler:(CHHapticEngineStoppedHandler _Nullable)stoppedHandler API_AVAILABLE(ios(13.0));

/// 启动触觉引擎以准备使用
/// @param engine 触觉引擎
/// @param completion 完成回调
+ (void)startHapticEngine:(CHHapticEngine *)engine completion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0));

/// 停止触觉引擎
/// @param engine 触觉引擎
/// @param completion 完成回调
+ (void)stopHapticEngine:(CHHapticEngine *)engine completion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0));

/// 启动共享触觉引擎以准备使用
/// @param completion 完成回调
- (void)startSharedEngineCompletion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0));

/// 停止共享触觉引擎
/// @param completion 完成回调
- (void)stopSharedEngineCompletion:(CHHapticCompletionHandler _Nullable)completion API_AVAILABLE(ios(13.0));


// MARK: - 触觉引擎模式播放器

// MARK: CHHapticPatternPlayer

/// 创建触觉引擎模式播放器
/// @param engine 触觉引擎
/// @param pattern 模式
+ (id<CHHapticPatternPlayer>)createPatternPlayerWithEngine:(CHHapticEngine *)engine pattern:(CHHapticPattern *)pattern API_AVAILABLE(ios(13.0));

// MARK: CHHapticAdvancedPatternPlayer

/// 创建触觉引擎高级模式播放器
/// @param engine 触觉引擎
/// @param pattern 模式
+ (id<CHHapticAdvancedPatternPlayer>)createAdvancedPatternPlayerWithEngine:(CHHapticEngine *)engine pattern:(CHHapticPattern *)pattern API_AVAILABLE(ios(13.0));

/// 开启模式播放器
/// @param player 模式播放器
/// @param time 开启时间 (传入 CHHapticTimeImmediate 或 0 表示立即开启)
+ (void)startPatternPlayer:(id<CHHapticPatternPlayer>)player atTime:(NSTimeInterval)time API_AVAILABLE(ios(13.0));

/// 停止模式播放器
/// @param player 模式播放器
/// @param time 停止时间 (传入 CHHapticTimeImmediate 或 0 表示立即停止)
+ (void)stopPatternPlayer:(id<CHHapticPatternPlayer>)player atTime:(NSTimeInterval)time API_AVAILABLE(ios(13.0));

// MARK: Play Pattern

/// 使用触觉引擎从文件播放触觉模式
/// @param engine 触觉引擎
/// @param filename 触觉模式文件
+ (void)useHapticEngine:(CHHapticEngine *)engine playHapticsWithAHAPFile:(NSString *)filename API_AVAILABLE(ios(13.0));

/// 使用共享触觉引擎从文件播放触觉模式
/// @param filename 触觉模式文件
- (void)useSharedEnginePlayHapticsWithAHAPFile:(NSString *)filename API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
