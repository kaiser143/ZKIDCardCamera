//
//  ZKUnicode.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "ZKUnicode.h"
#import "NSObject+ZKAdd.h"

@implementation NSString (ZKAddForUnicode)

- (NSString *)stringByReplaceUnicode {
    NSMutableString *convertedString = [self mutableCopy];

    [convertedString replaceOccurrencesOfString:@"\\U"
                                     withString:@"\\u"
                                        options:0
                                          range:NSMakeRange(0, convertedString.length)];

    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    return convertedString;
}

@end

@implementation NSArray (ZKAddForUnicode)

+ (void)load {
    [self swizzleMethod:@selector(description) withMethod:@selector(_kai_description)];
    [self swizzleMethod:@selector(descriptionWithLocale:) withMethod:@selector(_kai_descriptionWithLocale:)];
    [self swizzleMethod:@selector(descriptionWithLocale:indent:) withMethod:@selector(_kai_descriptionWithLocale:indent:)];
}

- (NSString *)_kai_description {
    return [[self _kai_description] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale {
    return [[self _kai_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self _kai_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSDictionary (ZKAddForUnicode)

+ (void)load {
    [self swizzleMethod:@selector(description) withMethod:@selector(_kai_description)];
    [self swizzleMethod:@selector(descriptionWithLocale:) withMethod:@selector(_kai_descriptionWithLocale:)];
    [self swizzleMethod:@selector(descriptionWithLocale:indent:) withMethod:@selector(_kai_descriptionWithLocale:indent:)];
}

- (NSString *)_kai_description {
    return [[self _kai_description] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale {
    return [[self _kai_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self _kai_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end

@implementation NSSet (ZKAddForUnicode)

+ (void)load {
    [self swizzleMethod:@selector(description) withMethod:@selector(_kai_description)];
    [self swizzleMethod:@selector(descriptionWithLocale:) withMethod:@selector(_kai_descriptionWithLocale:)];
    [self swizzleMethod:@selector(descriptionWithLocale:indent:) withMethod:@selector(_kai_descriptionWithLocale:indent:)];
}

- (NSString *)_kai_description {
    return [[self _kai_description] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale {
    return [[self _kai_descriptionWithLocale:locale] stringByReplaceUnicode];
}

- (NSString *)_kai_descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level {
    return [[self _kai_descriptionWithLocale:locale indent:level] stringByReplaceUnicode];
}

@end
