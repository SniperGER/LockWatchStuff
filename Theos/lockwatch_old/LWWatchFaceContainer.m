//
//  LWWatchFaceContainer.m
//  LockWatch
//
//  Created by Janik Schmidt on 06.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceContainer.h"
#import "LWWatchFaceSimple.h"
#import "LWWatchFaceColor.h"
#import "LWWatchFaceXLarge.h"

#define scaleUpFactor (312.0/188.0)

@implementation LWWatchFaceContainer

-(id)initWithFrame:(CGRect)frame withWatchFace:(NSString*)watchFaceType withAccentColor:(NSString*)accentColor withTitle:(NSString*)title {
    self = [super initWithFrame:frame];
    if (self) {
        self.watchFace = [[NSMutableArray alloc] initWithCapacity:1];
        self.layer.borderWidth = 10.0;

        if ([watchFaceType isEqualToString:@"simple"]) {
	        
            LWWatchFaceSimple* simple = [[LWWatchFaceSimple alloc] initWithFrame:CGRectMake(self.frame.size.width/2-312/2, self.frame.size.height/2-390/2,312,490)];
            [self.watchFace addObject:simple];
            [self addSubview:[self.watchFace objectAtIndex:0]];
            
        } else if ([watchFaceType isEqualToString:@"chrono"]) {
	        
            LWWatchFaceSimple* simple = [[LWWatchFaceSimple alloc] initWithFrame:CGRectMake(self.frame.size.width/2-312/2, self.frame.size.height/2-390/2,312,490)];
            [self.watchFace addObject:simple];
            [self addSubview:[self.watchFace objectAtIndex:0]];
            
        } else if ([watchFaceType isEqualToString:@"weather"]) {
	        
            LWWatchFaceSimple* simple = [[LWWatchFaceSimple alloc] initWithFrame:CGRectMake(self.frame.size.width/2-312/2, self.frame.size.height/2-390/2,312,490)];
            [self.watchFace addObject:simple];
            [self addSubview:[self.watchFace objectAtIndex:0]];
            
        } else if ([watchFaceType isEqualToString:@"xlarge"]) {
	        
            LWWatchFaceXLarge* xlarge = [[LWWatchFaceXLarge alloc] initWithFrame:CGRectMake(self.frame.size.width/2-312/2, self.frame.size.height/2-390/2,312,490)];
            [self.watchFace addObject:xlarge];
            [self addSubview:[self.watchFace objectAtIndex:0]];
            
        } else if ([watchFaceType isEqualToString:@"color"]) {
	        
            LWWatchFaceColor* color = [[LWWatchFaceColor alloc] initWithFrame:CGRectMake(self.frame.size.width/2-312/2, self.frame.size.height/2-390/2,312,490)];
            [self.watchFace addObject:color];
            [self addSubview:[self.watchFace objectAtIndex:0]];
        }
        
        if (title) {
            self.layer.masksToBounds = NO;
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2)-(312/2), -60, 312, 40)];
            _titleLabel.text = title;
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.font = [UIFont systemFontOfSize:24];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            _titleLabel.transform = CGAffineTransformMakeScale(scaleUpFactor, scaleUpFactor);
            _titleLabel.alpha = 0;
            [self addSubview:_titleLabel];
        }
    }
    return self;
}

-(void) scaleUp:(int)isAbleToReInit {
    if ([self.watchFace objectAtIndex:0]) {
        NSString* className = NSStringFromClass([[self.watchFace objectAtIndex:0] class]);
        if ([className isEqualToString:@"LWWatchFaceSimple"] && isAbleToReInit==1) {
            LWWatchFaceSimple* simple = [self.watchFace objectAtIndex:0];
            [simple reinit];
        } else if ([className isEqualToString:@"LWWatchFaceColor"] && isAbleToReInit==1) {
            LWWatchFaceColor* color = [self.watchFace objectAtIndex:0];
            [color reinit];
        } else if ([className isEqualToString:@"LWWatchFaceXLarge"] && isAbleToReInit==1) {
            LWWatchFaceXLarge* xlarge = [self.watchFace objectAtIndex:0];
            [xlarge reinit];
        }
        
        [[self.watchFace objectAtIndex:0] setUserInteractionEnabled:YES];
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             _titleLabel.alpha = 0.0;
                         } completion:^(BOOL finished) {}];
        CABasicAnimation* border = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        border.fromValue = (id)[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor;
        border.toValue = (id)[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:0.0].CGColor;
        self.layer.borderColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:0.0].CGColor;
        CABasicAnimation* corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        corner.fromValue = @18.0;
        corner.toValue = @0.0;
        self.layer.cornerRadius = 0.0;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.duration = 0.2;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        group.animations = @[border, corner];
        [self.layer addAnimation:group forKey:@"animations_reverse"];
    }
}
-(void) scaleDown {
    if ([self.watchFace objectAtIndex:0]) {
        NSString* className = NSStringFromClass([[self.watchFace objectAtIndex:0] class]);
        if ([className isEqualToString:@"LWWatchFaceSimple"]) {
            LWWatchFaceSimple* simple = [self.watchFace objectAtIndex:0];
            [simple deinit];
        } else if ([className isEqualToString:@"LWWatchFaceColor"]) {
            LWWatchFaceColor* color = [self.watchFace objectAtIndex:0];
            [color deinit];
        }else if ([className isEqualToString:@"LWWatchFaceXLarge"]) {
            LWWatchFaceXLarge* xlarge = [self.watchFace objectAtIndex:0];
            [xlarge deinit];
        }
        
        [[self.watchFace objectAtIndex:0] setUserInteractionEnabled:NO];
        [UIView animateWithDuration: 0.2
                              delay: 0
                            options: UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _titleLabel.alpha = 1.0;
                         } completion:^(BOOL finished) {}];
        
        CABasicAnimation* border = [CABasicAnimation animationWithKeyPath:@"borderColor"];
        border.fromValue = (id)[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:0.0].CGColor;
        border.toValue = (id)[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor;
        self.layer.borderColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor;
        CABasicAnimation* corner = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
        corner.fromValue = @0.0f;
        corner.toValue = @18.0f;
        self.layer.cornerRadius = 18.0;
        
        CAAnimationGroup* group = [CAAnimationGroup animation];
        group.duration = 0.2;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        group.animations = @[border, corner];
        [self.layer addAnimation:group forKey:@"animations"];
    }
}

-(void) customize {
    if ([self.watchFace objectAtIndex:0]) {
        NSString* className = NSStringFromClass([[self.watchFace objectAtIndex:0] class]);
        if ([className isEqualToString:@"LWWatchFaceSimple"]) {
            LWWatchFaceSimple* simple = [self.watchFace objectAtIndex:0];
            [simple callCustomizeSheet];
        }
        if ([className isEqualToString:@"LWWatchFaceColor"]) {
            LWWatchFaceColor* color = [self.watchFace objectAtIndex:0];
            [color callCustomizeSheet];
        }
        if ([className isEqualToString:@"LWWatchFaceXLarge"]) {
            LWWatchFaceXLarge* xlarge = [self.watchFace objectAtIndex:0];
            [xlarge callCustomizeSheet];
        }
    }
}

@end
