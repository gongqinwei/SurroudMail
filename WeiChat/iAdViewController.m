//
//  iAdViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/19/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import "iAdViewController.h"
#import "Constants.h"


#define iAd_ANIMATION_DURATION                          0.25
#define LABEL_ADD_DESCRIPTION                           @"Say something..."
#define WEICHAT_COPYRIGHT                               @"© 2014 WeiChat, Inc."

#define ACTION_SHEET_TITLE                              @"Share to"

#define UPLOAD_PROGRESS_OVERLAY_WIDTH                   200
#define UPLOAD_PROGRESS_OVERLAY_HEIGHT                  100
#define UPLOAD_PROGRESS_OVERLAY_Y                       85
#define UPLOAD_PROGRESS_OVERLAY_SHRINK_RECT             CGRectMake(SCREEN_WIDTH/2 - 0.5, UPLOAD_PROGRESS_OVERLAY_Y + UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 - 0.5, 1, 1)
#define UPLOAD_PROGRESS_OVERLAY_RECT                    CGRectMake(SCREEN_WIDTH/2 - UPLOAD_PROGRESS_OVERLAY_WIDTH/2, UPLOAD_PROGRESS_OVERLAY_Y, UPLOAD_PROGRESS_OVERLAY_WIDTH, UPLOAD_PROGRESS_OVERLAY_HEIGHT)

#define UPLOAD_PROGRESS_BAR_MARGIN_SIDE                 20
#define UPLOAD_PROGRESS_BAR_RECT                        CGRectMake(UPLOAD_PROGRESS_BAR_MARGIN_SIDE, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 - 3, UPLOAD_PROGRESS_OVERLAY_WIDTH - UPLOAD_PROGRESS_BAR_MARGIN_SIDE*2, 1)
//#define UPLOAD_PROGRESS_BAR_SHRINK_RECT                 CGRectMake(SCREEN_WIDTH/2 - 0.5, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 - 3, 1, 1)

#define UPLOAD_PROGRESS_LABEL_WIDTH                     60
#define UPLOAD_PROGRESS_LABEL_HEIGHT                    20
#define UPLOAD_PROGRESS_LABEL_RECT                      CGRectMake(UPLOAD_PROGRESS_OVERLAY_WIDTH/2 - UPLOAD_PROGRESS_LABEL_WIDTH/2, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 + 14, UPLOAD_PROGRESS_LABEL_WIDTH, UPLOAD_PROGRESS_LABEL_HEIGHT)
#define UPLOAD_PROGRESS_LABEL_SHRINK_RECT               CGRectMake(SCREEN_WIDTH/2 - 0.5, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 + 7, 1, 1)

#define UPLOAD_PROGRESS_TITLE_RECT                      CGRectMake(UPLOAD_PROGRESS_OVERLAY_WIDTH/2 - 50, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 - 36, 100, UPLOAD_PROGRESS_LABEL_HEIGHT)
#define UPLOAD_PROGRESS_TITLE_SHRINK_RECT               CGRectMake(UPLOAD_PROGRESS_OVERLAY_WIDTH/2 - 0.5, UPLOAD_PROGRESS_OVERLAY_HEIGHT/2 - 18, 1, 1)
#define UPLOAD_PROGRESS_TITLE                           @"Uploading..."

#define UPLOAD_PROGRESS_OVERLAY_ANIMATION_DURATION      0.3

#define COPYRIGHT_RECT                                  CGRectMake(0, SCREEN_HEIGHT - 90, SCREEN_WIDTH, 15)

#define GEO_BUTTON_RECT                                 CGRectMake(32, 182, 23, 32)
#define GEO_LABEL_RECT                                  CGRectMake(60, 195, 249, 21)
#define DESCRIPTION_TEXT_AREA_RECT                      CGRectMake(80, 10, 230, 170)


@interface iAdViewController ()

@end

@implementation iAdViewController

- (void)publishContentToWeixin {}

- (void)publishContentToSinaWeibo {}

- (void)publishContent {
    if (self.shareAction == kWeixinFriends || self.shareAction == kWeixinMoments) {
        [self publishContentToWeixin];
    } else if (self.shareAction == kSinaWeibo) {
        [self publishContentToSinaWeibo];
    }
}

//- (void)saveRecordingContentWithCompletionSelector:(SEL)completionSelector {
//    if (!completionSelector) {
//        self.needSave = NO;
//    }
//}

- (void)saveRecordingContentWithCompletionBlock:(AssetsLibraryWriteContentCompletionBlock)completionBlock {

}

- (void)toggleUploadProgress:(BOOL)show {
    if (show) {
        self.uploadProgressOverlay.hidden = NO;
        self.uploadProgress.hidden = NO;
        self.uploadProgress.progress = 0.0;
        self.uploadProgressLabel.text = @"0.0%";
        self.view.userInteractionEnabled = NO;
        self.shareButton.enabled = NO;
    } else {
        self.uploadProgress.hidden = YES;
        self.view.userInteractionEnabled = YES;
        self.shareButton.enabled = YES;
    }
    
    [UIView animateWithDuration:UPLOAD_PROGRESS_OVERLAY_ANIMATION_DURATION
                          delay: 0.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if (show) {
                             self.uploadProgressOverlay.frame = UPLOAD_PROGRESS_OVERLAY_RECT;
                             self.uploadProgressTitle.frame = UPLOAD_PROGRESS_TITLE_RECT;
                             self.uploadProgressLabel.frame = UPLOAD_PROGRESS_LABEL_RECT;
                         } else {
                             self.uploadProgressOverlay.frame = UPLOAD_PROGRESS_OVERLAY_SHRINK_RECT;
                             self.uploadProgressTitle.frame = UPLOAD_PROGRESS_TITLE_SHRINK_RECT;
                             self.uploadProgressLabel.frame = UPLOAD_PROGRESS_LABEL_SHRINK_RECT;
                         }
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             if (!show) {
                                 self.uploadProgressOverlay.hidden = YES;
                             }
                             
                             self.uploadProgress.progress = 0.0f;
                         }
                     }
     ];
}

- (void)uploadContent {
    [self toggleUploadProgress:YES];
}

- (void)validateVdiskSessionOrUpload {
    VdiskSession *vDiskSession = [VdiskSession sharedSession];
    
    if ([vDiskSession isLinked]) {
        [self uploadContent];
    } else {
//        [[VdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeDefault];
        [[VdiskSession sharedSession] linkWithSessionType:kVdiskSessionTypeWeiboAccessToken];
    }
}

- (void)onShareButtonTapped:(UIBarButtonItem *)sender {
    [self.contentDescription resignFirstResponder];
    
    UIActionSheet *actions = [[UIActionSheet alloc] init];
    actions.title = ACTION_SHEET_TITLE;
    actions.delegate = self;
    
    [actions addButtonWithTitle:SHARE_ACTIONS[kWeixinMoments]];
    [actions addButtonWithTitle:SHARE_ACTIONS[kWeixinFriends]];
    [actions addButtonWithTitle:SHARE_ACTIONS[kSinaWeibo]];
    [actions addButtonWithTitle:SHARE_ACTIONS[kSaveToDevice]];
    [actions addButtonWithTitle:SHARE_ACTIONS[kUnlinkVdisk]];
    [actions addButtonWithTitle:SHARE_ACTIONS[kCancelShare]];
    
    actions.cancelButtonIndex = kCancelShare;
    
    
    [[[actions valueForKey:@"_buttons"] objectAtIndex:kWeixinMoments] setImage:[UIImage imageNamed:@"WeixinMoments.png"] forState:UIControlStateNormal];
    [[[actions valueForKey:@"_buttons"] objectAtIndex:kWeixinFriends] setImage:[UIImage imageNamed:@"WeixinFriends.png"] forState:UIControlStateNormal];
    [[[actions valueForKey:@"_buttons"] objectAtIndex:kSinaWeibo] setImage:[UIImage imageNamed:@"SinaWeibo.png"] forState:UIControlStateNormal];
    [[[actions valueForKey:@"_buttons"] objectAtIndex:kSaveToDevice] setImage:[UIImage imageNamed:@"PhotoAlbum.png"] forState:UIControlStateNormal];
    
    [actions showFromBarButtonItem:self.shareButton animated:YES];
}

- (void)onGeoButtonTapped:(UIButton *)sender {
    self.currentLocation = nil;
    
    if (self.geoLabel.hidden) {
//        [self.geoButton setImage:[UIImage imageNamed:@"GeoOn.png"] forState:UIControlStateNormal];
        self.geoLabel.hidden = NO;
        [self.locationManager startUpdatingLocation];
    } else {
        [self.geoButton setImage:[UIImage imageNamed:@"GeoOff.png"] forState:UIControlStateNormal];
        self.geoLabel.hidden = YES;
    }
    
    [self.contentDescription resignFirstResponder];
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture {
    [self.contentDescription endEditing:YES];
}

- (void)offsetADBannerBy:(int)distance {
    [UIView animateWithDuration:iAd_ANIMATION_DURATION
                     animations:^{
                         self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, distance);
                     }];
}

- (void)raiseADBanner {
    if ([[[NSLocale currentLocale] localeIdentifier] hasPrefix:CHINESE]) {
        [self offsetADBannerBy:-AD_BANNER_ANIMATION_DISTANCE_CN];
    } else {
        [self offsetADBannerBy:-AD_BANNER_ANIMATION_DISTANCE_EN];
    }
}

- (void)lowerADBanner {
    if ([[[NSLocale currentLocale] localeIdentifier] hasPrefix:CHINESE]) {
        [self offsetADBannerBy:AD_BANNER_ANIMATION_DISTANCE_CN];
    } else {
        [self offsetADBannerBy:AD_BANNER_ANIMATION_DISTANCE_EN];
    }
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    banner.alpha = 1;
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    banner.alpha = 0;
    [UIView commitAnimations];
}

- (void)keyboardModeChange:(NSNotification *)aNotification {
    self.inputModeChanged = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Vdisk session
    VdiskSession *vDiskSession = [VdiskSession sharedSession];
    vDiskSession.delegate = nil;
    vDiskSession.delegate = self;
    
    // Vdisk REST Client
    [self.vdiskRestClient cancelAllRequests];
    self.vdiskRestClient.delegate = nil;
    self.vdiskRestClient.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:RGBCOLOR(0xe1, 0xe0, 0xde)];
    
    self.headView = [[UIView alloc]initWithFrame:HEAD_VIEW_RECT];
    self.headView.layer.shadowOffset = CGSizeMake(0, 3);
    self.headView.layer.shadowRadius = 5.0;
    self.headView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.headView.layer.shadowOpacity = 0.8;
    [self.headView setBackgroundColor:[UIColor whiteColor]];
    self.headView.alpha = 0.0;

    
    //                                 UIImage *image = [UIImage imageNamed:@"micro_messenger.png"];
    //                                 NSInteger tlx = (headView.frame.size.width -  image.size.width) / 2;
    //                                 NSInteger tly = 20;
    //
    //                                 UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(tlx, tly, image.size.width, image.size.height)];
    //                                 [imageView setImage:image];
    //                                 [headView addSubview:imageView];
    
    //                                 UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, tly + image.size.height, width, 40)];
    //                                 [title setText:@"WeChat OpenAPI Sample Demo"];
    //                                 title.font = [UIFont systemFontOfSize:17];
    //                                 title.textColor = RGBCOLOR(0x11, 0x11, 0x11);
    //                                 title.textAlignment = UITextAlignmentCenter;
    //                                 title.backgroundColor = [UIColor clearColor];
    //                                 [headView addSubview:title];
    
    [self.view addSubview:self.headView];
    
//    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, HEAD_VIEW_HEIGHT, SCREEN_WIDTH, 1)];
//    self.lineView.backgroundColor = [UIColor blackColor];
//    self.lineView.alpha = 0.0f;
//    [self.view addSubview:self.lineView];
    
    // Description text view
    self.contentDescription = [[UITextView alloc] initWithFrame:DESCRIPTION_TEXT_AREA_RECT];
    self.contentDescription.hidden = YES;
//        self.videoDescription.layer.borderWidth = 1.0;
//        self.videoDescription.layer.borderColor = [[UIColor lightGrayColor] CGColor];
//        self.videoDescription.layer.cornerRadius = 10.0;
    self.contentDescription.delegate = self;
    self.contentDescription.returnKeyType = UIReturnKeyDefault;
    self.contentDescription.text = LABEL_ADD_DESCRIPTION;
    self.contentDescription.font = [UIFont fontWithName:APP_FONT size:15];
    self.contentDescription.textColor = [UIColor lightGrayColor];
    [self.headView addSubview:self.contentDescription];
    
    self.geoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.geoButton setImage:[UIImage imageNamed:@"GeoOff.png"] forState:UIControlStateNormal];
    [self.geoButton addTarget:self action:@selector(onGeoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.geoButton setFrame:GEO_BUTTON_RECT];
    self.geoButton.hidden = YES;
    [self.headView addSubview:self.geoButton];
    
    self.geoLabel = [[UILabel alloc] initWithFrame:GEO_LABEL_RECT];
    self.geoLabel.font = [UIFont fontWithName:APP_FONT size:11];
    self.geoLabel.hidden = YES;
    [self.headView addSubview:self.geoLabel];
    
    // Upload progress
    self.uploadProgressOverlay = [[UIView alloc] initWithFrame:UPLOAD_PROGRESS_OVERLAY_SHRINK_RECT];
    self.uploadProgressOverlay.backgroundColor = [UIColor darkGrayColor];
    self.uploadProgressOverlay.alpha = 0.6;
    self.uploadProgressOverlay.layer.cornerRadius = 3;
    self.uploadProgressOverlay.layer.masksToBounds = YES;
    self.uploadProgressOverlay.hidden = YES;
    
    self.uploadProgressTitle = [[UILabel alloc] initWithFrame:UPLOAD_PROGRESS_TITLE_SHRINK_RECT];
    self.uploadProgressTitle.text = UPLOAD_PROGRESS_TITLE;
    self.uploadProgressTitle.font = [UIFont fontWithName:APP_BOLD_FONT size:13];
    self.uploadProgressTitle.backgroundColor = [UIColor clearColor];
    self.uploadProgressTitle.textColor = [UIColor whiteColor];
    self.uploadProgressTitle.textAlignment = NSTextAlignmentCenter;
    [self.uploadProgressOverlay addSubview:self.uploadProgressTitle];
    
    self.uploadProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.uploadProgress.frame = UPLOAD_PROGRESS_BAR_RECT;
    self.uploadProgress.hidden = YES;
    self.uploadProgress.progress = 0.0f;
    [self.uploadProgressOverlay addSubview:self.uploadProgress];
    
    self.uploadProgressLabel = [[UILabel alloc] initWithFrame:UPLOAD_PROGRESS_LABEL_SHRINK_RECT];
    self.uploadProgressLabel.font = [UIFont fontWithName:APP_FONT size:13];
    self.uploadProgressLabel.backgroundColor = [UIColor clearColor];
    self.uploadProgressLabel.textColor = [UIColor whiteColor];
    self.uploadProgressLabel.textAlignment = NSTextAlignmentCenter;
    [self.uploadProgressOverlay addSubview:self.uploadProgressLabel];
    
    [self.view addSubview:self.uploadProgressOverlay];
    
    // Recording progress
    self.recordingProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.recordingProgress.progress = 0.0f;
    
    self.recordingProgressLabel = [[UILabel alloc] init];
    self.recordingProgressLabel.text = @"00:00";
    self.recordingProgressLabel.font = [UIFont fontWithName:APP_BOLD_FONT size:15];
    self.recordingProgressLabel.textColor = [UIColor whiteColor];
    self.recordingProgressLabel.backgroundColor = [UIColor clearColor];
    self.recordingProgressLabel.textAlignment = NSTextAlignmentCenter;
    
    self.savingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.savingActivity.hidesWhenStopped = YES;
    [self.savingActivity stopAnimating];
    
//    self.recordingLength = 0.0;
    self.hasTimedUp = NO;
    
    self.needSave = NO;
    
    // CLLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.geocoder = [[CLGeocoder alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardModeChange:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
    
    self.singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [self.view addGestureRecognizer:self.singleTap];
    
    // Vdisk REST Client
    self.vdiskRestClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
    
    // Copyright
    UILabel *copyright = [[UILabel alloc] initWithFrame:COPYRIGHT_RECT];
    copyright.text = WEICHAT_COPYRIGHT;
    copyright.font = [UIFont fontWithName:APP_FONT size:14];
    copyright.textColor = [UIColor lightGrayColor];
    copyright.backgroundColor = [UIColor clearColor];
    copyright.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:copyright];
    
    // iAd
    self.adBanner = [[ADBannerView alloc] initWithFrame:CGRectZero];
    self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, SCREEN_HEIGHT - self.adBanner.frame.size.height - self.navigationController.navigationBar.frame.size.height - AD_BANNER_ADJUST_HEIGHT);
    [self.adBanner setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view addSubview:self.adBanner];
    self.adBanner.delegate = self;
    self.adBanner.alpha = 0;
}

- (int)getMaxRecordingDuration {
    return 0;
}

- (void)recordingTimesUp {
    // to be overridden
}

- (void)updateTimer {
    NSTimeInterval duration = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSinceDate:self.recordingStartTime];
    self.recordingProgress.progress = duration / [self getMaxRecordingDuration];
    
    if ((int)(duration * RECORDING_TIMER_INTERVAL_INVERSE) == (int)duration * RECORDING_TIMER_INTERVAL_INVERSE) {
        int sec = duration;
        int min = 0;
        NSString *currentTime = [NSString stringWithFormat:@"%02d:%02d", min, sec];
        self.recordingProgressLabel.text = currentTime;
    }
    
    if (duration > [self getMaxRecordingDuration]) {
        [self recordingTimesUp];
    }
}

- (void)pauseTimer {
    self.pauseStart = [NSDate dateWithTimeIntervalSinceNow:0];
    
    self.previousFireDate = self.recordingTimer.fireDate;
    self.recordingTimer.fireDate = [NSDate distantFuture];
}

- (void)resumeTimer {
    float pauseTime = -1 * [self.pauseStart timeIntervalSinceNow];
    self.recordingStartTime = [self.recordingStartTime dateByAddingTimeInterval:pauseTime];
    
    self.recordingTimer.fireDate = [self.previousFireDate initWithTimeInterval:pauseTime sinceDate:self.previousFireDate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Text View Delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.contentDescription.textColor == [UIColor lightGrayColor]) {
        self.contentDescription.text = @"";
        self.contentDescription.textColor = [UIColor blackColor];
    }
    
    if (self.adBanner.frame.origin.y > AD_BANNER_ADJUST_THRESHOLD) {
        [self raiseADBanner];
    }
    
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView {
    if (self.inputModeChanged) {
        self.inputModeChanged = NO;
    } else {
        [self addPlaceHolderText];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self addPlaceHolderText];
    
    if (self.adBanner.frame.origin.y < AD_BANNER_ADJUST_THRESHOLD) {
        [self lowerADBanner];
    }
    
}

- (void)addPlaceHolderText {
    if(self.contentDescription.text.length == 0){
        self.contentDescription.textColor = [UIColor lightGrayColor];
        self.contentDescription.text = LABEL_ADD_DESCRIPTION;
        [self.contentDescription resignFirstResponder];
    }
}

#pragma mark - CLLocation Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
    
    [self.locationManager stopUpdatingLocation];
    
    if (self.currentLocation != nil) {
        [self.geocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error == nil && [placemarks count] > 0) {
                [self.geoButton setImage:[UIImage imageNamed:@"GeoOn.png"] forState:UIControlStateNormal];
                
                self.placemark = [placemarks lastObject];
                //                NSArray *POIs = self.placemark.areasOfInterest;
                //                Debug(@"POI: %d %@", POIs.count, POIs[0]);
                
                self.geoLabel.text = [NSString stringWithFormat:@"%@, %@, %@, %@",
                                      //                                      self.placemark.subThoroughfare,
                                      self.placemark.thoroughfare,
                                      self.placemark.locality,
                                      self.placemark.administrativeArea,
                                      self.placemark.country];
            }
        } ];
    }
}


#pragma mark - Vdisk Session Delegate methods

- (void)sessionAlreadyLinked:(VdiskSession *)session {
    Debug(@"Vdisk Session Already Linked");
}

// Login succeeded
- (void)sessionLinkedSuccess:(VdiskSession *)session {
    /*
     VdiskRestClient *restClient = [[VdiskRestClient alloc] initWithSession:[VdiskSession sharedSession]];
     [restClient loadAccountInfo];
     */
    
    Debug(@"Vdisk Session Linked Success");
    
    [self validateVdiskSessionOrUpload];
}

// Login failed
- (void)session:(VdiskSession *)session didFailToLinkWithError:(NSError *)error {
    Error(@"Vdisk Session failed to Link With Error:%@", error);
}

// Log out successfully
- (void)sessionUnlinkedSuccess:(VdiskSession *)session {
    Debug(@"Vdisk Session Unlinked Success");
}

- (void)sessionNotLink:(VdiskSession *)session {
    Debug(@"Vdisk Session Not Link");
}

- (void)sessionExpired:(VdiskSession *)session {
    Debug(@"Vdisk session Expired. Renewing...");
    
    [session refreshLink];
}


#pragma mark - VdiskComplexUploadDelegate

- (void)complexUpload:(VdiskComplexUpload *)complexUpload startedWithStatus:(kVdiskComplexUploadStatus)status destPath:(NSString *)destPath srcPath:(NSString *)srcPath {
    switch (status) {
        case kVdiskComplexUploadStatusLocateHost:
            Debug(@"kVdiskComplexUploadStatusLocateHost");
            break;
        case kVdiskComplexUploadStatusCreateFileSHA1:
            Debug(@"kVdiskComplexUploadStatusCreateFileSHA1");
            break;
        case kVdiskComplexUploadStatusInitialize:
            Debug(@"kVdiskComplexUploadStatusInitialize:%@", self.vdiskUploader.fileSHA1);
            break;
        case kVdiskComplexUploadStatusSigning:
            Debug(@"kVdiskComplexUploadStatusSigning");
            break;
        case kVdiskComplexUploadStatusCreateFileMD5s:
            Debug(@"kVdiskComplexUploadStatusCreateFileMD5s");
            break;
        case kVdiskComplexUploadStatusUploading:
            Debug(@"kVdiskComplexUploadStatusUploading:%lu", (unsigned long)self.vdiskUploader.pointer);
            break;
        case kVdiskComplexUploadStatusMerging:
            Debug(@"kVdiskComplexUploadStatusMerging");
            break;
        default:
            break;
    }
    
    if (status == kVdiskComplexUploadStatusUploading) {
//        [_progressLabel setHidden:NO];
//        [_progressView setHidden:NO];
    }
}

- (void)complexUpload:(VdiskComplexUpload *)complexUpload finishedWithMetadata:(VdiskMetadata *)metadata destPath:(NSString *)destPath srcPath:(NSString *)srcPath {
    [self toggleUploadProgress:NO];
    
    self.destPath = nil;
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:srcPath error:nil];
    
    [self.vdiskRestClient loadSharableLinkForFile:metadata.path];
}

- (void)complexUpload:(VdiskComplexUpload *)complexUpload updateProgress:(CGFloat)newProgress destPath:(NSString *)destPath srcPath:(NSString *)srcPath {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.uploadProgress setProgress:newProgress];
        self.uploadProgressLabel.text = [NSString stringWithFormat:@"%.1f%%", newProgress * 100.0f];
    });
}

- (void)complexUpload:(VdiskComplexUpload *)complexUpload failedWithError:(NSError *)error destPath:(NSString *)destPath srcPath:(NSString *)srcPath {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR!!" message:[NSString stringWithFormat:@"Error!\n----------------\nerrno:%ld\n%@\%@\n----------------", (long)error.code, error.localizedDescription, [error userInfo]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alertView show];
    
    self.destPath = nil;
    
    //delete tmp file
    [[NSFileManager defaultManager] removeItemAtPath:[error.userInfo objectForKey:@"sourcePath"] error:nil];
}


#pragma mark - Vdisk Rest Client delegate

- (void)restClient:(VdiskRestClient *)restClient loadedSharableLink:(NSString *)link forFile:(NSString *)path {
    self.mediaLink = link;
    
    if (self.shareAction == kWeixinMoments || self.shareAction == kWeixinFriends) {
        [self publishContentToWeixin];
    } else if (self.shareAction == kSinaWeibo) {
        [self publishContentToSinaWeibo];
    }
}

- (void)restClient:(VdiskRestClient *)restClient loadSharableLinkFailedWithError:(NSError *)error {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ERROR!!" message:[NSString stringWithFormat:@"Error!\n----------------\nerrno:%ld\n%@\%@\n----------------", (long)error.code, error.localizedDescription, [error userInfo]] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    
    [alertView show];
}


#pragma mark - Action sheet delegate

//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
//}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.shareAction = (ShareActionEnum)buttonIndex;
    
    switch (buttonIndex) {
        case kWeixinMoments:
        case kWeixinFriends:
        case kSinaWeibo:
            if (self.mediaLink) {
                [self publishContent];
            } else {
                [self validateVdiskSessionOrUpload];
            }
            break;
        case kSaveToDevice:
        {
            [self saveRecordingContentWithCompletionBlock:^(NSURL *assetURL, NSError *error) {
                if (!error) {
                    self.needSave = NO;
                    self.referenceURL = assetURL;
                }
            }];
        }
            break;
        case kUnlinkVdisk:
            [[VdiskSession sharedSession] unlink];
            break;
        default:
            break;
    }
}



@end
