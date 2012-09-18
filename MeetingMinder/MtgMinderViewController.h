//
//  MtgMinderViewController.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/2/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MtgMinderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mainAgendaLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


// Timer control methods
- (void) updateTimer: (id) sender; // Update the countdown timer display based on current time

// Agenda control methods
- (IBAction)startMeeting:(id)sender; // Set context to first agenda item then call startTimer
- (IBAction)nextItem:(id)sender;  // Respond to Next button press by starting timer on next agenda item
// Respond to Previous button press
- (IBAction)previousItem:(id)sender;

// Pause or play meeting - suspends timer in current context
- (IBAction)pausePlayMeeting:(id)sender;

// Add a new agenda item
- (IBAction)addAgendaItem:(id)sender;

// Delegate methods for AgendaItemVCViewController
- (void) updateItemTime: (NSTimeInterval)timeInterval sender: (id) sender; // Update the selected agenda duration in seconds, this message is sent by the AgendaItemVCViewController
- (void) updateItemName: (NSString *) newName sender: (id) sender; // Update the selected agenda name, this message is sent by the AgendaItemVCViewController
- (void) deleteItem: (id) sender; // Remove the in focus agenda item from the agenda

@end
