//
//  LWWatchFaceChrono.h
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"
#import <UIKit/UIKit.h>

@interface LWWatchFaceChrono : WatchFaceBase <UIScrollViewDelegate> {
    UIView* secondIndicatorChrono;
    
    UILabel* dateLabel;
    BOOL dateLabelEnabled;
    
    UIScrollView* dateOptions;
    UIView* customizeDate;
}

@end
