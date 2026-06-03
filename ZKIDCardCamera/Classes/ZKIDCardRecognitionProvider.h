//
//  ZKIDCardRecognitionProvider.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKIDCardCameraTypes.h"

NS_ASSUME_NONNULL_BEGIN

/// 第三方证件识别能力接入协议（OCR / 活体等由宿主或外部 SDK 实现）
@protocol ZKIDCardRecognitionProvider <NSObject>

@required

/// 对拍摄得到的证件图进行识别
/// @param image 原图或裁剪图，由实现方自行处理
/// @param cardType 当前拍摄面（正面 / 背面）
/// @param completion 建议在主线程回调；result 可为 NSDictionary 或自定义模型
- (void)recognizeIDCardImage:(UIImage *)image
                    cardType:(ZKIDCardType)cardType
                  completion:(void (^)(id _Nullable result, NSError * _Nullable error))completion;

@optional

/// 点击「使用照片」后是否自动识别，默认 YES
- (BOOL)shouldRecognizeAutomaticallyAfterCapture;

@end

NS_ASSUME_NONNULL_END
