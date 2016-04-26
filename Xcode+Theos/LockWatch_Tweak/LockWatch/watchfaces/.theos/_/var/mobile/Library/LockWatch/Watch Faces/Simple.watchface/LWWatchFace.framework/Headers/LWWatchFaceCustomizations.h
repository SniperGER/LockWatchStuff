//
//  LWWatchFaceCustomizations.h
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LWWatchFaceColorSelector.h"
#import "ExperimentalColorSelector.h"
#import "WatchSelector.h"

@interface LWWatchFaceCustomizations : NSObject

- (UIScrollView*)simpleDetailCustomize:(CGRect)frame withCurrentDetailState:(int)detailState withTarget:(id)target withTapAction:(SEL)tapAction;
- (UIView*)experimentalDetailCustomize:(CGRect)frame withCurrentDetailState:(int)detailState withTarget:(id)target withTapAction:(SEL)tapAction;
- (UIView*)simpleAccentColorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction;
- (UIView*)experimentalAccentColorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target andTapAction:(SEL)tapAction;

- (UIView*)colorIndicatorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction;

- (UIView*)generalDateCustomize:(CGRect)frame withTarget:(id)target withTapAction:(SEL)tapAction withUserDefaults:(NSDictionary*)defaults withPrefKey:(NSString*)prefKey;
- (UIView*)generalCustomizeBorder:(CGRect)frame;

@end
