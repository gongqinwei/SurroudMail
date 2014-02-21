//
//  WeiChatIAPHelper.m
//  WeiChat
//
//  Created by Qinwei Gong on 2/14/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "WeiChatIAPHelper.h"
#import "Constants.h"


@implementation WeiChatIAPHelper

+ (WeiChatIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static WeiChatIAPHelper * sharedInstance;
    
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      IAP_PRODUCT_ID,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    
    return sharedInstance;
}

@end
