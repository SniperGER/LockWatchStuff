//
//  testingViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 04.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "testingViewController.h"
#import "UIDataSwitch.h"

@interface testingViewController ()

@end

NSMutableArray *tableDataStock, *tableDataExternal;

@implementation testingViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"SETTINGS_WATCHFACES", nil);
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    tableDataStock = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"stockPlugins"]];
    
    tableDataExternal = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"externalPlugins"]];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return tableDataStock.count;
            break;
        case 1:
            return tableDataExternal.count;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_STOCK", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_EXTERNAL", nil);
        default:
            break;
    }
    return sectionName;
}
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 1:
            sectionName = NSLocalizedString(@"SETTINGS_WATCHFACES_AVAILABLE_FOOTER", nil);
            break;
        default:
            break;
    }
    return sectionName;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    // Configure the cell...
    cell.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:29.9/255.0 alpha:1];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIDataSwitch* s = [[UIDataSwitch alloc] init];
    CGSize switchSize = [s sizeThatFits:CGSizeZero];
    s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                         (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                         switchSize.width,
                         switchSize.height);
    s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    
    switch ([indexPath section]) {
        case 0:
        {
            NSBundle* plugin = [NSBundle bundleWithIdentifier:[tableDataStock objectAtIndex:[indexPath row]]];
            if ([plugin localizedInfoDictionary]) {
                cell.textLabel.text = [plugin localizedInfoDictionary][@"CFBundleDisplayName"];
            } else {
                cell.textLabel.text = [plugin infoDictionary][@"CFBundleDisplayName"];
            }
            s.on = [[[defaults objectForKey:@"stockPluginsEnabled"] valueForKey:[plugin bundleIdentifier]] boolValue];
            
            NSArray* userDataArray = [[NSArray alloc] initWithObjects:@"stockPluginsEnabled", [plugin bundleIdentifier], nil];
            s.userData = userDataArray;
            
            break;
        }
        case 1:
        {
            NSBundle* plugin = [NSBundle bundleWithIdentifier:[tableDataExternal objectAtIndex:[indexPath row]]];
            if ([plugin localizedInfoDictionary]) {
                cell.textLabel.text = [plugin localizedInfoDictionary][@"CFBundleDisplayName"];
            } else {
                cell.textLabel.text = [plugin infoDictionary][@"CFBundleDisplayName"];
            }
            s.on = [[[defaults objectForKey:@"externalPluginsEnabled"] valueForKey:[plugin bundleIdentifier]] boolValue];
            
            NSArray* userDataArray = [[NSArray alloc] initWithObjects:@"externalPluginsEnabled", [plugin bundleIdentifier], nil];
            s.userData = userDataArray;
            
            break;
        }
        default:
            break;
    }
    
    [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    cell.accessoryView = s;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    if ([sourceIndexPath section] == 0) {
        NSString *stringToMove = tableDataStock[sourceIndexPath.row];
        [tableDataStock removeObjectAtIndex:sourceIndexPath.row];
        [tableDataStock insertObject:stringToMove atIndex:destinationIndexPath.row];
        
        [defaults setObject:tableDataStock forKey:@"stockPlugins"];
    } else if ([sourceIndexPath section] == 1) {
        NSString *stringToMove = tableDataExternal[sourceIndexPath.row];
        [tableDataExternal removeObjectAtIndex:sourceIndexPath.row];
        [tableDataExternal insertObject:stringToMove atIndex:destinationIndexPath.row];
        
        [defaults setObject:tableDataExternal forKey:@"externalPlugins"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:self userInfo:nil];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)switchChanged:(UIDataSwitch*)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    UIDataSwitch* tappedSwitch = (UIDataSwitch*)sender;
    NSMutableDictionary* settingsDict = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:tappedSwitch.userData[0]]];
    BOOL switchIsOn = [tappedSwitch isOn];
    NSString* settingsString = tappedSwitch.userData[0];
    
    [settingsDict setValue:[NSNumber numberWithBool:switchIsOn] forKey:tappedSwitch.userData[1]];
    [defaults setObject:settingsDict forKey:settingsString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"settingsChanged" object:self userInfo:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
