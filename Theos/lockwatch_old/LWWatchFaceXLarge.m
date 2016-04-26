//
//  LWWatchFaceXLarge.m
//  LockWatch
//
//  Created by Janik Schmidt on 10.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceXLarge.h"

@implementation LWWatchFaceXLarge

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.view = [[[NSBundle mainBundle] loadNibNamed:@"XLarge" owner:self options:nil] objectAtIndex:0];
        [self addSubview:self.view];
        
        _hourLabel = (UILabel*)[self.view viewWithTag:1];
        _minuteLabel = (UILabel*)[self.view viewWithTag:2];
        _secondIndicator = (UILabel*)[self.view viewWithTag:3];
        
        updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
        NSDate* date = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
        float Msecond = roundf([MsecondComp nanosecond]/1000000);

        [self updateTime];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((Msecond/1000) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(triggerSecondIndicatorAnimation) userInfo:nil repeats:YES];
        });
        
        [self makeCustomizeSheet];
    }
    return self;
}


-(void)updateTime {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    NSDateComponents *secondComp = [gregorian components:NSCalendarUnitSecond fromDate:date];
    NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
    
    float Hour = [hourComp hour];
    float Minute = [minuteComp minute];
    float Second = [secondComp second];
    float Msecond = roundf([MsecondComp nanosecond]/1000000);
    
    _hourLabel.text = [NSString stringWithFormat:@"%d", (int)Hour];
    _minuteLabel.text = (Minute < 10) ? [NSString stringWithFormat:@"0%d", (int)Minute] : [NSString stringWithFormat:@"%d", (int)Minute];

}

-(void) deinit {
    [updateTimeTimer invalidate];
    updateTimeTimer = nil;
    
    [animationTimer invalidate];
    animationTimer = nil;
    [_secondIndicator.layer removeAllAnimations];
    _secondIndicator.layer.opacity = 1;
    
    [self hideCustomizeSheet];
    
    _hourLabel.text = @"10";
    _minuteLabel.text = @"09";
}
-(void) reinit {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
    float Msecond = roundf([MsecondComp nanosecond]/1000000);
    
    updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((Msecond/1000) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        animationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(triggerSecondIndicatorAnimation) userInfo:nil repeats:YES];
    });
}

-(void)triggerSecondIndicatorAnimation {
    [_secondIndicator.layer removeAllAnimations];
    
    
    CABasicAnimation* fadeOut = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeOut.fromValue = @1.0;
    fadeOut.toValue = @0.5;
    fadeOut.duration = 0.85;
    _secondIndicator.layer.opacity = 0.5;
    
    CABasicAnimation* fadeIn = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeIn.fromValue = @0.5;
    fadeIn.toValue = @1.0;
    fadeIn.duration = 0.15;
    fadeIn.beginTime = fadeOut.beginTime + fadeOut.duration;
    _secondIndicator.layer.opacity = 1.0;
    
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration = 1.0;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.animations = @[fadeOut, fadeIn];
    
    [_secondIndicator.layer addAnimation:group forKey:@"fade"];
}

-(void)makeCustomizeSheet {
    customizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 490)];
    
    UIView* customize_border = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    customize_border.layer.borderWidth = 3;
    customize_border.layer.borderColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor;
    customize_border.layer.cornerRadius = 12;
    customize_border.layer.position = CGPointMake(312/2, 390/2);
    [customizeView addSubview:customize_border];
    
    colorOptions = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 400, 312, 90)];
    [customizeView addSubview:colorOptions];
    
    NSArray* colorHexArray = [NSArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
    colorOptions.contentSize = CGSizeMake(17*100, 90);
    for (int i=0; i<17; i++) {
        UIView* colorView = [[UIView alloc] initWithFrame:CGRectMake(i*100, 0, 90, 90)];
        colorView.layer.borderWidth = 3.0;
        colorView.layer.borderColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor;
        colorView.layer.cornerRadius = 12;
        colorView.tag = 900+i;
        
        UIView* colorViewInner = [[UIView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
        colorViewInner.backgroundColor = [self colorFromHexString:[colorHexArray objectAtIndex:i]];
        [colorView addSubview:colorViewInner];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeLabelTextColor:)];
        [colorView addGestureRecognizer:tap];
        [colorOptions addSubview:colorView];
    }
    
    customizeView.alpha = 0;
    customizeView.userInteractionEnabled = NO;
    
    [self addSubview:customizeView];
}
-(void)callCustomizeSheet {
    customizeView.userInteractionEnabled = YES;
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         customizeView.alpha = 1;
                         self.transform = CGAffineTransformMakeTranslation(0, -70);
                     } completion:nil];

}
-(void)hideCustomizeSheet {
    customizeView.userInteractionEnabled = NO;
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, 0);
                         customizeView.alpha = 0;
                     } completion:nil];
}

-(void) changeLabelTextColor:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = [NSArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
    
    _hourLabel.textColor = [self colorFromHexString:[colorHexArray objectAtIndex:sender.view.tag-900]];
    _minuteLabel.textColor = [self colorFromHexString:[colorHexArray objectAtIndex:sender.view.tag-900]];
    _secondIndicator.textColor = [self colorFromHexString:[colorHexArray objectAtIndex:sender.view.tag-900]];
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
