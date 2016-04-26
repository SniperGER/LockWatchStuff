#import "UIBackdropView.h"
#import "ViewController.h"
#define HBLogError NSLog

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
//@property (nonatomic,readonly) UIImage * currentNowPlayingArtwork;
-(UIImage *)currentNowPlayingArtwork;
@end

@interface MPUSystemMediaControlsViewController : UIViewController
- (UIView*)artworkView;
@end


UIView* mainView;
SBLockScreenNotificationListController* notificationController;
id nowPlayingArtView;

BOOL shouldShowWatchFace = YES;

BOOL hasResetGestureRecognizer = NO;

%hook SBLockScreenScrollView

-(BOOL)deliversTouchesForGesturesToSuperview {
    return NO;
}

%end

%hook SBLockScreenViewController

- (void)viewWillAppear:(BOOL)arg1 {
    %orig;
    notificationController = [self _notificationController];
}

- (void)viewDidLayoutSubviews {
    %orig;
    
    
    UIView *lockScreenView = (UIView *)self.lockScreenView;
    SBFLockScreenDateView *dateView = [lockScreenView valueForKey:@"dateView"];
    
    [mainView removeFromSuperview];
    mainView = [[UIView alloc] initWithFrame:CGRectMake(-[[UIScreen mainScreen] bounds].size.width,-dateView.frame.origin.y,[[UIScreen mainScreen] bounds].size.width*3,[[UIScreen mainScreen] bounds].size.height)];
    //mainView.backgroundColor = [UIColor greenColor];
    _UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForStyle:1];
    _UIBackdropView* blurredView = [[_UIBackdropView alloc] initWithFrame:CGRectZero
                                                  autosizesToFitSuperview:YES settings:settings];
    [mainView insertSubview:blurredView atIndex:0];
    
    ViewController* testViewController = [[ViewController alloc] init];
    
    CGRect lwFrame = testViewController.view.frame;
    lwFrame.origin.x = [[UIScreen mainScreen] bounds].size.width;
    testViewController.view.frame = lwFrame;
    [mainView addSubview:testViewController.view];
    
    id vc = [%c(VolumeControl) sharedVolumeControl];
    BOOL musicIsPlaying = [vc _isMusicPlayingSomewhere];
    
    //id mpu = %c(MPUNowPlayingController);
    //NSLog(@"[MPU] %@", nowPlayingArtView);
    
    shouldShowWatchFace = (!musicIsPlaying && ![nowPlayingArtView image]);
    
    //dateView.backgroundColor = [UIColor magentaColor];
    CGRect dvFrame = dateView.frame;
    dvFrame.size.height = [[UIScreen mainScreen] bounds].size.height-(2*dvFrame.origin.y)-72.5;
    dateView.frame = dvFrame;
    
    if (shouldShowWatchFace) {
        if (notificationController.hasAnyContent) {
            [dateView setUserInteractionEnabled:NO];
        } else {
            [dateView insertSubview:mainView atIndex:0];
            [dateView setUserInteractionEnabled:YES];
        }
    } else {
        [dateView setUserInteractionEnabled:NO];
    }
}

%end

%hook SBBacklightController
- (double)defaultLockScreenDimInterval {
    return -1;
}
%end

%hook SBLockScreenNotificationListController

- (void)_updateModelAndViewForAdditionOfItem:(SBAwayListItem*)item {
    %orig;
//    NSLog(@"[SBLockScreenNotificationListController] _newItemForBulletin: %@, %d", arg1, arg2);
    mainView.alpha = 0;
}

- (void)_updateModelForRemovalOfItem:(SBAwayListItem*)item updateView:(BOOL)update {
    %orig;
    
    int notificationCount = (int)[[notificationController valueForKey:@"listItems"] count];
    if (notificationCount > 0) {
        // Do nothing, there is still at least one notification
    } else {
        // Make the green square appear again
        mainView.alpha = 1;
    }
}

%end

%hook MPUNowPlayingController

    -(void)_updatePlaybackState {
        //NSLog(@"[MPU] Updating stuff");
        //nowPlayingArtView = [self currentNowPlayingArtwork];
        if ([self currentNowPlayingArtwork]) {
            mainView.alpha = 0;
        }
    }

/*-(BOOL)shouldUpdateNowPlayingArtwork {
    return YES;
}*/
    
%end

%hook MPUSystemMediaControlsViewController

-(void)nowPlayingController:(id)arg1 playbackStateDidChange:(BOOL)arg2 {
    %orig;
    
    NSLog(@"[MPUSystemMediaControlsViewController] PLAYBACK artworkView %@", [(UIImageView*)[self artworkView] image]);
    nowPlayingArtView = [self artworkView];
}

-(void)nowPlayingController:(id)arg1 nowPlayingApplicationDidChange:(id)arg2 {
    %orig;
    
    NSLog(@"[MPUSystemMediaControlsViewController] APP artworkView %@", [(UIImageView*)[self artworkView] image]);
    nowPlayingArtView = [self artworkView];
}

%end
