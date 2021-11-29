//
//  UITableViewCell+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2016/12/19.
//  Copyright © 2016年 Kaiser. All rights reserved.
//

#import "UITableViewCell+ZKAdd.h"
#import "UIView+ZKAdd.h"
#import "NSObject+ZKAdd.h"

@interface UITableViewCell ()

@end

@implementation UITableViewCell (ZKAdd)

+ (void)load {
    [self swizzleMethod:@selector(initWithStyle:reuseIdentifier:) withMethod:@selector(_kai_initWithStyle:reuseIdentifier:)];
}

- (instancetype)_kai_initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    id object = [self _kai_initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (object) {
        UIScrollView *scrollView = [object descendantOrSelfWithClass:[UIScrollView class]];
        if (scrollView) scrollView.delaysContentTouches = NO;
        
        [(UIView *)object setClipsToBounds:YES];
    }
    
    return object;
}

@end
