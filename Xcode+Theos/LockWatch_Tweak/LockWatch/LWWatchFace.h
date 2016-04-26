//
//  WatchFaceBase.h
//  LockWatch
//
//  Created by Janik Schmidt on 23.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LWWatchFaceIndicators.h"
#import "LWWatchFaceHands.h"
#import "LWWatchFaceCustomizations.h"
#import "LWWatchFaceColorSelector.h"
#import "TouchDownGestureRecognizer.h"

#import "CAKeyframeAnimation+AHEasing.h"

@interface LWWatchFace : UIView {
    NSString* titleLabelText;
    //UILabel* titleLabel;
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
    LWWatchFaceColorSelector* colorSelector;
    
    NSMutableDictionary* preferences;
    
    UITapGestureRecognizer* touchUp;
    TouchDownGestureRecognizer* touchDown;
	UILongPressGestureRecognizer* longPress;
}

- (void)touchDownEvent;
- (void)touchUpEvent;

- (void)renderIndicators:(BOOL)customize;
- (void)renderClockHands;

- (void)reRenderIndicatorsExperimental:(NSNumber*)newDetailState;
- (void)reRenderExperimental:(NSString*)newAccentColor;

- (void)initWatchFace;
- (void)deInitWatchFace:(BOOL)wasActiveBefore;
- (void)reInitWatchFace:(BOOL)initAfterAnimation;

- (void)makeCustomizeSheet;
- (void)callCustomizeSheet;
- (void)hideCustomizeSheet;

- (void)updateTime;

- (UIColor*) colorFromHexString:(NSString *)hexString;
- (void)setTitleLabelText:(NSString*)text;

- (UIImage* )getImageFromImageBundle:(NSString *)bundleName withImageName:(NSString*)imageName;

@property NSString* accentColor;

@property BOOL customizable;
@property UILabel* titleLabel;

@property NSString* bundlePath;
@property NSString* imageBundlePath;

@property BOOL allowTouchedZoom;

@end
