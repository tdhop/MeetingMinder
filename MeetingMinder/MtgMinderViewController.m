//
//  MtgMinderViewController.m
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/2/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import "MtgMinderViewController.h"
#import "AgendaItemVCViewController.h"
#import "AgendaContext.h"
#import "NSMutableDictionary+AgendaItem.h"
#import <math.h>

#pragma mark Agenda Dictionary Keys
// Define keys for agenda items
#define AGENDA_NAME @"Agenda Name"
#define AGENDA_TIME @"Agenda Time"

@interface MtgMinderViewController ()

// Reference for the tableview on this screen
@property (strong, nonatomic) UITableView *agendaTableView;

#pragma mark Declare Agenda Properties

// NEW: property for agenda context
@property (strong, nonatomic) AgendaContext *myAgendaContext;

// Properties to store agenda
@property (strong, nonatomic) NSURL *agendaStorageURL; // Where the Agenda array will be stored


#pragma mark Declare Table Properties

// Properties for interacting with AgendaItemVCViewController
@property (strong, nonatomic) NSIndexPath *detailEditRow; // Keeps track of most recently tapped row OR new item

@end

@implementation MtgMinderViewController

// NEW: synthesize myAgendaContext
@synthesize myAgendaContext = _myAgendaContext;

// synthesize all properties
@synthesize mainAgendaLabel = _mainAgendaLabel;
@synthesize timeLabel=_timeLabel;
@synthesize agendaTableView = _agendaTableView;
@synthesize agendaStorageURL = _agendaStorageURL;
@synthesize detailEditRow = _detailEditRow; // The row whose detail disclosure was tapped



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
    
    // Get an AgendaContext object and ask it to load the agenda
    self.myAgendaContext = [[AgendaContext alloc] initWithURL:self.agendaStorageURL];
    if (![self.myAgendaContext loadAgenda]) {
        NSLog(@"myAgendaContext failed to load");
    } else NSLog(@"myAgendaContext loaded successfully");
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO; // (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Agenda Control

// Set context to first agenda item then call startTimer
- (IBAction)startMeeting:(id)sender {
    // Start meeting will both start AND re-start the meeting
    NSMutableDictionary *itemInfo; // agenda info for item I'm about to start
    UITableViewCell *cell; // cell to highlight
    
    // Set label for button to "Restart Meeting"
    UIButton *myButton = sender;
    [myButton setTitle:@"Restart Meeting" forState:UIControlStateNormal];
    
    // Un-highlight any item that might have been playing at the time
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = NO;
    }
    
    
    
    // Now make sure that myAgendaContext is on the first item -- and that there is actually something there
    if (![self.myAgendaContext goToFirst]) {
        NSLog(@"Attempting to start meeting with empty agenda");
        [self startTimer:0];
    } else {

        
        itemInfo = [self.myAgendaContext inFocusInfo];
        
        // Set up main label to show this agenda item
        self.mainAgendaLabel.text = itemInfo.name;
        
        // If time has not yet been set, it will be 0 -- so just start the timer with the time from this item
        [self startTimer:itemInfo.time];
    }
    
    // Make sure Pause/Resume button is in the right state
    UIBarButtonItem *pausePlayButton;
    
    pausePlayButton = [[self.navigationController.toolbar items] objectAtIndex:0];
    
    pausePlayButton.title = @"Pause";
    
    
    // Highlight the current in-progress meeting item
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = YES;
    }
}

// Respond to Next button press by starting timer on next agenda item
- (IBAction)nextItem:(id)sender {
    
    NSMutableDictionary *itemInfo; // agenda info for item I'm about to start
    UITableViewCell *cell;

    // Un-highlight any item that might have been playing at the time
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = NO;
    }
    
    if(![self.myAgendaContext goToNext]) {
        NSLog(@"Got fail back from goToNext");
        // Do nothing
    } else {
        itemInfo = [self.myAgendaContext inFocusInfo];
        
        // Set up main label to show this agenda item
        self.mainAgendaLabel.text = itemInfo.name;
        
        // If time has not yet been set, it will be 0 -- so just start the timer with the time from this item
        [self startTimer:itemInfo.time];

    }
    
    // Highlight the current in-progress meeting item
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = YES;
    }
}

// Respond to Previous button press
- (IBAction)previousItem:(id)sender {
    
    NSMutableDictionary *itemInfo; // agenda info for item I'm about to start
    UITableViewCell *cell;
    
    // Un-highlight any item that might have been playing at the time
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = NO;
    }
    
    if(![self.myAgendaContext goToPrevious]) {
        NSLog(@"Got fail back from goToPrevious");
        // Do nothing
    } else {
        itemInfo = [self.myAgendaContext inFocusInfo];
        
        // Set up main label to show this agenda item
        self.mainAgendaLabel.text = itemInfo.name;
        
        // If time has not yet been set, it will be 0 -- so just start the timer with the time from this item
        [self startTimer:itemInfo.time];
        
    }

    // Highlight the current in-progress meeting item
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = YES;
    }
}

// Start item at index, used when table cell is tapped
- (void) startItemAtIndex: (NSUInteger) index {
    
    NSMutableDictionary *itemInfo; // agenda info for item I'm about to start
    UITableViewCell *cell;
    
    // Un-highlight any item that might have been playing at the time
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = NO;
    }
    
    if(![self.myAgendaContext goToIndex:index]) {
        NSLog(@"Got fail back from goToIndex");
        // Do nothing
    } else {
        itemInfo = [self.myAgendaContext inFocusInfo];
        
        // Set up main label to show this agenda item
        self.mainAgendaLabel.text = itemInfo.name;
        
        // If time has not yet been set, it will be 0 -- so just start the timer with the time from this item
        [self startTimer:itemInfo.time];
        
    }
    
    // Highlight the current in-progress meeting item
    if (self.myAgendaContext.inFocusIndexPath) {
        cell = [self.agendaTableView cellForRowAtIndexPath: self.myAgendaContext.inFocusIndexPath];
        cell.selected = YES;
    }
    
}

// Pause or play meeting - suspends timer in current context
- (IBAction)pausePlayMeeting:(id)sender {
    
    NSMutableDictionary *inFocusItem;
    
    inFocusItem = [self.myAgendaContext inFocusInfo];
    
    if ([myTimer isValid]) {
        // Timer is currently running, stop it and store the remaining time, change button to "Play" symbol
        [myTimer invalidate];
        inFocusItem.remaining = currentTime;
        UIBarButtonItem *button = sender;
        button.title = @"Resume";
    } else {
        // Timer is not currently running, start it with the inFocusItem remaining time, change button to "Pause" symbol
        [self startTimer:inFocusItem.remaining];
        UIBarButtonItem *button = sender;
        button.title = @"Pause";
    }
}

#pragma mark - Timer Display

// Timer control variables

int currentTime; // Stores current countdown value

NSTimer *myTimer; // The timer object I will use

NSDate *lastDate; // will use this to calculate time interval from timer



// The following are used to control the countdown timer display
- (void)startTimer:(NSUInteger) time {
  
    // Make sure that timer is not already running.  If it is, clean up (is anything needed here?)
    [myTimer invalidate];
    
    currentTime = time; // Initialize timer to initial value from arg time
    self.timeLabel.text = [self timeStringFromInterval:currentTime];
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0 target: self selector: @selector(updateTimer:) userInfo:nil repeats:YES];
    lastDate = [NSDate date];

    NSLog(@"Starting Timer, currentTime = %d", currentTime);
    
    
}

- (void) updateTimer:(id)sender {
    
    NSTimeInterval timerInterval;
    
    if (currentTime == 0) {
        [myTimer invalidate];
    } else {
    timerInterval = [[NSDate date] timeIntervalSinceDate:lastDate];
    int decrement = roundf(timerInterval); // makes sure I always decrement by exactly one second
    currentTime -= decrement;
    self.timeLabel.text = [self timeStringFromInterval:currentTime];
    lastDate = [NSDate date];

    NSLog(@"Updating Timer, currentTime = %d", currentTime);
    }
}

#pragma mark - Update Agenda Items (delegate methods)

// Add an agenda item
- (IBAction)addAgendaItem:(id)sender {
    
    if(![self.myAgendaContext addItemAtEnd]) {
        NSLog(@"Add agenda item failed");
    }
    
    // Now reload the table so it will show with new item even if user does not enter any info for it
    [self.agendaTableView reloadData];
    
    // Now go to agenda detail
    self.detailEditRow = self.myAgendaContext.inFocusIndexPath;
    [self performSegueWithIdentifier:@"AgendaItemDetail" sender:self];
}

// Remove the in focus agenda item from the agenda
- (void) deleteItem: (id) sender {
    
    if (![self.myAgendaContext deleteItemAtIndex:self.detailEditRow.row]) {
        NSLog(@"Delete item failed");
    }
    
    // Now reload the table with the item removed
    [self.agendaTableView reloadData];
}


// The following are used to receive information back from AgendaItemVCViewController
// Delegate method: Update selected agenda item time duration in seconds
- (void) updateItemTime:(NSTimeInterval) timeInterval sender:(id)sender {
    
    [self.myAgendaContext setTime:timeInterval forIndex:self.detailEditRow.row];

    // Now reload the table with new value
    [self.agendaTableView reloadData];
    
}

// Delegate method: Update selected agenda name
- (void) updateItemName:(NSString *)newName sender:(id)sender {
    
    [self.myAgendaContext setName:newName forIndex:self.detailEditRow.row];
     
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
    return [self.myAgendaContext agendaCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AgendaItem";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    // Get agenda dictionary for this row
    NSMutableDictionary *tempAgendaItem = [self.myAgendaContext agendaInfoForIndex:indexPath.row];
    // Get minutes and seconds
    cell.textLabel.text = tempAgendaItem.name;
    cell.detailTextLabel.text = [self timeStringFromInterval:tempAgendaItem.time];
     
    return cell;
}

- (NSString *)timeStringFromInterval:(NSTimeInterval)interval {
    NSString *formattedTime;
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    if (interval > 3599) {
        formattedTime = [NSString stringWithFormat:@"%i:%02i:%02i", hours, minutes, seconds];
    }
    if (interval >59) {
        formattedTime = [NSString stringWithFormat:@"%i:%02i", minutes, seconds];
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
    // Start this agenda item
    [self startItemAtIndex:indexPath.row];
    
}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {

    // First, store away the index path for the tapped row
    self.detailEditRow = indexPath;

    [self performSegueWithIdentifier:@"AgendaItemDetail" sender:self];
}


#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"Preparing for segue");
    
    
    AgendaItemVCViewController *agendaItemView = segue.destinationViewController;
    agendaItemView.myMtgMinderController = self;
    
    
    agendaItemView.agendaItemName = [self.myAgendaContext getNameForIndex:self.detailEditRow.row];
    agendaItemView.itemTimeInSeconds = [self.myAgendaContext getTimeForIndex:self.detailEditRow.row];
    
    
    }

@end
