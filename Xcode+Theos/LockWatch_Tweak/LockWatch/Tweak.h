//
//  Tweak.h
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 17.02.16.
//
//

#import "UIBackdropView.h"
#import "LWInterface.h"
#import "TouchDownGestureRecognizer.h"
#import "LWWeatherDataController.h"
#import "LWWatchFace.h"



@interface SBLockScreenNotificationListController : UIView
@property (assign,nonatomic) BOOL hasAnyContent;
@end

@interface SBFLockScreenDateView : UIView
@end

@interface SBLockScreenScrollView : UIScrollView
@end

@interface SBLockScreenViewController : UITableViewController
- (id)lockScreenView;
- (SBLockScreenNotificationListController*)_notificationController;
@end

@interface VolumeControl : NSObject
+(id)sharedVolumeControl;
-(BOOL)_isMusicPlayingSomewhere;
@end

@interface SBAwayListItem : NSObject
@end

@interface MPUNowPlayingController : NSObject
-(UIImage *)currentNowPlayingArtwork;
@end

@interface MPUSystemMediaControlsViewController : UIViewController
- (UIView*)artworkView;
@end

@interface _UILegibilityLabel : UIView
@end

// ------------------------- //

UIView* mainView;
_UIBackdropView* blurredView;
SBLockScreenNotificationListController* notificationController;
id nowPlayingArtView;
LWInterface* lockWatch;
UIButton* touchSimulatorButton;
UITapGestureRecognizer* tap;
TouchDownGestureRecognizer* touchDown;
UILongPressGestureRecognizer* longPress;
LWWeatherDataController* weather;

BOOL shouldShowWatchFace = YES;
BOOL hasResetGestureRecognizer = NO;