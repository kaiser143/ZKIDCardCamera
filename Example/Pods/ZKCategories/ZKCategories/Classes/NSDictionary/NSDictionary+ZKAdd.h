//
//  NSDictionary+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2017/1/11.
//  Copyright © 2017年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ValueType> (ZKAdd)

#pragma mark :. URL Parameter Strings

- (NSString *)URLEncodedStringValue;

/// Merges the keys and values from the given dictionary into the receiver. If
/// both the receiver and `dictionary` have a given key, the value from
/// `dictionary` is used.
///
/// Returns a new dictionary containing the entries of the receiver combined with
/// those of `dictionary`.
- (NSDictionary<KeyType, ValueType> *)dictionaryByAddingEntriesFromDictionary:(NSDictionary<KeyType, ValueType> *)dictionary;

/// Creates a new dictionary with all the entries for the given keys removed from
/// the receiver.
- (NSDictionary<KeyType, ValueType> *)dictionaryByRemovingValuesForKeys:(NSArray<KeyType> *)keys;

/**
 Returns a new array containing the dictionary's keys sorted.
 The keys should be NSString, and they will be sorted ascending.
 
 @return A new array containing the dictionary's keys,
 or an empty array if the dictionary has no entries.
 */
- (NSArray<KeyType> *)allKeysSorted;

/**
 Returns a new array containing the dictionary's values sorted by keys.
 
 The order of the values in the array is defined by keys.
 The keys should be NSString, and they will be sorted ascending.
 
 @return A new array containing the dictionary's values sorted by keys,
 or an empty array if the dictionary has no entries.
 */
- (NSArray<ValueType> *)allValuesSortedByKeys;

/**
 Returns a new dictionary containing the entries for keys.
 If the keys is empty or nil, it just returns an empty dictionary.
 
 @param keys The keys.
 @return The entries for the keys.
 */
- (NSDictionary<KeyType, ValueType> *)entriesForKeys:(NSArray<KeyType> *)keys;

/**
 Convert dictionary to json string. return nil if an error occurs.
 */
- (nullable NSString *)jsonStringEncoded;

/**
 Convert dictionary to json string formatted. return nil if an error occurs.
 */
- (nullable NSString *)jsonPrettyStringEncoded;

/**
 Try to parse an XML and wrap it into a dictionary.
 If you just want to get some value from a small xml, try this.
 
 example XML: "<config><a href="test.com">link</a></config>"
 example Return: @{@"_name":@"config", @"a":{@"_text":@"link",@"href":@"test.com"}}
 
 @param xmlDataOrString XML in NSData or NSString format.
 @return Return a new dictionary, or nil if an error occurs.
 */
+ (nullable NSDictionary<KeyType, ValueType> *)dictionaryWithXML:(id)xmlDataOrString;

#pragma mark - :. SafeAccess

/**
 Returns a BOOL value tells if the dictionary has an object for key.
 
 @param key The key.
 */
- (BOOL)hasKey:(KeyType)key;

/**
 Returns a NSString value for the specified key.
 
 @param key The key for which to return the corresponding value
 @returns the resulting string. If the result is not a NSString and can't converted to one, it returns nil
 */
- (NSString *)stringForKey:(KeyType)key;

/**
 Returns a NSNumber value for the specified key.
 @note this method, if it found a string on the specified key, uses a number formatter based on the en_US_POSIX locale to parse the number, if the number does not follow that format it will return nil.
 
 @param key The key for which to return the corresponding value
 @returns the resulting number. If the result is not a NSNumber and can't converted to one, it returns nil
 */
- (NSNumber *)numberForKey:(KeyType)key;

/**
 Returns a NSNumber value for the specified key.
 @param key The key for which to return the corresponding value
 @param numberFormatter The formatter to use to parse the number if the object found on the key is a string
 @returns the resulting number. If the result is not a NSNumber and can't converted to one, it returns nil
 */
- (NSNumber *)numberForKey:(KeyType)key usingFormatter:(NSNumberFormatter *)numberFormatter;

/**
 Returns a NSArray value for the specified key.
 
 @param key The key for which to return the corresponding value
 @returns the resulting array. If the result is not a NSArray, it returns nil
 */
- (NSArray<ValueType> *)arrayForKey:(KeyType)key;

/**
 Returns a NSDictionary value for the specified key.
 
 @param key The key for which to return the corresponding value
 @returns the resulting dictionary. If the result is not a NSDictionary, it returns nil
 */
- (NSDictionary<KeyType, ValueType> *)dictionaryForKey:(KeyType)key;

/**
 Returns an object for the specified keyPath
 
 @param keyPath A key path of the form relationship.property (with one or more relationships); for example “department.name” or “department.manager.lastName”
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid, it returns nil
 */
- (ValueType)objectForKeyPath:(NSString *)keyPath;

/**
 Returns an object for the specified keyPath
 
 @param keyPath A key path of the form relationship.property, see objectForKeyPath:
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid or the result is not a NSString or can't be converted to one, it returns nil
 */
- (NSString *)stringForKeyPath:(NSString *)keyPath;

/**
 Returns an object for the specified keyPath
 @note this method, if it found a string on the specified keypath, uses a number formatter based on the en_US_POSIX locale to parse the number, if the number does not follow that format it will return nil.
 @param keyPath A key path of the form relationship.property, see objectForKeyPath:
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid or the result is not a NSNumber or can't be converted to one, it returns nil
 */
- (NSNumber *)numberForKeyPath:(NSString *)keyPath;

/**
 Returns an object for the specified keyPath
 
 @param keyPath A key path of the form relationship.property, see objectForKeyPath:
 @param numberFormatter The formatter to use to parse the number if the object found on the keypath is a string
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid or the result is not a NSNumber or can't be converted to one, it returns nil
 */
- (NSNumber *)numberForKeyPath:(NSString *)keyPath usingFormatter:(NSNumberFormatter *)numberFormatter;

/**
 Returns an object for the specified keyPath
 
 @param keyPath A key path of the form relationship.property, see objectForKeyPath:
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid or the result is not a NSArray, it returns nil
 */
- (NSArray *)arrayForKeyPath:(NSString *)keyPath;

/**
 Returns an object for the specified keyPath
 
 @param keyPath A key path of the form relationship.property, see objectForKeyPath:
 @returns The value for the derived property identified by keyPath. If the keyPath is not valid or the result is not a NSDictionary, it returns nil
 */
- (NSDictionary<KeyType, ValueType> *)dictionaryForKeyPath:(NSString *)keyPath;

- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def;

- (char)charValueForKey:(NSString *)key default:(char)def;
- (unsigned char)unsignedCharValueForKey:(NSString *)key default:(unsigned char)def;

- (short)shortValueForKey:(NSString *)key default:(short)def;
- (unsigned short)unsignedShortValueForKey:(NSString *)key default:(unsigned short)def;

- (int)intValueForKey:(NSString *)key default:(int)def;
- (unsigned int)unsignedIntValueForKey:(NSString *)key default:(unsigned int)def;

- (long)longValueForKey:(NSString *)key default:(long)def;
- (unsigned long)unsignedLongValueForKey:(NSString *)key default:(unsigned long)def;

- (long long)longLongValueForKey:(NSString *)key default:(long long)def;
- (unsigned long long)unsignedLongLongValueForKey:(NSString *)key default:(unsigned long long)def;

- (float)floatValueForKey:(NSString *)key default:(float)def;
- (double)doubleValueForKey:(NSString *)key default:(double)def;

- (NSInteger)integerValueForKey:(NSString *)key default:(NSInteger)def;
- (NSUInteger)unsignedIntegerValueForKey:(NSString *)key default:(NSUInteger)def;

- (nullable NSNumber *)numberValueForKey:(NSString *)key default:(nullable NSNumber *)def;
- (nullable NSString *)stringValueForKey:(NSString *)key default:(nullable NSString *)def;

#pragma mark - :. XML

/*!
 *  @brief    将NSDictionary转成XML 字符串
 */
- (NSString *)XMLString;

/*
 * Checks to see if the dictionary is empty
 */
@property(nonatomic, readonly, getter=isEmpty) BOOL empty;

@end

@interface NSMutableDictionary<KeyType, ValueType> (ZKAdd)

/**
 Removes and returns the value associated with a given key.
 
 @param aKey The key for which to return and remove the corresponding value.
 @return The value associated with aKey, or nil if no value is associated with aKey.
 */
- (nullable ValueType)popObjectForKey:(KeyType)aKey;

/**
 Returns a new dictionary containing the entries for keys, and remove these
 entries from reciever. If the keys is empty or nil, it just returns an
 empty dictionary.
 
 @param keys The keys.
 @return The entries for the keys.
 */
- (NSDictionary<KeyType, ValueType> *)popEntriesForKeys:(NSArray<KeyType> *)keys;

@end

NS_ASSUME_NONNULL_END
