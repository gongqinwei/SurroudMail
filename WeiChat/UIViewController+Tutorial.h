//
//  UIViewController+Tutorial.h
//  WeiChat
//
//  Created by Qinwei Gong on 2/28/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Tutorial)

@property (nonatomic, strong) UITapGestureRecognizer *dismissTap;

- (void)dismissTutorial;

@end
