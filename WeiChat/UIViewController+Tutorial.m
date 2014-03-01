//
//  UIViewController+Tutorial.m
//  WeiChat
//
//  Created by Qinwei Gong on 2/28/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "UIViewController+Tutorial.h"
#import <objc/runtime.h>

static char const * const TapRecognizerKey = "TapRecognizer";

@implementation UIViewController (Tutorial)

@dynamic dismissTap;

- (void)initialize {
    self.dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissTutorial)];
    [self.view addGestureRecognizer:self.dismissTap];
    
    self.view.opaque = NO;
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
}

- (void)dismissTutorial {
    [self.view removeFromSuperview];
}

- (UITapGestureRecognizer *) dismissTap {
    return objc_getAssociatedObject(self, TapRecognizerKey);;
}

- (void) setLeftSwipeRecognizer:(UISwipeGestureRecognizer *)leftSwipeRecognizer {
    objc_setAssociatedObject(self, TapRecognizerKey, leftSwipeRecognizer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
