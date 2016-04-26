//
//  LWWatchFaceBase.m
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "LWWatchFaceWeather.h"
#define deg2rad(angle) ((angle) / 180.0 * M_PI)
#define PreferencesFilePath @"/var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"

@implementation LWWatchFaceWeather
NSString* woeid;
BOOL fahrenheit;
NSUserDefaults* defaults;

+ (void)load {
    //NSLog(@"\"Weather\" loaded");
}

- (id)initWithFrame:(CGRect)frame {
    self.customizable = false;

    accentColor = @"#ff9500";
    woeid = @"719746";
    
    self = [super initWithFrame:frame];
    
    if (self) {
        [self renderIndicators:NO];
        [self renderClockHands];
        
        tempLabel = [[UILabel alloc] initWithFrame:CGRectMake(312/2 - 40, 390/2 - 40, 80, 80)];
        tempLabel.textAlignment = NSTextAlignmentCenter;
        tempLabel.font = [UIFont systemFontOfSize:40 weight:UIFontWeightLight];
        tempLabel.textColor = [UIColor whiteColor];
        tempLabel.text = @"--°";
        
        [self addSubview:tempLabel];
        
        cityName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 40)];
        cityName.textColor = [self colorFromHexString:@"#008cfc"];
        cityName.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
        
        [self addSubview:cityName];
        
        clock = [[UILabel alloc] initWithFrame:CGRectMake(312-100, 0, 100, 40)];
        clock.textColor = [self colorFromHexString:@"#aeb4bf"];
        clock.textAlignment = NSTextAlignmentRight;
        clock.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
        
        [self addSubview:clock];
        
        preferences = [[NSMutableDictionary alloc] init];
        //defaults = [[NSMutableDictionary alloc] initWithContentsOfFile:PreferencesFilePath];
        defaults = [NSUserDefaults standardUserDefaults];
        if (![defaults objectForKey:@"weather"]) {
            [defaults setObject:preferences forKey:@"weather"];
        } else {
            preferences = [[NSMutableDictionary alloc]initWithDictionary:[defaults objectForKey:@"weather"]];
        }


        if ([preferences objectForKey:@"WOEID"]) {
            woeid = [preferences objectForKey:@"WOEID"];
        } else {
            woeid = @"2388327"; // San Francisco
            [preferences setObject:woeid forKey:@"WOEID"];
        }
        
        if ([preferences objectForKey:@"UseLocation"]) {
            if ([[preferences objectForKey:@"UseLocation"] boolValue]) {
                [self getCurrentLocation];
            } else {
                [self manualWeatherUpdate];
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
        //[defaults writeToFile:PreferencesFilePath atomically:YES];

        [self updateTime];
    }
    
    return self;
}

- (void)initWatchFace {
    [super initWatchFace];
}
- (void)deInitWatchFace:(BOOL)wasActiveBefore {
    [super deInitWatchFace:wasActiveBefore];
    
    [updateDisplayTimer invalidate];
    updateDisplayTimer = nil;
    
    clock.text = @"10:09";
}

- (void)renderIndicators:(BOOL)customize {
    [[indicatorContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    indicatorContainer = [[UIView alloc] initWithFrame:CGRectMake(312/2 - 308/2, 390/2 - 308/2, 308, 308)];
    
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    Hour = (Hour == 0) ? Hour + 12 : Hour;
    float Minute = [minuteComp minute];
    
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
    
    UIView* currentHourIndicator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 16)];
    currentHourIndicator.backgroundColor = [self colorFromHexString:@"#1fbeff"];
    
    float sinValue = sin(M_PI*((Hour + (Minute/60.0))*30.0/180.0))*94;
    float cosValue = cos(M_PI*((Hour + (Minute/60.0))*30.0/180.0))*94;
    currentHourIndicator.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
    currentHourIndicator.layer.cornerRadius = 8.0;
    
    [indicatorContainer addSubview:currentHourIndicator];
    
    [self insertSubview:indicatorContainer atIndex:0];
    
    [self makeWeatherSymbols:fcsthourly24short];
}

- (void)makeWeatherSymbols:(id)weatherData {
    [[weatherIconView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [weatherIconView removeFromSuperview];
    
    weatherIconView = [[UIView alloc] initWithFrame:CGRectMake(312/2 - 308/2, 390/2 - 308/2, 308, 308)];
    
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    
    float Hour = [hourComp hour];
    Hour = (Hour > 23) ? Hour - 12 : Hour;
    
    for (int i=1; i<12; i++) {
        //NSString* weatherImagePath = [NSString stringWithFormat:@"/Library/Application Support/LockWatch/Image Bundles/WeatherIcons/%@@2x.png", [self getImageForIndexNumber:[[[weatherData objectAtIndex:i-1] objectForKey:@"icon_cd"] intValue] currentHour:(int)Hour+(i)]];
        NSLog(@"[Weather] %@", [self getImageFromImageBundle:@"WeatherIcons" withImageName:[self getImageForIndexNumber:[[[weatherData objectAtIndex:i-1] objectForKey:@"icon_cd"] intValue] currentHour:(int)Hour+(i)]]);
        UIImageView* weatherImage = [[UIImageView alloc] initWithImage:[self getImageFromImageBundle:@"WeatherIcons" withImageName:[self getImageForIndexNumber:[[[weatherData objectAtIndex:i-1] objectForKey:@"icon_cd"] intValue] currentHour:(int)Hour+(i)]]];
        weatherImage.transform = CGAffineTransformMakeScale(0.8, 0.8);
        
        if ((Hour+i) == Hour) {
            weatherImage.alpha = 0;
        }
        
        float sinValue = sin(M_PI*((Hour+i)*30.0/180.0))*124;
        float cosValue = cos(M_PI*((Hour+i)*30.0/180.0))*124;
        
        weatherImage.layer.position = CGPointMake(308/2+sinValue, 308/2-cosValue);
        
        [weatherIconView addSubview:weatherImage];
    }
    [self addSubview:weatherIconView];
}

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

- (void)getCurrentLocation {
    locationManager = [[CLLocationManager alloc]init]; // initializing locationManager
    locationManager.delegate = self; // we set the delegate of locationManager to self.
    locationManager.desiredAccuracy = kCLLocationAccuracyBest; // setting the accuracy
    [locationManager requestWhenInUseAuthorization];
    
    geocoder = [[CLGeocoder alloc] init];
    
    [locationManager startUpdatingLocation];  //requesting location updates
}
- (id)getLocationByWOEID:(NSString*)woeid {
    NSURL* weatherApiUrlWOEID = [NSURL URLWithString:[[NSString stringWithFormat:@"https://query.yahooapis.com/v1/public/yql?q=select * from geo.placefinder where woeid = \"%@\" and flags=\"T\"&format=json&env=store://datatables.org/alltableswithkeys", woeid] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet]];
    
    id data = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:weatherApiUrlWOEID] options:NSJSONReadingMutableContainers error:nil];
    
    return data;
}

- (void)manualWeatherUpdate {
    /*fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
    NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
    
    id locationData = [self getLocationByWOEID:woeid][@"query"][@"results"][@"Result"];
    float lat = [locationData[@"latitude"] floatValue];
    float lon = [locationData[@"longitude"] floatValue];
    
    NSURL* weatherApiUrlLocation = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.weather.com/v1/geocode/%f/%f/aggregate.json?apiKey=e45ff1b7c7bda231216c7ab7c33509b8&products=conditionsshort,fcstdaily10short,fcsthourly24short,nowlinks", lat, lon]];
    
    
    NSData* jsonData = [NSData dataWithContentsOfURL:weatherApiUrlLocation];
    if (jsonData != nil) {
        conditionsshort = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"conditionsshort"] objectForKey:@"observation"];
        fcsthourly24short = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"fcsthourly24short"] objectForKey:@"forecasts"];
        
        [cityName setText:locationData[@"city"]];
        
        tempLabel.text = [NSString stringWithFormat:@"%@°", conditionsshort[unit][@"temp"]];
        updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
        [self makeWeatherSymbols:fcsthourly24short];
    }*/
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    fahrenheit = [[preferences objectForKey:@"UseFahrenheit"] boolValue];
    NSString* unit = (fahrenheit) ? @"imperial" : @"metric";
    
    // Reverse Geocoding
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        //NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            locationLat = newLocation.coordinate.latitude;
            locationLon = newLocation.coordinate.longitude;
            
            placemark = [placemarks lastObject];
            /*NSLog(@"%@", [NSString stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
             placemark.subThoroughfare, placemark.thoroughfare,
             placemark.postalCode, placemark.locality,
             placemark.administrativeArea,
             placemark.country]);*/
            
            cityName.text = [NSString stringWithFormat:@"%@", placemark.locality];
            //[cityName sizeToFit];
            
            NSURL* weatherApiUrlLocation = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.weather.com/v1/geocode/%f/%f/aggregate.json?apiKey=e45ff1b7c7bda231216c7ab7c33509b8&products=conditionsshort,fcstdaily10short,fcsthourly24short,nowlinks", locationLat, locationLon]];

            NSData* jsonData = [NSData dataWithContentsOfURL:weatherApiUrlLocation];

            if(jsonData != nil)
            {
                
                conditionsshort = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"conditionsshort"] objectForKey:@"observation"];
                fcsthourly24short = [[[NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil] objectForKey:@"fcsthourly24short"] objectForKey:@"forecasts"];
                
                tempLabel.text = [NSString stringWithFormat:@"%@°", [[conditionsshort objectForKey:unit] objectForKey:@"temp"]];
                updateDisplayTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(setNeedsDisplay) userInfo:nil repeats:YES];
                [self makeWeatherSymbols:fcsthourly24short];
            }
            [locationManager stopUpdatingLocation];
        } else {
            //NSLog(@"%@", error.debugDescription);
        }
    } ];
}

- (void)drawRect:(CGRect)rect {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    float Hour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    float Minute = [minuteComp minute];
    
    if (deinit) {
        Hour = 10;
        Minute = 9;
    }
    
    CGRect allRect = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw background
    CGContextSetRGBStrokeColor(context, 1.0,1.0,1.0,0.25);
    CGContextSetLineWidth(context, 8);
    
    // Draw progress
    CGPoint center = CGPointMake(allRect.size.width / 2, 390 / 2);
    CGFloat radius = 94;
    CGFloat startAngle = -90 + (Hour*30) + ((Minute/60)*30);
    CGFloat endAngle = -90 + ((Hour-1)*30);
    CGContextAddArc(context, center.x, center.y, radius, deg2rad(startAngle), deg2rad(endAngle), 0);
    CGContextStrokePath(context);
    
    [self renderIndicators:NO];
}

- (void) updateTime {
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];
    
    clock.text = [NSString stringWithFormat:@"%@:%@", ([hourComp hour] < 10) ? [NSString stringWithFormat:@"0%d", (int)[hourComp hour]] : [NSString stringWithFormat:@"%d", (int)[hourComp hour]], ([minuteComp minute] < 10) ? [NSString stringWithFormat:@"0%d", (int)[minuteComp minute]] : [NSString stringWithFormat:@"%d", (int)[minuteComp minute]]];
}

@end
