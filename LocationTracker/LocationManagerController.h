//
//  LocationManagerController.h
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ConciseKit.h"

#pragma mark - Public API methods and properties
@interface LocationManagerController : NSObject
<CLLocationManagerDelegate>

+ (LocationManagerController *)sharedInstance;

- (void)start;
- (void)stop;
- (void)startSignificant;
- (void)stopSignificant;

@property (nonatomic, assign) CLLocationAccuracy locationAccuracy;
@property (nonatomic, retain) NSNumber *desiredAccuracy;
@property (nonatomic, assign) BOOL isUpdatingLocation;
@property (nonatomic, assign) BOOL isMonitoringSignificantLocationChanges;
@property (atomic, retain) CLLocation *bestEffortAtLocation;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
