//
//  LWWatchFaceColorSelector.h
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWatchFaceColorSelector : UIScrollView

@property NSMutableArray* colorSets;
@property NSMutableArray* colorHex;

- (id)initWithFrame:(CGRect)frame withSelectedColor:(NSString*)accentColorSelected withTarget:(id)target andAction:(SEL)tapAction;

@property id target;
@property SEL tapAction;

@end
