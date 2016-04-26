//
//  LockWatchGraphicsListController.m
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 22.02.16.
//
//

#import "LockWatchGraphicsListController.h"
#define LocalizationsDirectory @"/var/mobile/Library/Application Support/LockWatch/Localizations"

@implementation LockWatchGraphicsListController

- (NSArray *)specifiers {
	if (!_specifiers) {
			NSArray* specifiers_pre = [[self loadSpecifiersFromPlistName:@"Appearance" target:self] retain];
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

@end
