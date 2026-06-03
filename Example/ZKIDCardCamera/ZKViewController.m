//
//  ZKViewController.m
//  ZKIDCardCamera
//

#import "ZKViewController.h"
#import <Masonry/Masonry.h>
#import <ZKIDCardCamera/ZKIDCardCameraController.h>

@interface ZKViewController () <ZKIDCardCameraControllerDelegate, ZKIDCardRecognitionProvider>

@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (ZKIDCardCameraController *)makeCameraWithType:(ZKIDCardType)type {
    ZKIDCardCameraConfiguration *config = [ZKIDCardCameraConfiguration defaultConfiguration];
    // config.preferredLanguage = @"en";

    ZKIDCardCameraController *controller = [[ZKIDCardCameraController alloc] initWithType:type configuration:config];
    controller.delegate = self;
    controller.recognitionProvider = self;
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    return controller;
}

#pragma mark - events Handler

- (IBAction)front {
    [self presentViewController:[self makeCameraWithType:ZKIDCardTypeFront] animated:YES completion:nil];
}

- (IBAction)reverse:(id)sender {
    [self presentViewController:[self makeCameraWithType:ZKIDCardTypeReverse] animated:YES completion:nil];
}

#pragma mark - ZKIDCardCameraControllerDelegate

- (void)idCardCamera:(ZKIDCardCameraController *)camera didCaptureImage:(UIImage *)image cardType:(ZKIDCardType)cardType {
    NSLog(@"拍摄完成 type=%lu image=%@", (unsigned long)cardType, image);
}

- (void)idCardCamera:(ZKIDCardCameraController *)camera
didFinishRecognition:(id)result
               error:(NSError *)error
               image:(UIImage *)image
            cardType:(ZKIDCardType)cardType {
    NSLog(@"识别结果 %@ error=%@", result, error);
}

#pragma mark - ZKIDCardRecognitionProvider

- (void)recognizeIDCardImage:(UIImage *)image
                    cardType:(ZKIDCardType)cardType
                  completion:(void (^)(id, NSError *))completion {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completion) {
            completion(@{ @"mock": @"第三方识别结果", @"side": @(cardType) }, nil);
        }
    });
}

@end
