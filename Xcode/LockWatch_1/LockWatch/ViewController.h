//
//  ViewController.h
//  LockWatch
//
//  Created by Janik Schmidt on 28.11.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LWScrollView.h"

@interface ViewController : UIViewController {
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

@property (strong, nonatomic) IBOutlet UIButton *settingsButton;

@end

