//
//  VideoRecordViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/15/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAdViewController.h"

@interface VideoRecordViewController : iAdViewController

@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (nonatomic, strong) UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchToAudioButton;

@end
