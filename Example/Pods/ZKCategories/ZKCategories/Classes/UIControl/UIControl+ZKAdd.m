//
//  UIControl+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIControl+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface _KAIUIControlBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _KAIUIControlBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block  = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end

@interface UIControl ()

/// 是否执行点UI方法，YES: 不允许点击  NO:允许点击
@property (nonatomic, assign, getter=isIgnoreEvent) BOOL ignoreEvent;

@end

@implementation UIControl (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(sendAction:to:forEvent:) withMethod:@selector(kai_sendAction:to:forEvent:)];
}

- (void)removeAllTargets {
    [[self allTargets] enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        [self removeTarget:object action:NULL forControlEvents:UIControlEventAllEvents];
    }];
    [[self kai_allUIControlBlockTargets] removeAllObjects];
}

- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents {
    if (!target || !action || !controlEvents) return;
    NSSet *targets = [self allTargets];
    for (id currentTarget in targets) {
        NSArray *actions = [self actionsForTarget:currentTarget forControlEvent:controlEvents];
        for (NSString *currentAction in actions) {
            [self removeTarget:currentTarget
                          action:NSSelectorFromString(currentAction)
                forControlEvents:controlEvents];
        }
    }
    [self addTarget:target action:action forControlEvents:controlEvents];
}

- (void)addBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(__kindof UIControl *sender))block {
    if (!controlEvents) return;
    _KAIUIControlBlockTarget *target = [[_KAIUIControlBlockTarget alloc] initWithBlock:block events:controlEvents];
    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self kai_allUIControlBlockTargets];
    [targets addObject:target];
}

- (void)setBlockForControlEvents:(UIControlEvents)controlEvents
                           block:(void (^)(__kindof UIControl *sender))block {
    [self removeAllBlocksForControlEvents:UIControlEventAllEvents];
    [self addBlockForControlEvents:controlEvents block:block];
}

- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents {
    if (!controlEvents) return;

    NSMutableArray *targets = [self kai_allUIControlBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_KAIUIControlBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)kai_allUIControlBlockTargets {
    NSMutableArray *targets = [self associatedValueForKey:_cmd];
    if (!targets) {
        targets = [NSMutableArray array];
        [self setAssociateValue:targets withKey:_cmd];
    }
    return targets;
}

- (void)setAcceptEventInterval:(NSTimeInterval)timeInterval {
    [self setAssociateValue:@(timeInterval) withKey:@selector(acceptEventInterval)];
}

- (NSTimeInterval)acceptEventInterval {
    NSNumber *interval = [self associatedValueForKey:_cmd];
    return interval ? interval.doubleValue : 0.5;
}

- (void)setIgnore:(BOOL)ignore {
    [self setAssociateValue:@(ignore) withKey:@selector(isIgnore)];
}

- (BOOL)isIgnore {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setIgnoreEvent:(BOOL)ignoreEvent {
    [self setAssociateValue:@(ignoreEvent) withKey:@selector(isIgnoreEvent)];
}

- (BOOL)isIgnoreEvent {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)kai_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event {
    if (self.isIgnore) {
        [self kai_sendAction:action to:target forEvent:event];
        return;
    }

    NSString *controlName = NSStringFromClass(self.class);
    if ([controlName isEqualToString:@"UIButton"] || [controlName isEqualToString:@"UINavigationButton"]) {
        if (self.isIgnoreEvent) {
            return;
        } else if (self.acceptEventInterval > 0) {
            [self performSelector:@selector(resetState) withObject:nil afterDelay:self.acceptEventInterval];
        }
    }
    // 此处 methodA和methodB方法IMP互换了，实际上执行 sendAction；所以不会死循环
    self.ignoreEvent = YES;
    [self kai_sendAction:action to:target forEvent:event];
}

- (void)resetState {
    self.ignoreEvent = NO;
}

@end
