//
//  Tweak.xm
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 17.02.16.
//
//

#define HBLogError NSLog
#define PREFERENCES_PATH @"var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#import "Tweak.h"

NSMutableDictionary *settings;
bool LSTimeDate = YES;

bool tweakEnabled = YES;
bool LSBlurBG = YES;
bool LSTimeout = YES;

static void ReloadSettings()
{
	if(kCFCoreFoundationVersionNumber > 900.00){ // iOS 8.0
		
		[settings release];
		CFStringRef appID2 = CFSTR("de.sniperger.LockWatch");
		CFArrayRef keyList = CFPreferencesCopyKeyList(appID2, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
		if(keyList)
		{
			settings = (NSMutableDictionary *)CFPreferencesCopyMultiple(keyList, appID2, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
			CFRelease(keyList);
		} else
		{
			settings = nil;
		}
	}
	else
	{
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFERENCES_PATH]; //Load settings the old way.
	}
	
	if (settings == nil) {
		//settings = @{ @"enabled": YES };
		settings = [NSDictionary dictionaryWithObjectsAndKeys:
					@YES, @"tweakEnabled",
					@YES, @"LSBlurBG",
					@YES, @"LSTimeout",
					nil];
		[settings writeToFile:PREFERENCES_PATH atomically:YES];
	}
	
	if (settings[@"tweakEnabled"]) {
		tweakEnabled = [settings[@"tweakEnabled"] boolValue];
	} else {
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"tweakEnabled"];
	}
	
	if (settings[@"LSBlurBG"]) {
		tweakEnabled = [settings[@"LSBlurBG"] boolValue];
	} else {
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"LSBlurBG"];
	}
	
	if (settings[@"LSTimeout"]) {
		tweakEnabled = [settings[@"LSTimeout"] boolValue];
	} else {
		[settings setValue:[NSNumber numberWithBool:YES] forKey:@"LSTimeout"];
	}
	[settings writeToFile:PREFERENCES_PATH atomically:YES];
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	ReloadSettings();
}


%group main

%hook SBLockScreenViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    notificationController = [self _notificationController];
	
	if ([settings[@"tweakEnabled"] boolValue]) {
		lockWatch = [[LWInterface alloc] initWithFrame:CGRectMake(0,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	} else {
		lockWatch = nil;
		[touchSimulatorButton removeGestureRecognizer:longPress];
		longPress = nil;
		[touchSimulatorButton removeGestureRecognizer:tap];
		tap = nil;
		
		[blurredView removeFromSuperview];
		[lockWatch removeFromSuperview];
		[touchSimulatorButton removeFromSuperview];
		[mainView removeFromSuperview];

	}
}

- (void)viewDidLayoutSubviews {
    %orig;
	
	[touchSimulatorButton removeGestureRecognizer:longPress];
	longPress = nil;
	[touchSimulatorButton removeGestureRecognizer:tap];
	tap = nil;
	
	[blurredView removeFromSuperview];
	[lockWatch removeFromSuperview];
	[touchSimulatorButton removeFromSuperview];
	[mainView removeFromSuperview];
	
	if ([settings[@"tweakEnabled"] boolValue]) {
		UIView *lockScreenView = (UIView *)self.lockScreenView;
		SBFLockScreenDateView *dateView = [lockScreenView valueForKey:@"dateView"];
		
		mainView = [[UIView alloc] initWithFrame:CGRectMake(0,-dateView.frame.origin.y,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
		[mainView insertSubview:lockWatch atIndex:0];
		
		_UIBackdropViewSettings *BVsettings = [_UIBackdropViewSettings settingsForStyle:1];
		blurredView = [[_UIBackdropView alloc] initWithFrame:CGRectZero
													  autosizesToFitSuperview:YES settings:BVsettings];
		
		//if (!lockWatch.scroll.scaledDown) {
		touchSimulatorButton = [[UIButton alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width/2 - 312.0/2, [[UIScreen mainScreen] bounds].size.height/2 - 390.0/2, 312, 390)];
		//[touchSimulatorButton setBackgroundColor:[UIColor greenColor]];
		[touchSimulatorButton addTarget:self
					 action:@selector(buttonTouchDown)
		   forControlEvents:UIControlEventTouchDown];
		
		tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonPressed)];
		[touchSimulatorButton addGestureRecognizer:tap];
		
		longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(buttonLongPress)];
		[mainView addGestureRecognizer:longPress];
		 
		[mainView addSubview:touchSimulatorButton];
		//}
		
		id vc = [%c(VolumeControl) sharedVolumeControl];
		BOOL musicIsPlaying = [vc _isMusicPlayingSomewhere];
		
		//id mpu = %c(MPUNowPlayingController);
		//NSLog(@"[MPU] %@", nowPlayingArtView);
		
		bool shouldShowWatchFace = (!musicIsPlaying && ![nowPlayingArtView image]);
		
		//dateView.backgroundColor = [UIColor magentaColor];
		CGRect dvFrame = dateView.frame;
		dvFrame.size.height = [[UIScreen mainScreen] bounds].size.height-(2*dvFrame.origin.y)-72.5;
		dateView.frame = dvFrame;
		
		
		if (shouldShowWatchFace) {
			if (notificationController.hasAnyContent) {
				[dateView setUserInteractionEnabled:NO];
			} else {
				[dateView insertSubview:mainView atIndex:0];
				
				if ([settings[@"LSBlurBG"] boolValue]) {
					[lockScreenView insertSubview:blurredView atIndex:0];
				}
				[dateView setUserInteractionEnabled:YES];
			}
		} else {
			[dateView setUserInteractionEnabled:NO];
		}
		
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		
		[center addObserverForName:@"scaledUp"
							object:nil
							 queue:[NSOperationQueue mainQueue]
						usingBlock:^(NSNotification *note){
							if (!lockWatch.scroll.scaledDown) {
								NSLog(@"[LockWatch] Button appears");
								[touchSimulatorButton setAlpha:1];
							}
						}];
		[center addObserverForName:@"scaledUpCustomize"
							object:nil
							 queue:[NSOperationQueue mainQueue]
						usingBlock:^(NSNotification *note){
							[touchSimulatorButton setAlpha:0];
						}];
		
		weather = [[LWWeatherDataController alloc] init];
	}
}

%new
- (void)buttonTouchDown {
	//NSLog(@"[LockWatch] %@", lockWatch.scroll);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"watchface.touchDown" object:self userInfo:nil];
	if (lockWatch.scroll.currentWatchFace && !lockWatch.scroll.scaledDown) {
		LWWatchFace* watchface = lockWatch.scroll.currentWatchFace;
		if (watchface.allowTouchedZoom) {
			[watchface touchDownEvent];
		}
	}
}

%new
- (void)buttonPressed {
	//NSLog(@"[LockWatch] Button pressed");
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"watchface.touchUp" object:self userInfo:nil];
	if (lockWatch.scroll.currentWatchFace && !lockWatch.scroll.scaledDown) {
		LWWatchFace* watchface = lockWatch.scroll.currentWatchFace;
		if (watchface.allowTouchedZoom) {
			[watchface touchUpEvent];
		}
	}
}

%new
- (void)buttonLongPress {
	//NSLog(@"[LockWatch] Button long pressed");
	[touchSimulatorButton setAlpha:0];
	[lockWatch.scroll _scaleDown];
	if (lockWatch.scroll.currentWatchFace) {
		LWWatchFace* watchface = lockWatch.scroll.currentWatchFace;
		[watchface touchUpEvent];
	}
}

%end


%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
	if ([settings[@"tweakEnabled"] boolValue] && [settings[@"LSTimeout"] boolValue]) {
		return %orig;
	}
    return -1;
}
%end

/*%hook SBLockScreenScrollView

-(BOOL)deliversTouchesForGesturesToSuperview {
	return NO;
}

%end*/

%hook SBLockScreenViewController
- (BOOL)isBounceEnabledForPresentingController:(id)fp8 locationInWindow:(struct CGPoint)fp12
{
	if ([settings[@"tweakEnabled"] boolValue]) {
		return NO;
	} else {
		return %orig;
	}
}
%end

%end

%ctor {
	ReloadSettings();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("de.sniperger.LockWatch.preferences"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	if ([settings[@"tweakEnabled"] boolValue]) {
		lockWatch = [[LWInterface alloc] initWithFrame:CGRectMake(0,0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
	}
	%init(main);
}
