//
//  ViewController.h
//  LockWatch
//
//  Created by Janik Schmidt on 23.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWScrollView.h"

@interface ViewController : UIViewController {

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
    
    LWScrollView* scroll;
    
}

- (void)loadStockPlugins;
@property (strong, nonatomic) IBOutlet UIButton *settingsButton;

@end

