//
//  LWScrollView.h
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWScrollViewContainer.h"

@interface LWScrollView : UIView<UIScrollViewDelegate,UIGestureRecognizerDelegate> {
    int currentIndex;
    CGFloat scrollDelta;
    
    BOOL scaledDown;
    LWScrollViewContainer* scrollContainer;
    UIScrollView* scroll;
    
    UILongPressGestureRecognizer* longPress;
    UITapGestureRecognizer* tap;
    
    NSMutableArray* watchFaceContainer;
    NSMutableDictionary* watchFaceContainerDict;
    NSArray* watchFacePlugins;
    
    UIButton* customizeButton;
}

- (id)initWithFrame:(CGRect)frame withWatchFaces:(NSArray*)watchFaces isScaledDown:(BOOL)startScaledDown;
- (void)updateSizes:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation;
- (void)reoderWatchFaces:(NSArray*)newOrder;
- (void)reRenderWatchFaces;

- (void)scaleDown:(UILongPressGestureRecognizer*)sender;
- (void)scaleUp:(UITapGestureRecognizer*)sender;

@property NSString* bundlePath;
@property NSString* imageBundlePath;

@end
