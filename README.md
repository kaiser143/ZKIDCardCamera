# ZKIDCardCamera

[![Version](https://img.shields.io/cocoapods/v/ZKIDCardCamera.svg?style=flat)](https://cocoapods.org/pods/ZKIDCardCamera)
[![License](https://img.shields.io/cocoapods/l/ZKIDCardCamera.svg?style=flat)](https://cocoapods.org/pods/ZKIDCardCamera)
[![Platform](https://img.shields.io/cocoapods/p/ZKIDCardCamera.svg?style=flat)](https://cocoapods.org/pods/ZKIDCardCamera)

![正面](https://github.com/kaiser143/ZKIDCardCamera/blob/master/screenshot/1.jpg)
![反面](https://github.com/kaiser143/ZKIDCardCamera/blob/master/screenshot/2.jpg)

身份证拍摄 UI 组件：提供取景框、拍照、预览与对焦；**证件 OCR/识别由宿主或第三方 SDK 实现**，通过协议接入。

## 特性

- 身份证正/反面取景框与引导 UI
- 点击对焦 + 连续自动对焦
- 完整相机权限流程（首次请求、拒绝引导、从设置返回后自动恢复）
- 基于 `AVCapturePhotoOutput` 拍照，Session 生命周期自动管理（前后台、页面切换）
- 默认按证件取景框**裁剪**输出，便于 OCR 对接
- 多语言（`en` / `zh-Hans`）与 `ZKIDCardCameraConfiguration` 自定义
- `ZKIDCardRecognitionProvider` 第三方识别协议

## Requirements

- iOS **12.0+**
- 宿主 App `Info.plist` 需配置相机权限说明：

```xml
<key>NSCameraUsageDescription</key>
<string>需要使用相机拍摄证件照片</string>
```

## Installation

```ruby
platform :ios, '12.0'

pod 'ZKIDCardCamera'
```

## 快速使用

```objc
#import <ZKIDCardCamera/ZKIDCardCameraController.h>

ZKIDCardCameraController *camera = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeFront];
camera.delegate = self;
camera.modalPresentationStyle = UIModalPresentationFullScreen; // 配合隐藏状态栏
[self presentViewController:camera animated:YES completion:nil];
```

### 带配置初始化

```objc
ZKIDCardCameraConfiguration *config = [ZKIDCardCameraConfiguration defaultConfiguration];
config.preferredLanguage = @"zh-Hans";

ZKIDCardCameraController *camera = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeReverse
                                                                   configuration:config];
camera.delegate = self;
camera.recognitionProvider = myOCRAdapter;
camera.modalPresentationStyle = UIModalPresentationFullScreen;
[self presentViewController:camera animated:YES completion:nil];
```

## 第三方识别对接

实现 `ZKIDCardRecognitionProvider`，并赋给 `recognitionProvider`。用户点击「使用照片」后，若配置了 provider，会先调用识别，再通过 delegate 回传结果。

```objc
@interface MyOCRAdapter : NSObject <ZKIDCardRecognitionProvider>
@end

@implementation MyOCRAdapter

- (void)recognizeIDCardImage:(UIImage *)image
                    cardType:(ZKIDCardType)cardType
                  completion:(void (^)(id, NSError *))completion {
    [ThirdPartySDK recognize:image side:cardType done:^(NSDictionary *info, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(info, err);
        });
    }];
}

@end
```

### Delegate 回调

| 方法 | 说明 |
|------|------|
| `idCardCamera:didCaptureImage:cardType:` | 用户确认使用照片 |
| `idCardCamera:didFinishRecognition:error:image:cardType:` | 配置了 `recognitionProvider` 且识别结束后 |
| `idCardCameraDidCancel:` | 用户关闭相机 |

> 旧接口 `cameraDidFinishShootWithCameraImage:` 仍可用，已标记废弃。

## 多语言

内置语言文件位于 `ZKIDCardCamera.bundle`：

- `en.lproj/Localizable.strings`
- `zh-Hans.lproj/Localizable.strings`

```objc
ZKIDCardCameraConfiguration *config = [ZKIDCardCameraConfiguration defaultConfiguration];
config.preferredLanguage = @"en"; // nil 时跟随系统（中文环境优先 zh-Hans，否则 en）
```

扩展语言：在宿主 bundle 中提供同名 key 的 strings，并通过 `config.resourceBundle` 指向宿主 bundle。

## 自定义 UI / 文案

`ZKIDCardCameraConfiguration` 支持：

| 类别 | 属性示例 |
|------|----------|
| 文案 | `hintTextFront`、`retakeButtonTitle`、`usePhotoButtonTitle`、权限弹窗文案等 |
| 外观 | `overlayColor`、`maskBorderColor`、`hintFont`、`bottomBarBackgroundColor` |
| 图片 | `shutterButtonImage`、`closeButtonImage`、`frontGuideImage` 等 |
| 行为 | `hidesStatusBar`（默认 YES）、`showsFlashButton`、`maskWidth`、`deliversCroppedImage`（默认 YES） |

```objc
ZKIDCardCameraConfiguration *config = [ZKIDCardCameraConfiguration defaultConfiguration];
config.hintTextFront = @"请将人像面对齐框内";
config.maskBorderColor = [UIColor colorWithRed:0 green:0.8 blue:1 alpha:1];
config.hidesStatusBar = YES;
config.deliversCroppedImage = YES; // NO 时回传相机原图
```

详细说明见头文件 [`ZKIDCardCameraConfiguration.h`](ZKIDCardCamera/Classes/ZKIDCardCameraConfiguration.h)。

### 证件框裁剪

默认 `deliversCroppedImage = YES`：拍照后按屏幕证件取景框区域裁剪，delegate 与识别 provider 收到的是裁剪图。若需要原图自行处理，可设为 `NO`：

```objc
config.deliversCroppedImage = NO;
```

## 相机能力说明

### 权限

| 状态 | 行为 |
|------|------|
| 首次使用 | 弹出系统授权框 |
| 已授权 | 正常进入拍摄 |
| 拒绝 / 受限 | 保留关闭按钮，弹窗引导前往设置；从设置返回且已授权时自动初始化相机 |

### 对焦

- 进入页面后连续自动对焦
- 点击预览区域手动对焦（显示聚焦框）
- 画面变化时自动回到中心对焦

### Session 生命周期

组件会在以下时机自动启停 `AVCaptureSession`：

- 页面 `viewWillAppear` / `viewWillDisappear`
- App 进入后台 / 回到前台
- 拍照预览态（不自动重启，重拍后恢复）
- 页面销毁时释放相机资源

### 隐藏状态栏

默认 `configuration.hidesStatusBar = YES`。若仍显示状态栏，请确认：

1. `modalPresentationStyle = UIModalPresentationFullScreen`
2. 外层未强制显示状态栏

## 公开头文件

| 头文件 | 说明 |
|--------|------|
| `ZKIDCardCameraController.h` | 拍摄页控制器与 Delegate |
| `ZKIDCardCameraConfiguration.h` | UI / 文案 / 行为配置 |
| `ZKIDCardRecognitionProvider.h` | 第三方识别协议 |
| `ZKIDCardCameraTypes.h` | `ZKIDCardType` 枚举 |
| `ZKIDCardFloatingView.h` | 取景浮层（一般无需直接使用） |

## Example

```bash
cd Example && pod install
```

打开 `Example/ZKIDCardCamera/ZKViewController.m` 可查看 delegate 与 Mock 识别实现。

> 若工程中曾集成 Reveal 调试脚本导致真机构建失败，请移除 Build Phases 中的 Reveal Server Run Script。

## Author

deyang143@126.com

## License

MIT — see [LICENSE](LICENSE).
