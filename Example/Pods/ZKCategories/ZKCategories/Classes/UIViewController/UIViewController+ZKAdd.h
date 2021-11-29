//
//  UIViewController+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKKeyboardStatus) {
    ZKKeyboardStatusDidHide,
    ZKKeyboardStatusWillShow,
    ZKKeyboardStatusDidShow,
    ZKKeyboardStatusWillHide
};

typedef void (^ZKKeyboardFrameAnimationBlock)(CGRect keyboardFrame);

@interface UIViewController (KeyboardNotifications)

@property (nonatomic, readonly) ZKKeyboardStatus keyboardStatus;

#pragma mark - Keyboard

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock;
- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock;

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock;
- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock;

#pragma mark - :. 转场

/// push 操作，返回按钮无文字
- (void)kai_pushViewController:(UIViewController *)viewController;
- (void)kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)kai_pushViewController:(UIViewController *)viewController backTitle:(NSString *)title animated:(BOOL)animated;

/// pop
- (void)kai_popViewControllerAnimated;
- (void)kai_popToRootViewControllerAnimated;

#pragma mark :. presentViewController

- (void)kai_presentViewController:(UIViewController *)newViewController;
- (void)kai_presentViewController:(UIViewController *)newViewController animated:(BOOL)animated;

@property (nonatomic, copy) void(^kai_prefersPopViewControllerInjectBlock)(UIViewController * _Nonnull controller);

@end

@interface UIViewController (ZKInteractiveTransitionTableViewDeselection)

@property (nonatomic, weak) UITableView *kai_prefersTableViewDeselectRowWhenViewWillAppear;

@end

NS_ASSUME_NONNULL_END
