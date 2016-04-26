#include "LockWatchRootListController.h"


@implementation LockWatchRootListController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
    self.navigationController.navigationController.navigationBar.tintColor = [self colorFromHexString:@"#ff9500"];
    self.navigationController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    
    prevStatusStyle = [[UIApplication sharedApplication] statusBarStyle];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}
    
    [self setBackgroundColor:[UIColor darkThemeBaseColor]];

	return _specifiers;
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
