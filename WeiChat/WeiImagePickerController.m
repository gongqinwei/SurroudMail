//
//  WeiImagePickerController.m
//  WeiChat
//
//  Created by Qinwei Gong on 2/21/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "WeiImagePickerController.h"

@interface WeiImagePickerController ()

@end

@implementation WeiImagePickerController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)   // iOS7+ only
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return nil;
}


@end
