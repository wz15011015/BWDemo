//
//  EditDeviceViewController.m
//  Haptics
//
//  Created by hadlinks on 2020/11/23.
//

#import "EditDeviceViewController.h"
#import "FeedbackGeneatorUtil.h"
#import "UIAlertController+Extension.h"

@interface EditDeviceViewController ()

@property (nonatomic, weak) IBOutlet UIButton *deleteButton1;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton2;

@end

@implementation EditDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"UIImpactFeedbackStyleHeavy";
    
    self.deleteButton1.layer.cornerRadius = 6.0;
    self.deleteButton1.layer.masksToBounds = YES;
    self.deleteButton2.layer.cornerRadius = 6.0;
    self.deleteButton2.layer.masksToBounds = YES;
}


#pragma mark - Action

- (IBAction)deleteDeviceAction:(UIButton *)sender {
    if (sender.tag == 1) {
        
    } else {
        // MARK: -------- UIImpactFeedbackGenerator 的使用 --------
        [FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleHeavy];
    }
        
    [UIAlertController showAlertWithTitle:NSLocalizedString(@"Delete Device", nil)
                                  message:NSLocalizedString(@"Are you sure you want to delete this device?", nil)
                               firstTitle:NSLocalizedString(@"Cancel", nil)
                             firstHandler:nil
                              secondTitle:NSLocalizedString(@"Delete", nil) secondHandler:^(UIAlertAction *action) {
        
                           } toController:self];
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
