//
//  WatchFaceSettingsViewController.h
//  LockWatch_Test
//
//  Created by Janik Schmidt on 17.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchFaceSettingsViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray* switches;
    NSMutableArray* labels;
    
    NSMutableArray* stockWatchFacePlugins;
    NSMutableArray* watchFacePlugins;
}

- (IBAction)startEditing:(id)sender;

@end
