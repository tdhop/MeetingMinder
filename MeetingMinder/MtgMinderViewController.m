//
//  MtgMinderViewController.m
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/2/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import "MtgMinderViewController.h"
#import "AgendaItemVCViewController.h"
#import <math.h>

#pragma mark Agenda Dictionary Keys
// Define keys for agenda items
#define AGENDA_NAME @"Agenda Name"
#define AGENDA_TIME @"Agenda Time"

@interface MtgMinderViewController ()

// Reference for the tableview on this screen
@property (strong, nonatomic) UITableView *agendaTableView;

#pragma mark Declare Agenda Properties

// Properties to store agenda
@property (strong, nonatomic) NSURL *agendaStorageURL; // Where the Agenda array will be stored
@property (strong, nonatomic) NSMutableArray *agenda; // Holder for array of agenda items
@property (strong, nonatomic) NSMutableDictionary *inFocusAgendaItem; // pointer to current in-focus agenda item in the agenda array
// Properties to store inFocus agenda information
@property (strong, nonatomic) NSString *inFocusAgendaName; // temp (working) copy of agenda name
@property NSTimeInterval inFocusAgendaTimeInSeconds; // temp (working) copy of agenda time
@property NSIndexPath *inFocusIndexPath; // pointer to current in focus agenda item

#pragma mark Declare Table Properties

// Properties for interacting with AgendaItemVCViewController
@property (strong, nonatomic) NSIndexPath *detailEditRow; // Keeps track of most recently tapped row OR new item

@end

@implementation MtgMinderViewController

// synthesize all properties
@synthesize mainAgendaLabel = _mainAgendaLabel;
@synthesize timeLabel=_timeLabel;
@synthesize agendaTableView = _agendaTableView;
@synthesize agendaStorageURL = _agendaStorageURL;
@synthesize inFocusAgendaItem = _inFocusAgendaItem;
@synthesize inFocusAgendaName = _inFocusAgendaName;
@synthesize inFocusAgendaTimeInSeconds = _inFocusAgendaTimeInSeconds;
@synthesize inFocusIndexPath = _inFocusIndexPath;
@synthesize agenda = _agenda;
@synthesize detailEditRow = _detailEditRow; // The row whose detail disclosure was tapped OR new item



#pragma mark - View Management Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // INITIALIZE TABLE PROPERTIES
    
    self.agendaTableView = (UITableView *) [self.view viewWithTag:1];
    
    // INITIALIZE AGENDA ITEM STORAGE
    
    // Get the URL for agenda item storage    
    NSArray *tempURLs = [[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains:NSUserDomainMask]; // An array because it returns all matching directories in the domain -- but since this is my sandbox, I should only see one and it is in location 0 of the array (or "lastObject")
    self.agendaStorageURL = [tempURLs lastObject];
    self.agendaStorageURL = [self.agendaStorageURL URLByAppendingPathComponent:@"Agenda.dat"];
    
    // Read in the stored agenda - or initialize an empty one if there is no stored agenda
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.agendaStorageURL path]]) {
        self.agenda = [NSMutableArray arrayWithContentsOfURL:self.agendaStorageURL];
    } else {
        NSLog(@"This is where I need to initialize an empty agenda array");
        self.agenda = [NSMutableArray arrayWithCapacity:5]; // Chose capacity of 5 somewhat randomly
        // FOLLOWING CODE SETS UP A DUMMY AGENDA ITEM, REMOVE THIS CODE WHEN IMPLEMENTING "ADD AGENDA ITEM" FUNCTIONALITY
        NSMutableDictionary *dummyAgendaItem = [NSMutableDictionary dictionaryWithCapacity:2];
        [dummyAgendaItem setValue:[NSNumber numberWithDouble:5] forKey:AGENDA_TIME];
        [dummyAgendaItem setValue:@"Dummy Item" forKey:AGENDA_NAME];
        [self.agenda addObject:dummyAgendaItem];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Agenda Control

// Set context to first agenda item then call startTimer
- (IBAction)startMeeting:(id)sender {
    // Put Start Meeting code here
}

// Respond to Next button press by starting timer on next agenda item
- (IBAction)nextItem:(id)sender {
    // Put nextItem code here
}

#pragma mark - Timer Display

// Timer control variables

int currentTime; // Stores current countdown value

NSTimer *myTimer; // The timer object I will use

NSDate *lastDate; // will use this to calculate time interval from timer



// The following are used to control the countdown timer display
- (IBAction)startTimer:(id)sender {
  
    // Make sure that timer is not already running.  If it is, clean up
    // FOR NOW I AM ONLY GOING TO RESTART THE TIMER, NOT WORRYING ABOUT OTHER CLEAN-UP
    [myTimer invalidate];
    
    // Set up working copies of in-focus agenda information to point to 1st agenda item
    self.inFocusIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.inFocusAgendaItem = [self.agenda objectAtIndex:self.inFocusIndexPath.row];
    self.inFocusAgendaName = [self.inFocusAgendaItem objectForKey:AGENDA_NAME];
    self.inFocusAgendaTimeInSeconds = [[self.inFocusAgendaItem objectForKey:AGENDA_TIME] doubleValue];
    
    // Set up main label to reflect current agenda item
    self.mainAgendaLabel.text = self.inFocusAgendaName;
    
    currentTime = self.inFocusAgendaTimeInSeconds; // Initialize timer to start of agenda item
    self.timeLabel.text = [self stringFromTimeInterval:currentTime];
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(updateTimer:) userInfo:nil repeats:YES];
    lastDate = [NSDate date];

    // Set lagel for button to "Restart Meeting
    UIButton *myButton = sender;
    [myButton setTitle:@"Restart Meeting" forState:UIControlStateNormal];
    NSLog(@"Starting Timer, currentTime = %d", currentTime);
    
    
}

- (void) updateTimer:(id)sender {
    
    NSTimeInterval timerInterval;
    
    timerInterval = [[NSDate date] timeIntervalSinceDate:lastDate];
    int decrement = roundf(timerInterval); // makes sure I always decrement by exactly one second
    currentTime -= decrement;
    self.timeLabel.text = [self stringFromTimeInterval:currentTime];
    lastDate = [NSDate date];
    if (currentTime == 0) {
        [myTimer invalidate];
    }
    NSLog(@"Updating Timer, currentTime = %d", currentTime);
}

#pragma mark - Update Agenda Items (delegate methods)

// Add an agenda item
- (IBAction)addAgendaItem:(id)sender {
    
    // First, add an empty agenda item to the agenda array
    NSMutableDictionary *newAgendaItem = [NSMutableDictionary dictionaryWithCapacity:2];
    [newAgendaItem setValue:[NSNumber numberWithDouble:0] forKey:AGENDA_TIME];
    [newAgendaItem setValue:@"New Item" forKey:AGENDA_NAME];
    [self.agenda addObject:newAgendaItem];
    
    // Now set in focus agenda to this item
    self.inFocusIndexPath = [NSIndexPath indexPathForRow:[self.agenda count]-1 inSection:0];
    self.inFocusAgendaItem = [self.agenda lastObject];
    self.inFocusAgendaName = [newAgendaItem objectForKey:AGENDA_NAME];
    self.inFocusAgendaTimeInSeconds = [[newAgendaItem objectForKey:AGENDA_TIME] doubleValue];
    self.detailEditRow = [NSIndexPath indexPathForRow:[self.agenda count]-1 inSection:0];
    
    
    // Now store the new agenda array
    [self.agenda writeToURL:self.agendaStorageURL atomically:YES];
    
    // Now reload the table so it will show with new item even if user does not enter any info for it
    [self.agendaTableView reloadData];
    
    // Now go to agenda detail
    [self performSegueWithIdentifier:@"AgendaItemDetail" sender:self];
}

// Remove the in focus agenda item from the agenda
- (void) deleteItem: (id) sender {
    [self.agenda removeObjectAtIndex:self.detailEditRow.row];
    // Now the in focus agenda item information is out of date so fix that
    // IS nil GOING TO BE A PROBLEM FOR THIS???
    self.inFocusAgendaItem = nil;
    self.inFocusAgendaName = nil;
    self.inFocusAgendaTimeInSeconds = 0;
    self.inFocusIndexPath = nil;
    
    // Now save the new agenda
    [self.agenda writeToURL:self.agendaStorageURL atomically:YES];

    // Now reload the table with the item removed
    [self.agendaTableView reloadData];
}


// The following are used to receive information back from AgendaItemVCViewController
// Delegate method: Update selected agenda item time duration in seconds
- (void) updateItemTime:(NSTimeInterval) timeInterval sender:(id)sender {
    NSLog(@"This is where I will update the item time for selected cell");
    NSMutableDictionary *agendaItem = [self.agenda objectAtIndex:self.detailEditRow.row];
    
    NSNumber *interval = [NSNumber numberWithDouble:timeInterval];
    [agendaItem setValue:interval forKey:AGENDA_TIME];
    
    // Now store the new agenda array
    [self.agenda writeToURL:self.agendaStorageURL atomically:YES];
    
    // Now update the agenda time shown in the current table cell
    UITableViewCell *cell = [self.agendaTableView cellForRowAtIndexPath:self.detailEditRow];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%f",timeInterval];
    
    // Now reload the table with new value
    [self.agendaTableView reloadData];
    
    // NOTE: WILL ALSO NEED TO STORE WHEN USER CHANGES AGENDA ORDER
}

// Delegate method: Update selected agenda name
- (void) updateItemName:(NSString *)newName sender:(id)sender {
    NSLog(@"Updating selected agenda name");
    
    // Update the agenda item array
    NSMutableDictionary *agendaItem = [self.agenda objectAtIndex:self.detailEditRow.row];
    [agendaItem setValue:newName forKey:AGENDA_NAME];


    // Now store the new agenda array
    [self.agenda writeToURL:self.agendaStorageURL atomically:YES];
    // NOTE: WILL ALSO NEED TO STORE WHEN USER CHANGES AGENDA ORDER
    
    // Now reload the table with new value
    [self.agendaTableView reloadData];
}


// IMPLEMENT TABLE DATA SOURCE AND DELEGATE METHODS

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [self.agenda count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AgendaItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    /* The following code should not be necessary - had it in here temporarily because I had failed to include the proper cell identifier before.  Now that the cell identifier ("AgendaItem") is in place, the tableview is acting as it should and is allocating a cell without me having to do so...
     
    if (cell == nil) {
        NSLog(@"Cell is nil");
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
     */
    
    // Configure the cell...
    // Get agenda dictionary for this row
    NSDictionary *tempAgendaItem = [self.agenda objectAtIndex:indexPath.row];
    // Get minutes and seconds
    NSTimeInterval seconds = [[tempAgendaItem valueForKey:AGENDA_TIME] doubleValue];
    NSString *timeString = [self stringFromTimeInterval:seconds];
    cell.textLabel.text = [tempAgendaItem valueForKey:AGENDA_NAME];
    cell.detailTextLabel.text = timeString;
    
    return cell;
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSString *formattedTime;
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (interval >59) {
        formattedTime = [NSString stringWithFormat:@"%i:%02i", hours, minutes];
    } else {
        formattedTime = [NSString stringWithFormat:@"0:%2i", seconds];

    }
    return formattedTime;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"About to perform segue");
    // First, store away the index path for the tapped row
    self.detailEditRow = indexPath;
    NSDictionary *currentAgendaDictionary = [self.agenda objectAtIndex:indexPath.row];
    NSNumber *timeNumber = [currentAgendaDictionary objectForKey:AGENDA_TIME];
    NSTimeInterval timeInSeconds = [timeNumber doubleValue];
    self.inFocusAgendaTimeInSeconds = timeInSeconds;
    [self performSegueWithIdentifier:@"AgendaItemDetail" sender:self];
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Preparing for segue");
    // TEST CODE:
    // self.currentAgendaTimeInSeconds = 480;
    // Get name for detailEditRow
    NSString *detailAgendaName = [[self.agenda objectAtIndex:self.detailEditRow.row] objectForKey:AGENDA_NAME];
    self.inFocusAgendaName = detailAgendaName;
    // END TEST CODE
    
    AgendaItemVCViewController *agendaItemView = segue.destinationViewController;
    agendaItemView.myMtgMinderController = self;
    
    
    agendaItemView.agendaItemName = self.inFocusAgendaName;
    agendaItemView.itemTimeInSeconds = self.inFocusAgendaTimeInSeconds;
    
    
    }

@end
