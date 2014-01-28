//
//  AudioRecordViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 12/15/13.
//  Copyright (c) 2013 WeiChat. All rights reserved.
//

#define SWITCH_TO_VIDEO_SEGUE       @"SwitchToVideo"


#import "AudioRecordViewController.h"
#import "VideoRecordViewController.h"

@interface AudioRecordViewController ()

@end

@implementation AudioRecordViewController

- (void)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(goBack:)];
    self.navigationItem.leftBarButtonItem = backButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
