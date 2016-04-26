//
//  LWWatchFaceWeather.m
//  LockWatch
//
//  Created by Janik Schmidt on 28.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import "LWWatchFaceWeather.h"
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#define deg2rad(angle) ((angle) / 180.0 * M_PI)

@implementation LWWatchFaceWeather
NSMutableDictionary* defaults;
bool demoMode = YES;
bool allowRenderSymbols = YES;
bool externalWeatherData = NO;
bool weatherActive = NO;

int currentPage = 1;
float Hour;
float Minute;

- (id)initWithFrame:(CGRect)frame {
    self.customizable = YES;
	self.allowTouchedZoom = YES;
    
    accentColor = @"#ff9500"; // Stock: @"#1fbeff"
    
    self = [super initWithFrame:frame];
    
    if (self) {
        preferences = [[NSMutableDictionary alloc] init];
        defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        //defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"weather"]) {
            [defaults setObject:preferences forKey:@"weather"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
        }
        
        if ([preferences objectForKey:@"AccentColor"]) {
            accentColor = [preferences objectForKey:@"AccentColor"];
        } else {
            [preferences setObject:@"#18B5FC" forKey:@"AccentColor"];
            accentColor = @"#18B5FC";
        }
        
        if ([preferences objectForKey:@"WOEID"]) {
            woeid = [preferences objectForKey:@"WOEID"];
        } else {
            woeid = @"2388327"; // Cupertino
            [preferences setObject:woeid forKey:@"WOEID"];
        }
        
        if ([preferences objectForKey:@"UseLocation"]) {
            if ([[preferences objectForKey:@"UseLocation"] boolValue]) {
                [self getCurrentLocation];
            } else {
                //[self manualWeatherUpdate];
				NSLog(@"[LockWatch] Pretending manual weather data update.");
            }
        } else {
            [preferences setValue:[NSNumber numberWithBool:YES] forKey:@"UseLocation"];
            [self getCurrentLocation];
        }
        
        if ([preferences objectForKey:@"UseFahrenheit"]) {
            fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
        } else {
            fahrenheit = NO;
            [preferences setValue:[NSNumber numberWithBool:NO] forKey:@"UseFahrenheit"];
        }
        [defaults setObject:preferences forKey:@"weather"];
		[defaults writeToFile:PreferencesFilePath atomically:YES];
        
        tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(308/2 - 40, 308/2 - 40, 80, 80)];
        tempLabel.textAlignment = NSTextAlignmentCenter;
        tempLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
        tempLabel.textColor = [UIColor whiteColor];
        
        if ([[preferences objectForKey:@"UseFahrenheit"] boolValue]) {
            tempLabel.text = @"72°";
        } else {
            tempLabel.text = @"22°";
        }
        
        cityName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
        cityName.textColor = [self colorFromHexString:accentColor];
        cityName.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
        cityName.text = @"Cupertino";
        
        clock = [[UILabel alloc] initWithFrame:CGRectMake(312-100, 0, 100, 40)];
        clock.textColor = [self colorFromHexString:@"#aeb4bf"];
        clock.textAlignment = NSTextAlignmentRight;
        clock.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
        
        umbrella = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"WeatherIcons" withImageName:@"umbrella"]];
        umbrella.image = [umbrella.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        umbrella.frame = CGRectMake(308/2 - 60/2, 308/2 - 40/2, 40, 40);
        [umbrella setAlpha:0];
        [umbrella setTintColor:[self colorFromHexString:accentColor]];

        umbrellaLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 40, 40)];
        umbrellaLabel.text = @"%";
        umbrellaLabel.textColor = [self colorFromHexString:accentColor];
        umbrellaLabel.font = [UIFont systemFontOfSize:30 weight:UIFontWeightLight];
        [umbrella addSubview:umbrellaLabel];
        
        [self addSubview:clock];
        [self addSubview:cityName];

        
        [self updateTime];
        //updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
        newWeatherTimer = [NSTimer scheduledTimerWithTimeInterval:15*60 target:self selector:@selector(checkForNewWeatherData) userInfo:nil repeats:YES];
        
        customizeBorder = [[LWWatchFaceCustomizations alloc] generalCustomizeBorder:CGRectMake(0,0,312,390)];
        [self addSubview:customizeBorder];
        
        activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(312/2 - 40/2, 390/2 - 40/2, 40, 40)];
        [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activity.alpha = 0;
        [self addSubview:activity];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fahrenheitChanged:)
                                                     name:@"weatherFahrenheit"
                                                   object:nil];
		[[NSNotificationCenter defaultCenter] addObserverForName:@"weatherExternalData"
							object:nil
							 queue:[NSOperationQueue mainQueue]
						usingBlock:^(NSNotification *note){
							
							externalWeatherData = YES;
								
							conditionsshort = note.userInfo[@"conditionsshort"];
							fcsthourly24short = note.userInfo[@"fcsthourly24short"];
							
							self.actualCityName = note.userInfo[@"cityName"];
							
							NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
							self.actualTemp = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
							
							
							if (weatherActive) {
								cityName.text = note.userInfo[@"cityName"];
								
								
								//NSLog(@"[LockWatch] %@", fcsthourly24short);

								demoMode = NO;
								fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
								
								tempLabel.text = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
								updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
								[self makeWeatherSymbols:fcsthourly24short];
								
								tempLabel.alpha = 1;
								activity.alpha = 0;
								[activity stopAnimating];
								[locationManager stopUpdatingLocation];
							}
						}];
		[[NSNotificationCenter defaultCenter] addObserverForName:@"weatherError"
														  object:nil
														   queue:[NSOperationQueue mainQueue]
													  usingBlock:^(NSNotification *note){
														  activity.alpha = 0;
														  [activity stopAnimating];
														  [locationManager stopUpdatingLocation];
						}];
    }
    return self;
}

- (void)touchDownEvent {
    [super touchDownEvent];
}
- (void)touchUpEvent {
    [super touchUpEvent];
	
	if (!isScaledDown) {
		if (currentPage < 3) {
			currentPage++;
		} else {
			currentPage = 1;
		}
		[self setWeatherPage:currentPage];
	}

}

- (void)fahrenheitChanged:(NSNotification*)notification {
    preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
    fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
    
    allowRenderSymbols = YES;
    
    [self setWeatherPage:1];
    [self makeWeatherSymbols:fcsthourly24short];
    
    NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
    if (fahrenheit) {
        tempLabel.text = @"72°";
    } else {
        tempLabel.text = @"22°";
    }
    self.actualTemp = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
}

- (void)setWeatherPage:(int)weatherPage {
    if (weatherPage == 1) {
        [weatherIconView setAlpha:1];
        [tempLabel setAlpha:1];
        tempLabel.text = self.actualTemp;
        [umbrella setAlpha:0];
        [popLabelContainer setAlpha:0];
    } else if (weatherPage == 2) {
        [tempLabelContainer setAlpha:1];
        [weatherIconView setAlpha:0];
        if ([[preferences objectForKey:@"UseFahrenheit"] boolValue]) {
            tempLabel.text = @"°F";
        } else {
            tempLabel.text = @"°C";
        }

    } else if (weatherPage == 3) {
        [weatherIconView setAlpha:0];
        [tempLabel setAlpha:0];
        [umbrella setAlpha:1];
        [tempLabelContainer setAlpha:0];
        [popLabelContainer setAlpha:1];
    }
}

- (void)initWatchFace {
    [super initWatchFace];
    
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    allowRenderSymbols = YES;
    
    currentPage = 1;
	deinit = NO;
	demoMode = NO;
    if (self.actualCityName) {
        cityName.text = self.actualCityName;
    } else {
        cityName.text = @"";
    }
    if (self.actualTemp) {
        tempLabel.text = self.actualTemp;
    } else {
        tempLabel.alpha = 0;
        activity.alpha = 1;
        [activity startAnimating];
    }
    
    [self setNeedsDisplay];
	weatherActive = YES;
}

- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    allowRenderSymbols = YES;
    
    deinit = YES;
    demoMode = YES;
    
    currentPage = 1;
    
    [updateDisplayTimer invalidate];
    updateDisplayTimer = nil;
    
    [umbrella setAlpha:0];
    [tempLabelContainer setAlpha:0];
    
	[self setNeedsDisplay];
	weatherActive = NO;
}

- (void)reInitWatchFace:(BOOL)initAfterAnimation {
    [super reInitWatchFace:initAfterAnimation];
    
    if (initAfterAnimation) {
        [self renderIndicators:NO];
        [self updateTime];
        updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
		weatherActive = YES;
    }
}

- (void)drawRect:(CGRect)rect {
    if (!isCustomizing) {
        [self renderIndicators:NO];
    }
}

- (void)renderIndicators:(BOOL)customize {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    if ([hourComp hour] != Hour || [minuteComp minute] != Minute) {
        allowRenderSymbols = YES;
    }
    
    Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    Hour = (Hour == 0) ? Hour + 12 : Hour;
    Minute = [minuteComp minute];
    
    //[[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (allowRenderSymbols) {
        [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(312/2 - 308/2, 390/2 - 308/2, 308, 308)];
    }
    
    [circularIndicator removeFromSuperview];
    circularIndicator = [LWWatchFaceWeatherIndicator alloc];
    [circularIndicator setDeinit:deinit];
    circularIndicator = [circularIndicator initWithFrame:CGRectMake(0, 0, 308, 308)];
    [indicatorContainer insertSubview:circularIndicator atIndex:0];
    
    if (deinit) {
        Hour = 10;
        Minute = 9;
    }
    
    for (int i=0; i<12; i++) {
        UIView* hourIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 8)];
        hourIndicator.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1];
        
        if ((i+1) == Hour) {
            hourIndicator.alpha = 0;
        }
        
        //var sin = Math.sin(Math.PI*((j+1)*30/180))*70;
        float sinValue = sin(M_PI*((i+1)*30.0/180.0))*94;
        float cosValue = cos(M_PI*((i+1)*30.0/180.0))*94;
        
        hourIndicator.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
        hourIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*30));
        
        [indicatorContainer addSubview:hourIndicator];
    }
    
    for (int i=0; i<12; i++) {
        UILabel* hourIndicator = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        hourIndicator.textAlignment = NSTextAlignmentCenter;
        hourIndicator.text = [NSString stringWithFormat:@"%d",(i+1)];
        hourIndicator.textColor = [UIColor whiteColor];
        hourIndicator.font = [UIFont systemFontOfSize:14];
        
        if ((i+1) == Hour) {
            hourIndicator.alpha = 0;
        }
        
        //var sin = Math.sin(Math.PI*((j+1)*30/180))*70;
        float sinValue = sin(M_PI*((i+1)*30.0/180.0))*70;
        float cosValue = cos(M_PI*((i+1)*30.0/180.0))*70;
        
        hourIndicator.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
        //hourIndicator.transform = CGAffineTransformMakeRotation(deg2rad((i+1)*30));
        
        [indicatorContainer addSubview:hourIndicator];
    }
    
    currentHourIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    currentHourIndicator.backgroundColor = [self colorFromHexString:accentColor];
    
    float sinValue = sin(M_PI*((Hour + (Minute/60.0))*30.0/180.0))*94;
    float cosValue = cos(M_PI*((Hour + (Minute/60.0))*30.0/180.0))*94;
    currentHourIndicator.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
    currentHourIndicator.layer.cornerRadius = 8.0;
    
    [indicatorContainer addSubview:currentHourIndicator];
    
    [self insertSubview:indicatorContainer atIndex:0];
    
    [indicatorContainer addSubview:tempLabel];
    [indicatorContainer addSubview:umbrella];
    
    if (!customize) {
        [self makeCustomizeSheet];
    }
    
    if (allowRenderSymbols) {
        [self makeWeatherSymbols:fcsthourly24short];
    }
    
    if (currentPage == 1) {
        [weatherIconView setAlpha:1];
        [tempLabel setAlpha:1];
        tempLabel.text = self.actualTemp;
        [umbrella setAlpha:0];
        [popLabelContainer setAlpha:0];
    } else if (currentPage == 2) {
        [tempLabelContainer setAlpha:1];
        [weatherIconView setAlpha:0];
        if ([[preferences objectForKey:@"UseFahrenheit"] boolValue]) {
            tempLabel.text = @"°F";
        } else {
            tempLabel.text = @"°C";
        }
        
    } else if (currentPage == 3) {
        [weatherIconView setAlpha:0];
        [tempLabel setAlpha:0];
        [umbrella setAlpha:1];
        [tempLabelContainer setAlpha:0];
        [popLabelContainer setAlpha:1];
    }
    
    if (demoMode) {
        clock.text = @"10:09";
        cityName.text = @"Cupertino";
        
        [tempLabel setAlpha:1];
        if ([[preferences objectForKey:@"UseFahrenheit"] boolValue]) {
            tempLabel.text = @"72°";
        } else {
            tempLabel.text = @"22°";
        }
    }
}

- (void)updateTime {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    clock.text = [NSString stringWithFormat:@"%@:%@", ([hourComp hour] < 10) ? [NSString stringWithFormat:@"0%d", (int)[hourComp hour]] : [NSString stringWithFormat:@"%d", (int)[hourComp hour]], ([minuteComp minute] < 10) ? [NSString stringWithFormat:@"0%d", (int)[minuteComp minute]] : [NSString stringWithFormat:@"%d", (int)[minuteComp minute]]];
}

- (void)checkForNewWeatherData {
    int timeSince1970 = (int)[[NSDate date] timeIntervalSince1970];
    if (conditionsshortExpire < timeSince1970 || fcsthourly24shortExpire < timeSince1970) {
        NSLog(@"[LWWatchFaceWeather] Updating weather data...");
        allowRenderSymbols = YES;
        if ([[preferences objectForKey:@"UseLocation"] boolValue]) {
            [self getCurrentLocation];
        } else {
            //[self manualWeatherUpdate];
        }
    }
}

- (void)makeWeatherSymbols:(id)weatherData {
    allowRenderSymbols = NO;
    
    [[weatherIconView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [weatherIconView removeFromSuperview];
    
    weatherIconView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 308, 308)];
    
    [[tempLabelContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [tempLabelContainer removeFromSuperview];
    
    tempLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 308, 308)];
    
    [[popLabelContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [popLabelContainer removeFromSuperview];
    
    popLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 308, 308)];
    
    NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSDate* date = [[NSDate alloc] init];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    
    Hour = [hourComp hour];
    Hour = (Hour > 23) ? Hour - 12 : Hour;
    
    if (demoMode) {
        Hour = 10;
        weatherData = [[NSArray alloc] initWithObjects:@"29", @"29", @"29", @"29", @"29", @"29", @"29", @"29", @"29", @"29", @"29", nil];
    }
    
    NSMutableDictionary* weatherDataTime = [[NSMutableDictionary alloc] init];
    if (!demoMode) {
        for (int i=0; i<[weatherData count]; i++) {
			NSMutableDictionary* _data = [[NSMutableDictionary alloc] init];
			[_data setValue:[weatherData objectAtIndex:i][@"icon_cd"] forKey:@"icon_cd"];
			[_data setValue:[weatherData objectAtIndex:i][@"metric"][@"temp"] forKey:@"tempC"];
			[_data setValue:[weatherData objectAtIndex:i][@"imperial"][@"temp"] forKey:@"tempF"];
			[_data setValue:[weatherData objectAtIndex:i][@"pop"] forKey:@"pop"];
			
			if (!externalWeatherData) {
				NSDate* _date = [dateFormatter dateFromString:[weatherData objectAtIndex:i][@"fcst_valid_local"]];
				NSDateComponents *components = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:_date];
				float hour = [components hour];
                [_data setValue:[NSNumber numberWithInt:(int)hour] forKey:@"validHour"];
                [weatherDataTime setObject:_data forKey:[NSString stringWithFormat:@"%d", (int)hour]];
			} else {
				NSString* string = [weatherData objectAtIndex:i][@"fcst_valid_local"];
				NSRange range = NSMakeRange(0,2);
				int h = [[string substringWithRange:range] intValue];
				[_data setValue:[NSNumber numberWithInt:h] forKey:@"validHour"];
				[weatherDataTime setObject:_data forKey:[NSString stringWithFormat:@"%d", h]];
				//NSLog()
			}
			//NSLog(@"[LockWatch] %@", weatherDataTime);
			
        }
    }
    
    for (int i=1; i<12; i++) {
        id dataObject;
        
        float _Hour = (Hour+i > 23) ? (Hour+i) - 24 : Hour+i;
        
        if (demoMode) {
            NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
            [dict setObject:@"29" forKey:@"icon_cd"];
            dataObject = dict;
        } else if ([weatherDataTime count] > 0) {
            dataObject = [weatherDataTime objectForKey:[NSString stringWithFormat:@"%d", (int)_Hour]];
        } else {
            return;
        }
        
        UIImageView* weatherImage = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"WeatherIcons" withImageName:[self getImageForIndexNumber:[dataObject[@"icon_cd"] intValue] currentHour:(int)_Hour]]];

        weatherImage.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        if ((Hour+i) == Hour) {
            weatherImage.alpha = 0;
        }
        
        float sinValue = sin(M_PI*((Hour+i)*30.0/180.0))*124;
        float cosValue = cos(M_PI*((Hour+i)*30.0/180.0))*124;
        
        weatherImage.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
        
        [weatherIconView addSubview:weatherImage];
        
        if (!demoMode && dataObject[@"tempC"] && dataObject[@"tempF"]) {
            UILabel* _tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
            _tempLabel.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
            
            NSString* _tempUnit = (fahrenheit) ? @"tempF" : @"tempC";
            
            NSString* _temp = [NSString stringWithFormat:@"%@", dataObject[_tempUnit]];
            [_tempLabel setText:_temp];
            [_tempLabel setFont:[UIFont systemFontOfSize:26]];
            [_tempLabel setTextColor:[UIColor whiteColor]];
            [_tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabelContainer addSubview:_tempLabel];
        }
        
        if (!demoMode && dataObject[@"pop"]) {
            UILabel* _popLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
            _popLabel.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
            
            NSString* _temp = [NSString stringWithFormat:@"%@", dataObject[@"pop"]];
            [_popLabel setText:_temp];
            [_popLabel setFont:[UIFont systemFontOfSize:26]];
            [_popLabel setTextColor:[self colorFromHexString:accentColor]];
            [_popLabel setTextAlignment:NSTextAlignmentCenter];
            [popLabelContainer addSubview:_popLabel];
        }
    }
    if (!self.actualTemp) {
        weatherIconView.alpha = 0;
    }
    if (currentPage != 2) {
        tempLabelContainer.alpha = 0;
    }
    if (currentPage != 3) {
        popLabelContainer.alpha = 0;
    }
    
    [indicatorContainer addSubview:weatherIconView];
    [indicatorContainer addSubview:tempLabelContainer];
    [indicatorContainer addSubview:popLabelContainer];
}
    
    /*for (int i=1; i<12; i++) {
        id dataObject;
        if (demoMode) {
            dataObject = [[weatherData objectAtIndex:i-1] intValue];
        } else {
            if ([weatherDataTime count] > 0) {
                dataObject = [weatherData objectAtIndex:[[weatherDataTime objectAtIndex:i-1] intValue]];
            }
        }
        
        if (demoMode || [weatherDataTime count] > 0) {
            UIImageView* weatherImage = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"WeatherIcons" withImageName:[self getImageForIndexNumber:[dataObject objectForKey:@"icon_cd"] currentHour:(int)Hour+(i)]]];
        weatherImage.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        if ((Hour+i) == Hour) {
            weatherImage.alpha = 0;
        }
        
        float sinValue = sin(M_PI*((Hour+i)*30.0/180.0))*124;
        float cosValue = cos(M_PI*((Hour+i)*30.0/180.0))*124;
        
        weatherImage.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
        
        [weatherIconView addSubview:weatherImage];
        
        if (!demoMode && [weatherData objectAtIndex:i-1]) {
            UILabel* _tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            _tempLabel.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
            
            NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
            NSString* _temp = [NSString stringWithFormat:@"%@", [weatherData objectAtIndex:i-1][unit][@"temp"]];
            [_tempLabel setText:_temp];
            [_tempLabel setFont:[UIFont systemFontOfSize:26]];
            [_tempLabel setTextColor:[UIColor whiteColor]];
            [_tempLabel setTextAlignment:NSTextAlignmentCenter];
            [tempLabelContainer addSubview:_tempLabel];
        }
        
        if (!demoMode && [weatherData objectAtIndex:i-1]) {
            UILabel* _popLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
            _popLabel.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
            
            NSString* _temp = [NSString stringWithFormat:@"%@", [weatherData objectAtIndex:i-1][@"pop"]];
            [_popLabel setText:_temp];
            [_popLabel setFont:[UIFont systemFontOfSize:26]];
            [_popLabel setTextColor:[self colorFromHexString:accentColor]];
            [_popLabel setTextAlignment:NSTextAlignmentCenter];
            [popLabelContainer addSubview:_popLabel];
        }
    }
    if (!self.actualTemp) {
        weatherIconView.alpha = 0;
    }
    if (currentPage != 2) {
        tempLabelContainer.alpha = 0;
    }
    if (currentPage != 3) {
        popLabelContainer.alpha = 0;
    }
    
    [indicatorContainer addSubview:weatherIconView];
    [indicatorContainer addSubview:tempLabelContainer];
    [indicatorContainer addSubview:popLabelContainer];
    }*/

- (NSString*)getImageForIndexNumber:(int)indexNumber currentHour:(int)Hour {
    Hour = (Hour > 23) ? Hour - 24 : Hour;
    int lightHour = 7;
    int darkHour = 20;
    NSArray* images = [NSArray arrayWithObjects:
                       @"tornado",
                       @"tropical-storm",
                       @"hurricane",
                       (Hour > lightHour && Hour < darkHour) ? @"severe-thunderstorm-day" : @"severe-thunderstorm-night",
                       (Hour > lightHour && Hour < darkHour) ? @"severe-thunderstorm-day" : @"severe-thunderstorm-night",
                       @"flurry",
                       @"flurry",
                       @"flurry",
                       @"flurry",
                       (Hour > lightHour && Hour < darkHour) ? @"drizzle-day" : @"drizzle-night",
                       @"ice",
                       (Hour > lightHour && Hour < darkHour) ? @"rain-day" : @"rain-night",
                       (Hour > lightHour && Hour < darkHour) ? @"rain-day" : @"rain-night",
                       @"flurry",
                       @"flurry",
                       @"blowingsnow",
                       @"flurry",
                       (Hour > lightHour && Hour < darkHour) ? @"hail-day" : @"hail-night",
                       (Hour > lightHour && Hour < darkHour) ? @"sleet-day" : @"sleet-night",
                       @"dust",
                       (Hour > lightHour && Hour < darkHour) ? @"fog-day" : @"fog-night",
                       @"haze",
                       @"smoke",
                       @"breezy",
                       @"breezy",
                       @"ice",
                       (Hour > lightHour && Hour < 20) ? @"mostly-cloudy-day" : @"mostly-cloudy-night",
                       (Hour > lightHour && Hour < 20) ? @"mostly-cloudy-day" : @"mostly-cloudy-night",
                       (Hour > lightHour && Hour < 20) ? @"mostly-cloudy-day" : @"mostly-cloudy-night",
                       (Hour > lightHour && Hour < 20) ? @"partly-cloudy-day" : @"partly-cloudy-night",
                       (Hour > lightHour && Hour < 20) ? @"partly-cloudy-day" : @"mostly-cloudy-night",
                       (Hour > lightHour && Hour < darkHour) ? @"mostly-sunny" : @"clear-night",
                       (Hour > lightHour && Hour < darkHour) ? @"mostly-sunny" : @"clear-night",
                       (Hour > lightHour && Hour < darkHour) ? @"mostly-sunny" : @"clear-night",
                       (Hour > lightHour && Hour < darkHour) ? @"mostly-sunny" : @"clear-night",
                       (Hour > lightHour && Hour < darkHour) ? @"hail-day" : @"hail-night",
                       @"hot",
                       (Hour > lightHour && Hour < darkHour) ? @"severe-thunderstorm-day" : @"severe-thunderstorm-night",
                       (Hour > lightHour && Hour < darkHour) ? @"severe-thunderstorm-day" : @"severe-thunderstorm-night",
                       (Hour > lightHour && Hour < darkHour) ? @"rain-day" : @"rain-night",
                       (Hour > lightHour && Hour < darkHour) ? @"heavy-rain-day" : @"heavy-rain-night",
                       @"flurry",
                       (Hour > lightHour && Hour < darkHour) ? @"sleet-day" : @"sleet-night",
                       (Hour > lightHour && Hour < darkHour) ? @"blizzard-day" : @"blizzard-night",
                       @"no-report",
                       (Hour > lightHour && Hour < darkHour) ? @"rain-day" : @"rain-night",
                       (Hour > lightHour && Hour < darkHour) ? @"blizzard-day" : @"blizzard-night",
                       (Hour > lightHour && Hour < darkHour) ? @"severe-thunderstorm-day" : @"severe-thunderstorm-night",
                       nil];
    return [NSString stringWithFormat:@"%@@2x", [images objectAtIndex:indexNumber]];
}

- (void)makeCustomizeSheet {
    [[customizeColors subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [customizeColors removeFromSuperview];
    
    if ([[defaults objectForKey:@"watchColorSelector"] boolValue]) {
        customizeColors = [[LWWatchFaceCustomizations alloc] experimentalAccentColorCustomize:CGRectMake(0, 0, 312, 390) withAccentColor:accentColor withTarget:self andTapAction:@selector(reRenderIndicators:)];
        CGRect _frame1 = [[customizeColors subviews] objectAtIndex:1].frame;
        _frame1.origin.y = 356;
        [[customizeColors subviews] objectAtIndex:1].frame = _frame1;
        
        [[[customizeColors subviews] objectAtIndex:0] removeFromSuperview];
    } else {
        customizeColors = [[LWWatchFaceCustomizations alloc] colorIndicatorCustomize:CGRectMake(0, 0, 312, 390)
                                                                     withAccentColor:accentColor
                                                                          withTarget:self
                                                                       withTapAction:@selector(reRenderIndicators:)];
        
    }
    
    [customizeColors setAlpha:0];
    
    [self addSubview:customizeColors];
}
- (void)callCustomizeSheet {
    [super callCustomizeSheet];
    [UIView animateWithDuration: 0.2
                          delay: 0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         customizeColors.alpha = 1;
                         customizeBorder.alpha = 1;
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                         secondHand.alpha = 0;
                     } completion:^(BOOL finished) {
                         hourHand.alpha = 0;
                         minuteHand.alpha = 0;
                     }];
    [UIView animateWithDuration:0.6f delay:0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        indicatorContainer.transform = CGAffineTransformMakeScale(0.935, 0.935); //first part of animation
        indicatorContainer.transform = CGAffineTransformMakeScale(1.0, 1.0); //second part of animation
    } completion:nil];
}
- (void)hideCustomizeSheet {
    [super hideCustomizeSheet];
    [UIView animateWithDuration: 0.1 delay: 0 options: UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, 0);
        customizeColors.alpha = 0;
        customizeBorder.alpha = 0;
        indicatorContainer.alpha = 1;
        indicatorContainer.transform = CGAffineTransformMakeScale(1.0, 1.0);
        hourHand.alpha = 1;
        minuteHand.alpha = 1;
        
    } completion:nil];
    [indicatorContainer.layer removeAllAnimations];
}

- (void)reRenderIndicators:(UITapGestureRecognizer*)sender {
    NSArray* colorHexArray = [[[LWWatchFaceColorSelector alloc] init] colorHex];
    accentColor = [colorHexArray objectAtIndex:sender.view.tag-900];
    
    defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    //defaults = [NSUserDefaults standardUserDefaults];
    [preferences setObject:accentColor forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"weather"];
    [defaults writeToFile:PreferencesFilePath atomically:YES];
    
    currentHourIndicator.backgroundColor = [self colorFromHexString:accentColor];
    cityName.textColor = [self colorFromHexString:accentColor];
    
    for (int i=0; i<[[[customizeColors subviews] objectAtIndex:0] subviews].count; i++) {
        [[[[[customizeColors subviews] objectAtIndex:0] subviews] objectAtIndex:i].layer setBorderWidth:0];
    }
    
    sender.view.layer.borderWidth = 3;
}

- (void)reRenderExperimental:(NSString*)newAccentColor {
    accentColor = newAccentColor;
    
    currentHourIndicator.backgroundColor = [self colorFromHexString:accentColor];
    cityName.textColor = [self colorFromHexString:accentColor];
    [umbrella setTintColor:[self colorFromHexString:accentColor]];
    umbrellaLabel.textColor = [self colorFromHexString:accentColor];
    
    for (int i=0; i<[[popLabelContainer subviews] count]; i++) {
        UILabel* _popLabel = [[popLabelContainer subviews] objectAtIndex:i];
        [_popLabel setTextColor:[self colorFromHexString:accentColor]];
    }
    
    //defaults = [NSUserDefaults standardUserDefaults];
	defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
    [preferences setObject:newAccentColor forKey:@"AccentColor"];
    [defaults setObject:preferences forKey:@"weather"];
	[defaults writeToFile:PreferencesFilePath atomically:YES];
};

- (void)getCurrentLocation {
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self; // we set the delegate of locationManager to self.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    [locationManager requestWhenInUseAuthorization];
    
    geocoder = [[CLGeocoder alloc] init];
    
    [locationManager startUpdatingLocation];  //requesting location updates
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    CLLocation *currentLocation = newLocation;
    fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
    NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error == nil && [placemarks count] > 0) {
            locationLat = newLocation.coordinate.latitude;
            locationLon = newLocation.coordinate.longitude;
            
            placemark = [placemarks lastObject];

            
            cityName.text = [NSString stringWithFormat:@"%@", placemark.locality];
            self.actualCityName = [NSString stringWithFormat:@"%@", placemark.locality];
            //[cityName sizeToFit];
            
            NSURL* weatherApiUrlLocation = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.weather.com/v1/geocode/%f/%f/aggregate.json?apiKey=e45ff1b7c7bda231216c7ab7c33509b8&products=conditionsshort,fcstdaily10short,fcsthourly24short,nowlinks", locationLat, locationLon]];
            
            NSData* jsonData = [NSData dataWithContentsOfURL:weatherApiUrlLocation];
            
            if(jsonData != nil) {
                demoMode = NO;
                
                conditionsshort = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"conditionsshort"] objectForKey:@"observation"];
                fcsthourly24short = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"fcsthourly24short"] objectForKey:@"forecasts"];
                
                conditionsshortExpire = [[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil][@"conditionsshort"][@"metadata"][@"expire_time_gmt"] doubleValue];
                
                tempLabel.text = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
                self.actualTemp = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
                updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
                [self makeWeatherSymbols:fcsthourly24short];
                
                tempLabel.alpha = 1;
                activity.alpha = 0;
                [activity stopAnimating];
            }
            [locationManager stopUpdatingLocation];
        }
    }];
}

@end
