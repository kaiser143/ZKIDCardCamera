//
//  UIButton+ZKAdd.h
//  FBSnapshotTestCase
//
//  Created by Kaiser on 2019/1/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (ZKAdd)

/**
 *  @brief  设置按钮额外热区
 */
@property(nonatomic, assign) UIEdgeInsets touchAreaInsets;

/**
 *  @brief  设置标题普通与高亮
 *
 *  @param title 标题
 */
- (void)kai_setTitle:(NSString *)title;

/**
 *  @brief  设置标题文字颜色普通与高亮
 *
 *  @param color 标题颜色
 */
- (void)setTitleColor:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
