//
//  DeviceListViewController.m
//  LocationDemo
//
//  Created by BTStudio on 2020/10/24.
//

#import "DeviceListViewController.h"

@interface DeviceListViewController ()

@end

@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor brownColor];
    
    // 停止定位
    [self.locationManager stopUpdatingLocation];
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
