//
//  LWWatchFaceMouse.m
//  LockWatch
//
//  Created by Janik Schmidt on 19.01.16.
//  Copyright © 2016 Janik Schmidt (Sniper_GER). All rights reserved.
//

// Mickey Mouse Watch Face assets by the guy who recreated
// this Watch Face for Android Wear. Or whereever he got them from.

#import "LWWatchFaceMouse.h"
#import <QuartzCore/QuartzCore.h>

@implementation LWWatchFaceMouse

- (id)initWithFrame:(CGRect)frame {
    self.customizable = false;
    
    self = [super initWithFrame:frame];
    
    if (self) {
        #if TARGET_IPHONE_SIMULATOR
        mouseImagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/PlugIns/Mickey.watchface/%@"];
        #else
        mouseImagePath = [self bundlePath];
        #endif
        
        bgView = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"bg_320"]];
        [bgView setFrame:CGRectMake(0, 39, 312, 312)];
        [self addSubview:bgView];
        
        CABasicAnimation* bgAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        bgAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
        bgAnim.duration = 40;
        bgAnim.cumulative = YES;
        bgAnim.repeatCount = INFINITY;
        [bgView.layer addAnimation:bgAnim forKey:@"bgAnim"];
        
        [self renderIndicators:NO];
        
        UIImageView* bodyView = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"body_320"]];
        [bodyView setFrame:CGRectMake(66, 180.5, 180, 157)];
        [self addSubview:bodyView];
        
        
        
        foot01View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"shoe05_320"]];
        [foot01View setFrame:CGRectMake(169, 260, 69, 78)];
        [self addSubview:foot01View];
        
        foot02View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"shoe04_320"]];
        [foot02View setFrame:CGRectMake(169, 264, 71, 72)];
        [self addSubview:foot02View];
        
        foot03View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"shoe03_320"]];
        [foot03View setFrame:CGRectMake(160, 279, 86, 57)];
        [self addSubview:foot03View];
        
        foot04View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"shoe02_320"]];
        [foot04View setFrame:CGRectMake(156, 288, 94, 48)];
        [self addSubview:foot04View];
        
        foot05View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"shoe01_320"]];
        [foot05View setFrame:CGRectMake(151, 296, 91, 50)];
        [self addSubview:foot05View];
        
        [foot01View setAlpha:1];
        [foot02View setAlpha:0];
        [foot03View setAlpha:0];
        [foot04View setAlpha:0];
        [foot05View setAlpha:0];
        
        
        hourHand = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"hand_hour_320"]];
        hourHand.layer.anchorPoint = CGPointMake(0.5, 01);
        [hourHand setFrame:CGRectMake(106, 82, 50, 113)];
        [hourHand setTransform:CGAffineTransformMakeRotation(-200)];
        [self addSubview:hourHand];
        
        
        UIImageView* headView = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"head_320"]];
        [headView setFrame:CGRectMake(82, 67, 148, 128)];
        [self addSubview:headView];
        
        
        eye01View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"eyes01_320"]];
        [eye01View setFrame:CGRectMake(108, 124, 23, 31)];
        [self addSubview:eye01View];
        
        eye02View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"eyes02_320"]];
        [eye02View setFrame:CGRectMake(109, 131, 22, 15)];
        [self addSubview:eye02View];
        
        eye03View = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"eyes03_320"]];
        [eye03View setFrame:CGRectMake(108, 136, 24, 6)];
        [self addSubview:eye03View];
        
        [eye01View setAlpha:1];
        [eye02View setAlpha:0];
        [eye03View setAlpha:0];
        
        _minuteHand = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"hand_minute_320_1"]];
        _minuteHand.layer.anchorPoint = CGPointMake(0.7, 1);
        [_minuteHand setFrame:CGRectMake(128, 65, 41, 130)];
        [_minuteHand setTransform:CGAffineTransformMakeRotation(42)];
        minuteHand = _minuteHand;
        [self addSubview:minuteHand];
    }

    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
    allowAnimateFoot = YES;
    allowAnimateEye = YES;
    [self animateFoot];
    footAnimTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                     target:self
                                                   selector:@selector(animateFoot)
                                                   userInfo:nil
                                                    repeats:YES];
    
    eyeAnimTimer = [NSTimer scheduledTimerWithTimeInterval:10.0f
                                                     target:self
                                                   selector:@selector(animateEyes)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    [super reInitWatchFace:initAfterAnimation];
    
    if (initAfterAnimation) {
        CABasicAnimation* bgAnim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        bgAnim.byValue = [NSNumber numberWithFloat: M_PI * 2.0];
        bgAnim.duration = 40;
        bgAnim.cumulative = YES;
        bgAnim.repeatCount = INFINITY;
        [bgView.layer addAnimation:bgAnim forKey:@"bgAnim"];
    }
}

- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    
    allowAnimateFoot = NO;
    [foot01View setAlpha:1];
    [foot02View setAlpha:0];
    [foot03View setAlpha:0];
    [foot04View setAlpha:0];
    [foot05View setAlpha:0];
    [footAnimTimer invalidate];
    
    allowAnimateEye = NO;
    [eye01View setAlpha:1];
    [eye02View setAlpha:0];
    [eye03View setAlpha:0];
    [eyeAnimTimer invalidate];
    
    [bgView.layer removeAllAnimations];
    [bgView.layer setTransform:CATransform3DMakeRotation(90.0 / 180.0 * M_PI, 0.0, 0.0, 1.0)];
    
    [_minuteHand setImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"hand_minute_320_1"]];
}

- (void)updateTime {
    [super updateTime];
    
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    float Minute = [minuteComp minute];
    
    if (Minute <30 && Minute >= 0) {
        [_minuteHand setImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"hand_minute_320_1"]];
    } else if (Minute <= 59 && Minute >= 30) {
        [_minuteHand setImage:[self getImageFromImageBundle:@"Mouse" withImageName:@"hand_minute_320_alt_2"]];
    }
}

- (void)renderIndicators:(BOOL)customize {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (!customize) {
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }
    
    for (int i=0; i<12; i++) {
        if (i==4 || i==5 || i==6) {
            
        } else {
            NSDictionary* valuesLabel = [self getRadForAngle:30 withRadius:145.0 withIndex:i];
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [label setCenter:CGPointMake((312/2) + [valuesLabel[@"sinValue"] floatValue], (390/2) - [valuesLabel[@"cosValue"] floatValue])];
            [label setFont:[UIFont boldSystemFontOfSize:26]];
            [label setText:[NSString stringWithFormat:@"%d", (i+1)]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            
            [indicatorContainer addSubview:label];
        }
    }
    
    [self addSubview:indicatorContainer];
}

- (void)animateFoot {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:1];
            [foot02View setAlpha:0];
            [foot03View setAlpha:0];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((2*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:1];
            [foot03View setAlpha:0];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((3*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:0];
            [foot03View setAlpha:1];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((4*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:0];
            [foot03View setAlpha:0];
            [foot04View setAlpha:1];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((5*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:0];
            [foot03View setAlpha:0];
            [foot04View setAlpha:0];
            [foot05View setAlpha:1];
        }
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((5*0.05)+0.35) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:0];
            [foot03View setAlpha:0];
            [foot04View setAlpha:1];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((6*0.05)+0.35) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:0];
            [foot03View setAlpha:1];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((7*0.05)+0.35) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:0];
            [foot02View setAlpha:1];
            [foot03View setAlpha:0];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((8*0.05)+0.35) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [foot01View setAlpha:1];
            [foot02View setAlpha:0];
            [foot03View setAlpha:0];
            [foot04View setAlpha:0];
            [foot05View setAlpha:0];
        }
    });
}

- (void)animateEyes {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((0*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [eye01View setAlpha:0];
            [eye02View setAlpha:1];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((1*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [eye02View setAlpha:0];
            [eye03View setAlpha:1];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((2*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [eye03View setAlpha:0];
            [eye02View setAlpha:1];
        }
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((3*0.05) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (allowAnimateEye) {
            [eye02View setAlpha:0];
            [eye01View setAlpha:1];
        }
    });

}

- (NSDictionary*)getRadForAngle:(float)angle withRadius:(float)radius withIndex:(int)index {
    NSMutableDictionary* values = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    float sinValue = sin(M_PI*((index+1)*angle/180.0))*radius;
    float cosValue = cos(M_PI*((index+1)*angle/180.0))*radius;
    
    [values setObject:[NSNumber numberWithFloat:sinValue] forKey:@"sinValue"];
    [values setObject:[NSNumber numberWithFloat:cosValue] forKey:@"cosValue"];
    
    return values;
}

@end
