//
//  UIWindow+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (ZKAdd)

/**
 * Searches the view hierarchy recursively for the first responder, starting with this window.
 */
- (__kindof UIView *)findFirstResponder;

/**
 * Searches the view hierarchy recursively for the first responder, starting with topView.
 */
- (__kindof UIView *)findFirstResponderInView:(UIView *)topView;

@end

NS_ASSUME_NONNULL_END
