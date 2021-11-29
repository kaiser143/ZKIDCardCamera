//
//  NSArray+ZKAdd.h
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2019/6/15.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebView (ZKAdd)

+ (void)clearAllWebCache;

/**
 *  截长图
 */
- (void)KAIContentScrollCaptureCompletionHandler:(void(^)(UIImage *_Nullable capturedImage))completionHandler;

@end

NS_ASSUME_NONNULL_END
