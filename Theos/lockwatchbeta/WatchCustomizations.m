//
//  WatchCustomizations.m
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchCustomizations.h"
#import "ColorSelector.h"

@implementation WatchCustomizations

- (UIScrollView*)simpleDetailCustomize:(CGRect)frame withCurrentDetailState:(int)detailState withTarget:(id)target withTapAction:(SEL)tapAction {
    UIScrollView* detailOptions = [[UIScrollView alloc] initWithFrame:frame];
    [detailOptions setContentSize:CGSizeMake(50, 370)];
    
    NSArray *previewImages = [NSArray arrayWithObjects:@"", @"WatchImages.bundle/simple_detail_1", @"WatchImages.bundle/simple_detail_2", @"WatchImages.bundle/simple_detail_3", nil];
    for (int i=0; i<4; i++) {
        UIView* detailOption = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, 50, 50)];
        if (i == detailState) {
            [detailOption.layer setBorderWidth:3.0];
        }
        [detailOption setBackgroundColor:[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0]];
        [detailOption.layer setBorderColor:[UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor];
        [detailOption.layer setCornerRadius:6];
        [detailOption setTag:(800+i)];
        
        UIImageView* preview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[previewImages objectAtIndex:i]]];
        [preview setFrame:CGRectMake(6, 6, 38, 38)];
        [preview setBackgroundColor:[UIColor blackColor]];
        [detailOption addSubview:preview];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapAction];
        [detailOption addGestureRecognizer:tap];
        [detailOptions addSubview:detailOption];
    }
    
    return detailOptions;
}
- (UIView*)simpleAccentColorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction {
    UIView* customizeSecondArmContainer = [[UIView alloc] initWithFrame:frame];
    
    UIView* customizeSecondArm = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58, 222)];
    [customizeSecondArm.layer setPosition:CGPointMake((312/2), 65+(390/2))];
    [customizeSecondArm.layer setCornerRadius:29.0];
    [customizeSecondArm.layer setBorderWidth:3.0];
    [customizeSecondArm.layer setBorderColor:[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor];

    ColorSelector* colorSelector = [[ColorSelector alloc] initWithFrame:CGRectMake(10, 10, 50, 370) withSelectedColor:accentColor];
    
    [customizeSecondArmContainer addSubview:customizeSecondArm];
    [customizeSecondArmContainer addSubview:colorSelector];
    for (int i=0; i<[[colorSelector subviews] count]; i++) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapAction];
        [[[colorSelector subviews] objectAtIndex:i] addGestureRecognizer:tap];
    }
    
    return customizeSecondArmContainer;
}

- (UIView*)colorIndicatorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction {
    UIView* colorCustomizeContainer = [[UIView alloc] initWithFrame:frame];
    
    ColorSelector* colorSelector = [[ColorSelector alloc] initWithFrame:CGRectMake(10, 10, 50, 370) withSelectedColor:accentColor];
    
    [colorCustomizeContainer addSubview:colorSelector];
    for (int i=0; i<[[colorSelector subviews] count]; i++) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapAction];
        [[[colorSelector subviews] objectAtIndex:i] addGestureRecognizer:tap];
    }
    
    return colorCustomizeContainer;
}

- (UIView*)generalDateCustomize:(CGRect)frame withTarget:(id)target withTapAction:(SEL)tapAction withUserDefaults:(NSDictionary*)defaults withPrefKey:(NSString*)prefKey {
    UIView* customizeDateContainer = [[UIView alloc] initWithFrame:frame];
    
    UIView* customizeDate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [customizeDate setCenter:CGPointMake((312/2)+65, 390/2)];
    [customizeDate.layer setCornerRadius:8.0];
    [customizeDate.layer setBorderWidth:3.0];
    [customizeDate.layer setBorderColor:[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor];
    [customizeDateContainer addSubview:customizeDate];
    
    UIScrollView* dateOptions = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, 50, 370)];
    for (int i=0; i<2; i++) {
        UIView* dateView = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, 50, 50)];
        //dateView.layer.borderWidth = 3.0;
        dateView.layer.borderColor = [UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0].CGColor;
        dateView.backgroundColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0];
        dateView.layer.cornerRadius = 6;
        dateView.tag = 950+i;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:tapAction];
        [dateView addGestureRecognizer:tap];
        
        [dateOptions addSubview:dateView];
        
        if (i == 1) {
            UILabel* dateLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            dateLabel2.text = @"31";
            dateLabel2.textAlignment = NSTextAlignmentCenter;
            dateLabel2.textColor = [self colorFromHexString:@"#ff9500"];
            dateLabel2.center = CGPointMake(50/2, 50/2);
            dateLabel2.font = [UIFont systemFontOfSize:32];
            [dateView addSubview:dateLabel2];
        }
        
        if (i == [[defaults objectForKey:prefKey] intValue]) {
            dateView.layer.borderWidth = 3.0;
        }
    }
    [customizeDateContainer addSubview:dateOptions];
    
    return customizeDateContainer;
}
- (UIView*)generalCustomizeBorder:(CGRect)frame {
    UIView* customizeBorder = [[UIView alloc] initWithFrame:frame];
    customizeBorder.layer.borderWidth = 3.0;
    customizeBorder.layer.borderColor = [UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor;
    customizeBorder.layer.cornerRadius = 12.0;
    customizeBorder.alpha = 0;
    
    return customizeBorder;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


@end
