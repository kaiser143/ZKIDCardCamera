//
//  ZKViewController.m
//  ZKIDCardCamera
//
//  Created by deyang143@126.com on 09/21/2018.
//  Copyright (c) 2018 deyang143@126.com. All rights reserved.
//

#import "ZKViewController.h"
#import <Masonry/Masonry.h>
#import <ZKIDCardCamera/ZKIDCardCameraController.h>

@interface ZKViewController ()

@end

@implementation ZKViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - events Handler

- (IBAction)front {
    ZKIDCardCameraController *controller = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeFront];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)reverse:(id)sender {
    ZKIDCardCameraController *controller = [[ZKIDCardCameraController alloc] initWithType:ZKIDCardTypeReverse];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

@end
