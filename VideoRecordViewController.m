//
//  VideoRecordViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/15/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#import "VideoRecordViewController.h"
#import "Constants.h"
#import "UIHelper.h"
#import "WXApi.h"
#import "VideoSoundTrackViewController.h"
#import "WeiChatIAPHelper.h"
#import "WeiImagePickerController.h"
#import <CoreMedia/CoreMedia.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>
#import <AssetsLibrary/AssetsLibrary.h>


#define VDISK_VIDEO_URL_PREFIX      @"http://vdisk.weibo.com/wap/fp/"
#define LABEL_FAIL_TO_SAVE_VIDEO    NSLocalizedString(@"Failed to save video!", nil)
#define SAVE_VIDEO_PROMPT           NSLocalizedString(@"Save current video to Camera Roll?", nil)


#define CAMCORDER_IMG_NAME          @"Aperture93.png"
//#define CAMCORDER_CLOSED_IMG_NAME   @"Aperture55.png"

#define PLAY_THUMBNAIL_SIZE         55
#define VIDEO_THUMBNAIL_SIZE_SMALL  67
#define VIDEO_THUMBNAIL_SIZE_BIG    93
#define PLAY_THUMBNAIL_RECT         CGRectMake(20, 20, PLAY_THUMBNAIL_SIZE, PLAY_THUMBNAIL_SIZE)
#define VIDEO_THUMBNAIL_INIT_RECT   CGRectMake((SCREEN_WIDTH - VIDEO_THUMBNAIL_SIZE_BIG) / 2, (IS_IOS7_AND_UP ? 220 : 160), VIDEO_THUMBNAIL_SIZE_BIG, VIDEO_THUMBNAIL_SIZE_BIG)
#define VIDEO_THUMBNAIL_AFTER_RECT  CGRectMake((SCREEN_WIDTH - VIDEO_THUMBNAIL_SIZE_SMALL) / 2, HEAD_VIEW_HEIGHT + 70 + (IS_IOS7_AND_UP ? 60 : 0), VIDEO_THUMBNAIL_SIZE_SMALL, VIDEO_THUMBNAIL_SIZE_SMALL)
#define GALLERY_BUTTON_INIT_RECT    CGRectMake(SCREEN_WIDTH - 70, SCREEN_HEIGHT - 70, 48, 48)
#define GALLERY_BUTTON_AFTER_RECT   CGRectMake(SCREEN_WIDTH - 65, SCREEN_HEIGHT - 220, 55, 55)

#define RECORD_BUTTON_RECT          CGRectMake((SCREEN_WIDTH - RECORD_BUTTON_SIZE) / 2, SCREEN_HEIGHT - 110, RECORD_BUTTON_SIZE, RECORD_BUTTON_SIZE);
#define CANCEL_BUTTON_RECT          CGRectMake(50, 14, 50, 20);
#define PROCEED_BUTTON_RECT         CGRectMake(SCREEN_WIDTH - 35, 14, 20, 10);

#define VIDEO_RECORDING_PROGRESS_BAR_RECT       CGRectMake(0, NAV_BAR_HEIGHT, SCREEN_WIDTH, 10)
#define VIDEO_RECORDING_PROGRESS_LABEL_RECT     CGRectMake((SCREEN_WIDTH - 60) / 2, 12, 60, 20)

#define VIDEO_MAX_DURATION_FREE     10  //seconds
#define VIDEO_MAX_DURATION          30  //seconds
#define ANIMATE_TO_POST_DURATION    0.6
#define ANIMATE_TO_REC_DURATION     0.4
#define SWITCH_TO_AUDIO_SEGUE       @"SwitchToAudio"
#define SET_VIDEO_SOUND_SEGUE       @"SetVideoSoundTrack"

#define RECORD_BUTTON_SIZE          120

#define WEIXIN_ALERT_TAG            0
#define ABANDON_VIDEO_ALERT_TAG     1
#define RETAKE_VIDEO_ALERT_TAG      2


@interface VideoRecordViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIVideoEditorControllerDelegate, UIAlertViewDelegate, VideoSoundTrackDelegate>

@property (nonatomic, strong) UIImagePickerController *recorder;
@property (nonatomic, strong) UIImagePickerController *picker;
@property (nonatomic, strong) UIImagePickerController *currentImagePicker;
@property (nonatomic, strong) MPMoviePlayerViewController *player;
@property (nonatomic, strong) UIVideoEditorController *editor;
@property (nonatomic, strong) AVAssetImageGenerator *generator;

@property (nonatomic, strong) UIControl *overlay;
@property (nonatomic, strong) UIButton *galleryButton;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) UIBarButtonItem *nextButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic, strong) NSMutableArray *videoAssets;
@property (nonatomic, strong) NSString *compositionPath;

@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *videoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *switchToAudioButton;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) CALayer *playLayer;
@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) BOOL flashOn;

@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableCompositionTrack *compositionAudioTrack;

@end


@implementation VideoRecordViewController

- (int)getMaxRecordingDuration {
    if ([[WeiChatIAPHelper sharedInstance] productPurchased:IAP_PRODUCT_ID]) {
        return VIDEO_MAX_DURATION;
    } else {
        return VIDEO_MAX_DURATION_FREE;
    }
}

- (void)publishContentToWeixin {
    //if the Weixin app is not installed, show an error
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The Wechat app is not installed", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alert.tag = WEIXIN_ALERT_TAG;
        [alert show];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = NSLocalizedString(@"Video from WeiChat", nil);
    [message setThumbImage:self.thumbnail];
    
    WXVideoObject *ext = [WXVideoObject object];
    Debug(@"------- media link: %@", self.mediaLink);
    
//    ext.videoUrl = [NSString stringWithFormat:@"http://192.168.1.63/?videoSrc=%@", @"https://dl.dropboxusercontent.com/s/83blvpg0zxmic47/IMG_0330.MOV"];
    ext.videoUrl = [NSString stringWithFormat:@"http://192.168.1.63/?videoSrc=%@", @"https://dl.dropbox.com/s/p114jnwdgpi3ll1/IMG_0321.3gp"];
    
    if (self.contentDescription.text.length > 0 && ![self.contentDescription.text isEqualToString:LABEL_ADD_DESCRIPTION]) {
        message.description = self.contentDescription.text;
        ext.videoUrl = [ext.videoUrl stringByAppendingFormat:@"&comment=%@", self.contentDescription.text];
    }
    
    if (self.currentLocation) {
        ext.videoUrl = [ext.videoUrl stringByAppendingFormat:@"&POI=%@&geo=%f,%f", self.geoLabel.text, self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude];
    }
    
//    ext.videoUrl = @"http://share.weiyun.com/7b628f051c3c3081f677bae7b8023bfc";
//    ext.videoUrl = self.mediaLink;
//    ext.videoUrl = [VDISK_VIDEO_URL_PREFIX stringByAppendingString:[self.mediaLink lastPathComponent]];
//    ext.videoUrl = @"http://vdisk.weibo.com/wap/fp/aIsz_qBLOinQf?skiplogin=1";
//    ext.videoUrl = @"http://download-vdisk.sina.com.cn/31365285/dff2516b78b89f51e0872332fa484a5c4b042560?ssig=OFqNlGWwT4&Expires=1388730326&KID=sae,l30zoo1wmz&fn=IMG_0360.MOV";
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    //set the "scene", WXSceneTimeline is for "moments". WXSceneSession allows the user to send a message to friends
    if (self.shareAction == kWeixinFriends) {
        req.scene = WXSceneSession;
    } else if (self.shareAction == kWeixinMoments) {
        req.scene = WXSceneTimeline;
    } else {
        //Invalid action here
        return;
    }
    
    //try to send the request
    if (![WXApi sendReq:req]) {
        [UIHelper showInfo:NSLocalizedString(@"Failed to share video to WeChat", nil) withStatus:kFailure];
    }
}

- (void)onPlayButtonTapped:(UIButton *)sender {
    [self.contentDescription resignFirstResponder];
    
    if (self.mediaURL) {
//        [self performSegueWithIdentifier:SET_VIDEO_SOUND_SEGUE sender:self];
        
        self.player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.mediaURL];
        [self presentMoviePlayerViewControllerAnimated:self.player];
        
        // Register for the playback finished notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
    } else {
        [self presentVideoPicker];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SET_VIDEO_SOUND_SEGUE]) {
        [segue.destinationViewController setOrigMediaURL:self.mediaURL];
        [segue.destinationViewController setComposition:self.composition];
        [segue.destinationViewController setCompositionAudioTrack:self.compositionAudioTrack];
        [segue.destinationViewController setDelegate:self];
    }
}

- (void)onVideoButtonTapped:(UIButton *)sender {
    if (self.needSave && self.mediaURL) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: nil
                              message:SAVE_VIDEO_PROMPT
                              delegate: self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                              otherButtonTitles:NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil), nil];
        alert.tag = RETAKE_VIDEO_ALERT_TAG;
        [alert show];
    } else {
        [self resetImagePicker];
        if (self.mediaURL) {
            [self animateToRecording];
        } else {
            [self presentVideoPicker];
        }
    }
}

- (void)onVideoButtonPressed:(UILongPressGestureRecognizer *)gestureRecognizer {
    [self presentVideoPicker];
    
    [self.videoButton removeGestureRecognizer:self.videoButtonPress];
}

- (void)presentVideoPicker {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [self presentViewController:self.recorder animated:YES completion:nil];
    }
}

- (void)switchToGallery {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [self.recorder dismissViewControllerAnimated:YES completion:^{
            [self presentViewController:self.picker animated:YES completion:nil];
        }];
    }
}

- (void)switchToAudioRecorder {
    [self performSegueWithIdentifier:SWITCH_TO_AUDIO_SEGUE sender:self];
}

- (void)cancelRecording {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)proceedToEdit {
    self.overlay.userInteractionEnabled = NO;
    
    [self.savingActivity startAnimating];
    self.navItem.rightBarButtonItem.customView = self.savingActivity;
    
    [self mergeVideoAssets];
}

#pragma mark - Life Cycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self presentVideoPicker];
    
    [self.videoButton addGestureRecognizer:self.videoButtonPress];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        self.isRecording = NO;
    
        self.title = NSLocalizedString(PRODUCT_NAME, nil);
        
        // Switch to Audio bar button
        UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"MicBarButton.png"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(switchToAudioRecorder) forControlEvents:UIControlEventTouchUpInside];
        [button setFrame:CGRectMake(0, 0, 32, 32)];
//        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        // UIImagePicker Overlay
        self.overlay = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.overlay addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchDown];
        [self.overlay addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
        self.overlay.opaque = NO;
        self.overlay.backgroundColor = [UIColor clearColor];
        
//        // Audio button
//        UIImage *audioImage = [UIImage imageNamed:@"Mic.png"];
//        CGRect audioImgFrame = CGRectMake(10, 12, 48, 48);
//
//        UIButton *audioButton = [[UIButton alloc] initWithFrame:audioImgFrame];
//        [audioButton setBackgroundImage:audioImage forState:UIControlStateNormal];
//        [audioButton addTarget:self action:@selector(switchToAudio) forControlEvents:UIControlEventTouchUpInside];
//        [audioButton setShowsTouchWhenHighlighted:YES];
//        [overlay addSubview:audioButton];

        // Flash button
        Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
        if (captureDeviceClass != nil) {
            AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            if ([device hasTorch] && [device hasFlash]){
                UIImage *flashImage = [UIImage imageNamed:@"FlashOff.png"];
                CGRect flashImgFrame = CGRectMake(5, SCREEN_HEIGHT - 55, flashImage.size.width, flashImage.size.height);

                self.flashButton = [[UIButton alloc] initWithFrame:flashImgFrame];
                [self.flashButton setBackgroundImage:flashImage forState:UIControlStateNormal];
                [self.flashButton addTarget:self action:@selector(switchFlash) forControlEvents:UIControlEventTouchUpInside];
                [self.flashButton setShowsTouchWhenHighlighted:YES];
                self.flashOn = NO;
                [self.overlay addSubview:self.flashButton];
            }
        }

        // Switch camera button
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            UIImage *switchCameraImage = [UIImage imageNamed:@"SwitchCamera.png"];
            CGRect switchCameraImgFrame = CGRectMake(52, SCREEN_HEIGHT - 50, switchCameraImage.size.width, switchCameraImage.size.height);

            UIButton *switchCameraButton = [[UIButton alloc] initWithFrame:switchCameraImgFrame];
            [switchCameraButton setBackgroundImage:switchCameraImage forState:UIControlStateNormal];
            [switchCameraButton addTarget:self action:@selector(switchCamera) forControlEvents:UIControlEventTouchUpInside];
            [switchCameraButton setShowsTouchWhenHighlighted:YES];

            [self.overlay addSubview:switchCameraButton];
        }
    
        // Gallery button
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
            self.galleryButton = [[UIButton alloc] initWithFrame:GALLERY_BUTTON_INIT_RECT];
            [self.galleryButton addTarget:self action:@selector(switchToGallery) forControlEvents:UIControlEventTouchUpInside];
            [self.galleryButton setShowsTouchWhenHighlighted:YES];
            self.galleryButton.layer.cornerRadius = 3;
            self.galleryButton.clipsToBounds = YES;
            self.galleryButton.layer.borderColor = [[UIColor lightGrayColor] CGColor];
            self.galleryButton.layer.borderWidth = 1;
            
            [self.overlay addSubview:self.galleryButton];
        }
    
        // Record button
        UIImage *recordImage = [UIImage imageNamed:@"Record.png"];
        CGRect recordImgFrame = RECORD_BUTTON_RECT;

        self.recordButton = [[UIButton alloc] initWithFrame:recordImgFrame];
        [self.recordButton setBackgroundImage:recordImage forState:UIControlStateNormal];
        [self.recordButton addTarget:self action:@selector(startRecording) forControlEvents:UIControlEventTouchDown];
        [self.recordButton addTarget:self action:@selector(stopRecording) forControlEvents:UIControlEventTouchUpInside];
//        [self.recordButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
        [self.recordButton setShowsTouchWhenHighlighted:YES];
        self.isRecording = NO;
        [self.overlay addSubview:self.recordButton];
        
        
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, NAV_BAR_HEIGHT)];
        navBar.tintColor = [UIColor clearColor];
        navBar.translucent = YES;
        
        [navBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
//        const float colorMask[6] = {222, 255, 222, 255, 222, 255};
//        UIImage *img = [[UIImage alloc] init];
//        UIImage *maskedImage = [UIImage imageWithCGImage: CGImageCreateWithMaskingColors(img.CGImage, colorMask)];
//        [navBar setBackgroundImage:maskedImage forBarMetrics:UIBarMetricsDefault];
        [navBar setShadowImage: [[UIImage alloc] init]];
        
        self.navItem = [[UINavigationItem alloc] init];
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelRecording)];
        self.cancelButton.tintColor = APP_SYSTEM_BLUE_COLOR;
        self.navItem.leftBarButtonItem = self.cancelButton;
        self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(proceedToEdit)];
        self.nextButton.tintColor = APP_SYSTEM_BLUE_COLOR;
        navBar.items = @[ self.navItem ];
        [self.overlay addSubview:navBar];
        
        // Recording timer and progress
        self.recordingProgress.frame = VIDEO_RECORDING_PROGRESS_BAR_RECT;
        self.recordingProgress.progressImage = [UIImage imageNamed:@"Progress.png"];
        [self.overlay addSubview:self.recordingProgress];
        
        self.recordingProgressLabel.frame = VIDEO_RECORDING_PROGRESS_LABEL_RECT;
        [self.overlay addSubview:self.recordingProgressLabel];
        
        
        // Video recorder
        self.recorder = [[WeiImagePickerController alloc] init];
        self.recorder.sourceType = UIImagePickerControllerSourceTypeCamera;
        self.recorder.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        self.recorder.delegate = self;
        self.recorder.allowsEditing = YES;
        self.recorder.showsCameraControls = NO;
        self.recorder.navigationBarHidden = YES;
        self.recorder.toolbarHidden = YES;
        self.recorder.wantsFullScreenLayout = YES;
        self.recorder.cameraOverlayView = self.overlay;
        
        if (IS_IOS7_AND_UP) {
            CGSize screenSize = [[UIScreen mainScreen] bounds].size;
            float cameraAspectRatio = 4.0 / 3.0;
            float imageWidth = floorf(screenSize.width * cameraAspectRatio);
            float scale = ceilf((screenSize.height / imageWidth) * 10.0) / 10.0;
            self.recorder.cameraViewTransform = CGAffineTransformMakeScale(scale, scale);
        }
        
        // Video picker from photo gallery
        self.picker = [[UIImagePickerController alloc] init];
        self.picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
        self.picker.delegate = self;
        self.picker.videoMaximumDuration = [self getMaxRecordingDuration];
//        self.picker.allowsEditing = YES;
        
        // Record Video thumbnail button
        self.videoButtonPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onVideoButtonPressed:)];
        self.videoButtonPress.minimumPressDuration = 0.7;
//        [self.videoButton addGestureRecognizer:self.videoButtonPress];
        
        // Video editor
        self.editor = [[UIVideoEditorController alloc] init];
        self.editor.delegate = self;
        self.editor.videoMaximumDuration = [self getMaxRecordingDuration];
        self.editor.videoQuality = UIImagePickerControllerQualityTypeHigh;
        
        // Movie player
        self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.playButton addTarget:self action:@selector(onPlayButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.playButton setFrame:VIDEO_THUMBNAIL_INIT_RECT];
        [self.headView addSubview:self.playButton];
        
        UIImage *camcorderImg = [UIImage imageNamed:CAMCORDER_IMG_NAME];
        self.videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.videoButton setImage:camcorderImg forState:UIControlStateNormal];
        [self.videoButton addTarget:self action:@selector(onVideoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.videoButton setFrame:VIDEO_THUMBNAIL_INIT_RECT];
        [self.view addSubview:self.videoButton];
        
        UIImage *playImg = [UIImage imageNamed:@"Play.png"];
        self.playLayer = [CALayer layer];
        self.playLayer.contents = (id) playImg.CGImage;
        self.playLayer.frame = CGRectMake((PLAY_THUMBNAIL_SIZE - playImg.size.width) / 2, (PLAY_THUMBNAIL_SIZE - playImg.size.height) / 2, playImg.size.width, playImg.size.height);
        
//        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
//            self.galleryButton = [[UIButton alloc] initWithFrame:GALLERY_BUTTON_INIT_RECT];
//            UIImage *galleryImage = [UIImage imageNamed:@"PhotoLibrary.png"];
//            [self.galleryButton setBackgroundImage:galleryImage forState:UIControlStateNormal];
//            [self.galleryButton addTarget:self action:@selector(switchToGallery) forControlEvents:UIControlEventTouchUpInside];
//            [self.galleryButton setShowsTouchWhenHighlighted:YES];
//            
//            [self.view addSubview:self.galleryButton];
//        }
        
//        self.semiCoverView = [[UIView alloc]initWithFrame:SEMI_COVER_VIEW_RECT];
//        self.semiCoverView.backgroundColor = [UIColor whiteColor];
//        self.semiCoverView.alpha = 0.0;
//        [self.view addSubview:self.semiCoverView];
     
        self.videoAssets = [NSMutableArray array];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Image Picker Delegate

- (void)genThumbnail {
    AVURLAsset *asset=[[AVURLAsset alloc] initWithURL:self.mediaURL options:nil];

    CMTime thumbTime = CMTimeMakeWithSeconds(0, 1);
    self.generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    self.generator.appliesPreferredTrackTransform = YES;
    self.generator.requestedTimeToleranceBefore = kCMTimeZero;
    self.generator.requestedTimeToleranceAfter = kCMTimeZero;
    self.generator.maximumSize = CGSizeMake(110, 110);
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            CGRect thumbnailFrame = CGRectMake(0, 0, PLAY_THUMBNAIL_SIZE, PLAY_THUMBNAIL_SIZE);
            CGImageRef imageRef = CGImageCreateWithImageInRect(im, thumbnailFrame);
            self.thumbnail = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.playButton setImage:self.thumbnail forState:UIControlStateNormal];
                self.playButton.contentMode = UIViewContentModeScaleAspectFit;
            });
        }
    };
    
    [self.generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}

- (void)mergeVideoAssets {
    if (self.compositionPath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.compositionPath error:nil];
    }
    self.composition = nil;
    self.compositionAudioTrack = nil;
    self.composition = [AVMutableComposition composition];
    
    // Video
    AVMutableCompositionTrack *compositionVideoTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    
    videoComposition.frameDuration = CMTimeMake(1,30);
    videoComposition.renderScale = 1.0;
    
    AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:compositionVideoTrack];
    
    // Audio
    self.compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    float time = 0;
    for (AVAsset *sourceAsset in self.videoAssets) {
        NSError *error = nil;
        
        BOOL ok = NO;
        AVAssetTrack *sourceVideoTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *sourceAudioTrack = [[sourceAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

        [compositionVideoTrack setPreferredTransform:sourceVideoTrack.preferredTransform];
        
//        CGSize temp = CGSizeApplyAffineTransform(sourceVideoTrack.naturalSize, sourceVideoTrack.preferredTransform);
//        CGSize size = CGSizeMake(fabsf(temp.width), fabsf(temp.height));
//        CGAffineTransform transform = sourceVideoTrack.preferredTransform;
//        
//        videoComposition.renderSize = sourceVideoTrack.naturalSize;
//        
//        if (size.width > size.height) {
//            [layerInstruction setTransform:transform atTime:CMTimeMakeWithSeconds(time, 30)];
//        } else {
//            float s = size.width/size.height;
//            
//            CGAffineTransform new = CGAffineTransformConcat(transform, CGAffineTransformMakeScale(s,s));
//            
//            float x = (size.height - size.width*s)/2;
//            
//            CGAffineTransform newer = CGAffineTransformConcat(new, CGAffineTransformMakeTranslation(x, 0));
//            
//            [layerInstruction setTransform:newer atTime:CMTimeMakeWithSeconds(time, 30)];
//        }
        
        CMTime startTime = [self.composition duration];
        ok = [compositionVideoTrack insertTimeRange:sourceVideoTrack.timeRange ofTrack:sourceVideoTrack atTime:startTime error:&error];
        ok = [self.compositionAudioTrack insertTimeRange:sourceAudioTrack.timeRange ofTrack:sourceAudioTrack atTime:startTime error:&error];

        if (!ok) {
            Error(@"*** Failed to insert video track ***");
            continue;
        }
        
        time += CMTimeGetSeconds(sourceVideoTrack.timeRange.duration);
    }
    
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    instruction.timeRange = compositionVideoTrack.timeRange;
    
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.compositionPath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];  //TODO: [[NSFileManager defaultManager] removeItemAtPath:compositionPath error:nil];
    
    self.mediaURL = [NSURL fileURLWithPath:self.compositionPath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.composition
                                                                      presetName:AVAssetExportPresetMediumQuality];
    exporter.outputURL = self.mediaURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
    
//    [self genThumbnail];
}

- (void)exportDidFinish:(AVAssetExportSession *)session {
    [self.savingActivity stopAnimating];
    self.navItem.rightBarButtonItem.customView = nil;
    self.overlay.userInteractionEnabled = YES;
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
//        NSURL *outputURL = session.outputURL; // == self.mediaURL
        
        if ([UIVideoEditorController canEditVideoAtPath:[[self.mediaURL absoluteURL] path]]) {
            self.editor.videoPath = [[self.mediaURL absoluteURL] path];
            
            [self dismissViewControllerAnimated:YES completion:^{
//                [self presentViewController:self.editor animated:YES completion:nil];
                [self performSegueWithIdentifier:SET_VIDEO_SOUND_SEGUE sender:self];
            }];
        }
        
//        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputURL]) {
//            [library writeVideoAtPathToSavedPhotosAlbum:outputURL completionBlock:^(NSURL *assetURL, NSError *error){
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (error) {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Video Saving Failed"
//                                                                       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    } else {
//                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Saved" message:@"Saved To Photo Album"
//                                                                       delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                        [alert show];
//                    }
//                });
//            }];
//        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        self.navItem.rightBarButtonItem = self.nextButton;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        // clean up
        self.referenceURL = nil;
        self.mediaLink = nil;
        
        self.mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        Debug(@"=== media url: %@", [info objectForKey:UIImagePickerControllerMediaURL]);
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            AVAsset *asset = [AVAsset assetWithURL:self.mediaURL];
            [self.videoAssets addObject:asset];
            if (self.hasTimedUp) {
                [self proceedToEdit];
            }
        } else {
            if ([UIVideoEditorController canEditVideoAtPath:[[self.mediaURL absoluteURL] path]]) {
                self.referenceURL = [info valueForKey:UIImagePickerControllerReferenceURL];
                
                [self genThumbnail];
                [self doneTakingVideo];
                self.currentImagePicker = self.picker;
            }
        }
    }
}

/***
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];

    if (CFStringCompare ((__bridge_retained CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        // clean up
        self.mediaURL = nil;
        self.referenceURL = nil;
        self.mediaLink = nil;
        
        self.mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        
        [self genThumbnail];
        
//        int offset;
//        if ([[[NSLocale currentLocale] localeIdentifier] hasPrefix:CHINESE]) {
//            offset = AD_BANNER_ANIMATION_DISTANCE_CN;
//        } else {
//            offset = AD_BANNER_ANIMATION_DISTANCE_EN;
//        }
        
        [UIView animateWithDuration:ANIMATION_DURATION
                              delay: 0.5f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.playButton.frame = PLAY_THUMBNAIL_RECT;
                             self.playButton.alpha = 1.0;
                             self.videoButton.frame = VIDEO_THUMBNAIL_AFTER_RECT;
                             self.galleryButton.frame = GALLERY_BUTTON_AFTER_RECT;
                             
//                             if (self.adBanner.frame.origin.y > AD_BANNER_ADJUST_THRESHOLD) {
//                                 self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -offset);
//                             }
//                             self.headView.backgroundColor = [UIColor whiteColor];
//                             self.lineView.alpha = 0.1f;
                             
                             self.headView.frame = HEAD_VIEW_RECT;
                         }
                         completion:^ (BOOL finished) {
                             if (finished) {
                                 self.contentDescription.hidden = NO;
                                 self.geoButton.hidden = NO;
                                 
                                 UIImage *playImg = [UIImage imageNamed:@"Play.png"];
                                 CALayer *sublayer = [CALayer layer];
                                 sublayer.contents = (id) playImg.CGImage;
                                 sublayer.frame = CGRectMake((VIDEO_THUMBNAIL_SIZE - playImg.size.width) / 2, (VIDEO_THUMBNAIL_SIZE - playImg.size.height) / 2, playImg.size.width, playImg.size.height);
                                 [self.playButton.layer addSublayer:sublayer];
//                                 [self.contentDescription becomeFirstResponder];
                             }
                         }
        ];
        
        self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShareButtonTapped:)];
        self.navigationItem.rightBarButtonItem = self.shareButton;
        
        self.currentImagePicker = picker;
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
//            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
//            [library writeVideoAtPathToSavedPhotosAlbum:self.mediaURL completionBlock:^(NSURL *assetURL, NSError *error){
//                if (!error) {
//                    self.referenceURL = assetURL;
//                    Debug(@">>> %@", self.referenceURL);
//                    [self uploadVideoToVdisk];
//                }else{
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.domain delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                    [alert show];
//                }
//            }];
        } else {
            self.referenceURL = [info valueForKey:UIImagePickerControllerReferenceURL];
//            [self uploadVideoToVdisk];
        }

        
//        // Save video: but can't get video referenceUrl this way! so commented out!
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.mediaURL.path)) {
//            UISaveVideoAtPathToSavedPhotosAlbum(self.mediaURL.path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//        }
        
    }
}
 ***/


- (void)saveRecordingContentWithCompletionBlock:(AssetsLibraryWriteContentCompletionBlock)completionBlock {
    [super saveRecordingContentWithCompletionBlock:completionBlock];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.mediaURL.path)) {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:self.mediaURL completionBlock:completionBlock];
    } else {
        [UIHelper showInfo:LABEL_FAIL_TO_SAVE_VIDEO withStatus:kFailure];
    }
}

- (void)uploadContent {
    if (self.currentImagePicker.sourceType == UIImagePickerControllerSourceTypeCamera && !self.referenceURL) {
        [self saveRecordingContentWithCompletionBlock:^(NSURL *assetURL, NSError *error){
            if (!error) {
                self.needSave = NO;
                self.referenceURL = assetURL;
                Debug(@"Video reference URL: %@", self.referenceURL);
                
                [super uploadContent];
                [self uploadVideoToVdisk];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.domain delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    } else {
        [super uploadContent];
        [self uploadVideoToVdisk];
    }
};

- (void)uploadVideoToVdisk {
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *theAsset) {
        NSString *fileName = [[theAsset defaultRepresentation] filename];
        NSString *tmpPath = [NSString stringWithFormat:@"%@/%@", [NSHomeDirectory() stringByAppendingFormat: @"/tmp"], fileName];
        
        NSMutableData *emptyData = [[NSMutableData alloc] initWithLength:0];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:tmpPath contents:emptyData attributes:nil];
        
        NSFileHandle *theFileHandle = [NSFileHandle fileHandleForWritingAtPath:tmpPath];
        
        unsigned long long offset = 0;
        unsigned long long length;
        
        long long theItemSize = [[theAsset defaultRepresentation] size];
        
        unsigned long bufferLength = 16384;
        
        if (theItemSize > 262144) {
            
            bufferLength = 262144;
            
        } else if (theItemSize > 65536) {
            
            bufferLength = 65536;
        }
        
        NSError *err = nil;
        uint8_t *buffer = (uint8_t *)malloc(bufferLength);
        
        while ((length = [[theAsset defaultRepresentation] getBytes:buffer fromOffset:offset length:bufferLength error:&err]) > 0 && err == nil) {
            NSData *data = [[NSData alloc] initWithBytes:buffer length:(NSUInteger)length];
            [theFileHandle writeData:data];
            offset += length;
        }
        
        free(buffer);
        [theFileHandle closeFile];
        
        if ([fileManager fileExistsAtPath:tmpPath]) {
            //                _progressLabel.text = @"0.0%";
            self.uploadProgress.progress = 0.0f;
            
            self.destPath = [NSString stringWithFormat:@"/%@", fileName];
            
            [self.vdiskUploader cancel];
            self.vdiskUploader = nil;
            
            self.vdiskUploader = [[VdiskComplexUpload alloc] initWithFile:fileName fromPath:tmpPath toPath:@"/"];
            self.vdiskUploader.delegate = self;
            
            [self.vdiskUploader start:NO params:nil];
            
        }
        
    };
    
    ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *theError) {
        Error(@"%@", [theError localizedDescription]);
    };
    
    ALAssetsLibrary *assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:self.referenceURL resultBlock:resultblock failureBlock:failureblock];
}


- (void)movieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    
//    MPMoviePlayerController* player = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification object:self.player];
//    player = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Video Editor delegate
- (void)doneTakingVideo {
    [self animateToPost];
    
    self.shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(onShareButtonTapped:)];
    self.navigationItem.rightBarButtonItem = self.shareButton;
}

- (void)videoEditorController: (UIVideoEditorController*) editor didSaveEditedVideoToPath: (NSString*) editedVideoPath {
    self.mediaURL = [NSURL URLWithString:editedVideoPath relativeToURL:[NSURL URLWithString:@"file://localhost"]];
    
    self.needSave = YES;
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    // clean up
    self.referenceURL = nil;
    self.mediaLink = nil;
    
    [self genThumbnail];
    
//        int offset;
//        if ([[[NSLocale currentLocale] localeIdentifier] hasPrefix:CHINESE]) {
//            offset = AD_BANNER_ANIMATION_DISTANCE_CN;
//        } else {
//            offset = AD_BANNER_ANIMATION_DISTANCE_EN;
//        }
    
    [self doneTakingVideo];
    
    self.currentImagePicker = self.recorder;
}

- (void)videoEditorControllerDidCancel:(UIVideoEditorController *)editor {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: nil
                          message: SAVE_VIDEO_PROMPT
                          delegate: self
                          cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                          otherButtonTitles:NSLocalizedString(@"Yes", nil), NSLocalizedString(@"No", nil), nil];
    alert.tag = ABANDON_VIDEO_ALERT_TAG;
    [alert show];
}

- (void)videoEditorController:(UIVideoEditorController *)editor didFailWithError:(NSError *)error {
    [UIHelper showInfo:NSLocalizedString(@"Failed to save video!", nil) withStatus:kFailure];
}


- (void)switchToAudio {
    [self dismissViewControllerAnimated:NO completion:^{
        [self performSegueWithIdentifier:SWITCH_TO_AUDIO_SEGUE sender:self];
    }];
}

- (void)switchFlash {
//    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
//    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            [device lockForConfiguration:nil];
            if (device.torchMode == AVCaptureTorchModeOff || device.torchMode == AVCaptureTorchModeAuto) {
                [device setTorchMode:AVCaptureTorchModeOn];
                [device setFlashMode:AVCaptureFlashModeOn];

                UIImage *flashImage = [UIImage imageNamed:@"FlashOn.png"];
                [self.flashButton setBackgroundImage:flashImage forState:UIControlStateNormal];
                
                self.flashOn = YES;
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];

                UIImage *noFlashImage = [UIImage imageNamed:@"FlashOff.png"];
                [self.flashButton setBackgroundImage:noFlashImage forState:UIControlStateNormal];
                
                self.flashOn = NO;
            }
            [device unlockForConfiguration];
        }
//    }
}

- (void)switchCamera {
    if (self.recorder.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.recorder.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.recorder.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options {
    [UIView animateWithDuration: 0.5f
                          delay: 0.0f
                        options: options
                     animations: ^{
                         self.recordButton.transform = CGAffineTransformRotate(self.recordButton.transform, M_PI / 2);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (self.isRecording) {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear];
//                             } else if (options != UIViewAnimationOptionCurveEaseOut) {
//                                 // one last spin, with deceleration
////                                 [self spinWithOptions: UIViewAnimationOptionCurveEaseOut];
                             }
                         }
                     }];
}

- (void) startSpin {
    self.isRecording = YES;
    [self spinWithOptions:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseIn];
}

- (void) stopSpin {
    // set the flag to stop spinning after one last 90 degree increment
    self.isRecording = NO;
}

- (void)startRecording {
    if (self.flashButton) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        if (self.flashOn) {
            [device setTorchMode:AVCaptureTorchModeOn];
            [device setFlashMode:AVCaptureFlashModeOn];
        } else {
            [device setTorchMode:AVCaptureTorchModeOff];
            [device setFlashMode:AVCaptureFlashModeOff];
        }
        [device unlockForConfiguration];
    }
    
    if (!self.recordingTimer) {
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:RECORDING_TIMER_INTERVAL target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        self.recordingStartTime = nil;
        self.recordingStartTime = [NSDate dateWithTimeIntervalSinceNow:0];
    } else {
        [self resumeTimer];
    }
    
    self.recordingProgress.hidden = NO;
    [self.recorder startVideoCapture];
    [self startSpin];
    self.navItem.leftBarButtonItem = nil;
    self.navItem.rightBarButtonItem = nil;
    
    self.galleryButton.hidden = YES;
}

- (void)stopRecording {
    [self.recorder stopVideoCapture];
    [self pauseTimer];
    [self stopSpin];
    self.navItem.leftBarButtonItem = self.cancelButton;
    self.navItem.rightBarButtonItem = self.nextButton;
}

- (void)toggleRecording {
    if (self.isRecording) {
        [self stopRecording];
    } else {
        [self startRecording];
    }
}

- (void)recordingTimesUp {
    self.hasTimedUp = YES;
    
    [self stopRecording];
//    [self toggleRecording];
}


#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ABANDON_VIDEO_ALERT_TAG:   // not in use any more!
            if (buttonIndex == 1) {
//                [self saveRecordingContentWithCompletionSelector:@selector(video:didFinishSavingWithError:abandon:)];
                [self saveRecordingContentWithCompletionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        [UIHelper showInfo:LABEL_FAIL_TO_SAVE_VIDEO withStatus:kFailure];
                    } else {
                        [self dismissViewControllerAnimated:YES completion:^{
                            [self resetImagePicker];
                            [self presentVideoPicker];
                        }];
                        
                        self.needSave = NO;
                        self.referenceURL = assetURL;
                    }
                }];
            } else if (buttonIndex == 2) {
                [self dismissViewControllerAnimated:YES completion:^{
                    [self resetImagePicker];
                    [self presentVideoPicker];
                    
                    self.needSave = NO;
                }];
            }
            break;
        case RETAKE_VIDEO_ALERT_TAG:
            if (buttonIndex == 1) {
//                [self saveRecordingContentWithCompletionSelector:@selector(video:didFinishSavingWithError:retake:)];
                [self saveRecordingContentWithCompletionBlock:^(NSURL *assetURL, NSError *error){
                    if (error) {
                        [UIHelper showInfo:LABEL_FAIL_TO_SAVE_VIDEO withStatus:kFailure];
                    } else {
                        [self resetImagePicker];
                        [self animateToRecording];
                        
                        self.needSave = NO;
                        self.referenceURL = assetURL;
                    }
                }];
            } else if (buttonIndex == 2) {
                [self resetImagePicker];
                [self animateToRecording];
                
                self.needSave = NO;
            }
            break;
        default:
            break;
    }
}

//- (void)saveRecordingContentWithCompletionSelector:(SEL)completionSelector {
//    [super saveRecordingContentWithCompletionSelector:completionSelector];
//    
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.mediaURL.path)) {
//        UISaveVideoAtPathToSavedPhotosAlbum(self.mediaURL.path, self, completionSelector, nil);
//    } else {
//        [UIHelper showInfo:@"Cannot save video to Camera Roll!" withStatus:kFailure];
//    }
//}
//
//- (void)video:(NSString*)mediaPath didFinishSavingWithError:(NSError*)error abandon:(void*)contextInfo {
//    if (error) {
//        [UIHelper showInfo:LABEL_FAIL_TO_SAVE_VIDEO withStatus:kFailure];
//    } else {
//        [self dismissViewControllerAnimated:YES completion:^{
//            [self resetImagePicker];
//            [self presentVideoPicker];
//        }];
//        
//        self.needSave = NO;
//    }
//}
//
//- (void)video:(NSString*)mediaPath didFinishSavingWithError:(NSError*)error retake:(void*)contextInfo {
//    if (error) {
//        [UIHelper showInfo:LABEL_FAIL_TO_SAVE_VIDEO withStatus:kFailure];
//    } else {
//        [self resetImagePicker];
//        [self animateToRecording];
//        
//        self.needSave = NO;
//    }
//}

- (void)animateToRecording {
    [self.videoButton setImage:[UIImage imageNamed:CAMCORDER_IMG_NAME] forState:UIControlStateNormal];
    
    [UIView animateWithDuration:ANIMATE_TO_REC_DURATION
                          delay: 0.5f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.videoButton.frame = VIDEO_THUMBNAIL_INIT_RECT;
                         self.headView.alpha = 1.0;
                         self.headView.frame = HEAD_VIEW_HIDDEN_RECT;
                         
                         self.videoButton.transform = CGAffineTransformRotate(self.videoButton.transform, M_PI);
                     }
                     completion:^ (BOOL finished) {
                         if (finished) {
                             self.playButton.frame = VIDEO_THUMBNAIL_INIT_RECT;
                             self.contentDescription.hidden = YES;
                             self.geoButton.hidden = YES;
                             [self.playLayer removeFromSuperlayer];
                             
                             self.headView.alpha = 0.0;
                             self.headView.frame = HEAD_VIEW_RECT;
                             
                             [self presentVideoPicker];
                         }
                     }
     ];
}

- (void)animateToPost {
    [UIView animateWithDuration:ANIMATE_TO_POST_DURATION
                          delay: 0.3f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.playButton.frame = PLAY_THUMBNAIL_RECT;
                         self.videoButton.frame = VIDEO_THUMBNAIL_AFTER_RECT;
                         //                         self.galleryButton.frame = GALLERY_BUTTON_AFTER_RECT;
                         
                         //                             if (self.adBanner.frame.origin.y > AD_BANNER_ADJUST_THRESHOLD) {
                         //                                 self.adBanner.frame = CGRectOffset(self.adBanner.frame, 0, -offset);
                         //                             }
                         //                             self.headView.backgroundColor = [UIColor whiteColor];
                         //                             self.lineView.alpha = 0.1f;
                         
                         self.headView.alpha = 1.0f;
//                         self.semiCoverView.alpha = 0.5;
                         
                         self.videoButton.transform = CGAffineTransformRotate(self.videoButton.transform, - M_PI);
                     }
                     completion:^ (BOOL finished) {
//                         if (finished) {
//                             [self.videoButton setImage:[UIImage imageNamed:CAMCORDER_CLOSED_IMG_NAME] forState:UIControlStateNormal];
                             self.contentDescription.hidden = NO;
                             self.geoButton.hidden = NO;
                             
                             [self.playButton.layer addSublayer:self.playLayer];
                             [self.contentDescription becomeFirstResponder];
//                         }
                     }
     ];
}

- (void)resetImagePicker {
    [self.videoAssets removeAllObjects];
    self.navItem.rightBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
    self.galleryButton.hidden = NO;
    self.hasTimedUp = NO;
    self.recordingProgress.hidden = YES;
    self.recordingProgress.progress = 0.0;
    self.recordingProgressLabel.text = @"00:00";
    self.recordingTimer = nil;
    [self genGalleryThumbnail];
}

- (void)genGalleryThumbnail {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:[group numberOfAssets] - 1] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset) {
                CGImageRef imageRef = [alAsset thumbnail];
                [self.galleryButton setBackgroundImage:[UIImage imageWithCGImage:imageRef] forState:UIControlStateNormal];
            }
        }];
    } failureBlock: ^(NSError *error) {
        Error(@"Photo album empty!");
    }];
    
}

#pragma mark - Video SoundTrack delegate
- (void)didSetSoundTrack:(NSURL *)mediaUrl {
    self.mediaURL = mediaUrl;
}

//- (void)didSetSoundTrack:(AVAsset *)audioAsset {
//    if (self.compositionPath) {
//        [[NSFileManager defaultManager] removeItemAtPath:self.compositionPath error:nil];
//    }
//    
//    [self.composition removeTrack:self.compositionAudioTrack];
//    self.compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
//    
//    NSError *error = nil;
//    
//    AVAssetTrack *sourceAudioTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
//    [self.compositionAudioTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, [self.composition duration])];
//    BOOL ok = [self.compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.composition duration]) ofTrack:sourceAudioTrack atTime:kCMTimeZero error:&error];
//    
//    if (!ok) {
//        Error(@"*** Failed to set audio track *** %@", error);
//    }
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    self.compositionPath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];
//    
//    self.mediaURL = [NSURL fileURLWithPath:self.compositionPath];
//    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.composition
//                                                                      presetName:AVAssetExportPresetHighestQuality];
//    exporter.outputURL = self.mediaURL;
//    exporter.outputFileType = AVFileTypeQuickTimeMovie;
//    exporter.shouldOptimizeForNetworkUse = YES;
//    
//    [exporter exportAsynchronouslyWithCompletionHandler:^{
//        dispatch_async(dispatch_get_main_queue(), ^{
////            [self exportDidFinish:exporter];
//        });
//    }];
//}

- (void)presentPost {
    self.needSave = YES;
    
    // clean up
    self.referenceURL = nil;
    self.mediaLink = nil;
    
    [self genThumbnail];
    [self doneTakingVideo];
    
    self.currentImagePicker = self.recorder;
}


/***
 - (void)mergeVideoAsset:(AVAsset *)newAsset {
 if (YES) {
 // 1 - Create AVMutableComposition object. This object will hold your AVMutableCompositionTrack instances.
 AVMutableComposition *mixComposition = [[AVMutableComposition alloc] init];
 
 // 2 - Video track
 AVMutableCompositionTrack *origTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
 preferredTrackID:kCMPersistentTrackID_Invalid];
 
 Debug(@"------- %@", self.videoAsset);
 Debug(@"------- %@", [self.videoAsset tracksWithMediaType:AVMediaTypeVideo]);
 [origTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, self.videoAsset.duration)
 ofTrack:[[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:kCMTimeZero error:nil];
 
 AVMutableCompositionTrack *newTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
 preferredTrackID:kCMPersistentTrackID_Invalid];
 [newTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, newAsset.duration)
 ofTrack:[[newAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:self.videoAsset.duration error:nil];
 
 // 2.1 - Create AVMutableVideoCompositionInstruction
 AVMutableVideoCompositionInstruction *mainInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
 mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeAdd(self.videoAsset.duration, newAsset.duration));
 
 // 2.2 - Create an AVMutableVideoCompositionLayerInstruction for the first track
 AVMutableVideoCompositionLayerInstruction *firstlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:origTrack];
 AVAssetTrack *firstAssetTrack = [[self.videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
 UIImageOrientation firstAssetOrientation_  = UIImageOrientationUp;
 BOOL isFirstAssetPortrait_  = NO;
 CGAffineTransform firstTransform = firstAssetTrack.preferredTransform;
 
 if (firstTransform.a == 0 && firstTransform.b == 1.0 && firstTransform.c == -1.0 && firstTransform.d == 0) {
 firstAssetOrientation_ = UIImageOrientationRight;
 isFirstAssetPortrait_ = YES;
 }
 if (firstTransform.a == 0 && firstTransform.b == -1.0 && firstTransform.c == 1.0 && firstTransform.d == 0) {
 firstAssetOrientation_ =  UIImageOrientationLeft;
 isFirstAssetPortrait_ = YES;
 }
 if (firstTransform.a == 1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == 1.0) {
 firstAssetOrientation_ =  UIImageOrientationUp;
 }
 if (firstTransform.a == -1.0 && firstTransform.b == 0 && firstTransform.c == 0 && firstTransform.d == -1.0) {
 firstAssetOrientation_ = UIImageOrientationDown;
 }
 
 [firstlayerInstruction setTransform:self.videoAsset.preferredTransform atTime:kCMTimeZero];
 [firstlayerInstruction setOpacity:0.0 atTime:self.videoAsset.duration];
 
 // 2.3 - Create an AVMutableVideoCompositionLayerInstruction for the second track
 AVMutableVideoCompositionLayerInstruction *secondlayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:newTrack];
 AVAssetTrack *secondAssetTrack = [[newAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
 UIImageOrientation secondAssetOrientation_  = UIImageOrientationUp;
 BOOL isSecondAssetPortrait_  = NO;
 CGAffineTransform secondTransform = secondAssetTrack.preferredTransform;
 
 if (secondTransform.a == 0 && secondTransform.b == 1.0 && secondTransform.c == -1.0 && secondTransform.d == 0) {
 secondAssetOrientation_= UIImageOrientationRight;
 isSecondAssetPortrait_ = YES;
 }
 if (secondTransform.a == 0 && secondTransform.b == -1.0 && secondTransform.c == 1.0 && secondTransform.d == 0) {
 secondAssetOrientation_ =  UIImageOrientationLeft;
 isSecondAssetPortrait_ = YES;
 }
 if (secondTransform.a == 1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == 1.0) {
 secondAssetOrientation_ =  UIImageOrientationUp;
 }
 if (secondTransform.a == -1.0 && secondTransform.b == 0 && secondTransform.c == 0 && secondTransform.d == -1.0) {
 secondAssetOrientation_ = UIImageOrientationDown;
 }
 
 [secondlayerInstruction setTransform:newAsset.preferredTransform atTime:self.videoAsset.duration];
 
 // 2.4 - Add instructions
 mainInstruction.layerInstructions = [NSArray arrayWithObjects:firstlayerInstruction, secondlayerInstruction, nil];
 self.mainCompositionInst = [AVMutableVideoComposition videoComposition];
 self.mainCompositionInst.instructions = [NSArray arrayWithObject:mainInstruction];
 self.mainCompositionInst.frameDuration = CMTimeMake(1, 30);
 
 CGSize naturalSizeFirst, naturalSizeSecond;
 if(isFirstAssetPortrait_){
 naturalSizeFirst = CGSizeMake(origTrack.naturalSize.height, origTrack.naturalSize.width);
 } else {
 naturalSizeFirst = origTrack.naturalSize;
 }
 if(isSecondAssetPortrait_){
 naturalSizeSecond = CGSizeMake(newTrack.naturalSize.height, newTrack.naturalSize.width);
 } else {
 naturalSizeSecond = newTrack.naturalSize;
 }
 
 float renderWidth, renderHeight;
 if(naturalSizeFirst.width > naturalSizeSecond.width) {
 renderWidth = naturalSizeFirst.width;
 } else {
 renderWidth = naturalSizeSecond.width;
 }
 if(naturalSizeFirst.height > naturalSizeSecond.height) {
 renderHeight = naturalSizeFirst.height;
 } else {
 renderHeight = naturalSizeSecond.height;
 }
 self.mainCompositionInst.renderSize = CGSizeMake(renderWidth, renderHeight);
 
 //        // 3 - Audio track
 //        if (audioAsset!=nil){
 //            AVMutableCompositionTrack *AudioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
 //                                                                                preferredTrackID:kCMPersistentTrackID_Invalid];
 //            [AudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, CMTimeAdd(firstAsset.duration, secondAsset.duration))
 //                                ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:kCMTimeZero error:nil];
 //        }
 
 // 4 - Get path
 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
 NSString *documentsDirectory = [paths objectAtIndex:0];
 self.compositionPath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];
 
 // 5 - Clean up & accumulate video asset
 newTrack = nil;
 self.videoAsset = nil;
 self.cumulativeMixComposition = nil;
 
 self.videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:self.compositionPath]];
 self.cumulativeMixComposition = mixComposition;
 }
 }
 ***/


@end
