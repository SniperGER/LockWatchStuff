//
//  LWWatchFaceSimple2.m
//  LockWatch
//
//  Created by Janik Schmidt on 09.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceSimple.h"
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

int detailState = 2;
float scrollViewDelta = 0;

UIScrollView* detailOptions;
UIScrollView* colorOptions;

@implementation LWWatchFaceSimple

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //// RENDER SECOND AND HOUR INDICATORS ////
        [self renderIndicators];
        //// //// //// ////
        
        //// RENDER WATCH HANDS ////
        _accentColor = @"#ff9500";
        handContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
        
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
        
        [self hourHand:Hour minutes:Minute seconds:Second Mseconds:Msecond];
        [self minuteHand:Minute seconds:Second Mseconds:Msecond];
        [self secondHand:Second Mseconds:Msecond];
        
        [self addSubview:handContainer];
        //// //// //// ////
        
        //// SET TIMER TO UPDATE TIME ON WATCH ////
        updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        //// //// //// ////
        
        //// CREATE CUSTOMIZE SHEET ////
        [self makeCustomizeSheet];
        //// //// //// ////
    }
    return self;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


-(void) renderIndicators {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    switch (detailState) {
        case 1:
            for (int i=0; i<60; i++) {
                float sinValue = sin(M_PI*((i+1)*6.0/180.0))*149.5;
                float cosValue = cos(M_PI*((i+1)*6.0/180.0))*149.5;
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                secondIndicator.backgroundColor = [self colorFromHexString:@"#7c7c7c"];
                secondIndicator.center = CGPointMake((312/2)+sinValue, (390/2)-cosValue);
                secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*6));
                secondIndicator.layer.allowsEdgeAntialiasing = YES;
                [indicatorContainer addSubview:secondIndicator];
            }
            break;
        case 2:
            for (int i=0; i<120; i++) {
                float sinValue = sin(M_PI*((i+1)*3.0/180.0))*149.5;
                float cosValue = cos(M_PI*((i+1)*3.0/180.0))*149.5;
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                secondIndicator.backgroundColor = [self colorFromHexString:@"#4b4b4b"];
                secondIndicator.center = CGPointMake((312/2)+sinValue, (390/2)-cosValue);
                secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*3));
                secondIndicator.layer.allowsEdgeAntialiasing = YES;
                [indicatorContainer addSubview:secondIndicator];
            }
            break;
        case 3:
            for (int i=0; i<240; i++) {
                float sinValue = sin(M_PI*((i+1)*1.5/180.0))*149.5;
                float cosValue = cos(M_PI*((i+1)*1.5/180.0))*149.5;
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                secondIndicator.backgroundColor = [self colorFromHexString:@"#4b4b4b"];
                secondIndicator.center = CGPointMake((312/2)+sinValue, (390/2)-cosValue);
                secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*1.5));
                secondIndicator.layer.allowsEdgeAntialiasing = YES;
                [indicatorContainer addSubview:secondIndicator];
            }
            break;
        default:
            break;
    }
    if (detailState >= 2) {
        // Highlighted Second indicators
        for (int i=0; i<12; i++) {
            float sinValue = sin(M_PI*((i+1)*30.0/180.0))*149.5;
            float cosValue = cos(M_PI*((i+1)*30.0/180.0))*149.5;
            UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
            secondIndicator.backgroundColor = [self colorFromHexString:@"#959595"];
            secondIndicator.center = CGPointMake((312/2)+sinValue, (390/2)-cosValue);
            secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*30));
            secondIndicator.layer.allowsEdgeAntialiasing = YES;
            [indicatorContainer addSubview:secondIndicator];
        }
        
        // Hour indicators
        for (int i=0; i<12; i++) {
            float sinValue = sin(M_PI*((i+1)*30.0/180.0))*114.5;
            float cosValue = cos(M_PI*((i+1)*30.0/180.0))*114.5;
            UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 39)];
            secondIndicator.backgroundColor = [self colorFromHexString:@"#b2b2b2"];
            secondIndicator.center = CGPointMake((312/2)+sinValue, (390/2)-cosValue);
            secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*30));
            secondIndicator.layer.cornerRadius = 4.0;
            [indicatorContainer addSubview:secondIndicator];
        }
        
        if (detailState == 3) {
            
        }
    }
    [self insertSubview:indicatorContainer atIndex:0];
}

-(void) secondHand:(float)seconds Mseconds:(float)Mseconds {
    [[secondCircle subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    secondCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    secondCircle.backgroundColor = [self colorFromHexString:_accentColor];
    secondCircle.center = CGPointMake(312/2, 390/2);
    secondCircle.layer.cornerRadius = 5.0;
    secondCircle.layer.allowsEdgeAntialiasing = YES;
    
    UIView* secondArm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 180)];
    secondArm.backgroundColor = [self colorFromHexString:_accentColor];
    secondArm.center = CGPointMake(5, 5-65);
    secondArm.layer.allowsEdgeAntialiasing = YES;
    [secondCircle addSubview:secondArm];
    
    
    UIView* secondHandInnerCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    secondHandInnerCircle.backgroundColor = [UIColor blackColor];
    secondHandInnerCircle.center = CGPointMake(5, 5);
    secondHandInnerCircle.layer.cornerRadius = 2.0;
    secondHandInnerCircle.layer.allowsEdgeAntialiasing = YES;
    [secondCircle addSubview:secondHandInnerCircle];
    
    float secondValue = ((seconds/60.0) + ((Mseconds/1000) / 60));
    secondCircle.transform = CGAffineTransformMakeRotation(deg2rad(secondValue*360));
    
    CABasicAnimation* secondAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    secondAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    secondAnim.duration = 60;
    secondAnim.cumulative = YES;
    secondAnim.repeatCount = 1;
    
    [secondCircle.layer addAnimation:secondAnim forKey:@"secRot"];
    
    [handContainer addSubview:secondCircle];
}
-(void) minuteHand:(float)minutes seconds:(float)seconds Mseconds:(float)Mseconds {
    minuteHand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hand_minute"]];
    minuteHand.layer.position = CGPointMake(312/2, 390/2);
    minuteHand.layer.anchorPoint = CGPointMake(0.5,144.0/151.0);
    minuteHand.layer.allowsEdgeAntialiasing = YES;
    
    float secondValue = ((seconds/60.0) + ((Mseconds/1000) / 60));
    float minuteValue = ((minutes/60) + secondValue/60);
    minuteHand.transform = CGAffineTransformMakeRotation(deg2rad(minuteValue*360));
    
    CABasicAnimation* minuteAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    minuteAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    minuteAnim.duration = 60*60;
    minuteAnim.cumulative = YES;
    minuteAnim.repeatCount = 1;
    
    [minuteHand.layer addAnimation:minuteAnim forKey:@"minRot"];
    
    [handContainer addSubview:minuteHand];
}
-(void) hourHand:(float)hours minutes:(float)minutes seconds:(float)seconds Mseconds:(float)Mseconds {
    hourHand = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hand_hour"]];
    hourHand.layer.position = CGPointMake(312/2, 390/2);
    hourHand.layer.anchorPoint = CGPointMake(0.5,78.0/85.0);
    hourHand.layer.allowsEdgeAntialiasing = YES;
    
    float secondValue = ((seconds/60.0) + ((Mseconds/1000) / 60));
    float minuteValue = ((minutes/60) + secondValue/60);
    float hourValue = ((hours/12) + minuteValue/12);
    hourHand.transform = CGAffineTransformMakeRotation(deg2rad(hourValue*360));
    
    CABasicAnimation* hourAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    hourAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    hourAnim.duration = 60 * 60 * 12;
    hourAnim.cumulative = YES;
    hourAnim.repeatCount = 1;
    
    [hourHand.layer addAnimation:hourAnim forKey:@"horRot"];
    
    [handContainer addSubview:hourHand];
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
    

    [secondCircle.layer removeAnimationForKey:@"secRot"];
    [minuteHand.layer removeAnimationForKey:@"minRot"];
    [hourHand.layer removeAnimationForKey:@"horRot"];
    
    secondCircle.transform = CGAffineTransformMakeRotation(deg2rad(secondValue*360));
    minuteHand.transform = CGAffineTransformMakeRotation(deg2rad(minuteValue*360));
    hourHand.transform = CGAffineTransformMakeRotation(deg2rad(hourValue*360));
    
    CABasicAnimation* secondAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    secondAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
    secondAnim.duration = 60;
    secondAnim.cumulative = YES;
    secondAnim.repeatCount = 1;
    
    [secondCircle.layer addAnimation:secondAnim forKey:@"secRot"];
    
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

-(void) deinit {
    [updateTimeTimer invalidate];
    updateTimeTimer = nil;
    
    [self hideCustomizeSheet];
    
    [secondCircle.layer removeAnimationForKey:@"secRot"];
    [minuteHand.layer removeAnimationForKey:@"minRot"];
    [hourHand.layer removeAnimationForKey:@"horRot"];
    
    [UIView animateWithDuration: 0.3
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         secondCircle.transform = CGAffineTransformMakeRotation(deg2rad((30.0/60.0)*360));
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
}
-(void) reinit {
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
                         secondCircle.transform = CGAffineTransformMakeRotation(deg2rad(secondValue*360));
                         minuteHand.transform = CGAffineTransformMakeRotation(deg2rad(minuteValue*360));
                         hourHand.transform = CGAffineTransformMakeRotation(deg2rad(hourValue*360));
                     } completion:nil];
    
    updateTimeTimer = [NSTimer scheduledTimerWithTimeInterval: 0.2 target: self selector:@selector(updateTime) userInfo: nil repeats:YES];
}

-(void) makeCustomizeSheet {
    customizeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 490)];
    
    UIScrollView* customizeScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 312, 490)];
    customizeScrollView.contentSize = CGSizeMake(312*2, 490);
    customizeScrollView.pagingEnabled = YES;
    customizeScrollView.showsHorizontalScrollIndicator = NO;
    customizeScrollView.delegate = self;
    //customizeScrollView.layer.masksToBounds = NO;
    
    
    //// Page 1
    UIImageView* customize_border = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"customize_pages"]];
    customize_border.layer.position = CGPointMake(312/2, 390/2);
    [customizeScrollView addSubview:customize_border];
    
    UILabel* customizeDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 80, 26)];
    customizeDetailLabel.layer.position = CGPointMake(312/2, 390-20);
    customizeDetailLabel.layer.cornerRadius = 5.0;
    customizeDetailLabel.backgroundColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0];
    customizeDetailLabel.text = @"DETAIL";
    customizeDetailLabel.textAlignment = NSTextAlignmentCenter;
    customizeDetailLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    customizeDetailLabel.layer.masksToBounds = YES;
    [customizeScrollView addSubview:customizeDetailLabel];
    
    detailOptions = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 400, 312, 90)];
    detailOptions.contentSize = CGSizeMake(400, 90);

    [customizeScrollView addSubview:detailOptions];
    
    //// Page 1 - Detail Options
    NSArray *previewImages = [NSArray arrayWithObjects:@"", @"simple_detail_1", @"simple_detail_2", @"simple_detail_3", nil];
    for (int i=0; i<4; i++) {
        UIView* detailOption = [[UIView alloc] initWithFrame:CGRectMake(i*100, 0, 90, 90)];
        detailOption.layer.borderWidth = 3.0;
        detailOption.layer.borderColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor;
        detailOption.layer.cornerRadius = 12;
        detailOption.tag = 800+i;
        
        UIImageView* preview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[previewImages objectAtIndex:i]]];
        preview.frame = CGRectMake(15, 15, 60, 60);
        [detailOption addSubview:preview];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reRenderIndicators:)];
        [detailOption addGestureRecognizer:tap];
        [detailOptions addSubview:detailOption];
    }
    
    //// Page 2
    UIView* customizeSecondArm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 222)];
    customizeSecondArm.layer.position = CGPointMake(312+(312/2), 65+(390/2));
    customizeSecondArm.layer.cornerRadius = 29.0;
    customizeSecondArm.layer.borderWidth = 3.0;
    customizeSecondArm.layer.borderColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor;
    [customizeScrollView addSubview:customizeSecondArm];
    
    colorOptions = [[UIScrollView alloc] initWithFrame:CGRectMake(312, 400, 312, 90)];
    [customizeScrollView addSubview:colorOptions];
    
    //// Page 2 - Color options
    
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
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reRenderSecondHand:)];
        [colorView addGestureRecognizer:tap];
        [colorOptions addSubview:colorView];
    }
    
    //// Page 3
    UIView* customizeDate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    customizeDate.layer.position = CGPointMake(312*2+232, 197);
    customizeDate.layer.cornerRadius = 8.0;
    customizeDate.layer.borderWidth = 3.0;
    customizeDate.layer.borderColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor;
    [customizeScrollView addSubview:customizeDate];
    
    [customizeView addSubview:customizeScrollView];
    
    customizeScrollViewPager = [[UIPageControl alloc] init];
    customizeScrollViewPager.layer.position = CGPointMake(312/2, 3);
    customizeScrollViewPager.numberOfPages = 3;
    customizeScrollViewPager.currentPage = 0;
    customizeScrollViewPager.transform = CGAffineTransformMakeScale(0.85, 0.85);
    [customizeView addSubview:customizeScrollViewPager];
    
    customizeView.alpha = 0;
    customizeView.userInteractionEnabled = NO;
    
    [self addSubview:customizeView];
}
-(void) callCustomizeSheet {
    customizeView.userInteractionEnabled = YES;
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         customizeView.alpha = 1;
                         self.transform = CGAffineTransformMakeTranslation(0, -70);
                         switch (customizeScrollViewPager.currentPage) {
                             case 0:
                                 handContainer.alpha = 0;
                                 break;
                             case 1:
                                 indicatorContainer.alpha = 0;
                                 hourHand.alpha = 0;
                                 minuteHand.alpha = 0;
                                 break;
                             case 2:
                                 handContainer.alpha = 0;
                                 indicatorContainer.alpha = 0;
                                 break;
                             default:
                                 break;
                         }
                     } completion:^(BOOL finished) {
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    
}
-(void) hideCustomizeSheet {
    customizeView.userInteractionEnabled = NO;
    [UIView animateWithDuration: 0.1
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.transform = CGAffineTransformMakeTranslation(0, 0);
                         customizeView.alpha = 0;
                         indicatorContainer.alpha = 1;
                         handContainer.alpha = 1;
                         hourHand.alpha = 1;
                         minuteHand.alpha = 1;
                     } completion:nil];
}

-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = (scrollView.contentOffset.x + (0.5f * 312.0)) / 312.0;
    customizeScrollViewPager.currentPage = page;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    float pageProgress = ((customizeScrollViewPager.currentPage * 312) - scrollView.contentOffset.x)/312;
    if (customizeScrollViewPager.currentPage == 0) {
        if (pageProgress > 0) {
            indicatorContainer.alpha = 1-pageProgress;
            detailOptions.alpha = 1-pageProgress;
            handContainer.alpha = 0;
            colorOptions.alpha = 0;
        } else if (pageProgress < 0) {
            indicatorContainer.alpha = 1+pageProgress;
            detailOptions.alpha = 1+pageProgress;
            handContainer.alpha = -pageProgress;
            colorOptions.alpha = -pageProgress;
        } else {
            indicatorContainer.alpha = 1;
            detailOptions.alpha = 1;
            handContainer.alpha = 0;
            colorOptions.alpha = 0;
        }
    }
    
    if (customizeScrollViewPager.currentPage == 1) {
        if (pageProgress > 0) {
            handContainer.alpha = 1-pageProgress;
            colorOptions.alpha = 1-pageProgress;
            indicatorContainer.alpha = pageProgress;
            detailOptions.alpha = pageProgress;
        } else if (pageProgress < 0) {
            handContainer.alpha = 1+pageProgress;
            colorOptions.alpha = 1+pageProgress;
            indicatorContainer.alpha = 0;
            detailOptions.alpha = 0;
        } else {
            handContainer.alpha = 1;
            colorOptions.alpha = 1;
            indicatorContainer.alpha = 0;
            detailOptions.alpha = 0;
        }
    }
    
    if (customizeScrollViewPager.currentPage == 2) {
        if (pageProgress > 0) {
            handContainer.alpha = pageProgress;
        } else if (pageProgress < 0) {
            handContainer.alpha = 0;
        } else {
            handContainer.alpha = 0;
        }
    }
    scrollViewDelta = scrollView.contentOffset.x;
}

-(void) reRenderIndicators:(UITapGestureRecognizer*)sender {
    switch (sender.view.tag) {
        case 800:
            detailState = 0;
            break;
        case 801:
            detailState = 1;
            break;
        case 802:
            detailState = 2;
            break;
        case 803:
            detailState = 3;
            break;
        default:
            break;
    }
    [self renderIndicators];
}
-(void) reRenderSecondHand:(UITapGestureRecognizer*)sender {
    NSArray* colorNameArray = [NSArray arrayWithObjects:@"WHITE", @"RED", @"ORANGE", @"LIGHT ORANGE", @"YELLOW", @"GREEN", @"TURQUOISE", @"LIGHT BLUE", @"BLUE", @"MIDNIGHT BLUE", @"PURPLE", @"LAVENDER", @"PINK", @"VINTAGE ROSE", @"WALNUT", @"STONE", @"ANTIQUE WHITE", nil];
    NSArray* colorHexArray = [NSArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
    _accentColor = [colorHexArray objectAtIndex:sender.view.tag-900];
    [self secondHand:30.0 Mseconds:0];
    [secondCircle.layer removeAnimationForKey:@"secRot"];
}

@end
