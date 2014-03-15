//
//  WeiChatAppDelegate.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/11/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import "WeiChatAppDelegate.h"
#import "Constants.h"
#import "WeiChatIAPHelper.h"


@implementation WeiChatAppDelegate


- (void)setupNavigationBarForiOS7 {
    if (IS_IOS7_AND_UP) {
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        shadow.shadowOffset = CGSizeMake(0, 1);
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                               shadow, NSShadowAttributeName,
                                                               [UIFont fontWithName:APP_BOLD_FONT size:20.0], NSFontAttributeName, nil]];
        
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"iOS7NavBarBackground.png"] forBarMetrics:UIBarMetricsDefault];
//        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    }
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self setupNavigationBarForiOS7];
    
    // In App Purchase
    [WeiChatIAPHelper sharedInstance];
    
    // Weixin
    if (![WXApi registerApp:kWeixinAppId]) {
        Error(@"Failed to register with Weixin");
    }
    
    // Sina Weibo
    [WeiboSDK enableDebugMode:YES]; //temp
    [WeiboSDK registerApp:kWeiboAppKey];
    SinaWeibo *sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kWeiboAppKey appSecret:kWeiboAppSecret appRedirectURI:kWeiboAppRedirectURI andDelegate:self];
    
    // Sina Vdisk
    VdiskSession *session = [[VdiskSession alloc] initWithAppKey:kVdiskSDKDemoAppKey appSecret:kVdiskSDKDemoAppSecret appRoot:@"basic" sinaWeibo:sinaWeibo];
	session.delegate = self;
    [session setRedirectURI:kVdiskSDKDemoAppRedirectURI];
    //session.udid = [[UIDevice currentDevice] uniqueIdentifier];
	[VdiskSession setSharedSession:session];
	[VdiskComplexRequest setNetworkRequestDelegate:self];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[VdiskSession sharedSession] refreshLink];
    [[VdiskSession sharedSession].sinaWeibo applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    Debug(@"----->>>>>>> %@", url);
    return [[VdiskSession sharedSession].sinaWeibo handleOpenURL:url];
//    return [WXApi handleOpenURL:url delegate:self];
//    return [WeiboSDK handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[VdiskSession sharedSession].sinaWeibo handleOpenURL:url];
//    return [WXApi handleOpenURL:url delegate:self];
}


#pragma mark - Weixin delegate

- (void) onReq:(BaseReq*)req {

}

- (void) onResp:(BaseResp*)resp {
    if([resp isKindOfClass:[SendMessageToWXResp class]]) {
        Debug(@"Response from Weixin was: %@", [NSString stringWithFormat:@"Result:%d", resp.errCode]);
    }
}

#pragma mark - VdiskNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
	outstandingRequests++;
	
    if (outstandingRequests >= 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
}

- (void)networkRequestStopped {
    outstandingRequests--;
	
    if (outstandingRequests <= 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo {
    
    Debug(@"sinaweiboDidLogIn userID = %@ accesstoken = %@ expirationDate = %@ refresh_token = %@", sinaweibo.userID, sinaweibo.accessToken, sinaweibo.expirationDate,sinaweibo.refreshToken);
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo {
    
    Debug(@"sinaweiboDidLogOut");
    
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo {
    
    Debug(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error {
    
    Error(@"sinaweibo logInDidFailWithError %@", error);
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error {
    
    Error(@"sinaweiboAccessTokenInvalidOrExpired %@", error);
    
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class])
    {
        
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
//        NSString *title = @"发送结果";
//        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
//        NSString *title = @"认证结果";
//        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:nil
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        
//        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
//        
//        [alert show];
    }
}



//#pragma mark VdiskSessionDelegate methods
//
//- (void)sessionAlreadyLinked:(VdiskSession *)session {
//    Debug(@"sessionAlreadyLinked");
//}
//
//// Login succeeded
//- (void)sessionLinkedSuccess:(VdiskSession *)session {
//    /*
//     VdiskRestClient *restClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
//     [restClient loadAccountInfo];
//     */
//    
//    Debug(@"sessionLinkedSuccess");
//}
//
//// Login failed
//- (void)session:(VdiskSession *)session didFailToLinkWithError:(NSError *)error {
//    Error(@"didFailToLinkWithError:%@", error);
//}
//
//// Log out successfully
//- (void)sessionUnlinkedSuccess:(VdiskSession *)session {
//    Debug(@"sessionUnlinkedSuccess");
//}
//
//- (void)sessionNotLink:(VdiskSession *)session {
//    Debug(@"sessionNotLink");
//}

- (void)sessionExpired:(VdiskSession *)session {
    Debug(@"Vdisk Session Expired. Renewing...");
    
    [session refreshLink];
}


@end
