//
//  AgendaItemVCViewController.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/3/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MtgMinderViewController.h"

@interface AgendaItemVCViewController : UIViewController <UITextFieldDelegate>

// Properties for interacting with the MtgMinderViewController
@property (nonatomic, strong) MtgMinderViewController *myMtgMinderController;
@property (nonatomic, strong) NSString *agendaItemName;
@property NSTimeInterval itemTimeInSeconds;

// Outlets and Actions for Date Picker
@property (nonatomic, weak) IBOutlet UIDatePicker *agendaTimePicker;
- (IBAction)userSetItemTimeInSeconds:(id)sender;

// Outlets and Actions for Agenda Text Field. Don't need delegate since I will go with default behavior
@property (nonatomic, weak) IBOutlet UITextField *agendaTextField;
// I'll use the delegate pattern to handle end of editing

// Action for delete item
- (IBAction)deleteItem: (id)sender;


@end
