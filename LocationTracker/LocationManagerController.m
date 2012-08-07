//
//  LocationManagerController.m
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//
// References:
//
// Singletons in Cocoa/Objective-C
// http://eschatologist.net/blog/?p=178

#import "LocationManagerController.h"
#import "Event.h"

#pragma mark - Private methods and constants.
@interface LocationManagerController ()

- (void)initLocationManager;
- (void)initListener;
- (void)startLocationUpdateTask;
- (void)stopLocationUpdateTask;
- (void)startDidFailWithErrorTask;
- (void)stopDidFailWithErrorTask;
- (void)update:(NSNotification*)notification;
- (void)updateDataStore:(CLLocation *)location;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) UIBackgroundTaskIdentifier locationUpdateTask;
@property (nonatomic, assign) UIBackgroundTaskIdentifier didFailWithErrorTask;
@property (nonatomic, retain) UIApplication *application;
@property (nonatomic, retain) dispatch_queue_t locationUpdateQueue;

@end

@implementation LocationManagerController

@synthesize locationManager = _locationManager,
            locationAccuracy = _locationAccuracy,
            isUpdatingLocation = _isUpdatingLocation,
            isMonitoringSignificantLocationChanges = _isMonitoringSignificantLocationChanges,
            locationUpdateTask = _locationUpdateTask,
            application = _application,
            bestEffortAtLocation = _bestEffortAtLocation,
            desiredAccuracy = _desiredAccuracy,
            managedObjectContext = _managedObjectContext;

static LocationManagerController *sharedInstance = nil;

#pragma mark - Public API
- (void)start
{
    NSLog(@"LocationManagerController::start");
    if (![CLLocationManager locationServicesEnabled])
    {
        NSLog(@"Location services disabled, this will re-prompt user.");
    }
    [[self locationManager] startUpdatingLocation];
    self.isUpdatingLocation = YES;
}

- (void)stop
{
    NSLog(@"LocationManagerController::stop");
    [[self locationManager] stopUpdatingLocation];
    self.isUpdatingLocation = NO;
}

- (void)startSignificant
{
    NSLog(@"LocationManagerController::startSignificant");
    [[self locationManager] startMonitoringSignificantLocationChanges];
    self.isMonitoringSignificantLocationChanges = YES;
}

- (void)stopSignificant
{
    NSLog(@"LocationManagerController::stopSignificant");
    [[self locationManager] stopMonitoringSignificantLocationChanges];
    self.isMonitoringSignificantLocationChanges = NO;
}

#pragma mark - Lazy getters
- (CLLocationManager *)locationManager
{
    if (_locationManager != nil)
        return _locationManager;
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = self.locationAccuracy;
    _locationManager.activityType = CLActivityTypeFitness;
    _locationManager.delegate = self;
    return _locationManager;
}

#pragma mark - Location manager delegate protocol and helpers
- (void)startLocationUpdateTask
{
    self.locationUpdateTask = [self.application beginBackgroundTaskWithExpirationHandler:^{
        [self stopLocationUpdateTask];
    }];
    
}

- (void)stopLocationUpdateTask
{
    [self.application endBackgroundTask:self.locationUpdateTask];
    self.locationUpdateTask = UIBackgroundTaskInvalid;
    
}

- (void)startDidFailWithErrorTask
{
    self.didFailWithErrorTask = [self.application beginBackgroundTaskWithExpirationHandler:^{
        [self stopDidFailWithErrorTask];
    }];
    
}

- (void)stopDidFailWithErrorTask
{
    [self.application endBackgroundTask:self.didFailWithErrorTask];
    self.didFailWithErrorTask = UIBackgroundTaskInvalid;
    
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    [self startLocationUpdateTask];
    dispatch_async(self.locationUpdateQueue,
    ^{
        NSLog(@"LocationManager::didUpdateToLocation. newLocation: %@", newLocation);
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        // Don't care about invalid readings, usually the first one is.
        if (newLocation.horizontalAccuracy < 0)
        {
            NSLog(@"Invalid location.");
        }
        
        // Don't care about old readings, usually a burst at the beginning are.
        else if (locationAge > 5.0)
        {
            NSLog(@"Old location.");
        }
        
        // If we're here because of a significant update it won't be accurate enough.
        // Turn regular updates back on.
        else if ((self.isMonitoringSignificantLocationChanges) &&
                 !(self.isUpdatingLocation))
        {
            NSLog(@"Significant location change.");
            self.bestEffortAtLocation = nil;
            [self start];
            [self stopSignificant];
        }
        
        // Don't care about readings that aren't at the required accuracy.
        // This depends on whether we've attempted to measure before.
        else if (self.bestEffortAtLocation == nil)
        {
            NSLog(@"No previous best effort.");
            self.bestEffortAtLocation = newLocation;
        }
        else if (self.bestEffortAtLocation.horizontalAccuracy <= self.desiredAccuracy.doubleValue)
        {
            NSLog(@"bestEffort not too old, and accurate enough, so nothing new.");
            if (self.isUpdatingLocation)
            {
                NSLog(@"Switch to significant change monitoring.");
                [self stop];
                [self startSignificant];
            }
            [self updateDataStore:self.bestEffortAtLocation];
            self.bestEffortAtLocation = nil;
        }
        else if (self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy)
        {
            NSLog(@"Best effort location is better.");
            self.bestEffortAtLocation = newLocation;
            if (self.bestEffortAtLocation.horizontalAccuracy <= self.desiredAccuracy.doubleValue)
            {
                NSLog(@"bestEffort is accurate enough.");
                if (self.isUpdatingLocation)
                {
                    NSLog(@"Switch to significant change monitoring.");
                    [self stop];
                    [self startSignificant];
                }
                [self updateDataStore:self.bestEffortAtLocation];
                self.bestEffortAtLocation = nil;
            }
        }
        
        [self stopLocationUpdateTask];
    });
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self startDidFailWithErrorTask];
    dispatch_async(self.locationUpdateQueue,
    ^{
        // Unknown error means we're unable to get the current location, that's fine.
        // Else just stop getting the location.
        NSLog(@"LocationManager::didFailWithError. error: %@", error);
        if (error.code != kCLErrorLocationUnknown)
        {
            NSLog(@"Critical error, stop gathering location.");
            [self stop];
            [self stopSignificant];
        }
        [self stopDidFailWithErrorTask];
    });
}

- (void)updateDataStore:(CLLocation *)location
{
    // This updates the Core Data model with the current best location.
    NSLog(@"updateDataStore entry. location: %@", location);
    Event *event = (Event *)[NSEntityDescription
                             insertNewObjectForEntityForName:@"Event"
                                      inManagedObjectContext:self.managedObjectContext];
    CLLocationCoordinate2D coordinate = location.coordinate;
    event.latitude = $double(coordinate.latitude);
    event.longitude = $double(coordinate.longitude);
    event.horizontalAccuracy = $double(location.horizontalAccuracy);
    event.timestamp = location.timestamp;
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error])
    {
        NSLog(@"Error while saving: %@", error);
        // !!AI Handle the error.
    }
}

#pragma mark - Singleton methods, lifecycle.
+ (void)initialize
{
    if (self == [LocationManagerController class])
    {
        sharedInstance = [[self alloc] init];
    }
}

+ (LocationManagerController *)sharedInstance
{
    return sharedInstance;
}

- (LocationManagerController *)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    [self initLocationManager];
    [self initListener];
    self.application = [UIApplication sharedApplication];
    return self;
}

- (void)initLocationManager
{
    self.locationAccuracy = kCLLocationAccuracyBest;
    self.desiredAccuracy = $float(10.0);
    
    // Note: this is a serial GCD queue. This get around nasty race conditions when
    // spawning lots of background tasks when running in the background.
    self.locationUpdateQueue = dispatch_queue_create("com.ai.locationUpdateQueue", NULL);
    
    
    self.bestEffortAtLocation = nil;
    [self stop];
    [self stopSignificant];
}

- (void)initListener
{
    // Listen for 'did become active' of application
    [[NSNotificationCenter defaultCenter] addObserver: self
                                            selector: @selector(update:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    
    // Listen for application enters background
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(update:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
}

- (void)dealloc
{
    [self stop];
    [self stopSignificant];
    self.locationUpdateQueue = nil;
}

#pragma mark - Notification-trigger update.
- (void)update:(NSNotification *)notification
{
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    if ([notification.name isEqualToString:UIApplicationDidBecomeActiveNotification])
    {
        // On restart of app if we were monitoring significant location changes then resume regular
        // monitoring.
        if ((locationServicesEnabled) &&
            (self.isMonitoringSignificantLocationChanges || self.isUpdatingLocation))
        {
            [self start];
        }
        [self stopSignificant];
    }
    else if ([notification.name isEqualToString:UIApplicationDidEnterBackgroundNotification])
    {
        // On entering background if we were monitoring location then start monitoring for
        // significant changes instead.
        if ((locationServicesEnabled) &&
            (self.isMonitoringSignificantLocationChanges || self.isUpdatingLocation))
        {
            [self startSignificant];
        }
        [self stop];
    }
    //
}

@end
