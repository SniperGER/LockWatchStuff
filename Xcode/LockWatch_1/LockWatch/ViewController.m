//
//  ViewController.m
//  LockWatch
//
//  Created by Janik Schmidt on 28.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "ViewController.h"
#import "CAKeyframeAnimation+AHEasing.h"


BOOL scaledDown;

@implementation ViewController

NSString* pluginLocationString;

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor blackColor]];
    
#if TARGET_IPHONE_SIMULATOR
    pluginLocationString = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/PlugIns/"];
#else
    pluginLocationString = @"/private/var/mobile/Library/LockWatch/Watch Faces/";
#endif
    
    if ( [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    }
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
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
    NSLog(@"Test");
    [self loadStockPlugins];
    [self loadExternalPlugins];
    //[self loadPlugins];
    [self initScrollView];
    
    _settingsButton.alpha = 0;
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:@"settingsChanged"
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note){
                        [self defaultsChanged];
                    }];
    [center addObserverForName:@"antialiasing"
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note){
                        [scroll reRenderWatchFaces];
                    }];
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

- (void)loadStockPlugins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    watchFacePlugins = [[NSMutableArray alloc] init];
    watchFacePluginIdentifiers = [[NSMutableArray alloc] init];
    
    if (![defaults objectForKey:@"stockPlugins"]) {
        NSArray* stockPlugins = [[NSArray alloc] initWithObjects:
                                 @"de.sniperger.watchface.simple",
                                 @"de.sniperger.watchface.color",
                                 @"de.sniperger.watchface.weather",
                                 @"de.sniperger.watchface.chrono",
                                 @"de.sniperger.watchface.xlarge",
                                 @"de.sniperger.watchface.mouse", nil];
        [defaults setObject:stockPlugins forKey:@"stockPlugins"];
    }
    if (![defaults objectForKey:@"stockPluginsEnabled"]) {
        NSMutableDictionary* enabledSettings = [[NSMutableDictionary alloc] init];
        
        for (id object in [defaults objectForKey:@"stockPlugins"]) {
            [enabledSettings setValue:[NSNumber numberWithBool:YES] forKey:object];
        }
        
        [defaults setObject:enabledSettings forKey:@"stockPluginsEnabled"];
    }
    
    NSMutableDictionary* loadedStockPluginsIndex = [[NSMutableDictionary alloc] init];
    
    NSURL* pluginLocation = [[NSURL fileURLWithPath:pluginLocationString] URLByResolvingSymlinksInPath];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    NSLog(@"%@", contents);
    
    if ([contents count] < 1) {
        NSLog(@"No plugins found");
    } else {
        NSArray* defaultPlugins = [[NSArray alloc] initWithObjects:@"Simple.watchface", @"Color.watchface", @"Weather.watchface", @"Chronograph.watchface", @"X-Large.watchface", @"Mickey.watchface", nil];
        [defaultPlugins enumerateObjectsUsingBlock:^(id defaultPlugin, NSUInteger i, BOOL* stop) {
            NSURL* filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", pluginLocationString, defaultPlugin]];
            NSBundle* plugin = [[NSBundle alloc] initWithURL:filePath];
            NSString* pluginIdentifier = [plugin bundleIdentifier];

            [loadedStockPluginsIndex setObject:plugin forKey:pluginIdentifier];
        }];
        
        stockPluginOrder = [defaults objectForKey:@"stockPlugins"];
        for (id object in stockPluginOrder) {
            NSBundle* plugin = loadedStockPluginsIndex[object];
            
            BOOL loaded = [plugin load];
            if (loaded) {
                [watchFacePlugins addObject:plugin];
                [watchFacePluginIdentifiers addObject:[plugin bundleIdentifier]];
            }
        }
    }
}

- (void)loadExternalPlugins {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL firstTimeSetup = NO;
    __block BOOL unknownPlugin = NO;
    
    if (![defaults objectForKey:@"externalPlugins"]) {
        NSArray* externalPlugins = [[NSArray alloc] init];
        [defaults setObject:externalPlugins forKey:@"externalPlugins"];
        
        firstTimeSetup = YES;
    }
    
    NSMutableDictionary* loadedPluginsIndex = [[NSMutableDictionary alloc] init];
    
    NSURL* pluginLocation = [NSURL fileURLWithPath:pluginLocationString];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    
    if ([contents count] < 1) {
        NSLog(@"No third-party plugins found");
    }
    
    NSMutableArray* externalPluginIdentifiers = [[NSMutableArray alloc] init];
    NSMutableArray* unknownExternalPlugins = [[NSMutableArray alloc] init];
    
    [contents enumerateObjectsUsingBlock:^ (NSURL *fileURL, NSUInteger idx, BOOL *stop) {
        NSString *fileType = [fileURL resourceValuesForKeys:@[NSURLTypeIdentifierKey] error:NULL][NSURLTypeIdentifierKey];
        if (fileType == nil) {
            return;
        }
        
        NSBundle *plugin = [[NSBundle alloc] initWithURL:fileURL];
        
        NSString *pluginIdentifier = [plugin bundleIdentifier];

        if (pluginIdentifier == nil) {
            NSLog(@"The plugin bundle identifier couldn\u2019t be retrieved.");
            return;
        }
        
        if ([pluginIdentifier isEqualToString:@"de.sniperger.watchface.simple"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.color"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.weather"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.chrono"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.xlarge"] ||
            [pluginIdentifier isEqualToString:@"de.sniperger.watchface.mouse"]) {
            return;
        }
        if (![knownPlugins containsObject:pluginIdentifier]) {
            unknownPlugin = YES;
            [unknownExternalPlugins addObject:pluginIdentifier];
        }
        
        [loadedPluginsIndex setObject:plugin forKey:pluginIdentifier];
        [externalPluginIdentifiers addObject:pluginIdentifier];
    }];

    if (firstTimeSetup) {
        [defaults setObject:externalPluginIdentifiers forKey:@"externalPlugins"];
    }
    if (unknownPlugin) {
        for (NSString* object in unknownExternalPlugins) {
            if (![externalPluginOrder containsObject:object]) {
                [externalPluginOrder addObject:object];
            }
            [externalPluginEnabled setValue:[NSNumber numberWithBool:YES] forKey:object];
            
            if (![knownPlugins containsObject:object]) {
                [knownPlugins addObject:object];
            }
        }
        [defaults setObject:externalPluginOrder forKey:@"externalPlugins"];
        [defaults setObject:externalPluginEnabled forKey:@"externalPluginsEnabled"];
    }
    
    externalPluginOrder = [defaults objectForKey:@"externalPlugins"];
    externalPluginEnabled = [defaults objectForKey:@"externalPluginsEnabled"];
    for (id object in externalPluginOrder) {
        NSBundle* plugin = loadedPluginsIndex[object];
        BOOL loaded = [plugin load];
        
        if (loaded && [[externalPluginEnabled valueForKey:[plugin bundleIdentifier]] boolValue]) {
        
            [watchFacePlugins addObject:plugin];
            [watchFacePluginIdentifiers addObject:[plugin bundleIdentifier]];
        }
    }
    [defaults setObject:knownPlugins forKey:@"knownPlugins"];
}

- (void)initScrollView {
    [[scroll subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [scroll removeFromSuperview];
    
    CGFloat scrollViewWidth = ([[UIScreen mainScreen] bounds].size.width/312.0) * 312;
    CGFloat scrollViewHeight = ([[UIScreen mainScreen] bounds].size.width/312.0) * 390;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        scrollViewHeight = [[UIScreen mainScreen] bounds].size.height - 64;
    }
    
    scroll = [[LWScrollView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen] bounds].size.height/2 - scrollViewHeight/2, scrollViewWidth, scrollViewHeight) withWatchFaces:watchFacePlugins isScaledDown:scaledDown];

    if (![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        scroll.transform = CGAffineTransformMakeScale([[UIScreen mainScreen] bounds].size.width / 414.0, [[UIScreen mainScreen] bounds].size.width / 414.0);
    }
    
    [self.view addSubview:scroll];
}

- (void)orientationChanged:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect screenBounds = [self screenBoundsFixedToPortraitOrientation];
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            CGFloat scrollViewWidth = (screenBounds.size.height/312.0) * 312;
            CGFloat scrollViewHeight = screenBounds.size.width - 64;
            
            [scroll updateSizes:CGRectMake(0, 32, scrollViewWidth, scrollViewHeight) withOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        } else {
            CGFloat scrollViewWidth = (screenBounds.size.width/312.0) * 312;
            CGFloat scrollViewHeight = (screenBounds.size.width/312.0) * 390;
            
            [scroll updateSizes:CGRectMake(0, screenBounds.size.height/2 - scrollViewHeight/2, scrollViewWidth, scrollViewHeight) withOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
        }
    });
}

- (CGRect)screenBoundsFixedToPortraitOrientation {
    UIScreen *screen = [UIScreen mainScreen];
    
    if ([screen respondsToSelector:@selector(fixedCoordinateSpace)]) {
        return [screen.coordinateSpace convertRect:screen.bounds toCoordinateSpace:screen.fixedCoordinateSpace];
    }
    return screen.bounds;
}

- (void)defaultsChanged {
    [self loadStockPlugins];
    [self loadExternalPlugins];
    
    [scroll reoderWatchFaces:watchFacePlugins];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
