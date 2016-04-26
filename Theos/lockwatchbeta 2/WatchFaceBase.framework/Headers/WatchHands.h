//
//  WatchHands.h
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WatchHands : NSObject

+ (UIView*)hourHand:(BOOL)chronoStyle;
+ (UIView*)minuteHand:(BOOL)chronoStyle;
+ (UIView*)secondHand:(NSString*)accentColor;
+ (UIView*)secondHandChrono;

@end
