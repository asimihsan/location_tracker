//
//  DataViewController.m
//  LocationTracker
//
//  Created by Asim Ihsan on 06/08/2012.
//  Copyright (c) 2012 Asim Ihsan. All rights reserved.
//

#import "DataViewController.h"
#import "Event.h"

@interface DataViewController ()

- (void)getData;

@end

@implementation DataViewController

// ----------------------------------------------------
//  Synthesize properties.
// ----------------------------------------------------
@synthesize fetchedResultsController = _fetchedResultsController,
            managedObjectContext = _managedObjectContext,
            delegate = _delegate,
            data = _data,
            dateFormatter = _dateFormatter,
            numberFormatter = _numberFormatter;
// ----------------------------------------------------

// ----------------------------------------------------
//  Lazy getters.
// ----------------------------------------------------
- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter != nil)
        return _dateFormatter;
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return _dateFormatter;
}

- (NSNumberFormatter *)numberFormatter
{
    if (_numberFormatter != nil)
        return _numberFormatter;
    _numberFormatter = [[NSNumberFormatter alloc] init];
    [_numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [_numberFormatter setMaximumFractionDigits:6];
    return _numberFormatter;
}
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
    [self getData];
    [super viewDidLoad];
}

- (void)getData
{
    // Create the fetch request.
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"Event"
                                   inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    // Sort by timestamp.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"timestamp"
                                        ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    // Execute the request.
    NSError *error = nil;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext
                                            executeFetchRequest:request
                                                          error:&error] mutableCopy];
    if (mutableFetchResults == nil)
    {
        NSLog(@"Error during fetch of results.");
        // Handle the error.
        self.data = [[NSArray alloc] init];
        return;
    }
    self.data = [[NSArray alloc] initWithArray:mutableFetchResults];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Dequeue prototype cell.
    static NSString *CellIdentifier = @"DataCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil)
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:@"DataCell"];
    
    // Read Event from Core Data, populate cell.
    Event *event = (Event *)[self.data objectAtIndex:indexPath.row];
    cell.textLabel.text = [[self dateFormatter] stringFromDate:event.timestamp];
    NSString *string = [NSString stringWithFormat:@"%@, %@",
                        [[self numberFormatter] stringFromNumber:event.latitude],
                        [[self numberFormatter] stringFromNumber:event.longitude]];
    cell.detailTextLabel.text = string;
    return cell;
}

- (IBAction)done:(id)sender {
    [self.delegate dataViewControllerDidFinish:self];
}
@end
