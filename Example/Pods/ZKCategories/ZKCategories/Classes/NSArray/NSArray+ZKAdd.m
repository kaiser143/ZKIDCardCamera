//
//  NSArray+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "NSArray+ZKAdd.h"

@implementation NSArray (ZKAdd)

- (NSArray *)filter:(BOOL (^)(id object))condition {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id _Nonnull evaluatedObject, NSDictionary<NSString *, id> *_Nullable bindings) {
                     return condition(evaluatedObject);
                 }]];
}

- (NSArray *)ignore:(id)value {
    return [self filter:^BOOL(id object) {
        return object != value && ![object isEqual:value];
    }];
}

- (NSArray *)map:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id currentObject, NSUInteger index, BOOL *stop) {
        id mappedCurrentObject = block(currentObject, index);
        if (mappedCurrentObject) {
            [result addObject:mappedCurrentObject];
        }
    }];
    return result;
}

- (NSArray *)flattenMap:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *results = [NSMutableArray new];
    [self each:^(NSArray *array) {
        [results addObject:[array map:^id(id obj, NSUInteger idx) {
                     return block(obj, idx);
                 }]];
    }];
    return results;
}

- (NSArray *)flattenMap:(NSString *)key block:(id (^)(id obj, NSUInteger idx))block {
    NSMutableArray *results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObject:[[object valueForKey:key] map:^id(id obj, NSUInteger idx) {
                     return block(obj, idx);
                 }]];
    }];
    return results;
}

- (void)each:(void (^)(id object))operation {
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        operation(object);
    }];
}

- (id)objectPassingTest:(BOOL (^)(id))block {
    NSCParameterAssert(block != NULL);

    return [self filter:block].firstObject;
}

//==============================================
#pragma mark - Operators
//==============================================
// 你可以简单的通过把 self 作为操作符后面的 key path 来获取一个由NSNumber组成的数组或者集合的总值
// https://nshipster.cn/kvc-collection-operators/
- (NSNumber *)operator:(NSString *)operator keypath:(NSString *)keypath {
    NSString *finalKeyPath;
    if (keypath != nil)
        finalKeyPath = [NSString stringWithFormat:@"%@.@%@.self",keypath, operator];
    else
        finalKeyPath = [NSString stringWithFormat:@"@%@.self",operator];

    return [self valueForKeyPath:finalKeyPath];
}

- (NSNumber *)sum { return [self operator:@"sum" keypath:nil]; }
- (NSNumber *)sum:(NSString *)keypath { return [self operator:@"sum" keypath:keypath]; }
- (NSNumber *)avg { return [self operator:@"avg" keypath:nil]; }
- (NSNumber *)avg:(NSString *)keypath { return [self operator:@"avg" keypath:keypath]; }
- (NSNumber *)max { return [self operator:@"max" keypath:nil]; }
- (NSNumber *)max:(NSString *)keypath { return [self operator:@"max" keypath:keypath]; }
- (NSNumber *)min { return [self operator:@"min" keypath:nil]; }
- (NSNumber *)min:(NSString *)keypath { return [self operator:@"min" keypath:keypath]; }

- (NSUInteger)countKeyPath:(NSString *)keypath {
    return [self flatten:keypath].count;
}

- (NSArray *)flatten:(NSString *)keypath {
    NSMutableArray *results = [NSMutableArray new];
    [self each:^(id object) {
        [results addObjectsFromArray:[object valueForKeyPath:keypath]];
    }];
    return results;
}

- (NSArray *)sortedArray:(BOOL)ascending
                   byKey:(NSString *)key, ... NS_REQUIRES_NIL_TERMINATION {
    NSMutableArray *array = [NSMutableArray array];
    if (key) {
        [array addObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
        va_list arguments;
        id eachObject;
        va_start(arguments, key);
        while ((eachObject = va_arg(arguments, id))) {
            [array addObject:[NSSortDescriptor sortDescriptorWithKey:eachObject ascending:ascending]];
        }
        va_end(arguments);
    }
    return [self sortedArrayUsingDescriptors:array];
}

- (NSArray *)sortedArray:(NSDictionary *)sortedKeyValue {
    NSMutableArray *array = [NSMutableArray array];
    for (NSString *key in sortedKeyValue.allKeys)
        [array addObject:[NSSortDescriptor sortDescriptorWithKey:key ascending:[[sortedKeyValue objectForKey:key] boolValue]]];

    return [self sortedArrayUsingDescriptors:array];
}

#pragma mark - :. SafeAccess

- (id)objectOrNilAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return self[index];
    } else {
        return nil;
    }
}

- (NSString *)stringAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if (value == nil || value == [NSNull null]) {
        return @"";
    }
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }

    return nil;
}

- (NSNumber *)numberAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    if ([value isKindOfClass:[NSString class]]) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        return [f numberFromString:(NSString *)value];
    }
    return nil;
}

- (NSDecimalNumber *)decimalNumberAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if ([value isKindOfClass:[NSDecimalNumber class]]) {
        return value;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)value;
        return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if ([value isKindOfClass:[NSString class]]) {
        NSString *str = (NSString *)value;
        return [str isEqualToString:@""] ? nil : [NSDecimalNumber decimalNumberWithString:str];
    }
    return nil;
}

- (NSArray *)arrayAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if (value == nil || value == [NSNull null]) {
        return nil;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        return value;
    }
    return nil;
}

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if (value == nil || value == [NSNull null]) {
        return nil;
    }
    if ([value isKindOfClass:[NSDictionary class]]) {
        return value;
    }
    return nil;
}

- (NSInteger)integerAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value integerValue];
    }
    return 0;
}

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];
    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]]) {
        return [value unsignedIntegerValue];
    }
    return 0;
}

- (BOOL)boolAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return NO;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value boolValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value boolValue];
    }
    return NO;
}

- (int16_t)int16AtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}

- (int32_t)int32AtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}

- (int64_t)int64AtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value longLongValue];
    }
    return 0;
}

- (char)charAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value charValue];
    }
    return 0;
}

- (short)shortAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value shortValue];
    }
    if ([value isKindOfClass:[NSString class]]) {
        return [value intValue];
    }
    return 0;
}

- (float)floatAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value floatValue];
    }
    return 0;
}
- (double)doubleAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return 0;
    }
    if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
        return [value doubleValue];
    }
    return 0;
}

- (NSDate *)dateAtIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat {
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    formater.dateFormat       = dateFormat;
    id value                  = [self objectOrNilAtIndex:index];

    if (value == nil || value == [NSNull null]) {
        return nil;
    }

    if ([value isKindOfClass:[NSString class]] && ![value isEqualToString:@""] && !dateFormat) {
        return [formater dateFromString:value];
    }
    return nil;
}

//CG
- (CGFloat)CGFloatAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    CGFloat f = [value doubleValue];

    return f;
}

- (CGPoint)pointAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    CGPoint point = CGPointFromString(value);

    return point;
}

- (CGSize)sizeAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    CGSize size = CGSizeFromString(value);

    return size;
}

- (CGRect)rectAtIndex:(NSUInteger)index {
    id value = [self objectOrNilAtIndex:index];

    CGRect rect = CGRectFromString(value);

    return rect;
}

- (BOOL)isEmpty {
    return [self count] == 0 ? YES : NO;
}

- (NSArray *)intersectSet:(NSArray *)array {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:(array.count + self.count)];
    for (id obj in array) {
        if ([self indexOfObject:obj] != NSNotFound) {
            [result addObject:obj];
        }
    }
    return [result copy];
}

- (NSArray *)unionSet:(NSArray *)array {
    NSMutableArray *result = [NSMutableArray arrayWithArray:self];
    for (id obj in array) {
        if ([self indexOfObject:obj] == NSNotFound) {
            [result addObject:obj];
        }
    }
    return [result copy];
}

- (NSArray *)subtractingSet:(NSArray *)array {
    NSMutableArray *result = [NSMutableArray arrayWithArray:self];
    for (id obj in array) {
        // belong B Set && belong A Set,remove it
        if ([self indexOfObject:obj] != NSNotFound) {
            [result removeObject:obj];
        }
    }
    return [result copy];
}

@end

@implementation NSMutableArray (SafeAccess)

- (void)addObj:(id)i {
    if (i != nil) {
        [self addObject:i];
    }
}

- (void)addString:(NSString *)i {
    if (i != nil) {
        [self addObject:i];
    }
}

- (void)addBool:(BOOL)i {
    [self addObject:@(i)];
}

- (void)addInt:(int)i {
    [self addObject:@(i)];
}

- (void)addInteger:(NSInteger)i {
    [self addObject:@(i)];
}

- (void)addUnsignedInteger:(NSUInteger)i {
    [self addObject:@(i)];
}

- (void)addCGFloat:(CGFloat)f {
    [self addObject:@(f)];
}

- (void)addChar:(char)c {
    [self addObject:@(c)];
}

- (void)addFloat:(float)i {
    [self addObject:@(i)];
}

- (void)addPoint:(CGPoint)o {
    [self addObject:NSStringFromCGPoint(o)];
}

- (void)addSize:(CGSize)o {
    [self addObject:NSStringFromCGSize(o)];
}

- (void)addRect:(CGRect)o {
    [self addObject:NSStringFromCGRect(o)];
}

- (void)addRange:(NSRange)range {
    [self addObject:NSStringFromRange(range)];
}

- (void)removeFirstObject {
    if (self.count) {
        [self removeObjectAtIndex:0];
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (void)removeLastObject {
    if (self.count) {
        [self removeObjectAtIndex:self.count - 1];
    }
}

#pragma clang diagnostic pop

- (id)popFirstObject {
    id obj = nil;
    if (self.count) {
        obj = self.firstObject;
        [self removeFirstObject];
    }
    return obj;
}

- (id)popLastObject {
    id obj = nil;
    if (self.count) {
        obj = self.lastObject;
        [self removeLastObject];
    }
    return obj;
}

- (void)appendObject:(id)anObject {
    [self addObject:anObject];
}

- (void)prependObject:(id)anObject {
    [self insertObject:anObject atIndex:0];
}

- (void)appendObjects:(NSArray *)objects {
    if (!objects) return;
    [self addObjectsFromArray:objects];
}

- (void)prependObjects:(NSArray *)objects {
    if (!objects) return;
    NSUInteger i = 0;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}

- (void)insertObjects:(NSArray *)objects atIndex:(NSUInteger)index {
    NSUInteger i = index;
    for (id obj in objects) {
        [self insertObject:obj atIndex:i++];
    }
}

- (void)reverse {
    NSUInteger count = self.count;
    int mid          = floor(count / 2.0);
    for (NSUInteger i = 0; i < mid; i++) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:(count - (i + 1))];
    }
}

- (void)shuffle {
    for (NSUInteger i = self.count; i > 1; i--) {
        [self exchangeObjectAtIndex:(i - 1)
                  withObjectAtIndex:arc4random_uniform((u_int32_t)i)];
    }
}

@end
