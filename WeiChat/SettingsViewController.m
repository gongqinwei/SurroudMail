//
//  SettingsViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 3/4/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "SettingsViewController.h"
#import "Constants.h"
#import "UIHelper.h"
#import "WXApi.h"
#import "WXApiObject.h"
#import "VdiskSDK.h"
#import <MessageUI/MessageUI.h>


enum SettingsSection {
    kVideoCaptureMode,
    kVideoQuality,
//    kShare,
//    kVdisk,
    kFeedbackAndVersion
};

enum VdiskSettings {
    kAuthorizeToVdisk,
    kAccessVdisk,
    kIncreasVdisk
};

typedef enum {
    kShareAppViaWeixinMoments,
    kShareAppViaWeixinFriends,
    kShareAppViaSinaWeibo
} ShareOption;

enum Info {
    kFeedback,
    kVersion
};

static NSString *const iOSAppStoreURL = @"http://itunes.apple.com/app/id696521463?at=10l6dK";


@interface SettingsViewController () <MFMailComposeViewControllerDelegate, VdiskConnectionDelegate>

@end

@implementation SettingsViewController

- (IBAction)onDoneButtonTapped:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Settings", nil);
    self.view.backgroundColor = APP_BG_GRAY_COLOR;
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
            
//        case kVdisk:
//            return 3;
//            break;
            
//        case kShare:
//            return 3;
//            break;
            
        case kFeedbackAndVersion:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SettingsItem";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    if (!cell) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
    
    cell.textLabel.font = [UIFont fontWithName:APP_FONT size:17];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    switch (indexPath.section) {
        case kVideoCaptureMode:
            cell.textLabel.font = [UIFont fontWithName:APP_FONT size:16];
            cell.detailTextLabel.font = [UIFont fontWithName:APP_FONT size:12];
            
            int captureMode = [[NSUserDefaults standardUserDefaults] integerForKey:VIDEO_CAPTURE_MODE];
//            if (captureMode == indexPath.row) {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            }
            
            switch (indexPath.row) {
                case kPressAndHoldToRecord:
                    cell.textLabel.text = NSLocalizedString(@"Press and hold anywhere in the screen", nil);
                    if (captureMode == kPressAndHoldToRecord) {
                        cell.detailTextLabel.text = NSLocalizedString(@"Release finger to pause recording", nil);
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case kTapToRecord:
                    cell.textLabel.text = NSLocalizedString(@"Tap button to record", nil);
                    if (captureMode == kTapToRecord) {
                        cell.detailTextLabel.text = NSLocalizedString(@"Tap button again to pause recording", nil);
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                default:
                    break;
            }
            break;
        
        case kVideoQuality:
            cell.textLabel.font = [UIFont fontWithName:APP_FONT size:16];
            cell.detailTextLabel.font = [UIFont fontWithName:APP_FONT size:12];
            
            int videoQuality = [[NSUserDefaults standardUserDefaults] integerForKey:VIDEO_QUALITY];
//            if (videoQuality == indexPath.row) {
//                cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            }
            
            switch (indexPath.row) {
                case kVideoQualityHigh:
                    cell.textLabel.text = NSLocalizedString(@"High", nil);
                    if (videoQuality == kVideoQualityHigh) {
                        cell.detailTextLabel.text = NSLocalizedString(@"Takes longer to upload and more cloud space", nil);
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case kVideoQualityMedium:
                    cell.textLabel.text = NSLocalizedString(@"Medium", nil);
                    if (videoQuality == kVideoQualityMedium) {
                        cell.detailTextLabel.text = NSLocalizedString(@"Suitable for transmission via Wi-Fi", nil);
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                case kVideoQualityLow:
                    cell.textLabel.text = NSLocalizedString(@"Low", nil);
                    if (videoQuality == kVideoQualityLow) {
                        cell.detailTextLabel.text = NSLocalizedString(@"Suitable for tranmission via cellular network", nil);
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                    break;
                default:
                    break;
            }
            
            break;
            
//        case kVdisk:
//            switch (indexPath.row) {
//                case kAuthorizeToVdisk:
//                {
//                    VdiskSession *vDiskSession = [VdiskSession sharedSession];
//                    if (![vDiskSession isLinked]){
//                        cell.textLabel.text = NSLocalizedString(@"Connect to Sina Vdisk", nil);
//                    } else {
//                        cell.textLabel.text = NSLocalizedString(@"Disconnect from Sina Vdisk", nil);
//                    }
//                }
//                    break;
//                case kAccessVdisk:
//                    cell.textLabel.text = NSLocalizedString(@"Access your Vdisk account", nil);
//                    break;
//                case kIncreasVdisk:
//                    cell.textLabel.text = NSLocalizedString(@"Increase Vdisk space", nil);
//                    break;
//                default:
//                    break;
//            }
//            
//            cell.detailTextLabel.text = nil;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            
//            break;
            
//        case kShare:
//            switch (indexPath.row) {
//                case kShareAppViaWeixinMoments:
//                    cell.textLabel.text = NSLocalizedString(@"WeChat Moments", nil);
//                    break;
//                case kShareAppViaWeixinFriends:
//                    cell.textLabel.text = NSLocalizedString(@"WeChat Friends", nil);
//                    break;
//                    
//                case kShareAppViaSinaWeibo:
//                    cell.textLabel.text = NSLocalizedString(@"Sina Weibo", nil);
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            cell.detailTextLabel.text = nil;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            
//            break;
            
        case kFeedbackAndVersion:
            switch (indexPath.row) {
                case kFeedback:
                    cell.textLabel.text = NSLocalizedString(@"Send us feedback", nil);
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case kVersion:
                {
                    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Version %@", nil), [infoDict objectForKey:@"CFBundleVersion"]];
                }
                    break;
                    
                default:
                    break;
            }
            
            cell.detailTextLabel.text = nil;
            
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kVideoCaptureMode:
            return NSLocalizedString(@"Video Recording Mode", nil);
            break;
            
        case kVideoQuality:
            return NSLocalizedString(@"Video Quality", nil);
            break;
            
//        case kVdisk:
//            return NSLocalizedString(@"Your videos are securely stored in your own Sina Vdisk", nil);
//            break;
            
//        case kShare:
//            return NSLocalizedString(@"Share WeiChat via", nil);
//            break;
            
        case kFeedbackAndVersion:
            return nil;
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case kVideoCaptureMode:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:VIDEO_CAPTURE_MODE];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kVideoCaptureMode] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.videoRecorderDelegate didSelectVideoCaptureMode:indexPath.row];
            break;
            
        case kVideoQuality:
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:VIDEO_QUALITY];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:kVideoQuality] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.videoRecorderDelegate didSelectVideoQuality:indexPath.row];
            break;
            
//        case kVdisk:
//        {
//            if (indexPath.row == kAuthorizeToVdisk) {
//                VdiskSession *vDiskSession = [VdiskSession sharedSession];
//                if (![vDiskSession isLinked]){
//                    [vDiskSession linkWithSessionType:kVdiskSessionTypeDefault];
//                } else {
//                    [vDiskSession unlink];
//                    [self vdiskConnectionChanged];
//                }
//            } else {
//                NSString *vdiskLink;
//                if (indexPath.row == kAccessVdisk) {
//                    vdiskLink = @"http://vdisk.weibo.com/wap/file/list";
//                } else if (indexPath.row == kIncreasVdisk) {
//                    vdiskLink = @"http://vdisk.weibo.com/zt/kongjian/";
//                }
//                
//                NSURL *vdiskURL = [NSURL URLWithString:vdiskLink];
//                if ([[UIApplication sharedApplication] canOpenURL:vdiskURL]) {
//                    [[UIApplication sharedApplication] openURL:vdiskURL];
//                } else {
//                    [UIHelper showInfo:@"Can't open browser on this device!" withStatus:kInfo];
//                }
//            }
//        }
//            break;
            
//        case kShare:
//            switch (indexPath.row) {
//                case kShareAppViaWeixinMoments:
//                    [self shareAppToWeixin:kShareAppViaWeixinMoments];
//                    break;
//                case kShareAppViaWeixinFriends:
//                    [self shareAppToWeixin:kShareAppViaWeixinFriends];
//                    break;
//                    
//                case kShareAppViaSinaWeibo:
//                    [self shareAppToWeibo];
//                    break;
//                    
//                default:
//                    break;
//            }
//            
//            break;
            
        case kFeedbackAndVersion:
            switch (indexPath.row) {
                case kFeedback:
                    [self sendFeedbackEmail];
                    break;
                    
                case kVersion:
                    break;
                    
                default:
                    break;
            }
                        
            break;
            
        default:
            break;
    }
}

- (void)sendFeedbackEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:NSLocalizedString(@"Feedback on WeiChat app", nil)];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"customer.weichat@gmail.com", nil];
        [mailer setToRecipients:toRecipients];
        
        [self presentViewController:mailer animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

#pragma mark - MailComposer delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        case MFMailComposeResultSent:
            [UIHelper showInfo:NSLocalizedString(@"Feedback email sent. Thank you!", nil) withStatus:kSuccess];
            break;
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            break;
        case MFMailComposeResultFailed:
            [UIHelper showInfo:NSLocalizedString(@"Failed to send the email. Please try again", nil) withStatus:kFailure];
            break;
        default:
            break;
    }
    
    // Remove the mail view
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)shareAppToWeixin:(ShareOption)option {
    //if the Weixin app is not installed, show an error
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"The Wechat app is not installed", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = NSLocalizedString(@"Use WeiChat to post videos to WeChat Moments! Cool!", nil);
//    message.description = NSLocalizedString(@"I'm using WeiChat to post videos to WeChat Moments! Check it out!", nil);
    [message setThumbImage:[UIImage imageNamed:APERTURE_IMG_NAME]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = iOSAppStoreURL;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    
    if (option == kShareAppViaWeixinMoments) {
        req.scene = WXSceneTimeline;
    } else if (option == kShareAppViaWeixinFriends) {
        req.scene = WXSceneSession;
    } else {
        //Invalid action here
        return;
    }
    
    //try to send the request
    if (![WXApi sendReq:req]) {
        [UIHelper showInfo:NSLocalizedString(@"Failed to share app to WeChat", nil) withStatus:kFailure];
    }
}

- (void)shareAppToWeibo {
    //if the Weibo app is not installed, show an error
    if (![WeiboSDK isWeiboAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Sina Weibo app is not installed", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"WeiboViaWeiChat";
    webpage.title = NSLocalizedString(@"WeiChat", nil);     //temp
    webpage.description = NSLocalizedString(@"Weibo + Wechat = WeiChat!", nil);     //temp
    webpage.thumbnailData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[APERTURE_IMG_NAME lastPathComponent] stringByDeletingPathExtension] ofType:[APERTURE_IMG_NAME pathExtension]]];
    webpage.webpageUrl = iOSAppStoreURL;
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = NSLocalizedString(@"Use WeiChat to post videos to Weibo! Super cool!", nil);     //temp
    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    
    [WeiboSDK sendRequest:request];
}

#pragma mark - (Weichat) vdisk connection delegate
- (void) didConnect{
    [self vdiskConnectionChanged];
}

- (void)didDisconnect {
    [self vdiskConnectionChanged];
}

- (void)vdiskConnectionChanged {
//    NSIndexPath *path = [NSIndexPath indexPathForRow:kAuthorizeToVdisk inSection:kVdisk];
//    [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
