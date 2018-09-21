//
//  ZKIDCardCameraController.h
//  FBSnapshotTestCase
//
//  Created by zhangkai on 2018/9/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ZKIDCardType) {
    ZKIDCardTypeFront,
    ZKIDCardTypeReverse,
};

@protocol ZKIDCardCameraControllerDelegate <NSObject>

- (void)cameraDidFinishShootWithCameraImage:(UIImage *)image;

@end

@interface ZKIDCardCameraController : UIViewController

@property (nonatomic, weak) id<ZKIDCardCameraControllerDelegate> delegate;

- (instancetype)initWithType:(ZKIDCardType)type;

@end

NS_ASSUME_NONNULL_END
