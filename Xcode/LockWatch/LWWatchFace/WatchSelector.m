//
//  WatchSelector.m
//  LockWatch
//
//  Created by Janik Schmidt on 28.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

#import "WatchSelector.h"

@implementation WatchSelector

int currentIndex = 0;

- (id)initWithFrame:(CGRect)frame type:(NSString*)type items:(NSMutableArray*)items action:(NSString*)action {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.type = type;
        self.items = items;
        //self.action = action;
        
        if ([type isEqualToString:@"detail"]) {
            [self setContentSize:CGSizeMake(312, 4*390)];
            
            WatchScrollBar* scrollBar = [self scrollBar];
            [scrollBar setScrollBarHeight:(390/self.contentSize.height)*75];
            
            self.items = [[NSMutableArray alloc] init];
            for (int i=0; i<4; i++) {
                [self.items addObject:[NSNumber numberWithInt:800+i]];
            }
        } else if ([type isEqualToString:@"color"]) {
            //NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
			NSMutableDictionary* defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
            
            self.items = [[NSMutableArray alloc] init];
            
            if ([defaults objectForKey:@"activeColorSet"]) {
                self.items = [defaults objectForKey:@"activeColorSet"];
                
                NSMutableArray* colorHex = [[NSMutableArray alloc] init];
                for (int i=0; i<[self.items count]; i++) {
                    [colorHex addObject:[self.items objectAtIndex:i][@"hex"]];
                }
            } else {
                NSMutableArray* colorHex = [NSMutableArray arrayWithObjects:@"#AAAAAA", @"#E00A23", @"#FF512F", @"#FF9500", @"#FFEE31", @"#8CE328", @"#9ED5CC", @"#69C5DD", @"#18B5FC", @"#5F84BF", @"#997BF7", @"#B29AA6", @"#FF5963", @"#F4ACA5", @"#B08663", @"#AF9980", @"#D4B694", nil];
                NSArray* colorHexNames = [NSArray arrayWithObjects:@"White", @"Red", @"Orange", @"Light Orange", @"Yellow", @"Green", @"Turquoise", @"Light Blue", @"Blue", @"Midnight Blue", @"Purple", @"Lavender", @"Pink", @"Vintage Rose",@"Walnut", @"Stone", @"Antique White", nil];
                
                for (int i=0; i<[colorHex count]; i++) {
                    NSMutableDictionary* singleColorDict = [[NSMutableDictionary alloc] init];
                    [singleColorDict setObject:[colorHex objectAtIndex:i] forKey:@"hex"];
                    [singleColorDict setObject:NSLocalizedString([colorHexNames objectAtIndex:i], nil) forKey:@"name"];
                    [self.items addObject:singleColorDict];
                }
                [defaults setObject:self.items forKey:@"activeColorSet"];
                [defaults writeToFile:PreferencesFilePath atomically:YES];
                //[defaults synchronize];
            }
            
            [[self selectionTarget] performSelector:self.action withObject:[self.items objectAtIndex:self.selectedIndex][@"hex"]];
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            [dict setValue:[NSNumber numberWithInt:self.selectedIndex] forKey:@"scrollViewPage"];
            [dict setObject:self.items forKey:@"colorSets"];
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(setActiveColorSet:)
                                                         name:@"setActiveColorSet"
                                                       object:nil];
            
            [self.nameLabel setContent:dict];
            [self setContentSize:CGSizeMake(312, [self.items count]*390)];
            
            WatchScrollBar* scrollBar = [self scrollBar];
            [scrollBar setScrollBarHeight:(390/self.contentSize.height)*75];
        } else if ([type isEqualToString:@"misc"]) {
            
        }
        
        
        [self setPagingEnabled:YES];
        [self setDelegate:self];
        
        
        
        [self setContentOffset:CGPointMake(0, _selectedIndex*390)];
    }
    
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat page = (scrollView.contentOffset.y / 390);
    CGFloat pageProgress = 1+(page - (int)page-1);
    
    if (pageProgress < 0.5) {
        page = floorf(page);
    } else {
        page = ceilf(page);
    }
    int _page = (int)page;
    
    if (_page >=0 && page <[self.items count]) {
        if (page != currentIndex) {
            currentIndex = _page;
            //[target reRenderExperimental:[_colorHex objectAtIndex:_page]];
            if ([self.type isEqualToString:@"detail"]) {
                [[self selectionTarget] performSelector:self.action withObject:[self.items objectAtIndex:_page]];
            } else if ([self.type isEqualToString:@"color"]) {
                [[self selectionTarget] performSelector:self.action withObject:[self.items objectAtIndex:_page][@"hex"]];
                NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
                [dict setValue:[NSNumber numberWithInt:_page] forKey:@"scrollViewPage"];
                [dict setObject:self.items forKey:@"colorSets"];
                
                [self.nameLabel setContent:dict];
            } else if ([self.type isEqualToString:@"misc"]) {
                
            }
        }
        
        WatchScrollBar* scrollBar = [self scrollBar];
        [scrollBar setScrollBarYPos:(scrollView.contentOffset.y)/(scrollView.contentSize.height-390.0)];
    }
}

#pragma clang diagnostic pop

- (void)setActiveColorSet:(NSNotification*)notification {
    self.items = [notification.userInfo objectForKey:@"colors"];
    NSMutableArray* colorHex = [[NSMutableArray alloc] init];
    for (int i=0; i<[self.items count]; i++) {
        [colorHex addObject:[self.items objectAtIndex:i][@"hex"]];
    }
    
    [self setContentSize:CGSizeMake(312, [self.items count]*390)];
    [self setContentOffset:CGPointMake(0, 0)];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithInt:0] forKey:@"scrollViewPage"];
    [dict setObject:self.items forKey:@"colorSets"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_nameLabel setContent:dict];
        WatchScrollBar* scrollBar = [self scrollBar];
        [scrollBar setScrollBarHeight:(390/self.contentSize.height)*75];
        
        LWWatchFace *target = [self selectionTarget];
        [target reRenderExperimental:[colorHex objectAtIndex:0]];
    });
}

@end
