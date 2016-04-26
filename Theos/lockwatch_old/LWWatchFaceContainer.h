//
//  LWWatchFaceContainer.h
//  LockWatch
//
//  Created by Janik Schmidt on 06.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LWWatchFaceContainer : UIView

@property NSMutableArray* watchFace;
@property UILabel* titleLabel;

-(id)initWithFrame:(CGRect)frame withWatchFace:(NSString*)watchFaceType withAccentColor:(NSString*)accentColor withTitle:(NSString*)title;
-(void)scaleUp:(int)isAbleToReInit;
-(void)scaleDown;
-(void)customize;

@end
