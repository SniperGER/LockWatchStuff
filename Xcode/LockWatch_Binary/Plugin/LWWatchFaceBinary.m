//
//  LWWatchFacePlugin.m
//  LockWatch_Plugin
//
//  Created by Janik Schmidt on 01.12.15.
//
//

#import "LWWatchFaceBinary.h"
#import <UIKit/UIKit.h>

@implementation LWWatchFaceBinary

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // Watch Face initialization code here
        self.customizable = YES;
        
        preferences = [[NSMutableDictionary alloc] init];
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"binary"]) {
            [defaults setObject:preferences forKey:@"binary"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"binary"]];
        }
        
        if ([preferences objectForKey:@"AccentColor"]) {
            accentColor = [preferences objectForKey:@"AccentColor"];
        } else {
            [preferences setObject:@"#8CE328" forKey:@"AccentColor"];
            accentColor = @"#8CE328";
        }
        
        [defaults setObject:preferences forKey:@"binary"];
        
        [self renderIndicators:NO];
        [self makeCustomizeSheet];
    }
    
    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
    [self updateTime];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    
    [self renderBinaryDots:@"100930"];
}

- (void)makeCustomizeSheet {
    [customizeBorder removeFromSuperview];
    [[customizeBorder subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    customizeBorder = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    customizeBorder.layer.borderWidth = 3.0;
    customizeBorder.layer.borderColor = [UIColor colorWithRed:8.0/255.0 green:217.0/255.0 blue:102.0/255.0 alpha:1].CGColor;
    customizeBorder.layer.cornerRadius = 12.0;
    customizeBorder.alpha = 0;
    [self addSubview:customizeBorder];
    
    colorSelector = [[ColorSelector alloc] initWithFrame:CGRectMake(10, self.frame.origin.y+10, 50, 370) withSelectedColor:accentColor];
    colorSelector.alpha = 0;
    
    [self addSubview:colorSelector];
    for (int i=0; i<[[colorSelector subviews] count]; i++) {
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setAccentColor:)];
        [[[colorSelector subviews] objectAtIndex:i] addGestureRecognizer:tap];
    }
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         colorSelector.alpha = 1;
                         customizeBorder.alpha = 1;
                     } completion:^(BOOL finished) {
                     }];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        binaryContainer.transform = CGAffineTransformMakeScale(0.935, 0.935); //first part of animation
        binaryContainer.transform = CGAffineTransformMakeScale(1.0, 1.0); //second part of animation
    } completion:nil];
}
-(void) hideCustomizeSheet {
    [super hideCustomizeSheet];
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        colorSelector.alpha = 0;
        customizeBorder.alpha = 0;
        
    } completion:nil];
    [binaryContainer.layer removeAllAnimations];
}

- (void)renderIndicators:(BOOL)customize {
    [[binaryContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [binaryContainer removeFromSuperview];
    
    if (!customize) {
        binaryContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 312, 390)];
    }
    
    UIView* binaryContainer1 = [[UIView alloc] initWithFrame:CGRectMake(52*0, 89, 52, 212)];
    UIView* binaryContainer2 = [[UIView alloc] initWithFrame:CGRectMake(52*1, 89, 52, 212)];
    UIView* binaryContainer3 = [[UIView alloc] initWithFrame:CGRectMake(52*2, 89, 52, 212)];
    UIView* binaryContainer4 = [[UIView alloc] initWithFrame:CGRectMake(52*3, 89, 52, 212)];
    UIView* binaryContainer5 = [[UIView alloc] initWithFrame:CGRectMake(52*4, 89, 52, 212)];
    UIView* binaryContainer6 = [[UIView alloc] initWithFrame:CGRectMake(52*5, 89, 52, 212)];
    
    // Hour - first bit
    for (int i=0; i<2; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer1 addSubview:indicatorBit];
    }
    // Hour - second bit
    for (int i=0; i<4; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer2 addSubview:indicatorBit];
    }
    
    // Minute - first bit
    for (int i=0; i<3; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer3 addSubview:indicatorBit];
    }
    // minute - second bit
    for (int i=0; i<4; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer4 addSubview:indicatorBit];
    }
    
    // Second - first bit
    for (int i=0; i<3; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer5 addSubview:indicatorBit];
    }
    // Second - second bit
    for (int i=0; i<4; i++) {
        UIView* indicatorBit = [[UIView alloc] initWithFrame:CGRectMake(11, 169-(i*52), 30, 30)];
        [indicatorBit setBackgroundColor:[self colorFromHexString:accentColor]];
        [indicatorBit.layer setCornerRadius:15];
        [binaryContainer6 addSubview:indicatorBit];
    }
    
    [binaryContainer addSubview:binaryContainer1];
    [binaryContainer addSubview:binaryContainer2];
    [binaryContainer addSubview:binaryContainer3];
    [binaryContainer addSubview:binaryContainer4];
    [binaryContainer addSubview:binaryContainer5];
    [binaryContainer addSubview:binaryContainer6];
    
    [self insertSubview:binaryContainer atIndex:0];
}

- (void)updateTime {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    NSDateComponents *secondComp = [gregorian components:NSCalendarUnitSecond fromDate:date];
    
    int Hour = (int)[hourComp hour];
    int Minute = (int)[minuteComp minute];
    int Second = (int)[secondComp second];
    
    NSString* testString = [NSString stringWithFormat:@"%@%@%@", [NSString stringWithFormat:(Hour < 10)?@"0%d":@"%d", Hour], [NSString stringWithFormat:(Minute < 10)?@"0%d":@"%d", Minute], [NSString stringWithFormat:(Second < 10)?@"0%d":@"%d", Second]];
    
    [self renderBinaryDots:testString];
}

- (void)renderBinaryDots:(NSString*)timeString {
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for (int i = 0; i < [timeString length]; i++) {
        NSString *ch = [timeString substringWithRange:NSMakeRange(i, 1)];
        [array addObject:ch];
    }
    
    [[[[binaryContainer subviews] objectAtIndex:0] subviews] objectAtIndex:0].alpha = 0;
    
    [[binaryContainer subviews] enumerateObjectsUsingBlock:^(UIView* subviewUpper, NSUInteger indexUpper, BOOL* stopUpper) {
        NSString* bitString = [self binaryStringFromInteger:[[array objectAtIndex:indexUpper] intValue] withSpacing:1];
        NSMutableString *reversedString = [NSMutableString stringWithCapacity:[bitString length]];
        [bitString enumerateSubstringsInRange:NSMakeRange(0,[bitString length])
                                      options:(NSStringEnumerationReverse | NSStringEnumerationByComposedCharacterSequences)
                                   usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                       [reversedString appendString:substring];
                                   }];
        
        NSMutableArray* bitArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [reversedString length]; i++) {
            NSString *ch = [reversedString substringWithRange:NSMakeRange(i, 1)];
            [bitArray addObject:ch];
        }
        
        [[subviewUpper subviews] enumerateObjectsUsingBlock:^(UIView* subview, NSUInteger index, BOOL* stop) {
            if ([[bitArray objectAtIndex:index] floatValue] == 1) {
                subview.backgroundColor = [self colorFromHexString:accentColor];
            } else {
                subview.backgroundColor = [UIColor colorWithWhite:.20 alpha:1];
            }
            subview.alpha = 1;
        }];
    }];
}

- (void)setAccentColor:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = colorSelector.colorHexArray;
    accentColor = [colorHexArray objectAtIndex:sender.view.tag-900];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [preferences setObject:accentColor forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"binary"];
    
    [self renderIndicators:YES];
    [self renderBinaryDots:@"100930"];
    
    for (int i=0; i<[colorSelector subviews].count; i++) {
        [[[[colorSelector subviews] objectAtIndex:i] layer]setBorderWidth:0];
    }
    sender.view.layer.borderWidth = 3;
}

- (NSString*) binaryStringFromInteger:(int)number withSpacing:(int)spacing {
    NSMutableString * string = [[NSMutableString alloc] init];

    int width = ( sizeof( number ) ) * spacing;
    int binaryDigit = 0;
    int integer = number;
    
    while( binaryDigit < width )
    {
        binaryDigit++;
        
        [string insertString:( (integer & 1) ? @"1" : @"0" )atIndex:0];
        
        if( binaryDigit % spacing == 0 && binaryDigit != width )
        {
            //[string insertString:@" " atIndex:0];
        }
        
        integer = integer >> 1;
    }
    
    return string;
}

@end
