//
//  LocationShareModel.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import "LocationManager.h"
#import <UIKit/UIKit.h>


@interface LocationManager () <CLLocationManagerDelegate>

@end


@implementation LocationManager

//Class method to make sure the share model is synch across the app
+ (id)sharedManager {
    static id sharedMyModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedMyModel = [[self alloc] init];
    });
    
    return sharedMyModel;
}


#pragma mark - CLLocationManager

- (void)startMonitoringLocation {
    if (_anotherLocationManager)
        [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.anotherLocationManager = [[CLLocationManager alloc]init];
    _anotherLocationManager.delegate = self;
    _anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    
    if(IS_OS_8_OR_LATER) {
        [_anotherLocationManager requestAlwaysAuthorization];
    }
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}

- (void)restartMonitoringLocation {
    [_anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if (IS_OS_8_OR_LATER) {
        [_anotherLocationManager requestAlwaysAuthorization];
    }
    [_anotherLocationManager startMonitoringSignificantLocationChanges];
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    NSLog(@"locationManager didUpdateLocations: %@",locations);
    
    for (int i = 0; i < locations.count; i++) {
        
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        self.myLocation = theLocation;
        self.myLocationAccuracy = theAccuracy;
    }
    
    [self addLocationToPList:_afterResume];
}



#pragma mark - Plist helper methods

// Below are 3 functions that add location and Application status to PList
// The purpose is to collect location information locally

- (NSString *)appState {
    UIApplication* application = [UIApplication sharedApplication];

    NSString * appState;
    if([application applicationState]==UIApplicationStateActive)
        appState = @"UIApplicationStateActive";
    if([application applicationState]==UIApplicationStateBackground)
        appState = @"UIApplicationStateBackground";
    if([application applicationState]==UIApplicationStateInactive)
        appState = @"UIApplicationStateInactive";
    
    return appState;
}

- (void)addResumeLocationToPList {
    
    NSLog(@"addResumeLocationToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:@"UIApplicationLaunchOptionsLocationKey" forKey:@"Resume"];
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}



- (void)addLocationToPList:(BOOL)fromResume {
    NSLog(@"addLocationToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.latitude]  forKey:@"Latitude"];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocation.longitude] forKey:@"Longitude"];
    [_myLocationDictInPlist setObject:[NSNumber numberWithDouble:self.myLocationAccuracy] forKey:@"Accuracy"];
    
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    
    if (fromResume) {
        [_myLocationDictInPlist setObject:@"YES" forKey:@"AddFromResume"];
    } else {
        [_myLocationDictInPlist setObject:@"NO" forKey:@"AddFromResume"];
    }
    
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}

- (void)addApplicationStatusToPList:(NSString*)applicationStatus {
    
    NSLog(@"addApplicationStatusToPList");
    
    NSString * appState = [self appState];
    
    self.myLocationDictInPlist = [[NSMutableDictionary alloc]init];
    [_myLocationDictInPlist setObject:applicationStatus forKey:@"applicationStatus"];
    [_myLocationDictInPlist setObject:appState forKey:@"AppState"];
    [_myLocationDictInPlist setObject:[NSDate date] forKey:@"Time"];
    
    [self saveLocationsToPlist];
}

- (void)saveLocationsToPlist {
    NSString *plistName = [NSString stringWithFormat:@"LocationArray.plist"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docDir, plistName];
    
    NSMutableDictionary *savedProfile = [[NSMutableDictionary alloc] initWithContentsOfFile:fullPath];
    
    if (!savedProfile) {
        savedProfile = [[NSMutableDictionary alloc] init];
        self.myLocationArrayInPlist = [[NSMutableArray alloc]init];
    } else {
        self.myLocationArrayInPlist = [savedProfile objectForKey:@"LocationArray"];
    }
    
    if(_myLocationDictInPlist) {
        [_myLocationArrayInPlist addObject:_myLocationDictInPlist];
        [savedProfile setObject:_myLocationArrayInPlist forKey:@"LocationArray"];
    }
    
    if (![savedProfile writeToFile:fullPath atomically:FALSE]) {
        NSLog(@"Couldn't save LocationArray.plist" );
    }
}


@end
