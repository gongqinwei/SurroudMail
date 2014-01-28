//
//  WeiChatAppDelegate.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/11/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "VdiskSDK.h"


@interface WeiChatAppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate, VdiskSessionDelegate, VdiskNetworkRequestDelegate, SinaWeiboDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
