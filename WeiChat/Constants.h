//
//  Constants.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/16/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//


#ifndef WeiChat_Constants_h
#define WeiChat_Constants_h

#define DEBUG_MODE

#ifdef DEBUG_MODE
#define Debug( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define Debug( s, ... )
#endif

#define Error( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )


#define ENGLISH             @"en"
#define CHINESE             @"zh"

#define KEYCHAIN_ID         @"WeiChat"

// Version
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

// Color
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

// Dimensions
#define SCREEN_WIDTH            [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT           [UIScreen mainScreen].bounds.size.height

// Fonts
#define APP_BOLD_FONT          @"HelveticaNeue-BoldMT" //@"Arial-BoldMT"
#define APP_FONT               @"HelveticaNeue" //@"Arial"
#define APP_LABEL_BLUE_COLOR   [UIColor colorWithRed:81.0/255.0 green:102.0/255.0 blue:145.0/255.0 alpha:1.0]
#define APP_SYSTEM_BLUE_COLOR  [UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1.0]
#define APP_BUTTON_BLUE_COLOR  [UIColor colorWithRed:50.0/255.0 green:135.0/255.0 blue:225.0/255.0 alpha:1.0]

// Vdisk
#ifndef kVdiskSDKDemoAppKey
#define kVdiskSDKDemoAppKey    @"4282666910"
#endif

#ifndef kVdiskSDKDemoAppRedirectURI
#define kVdiskSDKDemoAppRedirectURI     @"http://weichat.com"
#endif

#ifndef kVdiskSDKDemoAppSecret
#define kVdiskSDKDemoAppSecret     @"153c771e60768808141df52727218293"
#endif

#ifndef kWeiboAppKey
#define kWeiboAppKey    @"1695043515"
#endif

#ifndef kWeiboAppSecret
#define kWeiboAppSecret     @"f682e337fe88b4bd77b6944451ac87d4"
#endif

#ifndef kWeiboAppRedirectURI
#define kWeiboAppRedirectURI     @"https://api.weibo.com/oauth2/default.html"
#endif

// Size
#define NAV_BAR_HEIGHT          44


// APIs
#define VDISK_GET_FILE          @"https://api.weipan.cn/2/files/"


// API Handler typedef
typedef void(^Handler)(NSURLResponse * response, NSData * data, NSError * err);


#endif
