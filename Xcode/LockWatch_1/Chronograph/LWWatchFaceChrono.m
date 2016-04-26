//
//  LWWatchFaceChrono.m
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceChrono.h"
#import "WatchIndicators.h"
#import "WatchCustomizations.h"

#define deg2rad(angle) ((angle) / 180.0 * M_PI)
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceChrono
NSUserDefaults* defaults;

+ (void)load {
    //NSLog(@"\"Chronograph\" loaded");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.customizable = YES;
        
        accentColor = @"#FF9500";
        preferences = [[NSMutableDictionary alloc] init];
        defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"chrono"]) {
            [defaults setObject:preferences forKey:@"chrono"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"chrono"]];
        }
        
        if ([preferences objectForKey:@"DateLabelEnabled"]) {
            dateLabelEnabled = [[preferences objectForKey:@"DateLabelEnabled"] boolValue];
        } else {
            [preferences setValue:[NSNumber numberWithBool:YES] forKey:@"DateLabelEnabled"];
            dateLabelEnabled = YES;
        }
        
        [defaults setObject:preferences forKey:@"chrono"];
        //[defaults writeToFile:PreferencesFilePath atomically:YES];
        
        [self makeDateLabel];
        [self renderIndicators:NO];
        [self renderClockHands];
        [self makeCustomizeSheet];
        
        /*UIView* testView = [[[NSBundle bundleWithIdentifier:@"de.sniperger.watchface.chrono"] loadNibNamed:@"Analog" owner:self options:nil] objectAtIndex:0];
        [self addSubview:testView];*/
    }
    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
    
//    [secondHand setTransform:CGAffineTransformMakeRotation(deg2rad(0))];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
}
- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    [super reInitWatchFace:initAfterAnimation];
}

- (void)makeCustomizeSheet {
    
    customizeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    [customizeScrollView setContentSize:CGSizeMake(self.frame.size.width, self.frame.size.height)];
    [customizeScrollView setPagingEnabled:YES];
    [customizeScrollView setDelegate:self];
    [customizeScrollView.layer setMasksToBounds:NO];
    [customizeScrollView addSubview:customizeBorder];
    
    // Page 3 - Date Options
    customizeDate = [[WatchCustomizations alloc] generalDateCustomize:CGRectMake(0, 0, 312, 390)
                                                           withTarget:self
                                                        withTapAction:@selector(setDateLabelVisibility:)
                                                     withUserDefaults:preferences
                                                          withPrefKey:@"DateLabelEnabled"];
    [customizeScrollView addSubview:customizeDate];
    
    [customizeScrollView setScrollEnabled:NO];
    [customizeScrollView setAlpha:0];
    [self addSubview:customizeScrollView];
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    //customizeScrollView.scrollEnabled = YES;
    customizeScrollViewPager.alpha = 1;
    
    
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         customizeScrollView.alpha = 1;
                         customizeDate.alpha = 1;
                         dateOptions.alpha = 1;
                         indicatorContainer.alpha = 0.2;
                         secondIndicatorChrono.alpha = 0;
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                         secondHand.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         //hourHand.alpha = 0;
                         //minuteHand.alpha = 0;
                     }];
}
- (void)hideCustomizeSheet {
    //[super hideCustomizeSheet];
    if (isCustomizing) {
        isCustomizing = NO;
        customizeScrollView.scrollEnabled = NO;
    }
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        customizeScrollView.alpha = 0;
        indicatorContainer.alpha = 1;
        secondIndicatorChrono.alpha = 1;
        hourHand.alpha = 1;
        minuteHand.alpha = 1;
        secondHand.alpha = 1;
        dateOptions.alpha = 0;
        
        if (dateLabelEnabled) {
            dateLabel.alpha = 1;
        }
    } completion:nil];
    [indicatorContainer.layer removeAllAnimations];
}

- (void)renderIndicators:(BOOL)customize {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!customize) {
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }
    
    [indicatorContainer addSubview:[[WatchIndicators alloc] chronoIndicators]];
    
    [self insertSubview:indicatorContainer atIndex:0];
}

- (void)makeDateLabel {
    [dateLabel removeFromSuperview];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    dateLabel.text = [NSString stringWithFormat:@"%@", dateString];
    dateLabel.textAlignment = NSTextAlignmentRight;
    dateLabel.textColor = [self colorFromHexString:accentColor];
    dateLabel.center = CGPointMake((312/2)+65, 390/2);
    dateLabel.font = [UIFont systemFontOfSize:32];
    

    if ([preferences objectForKey:@"DateLabelEnabled"]) {
        if (![[preferences objectForKey:@"DateLabelEnabled"] boolValue]) {
            [dateLabel setAlpha:0];
        }
    }
    
    dateLabel.layer.allowsEdgeAntialiasing = YES;
    
    [self addSubview:dateLabel];
}

- (void)renderClockHands {
    [[handContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [handContainer removeFromSuperview];
    
    secondHand = [WatchHands secondHandChrono];
    [secondHand.layer setPosition:CGPointMake(312/2, 390/2 + 57)];
    [handContainer addSubview:secondHand];
    
    hourHand = [WatchHands hourHand:YES];
    [hourHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:hourHand];
    
    minuteHand = [WatchHands minuteHand:YES];
    [minuteHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:minuteHand];
    
    secondIndicatorChrono = [WatchHands secondHand:accentColor];
    [secondIndicatorChrono.layer setPosition:CGPointMake(312/2, 390/2)];
    [handContainer addSubview:secondIndicatorChrono];
    
    [self addSubview:handContainer];
}

- (void)updateTime {
    [super updateTime];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    [dateLabel setText:[NSString stringWithFormat:@"%@", dateString]];
}


- (void)setDateLabelVisibility:(UITapGestureRecognizer*)sender {
    defaults = [NSUserDefaults standardUserDefaults];
    
    for (int i=0; i<[[[customizeDate subviews] objectAtIndex:1] subviews].count; i++) {
        [[[[[customizeDate subviews] objectAtIndex:1] subviews] objectAtIndex:i].layer setBorderWidth:0];
    }
    [sender.view.layer setBorderWidth:3];
    
    switch (sender.view.tag) {
        case 950:
            dateLabelEnabled = false;
            [dateLabel setAlpha:0];
            [preferences setValue:[NSNumber numberWithBool:NO] forKey:@"DateLabelEnabled"];
            break;
        case 951:
            dateLabelEnabled = true;
            [dateLabel setAlpha:1];
            [preferences setValue:[NSNumber numberWithBool:YES] forKey:@"DateLabelEnabled"];
            break;
        default:
            break;
    }
    [defaults setObject:preferences forKey:@"chrono"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
}

@end
