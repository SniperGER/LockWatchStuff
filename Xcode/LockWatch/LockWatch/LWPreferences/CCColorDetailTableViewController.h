//
//  CCColorDetailTableViewController.h
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "colors.h"

@interface CCColorDetailTableViewController : UITableViewController

@property (strong, nonatomic) NSString *bgColorHex;
@property (strong, nonatomic) NSString *colorName;

- (void)setBgColorHex:(NSString *)bgColorHex;
- (void)setColorName:(NSString *)colorName;

@end
