//
//  VideoRecordViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/15/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iAdViewController.h"
#import "Constants.h"


@protocol VideoRecorderDelegate <NSObject>

- (void)didSelectVideoCaptureMode:(VideoCaptureMode)mode;
- (void)didSelectVideoQuality:(VideoQuality)quality;

@end

@interface VideoRecordViewController : iAdViewController

@end
