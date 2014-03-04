//
//  UIHelper.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/16/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSuccess,
    kInfo,
    kWarning,
    kFailure,
    kError,
} NotificationStatus;


@interface UIHelper : NSObject

+ (void)showInfo:(NSString *)info withStatus:(NotificationStatus)status;

+ (void)addShaddowForView:(UIView *)view;
+ (void)removeShaddowForView:(UIView *)view;

+ (void)initializeHeaderLabel:(UILabel *)label;
+ (void)addGradientForView:(UIView *)view;

@end
