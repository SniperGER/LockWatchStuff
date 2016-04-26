//
//  LWWeatherDataController.m
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 19.02.16.
//
//

#define PREFERENCES_FILE @"var/mobile/Library/Preferences/de.sniperger.LockWatch.plist"
#import "LWWeatherDataController.h"

bool noCitiesMessage = NO;
bool failedMessage = NO;

@implementation LWWeatherDataController

- (id)init {
	self = [super init];
	if (self) {
		NSMutableDictionary* tweakSettings = [NSMutableDictionary dictionaryWithContentsOfFile:PREFERENCES_FILE];
		
		City *localCity;
		
		if ([tweakSettings[@"weather"][@"UseLocation"] boolValue]) {
			localCity = [[%c(WeatherPreferences) sharedPreferences] localWeatherCity];
			WeatherLocationManager *weatherLocationManager = [%c(WeatherLocationManager) sharedWeatherLocationManager];
			
			CLLocationManager *locationManager = [[CLLocationManager alloc]init];
			[weatherLocationManager setDelegate:locationManager];
			
			if(![weatherLocationManager locationTrackingIsReady]) {
				[weatherLocationManager setLocationTrackingReady:YES activelyTracking:NO watchKitExtension:nil];
			}
			
			[[%c(WeatherPreferences) sharedPreferences] setLocalWeatherEnabled:YES];
			[weatherLocationManager setLocationTrackingActive:YES];
			[[%c(TWCLocationUpdater) sharedLocationUpdater] updateWeatherForLocation:[weatherLocationManager location] city:localCity];
			[weatherLocationManager setLocationTrackingActive:NO];
		} else {
			if ([[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"] count] > 0) {
				localCity = [[%c(WeatherPreferences) sharedPreferences] cityFromPreferencesDictionary:[[[%c(WeatherPreferences) userDefaultsPersistence]userDefaults] objectForKey:@"Cities"][0]];
				[[%c(TWCCityUpdater) sharedCityUpdater] updateWeatherForCity:localCity];
			} else {
				if (!noCitiesMessage) {
					noCitiesMessage = YES;
					UIAlertView *reminderAlert = [[UIAlertView alloc ] initWithTitle:@"LockWatch - Weather"
																			 message:@"Loading Weather data failed. You probably don't have any cities set up. If you're on an iPad, switch \"Location Services\" on in LockWatch Settings."
																			delegate:nil
																   cancelButtonTitle:@"Ok"
																   otherButtonTitles:nil];
					[reminderAlert show];
					[[NSNotificationCenter defaultCenter] postNotificationName:@"weatherError" object:self userInfo:nil];
				}
			}
		}
		
		
		fcsthourly24short = [[NSMutableArray alloc] init];
		
		NSMutableArray *hourlyForecasts  = [localCity hourlyForecasts];
		
		if ([hourlyForecasts count] > 0) {
			BOOL isCelsius = [[%c(WeatherPreferences) sharedPreferences] isCelsius];
			
			for (int i=0; i<[hourlyForecasts count]; i++) {
				NSMutableDictionary* dataDict = [[NSMutableDictionary alloc] init];
				HourlyForecast* fcst = (HourlyForecast*)[hourlyForecasts objectAtIndex:i];
				
				[dataDict setValue:[NSNumber numberWithInt:fcst.conditionCode] forKey:@"icon_cd"];
				[dataDict setValue:[NSNumber numberWithFloat:fcst.percentPrecipitation] forKey:@"pop"];
				
				if (isCelsius) {
					int celsius = [fcst.detail intValue];
					int fahrenheit = [fcst.detail intValue]*1.8+32;
					
					[dataDict setObject:@{ @"temp": @(celsius) } forKey:@"metric"];
					[dataDict setObject:@{ @"temp": @(fahrenheit) } forKey:@"imperial"];
				} else {
					int celsius = ([fcst.detail intValue]-32)/1.8;
					int fahrenheit = [fcst.detail intValue];
					
					[dataDict setObject:@{ @"temp": @(celsius) } forKey:@"metric"];
					[dataDict setObject:@{ @"temp": @(fahrenheit) } forKey:@"imperial"];
				}
				[dataDict setObject:fcst.time forKey:@"fcst_valid_local"];
				[fcsthourly24short addObject:dataDict];
				//NSLog(@"[LockWatch] %d", fcst.conditionCode);
			}
			
			NSMutableDictionary* temp = [[NSMutableDictionary alloc] init];
			
			int temperature = [[localCity temperature] intValue];
			if (isCelsius) {
				int temperature_c = temperature;
				int temperature_f = temperature*1.8+32;
				[temp setObject:@{ @"temp": @(temperature_c) } forKey:@"metric"];
				[temp setObject:@{ @"temp": @(temperature_f) } forKey:@"imperial"];
			} else {
				int temperature_c = (temperature-32)/1.8;
				int temperature_f = temperature;
				[temp setObject:@{ @"temp": @(temperature_c) } forKey:@"metric"];
				[temp setObject:@{ @"temp": @(temperature_f) } forKey:@"imperial"];
			}
			
			//NSLog(@"[LockWatch] %@", fcsthourly24short);
			NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
			[dict setObject:temp forKey:@"conditionsshort"];
			[dict setObject:fcsthourly24short forKey:@"fcsthourly24short"];
			[dict setObject:localCity.name forKey:@"cityName"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"weatherExternalData" object:self userInfo:dict];
		} else {
			if (!noCitiesMessage && !failedMessage) {
				failedMessage = YES;
				UIAlertView *reminderAlert = [[UIAlertView alloc ] initWithTitle:@"LockWatch - Weather"
																		 message:@"Loading Weather data failed. I can't explain why."
																		delegate:nil
															   cancelButtonTitle:@"Ok"
															   otherButtonTitles:nil];
				[reminderAlert show];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"weatherError" object:self userInfo:nil];
			}
		}
	}
	return self;
}

@end
