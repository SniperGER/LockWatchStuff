//
//  WatchScrollBar.m
//  LockWatch
//
//  Created by Janik Schmidt on 26.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "WatchScrollBar.h"

@implementation WatchScrollBar

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.3]];
        [self.layer setCornerRadius:6];
        
        _innerScrollBar = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 8, 71)];
        [_innerScrollBar setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0]];
        [_innerScrollBar.layer setCornerRadius:4];
        [self addSubview:_innerScrollBar];
    }
    
    return self;
}

- (void)setScrollBarHeight:(float)height {
    if (height < 12) {
        height = 12;
    }
    CGRect frame = [_innerScrollBar frame];
    frame.size.height = height;
    _innerScrollBar.frame = frame;
    self.scrollSize = height;
}

- (void)setScrollBarYPos:(float)yPos {
    float scrollRange = 71-self.scrollSize;
    yPos = (MAX(MIN(yPos, 1), 0));
    
    CGRect frame = [_innerScrollBar frame];
    frame.origin.y = (yPos*scrollRange)+2;
    _innerScrollBar.frame = frame;
/*    yPos = MAX(MIN((79-_innerScrollBar.frame.size.height), yPos), 4);
    CGRect frame = [_innerScrollBar frame];
    frame.origin.y = yPos;
    _innerScrollBar.frame = frame;*/
}

@end
