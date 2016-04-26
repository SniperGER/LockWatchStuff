//
//  ColorSelector.h
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorSelector : UIScrollView

@property NSArray* colorHexArray;

- (id)initWithFrame:(CGRect)frame withSelectedColor:(NSString*)accentColorSelected;

@end
