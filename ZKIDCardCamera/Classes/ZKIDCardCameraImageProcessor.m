//
//  ZKIDCardCameraImageProcessor.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import "ZKIDCardCameraImageProcessor.h"
#import <AVFoundation/AVFoundation.h>

UIImage *ZKIDCardNormalizedImage(UIImage *image) {
    if (!image || image.imageOrientation == UIImageOrientationUp) {
        return image;
    }
    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = image.scale;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:image.size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull rendererContext) {
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    }];
}

UIImage *ZKIDCardCropImage(UIImage *image,
                           AVCaptureVideoPreviewLayer *previewLayer,
                           CGRect maskFrameInViewCoordinates) {
    if (!image || !previewLayer) {
        return image;
    }

    UIImage *normalizedImage = ZKIDCardNormalizedImage(image);
    CGImageRef sourceImage = normalizedImage.CGImage;
    if (!sourceImage) {
        return image;
    }

    CGRect viewBounds = previewLayer.bounds;
    CGFloat viewWidth = CGRectGetWidth(viewBounds);
    CGFloat viewHeight = CGRectGetHeight(viewBounds);
    if (viewWidth <= 0.f || viewHeight <= 0.f) {
        return normalizedImage;
    }

    size_t pixelWidth = CGImageGetWidth(sourceImage);
    size_t pixelHeight = CGImageGetHeight(sourceImage);
    CGFloat imageWidth = normalizedImage.size.width;
    CGFloat imageHeight = normalizedImage.size.height;
    if (imageWidth <= 0.f || imageHeight <= 0.f) {
        return normalizedImage;
    }

    CGFloat pixelScale = (CGFloat)pixelWidth / imageWidth;
    CGFloat fillScale = MAX(viewWidth / imageWidth, viewHeight / imageHeight);
    CGFloat displayedWidth = imageWidth * fillScale;
    CGFloat displayedHeight = imageHeight * fillScale;
    CGFloat offsetX = (displayedWidth - viewWidth) / 2.f;
    CGFloat offsetY = (displayedHeight - viewHeight) / 2.f;

    CGRect maskInImagePoints = CGRectMake((CGRectGetMinX(maskFrameInViewCoordinates) + offsetX) / fillScale,
                                        (CGRectGetMinY(maskFrameInViewCoordinates) + offsetY) / fillScale,
                                        CGRectGetWidth(maskFrameInViewCoordinates) / fillScale,
                                        CGRectGetHeight(maskFrameInViewCoordinates) / fillScale);

    CGRect cropRect = CGRectMake(maskInImagePoints.origin.x * pixelScale,
                                 maskInImagePoints.origin.y * pixelScale,
                                 maskInImagePoints.size.width * pixelScale,
                                 maskInImagePoints.size.height * pixelScale);
    cropRect = CGRectIntegral(cropRect);
    cropRect = CGRectIntersection(cropRect, CGRectMake(0, 0, pixelWidth, pixelHeight));
    if (CGRectIsEmpty(cropRect)) {
        return normalizedImage;
    }

    CGImageRef croppedImageRef = CGImageCreateWithImageInRect(sourceImage, cropRect);
    if (!croppedImageRef) {
        return normalizedImage;
    }
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedImageRef
                                                  scale:normalizedImage.scale
                                            orientation:UIImageOrientationUp];
    CGImageRelease(croppedImageRef);
    return croppedImage ?: normalizedImage;
}
