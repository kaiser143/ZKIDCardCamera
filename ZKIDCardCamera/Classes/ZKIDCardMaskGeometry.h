//
//  ZKIDCardMaskGeometry.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

@class ZKIDCardCameraConfiguration;

NS_ASSUME_NONNULL_BEGIN

/// 证件取景框在指定 bounds 内的 frame（与 ZKIDCardFloatingView 一致）
FOUNDATION_EXPORT CGRect ZKIDCardMaskFrameInBounds(CGRect bounds, ZKIDCardCameraConfiguration *configuration);

NS_ASSUME_NONNULL_END
