//
//  WiFiViewController.h
//  LocationDemo
//
//  Created by BTStudio on 2020/10/24.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WiFiViewController : UIViewController

@property (nonatomic, strong) CLLocationManager *locationManager; // 定位管理器

@end

NS_ASSUME_NONNULL_END
