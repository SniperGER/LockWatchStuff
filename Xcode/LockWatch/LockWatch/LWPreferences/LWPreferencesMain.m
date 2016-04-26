//
//  LWPreferencesMain.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWPreferencesMain.h"
#import "colors.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWPreferencesMain

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView setBackgroundColor:[UIColor darkThemeBaseColor]];
    [self.tableView setSeparatorColor:[UIColor darkThemeSeparatorColor]];
    
    [self setTitle:NSLocalizedString(@"SETTINGS_TITLE", nil)];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    if (section == 1) {
        return 2;
    }
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
    // Configure the cell...
    if (cell) {
        [cell setBackgroundColor:[UIColor darkThemeCellColor]];
        [cell.textLabel setTextColor:[UIColor whiteColor]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
        selected.backgroundColor = [UIColor darkThemeSelectedCellColor];
        [cell setSelectedBackgroundView:selected];
        

        if ([indexPath section] == 0) {
            switch ([indexPath row]) {
                case 0:
                    [cell.textLabel setText:NSLocalizedString(@"COLOR_SETS", nil)];
                    break;
                default:
                    break;
            }
        } else if ([indexPath section] == 1) {
            if ([indexPath row] == 0) {
                [cell.textLabel setText:NSLocalizedString(@"WATCH_SELECTOR", nil)];
                UISwitch* s = [[UISwitch alloc] init];
                CGSize switchSize = [s sizeThatFits:CGSizeZero];
                s.tag = [[NSString stringWithFormat:@"%d%d", (int)[indexPath section], (int)[indexPath row]] intValue];
                s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                                     (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                     switchSize.width,
                                     switchSize.height);
                [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                if ([[defaults objectForKey:@"watchColorSelector"] boolValue]){
                    s.on = YES;
                }
                cell.accessoryView = s;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if ([indexPath row] == 1) {
                [cell.textLabel setText:NSLocalizedString(@"FAHRENHEIT", nil)];
                UISwitch* s = [[UISwitch alloc] init];
                CGSize switchSize = [s sizeThatFits:CGSizeZero];
                s.tag = [[NSString stringWithFormat:@"%d%d", (int)[indexPath section], (int)[indexPath row]] intValue];
                s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                                     (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                     switchSize.width,
                                     switchSize.height);
                [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                
                NSMutableDictionary* weatherSettings = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
                if ([[weatherSettings objectForKey:@"UseFahrenheit"] boolValue]){
                    s.on = YES;
                }
                cell.accessoryView = s;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        [self performSegueWithIdentifier:@"segueToColors" sender:[tableView cellForRowAtIndexPath:indexPath]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)switchChanged:(UISwitch*)sender {
    UISwitch* senderSwitch = (UISwitch*)sender;
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
    BOOL switchIsOn = [senderSwitch isOn];
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:[NSNumber numberWithBool:switchIsOn] forKey:@"switchIsOn"];
    
    NSMutableDictionary* weatherSettings;
    
    switch (sender.tag) {
        case 10:
            [defaults setObject:[NSNumber numberWithBool:switchIsOn] forKey:@"watchColorSelector"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"reRenderCustomizeSheets" object:self userInfo:dict];
            break;
        case 11:
            weatherSettings = [[NSMutableDictionary alloc] init];
            if (![defaults objectForKey:@"weather"]) {
                [defaults setObject:weatherSettings forKey:@"weather"];
            } else {
                weatherSettings = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
            }
            [weatherSettings setValue:[NSNumber numberWithBool:switchIsOn] forKey:@"UseFahrenheit"];
            [defaults setObject:weatherSettings forKey:@"weather"];
            NSLog(@"%@", [defaults objectForKey:@"weather"]);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"weatherFahrenheit" object:self userInfo:dict];
        default:
            break;
    }
	[defaults writeToFile:PreferencesFilePath atomically:YES];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
