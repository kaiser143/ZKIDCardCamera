//
//  UIView+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/10/12.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (ZKAdd)

/**
 * Finds the first descendant view (including this view) that is a member of a particular class.
 */
- (nullable __kindof UIView *)descendantOrSelfWithClass:(Class)cls;

/**
 * Finds the first ancestor view (including this view) that is a member of a particular class.
 */
- (nullable __kindof UIView *)ancestorOrSelfWithClass:(Class)cls;

/**
 Create a snapshot image of the complete view hierarchy.
 */
- (nullable UIImage *)snapshotImage;

/**
 Create a snapshot image of the complete view hierarchy.
 @discussion It's faster than "snapshotImage", but may cause screen updates.
 See -[UIView drawViewHierarchyInRect:afterScreenUpdates:] for more information.
 */
- (nullable UIImage *)snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

/**
 Create a snapshot PDF of the complete view hierarchy.
 */
- (nullable NSData *)snapshotPDF;

/**
 Shortcut to set the view.layer's shadow
 
 @param color  Shadow Color
 @param offset Shadow offset
 @param radius Shadow radius
 */
- (void)setLayerShadow:(nullable UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 Remove all subviews.
 
 @warning Never call this method inside your view's drawRect: method.
 */
- (void)removeAllSubviews;

/**
 Returns the view's view controller (may be nil).
 */
@property (nullable, nonatomic, readonly) UIViewController *viewController;

/**
 Returns the visible alpha on screen, taking into account superview and window.
 */
@property (nonatomic, readonly) CGFloat visibleAlpha;

/**
 Converts a point from the receiver's coordinate system to that of the specified view or window.
 
 @param point A point specified in the local coordinate system (bounds) of the receiver.
 @param view  The view or window into whose coordinate system point is to be converted.
 If view is nil, this method instead converts to window base coordinates.
 @return The point converted to the coordinate system of view.
 */
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;

/**
 Converts a point from the coordinate system of a given view or window to that of the receiver.
 
 @param point A point specified in the local coordinate system (bounds) of view.
 @param view  The view or window with point in its coordinate system.
 If view is nil, this method instead converts from window base coordinates.
 @return The point converted to the local coordinate system (bounds) of the receiver.
 */
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;

/**
 Converts a rectangle from the receiver's coordinate system to that of another view or window.
 
 @param rect A rectangle specified in the local coordinate system (bounds) of the receiver.
 @param view The view or window that is the target of the conversion operation. If view is nil, this method instead converts to window base coordinates.
 @return The converted rectangle.
 */
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;

/**
 Converts a rectangle from the coordinate system of another view or window to that of the receiver.
 
 @param rect A rectangle specified in the local coordinate system (bounds) of view.
 @param view The view or window with rect in its coordinate system.
 If view is nil, this method instead converts from window base coordinates.
 @return The converted rectangle.
 */
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;

@property (nonatomic) CGFloat left;    ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;     ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;   ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;  ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;   ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;  ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX; ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY; ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;  ///< Shortcut for frame.origin.
@property (nonatomic) CGSize size;     ///< Shortcut for frame.size.

@property (nonatomic, copy) void(^didSubviewLayoutBlock)(UIView *view);

@end

@interface UIView (ZKActionHandlers)

/**
 Attaches the given block for a single tap action to the receiver.
 @param block The block to execute.
 */
- (void)setTapActionWithBlock:(void (^)(void))block;

/**
 Attaches the given block for a long press action to the receiver.
 @param block The block to execute.
 */
- (void)setLongPressActionWithBlock:(void (^)(void))block;

@end

@interface UIView (ZKDebug)

/**
@name Main Thread Checking
*/

/**
 Toggles on/off main thread checking on several methods of UIView.
 
 Currently the following methods are swizzeled and checked:
 
 - setNeedsDisplay
 - setNeedsDisplayInRect:
 - setNeedsLayout
 
 Those are triggered by a variety of methods in UIView, e.g. setBackgroundColor and thus it is not necessary to swizzle all of them.
 */
+ (void)toggleViewMainThreadChecking;

/**
 Method that gets called if one of the important methods of UIView is not being called on a main queue.
 
 Toggle this on/off with <toggleViewMainThreadChecking>. Break on -[UIView methodCalledNotFromMainThread:] to catch it in debugger.
 @param methodName Symbolic name of the method being called
 */
- (void)methodCalledNotFromMainThread:(NSString *)methodName;

@end

@interface UIView (ZKAutoLayout)

/**
 Animates the view's constraints by calling layoutIfNeeded.
 
 @param bounce YES if the animation should use spring damping and velocity to give a bouncy effect to animations.
 @param options A mask of options indicating how you want to perform the animations.
 @param animations An additional block for custom animations.
 */
- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^__nullable)(void))animations;

- (void)animateLayoutIfNeededWithBounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^__nullable)(BOOL finished))completion;

/**
 Animates the view's constraints by calling layoutIfNeeded.
 
 @param duration The total duration of the animations, measured in seconds.
 @param bounce YES if the animation should use spring damping and velocity to give a bouncy effect to animations.
 @param options A mask of options indicating how you want to perform the animations.
 @param animations An additional block for custom animations.
 */
- (void)animateLayoutIfNeededWithDuration:(NSTimeInterval)duration bounce:(BOOL)bounce options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

/**
 Returns the view constraints matching a specific layout attribute (top, bottom, left, right, leading, trailing, etc.)
 
 @param attribute The layout attribute to use for searching.
 @return An array of matching constraints.
 */
- (nullable NSArray *)constraintsForAttribute:(NSLayoutAttribute)attribute;

/**
 Returns a layout constraint matching a specific layout attribute and relationship between 2 items, first and second items.
 
 @param attribute The layout attribute to use for searching.
 @param first The first item in the relationship.
 @param second The second item in the relationship.
 @return A layout constraint.
 */
- (nullable NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute firstItem:(id __nullable)first secondItem:(id __nullable)second;

@end


/*
 * @code
 - (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self loadContentsFromNib];
        [self awakeFromNib];
    }
    
    return self;
 }
 * @code
 */
@interface UIView (ZKNibLoading)

- (void)loadContentsFromNibNamed:(NSString *)nibName bundle:(NSBundle *)bundle;
- (void)loadContentsFromNibNamed:(NSString *)nibName;

// Convenience method, loads a nib named after the class name.
- (void)loadContentsFromNib;

// View where all content from nib will be added.
- (UIView *)contentViewForNib;

@end

NS_ASSUME_NONNULL_END


#if __has_include("Masonry.h") || __has_include(<Masonry/Masonry.h>)

#if __has_include(<Masonry/Masonry.h>)
    #import <Masonry/Masonry.h>
#else
    #import "Masonry.h"
#endif

@interface UIView (Masonry)

- (id _Nonnull)kai_safeAreaLayoutGuideTop;
- (id _Nonnull)kai_safeAreaLayoutGuideBottom;
- (id _Nonnull)kai_safeAreaLayoutGuideLeft;
- (id _Nonnull)kai_safeAreaLayoutGuideRight;

@end

#endif
