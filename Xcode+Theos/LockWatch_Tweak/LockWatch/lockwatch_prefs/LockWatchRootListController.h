#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>
#import "colors.h"

@interface LockWatchRootListController : PSListController {
    UIStatusBarStyle prevStatusStyle;
	NSMutableDictionary* tweakSettings;
}

@end
