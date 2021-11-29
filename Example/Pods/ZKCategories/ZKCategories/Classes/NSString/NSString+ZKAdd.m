//
//  NSString+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/11/21.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "NSString+ZKAdd.h"
#import "NSNumber+ZKAdd.h"
#import "NSDictionary+ZKAdd.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSData+ZKAdd.h"

#define URL_MATCHING_PATTERN @"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"

@implementation NSString (ZKAdd)

- (BOOL)isValidURL {
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", URL_MATCHING_PATTERN];
    BOOL returnBool    = [regex evaluateWithObject:self];
    return returnBool;
}

- (nullable NSDictionary *)dictionaryWithURLEncodedString {
    NSMutableDictionary *mutableResponseDictionary = [[NSMutableDictionary alloc] init];
    // split string by &s
    NSArray *encodedParameters = [self componentsSeparatedByString:@"&"];
    for (NSString *parameter in encodedParameters) {
        NSArray *keyValuePair = [parameter componentsSeparatedByString:@"="];
        if (keyValuePair.count == 2) {
            NSString *key   = [[keyValuePair objectAtIndex:0] stringByReplacingPercentEscapes];
            NSString *value = [[keyValuePair objectAtIndex:1] stringByReplacingPercentEscapes];
            [mutableResponseDictionary setObject:value forKey:key];
        }
    }
    return mutableResponseDictionary;
}

- (NSString *)stringByAddingQueryDictionary:(NSDictionary *)query {
    if (0 == query.count) return self;

    NSString *stringValue = [query URLEncodedStringValue];
    if ([self rangeOfString:@"?"].location == NSNotFound) {
        return [self stringByAppendingFormat:@"?%@", stringValue];

    } else {
        return [self stringByAppendingFormat:@"&%@", stringValue];
    }
}

- (NSComparisonResult)versionStringCompare:(NSString *)other {
    NSArray *oneComponents = [self componentsSeparatedByString:@"a"];
    NSArray *twoComponents = [other componentsSeparatedByString:@"a"];

    // The parts before the "a"
    NSString *oneMain = [oneComponents objectAtIndex:0];
    NSString *twoMain = [twoComponents objectAtIndex:0];

    // If main parts are different, return that result, regardless of alpha part
    NSComparisonResult mainDiff;
    if ((mainDiff = [oneMain compare:twoMain]) != NSOrderedSame) {
        return mainDiff;
    }

    // At this point the main parts are the same; just deal with alpha stuff
    // If one has an alpha part and the other doesn't, the one without is newer
    if ([oneComponents count] < [twoComponents count]) {
        return NSOrderedDescending;

    } else if ([oneComponents count] > [twoComponents count]) {
        return NSOrderedAscending;

    } else if ([oneComponents count] == 1) {
        // Neither has an alpha part, and we know the main parts are the same
        return NSOrderedSame;
    }

    // At this point the main parts are the same and both have alpha parts. Compare the alpha parts
    // numerically. If it's not a valid number (including empty string) it's treated as zero.
    NSNumber *oneAlpha = [NSNumber numberWithInt:[[oneComponents objectAtIndex:1] intValue]];
    NSNumber *twoAlpha = [NSNumber numberWithInt:[[twoComponents objectAtIndex:1] intValue]];
    return [oneAlpha compare:twoAlpha];
}

#pragma mark URL Escaping

- (NSString *)stringByURLEncoding {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]%"), kCFStringEncodingUTF8));
#else
    
    static NSCharacterSet *allowedCharacters = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSMutableCharacterSet *tmpSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        
        // add some characters that might have special meaning
        [tmpSet  removeCharactersInString: @"!*'();:@&=+$,/?%#[]"];
        allowedCharacters = [tmpSet copy];
    });
    
    return [self stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
#endif
}

- (NSString *)stringByEscapingQueryParameters {
    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, CFSTR("!*'();:@&=+$,/?%#[]%"), kCFStringEncodingUTF8));
}

- (NSString *)stringByReplacingPercentEscapes {
    return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, CFSTR("")));
}

- (nullable NSURL *)URL {
    return [NSURL URLWithString:self];
}

- (nullable NSURL *)URLRelativeToURL:(nullable NSURL *)baseURL {
    return [NSURL URLWithString:self relativeToURL:baseURL];
}

- (BOOL)contains:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

- (BOOL)startWith:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == 0;
}

- (BOOL)endWith:(NSString *)substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == self.length - substring.length;
}

- (NSUInteger)indexOf:(NSString *)substring {
    NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSArray *)split:(NSString *)token {
    return [self split:token limit:0];
}

- (NSArray *)split:(NSString *)token limit:(NSUInteger)maxResults {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:8];
    NSString *buffer       = self;
    while ([buffer contains:token]) {
        if (maxResults > 0 && [result count] == maxResults - 1) {
            break;
        }
        NSUInteger matchIndex = [buffer indexOf:token];
        NSString *nextPart    = [buffer substringFromIndex:0 toIndex:matchIndex];
        buffer                = [buffer substringFromIndex:matchIndex + [token length]];
        [result addObject:nextPart];
    }
    if ([buffer length] > 0) {
        [result addObject:buffer];
    }

    return result;
}

- (NSString *)substringFromIndex:(NSUInteger)from toIndex:(NSUInteger)to {
    NSRange range;
    range.location = from;
    range.length   = to - from;
    return [self substringWithRange:range];
}

+ (NSString *)stringByFormattingBytes:(long long)bytes {
    NSArray *units = @[@"%1.0f Bytes", @"%1.1f KB", @"%1.1f MB", @"%1.1f GB", @"%1.1f TB"];

    long long value = bytes * 10;
    for (NSUInteger i = 0; i < [units count]; i++) {
        if (i > 0) {
            value = value / 1024;
        }
        if (value < 10000) {
            return [NSString stringWithFormat:units[i], value / 10.0];
        }
    }

    return [NSString stringWithFormat:units[[units count] - 1], value / 10.0];
}

- (NSInteger)byteLength {
    NSInteger strlength = 0;
    char *p             = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i = 0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        } else {
            p++;
        }
    }

    return (strlength + 1) / 2;
}

- (NSString *)md2String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md2String];
}

- (NSString *)md4String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md4String];
}

- (NSString *)md5String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] md5String];
}

- (NSString *)sha1String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha1String];
}

- (NSString *)sha224String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha224String];
}

- (NSString *)sha256String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha256String];
}

- (NSString *)sha384String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha384String];
}

- (NSString *)sha512String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] sha512String];
}

- (NSString *)crc32String {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] crc32String];
}

- (NSString *)hmacMD5StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacMD5StringWithKey:key];
}

- (NSString *)hmacSHA1StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacSHA1StringWithKey:key];
}

- (NSString *)hmacSHA224StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacSHA224StringWithKey:key];
}

- (NSString *)hmacSHA256StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacSHA256StringWithKey:key];
}

- (NSString *)hmacSHA384StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacSHA384StringWithKey:key];
}

- (NSString *)hmacSHA512StringWithKey:(NSString *)key {
    return [[self dataUsingEncoding:NSUTF8StringEncoding]
        hmacSHA512StringWithKey:key];
}

- (NSString *)base64EncodedString {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

+ (NSString *)stringWithBase64EncodedString:(NSString *)base64EncodedString {
    NSData *data = [NSData dataWithBase64EncodedString:base64EncodedString];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSString *)stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
         - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
         - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
         - parameter string: The string to be percent-escaped.
         - returns: The percent-escaped string.
         */
        static NSString *const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString *const kAFCharactersSubDelimitersToEncode     = @"!$&'()*+,;=";

        NSMutableCharacterSet *allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;

        NSUInteger index         = 0;
        NSMutableString *escaped = @"".mutableCopy;

        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range     = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range               = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded   = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];

            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded           = (__bridge_transfer NSString *)
            CFURLCreateStringByAddingPercentEscapes(
                kCFAllocatorDefault,
                (__bridge CFStringRef)self,
                NULL,
                CFSTR("!#$&'()*+,/:;=?@[]"),
                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded   = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
            CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                NULL,
                (__bridge CFStringRef)decoded,
                CFSTR(""),
                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)stringByEscapingHTML {
    NSUInteger len = self.length;
    if (!len) return self;

    unichar *buf = malloc(sizeof(unichar) * len);
    if (!buf) return self;
    [self getCharacters:buf range:NSMakeRange(0, len)];

    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < len; i++) {
        unichar c     = buf[i];
        NSString *esc = nil;
        switch (c) {
            case 34:
                esc = @"&quot;";
                break;
            case 38:
                esc = @"&amp;";
                break;
            case 39:
                esc = @"&apos;";
                break;
            case 60:
                esc = @"&lt;";
                break;
            case 62:
                esc = @"&gt;";
                break;
            default:
                break;
        }
        if (esc) {
            [result appendString:esc];
        } else {
            CFStringAppendCharacters((CFMutableStringRef)result, &c, 1);
        }
    }
    free(buf);
    return result;
}

- (CGSize)sizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode            = lineBreakMode;
            attr[NSParagraphStyleAttributeName]     = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr
                                         context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)widthForFont:(UIFont *)font {
    if (@available(iOS 7.0, *)) {
        return [self sizeWithAttributes:@{NSFontAttributeName: font}].width;
    } else {
        CGSize size = [self sizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
        return size.width;
    }
}

- (CGFloat)heightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self sizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (BOOL)matchesRegex:(NSString *)regex options:(NSRegularExpressionOptions)options {
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:NULL];
    if (!pattern) return NO;
    return ([pattern numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block {
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self
                              options:kNilOptions
                                range:NSMakeRange(0, self.length)
                           usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                               block([self substringWithRange:result.range], result.range, stop);
                           }];
}

- (NSString *)stringByReplacingRegex:(NSString *)regex
                             options:(NSRegularExpressionOptions)options
                          withString:(NSString *)replacement;
{
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!pattern) return self;
    return [pattern stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:replacement];
}

- (char)charValue {
    return self.numberValue.charValue;
}

- (unsigned char)unsignedCharValue {
    return self.numberValue.unsignedCharValue;
}

- (short)shortValue {
    return self.numberValue.shortValue;
}

- (unsigned short)unsignedShortValue {
    return self.numberValue.unsignedShortValue;
}

- (unsigned int)unsignedIntValue {
    return self.numberValue.unsignedIntValue;
}

- (long)longValue {
    return self.numberValue.longValue;
}

- (unsigned long)unsignedLongValue {
    return self.numberValue.unsignedLongValue;
}

- (unsigned long long)unsignedLongLongValue {
    return self.numberValue.unsignedLongLongValue;
}

- (NSUInteger)unsignedIntegerValue {
    return self.numberValue.unsignedIntegerValue;
}

+ (NSString *)UUIDString {
    CFUUIDRef uuid     = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)string;
}

+ (NSString *)stringWithUTF32Char:(UTF32Char)char32 {
    char32 = NSSwapHostIntToLittle(char32);
    return [[NSString alloc] initWithBytes:&char32 length:4 encoding:NSUTF32LittleEndianStringEncoding];
}

+ (NSString *)stringWithUTF32Chars:(const UTF32Char *)char32 length:(NSUInteger)length {
    return [[NSString alloc] initWithBytes:(const void *)char32
                                    length:length * 4
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

- (void)enumerateUTF32CharInRange:(NSRange)range usingBlock:(void (^)(UTF32Char char32, NSRange range, BOOL *stop))block {
    NSString *str = self;
    if (range.location != 0 || range.length != self.length) {
        str = [self substringWithRange:range];
    }
    NSUInteger len    = [str lengthOfBytesUsingEncoding:NSUTF32StringEncoding] / 4;
    UTF32Char *char32 = (UTF32Char *)[str cStringUsingEncoding:NSUTF32LittleEndianStringEncoding];
    if (len == 0 || char32 == NULL) return;

    NSUInteger location = 0;
    BOOL stop           = NO;
    NSRange subRange;
    UTF32Char oneChar;

    for (NSUInteger i = 0; i < len; i++) {
        oneChar  = char32[i];
        subRange = NSMakeRange(location, oneChar > 0xFFFF ? 2 : 1);
        block(oneChar, subRange, &stop);
        if (stop) return;
        location += subRange.length;
    }
}

- (NSString *)stringByTrim {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    return [self stringByTrimmingCharactersInSet:set];
}

- (NSString *)stringByAppendingNameScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    return [self stringByAppendingFormat:@"@%@x", @(scale)];
}

- (NSString *)stringByAppendingPathScale:(CGFloat)scale {
    if (fabs(scale - 1) <= __FLT_EPSILON__ || self.length == 0 || [self hasSuffix:@"/"]) return self.copy;
    NSString *ext    = self.pathExtension;
    NSRange extRange = NSMakeRange(self.length - ext.length, 0);
    if (ext.length > 0) extRange.location -= 1;
    NSString *scaleStr = [NSString stringWithFormat:@"@%@x", @(scale)];
    return [self stringByReplacingCharactersInRange:extRange withString:scaleStr];
}

- (CGFloat)pathScale {
    if (self.length == 0 || [self hasSuffix:@"/"]) return 1;
    NSString *name        = self.stringByDeletingPathExtension;
    __block CGFloat scale = 1;
    [name enumerateRegexMatches:@"@[0-9]+\\.?[0-9]*x$"
                        options:NSRegularExpressionAnchorsMatchLines
                     usingBlock:^(NSString *match, NSRange matchRange, BOOL *stop) {
                         scale = [match substringWithRange:NSMakeRange(1, match.length - 2)].doubleValue;
                     }];
    return scale;
}

- (BOOL)isNotBlank {
    NSCharacterSet *blank = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![blank characterIsMember:c]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)containsString:(NSString *)string {
    if (string == nil) return NO;
    return [self rangeOfString:string].location != NSNotFound;
}

- (BOOL)containsCharacterSet:(NSCharacterSet *)set {
    if (set == nil) return NO;
    return [self rangeOfCharacterFromSet:set].location != NSNotFound;
}

- (NSNumber *)numberValue {
    return [NSNumber numberWithString:self];
}

- (NSData *)dataValue {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSRange)rangeOfAll {
    return NSMakeRange(0, self.length);
}

- (id)jsonValueDecoded {
    return [[self dataValue] jsonValueDecoded];
}

+ (NSString *)stringNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    NSString *str  = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    if (!str) {
        path = [[NSBundle mainBundle] pathForResource:name ofType:@"txt"];
        str  = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    }
    return str;
}

#pragma mark Working with Paths

- (NSString *)pathByIncrementingSequenceNumber {
    NSString *baseName  = [self stringByDeletingPathExtension];
    NSString *extension = [self pathExtension];

    NSRegularExpression *regex       = [NSRegularExpression regularExpressionWithPattern:@"\\(([0-9]+)\\)$" options:0 error:NULL];
    __block NSInteger sequenceNumber = 0;

    [regex enumerateMatchesInString:baseName
                            options:0
                              range:NSMakeRange(0, [baseName length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {

                             NSRange range       = [match rangeAtIndex:1]; // first capture group
                             NSString *substring = [self substringWithRange:range];

                             sequenceNumber = [substring integerValue];
                             *stop          = YES;
                         }];

    NSString *nakedName = [baseName pathByDeletingSequenceNumber];

    if ([extension isEqualToString:@""]) {
        return [nakedName stringByAppendingFormat:@"(%d)", (int)sequenceNumber + 1];
    }

    return [[nakedName stringByAppendingFormat:@"(%d)", (int)sequenceNumber + 1] stringByAppendingPathExtension:extension];
}

- (NSString *)pathByDeletingSequenceNumber {
    NSString *baseName = [self stringByDeletingPathExtension];

    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\([0-9]+\\)$" options:0 error:NULL];
    __block NSRange range      = NSMakeRange(NSNotFound, 0);

    [regex enumerateMatchesInString:baseName
                            options:0
                              range:NSMakeRange(0, [baseName length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {

                             range = [match range];
                             *stop = YES;
                         }];

    if (range.location != NSNotFound) {
        return [self stringByReplacingCharactersInRange:range withString:@""];
    }

    return self;
}

- (NSMutableAttributedString *)mutableAttributedString {
    return [[NSMutableAttributedString alloc] initWithString:self];
}

- (NSMutableAttributedString *)mutableAttributedStringWithAttributes:(nullable NSDictionary<NSAttributedStringKey, id> *)attrs {
    return [[NSMutableAttributedString alloc] initWithString:self attributes:attrs];
}

@end

@implementation NSString (ZKUTI)

+ (NSString *)MIMETypeForFileExtension:(NSString *)extension {
    CFStringRef typeForExt = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *result       = (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(typeForExt, kUTTagClassMIMEType);
    CFRelease(typeForExt);
    if (!result) {
        return @"application/octet-stream";
    }

    return result;
}

+ (NSString *)fileTypeDescriptionForFileExtension:(NSString *)extension {
    CFStringRef typeForExt = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
    NSString *result       = (__bridge_transfer NSString *)UTTypeCopyDescription(typeForExt);
    CFRelease(typeForExt);
    return result;
}

+ (NSString *)universalTypeIdentifierForFileExtension:(NSString *)extension {
    return (__bridge_transfer NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
}

+ (NSString *)fileExtensionForUniversalTypeIdentifier:(NSString *)UTI {
    return (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)(UTI), kUTTagClassFilenameExtension);
}

- (BOOL)conformsToUniversalTypeIdentifier:(NSString *)conformingUTI {
    return UTTypeConformsTo((__bridge CFStringRef)(self), (__bridge CFStringRef)conformingUTI);
}

- (BOOL)isMovieFileName {
    NSString *extension = [self pathExtension];

    // without extension we cannot know
    if (![extension length]) {
        return NO;
    }

    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];

    return [uti conformsToUniversalTypeIdentifier:@"public.movie"];
}

- (BOOL)isAudioFileName {
    NSString *extension = [self pathExtension];

    // without extension we cannot know
    if (![extension length]) {
        return NO;
    }

    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];

    return [uti conformsToUniversalTypeIdentifier:@"public.audio"];
}

- (BOOL)isImageFileName {
    NSString *extension = [self pathExtension];

    // without extension we cannot know
    if (![extension length]) {
        return NO;
    }

    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];

    return [uti conformsToUniversalTypeIdentifier:@"public.image"];
}

- (BOOL)isHTMLFileName {
    NSString *extension = [self pathExtension];

    // without extension we cannot know
    if (![extension length]) {
        return NO;
    }

    NSString *uti = [NSString universalTypeIdentifierForFileExtension:extension];

    return [uti conformsToUniversalTypeIdentifier:@"public.html"];
}

@end

