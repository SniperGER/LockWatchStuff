//
//  LWWatchFaceIndicators.h
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LWWatchFaceIndicators : NSObject

- (UIView*)simpleIndicators:(int)detailState isCustomizing:(BOOL)customize;
- (UIView*)colorIndicators:(NSString*)accentColorIndicators;
- (UIView*)chronoIndicators;

- (NSDictionary*)getRadForAngle:(float)angle withRadius:(float)radius withIndex:(int)index;

@end
