//
//  LWScrollView.h
//  LockWatch
//
//  Created by Janik Schmidt on 29.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWScrollViewContainer.h"

@interface LWScrollView : UIButton<UIScrollViewDelegate,UIGestureRecognizerDelegate> {
    int currentIndex;
    CGFloat scrollDelta;
    
    LWScrollViewContainer* scrollContainer;
    UIScrollView* scroll;
    
    UILongPressGestureRecognizer* longPress;
    UITapGestureRecognizer* tap;
    
    NSMutableArray* watchFaceContainer;
    NSMutableDictionary* watchFaceContainerDict;
    NSArray* watchFacePlugins;
    
    UIButton* customizeButton;
}

@property (strong,nonatomic) UIButton* customizationButton;
@property (strong,nonatomic) UIButton* longPressButton;
@property BOOL scaledDown;

- (id)initWithFrame:(CGRect)frame withWatchFaces:(NSArray*)watchFaces isScaledDown:(BOOL)startScaledDown;
- (void)updateSizes:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation;
- (void)reoderWatchFaces:(NSArray*)newOrder;
- (void)reRenderWatchFaces;

- (void)scaleDown:(UILongPressGestureRecognizer*)sender;
- (void)scaleUp:(UITapGestureRecognizer*)sender;

@end
