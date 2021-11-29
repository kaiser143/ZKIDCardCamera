//
//  UIWindow+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIWindow+ZKAdd.h"

@implementation UIWindow (ZKAdd)

- (UIView *)findFirstResponder {
    return [self findFirstResponderInView:self];
}

- (UIView *)findFirstResponderInView:(UIView *)topView {
    if ([topView isFirstResponder]) {
        return topView;
    }

    for (UIView *subView in topView.subviews) {
        if ([subView isFirstResponder]) {
            return subView;
        }

        UIView *firstResponderCheck = [self findFirstResponderInView:subView];
        if (nil != firstResponderCheck) {
            return firstResponderCheck;
        }
    }
    return nil;
}

@end
