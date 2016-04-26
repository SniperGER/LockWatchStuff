//
//  ColorSelector.m
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "ColorSelector.h"

@implementation ColorSelector

- (id)init {
    self = [super init];
    if (self) {
        _colorHexArray = [NSArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSelectedColor:(NSString*)accentColorSelected {
    self = [super initWithFrame:frame];
    if (self) {
        _colorHexArray = [NSArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
        [self setContentSize:CGSizeMake(50, [_colorHexArray count]*55-5)];
        for (int i=0; i<17; i++) {
            UIView* colorView = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, 50, 50)];
            //[colorView.layer setBorderWidth:3.0];
            //[colorView.layer setBorderColor:[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor];
            [colorView.layer setBorderColor:[UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor];
            if ([(NSString*)[_colorHexArray objectAtIndex:i] isEqualToString:[accentColorSelected uppercaseString]]) {
                [colorView.layer setBorderWidth:3];
            }
            [colorView.layer setCornerRadius:6.0];
            colorView.backgroundColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0];
            [colorView setTag:900+i];
            
            UIView* colorViewInner = [[UIView alloc] initWithFrame:CGRectMake(6, 6, 38, 38)];
            [colorViewInner setBackgroundColor:[self colorFromHexString:[_colorHexArray objectAtIndex:i]]];
            [colorView addSubview:colorViewInner];
            
            [self addSubview:colorView];
        }
        [self setShowsVerticalScrollIndicator:NO];
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

@end
