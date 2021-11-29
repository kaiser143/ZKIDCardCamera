//
//  NSNumber+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/22.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNumber (ZKAdd)

- (CGFloat)CGFloatValue;

- (instancetype)initWithValue:(CGFloat)value;

+ (NSNumber *)numberWithValue:(CGFloat)value;

/*!
 *  @brief    保留指定位数的小数()，不够则用0补位
 *  @(3.1.15926)
 *  decimals        0   2       3       20
 *  returnValue     3   3.14    3.142   3.14159260000000000000
 *  @param    decimals    小数位数
 */
- (NSString *)stringWithDecimals:(NSInteger)decimals;

/*!
 *  @brief    数字格式化定制
 *  @param    style
    NSNumberFormatterNoStyle,           // 无类型,四舍五入保留整数  123456
    NSNumberFormatterDecimalStyle,      // 123,456.023 (小数点后面最多3位)
    NSNumberFormatterCurrencyStyle,     // 以货币通用格式输出 保留2位小数,第三位小数四舍五入,在前面添加dollor符号 $12,345.66(会根据手机语言不同会改变)
    NSNumberFormatterPercentStyle,      // 以百分制形式输出  整个数字乘以保留2为小数,第三位小数四舍五入,然后乘以100,同时在最后加上百分号
    NSNumberFormatterScientificStyle,   // 以科学计数法输出 1.2345602322E5
    NSNumberFormatterSpellOutStyle,     // 十二万三千四百五十六点〇二三二二 (会根据手机语言不同会改变)
    NSNumberFormatterOrdinalStyle NS_ENUM_AVAILABLE(10_11, 9_0),            // 输出  12,346th
    NSNumberFormatterCurrencyISOCodeStyle NS_ENUM_AVAILABLE(10_11, 9_0),    // USD 123,456.02
    NSNumberFormatterCurrencyPluralStyle NS_ENUM_AVAILABLE(10_11, 9_0),     // 123,456.02美元
    NSNumberFormatterCurrencyAccountingStyle NS_ENUM_AVAILABLE(10_11, 9_0), // US$123,456.02
 */
- (NSString *)formatterWithNumberStyle:(NSNumberFormatterStyle)style;

/*!
 *  @brief    数字格式化定制
 *  @param    format    e.g.:@"#.00"
    #：为0则补位为空
    0：没有则补位为0
        @".00"           保留两位小数
        @",###.00"      //三位一逗，保留两位小数
        @"0%"           //输出：67778998%
        @"0.00%;"       //输出：67778998.00%
 */
- (NSString *)stringWithFormat:(NSString *)format;

/**
 Creates and returns an NSNumber object from a string.
 Valid format: @"12", @"12.345", @" -0xFF", @" .23e99 "...
 
 @param string  The string described an number.
 
 @return an NSNumber when parse succeed, or nil if an error occurs.
 */
+ (nullable NSNumber *)numberWithString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
