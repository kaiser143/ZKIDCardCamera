//
//  ZKIDCardFloatingView.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2018/9/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZKIDCardCameraTypes.h"
#import "ZKIDCardCameraConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKIDCardFloatingView : UIView

- (instancetype)initWithType:(ZKIDCardType)type configuration:(ZKIDCardCameraConfiguration *)configuration;

@end

NS_ASSUME_NONNULL_END
