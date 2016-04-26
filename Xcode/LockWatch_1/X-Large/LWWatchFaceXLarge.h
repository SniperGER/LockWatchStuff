//
//  LWWatchFaceXLarge.h
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"

@interface LWWatchFaceXLarge : WatchFaceBase {
    UILabel* hourLabel;
    UILabel* minuteLabel;
    UILabel* secondIndicator;
    
    UIView* labelView;
}

@end
