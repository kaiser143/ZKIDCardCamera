//
//  UIView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIView+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@implementation UIView (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(_kai_layoutSubviews)];
}

- (UIView *)descendantOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls])
        return self;

    for (UIView *child in self.subviews) {
        UIView *it = [child descendantOrSelfWithClass:cls];
        if (it)
            return it;
    }

    return nil;
}

- (UIView *)ancestorOrSelfWithClass:(Class)cls {
    if ([self isKindOfClass:cls]) {
        return self;

    } else if (self.superview) {
        return [self.superview ancestorOrSelfWithClass:cls];

    } else {
        return nil;
    }
}

- (UIImage *)snapshotImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates {
    if (![self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        return [self snapshotImage];
    }
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:afterUpdates];
    UIImage *snap = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snap;
}

- (NSData *)snapshotPDF {
    CGRect bounds              = self.bounds;
    NSMutableData *data        = [NSMutableData data];
    CGDataConsumerRef consumer = CGDataConsumerCreateWithCFData((__bridge CFMutableDataRef)data);
    CGContextRef context       = CGPDFContextCreate(consumer, &bounds, NULL);
    CGDataConsumerRelease(consumer);
    if (!context) return nil;
    CGPDFContextBeginPage(context, NULL);
    CGContextTranslateCTM(context, 0, bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [self.layer renderInContext:context];
    CGPDFContextEndPage(context);
    CGPDFContextClose(context);
    CGContextRelease(context);
    return data;
}

- (void)setLayerShadow:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius {
    self.layer.shadowColor        = color.CGColor;
    self.layer.shadowOffset       = offset;
    self.layer.shadowRadius       = radius;
    self.layer.shadowOpacity      = 1;
    self.layer.shouldRasterize    = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (void)removeAllSubviews {
    //[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    while (self.subviews.count) {
        [self.subviews.lastObject removeFromSuperview];
    }
}

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)visibleAlpha {
    if ([self isKindOfClass:[UIWindow class]]) {
        if (self.hidden) return 0;
        return self.alpha;
    }
    if (!self.window) return 0;
    CGFloat alpha = 1;
    UIView *v     = self;
    while (v) {
        if (v.hidden) {
            alpha = 0;
            break;
        }
        alpha *= v.alpha;
        v = v.superview;
    }
    return alpha;
}

- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point toWindow:nil];
        } else {
            return [self convertPoint:point toView:nil];
        }
    }

    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to   = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point toView:view];
    point = [self convertPoint:point toView:from];
    point = [to convertPoint:point fromWindow:from];
    point = [view convertPoint:point fromView:to];
    return point;
}

- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertPoint:point fromWindow:nil];
        } else {
            return [self convertPoint:point fromView:nil];
        }
    }

    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to   = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertPoint:point fromView:view];
    point = [from convertPoint:point fromView:view];
    point = [to convertPoint:point fromWindow:from];
    point = [self convertPoint:point fromView:to];
    return point;
}

- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect toWindow:nil];
        } else {
            return [self convertRect:rect toView:nil];
        }
    }

    UIWindow *from = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    UIWindow *to   = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    if (!from || !to) return [self convertRect:rect toView:view];
    if (from == to) return [self convertRect:rect toView:view];
    rect = [self convertRect:rect toView:from];
    rect = [to convertRect:rect fromWindow:from];
    rect = [view convertRect:rect fromView:to];
    return rect;
}

- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(UIView *)view {
    if (!view) {
        if ([self isKindOfClass:[UIWindow class]]) {
            return [((UIWindow *)self) convertRect:rect fromWindow:nil];
        } else {
            return [self convertRect:rect fromView:nil];
        }
    }

    UIWindow *from = [view isKindOfClass:[UIWindow class]] ? (id)view : view.window;
    UIWindow *to   = [self isKindOfClass:[UIWindow class]] ? (id)self : self.window;
    if ((!from || !to) || (from == to)) return [self convertRect:rect fromView:view];
    rect = [from convertRect:rect fromView:view];
    rect = [to convertRect:rect fromWindow:from];
    rect = [self convertRect:rect fromView:to];
    return rect;
}

- (CGFloat)left {
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
    CGRect frame   = self.frame;
    frame.origin.x = x;
    self.frame     = frame;
}

- (CGFloat)top {
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
    CGRect frame   = self.frame;
    frame.origin.y = y;
    self.frame     = frame;
}

- (CGFloat)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
    CGRect frame   = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame     = frame;
}

- (CGFloat)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
    CGRect frame   = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame     = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame     = self.frame;
    frame.size.width = width;
    self.frame       = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame      = self.frame;
    frame.size.height = height;
    self.frame        = frame;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame   = frame;
}

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size   = size;
    self.frame   = frame;
}

- (void)setDidSubviewLayoutBlock:(void (^)(UIView * _Nonnull))didSubviewLayoutBlock {
    [self setAssociateValue:didSubviewLayoutBlock withKey:@selector(didSubviewLayoutBlock)];
}

- (void (^)(UIView * _Nonnull))didSubviewLayoutBlock {
    return [self associatedValueForKey:_cmd];
}

- (void)_kai_layoutSubviews {
    [self _kai_layoutSubviews];
    
    !self.didSubviewLayoutBlock ?: self.didSubviewLayoutBlock(self);
}

@end

@implementation UIView (ZKActionHandlers)

- (void)setTapActionWithBlock:(void (^)(void))block {
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [self associatedValueForKey:_cmd];

    if (!gesture) {
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_handleActionForTapGesture:)];
        [self addGestureRecognizer:gesture];
        [self setAssociateValue:gesture withKey:_cmd];
    }

    [self setAssociateCopyValue:block withKey:@selector(_handleActionForTapGesture:)];
}

- (void)_handleActionForTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        void (^action)(void) = [self associatedValueForKey:_cmd];
        if (action) {
            action();
        }
    }
}

- (void)setLongPressActionWithBlock:(void (^)(void))block {
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *gesture = [self associatedValueForKey:_cmd];

    if (!gesture) {
        gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_handleActionForLongPressGesture:)];
        [self addGestureRecognizer:gesture];
        [self setAssociateValue:gesture withKey:_cmd];
    }

    [self setAssociateCopyValue:block withKey:@selector(_handleActionForLongPressGesture:)];
}

- (void)_handleActionForLongPressGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        void (^action)(void) = [self associatedValueForKey:_cmd];

        if (action) {
            action();
        }
    }
}

@end

@implementation UIView (ZKDebug)

- (void)methodCalledNotFromMainThread:(NSString *)methodName {
    NSLog(@"-[%@ %@] being called on background queue. Break on %s to find out where", NSStringFromClass([self class]), methodName, __PRETTY_FUNCTION__);
}

- (void)_setNeedsLayout_MainThreadCheck {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }

    // not really an endless loop, this calls the original
    [self _setNeedsLayout_MainThreadCheck];
}

- (void)_setNeedsDisplay_MainThreadCheck {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }

    // not really an endless loop, this calls the original
    [self _setNeedsDisplay_MainThreadCheck];
}

- (void)_setNeedsDisplayInRect_MainThreadCheck:(CGRect)rect {
    if (![NSThread isMainThread]) {
        [self methodCalledNotFromMainThread:NSStringFromSelector(_cmd)];
    }

    // not really an endless loop, this calls the original
    [self _setNeedsDisplayInRect_MainThreadCheck:rect];
}

+ (void)toggleViewMainThreadChecking {
    [UIView swizzleMethod:@selector(setNeedsLayout) withMethod:@selector(_setNeedsLayout_MainThreadCheck)];
    [UIView swizzleMethod:@selector(setNeedsDisplay) withMethod:@selector(_setNeedsDisplay_MainThreadCheck)];
    [UIView swizzleMethod:@selector(setNeedsDisplayInRect:) withMethod:@selector(_setNeedsDisplayInRect_MainThreadCheck:)];
}

@end

@implementation UIView (ZKAutoLayout)

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations {
    [self animateLayoutIfNeededWithBounce:bounce options:options animations:animations completion:NULL];
}

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    NSTimeInterval duration = bounce ? 0.65 : 0.2;
    [self animateLayoutIfNeededWithDuration:duration bounce:bounce options:options animations:animations completion:completion];
}

- (void)animateLayoutIfNeededWithDuration:(NSTimeInterval)duration bounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion {
    if (bounce) {
        [UIView animateWithDuration:duration
                              delay:0.0
             usingSpringWithDamping:0.7
              initialSpringVelocity:0.7
                            options:options
                         animations:^{
                             [self layoutIfNeeded];

                             if (animations) {
                                 animations();
                             }
                         }
                         completion:completion];
    } else {
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:options
                         animations:^{
                             [self layoutIfNeeded];

                             if (animations) {
                                 animations();
                             }
                         }
                         completion:completion];
    }
}

- (NSArray *)constraintsForAttribute:(NSLayoutAttribute)attribute {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d", attribute];
    return [self.constraints filteredArrayUsingPredicate:predicate];
}

- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id)first secondItem:(id)second {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstAttribute = %d AND firstItem = %@ AND secondItem = %@", attribute, first, second];
    return [[self.constraints filteredArrayUsingPredicate:predicate] firstObject];
}

@end

static char ZKNibLoadingAssociatedNibsKey;
static char ZKNibLoadingOutletsKey;

@implementation UIView (ZKNibLoading)

+ (UINib *)_kai_nibLoadingAssociatedNibWithName:(NSString *)nibName bundle:(NSBundle *)bundle {
    NSDictionary *associatedNibs = [self associatedValueForKey:&ZKNibLoadingAssociatedNibsKey];
    UINib *nib = associatedNibs[nibName];
    if (!nib) {
        nib = [UINib nibWithNibName:nibName bundle:bundle];
        if (nib) {
            NSMutableDictionary *newNibs = [NSMutableDictionary dictionaryWithDictionary:associatedNibs];
            newNibs[nibName] = nib;
            [self setAssociateValue:[NSDictionary dictionaryWithDictionary:newNibs] withKey:&ZKNibLoadingAssociatedNibsKey];
        }
    }
    
    return nib;
}

- (UIView *)contentViewForNib {
    return self;
}

- (void)loadContentsFromNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle {
    // Load the nib file, setting self as the owner.
    // The root view is only a container and is discarded after loading.
    UINib *nib = [[self class] _kai_nibLoadingAssociatedNibWithName:nibName bundle:bundle];
    NSAssert(nib != nil, @"UIView+ZKNibLoading : Can't load nib named %@.", nibName);
    
    // Instantiate (and keep a list of the outlets set through KVC.)
    NSMutableDictionary *outlets = [NSMutableDictionary new];
    [self setAssociateValue:outlets withKey:&ZKNibLoadingOutletsKey];
    
    NSArray *views = [nib instantiateWithOwner:self options:nil];
    NSAssert(views != nil, @"UIView+ZKNibLoading : Can't instantiate nib named %@.", nibName);
    
    [self setAssociateValue:nil withKey:&ZKNibLoadingOutletsKey];
    
    // Search for the first encountered UIView base object
    UIView *containerView = nil;
    for (id v in views) {
        if ([v isKindOfClass:[UIView class]]) {
            containerView = v;
            break;
        }
    }
    NSAssert(containerView != nil, @"UIView+ZKNibLoading : There is no container UIView found at the root of nib %@.", nibName);
    
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if (CGRectEqualToRect(self.bounds, CGRectZero)) {
        // `self` has no size : use the containerView's size, from the nib file
        self.bounds = containerView.bounds;
    } else {
        // `self` has a specific size : resize the containerView to this size, so that the subviews are autoresized.
        containerView.bounds = self.bounds;
    }
    
    // Save constraints for later
    NSArray *constraints = containerView.constraints;
    
    // reparent the subviews from the nib file
    for (UIView *view in containerView.subviews) {
        if (view.superview) {
            [view removeFromSuperview];
        }
        [[self contentViewForNib] addSubview:view];
    }
    
    // Recreate constraints, replace containerView with self
    for (NSLayoutConstraint *oldConstraint in constraints) {
        id firstItem = oldConstraint.firstItem;
        id secondItem = oldConstraint.secondItem;
        if (firstItem == containerView) {
            firstItem = [self contentViewForNib];
        }
        if (secondItem == containerView) {
            secondItem = [self contentViewForNib];
        }
        
        NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:firstItem
                                                                         attribute:oldConstraint.firstAttribute
                                                                         relatedBy:oldConstraint.relation
                                                                            toItem:secondItem
                                                                         attribute:oldConstraint.secondAttribute
                                                                        multiplier:oldConstraint.multiplier
                                                                          constant:oldConstraint.constant];
        [self addConstraint:newConstraint];
        
        // If there was outlet(s) to the old constraint, replace it with the new constraint.
        for (NSString *key in outlets) {
            if (outlets[key] == oldConstraint) {
                NSAssert([self valueForKey:key] == oldConstraint, @"UIView+ZKNibLoading : Unexpected value for outlet %@ of view %@. Expected %@, found %@.", key, self, oldConstraint, [self valueForKey:key]);
                [self setValue:newConstraint forKey:key];
            }
        }
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    // Keep a list of the outlets set during nib loading.
    // (See above: This associated object only exists during nib-loading)
    NSMutableDictionary *outlets = [self associatedValueForKey:&ZKNibLoadingOutletsKey];
    outlets[key] = value;
    [super setValue:value forKey:key];
}

- (void)loadContentsFromNibNamed:(NSString *)nibName {
    [self loadContentsFromNibNamed:nibName bundle:[NSBundle bundleForClass:self.class]];
}

- (void)loadContentsFromNib {
    NSString *className = self.className;
    
    // A Swift class name will be in the format of ModuleName.ClassName
    // We want to remove the module name so the Nib can have exactly the same file name as the class
    NSRange range = [className rangeOfString:@"."];
    if (range.location != NSNotFound) {
        className = [className substringFromIndex:range.location + range.length];
    }
    [self loadContentsFromNibNamed:className];
}

@end


@implementation UIView (Masonry)

- (id)kai_safeAreaLayoutGuideTop {
    if (@available(iOS 11.0, *)) {
        return [self safePerform:NSSelectorFromString(@"mas_safeAreaLayoutGuideTop")];
    } else {
        return [self safePerform:NSSelectorFromString(@"mas_top")];
    }
}

- (id)kai_safeAreaLayoutGuideBottom {
    if (@available(iOS 11.0, *)) {
        return [self safePerform:NSSelectorFromString(@"mas_safeAreaLayoutGuideBottom")];
    } else {
        return [self safePerform:NSSelectorFromString(@"mas_bottom")];
    }
}

- (id)kai_safeAreaLayoutGuideLeft {
    if (@available(iOS 11.0, *)) {
        return [self safePerform:NSSelectorFromString(@"mas_safeAreaLayoutGuideLeft")];
    } else {
        return [self safePerform:NSSelectorFromString(@"mas_left")];
    }
}

- (id)kai_safeAreaLayoutGuideRight {
    if (@available(iOS 11.0, *)) {
        return [self safePerform:NSSelectorFromString(@"mas_safeAreaLayoutGuideRight")];
    } else {
        return [self safePerform:NSSelectorFromString(@"mas_right")];
    }
}

@end

