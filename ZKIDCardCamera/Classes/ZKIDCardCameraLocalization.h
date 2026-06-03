//
//  ZKIDCardCameraLocalization.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZKIDCardCameraConfiguration;

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *ZKIDCardCameraLocalizedString(NSString *key, ZKIDCardCameraConfiguration *configuration);

/// customOverride 非空时优先使用，否则走多语言
FOUNDATION_EXPORT NSString *ZKIDCardCameraResolvedString(NSString *key, NSString * _Nullable customOverride, ZKIDCardCameraConfiguration *configuration);

NS_ASSUME_NONNULL_END
