//
//  CCTableViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "CCTableViewController.h"


@interface CCTableViewController ()

@end

@implementation CCTableViewController

//id data;
int colorCount;
UILabel* messageLabel;

- (void)viewDidLoad {
    colorCount = 0;
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor darkThemeBaseColor]];
    [self.tableView setSeparatorColor:[UIColor darkThemeSeparatorColor]];
    
    [self setTitle:NSLocalizedString(@"COLOR_SETS", nil)];
    
    /*NSURL* apiUrlLocation = [NSURL URLWithString:@"http://fdev.markab.uberspace.de/proj/floe2/api/sets"];
    NSData* jsonData = [NSData dataWithContentsOfURL:apiUrlLocation];
    if (jsonData) {
        data = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"results"];
    }
    for (int i=0; i<[data count]; i++) {
        colorCount += (int)[[data objectAtIndex:i][@"content"] count];
    }*/
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    //self.refreshControl.backgroundColor = [UIColor purpleColor];
    //self.refreshControl.tintColor = [UIColor whiteColor];
    
    /*messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    messageLabel.textColor = [UIColor colorWithRed:0.68 green:0.70 blue:0.75 alpha:1.0];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = @"No data available";
    self.tableView.backgroundView = messageLabel;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;*/
}

- (void)refreshData {
    NSURL* apiUrlLocation = [NSURL URLWithString:@"http://fdev.markab.uberspace.de/proj/floe2/api/sets"];
    NSData* jsonData = [NSData dataWithContentsOfURL:apiUrlLocation];
    if (jsonData) {
        _data = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"results"];
    }
    [self.refreshControl endRefreshing];
    
    if (_data) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        NSString *title = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"COLOR_SETS_LAST_UPDATED", nil), [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        self.refreshControl.attributedTitle = attributedTitle;
        
        colorCount = 0;
        for (int i=0; i<[_data count]; i++) {
            colorCount += (int)[[_data objectAtIndex:i][@"content"] count];
        }
        
        UITableViewCell* firstCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        firstCell.userInteractionEnabled = YES;
        firstCell.textLabel.enabled = YES;
        firstCell.detailTextLabel.enabled = YES;
        
        [self.tableView setContentOffset:CGPointMake(0, -64.0) animated:YES];
        
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_data) {
        return 1;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_data) {
        return [_data count];
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"colorCell" forIndexPath:indexPath];

    if (cell) {
        [cell setBackgroundColor:[UIColor darkThemeCellColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        
        if (_data) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
            UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
            selected.backgroundColor = [UIColor darkThemeSelectedCellColor];
            [cell setSelectedBackgroundView:selected];
            
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            cell.textLabel.text = [NSString stringWithFormat:@"%@", [_data objectAtIndex:indexPath.row][@"meta"][@"name"]];
            
            NSURL* apiUrlLocation = [NSURL URLWithString:[[NSString stringWithFormat:@"http://fdev.markab.uberspace.de/proj/floe2/api/sets/%@/preview", [_data objectAtIndex:indexPath.row][@"meta"][@"name"]] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
            NSData *data = [NSData dataWithContentsOfURL: apiUrlLocation];
            
            SVGRenderer* test = [[SVGRenderer alloc] initWithString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
            cell.imageView.image = [test asImageWithSize:CGSizeMake(44, 44) andScale:1.0];
        }  else {
            [cell.textLabel setText:NSLocalizedString(@"COLOR_SETS_NO_DATA", nil)];
            cell.userInteractionEnabled = NO;
            cell.textLabel.enabled = NO;
            cell.detailTextLabel.enabled = NO;
        }
    }
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            if (_data) { sectionName = [NSString stringWithFormat:NSLocalizedString(@"COLOR_SETS_FOOTER", nil), colorCount]; }
            break;
        default:
            break;
    }
    return sectionName;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"setsToColorSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString: @"setsToColorSegue"]) {
        [segue.destinationViewController setLocTitle:[[sender textLabel] text]];
        [segue.destinationViewController setSetData:_data];
    }
}

@end
