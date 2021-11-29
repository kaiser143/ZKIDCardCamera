//
//  UIControl+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (ZKAdd)

/**
 Removes all targets and actions for a particular event (or events)
 from an internal dispatch table.
 */
- (void)removeAllTargets;

/**
 Adds or replaces a target and action for a particular event (or events)
 to an internal dispatch table.
 
 @param target         The target object—that is, the object to which the
 action message is sent. If this is nil, the responder
 chain is searched for an object willing to respond to the
 action message.
 
 @param action         A selector identifying an action message. It cannot be NULL.
 
 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 Adds a block for a particular event (or events) to an internal dispatch table.
 It will cause a strong reference to @a block.
 
 @param block          The block which is invoked then the action message is
 sent  (cannot be nil). The block is retained.
 
 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 Adds or replaces a block for a particular event (or events) to an internal
 dispatch table. It will cause a strong reference to @a block.
 
 @param block          The block which is invoked then the action message is
 sent (cannot be nil). The block is retained.
 
 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(__kindof UIControl *sender))block;

/**
 Removes all blocks for a particular event (or events) from an internal
 dispatch table.
 
 @param controlEvents  A bitmask specifying the control events for which the
 action message is sent.
 */
- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

/// 设置点击时间间隔，默认时间间隔0.5
@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

/// 是否忽略时间间隔
@property (nonatomic, assign, getter=isIgnore) BOOL ignore;

@end

NS_ASSUME_NONNULL_END
