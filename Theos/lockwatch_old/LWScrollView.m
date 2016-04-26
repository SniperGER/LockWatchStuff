//
//  LWScrollView.m
//  LockWatch
//
//  Created by Janik Schmidt on 06.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWScrollView.h"
#import "LWWatchFaceContainer.h"

#define accentColor @"#FF9500"
#define scaleDownFactor (188.0/312.0)
#define offsetScale (220.0/188.0)

float scrollDelta = 0;

@implementation LWScrollView


-(id)initWithFrame:(CGRect)frame withWatchFaces:(NSArray*)watchFaceTypes withWatchFaceNames:(NSArray*)watchFaceNames {
    self = [super initWithFrame:frame];
    self.watchFaces = [[NSMutableArray alloc] init];
    self.scaledDown = NO;
    
    self.backgroundColor = [UIColor blackColor];
    
    if (self) {
        for (int i=0; i<[watchFaceTypes count]; i++) {
            LWWatchFaceContainer* watchFaceContainer = [[LWWatchFaceContainer alloc] initWithFrame:CGRectMake((312*offsetScale + 20)*i, 0, 312*offsetScale, 390*offsetScale)
                                                                                     withWatchFace:[watchFaceTypes objectAtIndex:i]
                                                                                   withAccentColor:accentColor
                                                                                         withTitle:[watchFaceNames objectAtIndex:i]];
            [self.watchFaces addObject:watchFaceContainer];
            [self addSubview:[self.watchFaces objectAtIndex:i]];
        }
        self.contentSize = CGSizeMake(self.frame.size.width * [watchFaceTypes count], self.frame.size.height);
        
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scaleDown:)];
        [self addGestureRecognizer:longPress];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleUp:)];
        [self addGestureRecognizer:tap];
        
        self.pagingEnabled = YES;
        self.scrollEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.layer.masksToBounds = NO;
        
        _customizeButton = [[WatchButton alloc] initWithFrame:CGRectMake(0, 0, 152, 42) withTitle:@"Customize"];
        [_customizeButton addTarget:self action:@selector(scaleUpToCustomize) forControlEvents:UIControlEventTouchUpInside];
        _customizeButton.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2 + ((390*offsetScale)/2)*scaleDownFactor + 39);
        _customizeButton.alpha = 0.0;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
        if (contentOffset.x <= 0) {
            _customizeButton.alpha = 1+contentOffset.x / 200;
        } else if (contentOffset.x >= self.contentSize.width - (self.contentSize.width/[self.watchFaces count])) {
            float contentWidth = self.contentSize.width - (self.contentSize.width/[self.watchFaces count]);
            _customizeButton.alpha = 1+(contentWidth-contentOffset.x) / 200;
        } else {
            _customizeButton.alpha = 1;
        }

    scrollDelta = contentOffset.x;
}

-(void)scaleDown:(UILongPressGestureRecognizer*)sender {
    if (!self.scaledDown) {
        self.scaledDown = YES;
        self.scrollEnabled = YES;
        if (sender.state == UIGestureRecognizerStateBegan) {
            CGAffineTransform scale = CGAffineTransformMakeScale(scaleDownFactor, scaleDownFactor);
            CGAffineTransform move = CGAffineTransformMakeTranslation(-4, 0);
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.transform = CGAffineTransformConcat(scale, move);
                                 _customizeButton.alpha = 1.0;
                             }
                             completion:^(BOOL finished){}];
            
            for (int i=0; i<[self.watchFaces count]; i++) {
                [[self.watchFaces objectAtIndex:i] scaleDown];
            }
        }
    }
}

-(void)scaleUp:(UITapGestureRecognizer*)sender {
    if (self.scaledDown) {
        self.scaledDown = NO;
        self.scrollEnabled = NO;
        
        CGAffineTransform scale = CGAffineTransformMakeScale(1, 1);
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, 0);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.transform = CGAffineTransformConcat(scale, move);
                                 _customizeButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished){}];
        for (int i=0; i<[self.watchFaces count]; i++) {
            int isAbleToReInit = (i==self.currentIndex);
            LWWatchFaceContainer* current = [self.watchFaces objectAtIndex:i];
            [current scaleUp:isAbleToReInit];
        }
    }
}

-(void)scaleUpToCustomize {
    if (self.scaledDown) {
        self.scaledDown = NO;
        self.scrollEnabled = NO;
        
        CGAffineTransform scale = CGAffineTransformMakeScale(1, 1);
        CGAffineTransform move = CGAffineTransformMakeTranslation(0, 0);
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.transform = CGAffineTransformConcat(scale, move);
                             _customizeButton.alpha = 0.0;
                         }
                         completion:^(BOOL finished){}];
        for (int i=0; i<[self.watchFaces count]; i++) {
            LWWatchFaceContainer* current = [self.watchFaces objectAtIndex:i];
            [current scaleUp:0];
        }
        LWWatchFaceContainer* current = [self.watchFaces objectAtIndex:self.currentIndex];
        [current customize];
    }
}
@end
