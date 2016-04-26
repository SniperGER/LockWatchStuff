//
//  LWWatchFaceIndicators.m
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFaceIndicators.h"

#define deg2rad(angle) ((angle) / 180.0 * M_PI)
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#define ANTIALIASING_ENABLED [[[[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath] objectForKey:@"enableAntialiasing"] boolValue]

@implementation LWWatchFaceIndicators

- (UIView*)simpleIndicators:(int)detailState isCustomizing:(BOOL)customize {
    UIView* indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    UIView* hourIndicators = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    
    switch (detailState) {
        case 1:
            for (int i=0; i<60; i++) {
                NSDictionary* values = [self getRadForAngle:6.0 withRadius:149.5 withIndex:i];
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                
                [secondIndicator setBackgroundColor:[self colorFromHexString:@"#7C7C7C"]];
                [secondIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
                [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*6))];
                [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
                [indicatorContainer addSubview:secondIndicator];
            }
            break;
        case 2:
            for (int i=0; i<120; i++) {
                NSDictionary* values = [self getRadForAngle:3.0 withRadius:149.5 withIndex:i];
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                
                [secondIndicator setBackgroundColor:[self colorFromHexString:@"#4B4B4B"]];
                [secondIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
                [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*3))];
                [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
                [indicatorContainer addSubview:secondIndicator];
                
                if ((i+1) % 10 == 0) {
                    [secondIndicator setBackgroundColor:[self colorFromHexString:@"#959595"]];
                }
            }
            break;
        case 3:
            for (int i=0; i<240; i++) {
                NSDictionary* values = [self getRadForAngle:1.5 withRadius:149.5 withIndex:i];
                UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 11)];
                
                [secondIndicator setBackgroundColor:[self colorFromHexString:@"#4B4B4B"]];
                [secondIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
                [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*1.5))];
                [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
                [indicatorContainer addSubview:secondIndicator];
                
                if ((i+1) % 20 == 0) {
                    [secondIndicator setBackgroundColor:[self colorFromHexString:@"#959595"]];
                }
            }
            break;
        default:
            break;
    }
    
    if (detailState >= 2) {
        // Hour indicators
        hourIndicators = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
        for (int i=0; i<12; i++) {
            NSDictionary* values = [self getRadForAngle:30 withRadius:114.5 withIndex:i];
            UIView* hourIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 39)];
            
            [hourIndicator setBackgroundColor:[self colorFromHexString:@"#B2B2B2"]];
            [hourIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
            [hourIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*30))];
            [hourIndicator.layer setCornerRadius:4.0];
            [hourIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
            [hourIndicators addSubview:hourIndicator];
        }
        [indicatorContainer addSubview:hourIndicators];
        
        if (detailState == 3) {
            for (int i=0; i<12; i++) {
                UILabel* hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
                [hourLabel setFont:[UIFont systemFontOfSize:16]];
                [hourLabel setTextColor:[UIColor colorWithWhite:.64 alpha:1]];
                [hourLabel setTextAlignment:NSTextAlignmentCenter];
                
                switch (i) {
                    case 0:
                        [hourLabel setText:@"5"];
                        break;
                    case 1:
                        [hourLabel setText:@"10"];
                        break;
                    case 3:
                        [hourLabel setText:@"20"];
                        break;
                    case 4:
                        [hourLabel setText:@"25"];
                        break;
                    case 6:
                        [hourLabel setText:@"35"];
                        break;
                    case 7:
                        [hourLabel setText:@"40"];
                        break;
                    case 9:
                        [hourLabel setText:@"50"];
                        break;
                    case 10:
                        [hourLabel setText:@"55"];
                        break;
                    default:
                        break;
                }
                if (i == 0 || i == 1 || i == 3 || i == 4 || i == 6 || i == 7 || i == 9 || i == 10) {
                    NSDictionary* values = [self getRadForAngle:30 withRadius:167.0 withIndex:i];
                    [hourLabel setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
                    
                    [indicatorContainer addSubview:hourLabel];
                }
            }
        }
    }
    
    return indicatorContainer;
}
- (UIView*)colorIndicators:(NSString*)accentColorIndicator {
    UIView* indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    
    for (int i=0; i<60; i++) {
        NSDictionary* values = [self getRadForAngle:6.0 withRadius:152.0 withIndex:i];
        
        UIView* minuteIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
        minuteIndicator.backgroundColor = [self colorFromHexString:accentColorIndicator];
        minuteIndicator.center = CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue]);
        minuteIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*6));
        minuteIndicator.layer.cornerRadius = 3.0;
        minuteIndicator.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
        
        
        if ((i+1) % 5 == 0) {
            NSDictionary* valuesHour = [self getRadForAngle:30.0 withRadius:134.0 withIndex:i];
            
            minuteIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 42)];
            minuteIndicator.backgroundColor = [self colorFromHexString:accentColorIndicator];
            minuteIndicator.center = CGPointMake((312/2) + [valuesHour[@"sinValue"] floatValue], (390/2) - [valuesHour[@"cosValue"] floatValue]);
            minuteIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*30));
            minuteIndicator.layer.cornerRadius = 3.0;
            minuteIndicator.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
        }
        
        [indicatorContainer addSubview:minuteIndicator];
    }
    
    return indicatorContainer;
}

- (UIView*)chronoIndicators {
    UIView* indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    
    for (int i=0; i<240; i++) {
        NSDictionary* values = [self getRadForAngle:1.5 withRadius:151.5 withIndex:i];
        UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 7)];
        [secondIndicator setBackgroundColor:[self colorFromHexString:@"#4b4b4b"]];
        [secondIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
        [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*1.5))];
        [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
        
        if ((i+1) % 4 == 0) {
            NSDictionary* values = [self getRadForAngle:1.5 withRadius:148.5 withIndex:i];
            secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 13)];
            [secondIndicator setBackgroundColor:[self colorFromHexString:@"#4b4b4b"]];
            [secondIndicator setCenter:CGPointMake((312/2) + [values[@"sinValue"] floatValue], (390/2) - [values[@"cosValue"] floatValue])];
            [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*1.5))];
            [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
            [indicatorContainer addSubview:secondIndicator];
        }
        
        if ((i+1) % 20 == 0) {
            [secondIndicator setBackgroundColor:[self colorFromHexString:@"#b9b9b9"]];
            
            NSDictionary* valuesLabel = [self getRadForAngle:1.5 withRadius:125.0 withIndex:i];
            
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [label setCenter:CGPointMake((312/2) + [valuesLabel[@"sinValue"] floatValue], (390/2) - [valuesLabel[@"cosValue"] floatValue])];
            [label setFont:[UIFont systemFontOfSize:26]];
            [label setText:[NSString stringWithFormat:@"%d", (i+1)/20]];
            [label setTextColor:[UIColor whiteColor]];
            [label setTextAlignment:NSTextAlignmentCenter];
            
            [indicatorContainer addSubview:label];
        }
        
        [indicatorContainer addSubview:secondIndicator];
    }
    
    [self make30secondIndicator:indicatorContainer];
    [self make60secondIndicator:indicatorContainer];
    
    return indicatorContainer;
}
- (void)make30secondIndicator:(UIView*)indicatorContainer {
    UIView* secondIndicator30Chrono = [[UIView alloc] initWithFrame:CGRectMake(312/2-88/2, 390/2 - 88/2 - 57, 88, 88)];
    
    for (int i=0; i<60; i++) {
        NSDictionary* values = [self getRadForAngle:6.0 withRadius:41.5 withIndex:i];
        UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 5)];
        
        [secondIndicator setBackgroundColor:[self colorFromHexString:@"#696969"]];
        [secondIndicator setCenter:CGPointMake(44 + [values[@"sinValue"] floatValue], 44 - [values[@"cosValue"] floatValue])];
        [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*6))];
        [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
        
        if ((i+1) % 2 == 0) {
            NSDictionary* values = [self getRadForAngle:6 withRadius:40.0 withIndex:i];
            secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 8)];
            [secondIndicator setBackgroundColor:[self colorFromHexString:@"#696969"]];
            [secondIndicator setCenter:CGPointMake(44 + [values[@"sinValue"] floatValue], 44 - [values[@"cosValue"] floatValue])];
            [secondIndicator setTransform:CGAffineTransformMakeRotation(deg2rad((i+1)*6))];
            [secondIndicator.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
        }
        if ((i+1) % 10 == 0) {
            [secondIndicator setBackgroundColor:[self colorFromHexString:@"#B9B9B9"]];
            
            NSDictionary* valuesLabel = [self getRadForAngle:6 withRadius:25.0 withIndex:i];
            UILabel* secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            
            [secondLabel setCenter:CGPointMake(44 + [valuesLabel[@"sinValue"] floatValue], 44 - [valuesLabel[@"cosValue"] floatValue])];
            [secondLabel.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
            [secondLabel setTextColor:[UIColor whiteColor]];
            
            int labelValue = (int)((i+1)/2);
            [secondLabel setText:(labelValue < 10) ? [NSString stringWithFormat:@"0%d", labelValue] : [NSString stringWithFormat:@"%d", labelValue]];
            [secondLabel setFont:[UIFont systemFontOfSize:14]];
            [secondLabel setTextAlignment:NSTextAlignmentCenter];
            [secondIndicator30Chrono addSubview:secondLabel];
        }
        
        [secondIndicator30Chrono addSubview:secondIndicator];
    }
    
    [indicatorContainer addSubview:secondIndicator30Chrono];
}
- (void)make60secondIndicator:(UIView*)indicatorContainer {
    UIView* secondIndicator60Chrono = [[UIView alloc] initWithFrame:CGRectMake(312/2-88/2, 390/2 - 88/2 + 57, 88, 88)];
    
    for (int i=0; i<60; i++) {
        float sinValue = sin(M_PI*((i+1)*6.0/180.0))*41.5;
        float cosValue = cos(M_PI*((i+1)*6.0/180.0))*41.5;
        UIView* secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 5)];
        secondIndicator.backgroundColor = [self colorFromHexString:@"#696969"];
        secondIndicator.center = CGPointMake(44+sinValue, 44-cosValue);
        secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*6));
        secondIndicator.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
        
        if ((i+1) % 5 == 0) {
            sinValue = sin(M_PI*((i+1)*6.0/180.0))*40.0;
            cosValue = cos(M_PI*((i+1)*6.0/180.0))*40.0;
            secondIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 8)];
            secondIndicator.backgroundColor = [self colorFromHexString:@"#b9b9b9"];
            secondIndicator.center = CGPointMake(44+sinValue, 44-cosValue);
            secondIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*6));
            secondIndicator.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
            
            if ((i+1) % 15 == 0) {
                float sinValueLabel = sin(M_PI*((i+1)*6.0/180.0))*25.0;
                float cosValueLabel = cos(M_PI*((i+1)*6.0/180.0))*25.0;
                UILabel* secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
                
                secondLabel.center = CGPointMake(44+sinValueLabel, 44-cosValueLabel);
                secondLabel.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
                secondLabel.textColor = [UIColor whiteColor];
                secondLabel.text = [NSString stringWithFormat:@"%d", (i+1)];
                secondLabel.font = [UIFont systemFontOfSize:14];
                secondLabel.textAlignment = NSTextAlignmentCenter;
                [secondIndicator60Chrono addSubview:secondLabel];
            }
        }
        
        [secondIndicator60Chrono addSubview:secondIndicator];
    }
    
    [indicatorContainer addSubview:secondIndicator60Chrono];
}

- (NSDictionary*)getRadForAngle:(float)angle withRadius:(float)radius withIndex:(int)index {
    NSMutableDictionary* values = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    float sinValue = sin(M_PI*((index+1)*angle/180.0))*radius;
    float cosValue = cos(M_PI*((index+1)*angle/180.0))*radius;
    
    [values setObject:[NSNumber numberWithFloat:sinValue] forKey:@"sinValue"];
    [values setObject:[NSNumber numberWithFloat:cosValue] forKey:@"cosValue"];
    
    return values;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
