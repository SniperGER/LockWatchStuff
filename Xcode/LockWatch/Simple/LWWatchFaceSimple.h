//
//  LWWatchFaceSimple.h
//  LockWatch
//
//  Created by Janik Schmidt on 23.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFace.h"

@interface LWWatchFaceSimple : LWWatchFace<UIScrollViewDelegate> {
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
