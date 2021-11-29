//
//  NSArray+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/8/17.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<__covariant ValueType> (ZKAdd)

/**
 * @return NSArray with only the elements that pass the truth test
 */
- (NSArray *)filter:(BOOL (^)(ValueType object))condition;

/**
 * @return NSArray with only the elements that pass the truth test
 */
- (NSArray *)ignore:(id)value;

/**
 * performs the operation to each element
 */
- (void)each:(void (^)(ValueType object))operation;

/**
 * @return new NSArray from the result of the block performed to each element
 */
- (NSArray *)map:(id (^)(ValueType obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it and performing a map to each element(格式化二维数组中的元素)
 */
- (NSArray *)flattenMap:(id (^)(id obj, NSUInteger idx))block;

/**
 * @return new NSArray by flatting it with the key and performing a map to each element
 */
- (NSArray *)flattenMap:(NSString *)key block:(id (^)(ValueType obj, NSUInteger idx))block;

// 参与运算的属性必须是NSNumber对象
- (NSNumber *)sum;
- (NSNumber *)sum:(NSString *)keypath;
- (NSNumber *)avg;
- (NSNumber *)avg:(NSString *)keypath;
- (NSNumber *)max;
- (NSNumber *)max:(NSString *)keypath;
- (NSNumber *)min;
- (NSNumber *)min:(NSString *)keypath;
- (NSUInteger)countKeyPath:(NSString *)keypath;
- (NSArray *)flatten:(NSString *)keypath;

- (ValueType)objectPassingTest:(BOOL (^)(ValueType))block;

/*!
 *  @brief  排序
 *  @param  ascending     是否升序
 *  @param  key 排序字段
 */
- (NSArray *)sortedArray:(BOOL)ascending
                   byKey:(NSString *)key, ... NS_REQUIRES_NIL_TERMINATION;

- (NSArray *)sortedArray:(NSDictionary *)sortedKeyValue;

#pragma mark - :. SafeAccess

- (id)objectOrNilAtIndex:(NSUInteger)index;

- (NSString *)stringAtIndex:(NSUInteger)index;

- (NSNumber *)numberAtIndex:(NSUInteger)index;

- (NSDecimalNumber *)decimalNumberAtIndex:(NSUInteger)index;

- (NSArray *)arrayAtIndex:(NSUInteger)index;

- (NSDictionary *)dictionaryAtIndex:(NSUInteger)index;

- (NSInteger)integerAtIndex:(NSUInteger)index;

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;

- (BOOL)boolAtIndex:(NSUInteger)index;

- (int16_t)int16AtIndex:(NSUInteger)index;

- (int32_t)int32AtIndex:(NSUInteger)index;

- (int64_t)int64AtIndex:(NSUInteger)index;

- (char)charAtIndex:(NSUInteger)index;

- (short)shortAtIndex:(NSUInteger)index;

- (float)floatAtIndex:(NSUInteger)index;

- (double)doubleAtIndex:(NSUInteger)index;

- (NSDate *)dateAtIndex:(NSUInteger)index dateFormat:(NSString *)dateFormat;
//CG
- (CGFloat)CGFloatAtIndex:(NSUInteger)index;

- (CGPoint)pointAtIndex:(NSUInteger)index;

- (CGSize)sizeAtIndex:(NSUInteger)index;

- (CGRect)rectAtIndex:(NSUInteger)index;


/*
 * Checks to see if the array is empty
 */
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

/*!
 *  @brief    交集,返回的数组是array中的对象
 */
- (NSArray<ValueType> *)intersectSet:(NSArray *)array;

/*!
 *  @brief    并集
 */
- (NSArray<ValueType> *)unionSet:(NSArray *)array;

/*!
 *  @brief    差集
 */
- (NSArray<ValueType> *)subtractingSet:(NSArray *)array;

@end

@interface NSMutableArray<ValueType> (SafeAccess)

/**
 Removes the object with the lowest-valued index in the array.
 If the array is empty, this method has no effect.
 
 @discussion Apple has implemented this method, but did not make it public.
 Override for safe.
 */
- (void)removeFirstObject;

/**
 Removes the object with the highest-valued index in the array.
 If the array is empty, this method has no effect.
 
 @discussion Apple's implementation said it raises an NSRangeException if the
 array is empty, but in fact nothing will happen. Override for safe.
 */
- (void)removeLastObject;

/**
 Removes and returns the object with the lowest-valued index in the array.
 If the array is empty, it just returns nil.
 
 @return The first object, or nil.
 */
- (nullable ValueType)popFirstObject;

/**
 Removes and returns the object with the highest-valued index in the array.
 If the array is empty, it just returns nil.
 
 @return The first object, or nil.
 */
- (nullable ValueType)popLastObject;

/**
 Inserts a given object at the end of the array.
 
 @param anObject The object to add to the end of the array's content.
 This value must not be nil. Raises an NSInvalidArgumentException if anObject is nil.
 */
- (void)appendObject:(ValueType)anObject;

/**
 Inserts a given object at the beginning of the array.
 
 @param anObject The object to add to the end of the array's content.
 This value must not be nil. Raises an NSInvalidArgumentException if anObject is nil.
 */
- (void)prependObject:(ValueType)anObject;

/**
 Adds the objects contained in another given array to the end of the receiving
 array's content.
 
 @param objects An array of objects to add to the end of the receiving array's
 content. If the objects is empty or nil, this method has no effect.
 */
- (void)appendObjects:(NSArray<ValueType> *)objects;

/**
 Adds the objects contained in another given array to the beginnin of the receiving
 array's content.
 
 @param objects An array of objects to add to the beginning of the receiving array's
 content. If the objects is empty or nil, this method has no effect.
 */
- (void)prependObjects:(NSArray<ValueType> *)objects;

/**
 Adds the objects contained in another given array at the index of the receiving
 array's content.
 
 @param objects An array of objects to add to the receiving array's
 content. If the objects is empty or nil, this method has no effect.
 
 @param index The index in the array at which to insert objects. This value must
 not be greater than the count of elements in the array. Raises an
 NSRangeException if index is greater than the number of elements in the array.
 */
- (void)insertObjects:(NSArray<ValueType> *)objects atIndex:(NSUInteger)index;

/**
 Reverse the index of object in this array.
 Example: Before @[ @1, @2, @3 ], After @[ @3, @2, @1 ].
 */
- (void)reverse;

/**
 Sort the object in this array randomly.
 */
- (void)shuffle;

- (void)addObj:(ValueType)i;
- (void)addString:(NSString *)i;
- (void)addBool:(BOOL)i;
- (void)addInt:(int)i;
- (void)addInteger:(NSInteger)i;
- (void)addUnsignedInteger:(NSUInteger)i;
- (void)addCGFloat:(CGFloat)f;
- (void)addChar:(char)c;
- (void)addFloat:(float)i;
- (void)addPoint:(CGPoint)o;
- (void)addSize:(CGSize)o;
- (void)addRect:(CGRect)o;
- (void)addRange:(NSRange)range;

@end

NS_ASSUME_NONNULL_END

