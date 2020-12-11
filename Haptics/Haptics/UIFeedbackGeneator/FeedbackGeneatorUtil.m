//
//  FeedbackGeneatorUtil.m
//  Haptics
//
//  Created by hadlinks on 2020/11/23.
//

#import "FeedbackGeneatorUtil.h"

@implementation FeedbackGeneatorUtil

// MARK: 触感反馈

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
+ (void)generateImpactFeedbackWithStyle:(UIImpactFeedbackStyle)style intensity:(CGFloat)intensity {
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:style];
        [feedbackGenerator prepare];
        
        if (@available(iOS 13.0, *)) {
            [feedbackGenerator impactOccurredWithIntensity:intensity];
        } else {
            [feedbackGenerator impactOccurred];
        }
    }
}

/// 产生触感反馈效果
/// @param style 触感反馈类型
+ (void)generateImpactFeedbackWithStyle:(UIImpactFeedbackStyle)style {
    [self generateImpactFeedbackWithStyle:style intensity:1.0];
}

/// 产生触感反馈效果
+ (void)generateImpactFeedback {
    [self generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
}


// MARK: 播放声音

/// 使用系统声音服务播放系统声音
///
/// Apple官方公布的系统铃声列表: http://iphonedevwiki.net/index.php/AudioServices
///
/// .mp3 转 .caf 的终端命令:  afconvert mp3文件路径 目标caf文件路径 -d ima4 -f caff -v
/// 例如: afconvert /Users/xxx/Desktop/demo.mp3 /Users/xxx/Desktop/demo.caf -d ima4 -f caff -v
///
/// 由于自定义通知声音还是由 iOS 系统来播放的，所以对音频数据格式有限制，可以是如下四种之一：
/// Linear PCM       MA4 (IMA/ADPCM)       µLaw        aLaw
/// 对应音频文件格式是 aiff，wav，caf 文件，文件也必须放到 app 的 mainBundle 目录中。
///
/// 自定义通知声音的播放时间必须在 30s 内，如果超过这个限制，则将用系统默认通知声音替代。
///
/// @param soundID 声音ID, UInt32类型
+ (void)playSystemSoundWithSoundID:(SystemSoundID)soundID {
    // The system sound ID in the range 1000 to 2000
    if (soundID < 1000 || soundID > 2000) {
        NSLog(@"The system soundID in the range 1000 to 2000");
        soundID = 1000;
    }

    // 通过音效ID播放声音
    if (@available(iOS 9.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        });
        
        // 震动
//        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
//        });
        // 通过音效ID播放声音并带有震动
//        AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
//        });
    } else {
        AudioServicesPlaySystemSound(soundID);
    }
}

/// 使用系统声音服务播放指定的声音文件
/// @param name 声音文件名称
/// @param type 声音文件类型
+ (void)playSoundWithName:(NSString *)name type:(NSString *)type {
    if (name.length == 0) {
        return;
    }
    
    // 1. 获取声音文件的路径
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
    if (soundFilePath.length == 0) {
        return;
    }
    // 将地址字符串转换成url
    NSURL *soundFileURL = [NSURL fileURLWithPath:soundFilePath isDirectory:NO];
    
    // 2. 生成系统音效ID
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundFileURL, &soundID);

    // 3. 通过音效ID播放声音
    if (@available(iOS 9.0, *)) {
        AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        });
        
        // 震动
//        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, ^{
//        });
        // 通过音效ID播放声音并带有震动
//        AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
//        });
    } else {
        AudioServicesPlaySystemSound(soundID);
    }
}

@end
