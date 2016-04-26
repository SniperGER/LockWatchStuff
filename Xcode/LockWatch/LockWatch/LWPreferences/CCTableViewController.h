//
//  CCTableViewController.h
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <SVGgh/SVGgh.h>
#import "colors.h"
#import "CCDetailTableViewController.h"

@interface CCTableViewController : UITableViewController<UIScrollViewDelegate>

@property (nonatomic) NSMutableArray* data;

@end
