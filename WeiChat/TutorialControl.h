//
//  TutorialControl.h
//  WeiChat
//
//  Created by Qinwei Gong on 3/3/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialControl : UIControl

- (void)addText:(NSString *)text at:(CGRect)frame;
- (void)addImageNamed:(NSString *)imageName at:(CGRect)frame;

@end
