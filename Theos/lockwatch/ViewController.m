//
//  ViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 23.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "ViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set plugin path if testing in Simulator or on device
#if TARGET_IPHONE_SIMULATOR
    pluginLocationString = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/PlugIns/"];
#else
    pluginLocationString = @"/private/var/mobile/Library/LockWatch/Watch Faces/";
#endif
    
    // Set which watch faces are recognized as stock
    stockPluginBundleNames = [[NSArray alloc] initWithObjects:
                              @"Simple.watchface",
                              @"Color.watchface",
                              @"Weather.watchface",
                              @"Chronograph.watchface",
                              @"X-Large.watchface",
                              @"Mickey.watchface", nil];
    stockPluginIdentifiers = [[NSArray alloc] initWithObjects:
                              @"de.sniperger.watchface.simple",
                              @"de.sniperger.watchface.color",
                              @"de.sniperger.watchface.weather",
                              @"de.sniperger.watchface.chrono",
                              @"de.sniperger.watchface.xlarge",
                              @"de.sniperger.watchface.mouse", nil];
    
    NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile:PreferencesFilePath];
    
    knownPlugins = [[NSMutableArray alloc] init];
    if ([defaults objectForKey:@"knownPlugins"]) {
        knownPlugins = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"knownPlugins"]];
    }
    
    stockPluginOrder = [[NSMutableArray alloc] init];
    if ([defaults objectForKey:@"stockPlugins"]) {
        stockPluginOrder = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"stockPlugins"]];
    }
    stockPluginEnabled = [[NSMutableDictionary alloc] init];
    if ([defaults objectForKey:@"stockPluginsEnabled"]) {
        stockPluginEnabled = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"stockPluginsEnabled"]];
    }
    
    externalPluginOrder = [[NSMutableArray alloc] init];
    if ([defaults objectForKey:@"externalPlugins"]) {
        externalPluginOrder = [[NSMutableArray alloc] initWithArray:[defaults objectForKey:@"externalPlugins"]];
    }
    externalPluginEnabled = [[NSMutableDictionary alloc] init];
    if ([defaults objectForKey:@"externalPluginsEnabled"]) {
        externalPluginEnabled = [[NSMutableDictionary alloc] initWithDictionary:[defaults objectForKey:@"externalPluginsEnabled"]];
    }
    
    //[defaults removeObjectForKey:@"activeColorSet"];
    
    //[defaults synchronize];
    
    // Set background color
    //[self.view setBackgroundColor:[UIColor greenColor]];
    
    // Load Watch Face Bundles
    [self loadStockPlugins];
    //[self loadExternalPlugins];
    
    // Initialize LWScrollView
    [self initScrollView];
    // Initialiize Notification Observers
    _settingsButton.alpha = 0;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    
    [center addObserverForName:@"scaledDown"
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note){
                        scaledDown = YES;
                        
                        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                                function:QuinticEaseOut
                                                                               fromValue:0.0
                                                                                 toValue:1.0];
                        opacity.fillMode = kCAFillModeForwards;
                        opacity.removedOnCompletion = NO;
                        [_settingsButton.layer addAnimation:opacity forKey:@"opacity"];
                        [CATransaction commit];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [_settingsButton.layer removeAllAnimations];
                            _settingsButton.alpha = 1;
                        });
                    }];
    [center addObserverForName:@"scaledUp"
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note){
                        scaledDown = NO;
                        
                        CAAnimation *opacity = [CAKeyframeAnimation animationWithKeyPath:@"opacity"
                                                                                function:QuinticEaseOut
                                                                               fromValue:1.0
                                                                                 toValue:0.0];
                        opacity.fillMode = kCAFillModeForwards;
                        opacity.removedOnCompletion = NO;
                        [_settingsButton.layer addAnimation:opacity forKey:@"opacity"];
                        [CATransaction commit];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [_settingsButton.layer removeAllAnimations];
                            _settingsButton.alpha = 0;
                        });
                    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadStockPlugins {
    //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    
    watchFacePlugins = [[NSMutableArray alloc] init];
    watchFacePluginIdentifiers = [[NSMutableArray alloc] init];
    
    //[defaults removeObjectForKey:@"activeColorSet"];
    
    if (![defaults objectForKey:@"stockPlugins"]) {
        [defaults setObject:stockPluginIdentifiers forKey:@"stockPlugins"];
    }
    if (![defaults objectForKey:@"stockPluginsEnabled"]) {
        NSMutableDictionary* enabledSettings = [[NSMutableDictionary alloc] init];
        
        for (id object in [defaults objectForKey:@"stockPlugins"]) {
            [enabledSettings setValue:[NSNumber numberWithBool:YES] forKey:object];
        }
        
        [defaults setObject:enabledSettings forKey:@"stockPluginsEnabled"];
    }
    [defaults writeToFile:PreferencesFilePath atomically:YES];
    //[defaults synchronize];
    
    NSMutableDictionary* loadedStockPluginsIndex = [[NSMutableDictionary alloc] init];
    
    NSURL* pluginLocation = [[NSURL fileURLWithPath:pluginLocationString] URLByResolvingSymlinksInPath];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    
    if ([contents count] < 1) {
        NSLog(@"No plugins found");
    } else {
        [stockPluginBundleNames enumerateObjectsUsingBlock:^(id defaultPlugin, NSUInteger i, BOOL* stop) {
            NSURL* filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", pluginLocationString, defaultPlugin]];
            NSBundle* plugin = [[NSBundle alloc] initWithURL:filePath];
            if (plugin!= NULL) {
                NSString* pluginIdentifier = [plugin bundleIdentifier];
                [loadedStockPluginsIndex setObject:plugin forKey:pluginIdentifier];
            }
        }];
        
        stockPluginOrder = [defaults objectForKey:@"stockPlugins"];
        for (id object in stockPluginOrder) {
            NSBundle* plugin = loadedStockPluginsIndex[object];
            BOOL loaded = [plugin load];
            if (loaded && [defaults[@"stockPluginsEnabled"][object] boolValue]) {
                [watchFacePlugins addObject:plugin];
                [watchFacePluginIdentifiers addObject:[plugin bundleIdentifier]];
            }
        }
    }
}

- (void)initScrollView {
    [[scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [scroll removeFromSuperview];
    
    scroll = [LWScrollView alloc];
    [scroll setPlugins:watchFacePlugins];
    [scroll setBundlePath:pluginLocationString];
    
    CGFloat scrollViewWidth = ([[UIScreen mainScreen] bounds].size.width/312.0) * 312;
    CGFloat scrollViewHeight = ([[UIScreen mainScreen] bounds].size.width/312.0) * 390;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        scrollViewHeight = [[UIScreen mainScreen] bounds].size.height - 64;
    }
    
    scroll = [scroll initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2 - scrollViewHeight/2, scrollViewWidth, scrollViewHeight)];
    
    if (![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        scroll.transform = CGAffineTransformMakeScale([[UIScreen mainScreen] bounds].size.width / 414.0, [[UIScreen mainScreen] bounds].size.width / 414.0);
    }
    
    [self.view addSubview:scroll];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
