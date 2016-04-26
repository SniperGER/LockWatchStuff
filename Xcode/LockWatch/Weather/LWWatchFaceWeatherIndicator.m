//
//  LWWatchFaceWeatherIndicator.m
//  LockWatch
//
//  Created by Janik Schmidt on 28.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFaceWeatherIndicator.h"
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

@implementation LWWatchFaceWeatherIndicator
@synthesize deinit;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    float Minute = [minuteComp minute];
    
    if (deinit) {
        Hour = 10;
        Minute = 9;
    }
    
    CGRect allRect = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    CGContextSetRGBStrokeColor(context, 1.0,1.0,1.0,0.25);
    CGContextSetLineWidth(context, 8);
    
    // Draw progress
    CGPoint center = CGPointMake(allRect.size.width / 2, 308 / 2);
    CGFloat radius = 94;
    CGFloat startAngle = -90 + (Hour*30) + ((Minute/60)*30);
    CGFloat endAngle = -90 + ((Hour-1)*30);
    CGContextAddArc(context, center.x, center.y, radius, deg2rad(startAngle), deg2rad(endAngle), 0);
    CGContextStrokePath(context);
}

@end
