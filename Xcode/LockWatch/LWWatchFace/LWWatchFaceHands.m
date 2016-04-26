//
//  LWWatchFaceHands.m
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFaceHands.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#define ANTIALIASING_ENABLED [[[[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath] objectForKey:@"enableAntialiasing"] boolValue]

@implementation LWWatchFaceHands

+ (UIView*)hourHand:(BOOL)chronoStyle {
    UIView* hourHandBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [hourHandBase setBackgroundColor:[UIColor whiteColor]];
    [hourHandBase.layer setCornerRadius:7.0];
    
    UIView* hourHandConnector = [[UIView alloc] initWithFrame:CGRectMake(5, -21+7.5, 4, 21.5)];
    [hourHandConnector setBackgroundColor:[UIColor whiteColor]];
    [hourHandBase addSubview:hourHandConnector];
    
    UIView* hourHandMain = [[UIView alloc] initWithFrame:CGRectMake(1, -62-21+10, 12, 62)];
    [hourHandMain.layer setCornerRadius:6];
    [hourHandMain setBackgroundColor:[UIColor whiteColor]];
    if (chronoStyle) {
        UIView* hourHandMainInside = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 8, 58)];
        [hourHandMainInside.layer setCornerRadius:4.0];
        [hourHandMainInside setBackgroundColor:[UIColor blackColor]];
        [hourHandMain addSubview:hourHandMainInside];
    }
    [hourHandBase addSubview:hourHandMain];
    
    [hourHandBase.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    [hourHandBase.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
    
    return hourHandBase;
}

+ (UIView*)minuteHand:(BOOL)chronoStyle {
    UIView* minuteHandBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
    [minuteHandBase setBackgroundColor:[UIColor whiteColor]];
    [minuteHandBase.layer setCornerRadius:7.0];
    
    UIView* minuteHandConnector = [[UIView alloc] initWithFrame:CGRectMake(5, -21+7.5, 4, 21.5)];
    [minuteHandConnector setBackgroundColor:[UIColor whiteColor]];
    [minuteHandBase addSubview:minuteHandConnector];
    
    UIView* minuteHandMain = [[UIView alloc] initWithFrame:CGRectMake(1, -124-21+10, 12, 124)];
    [minuteHandMain.layer setCornerRadius:6];
    [minuteHandMain setBackgroundColor:[UIColor whiteColor]];
    if (chronoStyle) {
        UIView* minuteHandMainInside = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 8, 120)];
        [minuteHandMainInside.layer setCornerRadius:4.0];
        [minuteHandMainInside setBackgroundColor:[UIColor blackColor]];
        [minuteHandMain addSubview:minuteHandMainInside];
    }
    [minuteHandBase addSubview:minuteHandMain];
    
    [minuteHandBase.layer setAnchorPoint:CGPointMake(0.5, 0.5)];
    
    [minuteHandBase.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
    
    return minuteHandBase;
}

+ (UIView*)secondHand:(NSString*)accentColor {
    UIView* secondCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    secondCircle.backgroundColor = [self colorFromHexString:accentColor];
    secondCircle.center = CGPointMake(0.5, 0.5);
    secondCircle.layer.cornerRadius = 5.0;
    secondCircle.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
    
    UIView* secondArm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 180)];
    secondArm.backgroundColor = [self colorFromHexString:accentColor];
    secondArm.center = CGPointMake(5, 5-65);
    secondArm.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
    [secondCircle addSubview:secondArm];
    
    UIView* secondHandInnerCircle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 4, 4)];
    secondHandInnerCircle.backgroundColor = [UIColor blackColor];
    secondHandInnerCircle.center = CGPointMake(5, 5);
    secondHandInnerCircle.layer.cornerRadius = 2.0;
    secondHandInnerCircle.layer.allowsEdgeAntialiasing = ANTIALIASING_ENABLED;
    [secondCircle addSubview:secondHandInnerCircle];
    
    [secondCircle.layer setAllowsEdgeAntialiasing:ANTIALIASING_ENABLED];
    
    return secondCircle;
}

+ (UIView*)secondHandChrono {
    UIView* secondIndicatorChrono = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    secondIndicatorChrono.center = CGPointMake(44, 44);
    secondIndicatorChrono.backgroundColor = [UIColor whiteColor];
    secondIndicatorChrono.layer.cornerRadius = 3.0;
    
    UIView* secondIndicatorArm = [[UIView alloc] initWithFrame:CGRectMake(2, -41, 2, 44)];
    secondIndicatorArm.backgroundColor = [UIColor whiteColor];
    [secondIndicatorChrono addSubview:secondIndicatorArm];
    
    return secondIndicatorChrono;
}

+ (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
