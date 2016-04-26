//
//  SettingsViewController.h
//  LockWatch_Test
//
//  Created by Janik Schmidt on 16.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController {
    NSMutableDictionary* weatherSettings;
}

- (IBAction)dismissView:(id)sender;

@end
