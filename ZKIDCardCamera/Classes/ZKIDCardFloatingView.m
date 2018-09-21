//
//  ZKIDCardFloatingView.m
//  FBSnapshotTestCase
//
//  Created by zhangkai on 2018/9/21.
//

#import "ZKIDCardFloatingView.h"
#import <Masonry/Masonry.h>
#import "ZKIDCardCameraController.h"

// iPhone5/5c/5s/SE 4英寸 屏幕宽高：320*568点 屏幕模式：2x 分辨率：1136*640像素
#define iPhone5or5cor5sorSE ([UIScreen mainScreen].bounds.size.height == 568.0)

// iPhone6/6s/7 4.7英寸 屏幕宽高：375*667点 屏幕模式：2x 分辨率：1334*750像素
#define iPhone6or6sor7 ([UIScreen mainScreen].bounds.size.height == 667.0)

// iPhone6 Plus/6s Plus/7 Plus 5.5英寸 屏幕宽高：414*736点 屏幕模式：3x 分辨率：1920*1080像素
#define iPhone6Plusor6sPlusor7Plus ([UIScreen mainScreen].bounds.size.height == 736.0)

@interface ZKIDCardFloatingView ()

@property (nonatomic, strong) CAShapeLayer *IDCardWindowLayer;
@property (nonatomic, strong) NSBundle *resouceBundle;
@property (nonatomic, assign) ZKIDCardType type;

@end

@implementation ZKIDCardFloatingView

- (instancetype)initWithType:(ZKIDCardType)type {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (!self) {
        return nil;
    }
    
    self.type = type;
    self.backgroundColor = [UIColor clearColor];
    CGFloat width = iPhone5or5cor5sorSE ? 240: (iPhone6or6sor7? 240: 270);
    self.IDCardWindowLayer.bounds = (CGRect){CGPointZero, {width, width * 1.574}};
    
    // 最里层镂空
    UIBezierPath *transparentRoundedRectPath = [UIBezierPath bezierPathWithRoundedRect:self.IDCardWindowLayer.frame
                                                                          cornerRadius:self.IDCardWindowLayer.cornerRadius];
    
    // 最外层背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:[UIScreen mainScreen].bounds];
    [path appendPath:transparentRoundedRectPath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor blackColor].CGColor;
    fillLayer.opacity = 0.6;
    [self.layer addSublayer:fillLayer];
    
    // 提示标签
    UILabel *textLabel = UILabel.new;
    textLabel.text = self.type == ZKIDCardTypeFront ? @"对齐身份证正面并点击拍照" : @"对齐身份证背面并点击拍照";
    textLabel.textColor = [UIColor whiteColor];
    textLabel.font = [UIFont systemFontOfSize:14];
    textLabel.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    [self addSubview:textLabel];
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self).offset(-CGRectGetWidth(self.IDCardWindowLayer.frame)/2.f - 20);
        make.centerY.equalTo(self);
    }];
    
    CGFloat facePathWidth, facePathHeight;
    UIImage *image;
    if ((self.type == ZKIDCardTypeFront)) {
        facePathWidth = iPhone5or5cor5sorSE? 95: (iPhone6or6sor7? 120: 150);
        facePathHeight = facePathWidth * 0.812;
        image = [UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"xuxian@2x" ofType:@"png"]];
    } else {
        facePathWidth = iPhone5or5cor5sorSE ? 40: (iPhone6or6sor7 ? 80: 100);
        facePathHeight = facePathWidth;
        image = [UIImage imageWithContentsOfFile:[self.resouceBundle pathForResource:@"Page 1@2x" ofType:@"png"]];
    }
    
    // 国徽、头像
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.transform = CGAffineTransformMakeRotation(M_PI * 0.5);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.type == ZKIDCardTypeFront) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(CGRectGetHeight(self.IDCardWindowLayer.frame)/2.f - facePathWidth/2.f - 30);
        } else {
            make.centerX.equalTo(self).offset(CGRectGetWidth(self.IDCardWindowLayer.frame)/2.f - facePathHeight/2.f - 25);
            make.centerY.equalTo(self).offset(-CGRectGetHeight(self.IDCardWindowLayer.frame)/2.f + facePathWidth/2.f + 20);
        }
        
        make.width.mas_equalTo(facePathWidth);
        make.height.mas_equalTo(facePathHeight);
    }];
                      
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

#pragma mark - getters and setters

- (CAShapeLayer *)IDCardWindowLayer {
    if (!_IDCardWindowLayer) {
        _IDCardWindowLayer = [[CAShapeLayer alloc] init];
        _IDCardWindowLayer.position = self.layer.position;
        _IDCardWindowLayer.cornerRadius = 15.f;
        _IDCardWindowLayer.borderColor = [UIColor whiteColor].CGColor;
        _IDCardWindowLayer.borderWidth = 2;
        
        [self.layer addSublayer:_IDCardWindowLayer];
    }
    return _IDCardWindowLayer;
}

- (NSBundle *)resouceBundle {
  if (!_resouceBundle) {
      _resouceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:self.class] pathForResource:@"ZKIDCardCamera" ofType:@"bundle"]];
  }
  return _resouceBundle;
}
                      
@end
