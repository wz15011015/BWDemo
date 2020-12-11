//
//  SGQRCodeScanningView.m
//  SGQRCodeExample
//
//  Created by apple on 17/3/20.
//  Copyright © 2017年 Sorgle. All rights reserved.
//

#import "SGQRCodeScanningView.h"
#import <AVFoundation/AVFoundation.h>
#import "SGQRCodeConst.h"

/** 扫描内容的Y值 */
#define scanContent_Y self.frame.size.height * 0.24
/** 扫描内容的Y值 */
#define scanContent_X self.frame.size.width * 0.15

@interface SGQRCodeScanningView ()

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) CALayer *tempLayer;
@property (nonatomic, strong) CALayer *scanContentLayer; // 扫描内容边框
@property (nonatomic, strong) UIImageView *scanningline;
@property (nonatomic, strong) NSTimer *timer;

/// 扫描外部四周的图层(上/左/下/右)
@property (nonatomic, strong) CALayer *scanTopLayer;
@property (nonatomic, strong) CALayer *scanLeftLayer;
@property (nonatomic, strong) CALayer *scanBottomLayer;
@property (nonatomic, strong) CALayer *scanRightLayer;

/// 扫描边角图片
@property (nonatomic, strong) UIImageView *leftTopImageView;
@property (nonatomic, strong) UIImageView *rightTopImageView;
@property (nonatomic, strong) UIImageView *leftBottomImageView;
@property (nonatomic, strong) UIImageView *rightBottomImageView;

/// 提示Label
@property (nonatomic, strong) UILabel *promptLabel;
/// 闪光灯开关按钮
@property (nonatomic, strong) UIButton *lightButton;

@end

@implementation SGQRCodeScanningView

/** 扫描动画线(冲击波) 的高度 */
static CGFloat const scanninglineHeight = 12;
/** 扫描内容外部View的alpha值 */
static CGFloat const scanBorderOutsideViewAlpha = 0.4;


- (instancetype)initWithFrame:(CGRect)frame layer:(CALayer *)layer {
    if (self = [super initWithFrame:frame]) {
//        self.tempLayer = layer;
        
        self.tempLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        [self.layer addSublayer:self.tempLayer];
        
        // 布局扫描界面
        [self setupSubviews];
    }
    return self;
}

+ (instancetype)scanningViewWithFrame:(CGRect )frame layer:(CALayer *)layer {
    return [[self alloc] initWithFrame:frame layer:layer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    self.tempLayer.frame = CGRectMake(0, 0, width, height);
    
    // 1. 扫描内容位置的调整
    CGFloat scanContentX = scanContent_X;
    CGFloat scanContentY = scanContent_Y;
    if (width > height) { // 横屏
        scanContentX = width * 0.3;
        scanContentY = height * 0.2;
    } else { // 竖屏
    }
    CGFloat scanContentW = width - 2 * scanContentX;
    CGFloat scanContentH = scanContentW;
    NSLog(@"SGQRCodeScanningView layoutSubviews:(%f, %f)", width, height);
    
    CGRect scanContentFrame = self.scanContentLayer.frame;
    scanContentFrame.origin.x = scanContentX;
    scanContentFrame.origin.y = scanContentY;
    scanContentFrame.size.width = scanContentW;
    scanContentFrame.size.height = scanContentH;
    self.scanContentLayer.frame = scanContentFrame;
    
    
    // 2. 扫描外部四周的图层位置调整
    CGRect scanTopFrame = self.scanTopLayer.frame;
    scanTopFrame.size.width = width;
    scanTopFrame.size.height = scanContentY;
    self.scanTopLayer.frame = scanTopFrame;

    CGRect scanBottomFrame = self.scanBottomLayer.frame;
    scanBottomFrame.origin.y = CGRectGetMaxY(scanContentFrame);
    scanBottomFrame.size.width = width;
    scanBottomFrame.size.height = height - CGRectGetMaxY(scanContentFrame);
    self.scanBottomLayer.frame = scanBottomFrame;

    CGRect scanLeftFrame = self.scanLeftLayer.frame;
    scanLeftFrame.origin.y = scanContentY;
    scanLeftFrame.size.width = scanContentX;
    scanLeftFrame.size.height = scanContentH;
    self.scanLeftLayer.frame = scanLeftFrame;

    CGRect scanRightFrame = self.scanRightLayer.frame;
    scanRightFrame.origin.x = CGRectGetMaxX(scanContentFrame);
    scanRightFrame.origin.y = scanContentY;
    scanRightFrame.size.width = 1000;
    scanRightFrame.size.height = scanContentH;
    self.scanRightLayer.frame = scanRightFrame;
    
    
    // 3. 扫描边角图片的位置调整
    CGFloat margin = 7;
    
    CGRect leftTopImageFrame = self.leftTopImageView.frame;
    leftTopImageFrame.origin.x = CGRectGetMinX(scanContentFrame) - leftTopImageFrame.size.width * 0.5 + margin;
    leftTopImageFrame.origin.y = CGRectGetMinY(scanContentFrame) - leftTopImageFrame.size.width * 0.5 + margin;
    self.leftTopImageView.frame = leftTopImageFrame;
    
    CGRect rightTopImageFrame = self.rightTopImageView.frame;
    rightTopImageFrame.origin.x = CGRectGetMaxX(scanContentFrame) - leftTopImageFrame.size.width * 0.5 - margin;
    rightTopImageFrame.origin.y = leftTopImageFrame.origin.y;
    self.rightTopImageView.frame = rightTopImageFrame;
    
    CGRect leftBottomImageFrame = self.leftBottomImageView.frame;
    leftBottomImageFrame.origin.x = leftTopImageFrame.origin.x;
    leftBottomImageFrame.origin.y = CGRectGetMaxY(scanContentFrame) - leftBottomImageFrame.size.width * 0.5 - margin;
    self.leftBottomImageView.frame = leftBottomImageFrame;
    
    CGRect rightBottomImageFrame = self.rightBottomImageView.frame;
    rightBottomImageFrame.origin.x = rightTopImageFrame.origin.x;
    rightBottomImageFrame.origin.y = leftBottomImageFrame.origin.y;
    self.rightBottomImageView.frame = rightBottomImageFrame;
    
    CGRect scanningLineFrame = self.scanningline.frame;
    scanningLineFrame.origin.x = scanContentX;
    scanningLineFrame.origin.y = scanContentY;
    scanningLineFrame.size.width = scanContentW;
    self.scanningline.frame = scanningLineFrame;

    
    // 4. 其他控件位置的调整
    CGRect promptLabelFrame = self.promptLabel.frame;
    promptLabelFrame.origin.y = CGRectGetMaxY(scanContentFrame) + 30;
    promptLabelFrame.size.width = width;
    self.promptLabel.frame = promptLabelFrame;
    
    CGRect lightButtonFrame = self.lightButton.frame;
    lightButtonFrame.origin.y = CGRectGetMaxY(promptLabelFrame) + 10;
    lightButtonFrame.size.width = width;
    self.lightButton.frame = lightButtonFrame;
}


- (void)setupSubviews {
    // 扫描内容的创建 (扫描内容的边框)
    CALayer *scanContent_layer = [[CALayer alloc] init];
    CGFloat scanContent_layerX = scanContent_X;
    CGFloat scanContent_layerY = scanContent_Y;
    CGFloat scanContent_layerW = self.frame.size.width - 2 * scanContent_X;
    CGFloat scanContent_layerH = scanContent_layerW;
    scanContent_layer.frame = CGRectMake(scanContent_layerX, scanContent_layerY, scanContent_layerW, scanContent_layerH);
    scanContent_layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6].CGColor;
    scanContent_layer.borderWidth = 0.7;
    scanContent_layer.backgroundColor = [UIColor clearColor].CGColor;
    self.scanContentLayer = scanContent_layer;
    [self.tempLayer addSublayer:scanContent_layer];
    
#pragma mark - - - 扫描外部View的创建
    // 顶部layer的创建
    CALayer *top_layer = [[CALayer alloc] init];
    CGFloat top_layerX = 0;
    CGFloat top_layerY = 0;
    CGFloat top_layerW = self.frame.size.width;
    CGFloat top_layerH = scanContent_layerY;
    top_layer.frame = CGRectMake(top_layerX, top_layerY, top_layerW, top_layerH);
    top_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    self.scanTopLayer = top_layer;
    [self.layer addSublayer:top_layer];
    
    // 左侧layer的创建
    CALayer *left_layer = [[CALayer alloc] init];
    CGFloat left_layerX = 0;
    CGFloat left_layerY = scanContent_layerY;
    CGFloat left_layerW = scanContent_X;
    CGFloat left_layerH = scanContent_layerH;
    left_layer.frame = CGRectMake(left_layerX, left_layerY, left_layerW, left_layerH);
    left_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    self.scanLeftLayer = left_layer;
    [self.layer addSublayer:left_layer];
    
    // 右侧layer的创建
    CALayer *right_layer = [[CALayer alloc] init];
    CGFloat right_layerX = CGRectGetMaxX(scanContent_layer.frame);
    CGFloat right_layerY = scanContent_layerY;
    CGFloat right_layerW = scanContent_X;
    CGFloat right_layerH = scanContent_layerH;
    right_layer.frame = CGRectMake(right_layerX, right_layerY, right_layerW, right_layerH);
    right_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    self.scanRightLayer = right_layer;
    [self.layer addSublayer:right_layer];
    
    // 下面layer的创建
    CALayer *bottom_layer = [[CALayer alloc] init];
    CGFloat bottom_layerX = 0;
    CGFloat bottom_layerY = CGRectGetMaxY(scanContent_layer.frame);
    CGFloat bottom_layerW = self.frame.size.width;
    CGFloat bottom_layerH = self.frame.size.height - bottom_layerY;
    bottom_layer.frame = CGRectMake(bottom_layerX, bottom_layerY, bottom_layerW, bottom_layerH);
    bottom_layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:scanBorderOutsideViewAlpha].CGColor;
    self.scanBottomLayer = bottom_layer;
    [self.layer addSublayer:bottom_layer];
    
    // 提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    promptLabel.backgroundColor = [UIColor clearColor];
    CGFloat promptLabelX = 0;
    CGFloat promptLabelY = CGRectGetMaxY(scanContent_layer.frame) + 30;
    CGFloat promptLabelW = self.frame.size.width;
    CGFloat promptLabelH = 32;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptLabelW, promptLabelH);
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.numberOfLines = 0;
    promptLabel.font = [UIFont boldSystemFontOfSize:13.0];
    promptLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    promptLabel.text = NSLocalizedString(@"Put the QR code in the box and it will scan automatically", nil); // @"将二维码/条码放入框内，即可自动扫描"
    self.promptLabel = promptLabel;
    [self addSubview:promptLabel];
    
    // 添加闪光灯按钮
    UIButton *light_button = [[UIButton alloc] init];
    light_button.tag = 66;
    CGFloat light_buttonX = 0;
    CGFloat light_buttonY = CGRectGetMaxY(promptLabel.frame) + scanContent_X * 0.5;
    CGFloat light_buttonW = self.frame.size.width;
    CGFloat light_buttonH = 25;
    light_button.frame = CGRectMake(light_buttonX, light_buttonY, light_buttonW, light_buttonH);
    [light_button setTitle:NSLocalizedString(@"Turn on the light", nil) forState:UIControlStateNormal];
    [light_button setTitle:NSLocalizedString(@"Turn off the light", nil) forState:UIControlStateSelected];
    [light_button setTitleColor:promptLabel.textColor forState:(UIControlStateNormal)];
    light_button.titleLabel.font = [UIFont systemFontOfSize:17];
    [light_button addTarget:self action:@selector(light_buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.lightButton = light_button;
    [self addSubview:light_button];
    
#pragma mark - - - 扫描边角imageView的创建
    // 左上侧的image
    CGFloat margin = 7;
    
    UIImage *left_image = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeLeftTop"];
    UIImageView *left_imageView = [[UIImageView alloc] init];
    CGFloat left_imageViewX = CGRectGetMinX(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewY = CGRectGetMinY(scanContent_layer.frame) - left_image.size.width * 0.5 + margin;
    CGFloat left_imageViewW = left_image.size.width;
    CGFloat left_imageViewH = left_image.size.height;
    left_imageView.frame = CGRectMake(left_imageViewX, left_imageViewY, left_imageViewW, left_imageViewH);
    left_imageView.image = left_image;
    self.leftTopImageView = left_imageView;
    [self.tempLayer addSublayer:left_imageView.layer];
    
    // 右上侧的image
    UIImage *right_image = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeRightTop"];
    UIImageView *right_imageView = [[UIImageView alloc] init];
    CGFloat right_imageViewX = CGRectGetMaxX(scanContent_layer.frame) - right_image.size.width * 0.5 - margin;
    CGFloat right_imageViewY = left_imageView.frame.origin.y;
    CGFloat right_imageViewW = left_image.size.width;
    CGFloat right_imageViewH = left_image.size.height;
    right_imageView.frame = CGRectMake(right_imageViewX, right_imageViewY, right_imageViewW, right_imageViewH);
    right_imageView.image = right_image;
    self.rightTopImageView = right_imageView;
    [self.tempLayer addSublayer:right_imageView.layer];
    
    // 左下侧的image
    UIImage *left_image_down = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeLeftBottom"];
    UIImageView *left_imageView_down = [[UIImageView alloc] init];
    CGFloat left_imageView_downX = left_imageView.frame.origin.x;
    CGFloat left_imageView_downY = CGRectGetMaxY(scanContent_layer.frame) - left_image_down.size.width * 0.5 - margin;
    CGFloat left_imageView_downW = left_image.size.width;
    CGFloat left_imageView_downH = left_image.size.height;
    left_imageView_down.frame = CGRectMake(left_imageView_downX, left_imageView_downY, left_imageView_downW, left_imageView_downH);
    left_imageView_down.image = left_image_down;
    self.leftBottomImageView = left_imageView_down;
    [self.tempLayer addSublayer:left_imageView_down.layer];
    
    // 右下侧的image
    UIImage *right_image_down = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeRightBottom"];
    UIImageView *right_imageView_down = [[UIImageView alloc] init];
    CGFloat right_imageView_downX = right_imageView.frame.origin.x;
    CGFloat right_imageView_downY = left_imageView_down.frame.origin.y;
    CGFloat right_imageView_downW = left_image.size.width;
    CGFloat right_imageView_downH = left_image.size.height;
    right_imageView_down.frame = CGRectMake(right_imageView_downX, right_imageView_downY, right_imageView_downW, right_imageView_downH);
    right_imageView_down.image = right_image_down;
    self.rightBottomImageView = right_imageView_down;
    [self.tempLayer addSublayer:right_imageView_down.layer];
}

/// 扫描动画添加
- (void)addScanningline {
    [self.tempLayer addSublayer:self.scanningline.layer];
}


#pragma mark - - - 闪光灯的点击事件

- (void)light_buttonAction:(UIButton *)button {
    if (button.selected == NO) { // 点击打开闪光灯
        [self turnOnLight:YES];
        button.selected = YES;
    } else { // 点击关闭闪光灯
        [self turnOnLight:NO];
        button.selected = NO;
    }
}

- (void)turnOnLight:(BOOL)on {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([_device hasTorch]) {
        [_device lockForConfiguration:nil];
        if (on) {
            [_device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [_device setTorchMode:AVCaptureTorchModeOff];
        }
        [_device unlockForConfiguration];
    }
}


#pragma mark - - - 添加定时器

- (void)addTimer {
    [self addScanningline];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:SGQRCodeScanningLineAnimation target:self selector:@selector(timeAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

#pragma mark - - - 移除定时器

- (void)removeTimer {
    [self.timer invalidate];
    self.timer = nil;
    [self.scanningline removeFromSuperview];
    self.scanningline = nil;
}

#pragma mark - - - 执行定时器方法

- (void)timeAction {
    static BOOL flag = YES;
    __block CGRect frame = self.scanningline.frame;
    CGFloat scanContentY = CGRectGetMinY(self.scanContentLayer.frame);
    
    if (flag) {
        frame.origin.y = scanContentY;
        flag = NO;
        [UIView animateWithDuration:SGQRCodeScanningLineAnimation animations:^{
            frame.origin.y += 5;
            self.scanningline.frame = frame;
        } completion:nil];
        
    } else {
        if (self.scanningline.frame.origin.y >= scanContentY) {
            CGFloat scanContentMaxY = CGRectGetMaxY(self.scanContentLayer.frame);
            if (self.scanningline.frame.origin.y >= scanContentMaxY - 10) {
                frame.origin.y = scanContentY;
                self.scanningline.frame = frame;
                flag = YES;
            } else {
                [UIView animateWithDuration:SGQRCodeScanningLineAnimation animations:^{
                    frame.origin.y += 5;
                    self.scanningline.frame = frame;
                } completion:nil];
            }
        } else {
            flag = !flag;
        }
    }
}


#pragma mark - Setters

- (void)setTurnOnLight:(BOOL)turnOnLight {
    _turnOnLight = turnOnLight;  
    
    if (turnOnLight) {
//        NSLog(@"显示");
    } else {
//        NSLog(@"隐藏");
    }
}

#pragma mark - Getters

- (CALayer *)tempLayer {
    if (!_tempLayer) {
        _tempLayer = [[CALayer alloc] init];
    }
    return _tempLayer;
}

- (UIImageView *)scanningline {
    if (!_scanningline) {
        _scanningline = [[UIImageView alloc] init];
        _scanningline.image = [UIImage imageNamed:@"SGQRCode.bundle/QRCodeScanningLine"];
        _scanningline.frame = CGRectMake(scanContent_X, scanContent_Y, self.frame.size.width - 2 * scanContent_X, scanninglineHeight);
    }
    return _scanningline;
}

@end
