#include "LockWatchWatchFaceListController.h"
#include "colors.h"
#define PREFERENCES_FILE @"var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#define LocalizationsDirectory @"/var/mobile/Library/Application Support/LockWatch/Localizations"

@implementation LockWatchWatchFaceListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#ff9500"];
    self.navigationController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    //prevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
	if ( ![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
}

- (id)specifiers {
    if (!_specifiers) {
		NSArray* specifiers_pre = [[self loadSpecifiersFromPlistName:@"WatchFaces" target:self] retain];
		NSMutableArray *specifiers_strings = [[NSMutableArray alloc] init];
		
		for (int i=0; i<[specifiers_pre count]; i++) {
			PSSpecifier* item = (PSSpecifier*)[specifiers_pre objectAtIndex:i];
			NSString* itemName = [item name];
			
			//NSLog(@"[LockWatch] item: %@", item);
			
			[item setName:[[NSBundle bundleWithPath:LocalizationsDirectory]localizedStringForKey:itemName value:itemName table:nil]];
			[specifiers_strings addObject:item];
		}
		_specifiers = specifiers_strings;
		
		
		
        NSMutableArray* specifiers = [[NSMutableArray alloc] init];
        tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
        NSArray* stockPluginOrder = tweakSettings[@"stockPlugins"];
        
        NSString* pluginLocationString = pluginLocationString = @"/private/var/mobile/Library/LockWatch/Watch Faces/";
        NSURL* pluginLocation = [[NSURL fileURLWithPath:pluginLocationString] URLByResolvingSymlinksInPath];
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:pluginLocation includingPropertiesForKeys:@[NSFileType] options:(NSDirectoryEnumerationOptions)0 error:nil];
        
        NSMutableDictionary* loadedStockPluginsIndex = [[NSMutableDictionary alloc] init];
		NSLog(@"[LockWatch] %@", contents);
        if ([contents count] < 1) {
            NSLog(@"[LockWatch] No plugins found");
        } else {
            [contents enumerateObjectsUsingBlock:^(id defaultPlugin, NSUInteger i, BOOL* stop) {
                //NSURL* filePath = [NSURL fileURLWithPath:defaultPlugin];
                NSBundle* plugin = [[NSBundle alloc] initWithURL:defaultPlugin];
                //NSLog(@"%@", [plugin localizedInfoDictionary][@"CFBundleDisplayName"]);
                if (plugin && [plugin bundleIdentifier]) {
                    NSString* pluginIdentifier = [plugin bundleIdentifier];
                    [loadedStockPluginsIndex setObject:plugin forKey:pluginIdentifier];
                }
            }];
            for (id object in stockPluginOrder) {
                NSBundle* plugin = loadedStockPluginsIndex[object];
                if (plugin) {
                PSSpecifier* testSpecifier = [PSSpecifier preferenceSpecifierNamed:[plugin localizedInfoDictionary][@"CFBundleDisplayName"]
                                                                            target:self
                                                                               set:@selector(setToggleValue:specifier:)
                                                                               get:@selector(readToggleValue:)
                                                                            detail:Nil
                                                                              cell:PSSwitchCell
                                                                              edit:Nil];
                [testSpecifier setProperty:@YES forKey:@"enabled"];
                
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[plugin bundleIdentifier] forKey:@"bundleIdentifier"];
                [testSpecifier setUserInfo:dict];
                [specifiers addObject:testSpecifier];
                }
            }
        }
		
		for (int i=0; i<[specifiers count]; i++) {
			[_specifiers addObject:[specifiers objectAtIndex:i]];
		}
		
//        _specifiers += specifiers;
    }
    return _specifiers;
}

- (BOOL)getWatchFaceEnabled {
    return YES;
}
- (NSNumber *)readToggleValue:(PSSpecifier *)specifier {
    //NSLog(@"%@", [tweakSettings[@"stockPluginsEnabled"][[specifier userInfo][@"bundleIdentifier"]] boolValue]);
    return [NSNumber numberWithBool:[tweakSettings[@"stockPluginsEnabled"][[specifier userInfo][@"bundleIdentifier"]] boolValue]];
}

- (void)setToggleValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
    tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
    NSMutableDictionary* stockPluginsEnabled = tweakSettings[@"stockPluginsEnabled"];
    //NSLog(@"%@", stockPluginsEnabled);
    [stockPluginsEnabled setValue:value forKey:[specifier userInfo][@"bundleIdentifier"]];
    [tweakSettings setObject:stockPluginsEnabled forKey:@"stockPluginsEnabled"];
    [tweakSettings writeToFile:PREFERENCES_FILE atomically:YES];
    
    //NSLog(@"%@", tweakSettings);
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
