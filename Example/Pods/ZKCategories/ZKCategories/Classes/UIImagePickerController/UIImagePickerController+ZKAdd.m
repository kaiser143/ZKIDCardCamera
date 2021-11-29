//
//  UIImagePickerController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/10/21.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIImagePickerController+ZKAdd.h"

@implementation UIImagePickerController (ZKAdd)

// 解决在编辑状态下禁用 `FDFullscreenPopGesture` 功能，不禁用会多出来导航栏
- (BOOL)fd_viewControllerBasedNavigationBarAppearanceEnabled {
    return NO;
}

@end
