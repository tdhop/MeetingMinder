//
//  MtgMinderViewController.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/2/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface MtgMinderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *mainAgendaLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;


#define EARLY_WARNING 120 // Seconds of early warning interval
#define ADDED_TIME 300 // Seconds of added time
#define WARNING_SOUND @"SweetAlert"
#define WARNING_TYPE @"wav"
#define EXPIRE_SOUND @"InsistentAlertLong"
#define EXPIRE_TYPE @"m4a"
#define SILENT_SOUND @"Silence"
#define SILENT_TYPE @"wav"

@property (strong, nonatomic) AVAudioPlayer *warningSound;
@property (strong, nonatomic) AVAudioPlayer *expiredSound;

// Timer control methods
- (void) updateTimer: (id) sender; // Update the countdown timer display based on current time

// Agenda control methods
- (IBAction)startMeeting:(id)sender; // Set context to first agenda item then call startTimer
- (IBAction)nextItem:(id)sender;  // Respond to Next button press by starting timer on next agenda item
// Respond to Previous button press
- (IBAction)previousItem:(id)sender;

// Reset meeting to starting point
- (IBAction) resetMeeting: (id) sender;

// Pause or play meeting - suspends timer in current context
- (IBAction)pausePlayMeeting:(id)sender;

// Add a new agenda item
- (IBAction)addAgendaItem:(id)sender;

// Delegate methods for AgendaItemVCViewController
- (void) updateItemTime: (NSTimeInterval)timeInterval sender: (id) sender; // Update the selected agenda duration in seconds, this message is sent by the AgendaItemVCViewController
- (void) updateItemName: (NSString *) newName sender: (id) sender; // Update the selected agenda name, this message is sent by the AgendaItemVCViewController
- (void) deleteItem: (id) sender; // Remove the in focus agenda item from the agenda

@end
