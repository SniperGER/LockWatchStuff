#import <UIKit/UIKit.h>
#import <UIKit/UIImageView.h>
#import <UIKit/UIButton.h>
#import <UIKit/UIScrollView.h>
#import <UIKit/UIAlertView.h>
#import <UIKit/UIApplication.h>
#import <UIKit/UILabel.h>
#import <UIKit/UIWindow.h>
#import <UIKit/UIGraphics.h>
#import "substrate.h"
#import "Headers.h"
#import "LWScrollView.h"

#define offsetScale (220.0/188.0)

@interface SBLockScreenViewController : NSObject
+(id)sharedInstance;
@end

@interface SBLockScreenView : UIView <UIScrollViewDelegate>
- (void)scrollToPage:(long long)arg1 animated:(BOOL)arg2;
@end

SBLockScreenScrollView* wind;
SBLockScreenView* sbLSView;

%hook SBLockScreenView
-(void)setCustomSlideToUnlockText:(id)arg1 {
	%orig(arg1);
	sbLSView = self;

	SBLockScreenViewController* lockViewController = MSHookIvar<SBLockScreenViewController*>([%c(SBLockScreenManager) sharedInstance], "_lockScreenViewController");
	SBLockScreenView* lockView = MSHookIvar<SBLockScreenView*>(lockViewController, "_view");
	wind = MSHookIvar<SBLockScreenScrollView*>(lockView, "_foregroundScrollView");

    NSArray* watchFaces = [NSArray arrayWithObjects:@"simple",@"color", @"weather", @"chrono", @"xlarge", nil];
    NSArray* watchFaceNames = [NSArray arrayWithObjects:@"SIMPLE",@"COLOR", @"WEATHER", @"CHRONOGRAPH", @"X-LARGE", nil];

	LWScrollView* existingView = (LWScrollView*)[sbLSView viewWithTag:99];
	if (existingView == nil) {
		// Create watch faces inside LWScrollView
	    CGRect scrollViewRect = CGRectMake(-(312*offsetScale/2 - [[UIScreen mainScreen] bounds].size.width/2), -(390*offsetScale/2 - [[UIScreen mainScreen] bounds].size.height/2), 312*offsetScale + 20, 390*offsetScale);
	    LWScrollView* watchScrollView = [[LWScrollView alloc] initWithFrame:scrollViewRect withWatchFaces:watchFaces withWatchFaceNames:watchFaceNames];
		watchScrollView.tag = 99;
		watchScrollView.delegate = self;

	    [sbLSView insertSubview:watchScrollView.customizeButton atIndex:100];
	    [sbLSView insertSubview:watchScrollView atIndex:100];
	    
	}
}

-(void) scrollViewDidEndDecelerating:(LWScrollView *)scrollView {
    CGFloat width = 312*offsetScale + 20;
    int page = (scrollView.contentOffset.x + (0.5f * width)) / width;
    scrollView.currentIndex = page;
    if (page < [scrollView.watchFaces count]) {
        //NSLog(@"%@", [scrollView.watchFaces objectAtIndex:page]);
    }
}

%end

%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
	return -1;
}
%end