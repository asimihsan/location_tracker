//
//  MainMenuViewController.m
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import "MainMenuViewController.h"
#import "PreferencesViewController.h"
#import "DataViewController.h"
#import "LocationManagerController.h"

#pragma mark - Private methods and constants.
@interface MainMenuViewController ()
<PreferencesViewControllerDelegate, DataViewControllerDelegate>

@end

@implementation MainMenuViewController

// ----------------------------------------------------
//  Synthesize properties.
// ----------------------------------------------------
@synthesize fetchedResultsController = _fetchedResultsController,
            managedObjectContext = _managedObjectContext;
// ----------------------------------------------------

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues and delegates

- (void)preferencesViewControllerDidFinish:(PreferencesViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dataViewControllerDidFinish:(DataViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowPreferences"])
    {
        UINavigationController *aNavigationController =
            (UINavigationController *)segue.destinationViewController;
        PreferencesViewController *preferencesViewController =
            (PreferencesViewController *)[aNavigationController.viewControllers $first];
        preferencesViewController.managedObjectContext = self.managedObjectContext;
        preferencesViewController.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ShowData"])
    {
        UINavigationController *aNavigationController =
            (UINavigationController *)segue.destinationViewController;
        DataViewController *dataViewController =
            (DataViewController *)[aNavigationController.viewControllers $first];
        dataViewController.managedObjectContext = self.managedObjectContext;
        dataViewController.delegate = self;
    }
}

@end
