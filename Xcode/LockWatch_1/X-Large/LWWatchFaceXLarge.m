//
//  LWWatchFaceXLarge.m
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceXLarge.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceXLarge
NSUserDefaults* defaults;

+ (void)load {
    //NSLog(@"\"X-Large\" loaded");
}

- (id)initWithFrame:(CGRect)frame {
    self.customizable = true;
    
    self = [super initWithFrame:frame];
    
    if (self) {
        NSLog(@"%@", [self bundlePath]);
        preferences = [[NSMutableDictionary alloc] init];
        //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"xlarge"]) {
            [defaults setObject:preferences forKey:@"xlarge"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"xlarge"]];
        }
        
        if ([preferences objectForKey:@"AccentColor"]) {
            accentColor = [preferences objectForKey:@"AccentColor"];
        } else {
            [preferences setObject:@"#18B5FC" forKey:@"AccentColor"];
            accentColor = @"#18B5FC";
        }
        
        [defaults setObject:preferences forKey:@"xlarge"];
        //[defaults writeToFile:PreferencesFilePath atomically:YES];
        
        [self renderIndicators:NO];
        [self renderClockHands];
        
        
        labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
        
        hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 42, 275, 170)];
        [hourLabel setFont:[UIFont systemFontOfSize:225]];
        hourLabel.text = @"10";
        hourLabel.textColor = [self colorFromHexString:accentColor];
        [hourLabel sizeToFit];
        [hourLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [labelView addSubview:hourLabel];
        
        minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 220, 275, 170)];
        [minuteLabel setFont:[UIFont systemFontOfSize:225]];
        minuteLabel.text = @"09";
        minuteLabel.textColor = [self colorFromHexString:accentColor];
        [minuteLabel sizeToFit];
        [minuteLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [labelView addSubview:minuteLabel];
        
        secondIndicator = [[UILabel alloc] initWithFrame:CGRectMake(-10, 175, 50, 215)];
        [secondIndicator setFont:[UIFont systemFontOfSize:225]];
        secondIndicator.text = @":";
        secondIndicator.textColor = [self colorFromHexString:accentColor];
        [secondIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [labelView addSubview:secondIndicator];
        [self addSubview:labelView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:hourLabel
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:hourLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:42]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:hourLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:-178]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:minuteLabel
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:minuteLabel
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:minuteLabel
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:220]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:secondIndicator
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:minuteLabel
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1
                                                          constant:3]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:secondIndicator
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:secondIndicator
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:labelView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:175]];
        [self makeCustomizeSheet];
    }
    
    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
    
    [self updateTime];
    //updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(updateTime) userInfo: nil repeats:YES];
}

- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    [updateTimeTimer invalidate];
    updateTimeTimer = nil;
    
    hourLabel.text = @"10";
    minuteLabel.text = @"09";
}

- (void)makeCustomizeSheet {
    [customizeBorder removeFromSuperview];
    [[customizeBorder subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    customizeBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    customizeBorder.layer.borderWidth = 3.0;
    customizeBorder.layer.borderColor = [UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor;
    customizeBorder.layer.cornerRadius = 12.0;
    customizeBorder.alpha = 0;
    [self addSubview:customizeBorder];
    
    colorSelector = [[ColorSelector alloc] initWithFrame:CGRectMake(10, self.frame.origin.y+10, 50, 370) withSelectedColor:accentColor];
    colorSelector.alpha = 0;
    
    [self addSubview:colorSelector];
    for (int i=0; i<[[colorSelector subviews] count]; i++) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setLabelColor:)];
        [[[colorSelector subviews] objectAtIndex:i] addGestureRecognizer:tap];
    }
    
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         colorSelector.alpha = 1;
                         customizeBorder.alpha = 1;
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                         secondHand.alpha = 0;
                     } completion:^(BOOL finished) {
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        labelView.transform = CGAffineTransformMakeScale(0.935, 0.935); //first part of animation
        labelView.transform = CGAffineTransformMakeScale(1.0, 1.0); //second part of animation
    } completion:nil];
}
-(void) hideCustomizeSheet {
    [super hideCustomizeSheet];
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        colorSelector.alpha = 0;
        customizeBorder.alpha = 0;
        indicatorContainer.alpha = 1;
        indicatorContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
        hourHand.alpha = 1;
        minuteHand.alpha = 1;
        
    } completion:nil];
    [labelView.layer removeAllAnimations];
}

- (void)updateTime {
    
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    float Hour = [hourComp hour];
    float Minute = [minuteComp minute];
    
    hourLabel.text = [NSString stringWithFormat:@"%d", (int)Hour];
    minuteLabel.text = (Minute < 10) ? [NSString stringWithFormat:@"0%d", (int)Minute] : [NSString stringWithFormat:@"%d", (int)Minute];
}

- (void)setLabelColor:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = colorSelector.colorHexArray;
    accentColor = [colorHexArray objectAtIndex:sender.view.tag-900];
    
    //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    defaults = [NSUserDefaults standardUserDefaults];
    [preferences setObject:accentColor forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"xlarge"];
    //[defaults writeToFile:PreferencesFilePath atomically:YES];
    
    hourLabel.textColor = [self colorFromHexString:accentColor];
    minuteLabel.textColor = [self colorFromHexString:accentColor];
    secondIndicator.textColor = [self colorFromHexString:accentColor];
    
    for (int i=0; i<[colorSelector subviews].count; i++) {
        [[[[colorSelector subviews] objectAtIndex:i] layer]setBorderWidth:0];
    }
    sender.view.layer.borderWidth = 3;
}

@end
