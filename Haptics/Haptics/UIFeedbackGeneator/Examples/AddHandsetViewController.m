//
//  AddHandsetViewController.m
//  MeiQiGuard
//
//  Created by 王志 on 2019/12/29.
//  Copyright © 2019 Hadlinks. All rights reserved.
//

#import "AddHandsetViewController.h"
#import "FeedbackGeneatorUtil.h"
#import "SGQRCode.h"

@interface AddHandsetViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIView *imeiView;
@property (nonatomic, weak) IBOutlet UILabel *imeiTitleLabel;
@property (nonatomic, weak) IBOutlet UITextField *imeiTextField;
@property (nonatomic, weak) IBOutlet UIButton *addButton;
@property (nonatomic, weak) IBOutlet UIButton *scanButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *addButtonH;

@property (nonatomic, weak) IBOutlet UITextField *imeiTextField2;
@property (nonatomic, assign) BOOL needImpactFeedback;

@property (nonatomic, copy) NSString *imei;


@end

@implementation AddHandsetViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"UIImpactFeedbackStyleMedium";
    
    [self setupData];
    [self setupUI];
}


#pragma mark - Events

- (IBAction)scanEvent:(UIButton *)sender {
    [self.view endEditing:YES];

    // 在 SGQRCodeScanningVC.m 中的 - (void)captureOutput:didOutputMetadataObjects:fromConnection:
    // 方法中调用了 [FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
    
    SGQRCodeScanningVC *vc = [[SGQRCodeScanningVC alloc] init];
    if (sender.tag == 1) {
        vc.needImpactFeedback = NO;
        self.needImpactFeedback = NO;
    } else {
        vc.needImpactFeedback = YES;
        self.needImpactFeedback = YES;
    }
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)setupData {
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(SGQRCodeInformationFromScanning:) name:SGQRCodeInformationFromScanning object:nil];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor colorWithRed:245 / 255.0 green:247 / 255.0 blue:247 / 255.0 alpha:1.0];
    self.imeiView.backgroundColor = [UIColor whiteColor];
    self.imeiTitleLabel.textColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1.0];
    
    // 字体自适应
    self.imeiTextField.minimumFontSize = 10;
    self.imeiTextField.adjustsFontSizeToFitWidth = YES;
    
    self.addButton.layer.cornerRadius = self.addButtonH.constant / 2;
    self.addButton.layer.masksToBounds = YES;
    [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.addButton setBackgroundColor:[UIColor colorWithRed:209 / 255.0 green:237 / 255.0 blue:240 / 255.0 alpha:1.0]];
    self.addButton.enabled = NO;
    
    [self.addButton setTitle:NSLocalizedString(@"Add handset", nil) forState:UIControlStateNormal];
}


#pragma mark - SGQRCodeNotification

- (void)SGQRCodeInformationFromScanning:(NSNotification *)notification {
    NSString *codeInfo = notification.object;
    
    self.imei = codeInfo;
    
    if (self.needImpactFeedback) {
        self.imeiTextField2.text = self.imei;
    } else {
        self.imeiTextField.text = self.imei;
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
