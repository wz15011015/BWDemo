//
//  FeedbackGeneratorUtil.h
//  Haptics
//
//  Created by hadlinks on 2020/11/23.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedbackGeneratorUtil : NSObject

// MARK: 添加触感反馈

/// 产生触感反馈效果
///
/// 1. iOS 13.0之前, 无强度参数 intensity
///
/// 2. iOS 13.0之后, 增加强度参数 intensity , 即可以指定触感反馈强度
///
///  - intensity 设置为0.0时, 无触感反馈
///
///  - intensity 设置为1.0时, 其强度等价于 iOS 13.0之前的无intensity时的强度
///
/// @param style 触感反馈类型
/// @param intensity 触感反馈强度 [0.0, 1.0]
+ (void)generateImpactFeedbackWithStyle:(UIImpactFeedbackStyle)style intensity:(CGFloat)intensity;

/// 产生触感反馈效果
/// @param style 触感反馈类型
+ (void)generateImpactFeedbackWithStyle:(UIImpactFeedbackStyle)style;

/// 产生触感反馈效果
+ (void)generateImpactFeedback;


// MARK: 播放声音

/// 使用系统声音服务播放系统声音
///
/// Apple官方公布的系统铃声列表: http://iphonedevwiki.net/index.php/AudioServices
///
/// @param soundID 声音ID, UInt32类型
+ (void)playSystemSoundWithSoundID:(SystemSoundID)soundID;

/// 使用系统声音服务播放指定的声音文件
/// @param name 声音文件名称
/// @param type 声音文件类型
+ (void)playSoundWithName:(NSString *)name type:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
