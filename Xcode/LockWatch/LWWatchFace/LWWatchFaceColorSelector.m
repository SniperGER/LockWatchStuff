//
//  LWWatchFaceColorSelector.m
//  LockWatch
//
//  Created by Janik Schmidt on 24.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFaceColorSelector.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceColorSelector

- (id)init {
    self = [super init];
    if (self) {
        //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        
        _colorSets = [[NSMutableArray alloc] init];
        
        if ([defaults objectForKey:@"activeColorSet"]) {
            _colorSets = [defaults objectForKey:@"activeColorSet"];
            
            _colorHex = [[NSMutableArray alloc] init];
            for (int i=0; i<[_colorSets count]; i++) {
                [_colorHex addObject:[_colorSets objectAtIndex:i][@"hex"]];
            }
        } else {
            _colorHex = [NSMutableArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
            NSArray* _colorHexNames = [NSArray arrayWithObjects:@"White", @"Red", @"Orange", @"Light Orange", @"Yellow", @"Green", @"Turquoise", @"Light Blue", @"Blue", @"Midnight Blue", @"Purple", @"Lavender", @"Pink", @"Vintage Rose",@"Walnut", @"Stone", @"Antique White", nil];
            
            for (int i=0; i<[_colorHex count]; i++) {
                NSMutableDictionary* singleColorDict = [[NSMutableDictionary alloc] init];
                [singleColorDict setObject:[_colorHex objectAtIndex:i] forKey:@"hex"];
                [singleColorDict setObject:NSLocalizedString([_colorHexNames objectAtIndex:i], nil) forKey:@"name"];
                [_colorSets addObject:singleColorDict];
            }
            [defaults setObject:_colorSets forKey:@"activeColorSet"];
            [defaults writeToFile:PreferencesFilePath atomically:YES];
            //[defaults synchronize];
        }
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame withSelectedColor:(NSString*)accentColorSelected withTarget:(id)target andAction:(SEL)tapAction {
    self = [super initWithFrame:frame];
    if (self) {
        //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        self.target = target;
        self.tapAction = tapAction;
        
        _colorSets = [[NSMutableArray alloc] init];
        
        if ([defaults objectForKey:@"activeColorSet"]) {
            _colorSets = [defaults objectForKey:@"activeColorSet"];
            
            _colorHex = [[NSMutableArray alloc] init];
            for (int i=0; i<[_colorSets count]; i++) {
                NSString* colorHex = [[_colorSets objectAtIndex:i] objectForKey:@"hex"];
                [_colorHex addObject:colorHex];
            }
        } else {
            _colorHex = [NSMutableArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
            NSArray* _colorHexNames = [NSArray arrayWithObjects:@"White", @"Red", @"Orange", @"Light Orange", @"Yellow", @"Green", @"Turquoise", @"Light Blue", @"Blue", @"Midnight Blue", @"Purple", @"Lavender", @"Pink", @"Vintage Rose",@"Walnut", @"Stone", @"Antique White", nil];
            
            for (int i=0; i<[_colorHex count]; i++) {
                NSMutableDictionary* singleColorDict = [[NSMutableDictionary alloc] init];
                [singleColorDict setObject:[_colorHex objectAtIndex:i] forKey:@"hex"];
                [singleColorDict setObject:NSLocalizedString([_colorHexNames objectAtIndex:i], nil) forKey:@"name"];
                [_colorSets addObject:singleColorDict];
            }
            [defaults setObject:_colorSets forKey:@"activeColorSet"];
            [defaults writeToFile:PreferencesFilePath atomically:YES];
            //[defaults synchronize];
        }
        
        [self setContentSize:CGSizeMake(50, [_colorHex count]*55-5)];
        for (int i=0; i<[_colorHex count]; i++) {
            UIView* colorView = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, 50, 50)];
            //[colorView.layer setBorderWidth:3.0];
            //[colorView.layer setBorderColor:[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor];
            [colorView.layer setBorderColor:[UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor];
            if ([(NSString*)[_colorHex objectAtIndex:i] isEqualToString:[accentColorSelected uppercaseString]]) {
                [colorView.layer setBorderWidth:3];
            }
            [colorView.layer setCornerRadius:6.0];
            colorView.backgroundColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0];
            [colorView setTag:900+i];
            
            UIView* colorViewInner = [[UIView alloc] initWithFrame:CGRectMake(6, 6, 38, 38)];
            [colorViewInner setBackgroundColor:[self colorFromHexString:[_colorHex objectAtIndex:i]]];
            [colorView addSubview:colorViewInner];
            
            [self addSubview:colorView];
        }
        [self setShowsVerticalScrollIndicator:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(testEvent)
                                                     name:@"testEvent"
                                                   object:nil];
    }
    
    return self;
}

- (void)testEvent {
    //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    _colorSets = [defaults objectForKey:@"activeColorSet"];
    _colorHex = [[NSMutableArray alloc] init];
    for (int i=0; i<[_colorSets count]; i++) {
        [_colorHex addObject:[_colorSets objectAtIndex:i][@"hex"]];
    }
    
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setContentSize:CGSizeMake(50, [_colorHex count]*55-5)];
    for (int i=0; i<[_colorHex count]; i++) {
        UIView* colorView = [[UIView alloc] initWithFrame:CGRectMake(0, i*55, 50, 50)];
        //[colorView.layer setBorderWidth:3.0];
        //[colorView.layer setBorderColor:[UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0].CGColor];
        [colorView.layer setBorderColor:[UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor];
        
        [colorView.layer setCornerRadius:6.0];
        colorView.backgroundColor = [UIColor colorWithRed:(64.0/255.0) green:(64.0/255.0) blue:(64.0/255.0) alpha:1.0];
        [colorView setTag:900+i];
        
        UIView* colorViewInner = [[UIView alloc] initWithFrame:CGRectMake(6, 6, 38, 38)];
        //[colorViewInner setBackgroundColor:[self colorFromHexString:[_colorHexArray objectAtIndex:i]]];
        [colorView addSubview:colorViewInner];
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self.target action:self.tapAction];
        [colorView addGestureRecognizer:tap];
        
        [self addSubview:colorView];
    }
	[defaults writeToFile:PreferencesFilePath atomically:YES];
}

- (UIColor*) colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
