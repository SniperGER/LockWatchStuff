//
//  LWScrollView.m
//  LockWatch
//
//  Created by Janik Schmidt on 23.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWScrollView.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

#define scaleDownFactor (188.0/312.0)
#define offsetScale (220.0/188.0)
//#define spacing (20.0/320.0)*[[UIScreen mainScreen] bounds].size.width
#define spacing 30

@implementation LWScrollView
@synthesize plugins, startScaledDown;

bool customizing;
int initialWatchFaceIndex;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        scaledDown = NO;
        
        //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        if ([defaults objectForKey:@"initialWatchFaceIndex"]) {
            initialWatchFaceIndex = [[defaults valueForKey:@"initialWatchFaceIndex"] intValue];
        } else {
            [defaults setValue:[NSNumber numberWithInt:0] forKey:@"initialWatchFaceIndex"];
            initialWatchFaceIndex = 0;
        }
        if (initialWatchFaceIndex > [plugins count]-1) {
            [defaults setValue:[NSNumber numberWithInt:(int)[plugins count]-1] forKey:@"initialWatchFaceIndex"];
            initialWatchFaceIndex = initialWatchFaceIndex-1;
        }
        [defaults writeToFile:PreferencesFilePath atomically:YES];
        //[defaults synchronize];
        
        CGFloat halfScaleOffset = ((312*offsetScale)-312);
        
        scrollContainer = [[LWScrollViewContainer alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0, 312+halfScaleOffset+spacing, 390)];
        
        [scroll setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [scroll.layer setAnchorPoint:CGPointMake((312.0/2)/(312+halfScaleOffset+spacing), 0.5)];
        
        watchFaceContainer = [[NSMutableArray alloc] init];
        watchFaceContainerDict = [[NSMutableDictionary alloc] init];
        
        NSDictionary* stockSettings = [defaults objectForKey:@"stockPluginsEnabled"];
        NSDictionary* externalSettings = [defaults objectForKey:@"externalPluginsEnabled"];
        
        for (int i=0; i<[plugins count]; i++) {
            CGRect watchFaceRect = CGRectMake((312+spacing+halfScaleOffset)*[watchFaceContainer count], 0, 312, 390);
            NSBundle* plugin = plugins[i];
            LWWatchFace* pluginInstance = [[plugin principalClass] alloc];
            
            [pluginInstance setBundlePath:[NSString stringWithFormat:@"%@%@.watchface/", [self bundlePath], [plugin infoDictionary][@"CFBundleExecutable"]]];
            [pluginInstance setImageBundlePath:@"/private/var/mobile/Library/LockWatch/Image Bundles/"];
            pluginInstance = [pluginInstance initWithFrame:watchFaceRect];

            [watchFaceContainerDict setObject:pluginInstance forKey:[plugin bundleIdentifier]];
            NSLog(@"stockSettings: %@", stockSettings);
            if ([stockSettings objectForKey:[plugin bundleIdentifier]] || [externalSettings objectForKey:[plugin bundleIdentifier]]) {
                if ([[stockSettings valueForKey:[plugin bundleIdentifier]] boolValue] || [[externalSettings valueForKey:[plugin bundleIdentifier]] boolValue]) {
                    if ([plugin localizedInfoDictionary]) {
                        [[pluginInstance titleLabel] setText:[[NSString stringWithFormat:@"%@", [plugin localizedInfoDictionary][@"CFBundleDisplayName"]] uppercaseString]];
                    } else {
                        [[pluginInstance titleLabel] setText:[[NSString stringWithFormat:@"%@", [plugin infoDictionary][@"CFBundleDisplayName"]] uppercaseString]];
                    }
                    NSLog(@"pluginInstance: %@", pluginInstance);
                    NSLog(@"initialWatchFaceIndex: %d, i: %d", initialWatchFaceIndex, i);
                    if (i == initialWatchFaceIndex) {
                        [pluginInstance initWatchFace];
                        [pluginInstance setAlpha:1.0];
                    }
                    [watchFaceContainer addObject:pluginInstance];
                    [scroll addSubview:pluginInstance];
                }
            }
        }

        [scroll setContentSize:CGSizeMake((312+spacing+halfScaleOffset)*[watchFaceContainer count], 390)];
        
        if (initialWatchFaceIndex < [watchFaceContainer count]-1) {
            [scroll setContentOffset:CGPointMake((312+spacing+halfScaleOffset)*initialWatchFaceIndex, 0)];
            currentIndex = initialWatchFaceIndex;
        } else {
            [scroll setContentOffset:CGPointMake((312+spacing+halfScaleOffset)*([watchFaceContainer count]-1), 0)];
            currentIndex = ((int)[watchFaceContainer count]-1);
        }
        
        watchFacePlugins = plugins;
        
        [scroll setClipsToBounds:NO];
        [scroll setPagingEnabled:YES];
        [scroll setShowsHorizontalScrollIndicator:NO];
        [scroll setScrollEnabled:NO];
        [scroll setDelegate:self];
        
        [scrollContainer addSubview:scroll];
        
        [self addSubview:scrollContainer];
        
        longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(scaleDown:)];
        [self addGestureRecognizer:longPress];
        
        tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scaleUp:)];
        [scroll addGestureRecognizer:tap];
        
        customizeButton = [[WatchButton alloc] initWithFrame:CGRectMake(0, 0, 152, 42) withTitle:NSLocalizedString(@"CUSTOMIZE", nil)];
        [customizeButton addTarget:self action:@selector(scaleUpToCustomize:) forControlEvents:UIControlEventTouchUpInside];
        [customizeButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, self.frame.size.height/2 + ((390*offsetScale)*scaleDownFactor)/2 + 39)];
        [customizeButton setAlpha:0.0];
        [self addSubview:customizeButton];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scaledUp" object:self userInfo:nil];
        
        if (startScaledDown) {
            [self scaleDownWithoutAnimation];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationResignedEvent)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationResignedEvent {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (scaledDown) {
            //[self scaleUp:nil];
        }
    });
}

- (void)updateSizes:(CGRect)frame withOrientation:(UIInterfaceOrientation)orientation {
    CGFloat scrollViewWidth, scrollViewHeight;
    CGFloat halfScaleOffset = ((312*offsetScale)-312);
    scrollViewWidth = ([[UIScreen mainScreen] bounds].size.width/312.0) * 312;
    scrollViewHeight = ([[UIScreen mainScreen] bounds].size.width/312.0) * 390;
    
    [self setFrame:frame];
    
    if (!scaledDown) {
        [scrollContainer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    } else {
        [scrollContainer setFrame:CGRectMake(0, frame.size.height/2 - (frame.size.height*scaleDownFactor)/2, frame.size.width, frame.size.height*scaleDownFactor)];
    }
    [scroll setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
    [scroll setContentSize:CGSizeMake((312+spacing+halfScaleOffset)*[watchFaceContainer count], 390)];
    [scroll.layer setAnchorPoint:CGPointMake((312.0/2)/(312+halfScaleOffset+spacing), 0.5)];
    [customizeButton setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, frame.size.height/2 + ((390*offsetScale)*scaleDownFactor)/2 + 39)];
    //colorSelector.frame = CGRectMake(0, (scrollContainer.frame.size.height/2 + 390/2) - 60, self.frame.size.width, 90);
}

- (void)reoderWatchFaces:(NSArray*)newOrder {
    [[scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    NSDictionary* stockSettings = [defaults objectForKey:@"stockPluginsEnabled"];
    NSDictionary* externalSettings = [defaults objectForKey:@"externalPluginsEnabled"];
    
    watchFaceContainer = [[NSMutableArray alloc] init];
    
    CGFloat halfScaleOffset = ((312*offsetScale)-312);
    
    for (int i=0; i<[newOrder count]; i++) {
        CGRect watchFaceRect = CGRectMake((312+spacing+halfScaleOffset)*[watchFaceContainer count], 0, 312, 390);
        NSBundle* plugin = [newOrder objectAtIndex:i];
        
        LWWatchFace* pluginInstance = [watchFaceContainerDict objectForKey:[plugin bundleIdentifier]];
        [pluginInstance setFrame:watchFaceRect];
        if (!pluginInstance) {
            pluginInstance = [[[[NSBundle bundleWithIdentifier:[plugin bundleIdentifier]] principalClass] alloc] initWithFrame:watchFaceRect];
            [pluginInstance deInitWatchFace:NO];
        }
        
        if ([stockSettings objectForKey:[plugin bundleIdentifier]] || [externalSettings objectForKey:[plugin bundleIdentifier]]) {
            if ([[stockSettings valueForKey:[plugin bundleIdentifier]] boolValue] || [[externalSettings valueForKey:[plugin bundleIdentifier]] boolValue]) {
                if ([plugin localizedInfoDictionary]) {
                    [[pluginInstance titleLabel] setText:[[NSString stringWithFormat:@"%@", [plugin localizedInfoDictionary][@"CFBundleDisplayName"]] uppercaseString]];
                } else {
                    [[pluginInstance titleLabel] setText:[[NSString stringWithFormat:@"%@", [plugin infoDictionary][@"CFBundleDisplayName"]] uppercaseString]];
                }
                if (i == initialWatchFaceIndex) {
                    [pluginInstance initWatchFace];
                    [pluginInstance setAlpha:1.0];
                }
                
                [watchFaceContainer addObject:pluginInstance];
                [scroll addSubview:pluginInstance];
            }
        }
    }
    
    [scroll setContentSize:CGSizeMake((312+spacing+halfScaleOffset)*[watchFaceContainer count], 390)];
    
    if (initialWatchFaceIndex < [watchFaceContainer count]-1) {
        [scroll setContentOffset:CGPointMake((312+spacing+halfScaleOffset)*initialWatchFaceIndex, 0)];
        currentIndex = initialWatchFaceIndex;
    } else {
        [scroll setContentOffset:CGPointMake((312+spacing+halfScaleOffset)*([watchFaceContainer count]-1), 0)];
        currentIndex = ((int)[watchFaceContainer count]-1);
    }
}
- (void)reRenderWatchFaces {
    CGFloat halfScaleOffset = ((312*offsetScale)-312);
    for (int i=0; i<watchFaceContainer.count; i++) {
        CGRect watchFaceRect = CGRectMake((312+spacing+halfScaleOffset)*i, 0, 312, 390);
        NSValue *testValue = [NSValue valueWithCGRect:watchFaceRect];
        [[watchFaceContainer objectAtIndex:i] performSelector:@selector(initWithFrame:) withObject:testValue afterDelay:0];
        
        if (i == currentIndex && !scaledDown) {
            [[watchFaceContainer objectAtIndex:i] performSelector:@selector(initWatchFace) withObject:nil afterDelay:0];
        } else if (scaledDown) {
            NSNumber* boolValue = [NSNumber numberWithBool:NO];
            [[watchFaceContainer objectAtIndex:i] performSelector:@selector(deInitWatchFace:) withObject:boolValue afterDelay:0];
        }
        
        NSBundle* pluginBundle = [watchFacePlugins objectAtIndex:i];
        if ([pluginBundle localizedInfoDictionary]) {
            NSString* titleString = [[NSString stringWithFormat:@"%@", [pluginBundle localizedInfoDictionary][@"CFBundleDisplayName"]] uppercaseString];
            [[watchFaceContainer objectAtIndex:i] performSelector:@selector(setTitleLabelText:) withObject:titleString afterDelay:0];
        } else {
            NSString* titleString = [[NSString stringWithFormat:@"%@", [pluginBundle infoDictionary][@"CFBundleDisplayName"]] uppercaseString];
            [[watchFaceContainer objectAtIndex:i] performSelector:@selector(setTitleLabelText:) withObject:titleString afterDelay:0];
        }
    }
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat halfScaleOffset = ((312*offsetScale)-312);
    CGFloat width = 312+halfScaleOffset+spacing;
    int page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    currentIndex = page;
    
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    [defaults setValue:[NSNumber numberWithInt:page] forKey:@"initialWatchFaceIndex"];
    [defaults writeToFile:PreferencesFilePath atomically:YES];
    initialWatchFaceIndex = page;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat halfScaleOffset = ((312*offsetScale)-312);
    CGFloat width = 312+halfScaleOffset+spacing;
    CGFloat page = (scrollView.contentOffset.x / width);
    currentIndex = page;
    
    int prevIndex = (page > 0) ? floor(page) : 0;
    int nextIndex = (page < [watchFaceContainer count]-1) ? ceil(page) : (int)[watchFaceContainer count]-1;
    
    CGFloat pageProgress = -(((currentIndex) * width) - scrollView.contentOffset.x)/width;
    pageProgress = (round(pageProgress*100))/100.0;
    
    if (scrollDelta != scrollView.contentOffset.x) {
        LWWatchFace* next = [watchFaceContainer objectAtIndex:nextIndex];
        // Swipe from right to left -> next watch face
        if (scrollDelta < scrollView.contentOffset.x) {
            // Detect overswipe
            if (scrollView.contentOffset.x+width <= scrollView.contentSize.width && scrollView.contentOffset.x > 0) {
                // Regular swipe
                LWWatchFace* current = [watchFaceContainer objectAtIndex:nextIndex-1];
                
                if ([current customizable]) {
                    if ([next customizable]) {
                        customizeButton.alpha = 1;
                    } else {
                        customizeButton.alpha = 1-pageProgress;
                    }
                } else {
                    if ([next customizable]) {
                        customizeButton.alpha = pageProgress;
                    } else {
                        customizeButton.alpha = 0;
                    }
                }
                [[current layer] removeAllAnimations];
                [[next layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, 1-pageProgress)];
                [next setAlpha:MAX(0.5, pageProgress)];
            } else if (scrollView.contentOffset.x <= 0) {
                // Transition outside to inside
                LWWatchFace* current = [watchFaceContainer objectAtIndex:currentIndex];
                if ([current customizable]) {
                    customizeButton.alpha = 1+(scrollView.contentOffset.x/width);
                } else {
                    customizeButton.alpha = 0;
                }
                [[current layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, 1+(scrollView.contentOffset.x/width))];
            } else{
                // Swipe over bounds
                LWWatchFace* current = [watchFaceContainer objectAtIndex:currentIndex];
                if ([current customizable]) {
                    customizeButton.alpha = 1-((scrollView.contentOffset.x+width)-scrollView.contentSize.width)/width;
                } else {
                    customizeButton.alpha = 0;
                }
                [[current layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, 1-((scrollView.contentOffset.x+width)-scrollView.contentSize.width)/width)];
            }
        }
        
        // Swipe from left to right -> previous watch face
        if (scrollDelta > scrollView.contentOffset.x) {
            LWWatchFace* prev = [watchFaceContainer objectAtIndex:prevIndex];
            // Detect overswipe
            if (scrollView.contentOffset.x >= 0 && scrollView.contentOffset.x+width <= scrollView.contentSize.width) {
                // Regular swipe
                LWWatchFace* current = [watchFaceContainer objectAtIndex:prevIndex+1];
                
                if ([current customizable]) {
                    if ([prev customizable]) {
                        customizeButton.alpha = 1;
                    } else {
                        customizeButton.alpha = pageProgress;
                    }
                } else {
                    if ([prev customizable]) {
                        customizeButton.alpha = 1-pageProgress;
                    } else {
                        customizeButton.alpha = 0;
                    }
                }
                [[current layer] removeAllAnimations];
                [[prev layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, pageProgress)];
                [prev setAlpha:MAX(0.5, 1-pageProgress)];
            } else if (scrollView.contentOffset.x+width > scrollView.contentSize.width) {
                // Transition outside to inside
                LWWatchFace* current = [watchFaceContainer objectAtIndex:currentIndex];
                if ([current customizable]) {
                    customizeButton.alpha = 1-((scrollView.contentOffset.x+width)-scrollView.contentSize.width)/width;
                } else {
                    customizeButton.alpha = 0;
                }
                [[current layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, 1-((scrollView.contentOffset.x+width)-scrollView.contentSize.width)/width)];
            } else {
                // Swipe over bounds
                LWWatchFace* current = [watchFaceContainer objectAtIndex:currentIndex];
                if ([current customizable]) {
                    customizeButton.alpha = 1+(scrollView.contentOffset.x/width);
                } else {
                    customizeButton.alpha = 0;
                }
                [[current layer] removeAllAnimations];
                [current setAlpha:MAX(0.5, 1+(scrollView.contentOffset.x/width))];
            }
        }
    }
    scrollDelta = scrollView.contentOffset.x;
}

- (void)scaleDown:(UILongPressGestureRecognizer*)sender {
    if (!scaledDown && sender.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scaledDown" object:self userInfo:nil];
        scaledDown = YES;
        [scrollContainer setScaledDownScrollView:YES];
        
        if (watchFaceContainer.count > 0) {
            for (int i=0; i<[watchFaceContainer count]; i++) {
                LWWatchFace* watchFace = [watchFaceContainer objectAtIndex:i];
                if (i == currentIndex) {
                    [watchFace deInitWatchFace:YES];
                } else {
                    [watchFace deInitWatchFace:NO];
                    [watchFace setAlpha:0.5];
                }
            }
        }
        [scroll setScrollEnabled:YES];
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.3] forKey:kCATransactionAnimationDuration];
        
        CAAnimation *scale1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"
                                                               function:QuinticEaseOut
                                                              fromValue:1.0
                                                                toValue:scaleDownFactor];
        scale1.fillMode = kCAFillModeForwards;
        scale1.removedOnCompletion = NO;
        [scroll.layer addAnimation:scale1 forKey:@"scale"];
        
        CAAnimation *scale2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"
                                                               function:QuinticEaseOut
                                                              fromValue:1.0
                                                                toValue:scaleDownFactor];
        scale2.fillMode = kCAFillModeForwards;
        scale2.removedOnCompletion = NO;
        [scrollContainer.layer addAnimation:scale2 forKey:@"scale"];
        
        
        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                function:QuinticEaseOut
                                                               fromValue:0.0
                                                                 toValue:1.0];
        opacity.fillMode = kCAFillModeForwards;
        opacity.removedOnCompletion = NO;
        
        LWWatchFace* current;
        if (watchFaceContainer.count > 0) {
            current = [watchFaceContainer objectAtIndex:currentIndex];
            if ([current customizable]) {
                [customizeButton.layer addAnimation:opacity forKey:@"opacity"];
            }
        }
        
        [CATransaction commit];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scroll setTransform:CGAffineTransformMakeScale(scaleDownFactor, 1)];
            [scrollContainer setTransform:CGAffineTransformMakeScale(1, scaleDownFactor)];
            
            if (watchFaceContainer.count > 0 && [current customizable]) {
                [customizeButton.layer setOpacity:1.0];
            }
            
            [customizeButton.layer removeAllAnimations];
        });
    }
    scaledDown = YES;
}

- (void)scaleDownWithoutAnimation {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"scaledDown" object:self userInfo:nil];
    scaledDown = YES;
    [scrollContainer setScaledDownScrollView:YES];
    
    if (watchFaceContainer.count > 0) {
        for (int i=0; i<[watchFaceContainer count]; i++) {
            LWWatchFace* watchFace = [watchFaceContainer objectAtIndex:i];
            if (i == currentIndex) {
                [watchFace deInitWatchFace:YES];
            } else {
                [watchFace deInitWatchFace:NO];
            }
        }
    }
    [scroll setTransform:CGAffineTransformMakeScale(scaleDownFactor, 1)];
    [scrollContainer setTransform:CGAffineTransformMakeScale(1, scaleDownFactor)];
    
    [scroll setScrollEnabled:YES];
    
    LWWatchFace* current;
    if (watchFaceContainer.count > 0) {
        current = [watchFaceContainer objectAtIndex:currentIndex];
    }
    if (watchFaceContainer.count > 0 && [current customizable]) {
        [customizeButton.layer setOpacity:1.0];
    }
    [current setAlpha:1.0];
    
    scaledDown = YES;
}

- (void)scaleUp:(UITapGestureRecognizer*)sender {
    if (scaledDown) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scaledUp" object:self userInfo:nil];
        scaledDown = NO;
        [scrollContainer setScaledDownScrollView:NO];
        
        for (int i=0; i<[watchFaceContainer count]; i++) {
            LWWatchFace* watchFace = [watchFaceContainer objectAtIndex:i];
            if (i == currentIndex) {
                [watchFace reInitWatchFace:YES];
            } else {
                [watchFace reInitWatchFace:NO];
            }
        }
        
        [scroll setScrollEnabled:NO];
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.4] forKey:kCATransactionAnimationDuration];
        
        CAAnimation *scale1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"
                                                               function:QuinticEaseOut
                                                              fromValue:scaleDownFactor
                                                                toValue:1.0];
        scale1.fillMode = kCAFillModeForwards;
        scale1.removedOnCompletion = NO;
        [scroll.layer addAnimation:scale1 forKey:@"scale"];
        
        CAAnimation *scale2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"
                                                               function:QuinticEaseOut
                                                              fromValue:scaleDownFactor
                                                                toValue:1.0];
        scale2.fillMode = kCAFillModeForwards;
        scale2.removedOnCompletion = NO;
        [scrollContainer.layer addAnimation:scale2 forKey:@"scale"];
        
        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                function:QuinticEaseOut
                                                               fromValue:1.0
                                                                 toValue:0.0];
        opacity.fillMode = kCAFillModeForwards;
        opacity.removedOnCompletion = NO;
        
        LWWatchFace* current = [watchFaceContainer objectAtIndex:currentIndex];
        if ([current customizable]) {
            [customizeButton.layer addAnimation:opacity forKey:@"opacity"];
        }
        
        [CATransaction commit];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scroll setTransform:CGAffineTransformMakeScale(1, 1)];
            [scrollContainer setTransform:CGAffineTransformMakeScale(1, 1)];
            
            [customizeButton.layer setOpacity:0.0];
        });
    }
}

- (void)scaleUpToCustomize:(UITapGestureRecognizer*)sender {
    if (scaledDown) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scaledUp" object:self userInfo:nil];
        scaledDown = NO;
        [scrollContainer setScaledDownScrollView:NO];
        
        if (watchFaceContainer.count > 0) {
            for (int i=0; i<[watchFaceContainer count]; i++) {
                LWWatchFace* watchFace = [watchFaceContainer objectAtIndex:i];
                if (i == currentIndex) {
                    //[watchFace reInitWatchFace:NO];
                    [watchFace callCustomizeSheet];
                } else {
                    [watchFace reInitWatchFace:NO];
                }
            }
        }
        
        [scroll setScrollEnabled:NO];
        
        [CATransaction begin];
        [CATransaction setValue:[NSNumber numberWithFloat:0.4] forKey:kCATransactionAnimationDuration];
        
        CAAnimation *scale1 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.x"
                                                               function:QuinticEaseOut
                                                              fromValue:scaleDownFactor
                                                                toValue:1.0];
        scale1.fillMode = kCAFillModeForwards;
        scale1.removedOnCompletion = NO;
        [scroll.layer addAnimation:scale1 forKey:@"scale"];
        
        CAAnimation *scale2 = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale.y"
                                                               function:QuinticEaseOut
                                                              fromValue:scaleDownFactor
                                                                toValue:1.0];
        scale2.fillMode = kCAFillModeForwards;
        scale2.removedOnCompletion = NO;
        [scrollContainer.layer addAnimation:scale2 forKey:@"scale"];
        
        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                function:QuinticEaseOut
                                                               fromValue:1.0
                                                                 toValue:0.0];
        opacity.fillMode = kCAFillModeForwards;
        opacity.removedOnCompletion = NO;
        
        LWWatchFace* current;
        if (watchFaceContainer.count > 0) {
            current = [watchFaceContainer objectAtIndex:currentIndex];
            if ([current customizable]) {
                [customizeButton.layer addAnimation:opacity forKey:@"opacity"];
            }
        }
        
        [CATransaction commit];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scroll setTransform:CGAffineTransformMakeScale(1, 1)];
            [scrollContainer setTransform:CGAffineTransformMakeScale(1, 1)];
            
            [customizeButton.layer setOpacity:0.0];
            //[colorSelector setAlpha:1.0];
        });
    }
}

@end