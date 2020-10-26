//
//  ViewController.m
//  LocationDemo
//
//  Created by BTStudio on 2020/10/24.
//

#import "ViewController.h"
#import "WiFiViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <systemconfiguration/captivenetwork.h>

@interface ViewController () <CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager; // 定位管理器

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self startAutoLocalization];
}


#pragma mark - Events

- (IBAction)jumpToWiFi {
    WiFiViewController *vc = [[WiFiViewController alloc] init];
    vc.locationManager = self.locationManager;
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 定位控制

/// 自动定位
- (void)startAutoLocalization {
    [self startAutoLocalizationWithAuthority:nil];
}

- (void)startAutoLocalizationWithAuthority:(void (^)(CLAuthorizationStatus status))authorizationStatus {
    if (![CLLocationManager locationServicesEnabled]) {
        // 定位服务不可用
        if (authorizationStatus) {
            authorizationStatus(kCLAuthorizationStatusRestricted);
        }
    } else {
        // 定位服务是否对本app授权
        CLAuthorizationStatus status = kCLAuthorizationStatusNotDetermined;
        if (@available(iOS 14.0, *)) {
            status = self.locationManager.authorizationStatus;
        } else {
            status = [CLLocationManager authorizationStatus];
        }
        switch (status) {
            case kCLAuthorizationStatusRestricted: // 定位服务授权状态是受限制的。可能是由于活动限制定位服务，用户不能改变。这个状态可能不是用户拒绝的定位服务。
                // 提示用户打开定位
                if (authorizationStatus) {
                    authorizationStatus(status);
                }
                break;
                
            case kCLAuthorizationStatusDenied:  // 已经被用户明确禁止定位
                // 提示用户打开定位
                if (authorizationStatus) {
                    authorizationStatus(status);
                }
                break;
                
            case kCLAuthorizationStatusNotDetermined: // 没有确定授权
                [self.locationManager requestWhenInUseAuthorization];
                break;
                
            default: // 已经授权
                [self.locationManager startUpdatingLocation];
                break;
        }
    }
}


#pragma mark - CLLocationManagerDelegate

/// 定位授权状态发生改变
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    NSLog(@"ViewController 当前定位权限状态: %d", status);
    if (kCLAuthorizationStatusAuthorizedAlways == status ||
        kCLAuthorizationStatusAuthorizedWhenInUse == status) {
        // 已经授权, 启动定位
        [self.locationManager startUpdatingLocation];
    }
    
    
    NSString *wifiName = [ViewController wifiName];
    self.nameLabel.text = [NSString stringWithFormat:@"WiFi名称: %@", wifiName];
    NSLog(@"ViewController WiFi名称: %@", wifiName);
}

- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0)) {
    // 1. 定位权限状态
    CLAuthorizationStatus status = self.locationManager.authorizationStatus;
    NSLog(@"ViewController 当前定位权限状态:: %d", status);
    if (kCLAuthorizationStatusAuthorizedAlways == status ||
        kCLAuthorizationStatusAuthorizedWhenInUse == status) {
        // 已经授权, 启动定位
        [self.locationManager startUpdatingLocation];
    }
    
    // 2. 精确定位权限状态
    CLAccuracyAuthorization accuracyStatus = manager.accuracyAuthorization;
    if (accuracyStatus == CLAccuracyAuthorizationFullAccuracy) {
        NSLog(@"ViewController 精确定位已开启");
    } else {
        NSLog(@"ViewController 精确定位未开启");
    }
    
    
    NSString *wifiName = [ViewController wifiName];
    self.nameLabel.text = [NSString stringWithFormat:@"WiFi名称: %@", wifiName];
    NSLog(@"ViewController WiFi名称:: %@", wifiName);
}

/// 定位信息发生改变
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    if (locations.count < 1) { // 失败
        [manager startUpdatingLocation];
        return;
    }
    // 成功
}


#pragma mark - Getters

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = 1000.0f;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        // 是否允许后台定位
//        _locationManager.allowsBackgroundLocationUpdates = YES;
        
        // 是否在状态栏显示后台定位指示器
        if (@available(iOS 11.0, *)) {
//            _locationManager.showsBackgroundLocationIndicator = YES;
        }
    }
    return _locationManager;
}


#pragma mark - Tools

/// 获取当前WiFi的名称(ssid)
+ (NSString *)wifiName {
    NSArray *interfaces = CFBridgingRelease(CNCopySupportedInterfaces());
    id info = nil;
    for (NSString *interfaceName in interfaces) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((CFStringRef)interfaceName);
        if (info) {
            break;
        }
    }
    NSDictionary *infoDic = (NSDictionary *)info;
    NSString *ssid = [infoDic objectForKey:@"SSID"]; // WiFi的名称
    NSString *bssid = [infoDic objectForKey:@"BSSID"]; // WiFi的mac地址
    NSLog(@"WiFi SSID = %@, MAC = %@", ssid, bssid);
    return ssid;
}

@end
