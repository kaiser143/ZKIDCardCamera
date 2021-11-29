//
//  NSError+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "NSError+ZKAdd.h"

@implementation NSError (ZKAdd)

+ (NSError *)errorWithDomain:(NSString *)domain
                        code:(NSInteger)code
                 description:(NSString *)description {

    NSError *result = [NSError errorWithDomain:domain
                                          code:code
                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 description, NSLocalizedDescriptionKey,
                                                                 nil]];
    return result;
}

+ (NSError *)errorWithDomain:(NSString *)domain
                        code:(NSInteger)code
                 description:(NSString *)description
               failureReason:(NSString *)failureReason {

    NSError *result = [NSError errorWithDomain:domain
                                          code:code
                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                 description, NSLocalizedDescriptionKey,
                                                                 failureReason, NSLocalizedFailureReasonErrorKey,
                                                                 nil]];
    return result;
}

@end
