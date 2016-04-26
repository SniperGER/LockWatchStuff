//
//  ExperimentalColorSelector.h
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWWatchFace.h"
#import "WatchLabel.h"
#import "WatchScrollBar.h"

@interface ExperimentalColorSelector : UIScrollView<UIScrollViewDelegate> {
    int currentColorIndex;
}

- (id)initWithFrame:(CGRect)frame andSelectedColor:(NSString*)currentAccentColor;

@property WatchLabel* colorNameLabel;

@property NSMutableArray* colorSets;
@property NSMutableArray* colorHex;

@property (nonatomic, weak) id selectionTarget;
@property (nonatomic, assign) SEL selectionAction;

@property WatchScrollBar* scrollBar;

@end
