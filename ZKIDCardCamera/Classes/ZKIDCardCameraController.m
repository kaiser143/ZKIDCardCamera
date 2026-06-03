//
//  ZKIDCardCameraController.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2018/9/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "ZKIDCardCameraController.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <ZKCategories/ZKCategories.h>
#import "ZKIDCardFloatingView.h"
#import "ZKIDCardCameraLocalization.h"
#import "ZKIDCardCameraImageProcessor.h"
#import "ZKIDCardMaskGeometry.h"

@interface ZKIDCardCameraController () <AVCapturePhotoCaptureDelegate>

@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCapturePhotoOutput *photoOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *retakeButton;
@property (nonatomic, strong) UIButton *usePhotoButton;
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign, getter=isFlashOn) BOOL flashOn;
@property (nonatomic, assign) ZKIDCardType type;
@property (nonatomic, strong) UIView *focusIndicatorView;
@property (nonatomic, assign) BOOL isObservingFocus;
@property (nonatomic, assign) BOOL cameraExperienceConfigured;
@property (nonatomic, assign) BOOL pendingPermissionDeniedAlert;
@property (nonatomic, assign) BOOL shouldRunCaptureSession;
@property (nonatomic, strong) dispatch_queue_t sessionQueue;

@end

@implementation ZKIDCardCameraController

@synthesize configuration = _configuration;

- (void)dealloc {
    self.shouldRunCaptureSession = NO;
    [self stopCaptureSessionSynchronously];
    [self removeFocusObserverIfNeeded];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (dispatch_queue_t)sessionQueue {
    if (!_sessionQueue) {
        _sessionQueue = dispatch_queue_create("com.zkidcardcamera.capture.session", DISPATCH_QUEUE_SERIAL);
    }
    return _sessionQueue;
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (!self.cameraExperienceConfigured) {
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
            self.pendingPermissionDeniedAlert = NO;
            [self setupCameraExperienceIfNeeded];
        }
        return;
    }
    if (self.shouldRunCaptureSession) {
        [self startCaptureSessionIfNeeded];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [self stopCaptureSessionIfNeeded];
}

- (instancetype)initWithType:(ZKIDCardType)type {
    return [self initWithType:type configuration:nil];
}

- (instancetype)initWithType:(ZKIDCardType)type configuration:(ZKIDCardCameraConfiguration *)configuration {
    self = [super init];
    if (!self) {
        return nil;
    }
    _type = type;
    _configuration = [(configuration ?: [ZKIDCardCameraConfiguration defaultConfiguration]) copy];
    return self;
}

- (ZKIDCardCameraConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[ZKIDCardCameraConfiguration defaultConfiguration] copy];
    }
    return _configuration;
}

- (void)setConfiguration:(ZKIDCardCameraConfiguration *)configuration {
    _configuration = [(configuration ?: [ZKIDCardCameraConfiguration defaultConfiguration]) copy];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupCancelButtonLayout];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [self evaluateCameraAuthorization];
}

- (void)setupCancelButtonLayout {
    [self.cancleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(45);
        make.left.equalTo(self.view).offset(32);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
    }];
}

- (void)evaluateCameraAuthorization {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized:
            [self setupCameraExperienceIfNeeded];
            break;
        case AVAuthorizationStatusNotDetermined: {
            __weak typeof(self) weakSelf = self;
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    if (!strongSelf) {
                        return;
                    }
                    if (granted) {
                        [strongSelf setupCameraExperienceIfNeeded];
                    } else {
                        strongSelf.pendingPermissionDeniedAlert = YES;
                        [strongSelf presentCameraPermissionDeniedAlertIfNeeded];
                    }
                });
            }];
            break;
        }
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            self.pendingPermissionDeniedAlert = YES;
            [self presentCameraPermissionDeniedAlertIfNeeded];
            break;
    }
}

- (void)setupCameraExperienceIfNeeded {
    if (self.cameraExperienceConfigured) {
        return;
    }
    self.cameraExperienceConfigured = YES;
    [self camera];
    [self setupCaptureControls];
    [self startCaptureSessionIfNeeded];
}

- (void)setupCaptureControls {
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(60);
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-40);
    }];
    [self.cancleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(45);
        make.left.equalTo(self.view).offset(32);
        make.centerY.equalTo(self.photoButton);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.bottom.equalTo(self.view);
        CGFloat bottom = 0;
        if (@available(iOS 11, *)) {
            bottom = self.view.safeAreaInsets.bottom;
        }
        make.height.mas_equalTo(64 + bottom);
    }];

    ZKIDCardCameraConfiguration *config = self.configuration;
    self.retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.retakeButton setTitle:ZKIDCardCameraResolvedString(@"zk_idcard_retake", config.retakeButtonTitle, config)
                       forState:UIControlStateNormal];
    [self.retakeButton setTitleColor:config.actionButtonTitleColor forState:UIControlStateNormal];
    [self.retakeButton addTarget:self action:@selector(takePhotoAgain) forControlEvents:UIControlEventTouchUpInside];
    self.retakeButton.titleLabel.font = config.actionButtonFont;
    [self.bottomView addSubview:self.retakeButton];
    [self.retakeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bottomView).offset(15);
        make.left.equalTo(self.bottomView).offset(12);
    }];

    self.usePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.usePhotoButton setTitle:ZKIDCardCameraResolvedString(@"zk_idcard_use_photo", config.usePhotoButtonTitle, config)
                         forState:UIControlStateNormal];
    [self.usePhotoButton setTitleColor:config.actionButtonTitleColor forState:UIControlStateNormal];
    [self.usePhotoButton addTarget:self action:@selector(usePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.usePhotoButton.titleLabel.font = config.actionButtonFont;
    [self.bottomView addSubview:self.usePhotoButton];
    [self.usePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.retakeButton);
        make.right.equalTo(self.bottomView).offset(-12);
    }];

    [self.flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-32);
        make.centerY.equalTo(self.cancleButton);
        make.width.height.equalTo(self.cancleButton);
    }];
    self.flashButton.hidden = !config.showsFlashButton;

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(focusGesture:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(subjectAreaDidChange:)
                                                 name:AVCaptureDeviceSubjectAreaDidChangeNotification
                                               object:self.device];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (@available(iOS 13.0, *)) {
        self.modalPresentationCapturesStatusBarAppearance = YES;
    }
    [self setNeedsStatusBarAppearanceUpdate];
    self.shouldRunCaptureSession = YES;
    [self startCaptureSessionIfNeeded];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.shouldRunCaptureSession = NO;
    [self stopCaptureSessionIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self presentCameraPermissionDeniedAlertIfNeeded];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    if (!self.view.window) {
        [self stopCaptureSessionIfNeeded];
    }
}

#pragma mark - events Handler

- (void)takePhotoAgain {
    [self startCaptureSessionIfNeeded];
    [self.imageView removeFromSuperview];
    self.imageView = nil;

    self.cancleButton.hidden = NO;
    self.flashButton.hidden = !self.configuration.showsFlashButton;

    self.bottomView.hidden = YES;
    self.photoButton.hidden = NO;
}

- (void)cancleButtonAction {
    [self.imageView removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(idCardCameraDidCancel:)]) {
        [self.delegate idCardCameraDidCancel:self];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyCaptureFinishedWithImage:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(idCardCamera:didCaptureImage:cardType:)]) {
        [self.delegate idCardCamera:self didCaptureImage:image cardType:self.type];
    }
    if ([self.delegate respondsToSelector:@selector(cameraDidFinishShootWithCameraImage:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [self.delegate cameraDidFinishShootWithCameraImage:image];
#pragma clang diagnostic pop
    }
}

- (void)notifyRecognitionFinishedWithResult:(id)result error:(NSError *)error image:(UIImage *)image {
    if ([self.delegate respondsToSelector:@selector(idCardCamera:didFinishRecognition:error:image:cardType:)]) {
        [self.delegate idCardCamera:self
             didFinishRecognition:result
                            error:error
                            image:image
                         cardType:self.type];
    }
}

- (void)usePhoto {
    UIImage *image = self.image;
    if (!image) {
        return;
    }

    id<ZKIDCardRecognitionProvider> provider = self.recognitionProvider;
    BOOL autoRecognize = YES;
    if (provider && [provider respondsToSelector:@selector(shouldRecognizeAutomaticallyAfterCapture)]) {
        autoRecognize = [provider shouldRecognizeAutomaticallyAfterCapture];
    }

    if (provider && autoRecognize) {
        __weak typeof(self) weakSelf = self;
        [provider recognizeIDCardImage:image
                              cardType:self.type
                            completion:^(id result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (!strongSelf) {
                    return;
                }
                [strongSelf notifyRecognitionFinishedWithResult:result error:error image:image];
                [strongSelf notifyCaptureFinishedWithImage:image];
                [strongSelf dismissViewControllerAnimated:YES completion:nil];
            });
        }];
        return;
    }

    [self notifyCaptureFinishedWithImage:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shutterCamera:(UIButton *)sender {
    if (!self.photoOutput) {
        return;
    }
    sender.userInteractionEnabled = NO;

    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettings];
    if (self.isFlashOn) {
        if ([self.photoOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeOn)]) {
            settings.flashMode = AVCaptureFlashModeOn;
        }
    } else if ([self.photoOutput.supportedFlashModes containsObject:@(AVCaptureFlashModeAuto)]) {
        settings.flashMode = AVCaptureFlashModeAuto;
    }

    [self.photoOutput capturePhotoWithSettings:settings delegate:self];
}

#pragma mark - AVCapturePhotoCaptureDelegate

- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhoto:(AVCapturePhoto *)photo
                error:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.photoButton.userInteractionEnabled = YES;
        if (error || !photo) {
            return;
        }

        NSData *imageData = [photo fileDataRepresentation];
        UIImage *capturedImage = [UIImage imageWithData:imageData];
        if (!capturedImage) {
            return;
        }

        UIImage *displayImage = capturedImage;
        if (self.configuration.deliversCroppedImage) {
            CGRect maskFrame = ZKIDCardMaskFrameInBounds(self.view.bounds, self.configuration);
            displayImage = ZKIDCardCropImage(capturedImage, self.previewLayer, maskFrame) ?: capturedImage;
        }

        self.image = displayImage;
        AVCaptureSession *session = self.session;
        dispatch_async(self.sessionQueue, ^{
            if (session.isRunning) {
                [session stopRunning];
            }
        });

        self.imageView = [[UIImageView alloc] initWithFrame:self.previewLayer.frame];
        [self.view insertSubview:self.imageView belowSubview:self.photoButton];
        self.imageView.layer.masksToBounds = YES;
        self.imageView.image = self.image;

        self.cancleButton.hidden = YES;
        self.flashButton.hidden = YES;
        self.photoButton.hidden = YES;
        self.bottomView.hidden = NO;
    });
}

- (void)flashOn:(UIButton *)sender {
    ZKIDCardCameraConfiguration *config = self.configuration;
    if ([self.device hasTorch]) {
        [self.device lockForConfiguration:nil];
        if (!self.isFlashOn) {
            [self.device setTorchMode:AVCaptureTorchModeOn];
            self.flashOn = YES;
        } else {
            [self.device setTorchMode:AVCaptureTorchModeOff];
            self.flashOn = NO;
        }
        [self.device unlockForConfiguration];
    } else {
        NSString *title = ZKIDCardCameraResolvedString(@"zk_idcard_no_flash_title", config.noFlashTitle, config);
        NSString *message = ZKIDCardCameraResolvedString(@"zk_idcard_no_flash_message", config.noFlashMessage, config);
        NSString *confirm = ZKIDCardCameraResolvedString(@"zk_idcard_alert_confirm", config.alertConfirmTitle, config);
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)focusGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded || self.imageView || !self.session.isRunning) {
        return;
    }
    CGPoint point = [gesture locationInView:self.view];
    if ([self isPoint:point insideView:self.photoButton] ||
        [self isPoint:point insideView:self.cancleButton] ||
        [self isPoint:point insideView:self.flashButton]) {
        return;
    }
    [self focusAtViewPoint:point animated:YES];
}

#pragma mark - Session Lifecycle

- (BOOL)canRunCaptureSession {
    return self.cameraExperienceConfigured && self.shouldRunCaptureSession && !self.imageView && self.session != nil;
}

- (void)startCaptureSessionIfNeeded {
    if (![self canRunCaptureSession]) {
        return;
    }
    AVCaptureSession *session = self.session;
    if (session.isRunning) {
        return;
    }
    dispatch_async(self.sessionQueue, ^{
        if (![self canRunCaptureSession] || session.isRunning) {
            return;
        }
        [session startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (session.isRunning && !self.imageView) {
                [self configureDeviceForAutoFocus];
                [self focusAtPreviewCenterAnimated:NO];
            }
        });
    });
}

- (void)stopCaptureSessionIfNeeded {
    [self turnTorchOffIfNeeded];
    AVCaptureSession *session = self.session;
    if (!session || !session.isRunning) {
        return;
    }
    dispatch_async(self.sessionQueue, ^{
        if (session.isRunning) {
            [session stopRunning];
        }
    });
}

- (void)stopCaptureSessionSynchronously {
    [self turnTorchOffIfNeeded];
    AVCaptureSession *session = self.session;
    if (!session || !session.isRunning) {
        return;
    }
    dispatch_sync(self.sessionQueue, ^{
        if (session.isRunning) {
            [session stopRunning];
        }
    });
}

- (void)turnTorchOffIfNeeded {
    if (!self.device || !self.isFlashOn) {
        return;
    }
    AVCaptureDevice *device = self.device;
    if ([device lockForConfiguration:nil]) {
        if ([device hasTorch] && device.torchMode != AVCaptureTorchModeOff) {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
    self.flashOn = NO;
}

- (void)registerSessionNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(sessionWasInterrupted:)
                   name:AVCaptureSessionWasInterruptedNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(sessionInterruptionEnded:)
                   name:AVCaptureSessionInterruptionEndedNotification
                 object:self.session];
    [center addObserver:self
               selector:@selector(sessionRuntimeError:)
                   name:AVCaptureSessionRuntimeErrorNotification
                 object:self.session];
}

- (void)sessionWasInterrupted:(NSNotification *)notification {
    [self turnTorchOffIfNeeded];
}

- (void)sessionInterruptionEnded:(NSNotification *)notification {
    [self startCaptureSessionIfNeeded];
}

- (void)sessionRuntimeError:(NSNotification *)notification {
    NSError *error = notification.userInfo[AVCaptureSessionErrorKey];
    if (error.code == AVErrorMediaServicesWereReset) {
        dispatch_async(self.sessionQueue, ^{
            if ([self canRunCaptureSession]) {
                [self.session startRunning];
            }
        });
    } else {
        [self startCaptureSessionIfNeeded];
    }
}

#pragma mark - Private Methods

- (void)presentCameraPermissionDeniedAlertIfNeeded {
    if (!self.pendingPermissionDeniedAlert) {
        return;
    }
    if (!self.isViewLoaded || self.view.window == nil || self.presentedViewController != nil) {
        return;
    }
    self.pendingPermissionDeniedAlert = NO;

    ZKIDCardCameraConfiguration *config = self.configuration;
    NSString *title = ZKIDCardCameraResolvedString(@"zk_idcard_camera_permission_title", config.cameraPermissionTitle, config);
    NSString *message = ZKIDCardCameraResolvedString(@"zk_idcard_camera_permission_message", config.cameraPermissionMessage, config);
    NSString *cancel = ZKIDCardCameraResolvedString(@"zk_idcard_camera_permission_cancel", config.cameraPermissionCancelTitle, config);
    NSString *confirm = ZKIDCardCameraResolvedString(@"zk_idcard_camera_permission_confirm", config.cameraPermissionConfirmTitle, config);

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:confirm style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)isPoint:(CGPoint)point insideView:(UIView *)view {
    if (view.hidden || view.alpha < 0.01) {
        return NO;
    }
    return CGRectContainsPoint(view.frame, point);
}

- (void)addFocusObserverIfNeeded {
    if (self.isObservingFocus || !self.device) {
        return;
    }
    [self.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:NULL];
    self.isObservingFocus = YES;
}

- (void)removeFocusObserverIfNeeded {
    if (!self.isObservingFocus || !self.device) {
        return;
    }
    @try {
        [self.device removeObserver:self forKeyPath:@"adjustingFocus"];
    } @catch (__unused NSException *exception) {
    }
    self.isObservingFocus = NO;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
    if (object == self.device && [keyPath isEqualToString:@"adjustingFocus"] && !self.device.isAdjustingFocus) {
        [self enableContinuousAutoFocusIfSupported];
    }
}

- (CGPoint)devicePointForViewPoint:(CGPoint)viewPoint {
    if (!self.previewLayer) {
        return CGPointMake(0.5, 0.5);
    }
    return [self.previewLayer captureDevicePointOfInterestForPoint:viewPoint];
}

- (void)configureDeviceForAutoFocus {
    if (!self.device) {
        return;
    }
    NSError *error = nil;
    if (![self.device lockForConfiguration:&error]) {
        return;
    }
    if (self.device.isSmoothAutoFocusSupported) {
        self.device.smoothAutoFocusEnabled = YES;
    }
    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        if (self.device.isFocusPointOfInterestSupported) {
            [self.device setFocusPointOfInterest:CGPointMake(0.5, 0.5)];
        }
        [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    } else if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        if (self.device.isExposurePointOfInterestSupported) {
            [self.device setExposurePointOfInterest:CGPointMake(0.5, 0.5)];
        }
        [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    } else if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
        [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    }
    if (self.device.isSubjectAreaChangeMonitoringEnabled == NO) {
        self.device.subjectAreaChangeMonitoringEnabled = YES;
    }
    [self.device unlockForConfiguration];
    [self addFocusObserverIfNeeded];
}

- (void)enableContinuousAutoFocusIfSupported {
    if (!self.device || self.imageView) {
        return;
    }
    NSError *error = nil;
    if (![self.device lockForConfiguration:&error]) {
        return;
    }
    if ([self.device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
        [self.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    if ([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [self.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [self.device unlockForConfiguration];
}

- (void)focusAtPreviewCenterAnimated:(BOOL)animated {
    CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    [self focusAtViewPoint:center animated:animated];
}

- (void)focusAtViewPoint:(CGPoint)viewPoint animated:(BOOL)animated {
    if (!self.device || !self.previewLayer) {
        return;
    }
    CGPoint devicePoint = [self devicePointForViewPoint:viewPoint];
    NSError *error = nil;
    if (![self.device lockForConfiguration:&error]) {
        return;
    }
    if (self.device.isFocusPointOfInterestSupported && [self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        [self.device setFocusPointOfInterest:devicePoint];
        [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if (self.device.isExposurePointOfInterestSupported && [self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        [self.device setExposurePointOfInterest:devicePoint];
        [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
    }
    if (self.device.isSubjectAreaChangeMonitoringEnabled == NO) {
        self.device.subjectAreaChangeMonitoringEnabled = YES;
    }
    [self.device unlockForConfiguration];
    if (animated) {
        [self showFocusIndicatorAtPoint:viewPoint];
    }
}

- (void)showFocusIndicatorAtPoint:(CGPoint)point {
    static CGFloat const kFocusIndicatorSide = 80.f;
    if (!self.focusIndicatorView) {
        self.focusIndicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFocusIndicatorSide, kFocusIndicatorSide)];
        self.focusIndicatorView.backgroundColor = [UIColor clearColor];
        self.focusIndicatorView.layer.borderColor = [UIColor colorWithRed:1.f green:0.84 blue:0.f alpha:1.f].CGColor;
        self.focusIndicatorView.layer.borderWidth = 1.5f;
        self.focusIndicatorView.userInteractionEnabled = NO;
        [self.view addSubview:self.focusIndicatorView];
    }
    self.focusIndicatorView.center = point;
    self.focusIndicatorView.hidden = NO;
    self.focusIndicatorView.transform = CGAffineTransformMakeScale(1.4, 1.4);
    self.focusIndicatorView.alpha = 1.f;
    [self.view bringSubviewToFront:self.focusIndicatorView];
    [UIView animateWithDuration:0.25
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.focusIndicatorView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2
                              delay:0.6
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
            self.focusIndicatorView.alpha = 0.f;
        } completion:nil];
    }];
}

- (void)camera {
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:nil];
    self.photoOutput = [[AVCapturePhotoOutput alloc] init];
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        self.session.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    if ([self.session canAddOutput:self.photoOutput]) {
        [self.session addOutput:self.photoOutput];
    }

    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];

    [self registerSessionNotifications];
    [self configureDeviceForAutoFocus];

    ZKIDCardFloatingView *IDCardFloatingView = [[ZKIDCardFloatingView alloc] initWithType:self.type
                                                                            configuration:self.configuration];
    [self.view addSubview:IDCardFloatingView];
    [IDCardFloatingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
    if (self.imageView || !self.session.isRunning) {
        return;
    }
    [self focusAtPreviewCenterAnimated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.configuration.hidesStatusBar;
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
        NSBundle *bundle = self.configuration.resourceBundle;
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *normal = self.configuration.shutterButtonImage;
        if (!normal) {
            normal = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"photo@2x" ofType:@"png"]];
        }
        UIImage *highlighted = self.configuration.shutterButtonHighlightedImage;
        if (!highlighted) {
            highlighted = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"photoSelect@2x" ofType:@"png"]];
        }
        [_photoButton setImage:normal forState:UIControlStateNormal];
        [_photoButton setImage:highlighted forState:UIControlStateHighlighted];
        [_photoButton addTarget:self action:@selector(shutterCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_photoButton];
    }
    return _photoButton;
}

- (UIButton *)cancleButton {
    if (!_cancleButton) {
        NSBundle *bundle = self.configuration.resourceBundle;
        UIImage *image = self.configuration.closeButtonImage;
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"closeButton" ofType:@"png"]];
        }
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancleButton setImage:image forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancleButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancleButton];
    }
    return _cancleButton;
}

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = self.configuration.bottomBarBackgroundColor;
        _bottomView.hidden = YES;
        [self.view addSubview:_bottomView];
    }
    return _bottomView;
}

- (UIButton *)flashButton {
    if (!_flashButton) {
        NSBundle *bundle = self.configuration.resourceBundle;
        UIImage *image = self.configuration.flashButtonImage;
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"cameraFlash" ofType:@"png"]];
        }
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.tintColor = [UIColor whiteColor];
        [_flashButton setImage:image forState:UIControlStateNormal];
        [_flashButton addTarget:self action:@selector(flashOn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_flashButton];
    }
    return _flashButton;
}

@end
