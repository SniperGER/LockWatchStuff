//
//  LWInterface.h
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 17.02.16.
//
//

#import <UIKit/UIKit.h>
#import "LWScrollView.h"


@interface LWInterface : UIView {
    
    bool scaledDown;
    NSString* pluginLocationString;
    NSArray* stockPluginBundleNames;
    NSArray* stockPluginIdentifiers;
    
    NSSet* watchFaceIdentifiers;
    NSMutableArray* watchFacePlugins;
    NSMutableArray* watchFacePluginIdentifiers;
    
    NSMutableArray* stockPluginOrder;
    NSMutableDictionary* stockPluginEnabled;
    
    NSMutableArray* externalPluginOrder;
    NSMutableDictionary* externalPluginEnabled;
    
    NSMutableArray* knownPlugins;
    
    //LWScrollView* scroll;
}

- (void)loadStockPlugins;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;
@property LWScrollView* scroll;

@end
