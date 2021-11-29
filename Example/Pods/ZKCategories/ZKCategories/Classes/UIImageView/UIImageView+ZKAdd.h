//
//  UIImageView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (ZKAdd)

/*!
 *    @brief    初始化方法，设置圆角幅度和圆角位置
 *    @param    rectCorner    需要设置圆角的位置
 */
- (instancetype)initWithCornerRadius:(CGFloat)radius rectCorner:(UIRectCorner)rectCorner;

/*!
 *    @brief    初始化方法，生成圆形ImageView
 */
- (instancetype)initWithRoundingRectImageView;

/*!
 *    @brief    设置成圆角
 */
- (void)setCornerRadiusRoundingRect;

/*!
 *    @brief    设置边框
 */
- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color;


@end

NS_ASSUME_NONNULL_END
