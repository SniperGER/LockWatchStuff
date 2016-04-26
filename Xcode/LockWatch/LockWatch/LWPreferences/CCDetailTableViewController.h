//
//  CCDetailTableViewController.h
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "colors.h"
#import "CCColorDetailTableViewController.h"

@interface CCDetailTableViewController : UITableViewController

@property (strong, nonatomic) NSString *locTitle;
@property (strong, nonatomic) id data;

- (void)setLocTitle:(NSString *)locTitle;
- (void)setSetData:(id)_data;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *useButton;

@end
