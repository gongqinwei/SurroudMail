//
//  UIHelper.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/16/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import "UIHelper.h"
#import "Constants.h"

#import <QuartzCore/QuartzCore.h>

#define INFO_VIEW_POSITION_Y     150
#define INFO_VIEW_WIDTH          200
#define INFO_VIEW_HEIGHT         150
#define INFO_VIEW_MARGIN         12
#define INFO_VIEW_PADDING        5

#define INFO_ICON_SIZE           20

#define INFO_ALPHA               0.9
#define INFO_CORNER_RADIUS       7
#define INFO_FONT_SIZE           14

#define INFO_SHOW_INTERVAL       1.0
#define INFO_FADEOUT_DURATION    3.5
#define ERROR_FADEOUT_DURATION   4

#define SWITCH_TAB_DURATION      0.3

#define TABLE_SECTION_HEADER_FONT_SIZE    14

@interface UIHelper ()

+ (void)fadeInfo:(NSTimer *)timer;

@end

@implementation UIHelper

+ (void)showInfo:(NSString *)info withStatus:(NotificationStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect window = [[UIScreen mainScreen] applicationFrame];
        CGRect infoFrame = CGRectMake(window.size.width/2 - INFO_VIEW_WIDTH/2, INFO_VIEW_POSITION_Y, INFO_VIEW_WIDTH, INFO_VIEW_HEIGHT);
        
        UIImageView *infoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(INFO_VIEW_MARGIN, INFO_VIEW_MARGIN, INFO_ICON_SIZE, INFO_ICON_SIZE)];
        UIImage *image;
        
        switch (status) {
            case kSuccess:
            {
                image = [UIImage imageNamed:@"success.png"];
            }
                break;
            case kInfo:
            {
                image = [UIImage imageNamed:@"success.png"]; //TODO: should be replaces
            }
                break;
            case kWarning:
            {
                image = [UIImage imageNamed:@"warning.png"];
            }
                break;
            case kFailure:
            {
                image = [UIImage imageNamed:@"warning.png"];  //TODO: should be replaced
            }
                break;
            case kError:
            {
                image = [UIImage imageNamed:@"warning.png"];  //TODO: should be replaced
            }
                break;
            default:
                break;
        }
        
        infoIcon.image = image;
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(INFO_VIEW_MARGIN + INFO_ICON_SIZE + INFO_VIEW_PADDING, INFO_VIEW_MARGIN, INFO_VIEW_WIDTH - INFO_VIEW_MARGIN * 2 - INFO_VIEW_PADDING - INFO_ICON_SIZE, INFO_VIEW_HEIGHT - INFO_VIEW_MARGIN * 2)];
        infoLabel.text = info;
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.backgroundColor = [UIColor clearColor];
        infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        infoLabel.textAlignment=NSTextAlignmentLeft;
        infoLabel.font=[UIFont fontWithName:APP_BOLD_FONT size:INFO_FONT_SIZE];
        infoLabel.numberOfLines = 0;
        [infoLabel sizeToFit];
        
        UIView *infoView = [[UIView alloc] initWithFrame:infoFrame];
        infoView.backgroundColor = [UIColor darkGrayColor];
        infoView.alpha = INFO_ALPHA;
        infoView.layer.cornerRadius = INFO_CORNER_RADIUS;
        infoView.layer.masksToBounds = YES;
        
        [infoView addSubview:infoIcon];
        [infoView addSubview:infoLabel];
        infoView.tag = status;
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:infoView];
        
        [NSTimer scheduledTimerWithTimeInterval:INFO_SHOW_INTERVAL
                                         target:[UIHelper class]
                                       selector:@selector(fadeInfo:)
                                       userInfo:infoView
                                        repeats:NO];
    });
}

+ (void)fadeInfo:(NSTimer *)timer {
    UIView *infoView = timer.userInfo;
    NSTimeInterval duration;
    
    if (infoView.tag == kSuccess || infoView.tag == kInfo) {
        duration = INFO_FADEOUT_DURATION;
    } else {
        duration = ERROR_FADEOUT_DURATION;
    }
    
    [UIView animateWithDuration:duration
                     animations:^{
                         infoView.alpha = 0.0;
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             [infoView removeFromSuperview];
                         }
                     }];
}

+ (void)addShaddowForView:(UIView *)view {
    view.layer.shadowOpacity = 0.8f;
    view.layer.shadowRadius = 10.0f;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
}

+ (void)removeShaddowForView:(UIView *)view {
    view.layer.shadowOpacity = 0.0f;
    view.layer.shadowRadius = 0.0f;
    view.layer.shadowColor = nil;
}

+ (void)initializeHeaderLabel:(UILabel *)label {
    label.font = [UIFont fontWithName:APP_FONT size:TABLE_SECTION_HEADER_FONT_SIZE];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:1];
	label.shadowOffset = CGSizeMake(0, 1);
}

+ (void)addGradientForView:(UIView *)view {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor whiteColor]CGColor], (id)[[UIColor darkGrayColor]CGColor], nil];
    [view.layer addSublayer:gradient];
}


@end
