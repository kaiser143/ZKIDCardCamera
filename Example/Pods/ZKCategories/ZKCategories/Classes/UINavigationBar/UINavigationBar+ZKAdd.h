//
//  UINavigationBar+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @code
 #define NAVBAR_CHANGE_POINT 50
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
        UIColor * color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1]; //导航栏背景色
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > NAVBAR_CHANGE_POINT) {
            CGFloat alpha = MIN(1, 1 - ((NAVBAR_CHANGE_POINT + 64 - offsetY) / 64));
            [self.navigationController.navigationBar setbarbackgroundView:[color colorWithAlphaComponent:alpha]];
        } else {
            [self.navigationController.navigationBar setbarbackgroundView:[color colorWithAlphaComponent:0]];
        }
 }

 导航栏缩进
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView {
        CGFloat offsetY = scrollView.contentOffset.y;
        if (offsetY > 0) {
            if (offsetY >= 44) {
                [self setNavigationBarTransformProgress:1];
            } else {
                [self setNavigationBarTransformProgress:(offsetY / 44)];
            }
        } else {
            [self setNavigationBarTransformProgress:0];
            self.navigationController.navigationBar.backIndicatorImage = [UIImage new];
        }
 }

 - (void)setNavigationBarTransformProgress:(CGFloat)progress {
        [self.navigationController.navigationBar setTranslationY:(-44 * progress)];
        [self.navigationController.navigationBar setElementsAlpha:(1-progress)];
 }
 * @endcode
 */

@interface UINavigationBar (ZKAdd)

/**
 *  @brief  设置背景颜色
 *  设置导航栏背景样式有两个方法，setBackgroundImage:forBarMetrics: 和 setBarTintColor:   推荐使用前者
 *  参见 https://github.com/MoZhouqi/KMNavigationBarTransition/blob/master/README_CN.md#已知问题
 *  @param backgroundColor 颜色
 */
- (void)setbarbackgroundView:(UIColor *)backgroundColor;

/**
 *  @brief  设置导航栏背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setNeedsNavigationBackground:(CGFloat)alpha;

/**
 *  @brief  侧滑设置背景透明度
 *
 *  @param alpha 透明度
 */
- (void)setSlideNavigationBackground:(CGFloat)alpha;

/**
 *  @brief  设置要素透明度
 *
 *  @param alpha 透明度
 */
- (void)setElementsAlpha:(CGFloat)alpha;

/**
 *  @brief  动画
 *
 *  @param translationY 动画值
 */
- (void)setTranslationY:(CGFloat)translationY;

@end

NS_ASSUME_NONNULL_END
