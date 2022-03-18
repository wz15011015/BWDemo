//
//  BWLogExportManager.h
//  LogExportDemo
//
//  Created by wangzhi on 2020/9/9.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define BWLogExportManagerShared [BWLogExportManager shared]


NS_ASSUME_NONNULL_BEGIN

/// 日志导出管理器
@interface BWLogExportManager : NSObject

/// Log日志文件名称 (默认格式为: 2020-01-01_08-59-59.log)
///
/// - 文件名称可设置为: xxx.log / xxx.txt, 建议设置为: xxx.log
///
/// - 提示: 需要在 开始日志记录 前设置文件名称,否则无效
@property (nonatomic, copy) NSString *logFileName;

/// 日志导出按钮
@property (nonatomic, strong) UIButton *logExportButton;


/// 单例
+ (instancetype)shared;


#pragma mark - 日志记录

/// 开始日志记录
/// @param xcodeEnable 连接Xcode运行时,是否记录日志
- (void)startLogRecordWithXcodeEnable:(BOOL)xcodeEnable;

/// 开始日志记录 (连接Xcode运行时,不记录日志)
- (void)startLogRecord;

/// 停止日志记录
/// @param remove 是否移除日志导出按钮
- (void)stopLogRecordWithExportButtonRemove:(BOOL)remove;

/// 停止日志记录
- (void)stopLogRecord;

/// 清除日志缓存文件
- (void)clearLogCaches;


// MARK: UI

/// 添加日志导出按钮到控制器右上角 (rightBarButtonItem)
/// @param viewController 控制器
- (void)addExportButtonInViewController:(UIViewController *)viewController;

/// 移除日志导出按钮
/// @param viewController 按钮所在控制器
- (void)removeExportButtonInViewController:(UIViewController *)viewController;

/// 通过系统的分享功能导出Log日志文件
/// @param viewController  弹出系统分享弹窗的控制器
- (void)exportLogFileInViewController:(UIViewController *)viewController;

/// 通过系统的分享功能导出Log日志文件
- (void)exportLogFile;

@end

NS_ASSUME_NONNULL_END
