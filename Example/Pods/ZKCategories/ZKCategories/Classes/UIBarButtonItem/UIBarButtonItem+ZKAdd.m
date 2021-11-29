//
//  UIBarButtonItem+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/9/26.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UIBarButtonItem+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface _KAIBarButtonItemBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);

- (id)initWithBlock:(void (^)(id sender))block;
- (void)invoke:(id)sender;

@end

@implementation _KAIBarButtonItemBlockTarget

- (id)initWithBlock:(void (^)(id sender))block {
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    if (self.block) self.block(sender);
}

@end

@implementation UIBarButtonItem (ZKAdd)

+ (instancetype)itemWithImage:(UIImage *)image target:(id)target action:(SEL)action {
    return [[self alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:target action:action];
}

- (void)setActionBlock:(void (^)(id sender))block {
    _KAIBarButtonItemBlockTarget *target = [[_KAIBarButtonItemBlockTarget alloc] initWithBlock:block];
    [self setAssociateValue:target withKey:_cmd];

    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

- (void (^)(id))actionBlock {
    _KAIBarButtonItemBlockTarget *target = [self associatedValueForKey:@selector(setActionBlock:)];
    return target.block;
}

@end
