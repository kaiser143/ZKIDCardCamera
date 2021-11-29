//
//  NSDecimalNumber+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import "NSDecimalNumber+ZKAdd.h"

@implementation NSDecimalNumber (ZKAdd)

- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals {
    return [self decimalNumberWithDecimals:decimals mode:NSRoundPlain];
}

- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals mode:(NSRoundingMode)roundingMode {
    NSDecimalNumberHandler *handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:roundingMode scale:decimals raiseOnExactness:NO raiseOnOverflow:YES raiseOnUnderflow:YES raiseOnDivideByZero:YES];
    return [self decimalNumberByRoundingAccordingToBehavior:handler];
}

- (NSDecimalNumber *)decimalNumberWithPercentage:(float)percent {
    NSDecimalNumber *percentage = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithFloat:percent] decimalValue]];
    return [self decimalNumberByMultiplyingBy:percentage];
}

- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage {
    NSDecimalNumber *hundred = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *percent = [self decimalNumberByMultiplyingBy:[discountPercentage decimalNumberByDividingBy:hundred]];
    return [self decimalNumberBySubtracting:percent];
}

- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage decimals:(NSUInteger)decimals {
    NSDecimalNumber *value = [self decimalNumberWithDiscountPercentage:discountPercentage];
    return [value decimalNumberWithDecimals:decimals];
}

- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue {
    NSDecimalNumber *hundred    = [NSDecimalNumber decimalNumberWithString:@"100"];
    NSDecimalNumber *percentage = [[self decimalNumberByDividingBy:baseValue] decimalNumberByMultiplyingBy:hundred];
    return [hundred decimalNumberBySubtracting:percentage];
}

- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue decimals:(NSUInteger)decimals {
    NSDecimalNumber *discount = [self discountPercentageWithBaseValue:baseValue];
    return [discount decimalNumberWithDecimals:decimals];
}

@end
