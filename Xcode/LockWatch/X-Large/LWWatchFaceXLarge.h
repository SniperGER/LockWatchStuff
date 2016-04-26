//
//  LWWatchFaceXLarge.h
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <LWWatchFace/LWWatchFace.h>
#import <UIKit/UIKit.h>

@interface LWWatchFaceXLarge : LWWatchFace {
    UILabel* hourLabel;
    UILabel* minuteLabel;
    UILabel* secondIndicator;
    
    UIView* labelView;
}

@end
