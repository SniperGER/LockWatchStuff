//
//  LWWatchFaceColor.m
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceColor.h"

#define deg2rad(angle) ((angle) / 180.0 * M_PI)
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceColor
NSUserDefaults* defaults;

+ (void)load {
    //NSLog(@"\"Color\" loaded");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.customizable = YES;
        
        preferences = [[NSMutableDictionary alloc] init];
        //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"color"]) {
            [defaults setObject:preferences forKey:@"color"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"color"]];
        }

        if ([preferences objectForKey:@"AccentColor"]) {
            accentColorIndicator = [preferences objectForKey:@"AccentColor"];
        } else {
            [preferences setObject:@"#18B5FC" forKey:@"AccentColor"];
            accentColorIndicator = @"#18B5FC";
        }
        
        [defaults setObject:preferences forKey:@"color"];
        //[defaults writeToFile:PreferencesFilePath atomically:YES];
        
        customizeBorder = [[WatchCustomizations alloc] generalCustomizeBorder:CGRectMake(0,0,312,390)];
        [self addSubview:customizeBorder];
        
        [self renderIndicators:NO];
        [self renderClockHands];
        [self makeCustomizeSheet];
    }
    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
}
- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    [super reInitWatchFace:initAfterAnimation];
}

- (void)makeCustomizeSheet {
    customizeColors = [[WatchCustomizations alloc] colorIndicatorCustomize:CGRectMake(0, 0, 312, 390)
                                                                   withAccentColor:accentColorIndicator
                                                                        withTarget:self
                                                                     withTapAction:@selector(reRenderIndicators:)];
    [customizeColors setAlpha:0];
    [self addSubview:customizeColors];
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         customizeColors.alpha = 1;
                         customizeBorder.alpha = 1;
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                         secondHand.alpha = 0;
                     } completion:^(BOOL finished) {
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        indicatorContainer.transform = CGAffineTransformMakeScale(0.935, 0.935); //first part of animation
        indicatorContainer.transform = CGAffineTransformMakeScale(1.0, 1.0); //second part of animation
    } completion:nil];
}
- (void)hideCustomizeSheet {
    [super hideCustomizeSheet];
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        customizeColors.alpha = 0;
        customizeBorder.alpha = 0;
        indicatorContainer.alpha = 1;
        indicatorContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
        hourHand.alpha = 1;
        minuteHand.alpha = 1;
        
    } completion:nil];
    [indicatorContainer.layer removeAllAnimations];
}

-(void)renderIndicators:(BOOL)customize {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!customize) {
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }
    
    [indicatorContainer addSubview:[[WatchIndicators alloc] colorIndicators:accentColorIndicator]];
    
    [self insertSubview:indicatorContainer atIndex:0];
}

- (void)renderClockHands {
    [[handContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [handContainer removeFromSuperview];
    
    hourHand = [WatchHands hourHand:NO];
    [hourHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:hourHand];
    
    minuteHand = [WatchHands minuteHand:NO];
    [minuteHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:minuteHand];
    
    secondHand = [WatchHands secondHand:accentColor];
    [secondHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:secondHand];
    
    [self addSubview:handContainer];
}

- (void)reRenderIndicators:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = [[[ColorSelector alloc] init] colorHexArray];
    accentColorIndicator = [colorHexArray objectAtIndex:sender.view.tag-900];
    
    //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    defaults = [NSUserDefaults standardUserDefaults];
    [preferences setObject:accentColorIndicator forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"color"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
    
    [self renderIndicators:YES];
    
    for (int i=0; i<[[[customizeColors subviews] objectAtIndex:0] subviews].count; i++) {
        [[[[[customizeColors subviews] objectAtIndex:0] subviews] objectAtIndex:i].layer setBorderWidth:0];
    }
    
    sender.view.layer.borderWidth = 3;
}

@end