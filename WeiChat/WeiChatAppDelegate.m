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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // In App Purchase
    [WeiChatIAPHelper sharedInstance];
    
    // Weixin
    if (![WXApi registerApp:@"wx68d5a54fe90b5ac3"]) {
        Error(@"Failed to register with Weixin");
    }
    
    SinaWeibo *sinaWeibo = [[SinaWeibo alloc] initWithAppKey:kWeiboAppKey appSecret:kWeiboAppSecret appRedirectURI:kWeiboAppRedirectURI andDelegate:self];
    
    // Sina Vdisk
    VdiskSession *session = [[VdiskSession alloc] initWithAppKey:kVdiskSDKDemoAppKey appSecret:kVdiskSDKDemoAppSecret appRoot:@"sandbox" sinaWeibo:sinaWeibo];
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
        NSString *strMsg = [NSString stringWithFormat:@"Result:%d", resp.errCode];
        Debug(@"Response from Weixin was: %@",strMsg);
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
