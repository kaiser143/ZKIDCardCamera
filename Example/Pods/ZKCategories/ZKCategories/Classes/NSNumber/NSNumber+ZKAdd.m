//
//  NSNumber+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/22.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "NSNumber+ZKAdd.h"
#import "NSString+ZKAdd.h"

@implementation NSNumber (ZKAdd)

- (CGFloat)CGFloatValue {
#if (CGFLOAT_IS_DOUBLE == 1)
    CGFloat result = [self doubleValue];
#else
    CGFloat result = [self floatValue];
#endif
    return result;
}

- (instancetype)initWithValue:(CGFloat)value {
#if (CGFLOAT_IS_DOUBLE == 1)
    self = [self initWithDouble:value];
#else
    self = [self initWithFloat:value];
#endif
    return self;
}

+ (NSNumber *)numberWithValue:(CGFloat)value {
    NSNumber *returnValue = [[NSNumber alloc] initWithValue:value];
    return returnValue;
}

- (NSString *)stringWithDecimals:(NSInteger)decimals {
    NSNumberFormatter *formatter    = NSNumberFormatter.new;
    formatter.locale                = [NSLocale currentLocale];
    formatter.maximumFractionDigits = decimals;
    formatter.minimumFractionDigits = decimals;
    formatter.minimumIntegerDigits  = 1;
    return [formatter stringFromNumber:self];
}

- (NSString *)formatterWithNumberStyle:(NSNumberFormatterStyle)style {
    NSString *strings = [NSNumberFormatter localizedStringFromNumber:self
                                                         numberStyle:style];
    return strings;
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSNumberFormatter *formatter = NSNumberFormatter.new;
    [formatter setPositiveFormat:format];
    formatter.minimumIntegerDigits = 1;
    return [formatter stringFromNumber:self];
}

+ (NSNumber *)numberWithString:(NSString *)string {
    NSString *str = [[string stringByTrim] lowercaseString];
    if (!str || !str.length) {
        return nil;
    }

    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dic = @{ @"true": @(YES),
                 @"yes": @(YES),
                 @"false": @(NO),
                 @"no": @(NO),
                 @"nil": [NSNull null],
                 @"null": [NSNull null],
                 @"<null>": [NSNull null] };
    });
    NSNumber *num = dic[str];
    if (num) {
        if (num == (id)[NSNull null]) return nil;
        return num;
    }

    // hex number
    int sign = 0;
    if ([str hasPrefix:@"0x"])
        sign = 1;
    else if ([str hasPrefix:@"-0x"])
        sign = -1;
    if (sign != 0) {
        NSScanner *scan = [NSScanner scannerWithString:str];
        unsigned num    = -1;
        BOOL suc        = [scan scanHexInt:&num];
        if (suc)
            return [NSNumber numberWithLong:((long)num * sign)];
        else
            return nil;
    }
    // normal number
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter numberFromString:string];
}

@end
