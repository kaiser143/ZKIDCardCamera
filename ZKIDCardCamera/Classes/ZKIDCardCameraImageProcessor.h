//
//  ZKIDCardCameraImageProcessor.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureVideoPreviewLayer;

NS_ASSUME_NONNULL_BEGIN

/// 将图片方向校正为 UIImageOrientationUp
FOUNDATION_EXPORT UIImage *ZKIDCardNormalizedImage(UIImage *image);

/// 按预览层与取景框区域裁剪照片（aspectFill 映射）
FOUNDATION_EXPORT UIImage *ZKIDCardCropImage(UIImage *image,
                                             AVCaptureVideoPreviewLayer *previewLayer,
                                             CGRect maskFrameInViewCoordinates);

NS_ASSUME_NONNULL_END
