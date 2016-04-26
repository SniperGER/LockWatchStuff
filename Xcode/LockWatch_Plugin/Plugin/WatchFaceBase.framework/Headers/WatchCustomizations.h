//
//  WatchCustomizations.h
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WatchCustomizations : NSObject

- (UIScrollView*)simpleDetailCustomize:(CGRect)frame withCurrentDetailState:(int)detailState withTarget:(id)target withTapAction:(SEL)tapAction;
- (UIView*)simpleAccentColorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction;

- (UIView*)colorIndicatorCustomize:(CGRect)frame withAccentColor:(NSString*)accentColor withTarget:(id)target withTapAction:(SEL)tapAction;

- (UIView*)generalDateCustomize:(CGRect)frame withTarget:(id)target withTapAction:(SEL)tapAction withUserDefaults:(NSUserDefaults*)defaults withPrefKey:(NSString*)prefKey;
- (UIView*)generalCustomizeBorder:(CGRect)frame;

@end
