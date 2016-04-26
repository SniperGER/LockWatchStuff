//
//  LWWatchFaceSimple.h
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"
#import <UIKit/UIKit.h>

@interface LWWatchFaceSimple : WatchFaceBase <UIScrollViewDelegate> {
    int detailState;
    
    UIView* hourIndicators;
    
    UILabel* dateLabel;
    BOOL dateLabelEnabled;
    
    UIScrollView* detailOptions;
    UIScrollView* dateOptions;
    UIView* customizeSecondArm;
    UIView* customizeDate;
}

@end
