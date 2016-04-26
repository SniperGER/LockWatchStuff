//
//  WatchLabel.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "WatchLabel.h"

@implementation WatchLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setContent:)
                                                     name:[self notificationChannel]
                                                   object:nil];
        [self setFont:[UIFont boldSystemFontOfSize:20]];
        [self setBackgroundColor:[UIColor colorWithRed:(8.0/255.0) green:(217.0/255.0) blue:(102.0/255.0) alpha:1.0]];
        [self setTextAlignment:NSTextAlignmentCenter];
        [self.layer setCornerRadius:8.0];
        [self setClipsToBounds:YES];
    }
    
    return self;
}

- (void)setContent:(NSDictionary*)userInfo {
    //NSLog(@"[WatchLabel] %@", [[notification userInfo] objectForKey:@"scrollViewPage"]);
    //NSDictionary* userInfo = [notification userInfo];
    
    int index = [[userInfo objectForKey:@"scrollViewPage"] intValue];
    NSString* colorName = [[userInfo objectForKey:@"colorSets"] objectAtIndex:index][@"name"];
    self.text = [colorName uppercaseString];
    
    [self sizeToFit];
    CGRect _frame = self.frame;
    _frame.size.width += 15;
    _frame.size.height += 5;
    _frame.origin.x = (312.0/2) - (_frame.size.width/2);
    self.frame = _frame;
}
- (void)setText:(NSString *)text {
    [super setText:text];
    [self sizeToFit];
    CGRect _frame = self.frame;
    _frame.size.width += 15;
    _frame.size.height += 5;
    _frame.origin.x = (312.0/2) - (_frame.size.width/2);
    self.frame = _frame;
}

@end
