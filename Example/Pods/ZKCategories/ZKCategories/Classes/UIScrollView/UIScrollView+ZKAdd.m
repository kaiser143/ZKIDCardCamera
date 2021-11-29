//
//  UIScrollView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIScrollView+ZKAdd.h"
#import "ZKCategoriesMacro.h"
#import "NSObject+ZKAdd.h"
#import "NSNumber+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import "ZKCGUtilities.h"

ZKSYNTH_DUMMY_CLASS(UIScrollView_ZKAdd)

static inline UIViewAnimationOptions UIViewAnimationCurveToAnimationOptions(UIViewAnimationCurve curve) {
    return curve << 16;
}

@implementation UIScrollView (ZKAdd)

- (void)setContentInsetTop:(CGFloat)contentInsetTop {
    UIEdgeInsets inset = self.contentInset;
    inset.top          = contentInsetTop;
    self.contentInset  = inset;
}

- (CGFloat)contentInsetTop {
    return self.contentInset.top;
}

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom {
    UIEdgeInsets inset = self.contentInset;
    inset.bottom       = contentInsetBottom;
    self.contentInset  = inset;
}

- (CGFloat)contentInsetBottom {
    return self.contentInset.bottom;
}

- (void)setContentInsetLeft:(CGFloat)contentInsetLeft {
    UIEdgeInsets inset = self.contentInset;
    inset.left         = contentInsetLeft;
    self.contentInset  = inset;
}

- (CGFloat)contentInsetLeft {
    return self.contentInset.left;
}

- (void)setContentInsetRight:(CGFloat)contentInsetRight {
    UIEdgeInsets inset = self.contentInset;
    inset.right        = contentInsetRight;
    self.contentInset  = inset;
}

- (CGFloat)contentInsetRight {
    return self.contentInset.right;
}

- (void)setContentOffsetX:(CGFloat)contentOffsetX {
    CGPoint offset     = self.contentOffset;
    offset.x           = contentOffsetX;
    self.contentOffset = offset;
}

- (CGFloat)contentOffsetX {
    return self.contentOffset.x;
}

- (void)setContentOffsetY:(CGFloat)contentOffsetY {
    CGPoint offset     = self.contentOffset;
    offset.y           = contentOffsetY;
    self.contentOffset = offset;
}

- (CGFloat)contentOffsetY {
    return self.contentOffset.y;
}

- (void)setContentSizeWidth:(CGFloat)contentSizeWidth {
    CGSize size      = self.contentSize;
    size.width       = contentSizeWidth;
    self.contentSize = size;
}

- (CGFloat)contentSizeWidth {
    return self.contentSize.width;
}

- (void)setContentSizeHeight:(CGFloat)contentSizeHeight {
    CGSize size      = self.contentSize;
    size.height      = contentSizeHeight;
    self.contentSize = size;
}

- (CGFloat)contentSizeHeight {
    return self.contentSize.height;
}

- (ZKScrollDirection)scrollDirection {
    ZKScrollDirection direction = ZKScrollDirectionUndefine;
    CGPoint point               = [self.panGestureRecognizer translationInView:self.superview];
    if (point.y > 0.0f) {
        direction = ZKScrollDirectionUp;
    } else if (point.y < 0.0f) {
        direction = ZKScrollDirectionDown;
    } else if (point.x < 0.0f) {
        direction = ZKScrollDirectionLeft;
    } else if (point.x > 0.0f) {
        direction = ZKScrollDirectionRight;
    }

    return direction;
}

- (void)scrollToTop {
    [self scrollToTopAnimated:YES];
}

- (void)scrollToBottom {
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToLeft {
    [self scrollToLeftAnimated:YES];
}

- (void)scrollToRight {
    [self scrollToRightAnimated:YES];
}

- (void)scrollToTopAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y       = 0 - self.contentInset.top;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.y       = self.contentSize.height - self.bounds.size.height + self.contentInset.bottom;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToLeftAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x       = 0 - self.contentInset.left;
    [self setContentOffset:off animated:animated];
}

- (void)scrollToRightAnimated:(BOOL)animated {
    CGPoint off = self.contentOffset;
    off.x       = self.contentSize.width - self.bounds.size.width + self.contentInset.right;
    [self setContentOffset:off animated:animated];
}

- (NSInteger)pages {
    NSInteger pages = self.contentSize.width / self.frame.size.width;
    return pages;
}

- (NSInteger)currentPage {
    NSInteger pages       = self.contentSize.width / self.frame.size.width;
    CGFloat scrollPercent = [self scrollPercent];
    NSInteger currentPage = (NSInteger)roundf((pages - 1) * scrollPercent);
    return currentPage;
}

- (CGFloat)scrollPercent {
    CGFloat width         = self.contentSize.width - self.frame.size.width;
    CGFloat scrollPercent = self.contentOffset.x / width;
    return scrollPercent;
}

- (CGFloat)pagesY {
    CGFloat pageHeight    = self.frame.size.height;
    CGFloat contentHeight = self.contentSize.height;
    return contentHeight / pageHeight;
}

- (CGFloat)pagesX {
    CGFloat pageWidth    = self.frame.size.width;
    CGFloat contentWidth = self.contentSize.width;
    return contentWidth / pageWidth;
}

- (CGFloat)currentPageY {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY    = self.contentOffset.y;
    return offsetY / pageHeight;
}

- (CGFloat)currentPageX {
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetX   = self.contentOffset.x;
    return offsetX / pageWidth;
}

- (void)setPageY:(CGFloat)page {
    [self setPageY:page animated:NO];
}

- (void)setPageX:(CGFloat)page {
    [self setPageX:page animated:NO];
}

- (void)setPageY:(CGFloat)page animated:(BOOL)animated {
    CGFloat pageHeight = self.frame.size.height;
    CGFloat offsetY    = page * pageHeight;
    CGFloat offsetX    = self.contentOffset.x;
    CGPoint offset     = CGPointMake(offsetX, offsetY);
    [self setContentOffset:offset];
}

- (void)setPageX:(CGFloat)page animated:(BOOL)animated {
    CGFloat pageWidth = self.frame.size.width;
    CGFloat offsetY   = self.contentOffset.y;
    CGFloat offsetX   = page * pageWidth;
    CGPoint offset    = CGPointMake(offsetX, offsetY);
    [self setContentOffset:offset animated:animated];
}

#pragma mark -
#pragma mark :. keyboardControl

#pragma mark - :. Setters

- (void)setKeyboardWillBeDismissed:(KeyboardWillBeDismissedBlock)keyboardWillBeDismissed {
    [self setAssociateCopyValue:keyboardWillBeDismissed withKey:@selector(keyboardWillBeDismissed)];
}

- (KeyboardWillBeDismissedBlock)keyboardWillBeDismissed {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardDidHide:(KeyboardDidHideBlock)keyboardDidHide {
    [self setAssociateCopyValue:keyboardDidHide withKey:@selector(keyboardDidHide)];
}

- (KeyboardDidHideBlock)keyboardDidHide {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardDidChange:(KeyboardDidShowBlock)keyboardDidChange {
    [self setAssociateCopyValue:keyboardDidChange withKey:@selector(keyboardDidChange)];
}

- (KeyboardDidShowBlock)keyboardDidChange {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardWillSnapBackToPoint:(KeyboardWillSnapBackToPointBlock)keyboardWillSnapBackToPoint {
    [self setAssociateCopyValue:keyboardWillSnapBackToPoint withKey:@selector(keyboardWillSnapBackToPoint)];
}

- (KeyboardWillSnapBackToPointBlock)keyboardWillSnapBackToPoint {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardDidScrollToPoint:(KeyboardDidScrollToPointBlock)keyboardDidScrollToPoint {
    [self setAssociateCopyValue:keyboardDidScrollToPoint withKey:@selector(keyboardDidScrollToPoint)];
}

- (KeyboardDidScrollToPointBlock)keyboardDidScrollToPoint {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardWillChange:(KeyboardWillChangeBlock)keyboardWillChange {
    [self setAssociateCopyValue:keyboardWillChange withKey:@selector(keyboardWillChange)];
}

- (KeyboardWillChangeBlock)keyboardWillChange {
    return [self associatedValueForKey:_cmd];
}

- (void)setKeyboardView:(UIView *)keyboardView {
    [self setAssociateCopyValue:keyboardView withKey:@selector(keyboardView)];
}

- (UIView *)keyboardView {
    return [self associatedValueForKey:_cmd];
}

- (void)setPreviousKeyboardY:(CGFloat)previousKeyboardY {
    [self setAssociateValue:@(previousKeyboardY) withKey:@selector(previousKeyboardY)];
}

- (CGFloat)previousKeyboardY {
    return [[self associatedValueForKey:_cmd] CGFloatValue];
}

- (void)setMessageInputBarHeight:(CGFloat)messageInputBarHeight {
    [self setAssociateValue:@(messageInputBarHeight) withKey:@selector(messageInputBarHeight)];
}

- (CGFloat)messageInputBarHeight {
    return [[self associatedValueForKey:_cmd] CGFloatValue];
}

#pragma mark - :. Helper Method

+ (UIView *)findKeyboard {
    UIView *keyboardView = nil;
    NSArray *windows     = [[UIApplication sharedApplication] windows];
    for (UIWindow *window in [windows reverseObjectEnumerator]) //逆序效率更高，因为键盘总在上方
    {
        keyboardView = [self findKeyboardInView:window];
        if (keyboardView) {
            return keyboardView;
        }
    }
    return nil;
}

+ (UIView *)findKeyboardInView:(UIView *)view {
    for (UIView *subView in [view subviews]) {
        if (strstr(object_getClassName(subView), "UIKeyboard")) {
            return subView;
        } else {
            UIView *tempView = [self findKeyboardInView:subView];
            if (tempView) {
                return tempView;
            }
        }
    }
    return nil;
}

- (void)setupPanGestureControlKeyboardHide:(BOOL)isPanGestured {
    // 键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillShowKeyboardNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleWillHideKeyboardNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardWillShowHideNotification:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];

    if (isPanGestured)
        [self.panGestureRecognizer addTarget:self action:@selector(handlePanGesture:)];
}

- (void)disSetupPanGestureControlKeyboardHide:(BOOL)isPanGestured {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    if (isPanGestured)
        [self.panGestureRecognizer removeTarget:self action:@selector(handlePanGesture:)];
}

#pragma mark - :. Gestures

- (void)handlePanGesture:(UIPanGestureRecognizer *)pan {
    if (!self.keyboardView || self.keyboardView.hidden)
        return;

    CGRect screenRect    = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;

    UIWindow *panWindow = [[UIApplication sharedApplication] keyWindow];
    CGPoint location    = [pan locationInView:panWindow];
    location.y += self.messageInputBarHeight;
    CGPoint velocity = [pan velocityInView:panWindow];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.previousKeyboardY = self.keyboardView.frame.origin.y;
            break;
        case UIGestureRecognizerStateEnded:
            if (velocity.y > 0 && self.keyboardView.frame.origin.y > self.previousKeyboardY) {

                [UIView animateWithDuration:0.3
                    delay:0
                    options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        self.keyboardView.frame = CGRectMake(0.0f,
                                                             screenHeight,
                                                             self.keyboardView.frame.size.width,
                                                             self.keyboardView.frame.size.height);

                        if (self.keyboardWillBeDismissed) {
                            self.keyboardWillBeDismissed();
                        }
                    }
                    completion:^(BOOL finished) {
                        self.keyboardView.hidden = YES;
                        self.keyboardView.frame  = CGRectMake(0.0f,
                                                             self.previousKeyboardY,
                                                             self.keyboardView.frame.size.width,
                                                             self.keyboardView.frame.size.height);
                        [self resignFirstResponder];

                        if (self.keyboardDidHide) {
                            self.keyboardDidHide();
                        }
                    }];
            } else { // gesture ended with no flick or a flick upwards, snap keyboard back to original position
                [UIView animateWithDuration:0.2
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     if (self.keyboardWillSnapBackToPoint) {
                                         self.keyboardWillSnapBackToPoint(CGPointMake(0.0f, self.previousKeyboardY));
                                     }

                                     self.keyboardView.frame = CGRectMake(0.0f,
                                                                          self.previousKeyboardY,
                                                                          self.keyboardView.frame.size.width,
                                                                          self.keyboardView.frame.size.height);
                                 }
                                 completion:NULL];
            }
            break;

        // gesture is currently panning, match keyboard y to touch y
        default:
            if (location.y > self.keyboardView.frame.origin.y || self.keyboardView.frame.origin.y != self.previousKeyboardY) {

                CGFloat newKeyboardY = self.previousKeyboardY + (location.y - self.previousKeyboardY);
                newKeyboardY         = newKeyboardY < self.previousKeyboardY ? self.previousKeyboardY : newKeyboardY;
                newKeyboardY         = newKeyboardY > screenHeight ? screenHeight : newKeyboardY;

                self.keyboardView.frame = CGRectMake(0.0f,
                                                     newKeyboardY,
                                                     self.keyboardView.frame.size.width,
                                                     self.keyboardView.frame.size.height);

                if (self.keyboardDidScrollToPoint) {
                    self.keyboardDidScrollToPoint(CGPointMake(0.0f, newKeyboardY));
                }
            }
            break;
    }
}

#pragma mark - :. Keyboard notifications

- (void)handleKeyboardWillShowHideNotification:(NSNotification *)notification {
    BOOL didShowed = YES;
    if ([notification.name isEqualToString:UIKeyboardDidShowNotification]) {
        self.keyboardView        = [UIScrollView findKeyboard].superview;
        self.keyboardView.hidden = NO;
        didShowed                = YES;
    } else if ([notification.name isEqualToString:UIKeyboardDidHideNotification]) {
        didShowed                = NO;
        self.keyboardView.hidden = NO;
        [self resignFirstResponder];
    }
    if (self.keyboardDidChange) {
        self.keyboardDidChange(didShowed);
    }
}

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification {
    self.keyboardView.hidden = NO;
    [self keyboardWillShowHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification {
    [self keyboardWillShowHide:notification];
}

- (void)keyboardWillShowHide:(NSNotification *)notification {
    CGRect keyboardRect        = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIViewAnimationCurve curve = [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval duration            = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    if (self.keyboardWillChange) {
        self.keyboardWillChange(keyboardRect, UIViewAnimationCurveToAnimationOptions(curve), duration, (([notification.name isEqualToString:UIKeyboardWillShowNotification]) ? YES : NO));
    }
}

- (void)snapshotImageWithBlock:(void(^)(UIImage *))block {
    if (!block) return;
    
    //保存offset
    CGPoint oldContentOffset = self.contentOffset;
    //保存frame
    CGRect oldFrame = self.frame;
    
    if (self.contentSize.height > self.frame.size.height) {
        self.contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    }
    self.frame = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    //延迟0.3秒，避免有时候渲染不出来的情况
    [NSThread sleepForTimeInterval:0.3];
    
    self.contentOffset = CGPointZero;
    UIImage *snapshotImage = self.snapshotImage;
    
    self.frame = oldFrame;
    //还原
    self.contentOffset = oldContentOffset;

    !block ?: block(snapshotImage);
}

#pragma mark - :. 解决手势返回和scrollView的冲突

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [self __kai_interactivePopEnable:gestureRecognizer];
}

//location_X可自己定义,其代表的是滑动返回距左边的有效长度
- (BOOL)__kai_interactivePopEnable:(UIGestureRecognizer *)gestureRecognizer {
    //是滑动返回距左边的有效长度
    int location_X = ZKScreenSize().width * 0.15;
    if (gestureRecognizer == self.panGestureRecognizer) {
        UIPanGestureRecognizer *pan    = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point                  = [pan translationInView:self];
        UIGestureRecognizerState state = gestureRecognizer.state;
        if (UIGestureRecognizerStateBegan == state || UIGestureRecognizerStatePossible == state) {
            CGPoint location = [gestureRecognizer locationInView:self];

            //这是允许每张图片都可实现滑动返回
            int temp1    = location.x;
            int temp2    = ZKScreenSize().width;
            NSInteger XX = temp1 % temp2;
            return (point.x > 0 && XX < location_X);
        }
    }
    return NO;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return ![self __kai_interactivePopEnable:gestureRecognizer];
}

@end

