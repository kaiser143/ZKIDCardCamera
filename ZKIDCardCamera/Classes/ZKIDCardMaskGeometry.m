//
//  ZKIDCardMaskGeometry.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import "ZKIDCardMaskGeometry.h"
#import "ZKIDCardCameraConfiguration.h"

static CGFloat ZKIDCardDefaultMaskWidthForBounds(CGRect bounds) {
    CGFloat height = CGRectGetHeight(bounds);
    if (height == 568.0) {
        return 240.f;
    }
    if (height == 667.0) {
        return 240.f;
    }
    return 270.f;
}

CGRect ZKIDCardMaskFrameInBounds(CGRect bounds, ZKIDCardCameraConfiguration *configuration) {
    configuration = configuration ?: [ZKIDCardCameraConfiguration defaultConfiguration];
    CGFloat width = configuration.maskWidth > 0 ? configuration.maskWidth : ZKIDCardDefaultMaskWidthForBounds(bounds);
    CGFloat cardHeight = width * 1.574f;
    CGFloat x = (CGRectGetWidth(bounds) - width) / 2.f;
    CGFloat y = (CGRectGetHeight(bounds) - cardHeight) / 2.f;
    return CGRectMake(x, y, width, cardHeight);
}
