//
//  LockWatchPrivacyListController.m
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 21.02.16.
//
//

#define PREFERENCES_FILE @"var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#import "LockWatchPrivacyListController.h"
#define LocalizationsDirectory @"/var/mobile/Library/Application Support/LockWatch/Localizations"

@implementation LockWatchPrivacyListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		NSArray* specifiers_pre = [[self loadSpecifiersFromPlistName:@"Privacy" target:self] retain];
		NSMutableArray *specifiers_strings = [[NSMutableArray alloc] init];
		
		for (int i=0; i<[specifiers_pre count]; i++) {
			PSSpecifier* item = (PSSpecifier*)[specifiers_pre objectAtIndex:i];
			NSString* itemName = [item name];
			
			//NSLog(@"[LockWatch] item: %@", item);
			
			[item setName:[[NSBundle bundleWithPath:LocalizationsDirectory]localizedStringForKey:itemName value:itemName table:nil]];
			[specifiers_strings addObject:item];
		}
		_specifiers = specifiers_strings;
	}
	
	return _specifiers;
}

- (NSNumber *)readWeatherValue:(PSSpecifier *)specifier {
	//NSLog(@"%@", [tweakSettings[@"stockPluginsEnabled"][[specifier userInfo][@"bundleIdentifier"]] boolValue]);
	tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
	return [NSNumber numberWithBool:[tweakSettings[@"weather"][@"UseLocation"] boolValue]];
}

- (void)setWeatherValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
	NSMutableDictionary* weather = tweakSettings[@"weather"];
	//NSLog(@"%@", stockPluginsEnabled);
	[weather setValue:value forKey:@"UseLocation"];
	[tweakSettings setObject:weather forKey:@"weather"];
	[tweakSettings writeToFile:PREFERENCES_FILE atomically:YES];
	
	//NSLog(@"%@", tweakSettings);
}

@end
