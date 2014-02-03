//
//  VideoSoundTrackViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 2/1/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoSoundTrackDelegate <NSObject>

- (void)didSetSoundTrack:(AVAsset *)audioAsset;

@end

@interface VideoSoundTrackViewController : UIViewController

@property (nonatomic, strong) NSURL *origMediaURL;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVMutableCompositionTrack *compositionAudioTrack;

@property (nonatomic, strong) id<VideoSoundTrackDelegate> delegate;

@end
