//
//  WiFiViewController.m
//  LocationDemo
//
//  Created by BTStudio on 2020/10/24.
//

#import "WiFiViewController.h"
#import "ViewController.h"
#import "DeviceListViewController.h"

@interface WiFiViewController () <CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation WiFiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor orangeColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(jumpToDeviceList)];
    
    
    self.locationManager.delegate = self;
    
    [self autoRequestTemporaryFullAccuracyAuthorization];
    
    
    NSString *wifiName = [ViewController wifiName];
    self.nameLabel.text = [NSString stringWithFormat:@"WiFi名称: %@", wifiName];
    NSLog(@"WiFi名称: %@", wifiName);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoRequestTemporaryFullAccuracyAuthorization];
    });
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}


/// 自动请求临时开启一次精确定位权限
///
/// - 当前为精确定位时, 不去请求
///
/// - 当前不是精确定位时, 去请求
///
- (void)autoRequestTemporaryFullAccuracyAuthorization {
    if (@available(iOS 14.0, *)) {
        CLAccuracyAuthorization accuracyStatus = self.locationManager.accuracyAuthorization;
        if (accuracyStatus == CLAccuracyAuthorizationFullAccuracy) {
            NSLog(@"当前为精确定位状态,不需要申请临时开启一次精确位置权限.");
        } else {
            NSLog(@"当前为模糊定位状态,需要向用户申请临时开启一次精确位置权限.");
            
            // 向用户申请临时开启一次精确位置权限
            [self.locationManager requestTemporaryFullAccuracyAuthorizationWithPurposeKey:@"WantsToGetWiFiSSID"];
        }
    }
}


#pragma mark - Events

- (IBAction)jumpToDeviceList {
    DeviceListViewController *vc = [[DeviceListViewController alloc] init];
    vc.locationManager = self.locationManager;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Notifications

/// App进入后台时调用
- (void)applicationDidEnterBackground {
    NSLog(@"App进入后台");
}

/// App进入前台时调用
- (void)applicationWillEnterForeground {
    NSLog(@"App进入前台");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoRequestTemporaryFullAccuracyAuthorization];
    });
}

/// App重新激活时调用
- (void)applicationDidBecomeActive {
//    NSLog(@"App重新激活");

//    [self autoRequestTemporaryFullAccuracyAuthorization];
}


#pragma mark - CLLocationManagerDelegate

/// 定位授权状态发生改变
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"当前定位权限状态: %d", status);
}

/// 定位授权状态发生改变
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0)) {
    // 1. 定位权限状态
    CLAuthorizationStatus status = manager.authorizationStatus;
    NSLog(@"当前定位权限状态:: %d", status);
    
    // 2. 精确定位权限状态
    CLAccuracyAuthorization accuracyStatus = manager.accuracyAuthorization;
    if (accuracyStatus == CLAccuracyAuthorizationFullAccuracy) {
        NSLog(@"精确定位已开启");
    } else {
        NSLog(@"精确定位未开启");
    }
    
    NSString *wifiName = [ViewController wifiName];
    self.nameLabel.text = [NSString stringWithFormat:@"WiFi名称: %@", wifiName];
    NSLog(@"WiFi名称:: %@", wifiName);
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
