/*
  Current Solution:
  
  • Add LockWatch as UIScrollView to SBLockScreenScrollView (using -layoutSubviews)
  • UIButton as overlay for handling the UILongPressGestureRecognizer
  
*/

#define PreferencesChangedNotification "de.sniperger.lockwatch.prefs"
#define PreferencesFilePath [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences/de.sniperger.LockWatch.plist"]
#define PluginFilePath "/Library/Application Support/LockWatch/Watch Faces/"

static NSDictionary *defaults = nil;

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	defaults = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
}

#import "LWScrollView.h"

@interface SBLockScreenScrollView : UIView
@end

@interface SBLockScreenNotificationListController : NSObject
@property (assign,nonatomic) BOOL hasAnyContent;
@end

@interface SBLockScreenViewController : UIViewController
-(SBLockScreenNotificationListController*)_notificationController;
-(BOOL)handleLockButtonPressed;
@end

@interface SBLockScreenView : UIView
- (void)scrollToPage:(long long)arg1 animated:(BOOL)arg2;
@end

static bool scaledDown = NO;
static bool isReRenderAllowed = YES;

static UIScrollView* _lsView = nil;
UIButton* scrollViewButton = nil;
SBLockScreenNotificationListController* notificationController;
LWScrollView* scrollView = nil;

static NSMutableArray* watchFacePlugins;
NSMutableArray* watchFacePluginIdentifiers;

NSMutableArray* stockPluginOrder;
NSMutableDictionary* stockPluginEnabled;

NSMutableArray* externalPluginOrder;
NSMutableDictionary* externalPluginEnabled;

NSMutableArray* knownPlugins;

LWScrollView* scroll;

static void loadStockPlugins() {    
    watchFacePlugins = [[NSMutableArray alloc] init];
    watchFacePluginIdentifiers = [[NSMutableArray alloc] init];
    
    NSLog(@"LockWatch: Loading plugins...");
    
    if (![defaults objectForKey:@"stockPlugins"]) {
        NSArray* stockPlugins = [[NSArray alloc] initWithObjects:
                                 @"de.sniperger.watchface.simple"
                                 @"de.sniperger.watchface.color"
                                 @"de.sniperger.watchface.weather"
                                 @"de.sniperger.watchface.chronograph",
                                 @"de.sniperger.watchface.xlarge",nil];
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
    
    NSLog(@"LockWatch: Searching for plugins...");
    NSString* pluginLocationString = @"/Library/Application Support/LockWatch/Watch Faces/";
    //NSString* pluginLocationString = [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/PlugIns/"];
    NSURL* pluginLocation = [NSURL fileURLWithPath:pluginLocationString];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    
    if ([contents count] < 1) {
        NSLog(@"No plugins found");
    }
    
    NSArray* defaultPlugins = [[NSArray alloc] initWithObjects:@"Simple.watchface", @"Color.watchface", @"Weather.watchface", @"Chronograph.watchface", @"X-Large.watchface", nil];
    [defaultPlugins enumerateObjectsUsingBlock:^(id defaultPlugin, NSUInteger i, BOOL* stop) {
        NSURL* filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", pluginLocationString, defaultPlugin]];
        NSBundle* plugin = [[NSBundle alloc] initWithURL:filePath];
        NSString* pluginIdentifier = [plugin bundleIdentifier];
        
        [loadedStockPluginsIndex setObject:plugin forKey:pluginIdentifier];
    }];
    
    stockPluginOrder = [defaults objectForKey:@"stockPlugins"];
    for (id object in stockPluginOrder) {
        NSBundle* plugin = loadedStockPluginsIndex[object];
        
        NSLog(@"LockWatch: %@", object);
        
        BOOL loaded = [plugin load];
        if (loaded) {
            [watchFacePlugins addObject:plugin];
            [watchFacePluginIdentifiers addObject:[plugin bundleIdentifier]];
        }
    }
    
    NSLog(@"LockWatchPrefs: %@", defaults);
}

/*static void loadStockPlugins() {
    NSURL* pluginLocation = [NSURL fileURLWithPath:@PluginFilePath];
    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
    
    NSMutableDictionary* loadedStockPluginsIndex = [[NSMutableDictionary alloc] init];
    
    NSArray* defaultPlugins = [[NSArray alloc] initWithObjects:@"Simple.watchface", nil];
    for (id object in defaultPlugins) {
    	NSURL* filePath = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", @PluginFilePath, object]];

		NSBundle* plugin = [[NSBundle alloc] initWithURL:filePath];
		BOOL loaded = [plugin load];
		
		if (loaded) {
			NSLog(@"LockWatch: %@", plugin);
		} else {
			NSLog(@"LockWatch: Failed to load plugin %@", object);
		}
	}
}*/

%ctor {
	defaults = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	
	loadStockPlugins();
}

%hook SBLockScreenViewController
- (void)viewWillAppear:(BOOL)arg1 {
	%orig;
	
	notificationController = [self _notificationController];
}

%end

%hook SBLockScreenNotificationListController 
- (void)_turnOnScreen {
	%orig;

	isReRenderAllowed = YES;
	[_lsView setFrame:[_lsView frame]];
	[_lsView layoutSubviews];
	[_lsView setNeedsDisplay];
}
%end

%hook SBLockScreenScrollView
-(id)initWithFrame:(CGRect)arg1 {
    id r = %orig;
    if (r) {
        _lsView = r;
        isReRenderAllowed = YES;
		defaults = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    }
    return r;
}
- (void)layoutSubviews {
	%orig;
	
	if (isReRenderAllowed) {
		isReRenderAllowed = NO;
		
		[scrollView removeFromSuperview];
		[scrollViewButton removeFromSuperview];
		
		CGSize screenSize = [UIScreen mainScreen].bounds.size;
		CGRect scrollViewRect = CGRectMake(0, screenSize.height/2 - (screenSize.height-100)/2, screenSize.width, screenSize.height-100);
		
		UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSimulateTap:)];
		UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewSimulateLongPress:)];
		
		
		//scrollView = [[LWScrollView alloc] initWithFrame:scrollViewRect];
		scrollView = [[LWScrollView alloc] initWithFrame: scrollViewRect withWatchFaces:watchFacePlugins isScaledDown:NO];
		scrollViewButton = [[UIButton alloc] initWithFrame:scrollViewRect];
		
		// DEBUG BACKGROUND COLORS
		//[scrollView setBackgroundColor:[UIColor redColor]];
		
		scrollView.longPressButton = scrollViewButton;
		[scrollView addSubview:scrollViewButton];
		
		//[scrollView addGestureRecognizer:tap];
		[scrollViewButton addGestureRecognizer:longPress];
		
		//[scrollView.customizationButton removeFromSuperview];
		//[scrollViewButton addSubview:scrollView.customizationButton];
		
		if (notificationController.hasAnyContent) {
			[scrollView setFrame:CGRectMake(screenSize.width, screenSize.height/2 - (screenSize.height-100)/2, screenSize.width, screenSize.height)];
			[self insertSubview:scrollView atIndex:0];
		} else {
			UIView* containerView = [[[[self subviews] objectAtIndex:2] subviews] objectAtIndex:3];
			[containerView addSubview:scrollView];
		}
	}
}

%new
- (void)scrollViewSimulateTap:(UITapGestureRecognizer*)sender {
	[scrollViewButton setAlpha:1];
}

%new
- (void)scrollViewSimulateLongPress:(UILongPressGestureRecognizer*)sender {
	if (sender.state == UIGestureRecognizerStateBegan){
		/*UIAlertView *alertView = [[UIAlertView alloc]
                           initWithTitle:@"DefaultStyle" 
                           message:[NSString stringWithFormat:@"%@", defaults]
                           delegate:self 
                           cancelButtonTitle:@"Cancel" 
                           otherButtonTitles:@"OK", nil];
		[alertView show];*/
		//[_lsView setScrollEnabled:NO];
		[scrollViewButton setAlpha:0];
		[scrollView scaleDown:sender];
	}
}

%end

%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
	return -1;
}
%end

__attribute__((constructor)) static void internalizer_init() {	
	defaults = [[NSDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PreferencesChangedCallback, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);
}