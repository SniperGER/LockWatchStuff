//
//  WatchButton.h
//  LockWatch
//
//  Created by Janik Schmidt on 08.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchButton : UIButton

- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title;
- (UIImage *)imageWithColor:(UIColor *)color;

@end
