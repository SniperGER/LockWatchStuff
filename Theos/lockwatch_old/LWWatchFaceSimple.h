//
//  LWWatchFaceSimple2.h
//  LockWatch
//
//  Created by Janik Schmidt on 09.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWatchFaceSimple : UIView <UIScrollViewDelegate> {
    UIView* handContainer;
    UIView* secondCircle;
    UIImageView* minuteHand;
    UIImageView* hourHand;
    
    UIView* indicatorContainer;
    
    NSTimer* updateTimeTimer;
    
    UIView* customizeView;
    UIPageControl* customizeScrollViewPager;
}

@property NSString* accentColor;

-(void) renderIndicators;

-(void) secondHand:(float)seconds Mseconds:(float)Mseconds;
-(void) minuteHand:(float)minutes seconds:(float)seconds Mseconds:(float)Mseconds;
-(void) hourHand:(float)hours minutes:(float)minutes seconds:(float)seconds Mseconds:(float)Mseconds;

-(void) updateTime;

-(void) deinit;
-(void) reinit;

-(void) makeCustomizeSheet;
-(void) callCustomizeSheet;

- (UIColor*) colorFromHexString:(NSString *)hexString;
@end
