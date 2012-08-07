//
//  PreferencesViewController.m
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import "PreferencesViewController.h"
#import "LocationManagerController.h"

#pragma mark - Private methods and constants.
@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

// ----------------------------------------------------
//  Synthesize properties.
// ----------------------------------------------------
@synthesize enabledSwitchInput = _enabledSwitchInput,
            fetchedResultsController = _fetchedResultsController,
            managedObjectContext = _managedObjectContext,
            delegate = _delegate,
            locationManagerController = _locationManagerController;
// ----------------------------------------------------

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (!self)
        return nil;
    return self;
}

- (void)viewDidLoad
{
    self.locationManagerController = [LocationManagerController sharedInstance];
    if ((self.locationManagerController.isUpdatingLocation) ||
        (self.locationManagerController.isMonitoringSignificantLocationChanges))
    {
        NSLog(@"PreferencesViewController::viewDidLoad, locationManagerController is monitoring location.");
        self.enabledSwitchInput.on = YES;
    }
    else
    {
        NSLog(@"PreferencesViewController::viewDidLoad, locationManagerController is not monitoring location.");
        self.enabledSwitchInput.on = NO;
    }
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    self.locationManagerController = nil;
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)enabledSwitchValueChanged:(id)sender {
    if (self.enabledSwitchInput.isOn == YES)
    {
        NSLog(@"Enabling location tracking.");
        [self.locationManagerController start];
        [self.locationManagerController stopSignificant];
    }
    else
    {
        NSLog(@"Disabling location tracking.");
        [self.locationManagerController stop];
        [self.locationManagerController stopSignificant];
    }
}

- (IBAction)done:(id)sender {
    NSLog(@"PreferencesViewController::done entry. sender: %@, delegate: %@", sender, self.delegate);
    [self.delegate preferencesViewControllerDidFinish:self];
}
@end
