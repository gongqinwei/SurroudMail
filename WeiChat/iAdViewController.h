//
//  iAdViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 12/19/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import <CoreLocation/CoreLocation.h>
#import "VdiskSDK.h"


#define AD_BANNER_ADJUST_HEIGHT             20
#define AD_BANNER_ANIMATION_DISTANCE_EN     215
#define AD_BANNER_ANIMATION_DISTANCE_CN     252
#define LANGUAGE_OFFSET                     37
#define AD_BANNER_ADJUST_THRESHOLD          400

#define HEAD_VIEW_HEIGHT                    225
#define HEAD_VIEW_RECT                      CGRectMake(3, 3, SCREEN_WIDTH - 6, HEAD_VIEW_HEIGHT)
#define HEAD_VIEW_HIDDEN_RECT               CGRectMake(3, -HEAD_VIEW_HEIGHT - 10, SCREEN_WIDTH - 6, HEAD_VIEW_HEIGHT)
#define SEMI_COVER_VIEW_RECT                CGRectMake(3, HEAD_VIEW_HEIGHT, SCREEN_WIDTH - 6, SCREEN_HEIGHT - HEAD_VIEW_HEIGHT)

#define RECORDING_TIMER_INTERVAL            0.01
#define RECORDING_TIMER_INTERVAL_INVERSE    1 / RECORDING_TIMER_INTERVAL

#define LABEL_ADD_DESCRIPTION               NSLocalizedString(@"Say something...", nil)

typedef enum {
    kWeixinMoments, kWeixinFriends, kSinaWeibo, kSaveToDevice, kUnlinkVdisk, kCancelShare
} ShareActionEnum;

typedef void(^AssetsLibraryWriteContentCompletionBlock)(NSURL *assetURL, NSError *error);

#define SHARE_ACTIONS     [NSArray arrayWithObjects:NSLocalizedString(@"WeChat Moments", nil), NSLocalizedString(@"WeChat Friends", nil), NSLocalizedString(@"Sina Weibo", nil), NSLocalizedString(@"Save in iPhone", nil), @"Unlink Vdisk", NSLocalizedString(@"Cancel", nil), nil]



@interface iAdViewController : UIViewController <UIActionSheetDelegate, ADBannerViewDelegate, CLLocationManagerDelegate, UITextViewDelegate, VdiskSessionDelegate, VdiskComplexUploadDelegate, VdiskRestClientDelegate>

@property (nonatomic, strong) UIView *headView;
//@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *semiCoverView;

@property (nonatomic, strong) UIBarButtonItem *shareButton;
@property (strong, nonatomic) UITextView *contentDescription;
@property (strong, nonatomic) UIButton *geoButton;
@property (strong, nonatomic) UILabel *geoLabel;
@property (nonatomic, strong) ADBannerView *adBanner;
@property (nonatomic, assign) BOOL inputModeChanged;

@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSURL *referenceURL;
@property (nonatomic, strong) NSString *mediaLink;      // video/audio link for share
@property (nonatomic, strong) UILongPressGestureRecognizer *videoButtonPress;
@property (nonatomic, strong) UITapGestureRecognizer *singleTap;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSString *destPath;
@property (nonatomic, strong) VdiskComplexUpload *vdiskUploader;
@property (nonatomic, strong) VdiskRestClient *vdiskRestClient;

@property (nonatomic, assign) ShareActionEnum shareAction;

@property (nonatomic, strong) UIProgressView *uploadProgress;
@property (nonatomic, strong) UIView *uploadProgressOverlay;
@property (nonatomic, strong) UILabel *uploadProgressLabel;
@property (nonatomic, strong) UILabel *uploadProgressTitle;

@property (nonatomic, strong) NSTimer *recordingTimer;
@property (nonatomic, strong) NSDate *pauseStart, *previousFireDate;
@property (nonatomic, strong) NSDate *recordingStartTime;
@property (nonatomic, strong) UIProgressView *recordingProgress;
@property (nonatomic, strong) UILabel *recordingProgressLabel;

@property (nonatomic, strong) UIActivityIndicatorView *savingActivity;
@property (nonatomic, assign) BOOL hasTimedUp;

@property (nonatomic, assign) BOOL needSave;


- (void)raiseADBanner;
- (void)lowerADBanner;

- (void)onShareButtonTapped:(UIBarButtonItem *)sender;
- (void)uploadContent;
- (void)publishContentToWeixin;
- (void)publishContentToSinaWeibo;

- (int)getMaxRecordingDuration;
- (void)updateTimer;
- (void)pauseTimer;
- (void)resumeTimer;
- (void)recordingTimesUp;

//- (void)saveRecordingContentWithCompletionSelector:(SEL)completionSelector;
- (void)saveRecordingContentWithCompletionBlock:(AssetsLibraryWriteContentCompletionBlock)completionBlock;

@end
