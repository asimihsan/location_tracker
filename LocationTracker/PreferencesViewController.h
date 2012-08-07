//
//  PreferencesViewController.h
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LocationManagerController;

@protocol PreferencesViewControllerDelegate;

@interface PreferencesViewController : UITableViewController

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <PreferencesViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UISwitch *enabledSwitchInput;
@property (strong, nonatomic) LocationManagerController *locationManagerController;

- (IBAction)enabledSwitchValueChanged:(id)sender;
- (IBAction)done:(id)sender;

@end

@protocol PreferencesViewControllerDelegate <NSObject>

- (void)preferencesViewControllerDidFinish:(PreferencesViewController *)controller;

@end
