//
//  LWWatchFaceBase.h
//  LockWatch
//
//  Created by Janik Schmidt on 01.12.15.
//  Copyright © 2015 Janik Schmidt (Sniper_GER). All rights reserved.
//

#import "WatchFaceBase.h"
#import <CoreLocation/CoreLocation.h>

@interface LWWatchFaceWeather : WatchFaceBase <CLLocationManagerDelegate> {
    UILabel* cityName;
    UILabel* clock;
    UILabel* tempLabel;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    
    UIView* weatherIconView;
    
    float locationLat;
    float locationLon;
    
    id conditionsshort;
    id fcsthourly24short;
    
    BOOL deinit;
    
    NSTimer* updateDisplayTimer;
}

@end
