//
//  UIResponder+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/5/18.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIResponder+ZKAdd.h"

static __weak id ___currentFirstResponder;

@implementation UIResponder (ZKAdd)

/**
 Based on Jakob Egger's answer in http://stackoverflow.com/a/14135456/590010
 */
+ (instancetype)currentFirstResponder {
    ___currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(findFirstResponder:) to:nil from:nil forEvent:nil];
    
    return ___currentFirstResponder;
}

- (void)findFirstResponder:(id)sender {
    ___currentFirstResponder = self;
}

- (void)sendEventWithName:(NSString *)eventName userInfo:(id)userInfo {
    [self.nextResponder dispatchEventWithName:eventName userInfo:userInfo];
}

- (void)dispatchEventWithName:(NSString *)eventName userInfo:(id)userInfo {
    BOOL shouldDispatchToNextResponder = [self responderDidReceiveEvent:eventName userInfo:userInfo];
    if (shouldDispatchToNextResponder) {
        [self.nextResponder dispatchEventWithName:eventName userInfo:userInfo];
    }
}

- (BOOL)responderDidReceiveEvent:(NSString *)eventName userInfo:(id)userInfo {
    return YES;
}

- (NSString *)responderChainDescription {
    NSMutableArray *responderChainStrings = [NSMutableArray array];
    [responderChainStrings addObject:[self class]];
    UIResponder *nextResponder = self;
    while ((nextResponder = [nextResponder nextResponder])) {
        [responderChainStrings addObject:[nextResponder class]];
    }
    __block NSString *returnString = @"Responder Chain:\n";
    __block int tabCount = 0;
    [responderChainStrings enumerateObjectsWithOptions:NSEnumerationReverse
                                            usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                                if (tabCount) {
                                                    returnString = [returnString stringByAppendingString:@"|"];
                                                    for (int i = 0; i < tabCount; i++) {
                                                        returnString = [returnString stringByAppendingString:@"----"];
                                                    }
                                                    returnString = [returnString stringByAppendingString:@" "];
                                                }
                                                else {
                                                    returnString = [returnString stringByAppendingString:@"| "];
                                                }
                                                returnString = [returnString stringByAppendingFormat:@"%@ (%@)\n", obj, @(idx)];
                                                tabCount++;
                                            }];
    return returnString;
}

@end
