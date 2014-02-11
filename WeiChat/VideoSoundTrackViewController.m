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
@property (strong, nonatomic) UIBarButtonItem *cancelSoundButton;
@property (strong, nonatomic) UISlider *setSoundBeginningSlider;

@property (nonatomic, strong) AVAsset *audioAsset;
@property (nonatomic, strong) NSURL *mediaURL;
@property (nonatomic, strong) NSString *compositionPath;

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

- (void)onCancelSoundButtonTapped {
    
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
    self.videoPlayer.repeatMode = MPMovieRepeatModeOne;
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
    
    self.cancelSoundButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"CancelSoundGrey.png"] style:UIBarButtonItemStylePlain target:self action:@selector(onCancelSoundButtonTapped)];
    
    self.setSoundBeginningSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH - 110, TOOLBAR_HEIGHT)];
    UIBarButtonItem *slider = [[UIBarButtonItem alloc] initWithCustomView:self.setSoundBeginningSlider];
    
    toolbar.items = @[self.selectSoundButton, slider, self.cancelSoundButton];
    [self.view addSubview:toolbar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setAudioAsset {
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
        }
    }
}

#pragma mark - MPMediaPicker (audio) delegate

-(void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *selectedSong = [mediaItemCollection items];
    if ([selectedSong count] > 0) {
        MPMediaItem *songItem = [selectedSong objectAtIndex:0];
        NSURL *songURL = [songItem valueForProperty:MPMediaItemPropertyAssetURL];
        self.audioAsset = [AVAsset assetWithURL:songURL];
        [self setAudioAsset];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
