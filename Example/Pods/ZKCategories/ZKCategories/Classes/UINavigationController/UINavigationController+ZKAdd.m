//
//  UINavigationController+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "UINavigationController+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "UINavigationBar+ZKAdd.h"

@interface _KAIFullscreenPopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation _KAIFullscreenPopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    if (topViewController.kai_interactivePopDisabled) {
        return NO;
    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGFloat maxAllowedInitialDistance = topViewController.kai_interactivePopMaxAllowedInitialDistanceToLeftEdge;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    BOOL isLeftToRight = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionLeftToRight;
    CGFloat multiplier = isLeftToRight ? 1 : - 1;
    if ((translation.x * multiplier) <= 0) {
        return NO;
    }
    
    self.navigationController.kai_grTransitioning = YES;
    
    return YES;
}

@end


@implementation UINavigationController (ZKAdd)

- (UIViewController *)viewControllerForClass:(Class)cls {
    for (UIViewController *each in self.viewControllers) {
        if ([each isKindOfClass:cls] == YES) {
            return each;
        }
    }
    
    return nil;
}

- (NSArray *)popToViewControllerClass:(Class)aClass animated:(BOOL)animated {
    UIViewController *controller = [self viewControllerForClass:aClass];
    if (!controller) {
        return nil;
    }
    
    return [self popToViewController:controller animated:animated];
}

- (UIViewController *)popThenPushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *controller = [self popViewControllerAnimated:NO];
    
    [self pushViewController:viewController animated:animated];
    
    return controller;
}

@end

typedef void (^_KAIViewControllerWillAppearInjectBlock)(UIViewController *viewController, BOOL animated);

@interface UIViewController (KAIFullscreenPopGesturePrivate)

@property (nonatomic, copy) _KAIViewControllerWillAppearInjectBlock kai_willAppearInjectBlock;

@end

@implementation UIViewController (KAIFullscreenPopGesturePrivate)

+ (void)load {
    [self swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(__kai_viewWillAppear:)];
    [self swizzleMethod:@selector(viewWillDisappear:) withMethod:@selector(__kai_viewWillDisappear:)];
}

- (void)__kai_viewWillAppear:(BOOL)animated {
    // Forward to primary implementation.
    [self __kai_viewWillAppear:animated];
    
    if (self.kai_willAppearInjectBlock) {
        self.kai_willAppearInjectBlock(self, animated);
    }
}

- (void)__kai_viewWillDisappear:(BOOL)animated {
    // Forward to primary implementation.
    [self __kai_viewWillDisappear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIViewController *viewController = self.navigationController.viewControllers.lastObject;
        if (viewController && viewController.kai_willAppearInjectBlock && !viewController.kai_prefersNavigationBarHidden) {
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
    });
}

- (_KAIViewControllerWillAppearInjectBlock)kai_willAppearInjectBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)setKai_willAppearInjectBlock:(_KAIViewControllerWillAppearInjectBlock)block {
    [self setAssociateValue:block withKey:@selector(kai_willAppearInjectBlock)];
}

@end

@implementation UINavigationController (KAIFullscreenPopGesture)

+ (void)load {
    // Inject "-pushViewController:animated:"
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethod:@selector(pushViewController:animated:) withMethod:@selector(_kai_pushViewController:animated:)];
        [self swizzleMethod:NSSelectorFromString(@"_updateInteractiveTransition:") withMethod:@selector(_kai_updateInteractiveTransition:)];
        [self swizzleMethod:@selector(popViewControllerAnimated:) withMethod:@selector(_kai_popViewControllerAnimated:)];
    });
}

- (void)_kai_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count) {
        viewController.hidesBottomBarWhenPushed = YES;
        [viewController setAssociateValue:@1 withKey:@"navigationBarAlpha"];
        [self.navigationBar setNeedsNavigationBackground:1];
    }
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.kai_fullscreenPopGestureRecognizer]) {
        
        // Add our own gesture recognizer to where the onboard screen edge pan gesture recognizer is attached to.
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.kai_fullscreenPopGestureRecognizer];
        
        // Forward the gesture events to the private handler of the onboard gesture recognizer.
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.kai_fullscreenPopGestureRecognizer.delegate = self.kai_popGestureRecognizerDelegate;
        [self.kai_fullscreenPopGestureRecognizer addTarget:internalTarget action:internalAction];
        
        // Disable the onboard gesture recognizer.
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    
    // Handle perferred navigation bar appearance.
    [self _kai_setupViewControllerBasedNavigationBarAppearanceIfNeeded:viewController];
    
    // Forward to primary implementation.
    if (![self.viewControllers containsObject:viewController]) {
        [self _kai_pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)_kai_popViewControllerAnimated:(BOOL)animated {
    UIViewController *popVc = [self _kai_popViewControllerAnimated:animated];
    if (self.viewControllers.count <= 0) return popVc;
    
    UIViewController *topVC = [self.viewControllers lastObject];
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator != nil) {
            if (@available(iOS 10.0, *)) {
                [coordinator notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
                    [self navigationBarChanges:context];
                }];
                
                if (!self.isKai_grTransitioning)
                    [self navigationBarChanges:coordinator];
            } else {
                [coordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> _Nonnull context) {
                    [self navigationBarChanges:context];
                }];
            }
        }
    }
    return popVc;
}

- (void)navigationBarChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) { // 取消了(还在当前页面)
        CGFloat animdDuration = [context transitionDuration] * [context percentComplete];
        UIViewController *fromViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
        CGFloat fromVCAlpha = [[fromViewController associatedValueForKey:@"navigationBarAlpha"] floatValue];
        [UIView animateWithDuration:animdDuration
                         animations:^{
                             [self.navigationBar setSlideNavigationBackground:fromVCAlpha];
                         }];
    } else { // 自动完成(pop到上一个界面了)
        CGFloat animdDuration = [context transitionDuration] * (1 - [context percentComplete]);
        UIViewController *toViewController = [context viewControllerForKey:UITransitionContextToViewControllerKey];
        CGFloat toVCAlpha = [[toViewController associatedValueForKey:@"navigationBarAlpha"] floatValue];
        [UIView animateWithDuration:animdDuration
                         animations:^{
                             [self.navigationBar setSlideNavigationBackground:toVCAlpha];
                         }];
    };
    self.kai_grTransitioning = NO;
}

- (void)_kai_updateInteractiveTransition:(CGFloat)percentComplete {
    [self _kai_updateInteractiveTransition:percentComplete];
    UIViewController *topVC = self.topViewController;
    if (topVC) {
        id<UIViewControllerTransitionCoordinator> coordinator = topVC.transitionCoordinator;
        if (coordinator != nil) {
            UIViewController *fromViewController = [coordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
            id fromAlpha = [fromViewController associatedValueForKey:@"navigationBarAlpha"];
            CGFloat fromVCAlpha = 1;
            if (fromAlpha)
                fromVCAlpha = [fromAlpha floatValue];
            
            UIViewController *toViewController = [coordinator viewControllerForKey:UITransitionContextToViewControllerKey];
            id toAlpha = [toViewController associatedValueForKey:@"navigationBarAlpha"];
            CGFloat toVCAlpha = 1;
            if (toAlpha)
                toVCAlpha = [toAlpha floatValue];
            
            CGFloat newAlpha = fromVCAlpha + ((toVCAlpha - fromVCAlpha) * percentComplete);
            [self.navigationBar setSlideNavigationBackground:newAlpha];
        }
    }
}

- (void)_kai_setupViewControllerBasedNavigationBarAppearanceIfNeeded:(UIViewController *)appearingViewController {
    if (!self.kai_viewControllerBasedNavigationBarAppearanceEnabled) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    _KAIViewControllerWillAppearInjectBlock block = ^(UIViewController *viewController, BOOL animated) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf setNavigationBarHidden:viewController.kai_prefersNavigationBarHidden animated:animated];
        }
    };
    
    // Setup will appear inject block to appearing view controller.
    // Setup disappearing view controller as well, because not every view controller is added into
    // stack by pushing, maybe by "-setViewControllers:".
    appearingViewController.kai_willAppearInjectBlock = block;
    UIViewController *disappearingViewController = self.viewControllers.lastObject;
    if (disappearingViewController && !disappearingViewController.kai_willAppearInjectBlock) {
        disappearingViewController.kai_willAppearInjectBlock = block;
    }
}

- (_KAIFullscreenPopGestureRecognizerDelegate *)kai_popGestureRecognizerDelegate {
    _KAIFullscreenPopGestureRecognizerDelegate *delegate = [self associatedValueForKey:_cmd];
    
    if (!delegate) {
        delegate = [[_KAIFullscreenPopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        [self setAssociateValue:delegate withKey:_cmd];
    }
    return delegate;
}

- (UIPanGestureRecognizer *)kai_fullscreenPopGestureRecognizer {
    UIPanGestureRecognizer *panGestureRecognizer = [self associatedValueForKey:_cmd];
    
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        [self setAssociateValue:panGestureRecognizer withKey:_cmd];
    }
    return panGestureRecognizer;
}

- (BOOL)kai_viewControllerBasedNavigationBarAppearanceEnabled {
    NSNumber *number = [self associatedValueForKey:_cmd];
    if (number) {
        return number.boolValue;
    }
    self.kai_viewControllerBasedNavigationBarAppearanceEnabled = YES;
    return YES;
}

- (void)setKai_viewControllerBasedNavigationBarAppearanceEnabled:(BOOL)enabled {
    SEL key = @selector(kai_viewControllerBasedNavigationBarAppearanceEnabled);
    [self setAssociateValue:@(enabled) withKey:key];
}

- (BOOL)isKai_grTransitioning {
    NSNumber *number = [self associatedValueForKey:_cmd];
    return number.boolValue;
}

- (void)setKai_grTransitioning:(BOOL)kai_grTransitioning {
    [self setAssociateValue:@(kai_grTransitioning) withKey:@selector(isKai_grTransitioning)];
}

@end

@implementation UIViewController (KAIFullscreenPopGesture)

- (BOOL)kai_interactivePopDisabled {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_interactivePopDisabled:(BOOL)disabled {
    [self setAssociateValue:@(disabled) withKey:@selector(kai_interactivePopDisabled)];
}

- (BOOL)kai_prefersNavigationBarHidden {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setKai_prefersNavigationBarHidden:(BOOL)hidden {
    [self setAssociateValue:@(hidden) withKey:@selector(kai_prefersNavigationBarHidden)];
}


- (CGFloat)kai_interactivePopMaxAllowedInitialDistanceToLeftEdge {
#if CGFLOAT_IS_DOUBLE
    return [[self associatedValueForKey:_cmd] doubleValue];
#else
    return [[self associatedValueForKey:_cmd] floatValue];
#endif
}

- (void)setKai_interactivePopMaxAllowedInitialDistanceToLeftEdge:(CGFloat)distance {
    SEL key = @selector(kai_interactivePopMaxAllowedInitialDistanceToLeftEdge);
    [self setAssociateValue:@(MAX(0, distance)) withKey:key];
}

@end
