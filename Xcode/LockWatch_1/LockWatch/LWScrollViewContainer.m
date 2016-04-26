//
//  LWScrollViewContainer.m
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWScrollViewContainer.h"

@implementation LWScrollViewContainer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (UIView *)hitTest:(CGPoint) point withEvent:(UIEvent *)event
{
    /* this view should have only view only: the scroll view */
    UIView * scrv = [[self subviews] objectAtIndex:0];
    
    UIView *superView = [super hitTest:point withEvent:event];
    if (superView == self)
    {
        return scrv;
    }
    
    return superView;
}

@end
