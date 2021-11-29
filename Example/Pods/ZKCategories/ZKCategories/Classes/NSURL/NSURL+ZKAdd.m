//
//  NSURL+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "NSURL+ZKAdd.h"
#import "NSDictionary+ZKAdd.h"

@implementation NSURL (ZKAdd)

+ (NSURL *)appStoreURLforApplicationIdentifier:(NSString *)identifier {
    NSString *link = [NSString stringWithFormat:@"http://itunes.apple.com/us/app/id%@?mt=8", identifier];

    return [NSURL URLWithString:link];
}

+ (NSURL *)appStoreReviewURLForApplicationIdentifier:(NSString *)identifier {
    NSString *link = [NSString stringWithFormat:@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", identifier];
    return [NSURL URLWithString:link];
}

- (NSDictionary *)queryParameters {
    NSString *query             = [self query];
    NSArray *keyValuePairs      = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    for (NSString *pair in keyValuePairs) {
        NSArray *components = [pair componentsSeparatedByString:@"="];

        if (components.count == 2) {
            NSString *key   = [[components firstObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

            if (key && value) {
                [params setObject:value forKey:key];
            }
        }
    }

    return params;
}

- (NSURL *)URLByAppendingString:(NSString *)string {
    NSString *baseURL = [self absoluteString];

    if ([baseURL hasSuffix:@"/"] && [string hasPrefix:@"/"]) {
        string = [string substringFromIndex:1];
    } else if (string.length && ![baseURL hasSuffix:@"/"] && ![string hasPrefix:@"/"]) {
        // Don't append a trailing / if string is empty.
        string = [@"/" stringByAppendingString:string];
    }

    return [NSURL URLWithString:[baseURL stringByAppendingString:string]];
}

- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)parameters {
    if (!parameters.count) {
        return self;
    }

    NSMutableString *urlString = [[self absoluteString] mutableCopy];

    if ([self query]) {
        [urlString appendString:@"&"];
    } else {
        [urlString appendString:@"?"];
    }

    [urlString appendString:[parameters URLEncodedStringValue]];
    NSURL *returnURL = [NSURL URLWithString:urlString];

    return returnURL;
}

@end

@implementation NSURL (ZKComparing)

- (BOOL)isEqualToURL:(NSURL *)URL {
    // scheme must be same
    if (![[self scheme] isEqualToString:[URL scheme]]) {
        return NO;
    }

    // host must be same
    if (![[self host] isEqualToString:[URL host]]) {
        return NO;
    }

    // path must be same
    if (![[self path] isEqualToString:[URL path]]) {
        return NO;
    }

    return YES;
}

@end
