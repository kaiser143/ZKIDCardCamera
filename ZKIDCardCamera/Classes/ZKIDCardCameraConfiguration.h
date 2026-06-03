//
//  ZKIDCardCameraConfiguration.h
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 证件拍摄页 UI / 文案 / 行为配置。
 
 传入 `ZKIDCardCameraController` 的 `initWithType:configuration:` 使用。
 颜色、字体、图片等未赋值项会使用内置默认值；文案为 nil 时走多语言（见 `preferredLanguage`）。
 
 @code
 ZKIDCardCameraConfiguration *config = [ZKIDCardCameraConfiguration defaultConfiguration];
 config.preferredLanguage = @"en";
 config.hintTextFront = @"请将人像面对齐框内";
 ZKIDCardCameraController *camera = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeFront configuration:config];
 @endcode
 */
@interface ZKIDCardCameraConfiguration : NSObject <NSCopying>

/// 返回一份带默认行为值的配置实例，可在此基础上按需修改
+ (instancetype)defaultConfiguration;

#pragma mark - Localization

/// 文案与图片资源 Bundle；默认使用组件内置 `ZKIDCardCamera.bundle`
@property (nonatomic, strong) NSBundle *resourceBundle;

/// 覆盖系统语言，如 `@"en"`、`@"zh-Hans"`；nil 时跟随系统（中文环境优先 zh-Hans，否则 en）
@property (nonatomic, copy, nullable) NSString *preferredLanguage;

#pragma mark - Copy

/// 以下文案属性为 nil 时使用 `Localizable.strings` 中的对应 key；非 nil 则完全覆盖多语言

/// 正面拍摄提示文案
@property (nonatomic, copy, nullable) NSString *hintTextFront;
/// 背面拍摄提示文案
@property (nonatomic, copy, nullable) NSString *hintTextReverse;
/// 预览页「重拍」按钮标题
@property (nonatomic, copy, nullable) NSString *retakeButtonTitle;
/// 预览页「使用照片」按钮标题
@property (nonatomic, copy, nullable) NSString *usePhotoButtonTitle;
/// 无相机权限弹窗标题
@property (nonatomic, copy, nullable) NSString *cameraPermissionTitle;
/// 无相机权限弹窗说明
@property (nonatomic, copy, nullable) NSString *cameraPermissionMessage;
/// 无相机权限弹窗取消按钮
@property (nonatomic, copy, nullable) NSString *cameraPermissionCancelTitle;
/// 无相机权限弹窗确认按钮（跳转设置）
@property (nonatomic, copy, nullable) NSString *cameraPermissionConfirmTitle;
/// 设备无闪光灯时的弹窗标题
@property (nonatomic, copy, nullable) NSString *noFlashTitle;
/// 设备无闪光灯时的弹窗说明
@property (nonatomic, copy, nullable) NSString *noFlashMessage;
/// 通用 Alert 确认按钮标题
@property (nonatomic, copy, nullable) NSString *alertConfirmTitle;

#pragma mark - Appearance

/// 取景框外蒙层颜色，默认黑色
@property (nonatomic, strong) UIColor *overlayColor;
/// 蒙层不透明度，默认 0.6，范围建议 0~1
@property (nonatomic, assign) CGFloat overlayOpacity;
/// 证件框边框颜色，默认白色
@property (nonatomic, strong) UIColor *maskBorderColor;
/// 证件框边框宽度（点），默认 2
@property (nonatomic, assign) CGFloat maskBorderWidth;
/// 证件框圆角（点），默认 15
@property (nonatomic, assign) CGFloat maskCornerRadius;
/// 侧边提示文字颜色，默认白色
@property (nonatomic, strong) UIColor *hintTextColor;
/// 侧边提示文字字体，默认 14pt 系统字体
@property (nonatomic, strong) UIFont *hintFont;
/// 预览底部操作栏背景色，默认 #141414
@property (nonatomic, strong) UIColor *bottomBarBackgroundColor;
/// 「重拍」「使用照片」按钮标题颜色，默认白色
@property (nonatomic, strong) UIColor *actionButtonTitleColor;
/// 「重拍」「使用照片」按钮字体，默认 18pt 系统字体
@property (nonatomic, strong) UIFont *actionButtonFont;

#pragma mark - Images

/// 以下图片为 nil 时使用 bundle 内默认资源

/// 快门按钮常态图
@property (nonatomic, strong, nullable) UIImage *shutterButtonImage;
/// 快门按钮高亮图
@property (nonatomic, strong, nullable) UIImage *shutterButtonHighlightedImage;
/// 关闭按钮图
@property (nonatomic, strong, nullable) UIImage *closeButtonImage;
/// 闪光灯按钮图
@property (nonatomic, strong, nullable) UIImage *flashButtonImage;
/// 正面拍摄引导图（头像虚线框）
@property (nonatomic, strong, nullable) UIImage *frontGuideImage;
/// 背面拍摄引导图（国徽区域）
@property (nonatomic, strong, nullable) UIImage *reverseGuideImage;

#pragma mark - Behavior

/// 拍照界面是否隐藏状态栏，默认 YES；需配合 `UIModalPresentationFullScreen` 展示
@property (nonatomic, assign) BOOL hidesStatusBar;
/// 是否显示闪光灯按钮，默认 YES
@property (nonatomic, assign) BOOL showsFlashButton;
/// 证件框宽度（点）；0 表示按屏幕尺寸自动适配，默认 0
@property (nonatomic, assign) CGFloat maskWidth;
/// 回传/预览是否使用证件框裁剪图，默认 YES；NO 时使用相机原图
@property (nonatomic, assign) BOOL deliversCroppedImage;

@end

NS_ASSUME_NONNULL_END
