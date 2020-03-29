//
//  Common.h
//  BWDemo
//
//  Created by wangzhi. on 2020/3/29.
//  Copyright © 2020 BTStudio. All rights reserved.
//

#ifndef Common_h
#define Common_h


#pragma mark - 文件引用

#import "BWConstant.h"


#pragma mark - 不同服务器环境的配置

#define URL_HEAD_PRODUCT     @"http://www.google.cn"
#define URL_HEAD_DEVELOP     @"https://www.baidu.com"
#define URL_HEAD_JIANSHU     @"https://www.jianshu.com"
#define URL_HEAD_BOKEYUAN    @"https://www.cnblogs.com"

#define APP_URL_HEAD \
({ \
    NSString *url = URL_HEAD_PRODUCT; \
    if (APP_SETTINGS_DEBUG_ENABLE) { \
        NSString *environment = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsAppServerKey]; \
        if ([environment isEqualToString:ServerProductKey]) { \
            url = URL_HEAD_PRODUCT; \
        } else if ([environment isEqualToString:ServerDevelopKey]) { \
            url = URL_HEAD_DEVELOP; \
        } else if ([environment isEqualToString:ServerJianshuKey]) { \
            url = URL_HEAD_JIANSHU; \
        } else if ([environment isEqualToString:ServerBokeyuanKey]) { \
            url = URL_HEAD_BOKEYUAN; \
        } \
    } \
    (url); \
}) \


#pragma mark - 开发调试相关的宏定义

/// 是否在App设置中开启了调试开关
#define APP_SETTINGS_DEBUG_ENABLE \
({ \
    BOOL enable = [[NSUserDefaults standardUserDefaults] boolForKey:UserDefaultsAppDebugEnableKey]; \
    (enable); \
}) \


#endif /* Common_h */
