//
//  LWWatchFaceHands.h
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWWatchFaceHands : NSObject

+ (UIView*)hourHand:(BOOL)chronoStyle;
+ (UIView*)minuteHand:(BOOL)chronoStyle;
+ (UIView*)secondHand:(NSString*)accentColor;
+ (UIView*)secondHandChrono;

@end
