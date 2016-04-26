//
//  ExperimentalColorSelector.m
//  LockWatch
//
//  Created by Janik Schmidt on 25.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "ExperimentalColorSelector.h"

@implementation ExperimentalColorSelector

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andSelectedColor:(NSString*)currentAccentColor {
    self = [super initWithFrame:frame];
    
    if (self) {
        //[self setBackgroundColor:[UIColor redColor]];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        
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
            
            [defaults synchronize];
        }
        
        [self setContentSize:CGSizeMake(312, [_colorSets count]*390)];
        [self setPagingEnabled:YES];
        [self setDelegate:self];
        
        int selectedColorIndex = 0;
        for (int i=0; i<[_colorHex count]; i++) {
            if ([[_colorHex objectAtIndex:i] isEqualToString:currentAccentColor]) {
                selectedColorIndex = i;
            }
        }
        
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSNumber numberWithInt:selectedColorIndex] forKey:@"scrollViewPage"];
        [dict setObject:_colorSets forKey:@"colorSets"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //[_colorNameLabel testEvent:dict];
            WatchScrollBar* scrollBar = [self scrollBar];
            [scrollBar setScrollBarHeight:(390/self.contentSize.height)*75];
            //[target reRenderSecondHandExperimental:[_colorHex objectAtIndex:selectedColorIndex]];
            [self setContentOffset:CGPointMake(0, selectedColorIndex*390)];
        });
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(testEvent:)
                                                     name:@"setActiveColorSet"
                                                   object:nil];
    }
    
    return self;
}

- (void)testEvent:(NSNotification*)notification {
    _colorSets = [notification.userInfo objectForKey:@"colors"];
    _colorHex = [[NSMutableArray alloc] init];
    for (int i=0; i<[_colorSets count]; i++) {
        [_colorHex addObject:[_colorSets objectAtIndex:i][@"hex"]];
    }
    
    [self setContentSize:CGSizeMake(312, [_colorSets count]*390)];
    [self setContentOffset:CGPointMake(0, 0)];
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setValue:[NSNumber numberWithInt:0] forKey:@"scrollViewPage"];
    [dict setObject:_colorSets forKey:@"colorSets"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //[_colorNameLabel testEvent:dict];
        WatchScrollBar* scrollBar = [self scrollBar];
        [scrollBar setScrollBarHeight:(390/self.contentSize.height)*75];
        
        LWWatchFace *target = [self selectionTarget];
        [target reRenderExperimental:[_colorHex objectAtIndex:0]];
    });
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
    
    if (_page >=0 && page <[_colorSets count]) {
        if (page != currentColorIndex) {
            currentColorIndex = _page;
            LWWatchFace *target = [self selectionTarget];
            [target reRenderExperimental:[_colorHex objectAtIndex:_page]];
            //[[self selectionTarget] performSelector:[self selectionAction]];
        }
        
        WatchScrollBar* scrollBar = [self scrollBar];
        [scrollBar setScrollBarYPos:(scrollView.contentOffset.y)/(scrollView.contentSize.height-390.0)];
        
        NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
        [dict setValue:[NSNumber numberWithInt:_page] forKey:@"scrollViewPage"];
        [dict setObject:_colorSets forKey:@"colorSets"];
    
        //[_colorNameLabel testEvent:dict];
    }
}

@end
