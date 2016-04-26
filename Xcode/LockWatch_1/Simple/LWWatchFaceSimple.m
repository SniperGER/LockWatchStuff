//
//  LWWatchFaceSimple.m
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//


#import "LWWatchFaceSimple.h"

#define deg2rad(angle) ((angle) / 180.0 * M_PI)
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceSimple
float scrollViewDelta;
NSUserDefaults* defaults;

+ (void)load {
    //NSLog(@"\"Simple\" loaded");
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.customizable = YES;
        detailState = 2;

        preferences = [[NSMutableDictionary alloc] init];
        
        defaults = [NSUserDefaults standardUserDefaults];
        //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        if (![defaults objectForKey:@"simple"]) {
            [defaults setObject:preferences forKey:@"simple"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"simple"]];
        }

        if ([preferences objectForKey:@"DetailState"]) {
            detailState = [[preferences valueForKey:@"DetailState"] intValue];
        } else {
            [preferences setValue:[NSNumber numberWithInt:2] forKey:@"DetailState"];
            detailState = 2;
        }

        if ([preferences objectForKey:@"AccentColor"]) {
            accentColor = [preferences objectForKey:@"AccentColor"];
        } else {
            [preferences setObject:@"#FF9500" forKey:@"AccentColor"];
            accentColor = @"#FF9500";
        }

        if ([preferences objectForKey:@"DateLabelEnabled"]) {
            dateLabelEnabled = [[preferences objectForKey:@"DateLabelEnabled"] boolValue];
        } else {
            [preferences setValue:[NSNumber numberWithBool:YES] forKey:@"DateLabelEnabled"];
            dateLabelEnabled = YES;
        }
        
        [defaults setObject:preferences forKey:@"simple"];
        //[defaults writeToFile:PreferencesFilePath atomically:YES];
        
        [self makeDateLabel];
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
    customizeScrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    [customizeScrollView setContentSize:CGSizeMake(self.frame.size.width*3, self.frame.size.height)];
    [customizeScrollView setPagingEnabled:YES];
    [customizeScrollView setDelegate:self];
    [customizeScrollView.layer setMasksToBounds:NO];
    [customizeScrollView addSubview:customizeBorder];
    
    // Page 1 - Detail
    detailOptions = [[WatchCustomizations alloc] simpleDetailCustomize:CGRectMake(10, 10, 50, 370)
                                                       withCurrentDetailState:detailState
                                                                   withTarget:self
                                                                withTapAction:@selector(reRenderIndicators:)];

    [customizeScrollView addSubview:detailOptions];
    
    // Page 2 - Accent Color
    customizeSecondArm = [[WatchCustomizations alloc] simpleAccentColorCustomize:CGRectMake(312, 0, 312, 390)
                                                                  withAccentColor:accentColor
                                                                       withTarget:self
                                                                   withTapAction:@selector(reRenderSecondHand:)];
    [customizeScrollView addSubview:customizeSecondArm];

    // Page 3 - Date Options
    customizeDate = [[WatchCustomizations alloc] generalDateCustomize:CGRectMake(312*2, 0, 312, 390)
                                                                  withTarget:self
                                                               withTapAction:@selector(setDateLabelVisibility:)
                                                            withUserDefaults:preferences
                                                                 withPrefKey:@"DateLabelEnabled"];
    [customizeScrollView addSubview:customizeDate];
    
    customizeScrollViewPager = [[UIPageControl alloc] init];
    [customizeScrollViewPager.layer setPosition:CGPointMake(312/2, 3)];
    [customizeScrollViewPager setNumberOfPages:3];
    [customizeScrollViewPager setCurrentPage:0];
    [customizeScrollViewPager setTransform:CGAffineTransformMakeScale(0.85, 0.85)];
    [customizeScrollViewPager setAlpha:0];
    [self addSubview:customizeScrollViewPager];
    
    [customizeScrollView setScrollEnabled:NO];
    [customizeScrollView setAlpha:0];
    [self addSubview:customizeScrollView];
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    [customizeScrollView setScrollEnabled:YES];
    [customizeScrollViewPager setAlpha:1];
    
    switch (customizeScrollViewPager.currentPage) {
        case 0:
            [colorSelector setAlpha:0];
            [customizeSecondArm setAlpha:0];
            [dateOptions setAlpha:0];
            [customizeDate setAlpha:0];
            break;
        case 1:
            [customizeBorder setAlpha:0];
            break;
        default:
            break;
    }
    
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [customizeScrollView setAlpha:1];
                         
                         [customizeScrollViewPager setAlpha:1];
                         switch (customizeScrollViewPager.currentPage) {
                             case 0:
                                 [handContainer setAlpha:0];
                                 [dateLabel setAlpha:0];
                                 [customizeBorder setAlpha:1];
                                 break;
                             case 1:
                                 [indicatorContainer setAlpha:0];
                                 [hourHand setAlpha:0];
                                 [minuteHand setAlpha:0];
                                 [secondHand setAlpha:1];
                                 [dateLabel setAlpha:0];
                                 break;
                             case 2:
                                 [handContainer setAlpha:0];
                                 [indicatorContainer setAlpha:0];
                                 break;
                             default:
                                 break;
                         }
                     } completion:^(BOOL finished) {
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [indicatorContainer setTransform:CGAffineTransformMakeScale(0.935, 0.935)];
        [indicatorContainer setTransform:CGAffineTransformMakeScale(1, 1)];
    } completion:nil];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [handContainer setTransform:CGAffineTransformMakeScale(0.935, 0.935)];
        [handContainer setTransform:CGAffineTransformMakeScale(1, 1)];
    } completion:nil];
}
-(void) hideCustomizeSheet {
    //[super hideCustomizeSheet];
    if (isCustomizing) {
        isCustomizing = NO;
        [customizeScrollView setScrollEnabled:NO];
    }
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        [self setTransform:CGAffineTransformMakeTranslation(0, 0)];
        [customizeScrollView setAlpha:0];
        [customizeScrollViewPager setAlpha:0];
        [indicatorContainer setAlpha:1];
        [indicatorContainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [handContainer setAlpha:1];
        [handContainer setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
        [hourHand setAlpha:1];
        [minuteHand setAlpha:1];
        
        if (dateLabelEnabled) {
            [dateLabel setAlpha:1];
        }
    } completion:nil];
    [indicatorContainer.layer removeAllAnimations];
    [handContainer.layer removeAllAnimations];
}

- (void)renderIndicators:(BOOL)customize {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!customize) {
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }

    [indicatorContainer addSubview:[[WatchIndicators alloc] simpleIndicators:detailState isCustomizing:customize]];
    
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

-(void) reRenderIndicators:(UITapGestureRecognizer*)sender {
    for (int i=0; i<[[detailOptions subviews] count]; i++) {
        [[[[detailOptions subviews] objectAtIndex:i] layer] setBorderWidth:0];
    }
    [sender.view.layer setBorderWidth:3];
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    switch (sender.view.tag) {
        case 800:
            detailState = 0;
            [preferences setValue:[NSNumber numberWithInt:0] forKey:@"DetailState"];
            break;
        case 801:
            detailState = 1;
            [preferences setValue:[NSNumber numberWithInt:1] forKey:@"DetailState"];
            break;
        case 802:
            detailState = 2;
            [preferences setValue:[NSNumber numberWithInt:2] forKey:@"DetailState"];
            break;
        case 803:
            detailState = 3;
            [preferences setValue:[NSNumber numberWithInt:3] forKey:@"DetailState"];
            break;
        default:
            break;
    }
    [defaults setObject:preferences forKey:@"simple"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
    
    [self renderIndicators:true];
}

- (void)makeDateLabel {
    [dateLabel removeFromSuperview];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [dateLabel setText:[NSString stringWithFormat:@"%@", dateString]];
    [dateLabel setTextAlignment:NSTextAlignmentRight];
    [dateLabel setTextColor:[self colorFromHexString:accentColor]];
    [dateLabel setCenter:CGPointMake((312/2)+65, 390/2)];
    [dateLabel setFont:[UIFont systemFontOfSize:32]];
    
    if ([preferences objectForKey:@"DateLabelEnabled"]) {
        if (![[preferences objectForKey:@"DateLabelEnabled"] boolValue]) {
            [dateLabel setAlpha:0];
        }
    }
    
    [dateLabel.layer setAllowsEdgeAntialiasing:YES];
    
    [self addSubview:dateLabel];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = (scrollView.contentOffset.x + (0.5f * 312.0)) / 312.0;
    [customizeScrollViewPager setCurrentPage:page];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = (scrollView.contentOffset.x + (0.5f * 312.0)) / 312.0;
    [customizeScrollViewPager setCurrentPage:page];
    
    float pageProgress = ((customizeScrollViewPager.currentPage * 312) - scrollView.contentOffset.x)/312;
    NSArray *fadeOut, *fadeIn;
    
    if (customizeScrollViewPager.currentPage == 0) {
        fadeOut = [[NSArray alloc] initWithObjects:indicatorContainer, customizeBorder, detailOptions, nil];
        fadeIn = [[NSArray alloc] initWithObjects:customizeSecondArm, handContainer, colorSelector, nil];
    } else if (customizeScrollViewPager.currentPage == 1) {
        fadeOut = [[NSArray alloc] initWithObjects:customizeSecondArm, handContainer, colorSelector, nil];
        fadeIn = [[NSArray alloc] initWithObjects:indicatorContainer, customizeBorder, detailOptions, nil];
    } else if (customizeScrollViewPager.currentPage == 2) {
        if (dateLabelEnabled) {
            fadeOut = [[NSArray alloc] initWithObjects:customizeDate, dateLabel, nil];
        } else {
            fadeOut = [[NSArray alloc] initWithObjects:customizeDate, nil];
        }
        fadeIn = [[NSArray alloc] initWithObjects:customizeSecondArm, handContainer, colorSelector, nil];
    }
    
    if (pageProgress > 0) {
        [fadeOut enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
            [object setAlpha:1-pageProgress];
        }];
        
        if (customizeScrollViewPager.currentPage < 1) {
            [fadeIn enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
                [object setAlpha:0];
            }];
        } else {
            [fadeIn enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
                [object setAlpha:pageProgress];
            }];
        }

    } else if (pageProgress < 0) {
        [fadeOut enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
            [object setAlpha:1+pageProgress];
        }];
        if (customizeScrollViewPager.currentPage >= 1) {
            [fadeIn enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
                [object setAlpha:0];
            }];
        } else {
            [fadeIn enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
                [object setAlpha:-pageProgress];
            }];
        }
        if (customizeScrollViewPager.currentPage == 1) {
            [customizeDate setAlpha:-pageProgress];
            if (dateLabelEnabled) {
                [dateLabel setAlpha:-pageProgress];
            }
        }
    } else {
        [fadeOut enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
            [object setAlpha:1];
        }];
        [fadeIn enumerateObjectsUsingBlock:^ (id object, NSUInteger idx, BOOL *stop) {
            [object setAlpha:0];
        }];
    }

    scrollViewDelta = scrollView.contentOffset.x;
}

- (void)updateTime {
    [super updateTime];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"d"];
    NSString *dateString = [dateFormat stringFromDate:today];
    
    [dateLabel setText:[NSString stringWithFormat:@"%@", dateString]];
}

- (void)reRenderSecondHand:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = [[[ColorSelector alloc] init] colorHexArray];
    accentColor = [colorHexArray objectAtIndex:sender.view.tag-900];
    
    [secondHand removeFromSuperview];
    
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [preferences setObject:accentColor forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"simple"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
    
    secondHand = [WatchHands secondHand:accentColor];
    [secondHand.layer setPosition:CGPointMake(312/2, 390/2)];
    [secondHand setTransform:CGAffineTransformMakeRotation(deg2rad(180))];
    [handContainer addSubview:secondHand];
    
    [dateLabel setTextColor:[self colorFromHexString:accentColor]];
    
    for (int i=0; i<[[[customizeSecondArm subviews] objectAtIndex:1] subviews].count; i++) {
        [[[[[customizeSecondArm subviews] objectAtIndex:1] subviews] objectAtIndex:i].layer setBorderWidth:0];
    }
    [sender.view.layer setBorderWidth:3];
}

-(void) setDateLabelVisibility:(UITapGestureRecognizer*)sender {
    defaults = [NSUserDefaults standardUserDefaults];
    //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
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
    
    [defaults setObject:preferences forKey:@"simple"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
}

@end
