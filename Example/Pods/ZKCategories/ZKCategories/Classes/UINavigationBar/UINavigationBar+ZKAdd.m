//
//  UINavigationBar+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UINavigationBar+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import <objc/runtime.h>

@implementation UINavigationBar (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(kai_layoutSubviews)];
}

#pragma mark -
#pragma mark :. Awesome

- (void)kai_layoutSubviews {
    [self kai_layoutSubviews];
    if (@available(iOS 13.0, *)) {
    } else if (@available(iOS 11.0, *)) {
        self.layoutMargins = UIEdgeInsetsZero;
        for (UIView *view in self.subviews) {
            if ([NSStringFromClass(view.classForCoder) containsString:@"ContentView"]) {
                view.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 10);
            }
        }
    }
}

/**
 *  @brief  设置背景颜色
 *
 *  @param backgroundColor 颜色
 */
- (void)setbarbackgroundView:(UIColor *)backgroundColor {
    [self setNavigationBackground:0
                  backgroundColor:backgroundColor
                          isAlpha:YES];
}

/**
 *  @brief  设置背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    [self setNavigationBackground:alpha
                  backgroundColor:nil
                          isAlpha:YES];
}

/**
 *  @brief  侧滑设置背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setSlideNavigationBackground:(CGFloat)alpha {
    [self setNavigationBackground:alpha
                  backgroundColor:nil
                          isAlpha:NO];
}

/**
 *  @brief  动态设置背景
 *
 *  @param alpha 透明度
 *  @param backgroundColor 颜色
 */
- (void)setNavigationBackground:(CGFloat)alpha backgroundColor:(UIColor *)backgroundColor isAlpha:(BOOL)isAlpha {
    //将导航栏的子控件添加到数组当中,取首个子控件设置透明度(防止导航栏上存在非导航栏自带的控件)
    NSMutableArray *barSubviews = [NSMutableArray array];
    for (UIView *view in self.subviews) {
        if (![view isMemberOfClass:[UIView class]])
            [barSubviews addObject:view];
    }

    if (alpha == 0 && backgroundColor) {
        const CGFloat *components = CGColorGetComponents(backgroundColor.CGColor);
        alpha                     = MAX(1, components[3] ?: 1);
    }

    Ivar backgroundOpacityVar = class_getInstanceVariable([UINavigationBar class], "__backgroundOpacity");
    if (backgroundOpacityVar)
        [self setValue:@(alpha) forKey:@"__backgroundOpacity"];

    UIView *barBackgroundView = [barSubviews firstObject];
    barBackgroundView.alpha   = alpha;
    if (backgroundColor)
        barBackgroundView.backgroundColor = backgroundColor;

    if (isAlpha) {
        UINavigationController *superNav = (UINavigationController *)[self viewController];
        if (superNav && superNav.topViewController)
            [superNav.topViewController setAssociateCopyValue:@(alpha) withKey:@"navigationBarAlpha"];
    }
}

- (void)setTranslationY:(CGFloat)translationY {
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  设置要素透明度
 *
 *  @param alpha 透明度
 */
- (void)setElementsAlpha:(CGFloat)alpha {
    [[self valueForKey:@"_leftViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];

    [[self valueForKey:@"_rightViews"] enumerateObjectsUsingBlock:^(UIView *view, NSUInteger i, BOOL *stop) {
        view.alpha = alpha;
    }];

    UIView *titleView = [self valueForKey:@"_titleView"];
    titleView.alpha   = alpha;
    //    when viewController first load, the titleView maybe nil
    [[self subviews] enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UINavigationItemView")]) {
            obj.alpha = alpha;
            *stop     = YES;
        }
    }];
}

/**
 *  @author CC, 2016-12-30
 *
 *  @brief  重置
 */
- (void)reset {
    [self setNeedsNavigationBackground:1];
}

- (UIViewController *)viewController {
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}

@end
