//
//  SGQRCodeScanningVC.m
//  SGQRCodeExample
//
//  Created by apple on 17/3/20.
//  Copyright © 2017年 Sorgle. All rights reserved.
//

#import "SGQRCodeScanningVC.h"
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>
#import "SGQRCodeScanningView.h"
#import "SGQRCodeConst.h"
#import "UIImage+SGHelper.h"
#import "FeedbackGeneatorUtil.h"

@interface SGQRCodeScanningVC () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

/// 会话对象
@property (nonatomic, strong) AVCaptureSession *session;
/// 图层类
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

/// 视频输出流
@property (nonatomic, strong) AVCaptureVideoDataOutput *captureVideoOutput;

@property (nonatomic, strong) SGQRCodeScanningView *scanningView;

@end

@implementation SGQRCodeScanningVC

#pragma mark - Getters

- (AVCaptureVideoDataOutput *)captureVideoOutput {
    if (!_captureVideoOutput) {
        _captureVideoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _captureVideoOutput.alwaysDiscardsLateVideoFrames = YES;
        
        dispatch_queue_t queue;
        queue = dispatch_queue_create("cameraQueue", NULL);
        [_captureVideoOutput setSampleBufferDelegate:self queue:queue];
        
        // 设置视频格式
        NSString *key = (NSString *)kCVPixelBufferPixelFormatTypeKey;
        NSNumber *value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
        [_captureVideoOutput setVideoSettings:videoSettings];
    }
    return _captureVideoOutput;
}

- (SGQRCodeScanningView *)scanningView {
    if (!_scanningView) {
//        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:self.view.bounds layer:self.view.layer];
        
        // Brian修改
        _scanningView = [SGQRCodeScanningView scanningViewWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) layer:self.view.layer];
    }
    return _scanningView;
}


#pragma mark - Life cycle

- (void)dealloc {
    SGQRCodeLog(@"SGQRCodeScanningVC - dealloc");
    [self removeScanningView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor clearColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavigationBar];
    [self.view addSubview:self.scanningView];
    [self setupSGQRCodeScanning];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    self.previewLayer.frame = self.view.layer.bounds;
    
    CGRect scanningViewFrame = self.scanningView.frame;
    scanningViewFrame.size.width = width;
    scanningViewFrame.size.height = height;
    self.scanningView.frame = scanningViewFrame;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置navigationBar为半透明
//    self.navigationController.navigationBar.translucent = YES;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"SGQRCodeScanningVC_navigation_background"] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont navigationBarTitleFont]}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.scanningView addTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.scanningView removeTimer];
    
    // 还原navigationBar设置
//    self.navigationController.navigationBar.translucent = NO;
//    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//    self.navigationController.navigationBar.barTintColor = [UIColor navigationBarTintColor];
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont navigationBarTitleFont]}];
}


#pragma mark - Custom Methods

- (void)setupNavigationBar {
    self.navigationItem.title = NSLocalizedString(@"Scan", nil);
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"相册", nil) style:(UIBarButtonItemStyleDone) target:self action:@selector(rightBarButtonItenAction)];
}

- (void)removeScanningView {
    [self.scanningView removeTimer];
    [self.scanningView removeFromSuperview];
    self.scanningView = nil;
}

- (void)rightBarButtonItenAction {
    [self readImageFromAlbum];

    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 栅栏函数
    dispatch_barrier_async(queue, ^{
        [self removeScanningView];
    });
}

- (void)showRestrictedAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showDeniedAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)setupSGQRCodeScanning {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        NSLog(@"摄像设备不可用！");
        return;
    }
    // 2、获取相机的授权状态
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined: { // 用户还没有做出选择
            // 弹框请求用户授权
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) { // 用户第一次同意了使用相机的权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self createSGQRCodeScanning];
                    });
                } else { // 用户第一次拒绝了使用相机的权限
                    NSLog(@"用户第一次拒绝了使用相机的权限");
                }
            }];
        }
            break;
            
        case AVAuthorizationStatusRestricted: { // 当前应用使用相机是受限制的
            [self showRestrictedAlertWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"The camera cannot be used due to system reasons.", nil)];
        }
            break;
            
        case AVAuthorizationStatusDenied: { // 用户拒绝当前应用使用相机
            NSString *appName = @"Haptics"; // 当前应用的名称
            
            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"You have not authorized the application to use the camera, please go to [Settings - %@ - Camera] to turn on the access switch.", nil), appName];
            [self showDeniedAlertWithTitle:NSLocalizedString(@"Tips", nil) message:message];
        }
            break;
            
        case AVAuthorizationStatusAuthorized: // 用户允许当前应用使用相机
            [self createSGQRCodeScanning];
            break;
            
        default:
            break;
    }
}

- (void)createSGQRCodeScanning {
    // 1、获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    
    // 3、创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 4、设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 设置扫描范围(每一个取值0～1，以屏幕右上角为坐标原点)
    // 注：微信二维码的扫描范围是整个屏幕，这里并没有做处理（可不用设置）
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    
    // 5、初始化链接对象（会话对象）
    self.session = [[AVCaptureSession alloc] init];
    // 高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    // 5.1 添加会话输入
    [_session addInput:input];
    
    // 5.2 添加会话输出
    [_session addOutput:output];
    
    // 5.3 视频输出流
    if ([_session canAddOutput:self.captureVideoOutput]) {
        [_session addOutput:self.captureVideoOutput];
    }
    
    // 6、设置输出数据类型，需要将元数据输出添加到会话后，才能指定元数据类型，否则会报错
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    // 7、实例化预览图层, 传递_session是为了告诉图层将来显示什么内容
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _previewLayer.frame = self.view.layer.bounds;
    
    // 8、将图层插入当前视图
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    // 9、启动会话
    [_session startRunning];
}

- (void)readImageFromAlbum {
    // 1、 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device) {
        // 判断授权状态
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusNotDetermined) { // 用户还没有做出选择
            // 弹框请求用户授权
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) { // 用户第一次同意了访问相册权限
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
                        imagePicker.delegate = self;
                        [self presentViewController:imagePicker animated:YES completion:nil];
                    });
                } else { // 用户第一次拒绝了访问相机权限
                    
                }
            }];
            
        } else if (status == PHAuthorizationStatusAuthorized) { // 用户允许当前应用访问相册
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //（选择类型）表示仅仅从相册中选取照片
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];

        } else if (status == PHAuthorizationStatusDenied) { // 用户拒绝当前应用访问相册
            NSString *appName = @"Haptics"; // 当前应用的名称
            
            NSString *message = [NSString stringWithFormat:@"You have not authorize the application to access photos, please go to [Settings - %@ - Photo] to turn on the access switch.", appName];
            [self showDeniedAlertWithTitle:NSLocalizedString(@"Tips", nil) message:message];
        } else if (status == PHAuthorizationStatusRestricted) {
            [self showRestrictedAlertWithTitle:NSLocalizedString(@"Tips", nil) message:NSLocalizedString(@"Unable to access the album due to system reasons.", nil)];
        }
    }
}


#pragma mark - - - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.view addSubview:self.scanningView];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - - - 从相册中识别二维码, 并进行界面跳转

- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    image = [UIImage imageSizeWithScreenImage:image];

    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        //SGQRCodeLog(@"scannedResult - - %@", scannedResult);
        // 在此发通知，告诉子类二维码数据
        [SGQRCodeNotificationCenter postNotificationName:SGQRCodeInformationFromAlbum object:scannedResult];
    }
}


#pragma mark - - - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // 0、扫描成功之后的提示音和振动反馈
    [self SG_playSoundEffect:@"SGQRCode.bundle/sound.caf"];
    
    
    // MARK: -------- UIImpactFeedbackGenerator 的使用 --------
    if (self.needImpactFeedback) {
        [FeedbackGeneatorUtil generateImpactFeedbackWithStyle:UIImpactFeedbackStyleMedium];
    }
    
    
    // 1、如果扫描完成，停止会话
    [self.session stopRunning];
    
    // 2、删除预览图层
//    [self.previewLayer removeFromSuperlayer];
    
    // 3、设置界面显示扫描结果
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        NSString *metadataStr = obj.stringValue;
        
        // 在此发通知，告诉子类二维码数据
        [SGQRCodeNotificationCenter postNotificationName:SGQRCodeInformationFromScanning object:metadataStr];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
}


#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

// 从缓冲区读取照片
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    /**
     * iOS利用摄像头获取环境光感参数 (引入<ImageIO/ImageIO.h>)
     */
    // 1. 获取视频流的相关参数
    CFDictionaryRef metadataDic = CMCopyDictionaryOfAttachments(NULL, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary *)metadataDic];
    CFRelease(metadataDic);
    
    // 2. exif中有个brightness参数值,范围大概在[-5, 12]之间,参数数值越大,环境越亮
    NSDictionary *exifMetadata = [metadata[(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [exifMetadata[(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
//    NSLog(@"环境亮度: %f", brightnessValue);
    
    // 3. 根据brightnessValue来判断是否显示照明灯开关
    if (brightnessValue < 0) {
        self.scanningView.turnOnLight = YES;
    } else {
        self.scanningView.turnOnLight = NO;
    }
}


#pragma mark - Tools Methods

/** 播放音效文件 */
- (void)SG_playSoundEffect:(NSString *)name {
    // 获取音效
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
    
    // 1、获得系统声音ID
    SystemSoundID soundID = 0;
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    
    AudioServicesAddSystemSoundCompletion(soundID, NULL, NULL, soundCompleteCallback, NULL);
    
    // 2、播放音频
    AudioServicesPlaySystemSound(soundID); // 播放音效
}

/** 播放完成回调函数 */
void soundCompleteCallback(SystemSoundID soundID, void *clientData) {
//    SGQRCodeLog(@"播放完成...");
}


// 判断设备是否有摄像头
- (BOOL)isCameraAvailable {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL)isRearCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

@end

