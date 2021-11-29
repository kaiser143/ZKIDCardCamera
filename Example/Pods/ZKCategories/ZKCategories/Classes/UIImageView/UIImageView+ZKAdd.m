//
//  UIImageView+ZKAdd.m
//  ZKCategories(https://github.com/kaiser143/ZKCategories.git)
//
//  Created by Kaiser on 2018/12/30.
//  Copyright © 2018年 Kaiser. All rights reserved.
//

#import "UIImageView+ZKAdd.h"
#import "NSObject+ZKAdd.h"
#import "NSNumber+ZKAdd.h"

@interface UIImageView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) UIRectCorner corner;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, assign) BOOL hadAddObserver;
@property (nonatomic, assign, getter=isRounding) BOOL rounding;

@end

@implementation UIImageView (ZKAdd)

+ (void)load {
    [self swizzleMethod:NSSelectorFromString(@"dealloc") withMethod:@selector(__dealloc)];
    [self swizzleMethod:@selector(layoutSubviews) withMethod:@selector(__layoutSubviews)];
}

- (instancetype)initWithCornerRadius:(CGFloat)radius rectCorner:(UIRectCorner)rectCorner {
    self = [super init];
    if (!self) {
        return nil;
    }

    [self setCornerRadius:radius rectCorner:rectCorner];

    return self;
}

- (instancetype)initWithRoundingRectImageView {
    self = [super init];
    if (!self) {
        return nil;
    }

    [self setCornerRadiusRoundingRect];

    return self;
}

#pragma mark -
#pragma mark - :. KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"image"]) {
        UIImage *newImage = change[ NSKeyValueChangeNewKey ];
        if ([newImage isMemberOfClass:[NSNull class]]) {
            return;
        } else if ([[self associatedValueForKey:@selector(updateImage:withRadius:withCorner:)] integerValue] == 1) {
            return;
        }

        if (self.isRounding) {
            [self updateImage:newImage withRadius:CGRectGetWidth(self.frame) / 2 withCorner:UIRectCornerAllCorners];
        } else if (0 != self.radius && 0 != self.corner && nil != self.image) {
            [self updateImage:newImage withRadius:self.radius withCorner:self.corner];
        }
    }
}

#pragma mark -
#pragma mark :. Public methods

- (void)setBorderWidth:(CGFloat)width color:(UIColor *)color {
    self.borderWidth = width;
    self.borderColor = color;
}

- (void)setCornerRadiusRoundingRect {
    self.rounding = YES;

    if (!self.hadAddObserver) {
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.hadAddObserver = YES;
    }

    [self layoutIfNeeded];
}

#pragma mark -
#pragma mark :. Private methods

- (void)setCornerRadius:(CGFloat)radius rectCorner:(UIRectCorner)rectCorner {
    self.radius   = radius;
    self.corner   = rectCorner;
    self.rounding = NO;
    if (!self.hadAddObserver) {
        [self addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
        self.hadAddObserver = YES;
    }

    [self layoutIfNeeded];
}

- (void)updateImage:(UIImage *)image withRadius:(CGFloat)radius withCorner:(UIRectCorner)corner {
    CGSize size       = self.bounds.size;
    CGFloat scale     = [UIScreen mainScreen].scale;
    CGSize resultSize = CGSizeMake(radius, radius);

    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    if (nil == currentContext) {
        return;
    }
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                     byRoundingCorners:corner
                                                           cornerRadii:resultSize];
    [cornerPath addClip];
    [self.layer renderInContext:currentContext];
    [self drawBorder:cornerPath];
    UIImage *processedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    if (processedImage) {
        [self setAssociateValue:@1 withKey:_cmd];
    }
    self.image = processedImage;
}

- (void)drawBorder:(UIBezierPath *)path {
    if (0 != self.borderWidth && nil != self.borderColor) {
        [path setLineWidth:2 * self.borderWidth];
        [self.borderColor setStroke];
        [path stroke];
    }
}

- (void)__dealloc {
    if (self.hadAddObserver) {
        [self removeObserver:self forKeyPath:@"image"];
    }

    [self __dealloc];
}

- (void)__layoutSubviews {
    [self __layoutSubviews];

    if (self.isRounding) {
        [self updateImage:self.image withRadius:CGRectGetWidth(self.frame) / 2 withCorner:UIRectCornerAllCorners];
    } else if (0 != self.radius && 0 != self.corner && nil != self.image) {
        [self updateImage:self.image withRadius:self.radius withCorner:self.corner];
    }
}

#pragma mark - getters and setters

- (CGFloat)borderWidth {
    return [[self associatedValueForKey:_cmd] floatValue];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    [self setAssociateValue:@(borderWidth) withKey:@selector(borderWidth)];
}

- (UIColor *)borderColor {
    return [self associatedValueForKey:_cmd];
}

- (void)setBorderColor:(UIColor *)borderColor {
    [self setAssociateValue:borderColor withKey:@selector(borderColor)];
}

- (BOOL)hadAddObserver {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setHadAddObserver:(BOOL)hadAddObserver {
    [self setAssociateValue:@(hadAddObserver) withKey:@selector(hadAddObserver)];
}

- (BOOL)isRounding {
    return [[self associatedValueForKey:_cmd] boolValue];
}

- (void)setRounding:(BOOL)rounding {
    [self setAssociateValue:@(rounding) withKey:@selector(isRounding)];
}

- (UIRectCorner)corner {
    return [[self associatedValueForKey:_cmd] unsignedLongValue];
}

- (void)setCorner:(UIRectCorner)corner {
    [self setAssociateValue:@(corner) withKey:@selector(corner)];
}

- (CGFloat)radius {
    return [[self associatedValueForKey:_cmd] CGFloatValue];
}

- (void)setRadius:(CGFloat)radius {
    [self setAssociateValue:@(radius) withKey:@selector(radius)];
}

@end
