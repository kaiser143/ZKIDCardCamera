//
//  ZKIDCardCameraLocalization.m
//  ZKIDCardCamera(https://github.com/kaiser143/ZKIDCardCamera.git)
//
//  Created by zhangkai on 2026/6/3.
//  Copyright © 2026年 zhangkai. All rights reserved.
//

#import "ZKIDCardCameraLocalization.h"
#import "ZKIDCardCameraConfiguration.h"

static NSString *ZKIDCardCameraLanguageForConfiguration(ZKIDCardCameraConfiguration *configuration) {
    if (configuration.preferredLanguage.length > 0) {
        return configuration.preferredLanguage;
    }
    NSString *preferred = [NSLocale preferredLanguages].firstObject;
    if ([preferred hasPrefix:@"zh"]) {
        return @"zh-Hans";
    }
    return @"en";
}

NSString *ZKIDCardCameraLocalizedString(NSString *key, ZKIDCardCameraConfiguration *configuration) {
    NSBundle *bundle = configuration.resourceBundle;
    NSString *language = ZKIDCardCameraLanguageForConfiguration(configuration);
    NSString *path = [bundle pathForResource:language ofType:@"lproj"];
    if (!path.length) {
        path = [bundle pathForResource:@"en" ofType:@"lproj"];
    }
    NSBundle *languageBundle = path.length ? [NSBundle bundleWithPath:path] : bundle;
    NSString *value = [languageBundle localizedStringForKey:key value:nil table:nil];
    if (value.length == 0 || [value isEqualToString:key]) {
        value = [bundle localizedStringForKey:key value:key table:nil];
    }
    return value.length ? value : key;
}

NSString *ZKIDCardCameraResolvedString(NSString *key, NSString *customOverride, ZKIDCardCameraConfiguration *configuration) {
    if (customOverride.length > 0) {
        return customOverride;
    }
    return ZKIDCardCameraLocalizedString(key, configuration);
}
