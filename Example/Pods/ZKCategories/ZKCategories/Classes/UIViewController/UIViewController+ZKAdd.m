//
//  UIViewController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/25.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIViewController+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "UINavigationController+ZKAdd.h"

@implementation UIViewController (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(kai_viewWillAppear:)];
    [self swizzleMethod:@selector(viewDidDisappear:) withMethod:@selector(kai_viewDidDisappear:)];
}

- (void)kai_viewWillAppear:(BOOL)animated {
    [self kai_registerForKeyboardNotifications];
    [self kai_viewWillAppear:animated];

    UITableView *tableView = self.kai_prefersTableViewDeselectRowWhenViewWillAppear;
    if (tableView) {
        NSIndexPath *selectedIndexPath = [tableView indexPathForSelectedRow];
        if (selectedIndexPath != nil) {
            id<UIViewControllerTransitionCoordinator> coordinator = self.transitionCoordinator;
            if (coordinator != nil) {
                [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
                }
                    completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                        if (context.cancelled) {
                            [tableView selectRowAtIndexPath:selectedIndexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
                        }
                    }];
            } else {
                [tableView deselectRowAtIndexPath:selectedIndexPath animated:animated];
            }
        }
    }
}

- (void)kai_viewDidDisappear:(BOOL)animated {
    [self kai_unregisterForKeyboardNotifications];
    [self kai_viewDidDisappear:animated];
}

- (void)kai_setWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)willShowBlock {
    [self setAssociateCopyValue:willShowBlock withKey:@selector(kai_willShowAnimationBlock)];
}

- (ZKKeyboardFrameAnimationBlock)kai_willShowAnimationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_setWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)willHideBlock {
    [self setAssociateCopyValue:willHideBlock withKey:@selector(kai_willHideAnimationBlock)];
}

- (ZKKeyboardFrameAnimationBlock)kai_willHideAnimationBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_setDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    [self setAssociateCopyValue:didShowBlock withKey:@selector(kai_didShowActionBlock)];
}

- (ZKKeyboardFrameAnimationBlock)kai_didShowActionBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_setDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    [self setAssociateCopyValue:didHideBlock withKey:@selector(kai_didHideActionBlock)];
}

- (ZKKeyboardFrameAnimationBlock)kai_didHideActionBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_setNotificationsOn:(BOOL)notificationsOn {
    [self setAssociateValue:@(notificationsOn) withKey:@selector(kai_areNotificationsOn)];
}

- (BOOL)kai_areNotificationsOn {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKeyboardStatus:(ZKKeyboardStatus)keyboardStatus {
    [self setAssociateValue:@(keyboardStatus) withKey:@selector(keyboardStatus)];
}

- (ZKKeyboardStatus)keyboardStatus {
    ZKKeyboardStatus status = [[self associatedValueForKey:_cmd] unsignedIntegerValue];
    return status;
}

- (void)setKeyboardWillShowAnimationBlock:(ZKKeyboardFrameAnimationBlock)showBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillShowBlock = [self kai_willShowAnimationBlock];
        
        if (!showBlock && prevWillShowBlock)
            [self unregisterWillShowNotification];
        else if (showBlock && !prevWillShowBlock)
            [self registerWillShowNotification];
    }
    
    [self kai_setWillShowAnimationBlock:showBlock];
}

- (void)setKeyboardWillHideAnimationBlock:(ZKKeyboardFrameAnimationBlock)hideBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevWillHideBlock = [self kai_willHideAnimationBlock];
        
        if (!hideBlock && prevWillHideBlock)
            [self unregisterWillHideNotification];
        else if (hideBlock && !prevWillHideBlock)
            [self registerWillHideNotification];
    }
    
    [self kai_setWillHideAnimationBlock:hideBlock];
}

- (void)setKeyboardDidShowActionBlock:(ZKKeyboardFrameAnimationBlock)didShowBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidShowBlock = [self kai_didShowActionBlock];
        
        if (!didShowBlock && prevDidShowBlock)
            [self unregisterDidShowNotification];
        else if (didShowBlock && !prevDidShowBlock)
            [self registerDidShowNotification];
    }
    
    [self kai_setDidShowActionBlock:didShowBlock];
}

- (void)setKeyboardDidHideActionBlock:(ZKKeyboardFrameAnimationBlock)didHideBlock {
    if ([self kai_areNotificationsOn]) {
        ZKKeyboardFrameAnimationBlock prevDidHideBlock = [self kai_didHideActionBlock];
        
        if (!didHideBlock && prevDidHideBlock)
            [self unregisterDidHideNotification];
        else if (didHideBlock && !prevDidHideBlock)
            [self registerDidHideNotification];
    }
    
    [self kai_setDidHideActionBlock:didHideBlock];
}

#pragma mark - registering notifications

- (void)kai_registerForKeyboardNotifications {
    [self kai_setNotificationsOn:YES];
    
    if ([self kai_willShowAnimationBlock])
        [self registerWillShowNotification];
    
    if ([self kai_willHideAnimationBlock])
        [self registerWillHideNotification];
    
    if ([self kai_didShowActionBlock])
        [self registerDidShowNotification];
    
    if ([self kai_didHideActionBlock])
        [self registerDidHideNotification];
}

- (void)registerWillShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)registerWillHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)registerDidShowNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)registerDidHideNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kai_keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)kai_unregisterForKeyboardNotifications {
    [self kai_setNotificationsOn:NO];
    
    if ([self kai_willShowAnimationBlock])
        [self unregisterWillShowNotification];
    
    if ([self kai_willHideAnimationBlock])
        [self unregisterWillHideNotification];
    
    if ([self kai_didShowActionBlock])
        [self unregisterDidShowNotification];
    
    if ([self kai_didHideActionBlock])
        [self unregisterDidHideNotification];
}

- (void)unregisterWillShowNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)unregisterWillHideNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterDidShowNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)unregisterDidHideNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}


#pragma mark - notification callbacks

- (void)kai_keyboardWillShow:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_willShowAnimationBlock]
                   withNotification:notification];
}

- (void)kai_keyboardWillHide:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_willHideAnimationBlock]
                   withNotification:notification];
}

- (void)kai_keyboardDidShow:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_didShowActionBlock]
                   withNotification:notification];
}

- (void)kai_keyboardDidHide:(NSNotification *)notification {
    [self kai_performAnimationBlock:[self kai_didHideActionBlock]
                   withNotification:notification];
}

- (void)kai_performAnimationBlock:(ZKKeyboardFrameAnimationBlock)animationBlock withNotification:(NSNotification *)notification {
    if (!animationBlock)
        return;
    
    NSDictionary *info = [notification userInfo];
    
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    NSInteger curve                  = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue] << 16;
    CGRect keyboardFrame             = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    ZKKeyboardStatus status          = [self kai_keyboardStatusForNotification:notification];
    
    if (!(status != ZKKeyboardStatusDidHide && [self __isIllogicalKeyboardStatus:status])) {
        self.keyboardStatus = status;
    }
    
    [UIView animateWithDuration:animationDuration
                          delay:0.0
                        options:curve|UIViewAnimationOptionLayoutSubviews|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ animationBlock(keyboardFrame); }
                     completion:nil];
}

- (ZKKeyboardStatus)kai_keyboardStatusForNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    
    if ([name isEqualToString:UIKeyboardWillShowNotification]) {
        return ZKKeyboardStatusWillShow;
    }
    if ([name isEqualToString:UIKeyboardDidShowNotification]) {
        return ZKKeyboardStatusDidShow;
    }
    if ([name isEqualToString:UIKeyboardWillHideNotification]) {
        return ZKKeyboardStatusWillHide;
    }
    if ([name isEqualToString:UIKeyboardDidHideNotification]) {
        return ZKKeyboardStatusDidHide;
    }
    return -1;
}

- (BOOL)__isIllogicalKeyboardStatus:(ZKKeyboardStatus)newStatus {
    if ((self.keyboardStatus == ZKKeyboardStatusDidHide && newStatus == ZKKeyboardStatusWillShow) ||
        (self.keyboardStatus == ZKKeyboardStatusWillShow && newStatus == ZKKeyboardStatusDidShow) ||
        (self.keyboardStatus == ZKKeyboardStatusDidShow && newStatus == ZKKeyboardStatusWillHide) ||
        (self.keyboardStatus == ZKKeyboardStatusWillHide && newStatus == ZKKeyboardStatusDidHide)) {
        return NO;
    }
    return YES;
}

#pragma mark - :. Back

- (void)setKai_prefersPopViewControllerInjectBlock:(void (^)(UIViewController * _Nonnull))block {
    self.kai_interactivePopDisabled = block != nil;
    
    [self setAssociateCopyValue:block withKey:@selector(kai_prefersPopViewControllerInjectBlock)];
}

- (void (^)(UIViewController * _Nonnull))kai_prefersPopViewControllerInjectBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)kai_pushViewController:(UIViewController *)viewController {
    [self kai_pushViewController:viewController animated:YES];
}

- (void)kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self kai_pushViewController:viewController backTitle:@"" animated:animated];
}

- (void)kai_pushViewController:(UIViewController *)viewController backTitle:(NSString *)title animated:(BOOL)animated {
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:nil];
    self.navigationController.topViewController.navigationItem.backBarButtonItem = backBarButtonItem;
    [self.navigationController pushViewController:viewController animated:animated];
}

- (void)kai_popViewControllerAnimated {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)kai_popToRootViewControllerAnimated {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)kai_presentViewController:(UIViewController *)newViewController {
    [self kai_presentViewController:newViewController animated:YES];
}

- (void)kai_presentViewController:(UIViewController *)newViewController animated:(BOOL)animated {
    if (self.parentViewController)
        [self.parentViewController presentViewController:newViewController animated:animated completion:nil];
    else {
        UIViewController *rootViewController = [[UIApplication sharedApplication].windows firstObject].rootViewController;
        while (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
        [rootViewController presentViewController:newViewController animated:animated completion:nil];
    }
}

@end

@implementation UINavigationController (__KAINavigationBackItemInjection)

+ (void)load {
    [self swizzleMethod:@selector(navigationBar:shouldPopItem:) withMethod:@selector(_kai_navigationBar:shouldPopItem:)];
}

// 修复Xcode11 iOS13 `navigationBar:shouldPopItem:` 不运行的问题
- (BOOL)_kai_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item {
    if (self.topViewController.navigationItem != item) return YES;
    
    // Should pop. It appears called the pop view controller methods. We should pop items directly.
    if ([[self valueForKey:@"_isTransitioning"] boolValue]) return YES;
    
    UIView *barBackIndicatorView = navigationBar.subviews.lastObject;
    barBackIndicatorView.alpha = 1;
    
    UIViewController *topViewController = self.topViewController;
    void (^callback)(UIViewController *) = topViewController.kai_prefersPopViewControllerInjectBlock;
    if (!callback) [self popViewControllerAnimated:YES];
    else callback(topViewController);
    
    return NO;
}

@end

@implementation UIViewController (ZKInteractiveTransitionTableViewDeselection)

- (UITableView *)kai_prefersTableViewDeselectRowWhenViewWillAppear {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_prefersTableViewDeselectRowWhenViewWillAppear:(UITableView *)kai_prefersTableViewDeselectRowWhenViewWillAppear {
    [self setAssociateWeakValue:kai_prefersTableViewDeselectRowWhenViewWillAppear withKey:@selector(kai_prefersTableViewDeselectRowWhenViewWillAppear)];
}

@end
