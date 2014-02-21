//
//  Util.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/16/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import "Util.h"
#import "Constants.h"
#import <Security/Security.h>
#import "KeychainItemWrapper.h"


#define KEYCHAIN_ID             @"WeiChat_YaoShi"

@implementation Util

+ (BOOL)checkAdvancedUsage:(RequestProductsCompletionHandler)completionHandler {
    // Check purchased first...
    if ([[WeiChatIAPHelper sharedInstance] productPurchased:IAP_PRODUCT_ID]) {
        return YES;
    }
    
    // Not purchased yet, check usage so far
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    NSString *advancedUsage = [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
    int usage = [advancedUsage intValue];
    if (usage < FREE_TRIAL) {
        usage++;
        Debug(@"---------------- usage: %d", usage);
        [keychainItem setObject:[NSString stringWithFormat:@"%d", usage] forKey:(__bridge id)(kSecAttrAccount)];
        
        return YES;
    } else {
        [[WeiChatIAPHelper sharedInstance] requestProductsWithCompletionHandler:completionHandler];
        
        return NO;
    }
}

+ (NSString *)getAdvancedUsage {
    KeychainItemWrapper *keychainItem = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    return [keychainItem objectForKey:(__bridge id)(kSecAttrAccount)];
}


+ (BOOL)isSameDay:(NSDate *)date1 otherDay:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];
    
    return [comp1 day]  == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

+ (BOOL)isDay:(NSDate *)date1 earlierThanDay:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents *comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents *comp2 = [calendar components:unitFlags fromDate:date2];
    
//    Debug(@"%d", [comp1 year]);
//    Debug(@"%d", [comp1 month]);
//    Debug(@"%d", [comp1 day]);
//    Debug(@"%d", [comp2 year]);
//    Debug(@"%d", [comp2 month]);
//    Debug(@"%d", [comp2 day]);
    
    if ([comp1 year] != [comp2 year]) {
        return [comp1 year] < [comp2 year];
    } else {
        if ([comp1 month] != [comp2 month]) {
            return [comp1 month] < [comp2 month];
        } else {
            return [comp1 day] < [comp2 day];
        }
    }
    
//    if ([comp1 year] == [comp2 year]) {
//        if ([comp1 month] == [comp2 month]) {
//            return [comp1 day] < [comp2 day];
//        } else  {
//            return [comp1 month] < [comp2 month];
//        }
//    } else {
//        if([comp1 day] < [comp2 day]) {
//            Debug(@"true");
//        } else {
//            Debug(@"false");
//        }
//        return [comp1 day] < [comp2 day];
//    }
}

+ (NSDecimalNumber *)parseCurrency:(NSString *)str {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    if ([[Util trim:str] hasPrefix:@"$"]) {
        [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    } else {
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    
    NSNumber *number = [formatter numberFromString:str];
    return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
}

+ (NSString *)formatCurrency:(NSDecimalNumber *)amount {
    if (!amount) {
        return @"$0.00";
    }
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    return [formatter stringFromNumber:amount];
}

+ (NSDate *)getDate:(NSString *)date format:(NSString *)format {
    if (format == nil) {
        format = @"yyyy-MM-dd";
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:format];
    
    return [df dateFromString: date];
}

+ (NSString *)formatDate:(NSDate *)date format:(NSString *)format {
    if (format == nil) {
        format = @"MM/dd/yyyy";
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    
    return [formatter stringFromDate:date];
}

+ (NSDecimalNumber *)id2Decimal:(id)number {
    if (!number || number == [NSNull null]) {
        return [NSDecimalNumber zero];
    } else {
        return [[NSDecimalNumber alloc] initWithDouble:[number doubleValue]];
    }
}

+ (NSString *)URLEncode:(NSString *)string {
    NSString *encodedEmail = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (__bridge CFStringRef)string,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8 );
    return encodedEmail;
}

+ (NSString *)trim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
