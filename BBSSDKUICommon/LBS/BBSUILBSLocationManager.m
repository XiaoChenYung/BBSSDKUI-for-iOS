//
//  BBSUILBSLocationManager.m
//  BBSSDKUI_WF
//
//  Created by wukx on 2018/4/16.
//  Copyright © 2018年 MOB. All rights reserved.
//

#import "BBSUILBSLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface BBSUILBSLocationManager()<CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation BBSUILBSLocationManager

+ (BBSUILBSLocationManager *)shareManager
{
    static BBSUILBSLocationManager *obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[BBSUILBSLocationManager alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        if ([CLLocationManager locationServicesEnabled] == YES) {
            _locationManager = [[CLLocationManager alloc] init];
            [_locationManager requestWhenInUseAuthorization];
            _locationManager.delegate = self;
            _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            _locationManager.distanceFilter = kCLDistanceFilterNone;
            _locationManager.pausesLocationUpdatesAutomatically = NO;
            _locationManager.activityType = CLActivityTypeFitness;
        }
    }
    return self;
}

- (BOOL)isOpenLocationServices
{
    if ([CLLocationManager locationServicesEnabled])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)startLocation
{
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)stopLocation
{
    [_locationManager stopUpdatingLocation];
    [_locationManager stopUpdatingHeading];
}

#pragma mark - CLLocationManagerDelegate


/**
 更新用户位置

 @param manager  manager
 @param locations locations
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self stopLocation];
    CLLocation *location = [locations lastObject];
    CLLocationCoordinate2D coor = location.coordinate;
    self.latitude = coor.latitude;
    self.lontitue = coor.longitude;
}


/**
 更新用户方向

 @param manager  manager
 @param newHeading newHeading
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    
}

/**
 定位失败

 @param manager  manager
 @param error error
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}



/**
 更改用户授权状态

 @param manager  manager
 @param status status
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

@end
