#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ZKIDCardCameraConfiguration.h"
#import "ZKIDCardCameraController.h"
#import "ZKIDCardCameraImageProcessor.h"
#import "ZKIDCardCameraLocalization.h"
#import "ZKIDCardCameraTypes.h"
#import "ZKIDCardFloatingView.h"
#import "ZKIDCardMaskGeometry.h"
#import "ZKIDCardRecognitionProvider.h"

FOUNDATION_EXPORT double ZKIDCardCameraVersionNumber;
FOUNDATION_EXPORT const unsigned char ZKIDCardCameraVersionString[];

