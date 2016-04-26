//
//  WatchIndicators.h
//  LockWatch
//
//  Created by Janik Schmidt on 30.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WatchIndicators : NSObject

- (UIView*)simpleIndicators:(int)detailState isCustomizing:(BOOL)customize;
- (UIView*)colorIndicators:(NSString*)accentColorIndicators;
- (UIView*)chronoIndicators;

- (NSDictionary*)getRadForAngle:(float)angle withRadius:(float)radius withIndex:(int)index;

@end
