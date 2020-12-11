//
//  UIAlertController+Extension.m
//  Sumeida
//
//  Created by FangFang on 16/6/21.
//  Copyright © 2016年 hadlinks. All rights reserved.
//

#import "UIAlertController+Extension.h"

@implementation UIAlertController (Extension)

#pragma mark - Alert

/**
 * 提示警告：一个按键，点击则警告消失
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
              toController:(UIViewController *)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleCancel handler:firstHandler];
    [alertController addAction:firstAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}

/**
 * 提示警告：一个按键，点击则警告消失
 * 可显示加粗文本
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         boldTextInMessage:(NSString *)boldText
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
              toController:(UIViewController *)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleCancel handler:firstHandler];
    [alertController addAction:firstAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (message) { // 修改message
            alertController.messageLabel.font = [UIFont systemFontOfSize:13];
            
            NSMutableAttributedString *messageStr = [[NSMutableAttributedString alloc] initWithString:message];
            NSRange range = [message rangeOfString:boldText];
            if (range.location != NSNotFound) {
                [messageStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:13] range:range];
            }
            [alertController setValue:messageStr forKey:@"attributedMessage"];
        }
        
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}

/**
 * 提示警告：2个按键
 */
+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
                firstTitle:(NSString *)firstTitle
              firstHandler:(AlertHandler)firstHandler
               secondTitle:(NSString *)secondTitle
             secondHandler:(AlertHandler)secondHandler
              toController:(UIViewController *)controller {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:firstTitle style:UIAlertActionStyleCancel handler:firstHandler];
    
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:secondTitle style:UIAlertActionStyleDefault handler:secondHandler];
    if ([secondTitle isEqualToString:NSLocalizedString(@"Delete", nil)]) {
        [secondAction setValue:[UIColor colorWithRed:255 / 255.0 green:114 / 255.0 blue:114 / 255.0 alpha:1.0] forKey:@"_titleTextColor"];
    }
    
    [alertController addAction:firstAction];
    [alertController addAction:secondAction];
  
    dispatch_async(dispatch_get_main_queue(), ^{
        [controller presentViewController:alertController animated:YES completion:nil];
    });
}
 
@end




@implementation UIAlertController (BWLabelAdjust)

@dynamic titleLabel;
@dynamic messageLabel;

- (NSArray *)viewArray:(UIView *)root {
    static NSArray *_subviews = nil;
    _subviews = nil;
    for (UIView *view in root.subviews) {
        if (_subviews) {
            break;
        }
        if ([view isKindOfClass:[UILabel class]]) {
            _subviews = root.subviews;
            return _subviews;
        }
        [self viewArray:view];
    }
    return _subviews;
}

- (UILabel *)titleLabel {
    NSArray *views = [self viewArray:self.view];
    if (@available(iOS 12.0, *)) { // iOS 12 及其以上系统运行
        if (views.count < 2) {
            return nil;
        }
        return views[1];
    } else {
        if (views.count < 1) {
            return nil;
        }
        return views[0];
    }
}

- (UILabel *)messageLabel {
    NSArray *views = [self viewArray:self.view];
    if (@available(iOS 12.0, *)) { // iOS 12 及其以上系统运行
        if (views.count < 3) {
            return nil;
        }
        return views[2];
    } else {
        if (views.count < 2) {
            return nil;
        }
        return views[1];
    }
}

@end
