//
//  LanguageCell.h
//  MeiQiGuard
//
//  Created by wangzhi on 2020/01/12.
//  Copyright © 2020年 wangzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const LanguageCellID;
UIKIT_EXTERN CGFloat const LanguageCellHeight;


/// 语言设置Cell
@interface LanguageCell : UITableViewCell

/// 标题
@property (nonatomic, copy) NSString *title;

/// Cell索引值
@property (nonatomic, strong) NSIndexPath *indexPath;

/// Cell是否被选中
@property (nonatomic, assign) BOOL cellSelected;

@end
