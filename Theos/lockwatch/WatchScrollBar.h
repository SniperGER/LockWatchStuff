//
//  WatchScrollBar.h
//  LockWatch
//
//  Created by Janik Schmidt on 26.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WatchScrollBar : UIView

- (void)setScrollBarHeight:(float)height;
- (void)setScrollBarYPos:(float)yPos;

@property UIView* innerScrollBar;
@property float scrollSize;

@end
