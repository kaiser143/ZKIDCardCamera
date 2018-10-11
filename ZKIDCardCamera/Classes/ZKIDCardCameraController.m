//
//  ZKIDCardCameraController.m
//  FBSnapshotTestCase
//
//  Created by zhangkai on 2018/9/21.
//

#import "ZKIDCardCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import "ZKIDCardFloatingView.h"

@interface ZKIDCardCameraController () <AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;

/*!
 *    @brief    AVCaptureDeviceInput: 输入设备, 使用AVCaptureDevice初始化
 */
@property (nonatomic, strong) AVCaptureDeviceInput *input;

/*!
 *    @brief    捕捉摄像头输出
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;

/*!
 *    @brief    启动捕获摄像头
 */
@property (nonatomic, strong) AVCaptureSession *session;

/*!
 *    @brief    实时捕获图像层，图片预览
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *flashButton;

/*!
 *    @brief    拍摄成功后回显到屏幕
 */
@property (nonatomic, strong) UIImageView *imageView;

/*!
 *    @brief    拍的图片数据
 */
@property (nonatomic, strong) UIImage *image;

/*!
 *    @brief    是否有相机权限
 */
@property (nonatomic, assign) BOOL canUseCamera;

/*!
 *    @brief    取消拍摄
 */
@property (nonatomic, strong) UIButton *cancleButton;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign, getter=isFlashOn) BOOL flashOn;
@property (nonatomic, strong) NSBundle *resouceBundle;

@property (nonatomic, assign) ZKIDCardType type;

@end

@implementation ZKIDCardCameraController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithType:(ZKIDCardType)type {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.type = type;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self isCanUseCamera]) {
        [self camera];
        
        [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(60);
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
        }];
        [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(45);
            make.left.equalTo(self.view).offset(32);
            make.centerY.equalTo(self.photoButton);
        }];
        [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.width.bottom.equalTo(self.view);
            make.height.mas_equalTo(64);
        }];
        
        UIButton *again = [UIButton buttonWithType:UIButtonTypeCustom];
        [again setTitle:@"重拍" forState:UIControlStateNormal];
        [again setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [again addTarget:self action:@selector(takePhotoAgain) forControlEvents:UIControlEventTouchUpInside];
        again.titleLabel.font = [UIFont systemFontOfSize:18];
        again.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:again];
        [again mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView);
            make.left.equalTo(self.bottomView).offset(12);
        }];
        
        UIButton *use = [UIButton buttonWithType:UIButtonTypeCustom];
        [use setTitle:@"使用照片" forState:UIControlStateNormal];
        [use setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [use addTarget:self action:@selector(usePhoto) forControlEvents:UIControlEventTouchUpInside];
        use.titleLabel.font = [UIFont systemFontOfSize:18];
        use.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.bottomView addSubview:use];
        [use mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.bottomView);
            make.right.equalTo(self.bottomView).offset(-12);
        }];
        
        [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-32);
            make.centerY.equalTo(self.cancleButton);
            make.width.height.equalTo(self.cancleButton);
        }];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(focusGesture:)];
        [self.view addGestureRecognizer:tapGesture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(subjectAreaDidChange:)
                                                     name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                                   object:self.device];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    CGPoint point = CGPointMake(CGRectGetWidth(bounds)/2.f, CGRectGetHeight(bounds)/2.f);
    [self focusAtPoint:point];
}

#pragma mark - events Handler

- (void)takePhotoAgain {
    [self.session startRunning];
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    self.cancleButton.hidden = NO;
    self.flashButton.hidden = NO;
    
    self.bottomView.hidden = YES;
    self.photoButton.hidden = NO;
    
}

- (void)cancleButtonAction {
    [self.imageView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)usePhoto {
    if ([self.delegate respondsToSelector:@selector(cameraDidFinishShootWithCameraImage:)]) {
        [self.delegate cameraDidFinishShootWithCameraImage:self.image];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shutterCamera:(UIButton *)sender {
    AVCaptureConnection * videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"拍照失败!");
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error){
        if (imageDataSampleBuffer == NULL) return;
        
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        strongSelf.image = [UIImage imageWithData:imageData];
        [strongSelf.session stopRunning]; // 停止会话
        
        strongSelf.imageView = [[UIImageView alloc] initWithFrame:strongSelf.previewLayer.frame];
        [strongSelf.view insertSubview:self.imageView belowSubview:sender];
        strongSelf.imageView.layer.masksToBounds = YES;
        strongSelf.imageView.image = self.image;
        
        // 隐藏切换取消闪光灯按钮
        strongSelf.cancleButton.hidden = YES;
        strongSelf.flashButton.hidden = YES;
        strongSelf.photoButton.hidden = YES;
        
        strongSelf.bottomView.hidden = NO;
        strongSelf.photoButton.hidden = YES;
    }];
}

- (void)flashOn:(UIButton *)sender {
    if ([self.device hasTorch]){ // 判断是否有闪光灯
        [self.device lockForConfiguration:nil];// 请求独占访问硬件设备
        
        if (!self.isFlashOn) {
            [self.device setTorchMode:AVCaptureTorchModeOn];
            self.flashOn = YES;
        } else {
            [self.device setTorchMode:AVCaptureTorchModeOff];
            self.flashOn = NO;
        }
        [self.device unlockForConfiguration];// 请求解除独占访问硬件设备
    }else {
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示"
                                                                                 message:@"您的设备没有闪光设备，不能提供手电筒功能，请检查"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)focusGesture:(UITapGestureRecognizer*)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}

#pragma mark - Private Methods

- (BOOL)isCanUseCamera {
    if (!_canUseCamera) {
        _canUseCamera = [self validateCanUseCamera];
    }
    return _canUseCamera;
}

- (BOOL)validateCanUseCamera {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请打开相机权限" message:@"请到设置中去允许应用访问您的相机: 设置-隐私-相机" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不需要" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 跳转至设置开启权限
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if([[UIApplication sharedApplication] canOpenURL:url])
            {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootViewController presentViewController:alertController animated:NO completion:nil];
        return NO;
    } else {
        return YES;
    }
}

- (void)focusAtPoint:(CGPoint)point {
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
    }
}

- (void)camera {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; // 使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
    
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil]; // 使用设备初始化输入
    
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    self.session = [[AVCaptureSession alloc] init]; // 生成会话，用来结合输入输出
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [[self session] addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    
    // 使用self.session，初始化预览层，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = (CGRect){CGPointZero, [UIScreen mainScreen].bounds.size};
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.session startRunning]; // 开始启动
    if ([_device lockForConfiguration:nil]) {
        if ([_device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [_device setFlashMode:AVCaptureFlashModeAuto];
        }
        if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {// 自动白平衡
            [_device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        }
        [_device unlockForConfiguration];
    }
    
    ZKIDCardFloatingView *IDCardFloatingView = [[ZKIDCardFloatingView alloc] initWithType:self.type];
    [self.view addSubview:IDCardFloatingView];
    [IDCardFloatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    //先进行判断是否支持控制对焦
    if (self.device.isFocusPointOfInterestSupported
        &&[self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error =nil;
        //对cameraDevice进行操作前，需要先锁定，防止其他线程访问，
        [self.device lockForConfiguration:&error];
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        
        CGRect bounds = [UIScreen mainScreen].bounds;
        CGPoint point = CGPointMake(CGRectGetWidth(bounds)/2.f, CGRectGetHeight(bounds)/2.f);
        [self focusAtPoint:point];
        //操作完成后，记得进行unlock。
        [self.device unlockForConfiguration];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - getters and setters

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_photoButton setImage:[UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"photo@2x" ofType:@"png"]]
                      forState: UIControlStateNormal];
        [_photoButton setImage:[UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"photoSelect@2x" ofType:@"png"]]
                      forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(shutterCamera:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_photoButton];
    }
    return _photoButton;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        UIImage *image = [UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"closeButton" ofType:@"png"]];
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setImage:image
                       forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancleButtonAction)
                forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_cancleButton];
    }
    return _cancleButton;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor colorWithRed:20/255.f green:20/255.f blue:20/255.f alpha:1];
        _bottomView.hidden = YES;
        
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        UIImage * image = [UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"cameraFlash" ofType:@"png"]];
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.tintColor = [UIColor whiteColor];
        [_flashButton setImage:image
                      forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashOn:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:_flashButton];
    }
    return _flashButton;
}

- (NSBundle *)resouceBundle {
    if (!_resouceBundle) {
        _resouceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:self.class] pathForResource:@"ZKIDCardCamera" ofType:@"bundle"]];
    }
    return _resouceBundle;
}

@end
