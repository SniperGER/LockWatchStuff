//
//  CCDetailTableViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "CCDetailTableViewController.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation CCDetailTableViewController
@synthesize locTitle, data;

id _data;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = locTitle;
    [self.tableView setBackgroundColor:[UIColor darkThemeBaseColor]];
    [self.tableView setSeparatorColor:[UIColor darkThemeSeparatorColor]];
    
    for (int i=0; i<[data count]; i++) {
        if ([[data objectAtIndex:i][@"meta"][@"name"] isEqualToString:locTitle]) {
            _data = [data objectAtIndex:i][@"content"];
        }
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.useButton setTitle:NSLocalizedString(@"COLOR_SETS_USE_SET", nil)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setSetData:(id)_data {
    data = _data;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_data count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.backgroundColor = [self colorFromHexString:[_data objectAtIndex:[indexPath row]][@"hex"]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    separatorLineView.backgroundColor = [UIColor clearColor]; // set color as you want.
    [cell.contentView addSubview:separatorLineView];
    
    return cell;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"setDetailToColorDetail" sender:[tableView cellForRowAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"setDetailToColorDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        //[segue.destinationViewController setLocTitle:[[sender textLabel] text]];
        [segue.destinationViewController setColorName:[_data objectAtIndex:[indexPath row]][@"name"]];
        [segue.destinationViewController setBgColorHex:[_data objectAtIndex:[indexPath row]][@"hex"]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (IBAction)useSet:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    
    NSMutableArray* colorArray = [[NSMutableArray alloc] init];
    for (int i=0; i<[_data count]; i++) {
        NSMutableDictionary* singleColorDict = [[NSMutableDictionary alloc] init];
        [singleColorDict setObject:[_data objectAtIndex:i][@"hex"] forKey:@"hex"];
        
        if ([locTitle isEqualToString:@"watchOS"]) {
            [singleColorDict setObject:NSLocalizedString([_data objectAtIndex:i][@"name"], nil) forKey:@"name"];
        } else {
            [singleColorDict setObject:[_data objectAtIndex:i][@"name"] forKey:@"name"];
        }
        [colorArray addObject:singleColorDict];
    }
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    [defaults setObject:colorArray forKey:@"activeColorSet"];
	[defaults writeToFile:PreferencesFilePath atomically:YES];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:colorArray forKey:@"colors"];
    
    //if ([[defaults objectForKey:@"watchColorSelector"] boolValue]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"setActiveColorSet"
                                                        object:self userInfo:dict];
    //}
}

@end
