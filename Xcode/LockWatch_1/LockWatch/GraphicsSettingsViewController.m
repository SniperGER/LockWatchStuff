//
//  WatchFaceSettingsViewController.m
//  LockWatch_Test
//
//  Created by Janik Schmidt on 17.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "GraphicsSettingsViewController.h"

@interface GraphicsSettingsViewController ()

@end

@implementation GraphicsSettingsViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = NSLocalizedString(@"SETTINGS_GRAPHICS", nil);
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *selected = [[UIView alloc] initWithFrame:cell.frame];
        selected.backgroundColor = [UIColor colorWithRed:54.0/255.0 green:54.0/255.0 blue:54.0/255.0 alpha:1];
        cell.selectedBackgroundView = selected;
        cell.textLabel.text = NSLocalizedString(@"SETTINGS_GRAPHICS_AA", nil);
        
        UISwitch* s = [[UISwitch alloc] init];
        CGSize switchSize = [s sizeThatFits:CGSizeZero];
        s.frame = CGRectMake(cell.contentView.bounds.size.width - switchSize.width - 5.0f,
                             (cell.contentView.bounds.size.height - switchSize.height) / 2.0f,
                             switchSize.width,
                             switchSize.height);
        s.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        s.tag = [indexPath row];
        if ([defaults objectForKey:@"enableAntialiasing"]) {
            if ([defaults boolForKey:@"enableAntialiasing"]) {
                s.on = YES;
            }
        } else {
            [defaults setBool:YES forKey:@"enableAntialiasing"];
            s.on = YES;
        }
        
        [s addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = s;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = NSLocalizedString(@"SETTINGS_GRAPHICS_AA_FOOTER", nil);
            break;
        default:
            break;
    }
    return sectionName;
}

- (void)switchChanged:(id)sender {
    //NSLog(@"%d",[sender tag]);
    UISwitch* tappedSwitch = (UISwitch*)sender;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL switchIsOn = [tappedSwitch isOn];
    switch ([sender tag]) {
        case 0:
            [defaults setBool:switchIsOn forKey:@"enableAntialiasing"];
            break;
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"antialiasing" object:self userInfo:nil];
}

@end
