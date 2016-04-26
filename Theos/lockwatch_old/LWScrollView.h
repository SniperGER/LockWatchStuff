//
//  LWScrollView.h
//  LockWatch
//
//  Created by Janik Schmidt on 06.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WatchButton.h"

@interface LWScrollView : UIScrollView

@property (retain) NSMutableArray* watchFaces;
@property int currentIndex;
@property BOOL scaledDown;
@property (retain) WatchButton* customizeButton;


-(id)initWithFrame:(CGRect)frame withWatchFaces:(NSArray*)watchFaceTypes withWatchFaceNames:(NSArray*)watchFaceNames;

-(void)scaleDown:(UILongPressGestureRecognizer*)sender;

@end
