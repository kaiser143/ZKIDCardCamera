//
//  ZKIDCardCameraController.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2018/9/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKIDCardCameraTypes.h"
#import "ZKIDCardCameraConfiguration.h"
#import "ZKIDCardRecognitionProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class ZKIDCardCameraController;

@protocol ZKIDCardCameraControllerDelegate <NSObject>

@optional

/// 拍摄完成（未配置识别 provider，或 provider 关闭自动识别时）
- (void)idCardCamera:(ZKIDCardCameraController *)camera
     didCaptureImage:(UIImage *)image
             cardType:(ZKIDCardType)cardType;

/// 第三方识别完成（需设置 recognitionProvider）
- (void)idCardCamera:(ZKIDCardCameraController *)camera
didFinishRecognition:(id _Nullable)result
               error:(NSError * _Nullable)error
               image:(UIImage *)image
            cardType:(ZKIDCardType)cardType;

/// 用户取消拍摄
- (void)idCardCameraDidCancel:(ZKIDCardCameraController *)camera;

#pragma mark - Deprecated

- (void)cameraDidFinishShootWithCameraImage:(UIImage *)image DEPRECATED_MSG_ATTRIBUTE("Use idCardCamera:didCaptureImage:cardType:");

@end

@interface ZKIDCardCameraController : UIViewController

@property (nonatomic, weak, nullable) id<ZKIDCardCameraControllerDelegate> delegate;

/// UI / 文案 / 行为自定义，默认 [ZKIDCardCameraConfiguration defaultConfiguration]
@property (nonatomic, copy) ZKIDCardCameraConfiguration *configuration;

/// 第三方证件识别实现（OCR 等），可选
@property (nonatomic, weak, nullable) id<ZKIDCardRecognitionProvider> recognitionProvider;

- (instancetype)initWithType:(ZKIDCardType)type;
- (instancetype)initWithType:(ZKIDCardType)type configuration:(nullable ZKIDCardCameraConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
