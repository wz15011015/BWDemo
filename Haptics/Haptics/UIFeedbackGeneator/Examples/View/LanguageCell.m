//
//  LanguageCell.m
//  MeiQiGuard
//
//  Created by wangzhi on 2020/01/12.
//  Copyright © 2020年 wangzhi. All rights reserved.
//

#import "LanguageCell.h"

NSString *const LanguageCellID = @"LanguageCellIdentifier";
CGFloat const LanguageCellHeight = 48;

@interface LanguageCell ()

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@property (nonatomic, weak) IBOutlet UIImageView *selectImageView;

@end

@implementation LanguageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.titleLabel.textColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark - Setter

- (void)setTitle:(NSString *)title {
    _title = title;
    
    self.titleLabel.text = title;
}

- (void)setCellSelected:(BOOL)cellSelected {
    _cellSelected = cellSelected;
    
    self.selectImageView.hidden = !cellSelected;
}

@end
