//
//  WatchSelector.h
//  LockWatch
//
//  Created by Janik Schmidt on 28.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWWatchFace.h"
#import "WatchLabel.h"
#import "WatchScrollBar.h"

@interface WatchSelector : UIScrollView<UIScrollViewDelegate>

- (id)initWithFrame:(CGRect)frame type:(NSString*)type items:(NSArray*)items action:(NSString*)action;

@property NSMutableArray* items;
@property NSString* type; // 'detail', 'color', 'misc'
@property SEL action;
@property int selectedIndex;
@property WatchLabel* nameLabel;
@property WatchScrollBar* scrollBar;
@property (nonatomic, weak) id selectionTarget;

@end
