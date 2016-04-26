//
//  WatchButton.m
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//


#import "WatchButton.h"

@implementation WatchButton

- (id)initWithFrame:(CGRect)frame withTitle:(NSString*)title
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        
        [self setBackgroundColor: [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
        [self setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.34901961 green:0.34901961 blue:0.34901961 alpha:1]] forState:UIControlStateHighlighted];
        [self setTitle:title forState:UIControlStateNormal];
        [self.titleLabel setFont:[UIFont systemFontOfSize:20]];
        [[self layer] setCornerRadius:8.0];
        [[self layer] setMasksToBounds:YES];
    }
    return self;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:8.0];
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end