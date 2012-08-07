//
//  DataViewController.h
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@protocol DataViewControllerDelegate;

@interface DataViewController : UITableViewController
<NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (weak, nonatomic) id <DataViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *data;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@property (nonatomic, retain) NSNumberFormatter *numberFormatter;

- (IBAction)done:(id)sender;

@end

@protocol DataViewControllerDelegate <NSObject>

- (void)dataViewControllerDidFinish:(DataViewController *)controller;

@end
