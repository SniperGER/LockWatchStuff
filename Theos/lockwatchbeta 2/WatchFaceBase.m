//
//  WatchFaceBase.m
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"
#import "WatchHands.h"
#import "CAKeyframeAnimation+AHEasing.h"

#import <UIKit/UIKit.h>

#define offsetScale (220.0/188.0)
#define scaleUpFactor (312.0/188.0)
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

@implementation WatchFaceBase

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        for (UIView *subUIView in self.subviews) {
            [subUIView removeFromSuperview];
        }
        [updateTimeTimer invalidate];
        updateTimeTimer = nil;
        [secondHand.layer removeAnimationForKey:@"secRot"];
        [minuteHand.layer removeAnimationForKey:@"minRot"];
        [hourHand.layer removeAnimationForKey:@"horRot"];
        
        borderView = [[UIView alloc] initWithFrame:CGRectMake(312/2 - (312*offsetScale)/2, 390/2 - (390*offsetScale)/2, 312*offsetScale, 390*offsetScale)];
        [borderView.layer setBorderWidth:10.0];
        [borderView.layer setBorderColor:[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor];
        [borderView.layer setCornerRadius:18.0];
        [borderView.layer setOpacity:0.0];
        
        [self addSubview:borderView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(312/2), -90, 312, 40)];
        _titleLabel.text = titleLabelText;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:24];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.transform = CGAffineTransformMakeScale(scaleUpFactor, scaleUpFactor);
        _titleLabel.layer.opacity = 0;
        [self addSubview:_titleLabel];
        
        [self setBackgroundColor:[UIColor blackColor]];
        
        [self makeCustomizeBorder];
        
        contentIsHidden = YES;
        [self.layer setOpacity:0.0];
        
        handContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
        
        accentColor = @"#FF9500";
        accentColorIndicator = @"#18b5fc";
    }
    
    return self;
}


- (void)renderIndicators:(BOOL)customize {}
- (void)renderClockHands {}

- (void)initWatchFace {
    contentIsHidden = NO;
    [self.layer setOpacity:1.0];
    
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    NSDateComponents *secondComp = [gregorian components:NSCalendarUnitSecond fromDate:date];
    NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
    
    float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    float Minute = [minuteComp minute];
    float Second = [secondComp second];
    float Msecond = roundf([MsecondComp nanosecond]/1000000);
    
    float secondValue = ((Second/60.0) + ((Msecond/1000) / 60));
    float minuteValue = ((Minute/60) + secondValue/60);
    float hourValue = ((Hour/12) + minuteValue/12);
    
    [hourHand setTransform:CGAffineTransformMakeRotation(deg2rad(hourValue*360))];
    [minuteHand setTransform:CGAffineTransformMakeRotation(deg2rad(minuteValue*360))];
    [secondHand setTransform:CGAffineTransformMakeRotation(deg2rad(secondValue*360))];
    
    updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(updateTime) userInfo: nil repeats:YES];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [self hideCustomizeSheet];
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:QuinticEaseOut
                                                           fromValue:0.0
                                                             toValue:1.0];
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    [opacity setDelegate:self];
    
    if (!contentIsHidden) {
        [borderView.layer addAnimation:opacity forKey:@"opacity"];
        [_titleLabel.layer addAnimation:opacity forKey:@"opacity"];
    } else {
        [borderView.layer setOpacity:1.0];
        [_titleLabel.layer setOpacity:1.0];
        [self.layer addAnimation:opacity forKey:@"opacity"];
    }
    
    [CATransaction commit];
    
    
    [updateTimeTimer invalidate];
    updateTimeTimer = nil;
    
    if (wasActiveBefore) {
        [secondHand.layer removeAnimationForKey:@"secRot"];
        [minuteHand.layer removeAnimationForKey:@"minRot"];
        [hourHand.layer removeAnimationForKey:@"horRot"];
        
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             secondHand.transform = CGAffineTransformMakeRotation(deg2rad((30.0/60.0)*360));
                             minuteHand.transform = CGAffineTransformMakeRotation(deg2rad((9.0/60.0+(30.0/60.0)/60.0))*360);
                             hourHand.transform = CGAffineTransformMakeRotation(deg2rad((10.0/12.0+(9.0/60.0)/12.0+((30.0/60.0)/60.0)/12.0))*360);
                         } completion:nil];
        
        CABasicAnimation* border = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        border.fromValue = (id)[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor;
        border.toValue = (id)[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:0.0].CGColor;
        border.duration = 0.2;
        self.layer.borderColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:0.0].CGColor;
        
        CABasicAnimation* corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        corner.fromValue = @11.0f;
        corner.toValue = @0.0f;
        self.layer.cornerRadius = 0.0;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.duration = 0.2;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.animations = @[border, corner];
        [self.layer addAnimation:group forKey:@"animations"];
    } else {
        secondHand.transform = CGAffineTransformMakeRotation(deg2rad((30.0/60.0)*360));
        minuteHand.transform = CGAffineTransformMakeRotation(deg2rad((9.0/60.0+(30.0/60.0)/60.0))*360);
        hourHand.transform = CGAffineTransformMakeRotation(deg2rad((10.0/12.0+(9.0/60.0)/12.0+((30.0/60.0)/60.0)/12.0))*360);
    }
}
- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    if (initAfterAnimation) {
        NSDate* date = [NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
        NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
        NSDateComponents *secondComp = [gregorian components:NSCalendarUnitSecond fromDate:date];
        NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
        
        float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
        float Minute = [minuteComp minute];
        float Second = [secondComp second];
        float Msecond = roundf([MsecondComp nanosecond]/1000000);
        
        float secondValue = ((Second/60.0) + ((Msecond/1000) / 60));
        float minuteValue = ((Minute/60) + secondValue/60);
        float hourValue = ((Hour/12) + minuteValue/12);
        
        [UIView animateWithDuration: 0.3
                              delay: 0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             secondHand.transform = CGAffineTransformMakeRotation(deg2rad(secondValue*360));
                             minuteHand.transform = CGAffineTransformMakeRotation(deg2rad(minuteValue*360));
                             hourHand.transform = CGAffineTransformMakeRotation(deg2rad(hourValue*360));
                         } completion:nil];
    }

    
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.4] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:QuinticEaseOut
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    
    if (initAfterAnimation) {
        [borderView.layer addAnimation:opacity forKey:@"opacity"];
        [_titleLabel.layer addAnimation:opacity forKey:@"opacity"];
        [self initWatchFace];
        contentIsHidden = NO;
    } else {
        [self.layer addAnimation:opacity forKey:@"opacity"];
        contentIsHidden = YES;
    }
    
    [CATransaction commit];
    
}

- (void)makeCustomizeBorder {
    customizeBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    UIImageView *watchCustomizeBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WatchImages.bundle/customize_pages"]];
    [customizeBorder addSubview:watchCustomizeBorder];
    customizeBorder.alpha = 0;
    
    //[self addSubview:customizeBorder];
}
- (void)makeCustomizeSheet {
    
}
- (void)callCustomizeSheet {
    isCustomizing = YES;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.4] forKey:kCATransactionAnimationDuration];
    
    CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                            function:QuinticEaseOut
                                                           fromValue:1.0
                                                             toValue:0.0];
    opacity.fillMode = kCAFillModeForwards;
    opacity.removedOnCompletion = NO;
    
    [opacity setDelegate:self];
    [borderView.layer addAnimation:opacity forKey:@"opacity"];
    [_titleLabel.layer addAnimation:opacity forKey:@"opacity"];
    contentIsHidden = NO;
    
    [CATransaction commit];
    
    [self.layer setOpacity:1.0];
}
- (void)hideCustomizeSheet {
    if (isCustomizing) {
        isCustomizing = NO;
        customizeScrollView.scrollEnabled = NO;
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:kCATransactionAnimationDuration];
        
        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                function:QuinticEaseOut
                                                               fromValue:1.0
                                                                 toValue:0.0];
        [customizeBorder.layer addAnimation:opacity forKey:@"opacity"];
        [customizeScrollView.layer addAnimation:opacity forKey:@"opacity"];
        
        CAAnimation *opacityReverse = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                       function:QuinticEaseOut
                                                                      fromValue:0.0
                                                                        toValue:1.0];
        [hourHand.layer addAnimation:opacityReverse forKey:@"opacity"];
        [minuteHand.layer addAnimation:opacityReverse forKey:@"opacity"];
        [secondHand.layer addAnimation:opacityReverse forKey:@"opacity"];
        
        [CATransaction commit];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hourHand.layer removeAllAnimations];
            [minuteHand.layer removeAllAnimations];
            [secondHand.layer removeAllAnimations];
            customizeBorder.alpha = 0;
            customizeScrollView.alpha = 0;
            hourHand.alpha = 1;
            minuteHand.alpha = 1;
            secondHand.alpha = 1;
        });
    }
}

-(void) updateTime {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    NSDateComponents *secondComp = [gregorian components:NSCalendarUnitSecond fromDate:date];
    NSDateComponents *MsecondComp = [gregorian components:NSCalendarUnitNanosecond fromDate:date];
    
    float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    float Minute = [minuteComp minute];
    float Second = [secondComp second];
    float Msecond = roundf([MsecondComp nanosecond]/1000000);
    
    float secondValue = ((Second/60.0) + ((Msecond/1000) / 60));
    float minuteValue = ((Minute/60) + secondValue/60);
    float hourValue = ((Hour/12) + minuteValue/12);
    
    
    [secondHand.layer removeAnimationForKey:@"secRot"];
    [minuteHand.layer removeAnimationForKey:@"minRot"];
    [hourHand.layer removeAnimationForKey:@"horRot"];
    
    secondHand.transform = CGAffineTransformMakeRotation(deg2rad(secondValue*360));
    minuteHand.transform = CGAffineTransformMakeRotation(deg2rad(minuteValue*360));
    hourHand.transform = CGAffineTransformMakeRotation(deg2rad(hourValue*360));
    
    CABasicAnimation* secondAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    secondAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    secondAnim.duration = 60;
    secondAnim.cumulative = YES;
    secondAnim.repeatCount = 1;
    
    [secondHand.layer addAnimation:secondAnim forKey:@"secRot"];
    
    CABasicAnimation* minuteAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    minuteAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    minuteAnim.duration = 60*60;
    minuteAnim.cumulative = YES;
    minuteAnim.repeatCount = 1;
    
    [minuteHand.layer addAnimation:minuteAnim forKey:@"minRot"];
    
    CABasicAnimation* hourAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    hourAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    hourAnim.duration = 60 * 60 * 12;
    hourAnim.cumulative = YES;
    hourAnim.repeatCount = 1;
    
    [hourHand.layer addAnimation:hourAnim forKey:@"horRot"];
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)setTitleLabelText:(NSString*)text {
    _titleLabel.text = text;
}

@end