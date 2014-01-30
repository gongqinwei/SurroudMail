//
//  POITableViewController.m
//  WeiChat
//
//  Created by Qinwei Gong on 1/29/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import "POITableViewController.h"
#import "Constants.h"


@interface POITableViewController ()

@property (nonatomic, strong) NSString *currLocationString;

@end


@implementation POITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    self.title = NSLocalizedString(@"Select Location", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1 + self.POIs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"POICell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        if ([PRODUCT_NAME isEqualToString:NSLocalizedString(PRODUCT_NAME, nil)]) {    //English Locale
            self.currLocationString = [NSString stringWithFormat:@"%@, %@, %@, %@",
                                  self.currentLocation.thoroughfare,
                                  self.currentLocation.locality,
                                  self.currentLocation.administrativeArea,
                                  self.currentLocation.country];
        } else {
            self.currLocationString = [NSString stringWithFormat:@"%@, %@, %@, %@",
                                  self.currentLocation.country,
                                  self.currentLocation.administrativeArea,
                                  self.currentLocation.locality,
                                  self.currentLocation.thoroughfare];
        }
        
        cell.textLabel.text = self.currLocationString;
        cell.textLabel.font = [UIFont fontWithName:APP_FONT size:14];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.textLabel.text = self.POIs[indexPath.row - 1];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.poiDelegate selectedPOI:self.currLocationString];
    } else {
        [self.poiDelegate selectedPOI:self.POIs[indexPath.row - 1]];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
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
