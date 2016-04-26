//
//  PrivacySettingsViewController.m
//  LockWatch_Test
//
//  Created by Janik Schmidt on 18.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "PrivacySettingsViewController.h"

@interface PrivacySettingsViewController ()

@end

@implementation PrivacySettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"SETTINGS_PRIVACY", nil);
    
    privacyWeather = [[NSMutableDictionary alloc] init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"weather"]) {
        [defaults setObject:privacyWeather forKey:@"weater"];
    } else {
        privacyWeather = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell*) tableView:(UITableView*) tableView cellForRowAtIndexPath:(NSIndexPath*) indexPath {
    tableView.separatorColor = [UIColor colorWithRed:41.0/255.0 green:41.0/255.0 blue:41.0/255.0 alpha:1];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    static NSString* cellIdentifier = @"switchCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor colorWithRed:28.0/255.0 green:28.0/255.0 blue:29.9/255.0 alpha:1];
        cell.textLabel.textColor = [UIColor whiteColor];
        
        UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
        selected.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
        cell.selectedBackgroundView = selected;
        
        //cell.textLabel.text = NSLocalizedString((NSString*)[strings objectAtIndex:[indexPath row]], nil);
        UISwitch* s = [[UISwitch alloc] init];
        CGSize switchSize = [s sizeThatFits:CGSizeZero];
        s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                             (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                             switchSize.width,
                             switchSize.height);
        s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        s.tag = [indexPath row];
        //[s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        
        
        if ([indexPath section] == 0) {
            if ([indexPath row] == 0) {
                cell.textLabel.text = NSLocalizedString(@"SETTINGS_PRIVACY_LOCATION", nil);
                if ([[privacyWeather objectForKey:@"UseLocation"] boolValue]) {
                    s.on = YES;
                } else {
                    s.on = NO;
                }
                [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
                cell.accessoryView = s;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else if ([indexPath row] == 1) {
                cell.textLabel.textColor = [UIColor colorWithRed:255.0/255.0 green:143.0/255.0 blue:0/255.0 alpha:1];
                cell.textLabel.text = NSLocalizedString(@"SETTINGS_PRIVACY_WOEID", nil);
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 1) {
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"SETTINGS_PRIVACY_WOEID_ALERT_TITLE", nil)
                                              message:NSLocalizedString(@"SETTINGS_PRIVACY_WOEID_ALERT_DESCRIPTION", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"WOEID";
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:NSLocalizedString(@"SETTINGS_PRIVACY_WOEID_ALERT_OK", nil)
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action)
                                    {
                                        //Handel your yes please button action here
                                        [alertController dismissViewControllerAnimated:YES completion:nil];
                                        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

                                        [defaults setObject:[[alertController textFields] objectAtIndex:0].text forKey:@"weatherUserWOEID"];
                                        
                                    }];
        UIAlertAction* noButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"SETTINGS_PRIVACY_WOEID_ALERT_CANCEL", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alertController dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        [alertController addAction:yesButton];
        [alertController addAction:noButton];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)switchChanged:(id)sender {
    //NSLog(@"%d",[sender tag]);
    UISwitch* tappedSwitch = (UISwitch*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL switchIsOn = [tappedSwitch isOn];
    switch ([sender tag]) {
        case 0:
            [privacyWeather setValue:[NSNumber numberWithBool:switchIsOn] forKey:@"UseLocation"];
            [defaults setObject:privacyWeather forKey:@"weather"];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"antialiasing" object:self userInfo:nil];
}

@end
