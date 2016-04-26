//
//  SettingsViewController.m
//  LockWatch_Test
//
//  Created by Janik Schmidt on 16.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

NSString* versionNumber;

@implementation SettingsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    versionNumber = @"1.1 Beta 1";
    self.title = NSLocalizedString(@"SETTINGS", nil);
    
    weatherSettings = [[NSMutableDictionary alloc] init];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults objectForKey:@"weather"]) {
        [defaults setObject:weatherSettings forKey:@"weather"];
    } else {
        weatherSettings = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

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
        
        if ([indexPath section] == 0 && [indexPath row] == 0) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_WATCHFACES", nil);
        } else if ([indexPath section] == 0 && [indexPath row] == 1) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_PRIVACY", nil);
        }
        else if ([indexPath section] == 0 && [indexPath row] == 2) {
            cell.textLabel.text = NSLocalizedString(@"SETTINGS_GRAPHICS", nil);
        }
        
        if ([indexPath section] == 0) {
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            switch ([indexPath row]) {
                case 0:
                    cell.imageView.image = [UIImage imageNamed:@"WatchPreferencesIcons.bundle/glances"];
                    break;
                case 1:
                    cell.imageView.image = [UIImage imageNamed:@"WatchPreferencesIcons.bundle/privacy"];
                    break;
                case 2:
                    cell.imageView.image = [UIImage imageNamed:@"WatchPreferencesIcons.bundle/general"];
                default:
                    break;
            }
            cell.imageView.layer.cornerRadius = 14.5;
            cell.imageView.layer.masksToBounds = YES;
            cell.imageView.layer.allowsEdgeAntialiasing = YES;
        } else if ([indexPath section] == 1) {
            UISwitch* s = [[UISwitch alloc] init];
            CGSize switchSize = [s sizeThatFits:CGSizeZero];
            s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                                 (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                                 switchSize.width,
                                 switchSize.height);
            //s.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            s.tag = [indexPath row];
            [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            if ([[weatherSettings objectForKey:@"UseFahrenheit"] boolValue]) {
                s.on = YES;
            } else {
                s.on = NO;
            }
            cell.textLabel.text = NSLocalizedString(@"WEATHER_FAHRENHEIT", nil);
            cell.accessoryView = s;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
            selected.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
            cell.selectedBackgroundView = selected;
        }
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0 && [indexPath row] == 0) {
        [self performSegueWithIdentifier:@"testing" sender:self];
    } else if ([indexPath section] == 0 && [indexPath row] == 1) {
        [self performSegueWithIdentifier:@"segueToPrivacy" sender:self];
    }
    else if ([indexPath section] == 0 && [indexPath row] == 2) {
        [self performSegueWithIdentifier:@"segueToGraphics" sender:self];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"SETTINGS_GENERAL", nil);
            break;
        case 1:
            sectionName = NSLocalizedString(@"SETTINGS_WEATHER", nil);
        default:
            break;
    }
    return sectionName;
}
- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = [NSString stringWithFormat:NSLocalizedString(@"SETTINGS_GENERAL_FOOTER", nil), versionNumber];
            break;
        default:
            break;
    }
    return sectionName;
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchChanged:(id)sender {
    UISwitch* senderSwitch = (UISwitch*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL switchIsOn = [senderSwitch isOn];
    [weatherSettings setValue:[NSNumber numberWithBool:switchIsOn] forKey:@"UseFahrenheit"];
    [defaults setObject:weatherSettings forKey:@"weather"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"antialiasing" object:self userInfo:nil];
}
@end
