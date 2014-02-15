//
//  Util.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/16/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Util : NSObject

+ (void)incrementAdvancedUsage;
+ (NSNumber *)getAdvancedUsage;

+ (BOOL)isSameDay:(NSDate*)date1 otherDay:(NSDate*)date2;
+ (BOOL)isDay:(NSDate*)date1 earlierThanDay:(NSDate*)date2;

+ (NSDate *)getDate:(NSString *)date format:(NSString *)format;
+ (NSString *)formatDate:(NSDate *)date format:(NSString *)format;
+ (NSString *)formatCurrency:(NSDecimalNumber *)amount;
+ (NSDecimalNumber *)parseCurrency:(NSString *)str;

+ (NSDecimalNumber *)id2Decimal:(id)number;

+ (NSString *)URLEncode:(NSString *)string;
+ (NSString *)trim:(NSString *)string;
 
@end
