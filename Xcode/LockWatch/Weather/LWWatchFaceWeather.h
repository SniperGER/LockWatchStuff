//
//  LWWatchFaceWeather.h
//  LockWatch
//
//  Created by Janik Schmidt on 28.01.16.
//  Copyright © 2016 Janik Schmidt. All rights reserved.
//

#import <LWWatchFace/LWWatchFace.h>
#import "LWWatchFaceWeatherIndicator.h"
#import <CoreLocation/CoreLocation.h>

@interface LWWatchFaceWeather : LWWatchFace<CLLocationManagerDelegate> {
    UILabel* cityName;
    UILabel* clock;
    UILabel* tempLabel;
    NSString* woeid;
    UIImageView* umbrella;
    UILabel* umbrellaLabel;
    
    UIView* tempLabelContainer;
    UIView* popLabelContainer;
    
    BOOL fahrenheit;
    BOOL deinit;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    float locationLat;
    float locationLon;
    
    id conditionsshort;
    id fcsthourly24short;
    double conditionsshortExpire;
    double fcsthourly24shortExpire;
    NSTimer* newWeatherTimer;
    
    NSTimer* updateDisplayTimer;
    UIView* weatherIconView;
    
    UIView* customizeColors;
    
    UIView* currentHourIndicator;
    
    UIActivityIndicatorView* activity;
    LWWatchFaceWeatherIndicator* circularIndicator;
}

@property NSString* actualCityName;
@property NSString* actualTemp;

@end
