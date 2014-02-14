//
//  VideoSoundTrackViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 2/1/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "VideoSoundTrackViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "Constants.h"

#define TOOLBAR_HEIGHT          120

@interface VideoSoundTrackViewController () <MPMediaPickerControllerDelegate>

@property (nonatomic, strong) MPMoviePlayerController *videoPlayer;
@property (nonatomic, strong) MPMediaPickerController *soundTrackPicker;

@property (strong, nonatomic) UIBarButtonItem *selectSoundButton;
@property (nonatomic, strong) UILabel *soundStartTimeLabel;
@property (strong, nonatomic) UISlider *setSoundBeginningSlider;

@property (nonatomic, strong) AVAsset *origAudioAsset;
@property (nonatomic, strong) AVAsset *audioAsset;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *compositionPath;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end

@implementation VideoSoundTrackViewController

- (void)onSelectSoundButtonTapped {
    [self.videoPlayer pause];
    
    if (!self.soundTrackPicker) {
        self.soundTrackPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAny];
    }
    
    self.soundTrackPicker.delegate = self;
    self.soundTrackPicker.prompt = @"Select Sound Track";
    [self presentViewController:self.soundTrackPicker animated:YES completion:nil];
}

- (void)onSetSoundBeginSliderValueChanged:(UISlider *)sender {
    int min = sender.value / 60;
    int sec = (int)sender.value % 60;
    self.soundStartTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

- (void)onSetSoundBeginSliderTouchUp:(UISlider *)sender {
    [self exportAsset:sender.value];
}

- (BOOL)exportAsset:(int)start {
    [self toggleUI:NO];
    
    CMTime assetTime = [self.origAudioAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    
    // get the first audio track
    NSArray *tracks = [self.origAudioAsset tracksWithMediaType:AVMediaTypeAudio];
    if ([tracks count] == 0) {
        return NO;
    }
    
    AVAssetTrack *track = [tracks objectAtIndex:0];
    
    AVAssetExportSession *exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:self.origAudioAsset
                                           presetName:AVAssetExportPresetAppleM4A];
    if (nil == exportSession) {
        return NO;
    }
    
    CMTime startTime = CMTimeMake(start, 1);
    CMTime stopTime = CMTimeMake(duration, 1);
    CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime, stopTime);
    
//    // create fade in time range - 10 seconds starting at the beginning of trimmed asset
//    CMTime startFadeInTime = startTime;
//    CMTime endFadeInTime = CMTimeMake(40, 1);
//    CMTimeRange fadeInTimeRange = CMTimeRangeFromTimeToTime(startFadeInTime,
//                                                            endFadeInTime);
    
    // setup audio mix
    AVMutableAudioMix *exportAudioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters *exportAudioMixInputParameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:track];
//
//    [exportAudioMixInputParameters setVolumeRampFromStartVolume:0.0 toEndVolume:1.0 timeRange:fadeInTimeRange];
    exportAudioMix.inputParameters = [NSArray arrayWithObject:exportAudioMixInputParameters];
    
    // configure export session  output with all our parameters
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"timmedAudio-%d.m4a", arc4random() % 1000]];  //TODO: [[NSFileManager defaultManager] removeItemAtPath:compositionPath error:nil];
    self.audioURL = [NSURL fileURLWithPath:filePath];
    
    exportSession.outputURL = [NSURL fileURLWithPath:filePath]; // output path
    exportSession.outputFileType = AVFileTypeAppleM4A; // output file type
    exportSession.timeRange = exportTimeRange; // trim time range
    exportSession.audioMix = exportAudioMix; // fade in audio mix
    
    // perform the export
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        if (AVAssetExportSessionStatusCompleted == exportSession.status) {
            Debug(@"AVAssetExportSessionStatusCompleted");
            
            self.audioAsset = [AVAsset assetWithURL:self.audioURL];
            [self setSoundTrackAsset];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self toggleUI:NO];
//            });
        } else if (AVAssetExportSessionStatusFailed == exportSession.status) {
            // a failure may happen because of an event out of your control
            // for example, an interruption like a phone call comming in
            // make sure and handle this case appropriately
            Error(@"AVAssetExportSessionStatusFailed");
        } else {
            Error(@"Export Session Status: %ld", (long)exportSession.status);
        }
    }];
    
    return YES;
}

- (void)onDoneButtonTapped {
    [self.videoPlayer stop];
//    [self.delegate didSetSoundTrack:self.audioAsset];
    [self.delegate didSetSoundTrack:self.mediaURL];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate presentPost];
}

- (void)onCancelButtonTapped {
    [self.videoPlayer stop];
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate presentPost];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mediaURL = self.origMediaURL;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButtonTapped)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(onDoneButtonTapped)];
    
    self.videoPlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.origMediaURL];
    self.videoPlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.videoPlayer.shouldAutoplay = YES;
//    self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
    self.videoPlayer.allowsAirPlay = NO;
    self.videoPlayer.fullscreen = NO;
    self.videoPlayer.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TOOLBAR_HEIGHT);
    [self.view addSubview:self.videoPlayer.view];
    [self.videoPlayer play];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TOOLBAR_HEIGHT, SCREEN_WIDTH, 60)];
    toolbar.translucent = YES;

    UIImage *image = [UIImage imageNamed:@"SelectSound.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onSelectSoundButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    self.selectSoundButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
//    self.cancelSoundButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CancelSoundGrey.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancelSoundButtonTapped)];
    
    self.soundStartTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    self.soundStartTimeLabel.backgroundColor = [UIColor clearColor];
    self.soundStartTimeLabel.textColor = [UIColor whiteColor];
    self.soundStartTimeLabel.font = [UIFont fontWithName:APP_FONT size:13];
    self.soundStartTimeLabel.hidden = YES;
//    self.soundStartTimeLabel.text = @"00:00";
    UIBarButtonItem *beginTime = [[UIBarButtonItem alloc] initWithCustomView:self.soundStartTimeLabel];
    
    self.setSoundBeginningSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 110, TOOLBAR_HEIGHT)];
    [self.setSoundBeginningSlider addTarget:self action:@selector(onSetSoundBeginSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.setSoundBeginningSlider addTarget:self action:@selector(onSetSoundBeginSliderTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    self.setSoundBeginningSlider.hidden = YES;
    UIBarButtonItem *slider = [[UIBarButtonItem alloc] initWithCustomView:self.setSoundBeginningSlider];
    
    toolbar.items = @[self.selectSoundButton, slider, beginTime];
    [self.view addSubview:toolbar];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.frame = CGRectMake((SCREEN_WIDTH - self.activityIndicator.bounds.size.width) / 2, 180, self.activityIndicator.bounds.size.width, self.activityIndicator.bounds.size.height);
    self.activityIndicator.hidesWhenStopped = YES;
    [self.activityIndicator stopAnimating];
    [self.view addSubview:self.activityIndicator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)toggleUI:(BOOL)enable {
    if (enable) {
        [self.activityIndicator stopAnimating];
        self.view.userInteractionEnabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else if (self.view.userInteractionEnabled == YES) {
        [self.activityIndicator startAnimating];
        self.view.userInteractionEnabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
    }
}

- (void)setSoundTrackAsset {
    [self toggleUI:NO];
    
    if (self.compositionPath) {
        [[NSFileManager defaultManager] removeItemAtPath:self.compositionPath error:nil];
    }
    
    [self.composition removeTrack:self.compositionAudioTrack];
    self.compositionAudioTrack = [self.composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSError *error = nil;
    
    AVAssetTrack *sourceAudioTrack = [[self.audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [self.compositionAudioTrack removeTimeRange:CMTimeRangeMake(kCMTimeZero, [self.composition duration])];
    BOOL ok = [self.compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [self.composition duration]) ofTrack:sourceAudioTrack atTime:kCMTimeZero error:&error];
    
    if (!ok) {
        Error(@"*** Failed to set audio track *** %@", error);
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.compositionPath =  [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"mergeVideo-%d.mov", arc4random() % 1000]];
    
    self.mediaURL = [NSURL fileURLWithPath:self.compositionPath];
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc] initWithAsset:self.composition
                                                                      presetName:AVAssetExportPresetHighestQuality];
    exporter.outputURL = self.mediaURL;
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.shouldOptimizeForNetworkUse = YES;
    
    [exporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self exportDidFinish:exporter];
        });
    }];
}

- (void)exportDidFinish:(AVAssetExportSession *)session {
//    [self.savingActivity stopAnimating];
//    self.navItem.rightBarButtonItem.customView = nil;
//    self.overlay.userInteractionEnabled = YES;
    
    if (session.status == AVAssetExportSessionStatusCompleted) {
        if ([UIVideoEditorController canEditVideoAtPath:[[self.mediaURL absoluteURL] path]]) {
            self.videoPlayer.contentURL = self.mediaURL;
            [self.videoPlayer stop];
            [self.videoPlayer play];
            [self toggleUI:YES];
        }
    }
}

#pragma mark - MPMediaPicker (audio) delegate

-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *selectedSong = [mediaItemCollection items];
    if ([selectedSong count] > 0) {
        MPMediaItem *songItem = [selectedSong objectAtIndex:0];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        self.audioAsset = self.origAudioAsset = [AVAsset assetWithURL:songURL];
        [self setSoundTrackAsset];
        
        self.setSoundBeginningSlider.hidden = NO;
        self.soundStartTimeLabel.hidden = NO;
        self.soundStartTimeLabel.text = @"00:00";
        self.setSoundBeginningSlider.maximumValue = CMTimeGetSeconds(self.audioAsset.duration);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
