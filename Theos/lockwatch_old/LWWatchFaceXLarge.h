//
//  LWWatchFaceXLarge.h
//  LockWatch
//
//  Created by Janik Schmidt on 10.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWatchFaceXLarge : UIView {
    NSTimer* updateTimeTimer;
    NSTimer* animationTimer;
    
    UIView* customizeView;
    
    UIScrollView* colorOptions;
}

@property UILabel *minuteLabel;
@property UILabel *hourLabel;
@property UILabel *secondIndicator;
@property UIView* view;

-(void) deinit;
-(void) reinit;

-(void)callCustomizeSheet;

@end
