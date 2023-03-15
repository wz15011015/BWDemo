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
//    FILE *_logFile;
}

/// Log文件夹路径
@property (nonatomic, copy) NSString *logFolderPath;

/// Log日志文件路径
@property (nonatomic, copy, readonly) NSString *logFilePath;

/// 日志导出按钮所在控制器
@property (nonatomic, strong) UIViewController *viewController;

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
        
//        _logFile = NULL;
    }
    return self;
}


#pragma mark - Getters

- (UIButton *)logExportButton {
    if (!_logExportButton) {
        _logExportButton = [UIButton buttonWithType:UIButtonTypeSystem];
        _logExportButton.frame = CGRectMake(0, 0, 120, 44);
        _logExportButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _logExportButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_logExportButton setTitle:NSLocalizedString(@"Log Export", nil) forState:UIControlStateNormal];
        [_logExportButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_logExportButton addTarget:self action:@selector(didClickLogExportButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logExportButton;
}


#pragma mark - Setters

- (void)setLogFileName:(NSString *)logFileName {
    _logFileName = logFileName;
    
    // 拼接Log日志文件路径
    _logFilePath = [_logFolderPath stringByAppendingPathComponent:_logFileName];
}


#pragma mark - Events

/// 日志记录导出事件
- (void)didClickLogExportButton {
    [self exportLogFile];
}


#pragma mark - Public

/// 开始日志记录
/// @param xcodeEnable 连接Xcode运行时,是否记录日志
- (void)startLogRecordWithXcodeEnable:(BOOL)xcodeEnable {
    // 1. isatty(int) : 该函数主要功能是检查设备类型，判断文件描述符是否是为终端机。
    //
    // 2. NSLog输出的日志内容，最终都是通过STDERR_FILENO句柄来记录的，所以可以考虑对其进行重定向
    // （当然，重定向之后就无法在控制台看到日志打印了）。
    //
    // 3. 利用C语言的freopen函数进行重定向，将写往stderr的内容重定向到我们指定的文件中去。
    // FILE *freopen(const char *__restrict, const char *__restrict, FILE *__restrict);
    // 第一个参数：重定向到目标文件的路径
    // 第二个参数：文件的打开模式，r/w/a/+等
    // 第三个参数：被打开的文件名，通常使用标准流文件（stdin/stdout/stderr）
    
    // 1. 删除之前的Log日志文件
    [BWLogExportManager deleteFileAtPath:_logFilePath];
    
    // 2. 将日志信息写入到Log日志文件中
    if (xcodeEnable) {
        // 记录原始的输出流并存储
        [BWLogExportManager record_STDOUT_STDERR_FILENO];
        
        // 利用freopen进行重定向
        freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
        freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
    } else {
        if (isatty(STDOUT_FILENO)) { // 如果连接Xcode运行,则不输出到文件中
            
        } else {
            // 记录原始的输出流并存储
            [BWLogExportManager record_STDOUT_STDERR_FILENO];
            
            // 利用freopen进行重定向
            freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
            freopen([_logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
        }
    }
}

/// 开始日志记录 (连接Xcode运行时,不记录日志)
- (void)startLogRecord {
    [self startLogRecordWithXcodeEnable:NO];
}

/// 停止日志记录
/// @param remove 是否移除日志导出按钮
- (void)stopLogRecordWithExportButtonRemove:(BOOL)remove {
    // 恢复重定向
    [BWLogExportManager recover_STDOUT_STDERR_FILENO];
    
//    fclose(_logFile);
//    _logFile = NULL;
    
    if (remove) {
        [self removeExportButtonInViewController:self.viewController];
    }
}

/// 停止日志记录
- (void)stopLogRecord {
    [self stopLogRecordWithExportButtonRemove:NO];
}

/// 清除日志缓存文件
- (void)clearLogCaches {
    NSString *folderPath = BWLogExportManagerShared.logFolderPath;
    [BWLogExportManager deleteFolderAtPath:folderPath];
}

// MARK: UI

/// 添加日志导出按钮到控制器右上角 (rightBarButtonItem)
/// @param viewController 控制器
- (void)addExportButtonInViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    self.viewController = viewController;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.logExportButton];
        viewController.navigationItem.rightBarButtonItem = rightItem;
    });
}

/// 移除日志导出按钮
/// @param viewController 按钮所在控制器
- (void)removeExportButtonInViewController:(UIViewController *)viewController {
    if (!viewController) {
        return;
    }
    if (viewController == self.viewController) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.logExportButton.hidden = YES;
            
            viewController.navigationItem.rightBarButtonItem = nil;
        });
    }
}

/// 通过系统的分享功能导出Log日志文件
/// @param viewController  弹出系统分享弹窗的控制器
- (void)exportLogFileInViewController:(UIViewController *)viewController {
    // 1. 获取文件路径
    NSURL *fileURL = nil;
    // 判断文件是否存在
    if ([BWLogExportManager existsFileAtPath:self.logFilePath]) {
        fileURL = [NSURL fileURLWithPath:self.logFilePath];
    } else {
        fileURL = [NSURL fileURLWithPath:_defaultLogFilePath];
    }
    
    // 2. 弹出系统分享控制器以导出文件
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *itemsArr = @[fileURL];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsArr applicationActivities:nil];
        activityViewController.completionWithItemsHandler = ^(UIActivityType __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError) {
            NSLog(@"completion: %@, %d, %@, %@", activityType, completed, returnedItems, activityError);
        };
        
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


// MARK: 文件相关操作

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
    
    // 2. 判断文件夹是否存在
    if ([self existsFolderAtPath:folderPath]) {
        return folderPath; // 文件夹已存在,则直接返回文件夹路径
    }
    
    // 3. 文件夹不存在或者不是文件夹,则创建文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    BOOL success = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success || error) { // 创建文件夹失败
        NSLog(@"create folder error: %@", error.localizedDescription);
        return nil;
    }
    // 创建文件夹成功,返回文件夹路径
    return folderPath;
}

/// 判断文件是否存在
/// @param filePath 文件路径
/// @param isDirectory 是否为目录
+ (BOOL)existsFileAtPath:(NSString *)filePath isDirectory:(BOOL)isDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL exists = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    return exists;
}

/// 判断文件是否存在
/// @param filePath 文件路径
+ (BOOL)existsFileAtPath:(NSString *)filePath {
    return [self existsFileAtPath:filePath isDirectory:NO];
}

/// 判断文件夹是否存在
/// @param folderPath 文件夹路径
+ (BOOL)existsFolderAtPath:(NSString *)folderPath {
    return [self existsFileAtPath:folderPath isDirectory:YES];
}

/// 删除文件
/// @param filePath 文件路径
/// @param isDirectory 是否为目录
+ (void)deleteFileAtPath:(NSString *)filePath isDirectory:(BOOL)isDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    BOOL exists = [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory];
    if (exists) {
        NSError *error = nil;
        [fileManager removeItemAtPath:filePath error:nil];
        if (error) {
            NSLog(@"delete file error: %@", error.localizedDescription);
        }
    }
}

/// 删除文件
/// @param filePath 文件路径
+ (void)deleteFileAtPath:(NSString *)filePath {
    [self deleteFileAtPath:filePath isDirectory:NO];
}

/// 删除文件夹
/// @param folderPath 文件夹路径
+ (void)deleteFolderAtPath:(NSString *)folderPath {
    [self deleteFileAtPath:folderPath isDirectory:YES];
}


// MARK: STDOUT_FILENO & STDERR_FILENO

/// 记录原始的输出流
+ (void)record_STDOUT_STDERR_FILENO {
    // https://juejin.cn/post/6844904151881646093
    
    // 1. dup(int) : 该函数可以复制一个文件描述符。
    // 传给该函数一个既有的描述符，它就会返回一个新的描述符，这个新的描述符是传给它的描述符的拷贝。
    // 这意味着，这两个描述符共享同一个数据结构。
    //
    // 2. dup2(int, int) : 该函数允许调用者给定一个 源描述符 和 目标描述符，
    // 函数成功返回时，目标描述符（第二个参数）将变成 源描述符（第一个参数）的复制品，
    // 换句话说，两个文件描述符现在都指向同一个文件，并且是函数第一个参数指向的文件。
    
    int origin_STDOUT_FILENO = dup(STDOUT_FILENO);
    int origin_STDERR_FILENO = dup(STDERR_FILENO);
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", origin_STDOUT_FILENO] forKey:@"LOG_STDOUT_FILENO"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", origin_STDERR_FILENO] forKey:@"LOG_STDERR_FILENO"];
}

/// 恢复重定向
+ (void)recover_STDOUT_STDERR_FILENO {
    int origin_STDOUT_FILENO = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LOG_STDOUT_FILENO"] intValue];
    int origin_STDERR_FILENO = [[[NSUserDefaults standardUserDefaults] objectForKey:@"LOG_STDERR_FILENO"] intValue];
    dup2(origin_STDOUT_FILENO, STDOUT_FILENO);
    dup2(origin_STDERR_FILENO, STDERR_FILENO);
}

@end
