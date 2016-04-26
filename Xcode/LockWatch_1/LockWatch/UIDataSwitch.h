//
//  UIDataSwitch.h
//  LockWatch
//
//  Created by Janik Schmidt on 06.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDataSwitch : UISwitch {
    id userData;
}

@property (nonatomic, readwrite, retain) id userData;

@end
