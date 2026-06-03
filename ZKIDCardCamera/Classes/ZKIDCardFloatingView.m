//
//  ZKIDCardFloatingView.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2018/9/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "ZKIDCardFloatingView.h"
#import <Masonry/Masonry.h>
#import "ZKIDCardCameraLocalization.h"
#import "ZKIDCardMaskGeometry.h"

@interface ZKIDCardFloatingView ()

@property (nonatomic, strong) CAShapeLayer *IDCardWindowLayer;
@property (nonatomic, assign) ZKIDCardType type;
@property (nonatomic, copy) ZKIDCardCameraConfiguration *configuration;

@end

@implementation ZKIDCardFloatingView

- (instancetype)initWithType:(ZKIDCardType)type configuration:(ZKIDCardCameraConfiguration *)configuration {
    self = [super initWithFrame:[UIScreen.mainScreen bounds]];
    if (!self) {
        return nil;
    }

    self.type = type;
    self.configuration = configuration ?: [ZKIDCardCameraConfiguration defaultConfiguration];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;

    CGRect maskFrame = ZKIDCardMaskFrameInBounds(self.bounds, self.configuration);
    self.IDCardWindowLayer.frame = maskFrame;
    self.IDCardWindowLayer.cornerRadius = self.configuration.maskCornerRadius;
    self.IDCardWindowLayer.borderColor = self.configuration.maskBorderColor.CGColor;
    self.IDCardWindowLayer.borderWidth = self.configuration.maskBorderWidth;

    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:maskFrame
                                                                          cornerRadius:self.IDCardWindowLayer.cornerRadius];

    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path appendPath:transparentRoundedRectPath];
    [path setUsesEvenOddFillRule:YES];

    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = self.configuration.overlayColor.CGColor;
    fillLayer.opacity = (float)self.configuration.overlayOpacity;
    [self.layer addSublayer:fillLayer];

    NSString *hintKey = (self.type == ZKIDCardTypeFront) ? @"zk_idcard_hint_front" : @"zk_idcard_hint_reverse";
    NSString *hintCustom = (self.type == ZKIDCardTypeFront) ? self.configuration.hintTextFront : self.configuration.hintTextReverse;

    UILabel *textLabel = UILabel.new;
    textLabel.text = ZKIDCardCameraResolvedString(hintKey, hintCustom, self.configuration);
    textLabel.textColor = self.configuration.hintTextColor;
    textLabel.font = self.configuration.hintFont;
    textLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    [self addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-CGRectGetWidth(maskFrame) / 2.f - 20);
        make.centerY.equalTo(self);
    }];

    CGFloat facePathWidth, facePathHeight;
    UIImage *image;
    NSBundle *bundle = self.configuration.resourceBundle;
    CGFloat boundsHeight = CGRectGetHeight(self.bounds);
    if (self.type == ZKIDCardTypeFront) {
        facePathWidth = boundsHeight <= 568.f ? 95.f : (boundsHeight <= 667.f ? 120.f : 150.f);
        facePathHeight = facePathWidth * 0.812;
        image = self.configuration.frontGuideImage;
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"xuxian@2x" ofType:@"png"]];
        }
    } else {
        facePathWidth = boundsHeight <= 568.f ? 40.f : (boundsHeight <= 667.f ? 80.f : 100.f);
        facePathHeight = facePathWidth;
        image = self.configuration.reverseGuideImage;
        if (!image) {
            image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"Page 1@2x" ofType:@"png"]];
        }
    }

    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.type == ZKIDCardTypeFront) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(CGRectGetHeight(maskFrame) / 2.f - facePathWidth / 2.f - 30);
        } else {
            make.centerX.equalTo(self).offset(CGRectGetWidth(maskFrame) / 2.f - facePathHeight / 2.f - 25);
            make.centerY.equalTo(self).offset(-CGRectGetHeight(maskFrame) / 2.f + facePathWidth / 2.f + 20);
        }
        make.width.mas_equalTo(facePathWidth);
        make.height.mas_equalTo(facePathHeight);
    }];

    return self;
}

#pragma mark - getters and setters

- (CAShapeLayer *)IDCardWindowLayer {
    if (!_IDCardWindowLayer) {
        _IDCardWindowLayer = [[CAShapeLayer alloc] init];
        [self.layer addSublayer:_IDCardWindowLayer];
    }
    return _IDCardWindowLayer;
}

@end
