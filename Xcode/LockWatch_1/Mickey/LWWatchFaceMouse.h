//
//  LWWatchFaceMouse.h
//  LockWatch
//
//  Created by Janik Schmidt on 19.01.16.
//  Copyright © 2016 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"

@interface LWWatchFaceMouse : WatchFaceBase {

    UIImageView* _minuteHand;
    NSString* mouseImagePath;
    
    UIImageView* bgView;
    
    UIImageView *arm01;
    UIImageView *arm02;
    UIImageView *arm02alt;
    
    UIImageView* foot01View;
    UIImageView* foot02View;
    UIImageView* foot03View;
    UIImageView* foot04View;
    UIImageView* foot05View;
    
    NSTimer* footAnimTimer;
    BOOL allowAnimateFoot;
    
    UIImageView* eye01View;
    UIImageView* eye02View;
    UIImageView* eye03View;
    
    NSTimer* eyeAnimTimer;
    BOOL allowAnimateEye;
    
}

- (void)animateFoot;
- (void)animateEyes;

@end
