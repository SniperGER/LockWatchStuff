//
//  WatchFaceBase.h
//  WatchFaceBase
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "WatchHands.h"
#import "ColorSelector.h"

@interface WatchFaceBase : UIView {
    NSString* titleLabelText;
    UILabel* titleLabel;
    NSString* accentColor;
    NSString* accentColorIndicator;
    
    UIView* borderView;
    BOOL contentIsHidden;
    BOOL isCustomizing;
    
    UIView* customizeBorder;
    
    UIView* indicatorContainer;
    UIView* handContainer;
    
    UIView* hourHand;
    UIView* minuteHand;
    UIView* secondHand;
    
    NSTimer* updateTimeTimer;
    
    UIScrollView* customizeScrollView;
    UIPageControl* customizeScrollViewPager;
    ColorSelector* colorSelector;
}

@property BOOL customizable;

- (void)renderIndicators:(BOOL)customize;
- (void)renderClockHands;

- (void)initWatchFace;
- (void)deInitWatchFace:(BOOL)wasActiveBefore;
- (void)reInitWatchFace:(BOOL)initAfterAnimation;

- (void)makeCustomizeSheet;
- (void)callCustomizeSheet;
- (void)hideCustomizeSheet;

- (void)updateTime;

- (UIColor*) colorFromHexString:(NSString *)hexString;

@end