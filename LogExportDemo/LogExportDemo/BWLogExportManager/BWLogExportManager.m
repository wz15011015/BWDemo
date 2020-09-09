//
//  BWLogExportManager.m
//  LogExportDemo
//
//  Created by wangzhi on 2020/9/9.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import "BWLogExportManager.h"

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
#import "SceneDelegate.h"
#else
#endif

@interface BWLogExportManager () {
    NSString *_defaultLogFilePath;
}

/// Log文件夹路径
@property (nonatomic, copy) NSString *logFolderPath;

/// Log日志文件路径
@property (nonatomic, copy, readonly) NSString *logFilePath;

@end

@implementation BWLogExportManager

/// 单例
+ (instancetype)shared {
    static BWLogExportManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}


- (instancetype)init {
    if (self = [super init]) {
        // 创建 BWLog 文件夹
        _logFolderPath = [BWLogExportManager createFolderAtPath:[BWLogExportManager getDocumentPath] folderName:@"BWLog"];
        
        // 设置Log日志文件的默认名称 (默认使用时间作为文件名称)
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
        NSString *time = [dateFormatter stringFromDate:[NSDate date]];
        _logFileName = [NSString stringWithFormat:@"%@.log", time];
        
        // Log日志文件路径
        _defaultLogFilePath = [_logFolderPath stringByAppendingPathComponent:_logFileName];
        _logFilePath = _defaultLogFilePath;
    }
    return self;
}


#pragma mark - Setters

- (void)setLogFileName:(NSString *)logFileName {
    _logFileName = logFileName;
    
    // 拼接Log日志文件路径
    _logFilePath = [_logFolderPath stringByAppendingPathComponent:_logFileName];
}


#pragma mark - Public

/// 开始日志记录
- (void)startLogRecord {
    // 如果连接Xcode进行调试,则不输出到文件中
//    if (isatty(STDOUT_FILENO)) {
//        return;
//    }
    
    // 1. 判断Log日志文件是否已存在,若存在,则删除之前的文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:_logFilePath isDirectory:&isDirectory];
    if (exists) {
        NSError *error = nil;
        [fileManager removeItemAtPath:_logFilePath error:nil];
        if (error) {
            NSLog(@"delete file error: %@", error.localizedDescription);
        }
    }
    
    // 2. 将日志信息写入到Log日志文件中
    freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

/// 通过系统的分享功能导出Log日志文件
/// @param viewController  弹出系统分享弹窗的控制器
- (void)exportLogFileInViewController:(UIViewController *)viewController {
    // 1. 获取文件路径
    NSURL *fileURL = nil;
    // 判断文件是否存在
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:self.logFilePath isDirectory:&isDirectory];
    if (exists) {
        fileURL = [NSURL fileURLWithPath:self.logFilePath];
    } else {
        fileURL = [NSURL fileURLWithPath:_defaultLogFilePath];
    }
    
    // 2. 弹出系统分享控制器以导出文件
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *itemsArr = @[fileURL];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsArr applicationActivities:nil];
        
        // 适配iPad
        UIPopoverPresentationController *popVC = activityViewController.popoverPresentationController;
        popVC.sourceView = viewController.view;
        [viewController presentViewController:activityViewController animated:YES completion:nil];
    });
}

/// 通过系统的分享功能导出Log日志文件
- (void)exportLogFile {
    UIWindow *window = [BWLogExportManager getCurrentWindow];
    [self exportLogFileInViewController:window.rootViewController];
}


#pragma mark - Tool Methods

/// 获取 Document 路径
+ (NSString *)getDocumentPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

/// 创建指定路径的文件夹
/// @param path 指定的路径
/// @param name 文件夹名称
+ (NSString *)createFolderAtPath:(NSString *)path folderName:(NSString *)name {
    // 1. 拼接文件夹路径
    NSString *folderPath = [NSString stringWithFormat:@"%@/%@", path, name];
    
    // 2. 判断文件夹是否存在,如果不存在,则创建文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL exists = [fileManager fileExistsAtPath:folderPath isDirectory:&isDirectory];
    if (exists) { // 文件夹已存在,则直接返回文件夹路径
        return folderPath;
    }
    
    // 3. 文件夹不存在或者不是文件夹,则创建文件夹
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success || error) { // 创建文件夹失败
        NSLog(@"create folder error: %@", error.localizedDescription);
        return nil;
    }
    // 创建文件夹成功,返回文件夹路径
    return folderPath;
}

/// 获取应用程序当前窗口
+ (UIWindow *)getCurrentWindow {
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if (@available(iOS 13.0, *)) {
        NSSet *scenes = UIApplication.sharedApplication.connectedScenes;
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive ||
                scene.activationState == UISceneActivationStateForegroundInactive) {
                SceneDelegate *delegate = (SceneDelegate *)scene.delegate;
                window = delegate.window;
                break;
            }
        }
    }
#else
    
#endif
    return window;
}

@end
