//
//  SettingsViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 3/4/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoRecordViewController.h"


@interface SettingsViewController : UITableViewController

@property (nonatomic, strong) id<VideoRecorderDelegate> videoRecorderDelegate;

@end
