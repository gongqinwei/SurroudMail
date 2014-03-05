//
//  SettingsViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 3/4/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "SettingsViewController.h"


enum SettingsSection {
    kVideoCaptureMode,
    kVideoQuality,
    kVdisk,
    kShare,
    kInfo
};

enum VideoCaptureMode {
    kPressAndHold,
    kTap
};

enum VideoQuality {
    kVideoQualityHigh,
    kVideoQualityMedium,
    kVideoQualityLow
};

enum VdiskSettings {
    kAccessVdisk,
    kIncreasVdisk
};

enum ShareOption {
    kWeixinMoments,
    kWeixinFriends,
    kSinaWeibo,
    kEmail
};

enum Info {
    kFeedback,
    kVersion
};


@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kVideoCaptureMode:
            return 2;
            break;
            
        case kVideoQuality:
            return 3;
            break;
            
        case kVdisk:
            return 2;
            break;
            
        case kShare:
            return 4;
            break;
            
        case kInfo:
            return 2;
            break;
            
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.section) {
        case kVideoCaptureMode:
            switch (indexPath.row) {
                case kPressAndHold:
                    cell.textLabel.text = NSLocalizedString(@"Press and hold anywhere in screen to record", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"Release finger to pause recording", nil);
                    break;
                case kTap:
                    cell.textLabel.text = NSLocalizedString(@"Tap button to record", nil);
                    cell.detailTextLabel.text = NSLocalizedString(@"Tap button again to pause recording", nil);
                    break;
                default:
                    break;
            }
            break;
        
        case kVideoQuality:
            switch (indexPath.row) {
                case kVideoQualityHigh:
                    cell.textLabel.text = NSLocalizedString(@"High", nil);
                    break;
                case kVideoQualityMedium:
                    cell.textLabel.text = NSLocalizedString(@"Medium", nil);
                    break;
                case kVideoQualityLow:
                    cell.textLabel.text = NSLocalizedString(@"Low", nil);
                    break;
                default:
                    break;
            }
            break;
            
        case kVdisk:
            switch (indexPath.row) {
                case kAccessVdisk:
                    cell.textLabel.text = NSLocalizedString(@"Access your Vdisk account", nil);
//                    cell.detailTextLabel.text = NSLocalizedString(@"", nil);
                    break;
                case kIncreasVdisk:
                    cell.textLabel.text = NSLocalizedString(@"Increase your Vdisk space for more videos", nil);
//                    cell.detailTextLabel.text = NSLocalizedString(@"Tap button again to pause recording", nil);
                    break;
                default:
                    break;
            }
            break;
            
        case kShare:
            switch (indexPath.row) {
                case kWeixinMoments:
                    cell.textLabel.text = NSLocalizedString(@"WeChat Moments", nil);
                    break;
                case kWeixinFriends:
                    cell.textLabel.text = NSLocalizedString(@"WeChat Friends", nil);
                    break;
                    
                case kSinaWeibo:
                    cell.textLabel.text = NSLocalizedString(@"Sina Weibo", nil);
                    break;
                   
                case kEmail:
                    cell.textLabel.text = NSLocalizedString(@"Send Email", nil);
                    break;
                    
                default:
                    break;
            }
            break;
            
        case kInfo:
            switch (indexPath.row) {
                case kFeedback:
                    cell.textLabel.text = NSLocalizedString(@"Send us feedback", nil);
                    break;
                    
                case kVersion:
                    cell.textLabel.text = NSLocalizedString(@"Version", nil);
                    break;
                    
                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    return cell;
}


/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
