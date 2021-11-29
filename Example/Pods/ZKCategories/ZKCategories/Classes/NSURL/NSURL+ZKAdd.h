//
//  NSURL+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/14.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSURL (ZKAdd)

/** Returns the URL to open the mobile app store on the app's page.
 
 URL construction as described in [QA1629](https://developer.apple.com/library/ios/#qa/qa2008/qa1629.html). Test and found to be opening the app store app directly even without the itms: or itms-apps: scheme. This kind of URL can also be used to forward a link to the app to non-iOS devices.
 
 @param identifier The application identifier that gets assigned to a new app when you add it to iTunes Connect.
 @return Returns the URL to the direct app store link
 */
+ (NSURL *)appStoreURLforApplicationIdentifier:(NSString *)identifier;


/** Returns the URL to open the mobile app store on the app's review page.
 
 The reviews page is a sub-page of the normal app landing page you get with appStoreURLforApplicationIdentifier:
 
 @param identifier The application identifier that gets assigned to a new app when you add it to iTunes Connect.
 @return Returns the URL to the direct app store link
 */
+ (NSURL *)appStoreReviewURLForApplicationIdentifier:(NSString *)identifier;

- (NSDictionary *)queryParameters;
- (NSURL *)URLByAppendingString:(NSString *)string;
- (NSURL *)URLByAppendingQueryParameters:(NSDictionary *)parameters;

@end


@interface NSURL (ZKComparing)

/**
 Compares the receiver with another URL
 @param URL another URL
 @returns `YES` if the receiver is equivalent with the passed URL
 */
- (BOOL)isEqualToURL:(NSURL *)URL;

@end

NS_ASSUME_NONNULL_END
