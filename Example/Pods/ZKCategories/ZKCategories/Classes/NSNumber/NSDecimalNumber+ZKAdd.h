//
//  NSDecimalNumber+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/6/28.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

// Rounding policies :
// Original
//    value 1.2  1.21  1.25  1.35  1.27

// Plain    1.2  1.2   1.3   1.4   1.3
// Down     1.2  1.2   1.2   1.3   1.2
// Up       1.2  1.3   1.3   1.4   1.3
// Bankers  1.2  1.2   1.2   1.4   1.3

@interface NSDecimalNumber (ZKAdd)

/**
 *  @brief  四舍五入 NSRoundPlain
 *
 *  @param decimals 限制位数
 *
 *  @return 返回结果
 */
- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals;
/**
 *  @brief  四舍五入
 *
 *  @param decimals        限制位数
 *  @param roundingMode NSRoundingMode
 *
 *  @return 返回结果
 */
- (NSDecimalNumber *)decimalNumberWithDecimals:(NSUInteger)decimals mode:(NSRoundingMode)roundingMode;

- (NSDecimalNumber *)decimalNumberWithPercentage:(float)percent;
- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage;
- (NSDecimalNumber *)decimalNumberWithDiscountPercentage:(NSDecimalNumber *)discountPercentage decimals:(NSUInteger)decimals;
- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue;
- (NSDecimalNumber *)discountPercentageWithBaseValue:(NSDecimalNumber *)baseValue decimals:(NSUInteger)decimals;

@end
