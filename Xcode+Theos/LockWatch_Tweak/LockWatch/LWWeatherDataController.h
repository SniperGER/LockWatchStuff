//
//  LWWeatherDataController.h
//  LockWatch_Tweak
//
//  Created by Janik Schmidt on 19.02.16.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Weather/HourlyForecast.h>
#import <Weather/DayForecast.h>

@interface City : NSObject
@property (nonatomic,copy) NSString * name; 
-(NSMutableArray*)hourlyForecasts;
-(NSMutableArray*)dayForecasts;
-(unsigned long long)conditionCode;
-(NSString *)temperature;
-(unsigned long long)sunriseTime;
-(unsigned long long)sunsetTime;
-(BOOL)isDay;
-(NSDate*) updateTime;
@end

@interface WeatherPreferences : NSObject
+(id)sharedPreferences;
+(id)userDefaultsPersistence;
-(NSDictionary*)userDefaults;
-(City*)localWeatherCity;
-(void)setLocalWeatherEnabled:(BOOL)arg1;
-(City*)cityFromPreferencesDictionary:(id)arg1;
-(BOOL)isCelsius;
@end

@interface WeatherLocationManager : NSObject
+(id)sharedWeatherLocationManager;
-(BOOL)locationTrackingIsReady;
-(void)setLocationTrackingReady:(BOOL)arg1 activelyTracking:(BOOL)arg2 watchKitExtension:(id)arg3;
-(void)setLocationTrackingActive:(BOOL)arg1;
-(CLLocation*)location;
-(void)setDelegate:(id)arg1;
@end

@interface TWCLocationUpdater : NSObject
+(id)sharedLocationUpdater;
-(void)updateWeatherForLocation:(CLLocation*)arg1 city:(City*)arg2;
@end

@interface TWCCityUpdater : NSObject
+(id)sharedCityUpdater;
-(void)updateWeatherForCity:(City*)arg1;
@end


@interface LWWeatherDataController : NSObject {
	id conditionsshort;
	NSMutableArray* fcsthourly24short;
}

@end
