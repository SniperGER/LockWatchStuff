#include "LockWatchRootListController.h"
#define PREFERENCES_FILE @"var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

#define LocalizationsDirectory @"/var/mobile/Library/Application Support/LockWatch/Localizations"

@implementation LockWatchRootListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	if ( ![(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
		self.navigationController.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#ff9500"];
		self.navigationController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
		self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
		
		prevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	}
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationController.navigationBar.tintColor = nil;
    self.navigationController.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationController.navigationBar.titleTextAttributes = nil;

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}


- (NSArray *)specifiers {
	if (!_specifiers) {
		NSArray* specifiers_pre = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		NSMutableArray *specifiers_strings = [[NSMutableArray alloc] init];
		
		for (int i=0; i<[specifiers_pre count]; i++) {
			PSSpecifier* item = (PSSpecifier*)[specifiers_pre objectAtIndex:i];
			NSString* itemName = [item name];
			
			//NSLog(@"[LockWatch] item: %@", item);
			
			[item setName:[[NSBundle bundleWithPath:LocalizationsDirectory]localizedStringForKey:itemName value:itemName table:nil]];
			[specifiers_strings addObject:item];
		}
		_specifiers = specifiers_strings;
		tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
		// Weather - Use Fahrenheit
		/*PSSpecifier* weatherFahrenheit = [PSSpecifier preferenceSpecifierNamed:@"Use Fahrenheit"
																	target:self
																	   set:@selector(setWeatherValue:specifier:)
																	   get:@selector(readWeatherValue:)
																	detail:Nil
																	  cell:PSSwitchCell
																	  edit:Nil];
		[weatherFahrenheit setProperty:@YES forKey:@"enabled"];
		
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		[weatherFahrenheit setUserInfo:dict];
		[_specifiers addObject:weatherFahrenheit];*/
	}
	
    [self setBackgroundColor:[UIColor darkThemeBaseColor]];

	return _specifiers;
}

- (NSNumber *)readWeatherValue:(PSSpecifier *)specifier {
	//NSLog(@"%@", [tweakSettings[@"stockPluginsEnabled"][[specifier userInfo][@"bundleIdentifier"]] boolValue]);
	tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
	return [NSNumber numberWithBool:[tweakSettings[@"weather"][@"UseFahrenheit"] boolValue]];
}

- (void)setWeatherValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
	NSMutableDictionary* weather = tweakSettings[@"weather"];
	//NSLog(@"%@", stockPluginsEnabled);
	[weather setValue:value forKey:@"UseFahrenheit"];
	[tweakSettings setObject:weather forKey:@"weather"];
	[tweakSettings writeToFile:PREFERENCES_FILE atomically:YES];
	
	//NSLog(@"%@", tweakSettings);
}

- (void)killSpringBoard {
	system("killall -9 SpringBoard");
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
