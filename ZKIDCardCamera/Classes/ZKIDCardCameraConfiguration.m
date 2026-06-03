//
//  ZKIDCardCameraConfiguration.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import "ZKIDCardCameraConfiguration.h"

@implementation ZKIDCardCameraConfiguration

+ (instancetype)defaultConfiguration {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _overlayOpacity = 0.6f;
        _maskBorderWidth = 2.f;
        _maskCornerRadius = 15.f;
        _hidesStatusBar = YES;
        _showsFlashButton = YES;
        _maskWidth = 0;
        _deliversCroppedImage = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    ZKIDCardCameraConfiguration *copy = [[[self class] allocWithZone:zone] init];
    copy.resourceBundle = self.resourceBundle;
    copy.preferredLanguage = self.preferredLanguage;
    copy.hintTextFront = self.hintTextFront;
    copy.hintTextReverse = self.hintTextReverse;
    copy.retakeButtonTitle = self.retakeButtonTitle;
    copy.usePhotoButtonTitle = self.usePhotoButtonTitle;
    copy.cameraPermissionTitle = self.cameraPermissionTitle;
    copy.cameraPermissionMessage = self.cameraPermissionMessage;
    copy.cameraPermissionCancelTitle = self.cameraPermissionCancelTitle;
    copy.cameraPermissionConfirmTitle = self.cameraPermissionConfirmTitle;
    copy.noFlashTitle = self.noFlashTitle;
    copy.noFlashMessage = self.noFlashMessage;
    copy.alertConfirmTitle = self.alertConfirmTitle;
    copy.overlayColor = self.overlayColor;
    copy.overlayOpacity = self.overlayOpacity;
    copy.maskBorderColor = self.maskBorderColor;
    copy.maskBorderWidth = self.maskBorderWidth;
    copy.maskCornerRadius = self.maskCornerRadius;
    copy.hintTextColor = self.hintTextColor;
    copy.hintFont = self.hintFont;
    copy.bottomBarBackgroundColor = self.bottomBarBackgroundColor;
    copy.actionButtonTitleColor = self.actionButtonTitleColor;
    copy.actionButtonFont = self.actionButtonFont;
    copy.shutterButtonImage = self.shutterButtonImage;
    copy.shutterButtonHighlightedImage = self.shutterButtonHighlightedImage;
    copy.closeButtonImage = self.closeButtonImage;
    copy.flashButtonImage = self.flashButtonImage;
    copy.frontGuideImage = self.frontGuideImage;
    copy.reverseGuideImage = self.reverseGuideImage;
    copy.hidesStatusBar = self.hidesStatusBar;
    copy.showsFlashButton = self.showsFlashButton;
    copy.maskWidth = self.maskWidth;
    copy.deliversCroppedImage = self.deliversCroppedImage;
    return copy;
}

- (NSBundle *)resourceBundle {
    if (!_resourceBundle) {
        _resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[ZKIDCardCameraConfiguration class]] pathForResource:@"ZKIDCardCamera" ofType:@"bundle"]];
    }
    return _resourceBundle;
}

- (UIColor *)overlayColor {
    return _overlayColor ?: [UIColor blackColor];
}

- (UIColor *)maskBorderColor {
    return _maskBorderColor ?: [UIColor whiteColor];
}

- (UIColor *)hintTextColor {
    return _hintTextColor ?: [UIColor whiteColor];
}

- (UIFont *)hintFont {
    return _hintFont ?: [UIFont systemFontOfSize:14];
}

- (UIColor *)bottomBarBackgroundColor {
    return _bottomBarBackgroundColor ?: [UIColor colorWithRed:20/255.f green:20/255.f blue:20/255.f alpha:1];
}

- (UIColor *)actionButtonTitleColor {
    return _actionButtonTitleColor ?: [UIColor whiteColor];
}

- (UIFont *)actionButtonFont {
    return _actionButtonFont ?: [UIFont systemFontOfSize:18];
}

@end
