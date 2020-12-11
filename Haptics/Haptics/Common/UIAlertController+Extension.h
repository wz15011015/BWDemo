//
//  UIAlertController+Extension.h
//  Sumeida
//
//  Created by FangFang on 16/6/21.
//  Copyright © 2016年 hadlinks. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^InputHandle)(NSString *text);
typedef void (^AlertHandler)(UIAlertAction *action);

@interface UIAlertController (Extension)

#pragma mark - Alert

/**
 * 提示警告：一个按键，点击则警告消失
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
              toController:(UIViewController *)controller;

/**
 * 提示警告：一个按键，点击则警告消失
 * 可显示加粗文本
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         boldTextInMessage:(NSString *)boldText
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
              toController:(UIViewController *)controller;

/**
 * 提示警告：2个按键
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
               secondTitle:(NSString *)secondTitle
             secondHandler:(AlertHandler)secondHandler
              toController:(UIViewController *)controller;

@end




/**
 调整titleLabel/messageLabel的对齐方式
 */
@interface UIAlertController (BWLabelAdjust)

/**
 alertController title
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 alertController message
 */
@property (nonatomic, strong) UILabel *messageLabel;

@end
