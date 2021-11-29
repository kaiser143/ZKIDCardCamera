//
//  UIScreen+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Provides extensions for `UIScreen`.
 */
@interface UIScreen (ZKAdd)

/**
 Main screen's scale
 
 @return screen's scale
 */
+ (CGFloat)screenScale;

/**
 Returns the bounds of the screen for the current device orientation.
 
 @return A rect indicating the bounds of the screen.
 @see    boundsForOrientation:
 */
- (CGRect)currentBounds NS_EXTENSION_UNAVAILABLE_IOS("");

/**
 Returns the bounds of the screen for a given device orientation.
 `UIScreen`'s `bounds` method always returns the bounds of the
 screen of it in the portrait orientation.
 
 @param orientation  The orientation to get the screen's bounds.
 @return A rect indicating the bounds of the screen.
 @see  currentBounds
 */
- (CGRect)boundsForOrientation:(UIInterfaceOrientation)orientation;

/**
 The screen's real size in pixel (width is always smaller than height).
 This value may not be very accurate in an unknown device, or simulator.
 e.g. (768,1024)
 */
@property (nonatomic, readonly) CGSize sizeInPixel;

/**
 The screen's PPI.
 This value may not be very accurate in an unknown device, or simulator.
 Default value is 96.
 */
@property (nonatomic, readonly) CGFloat pixelsPerInch;

@end

NS_ASSUME_NONNULL_END
