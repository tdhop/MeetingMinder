//
//  AgendaItemVCViewController.m
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/3/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import "AgendaItemVCViewController.h"

@interface AgendaItemVCViewController ()

@end

@implementation AgendaItemVCViewController

// Synthesize properties for interacting with MtgMinderViewController
@synthesize myMtgMinderController = _myMtgMinderController;
@synthesize agendaItemName = _agendaItemName;
@synthesize itemTimeInSeconds = _itemTimeInSeconds;

// Synthesize target-action properties for Outlets on this view
@synthesize agendaTimePicker = _agendaTimePicker;
@synthesize agendaTextField = _agendaTextField;

#pragma mark - Manage View

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Set up initial values of View components - eventually will do this based on what myMtgMinderController gives me
    
    // I'm writing the following with the assumption that viewDidLoad gets called AFTER prepareForSegue
    // First, set up agenda text field
    self.agendaTextField.delegate = self;
    if (self.agendaItemName == nil) {
        // In this case, I want to show some default text
        self.agendaItemName = @"Type agenda item name";
    }
    self.agendaTextField.clearButtonMode = UITextFieldViewModeAlways;
    self.agendaTextField.returnKeyType = UIReturnKeyDone; // Keyboard will show "Done" instead of "Return"
    self.agendaTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; // Text field will autocap first letter of each word
    self.agendaTextField.text = self.agendaItemName;
    
    // Now set up date picker    
    self.agendaTimePicker.countDownDuration = self.itemTimeInSeconds;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Agenda Text Field Delegate

// INTERACT WITH THE TEXT FIELD

// 
// Act on user input on the Text Field
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.myMtgMinderController updateItemName: textField.text sender:self];
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - Date Picker Actions

// Act on user input on the Date Picker
- (IBAction)userSetItemTimeInSeconds:(id)sender{
    // Put delegate action here
    NSLog(@"userSetItemTimeInSeconds has been called - need delegate method here");
    [self.myMtgMinderController updateItemTime:self.agendaTimePicker.countDownDuration sender:self];
}

#pragma mark - Delete Item Action
- (IBAction)deleteItem: (id)sender {
    [self.myMtgMinderController deleteItem: self];
    // now pop back to other controller
    [self.navigationController popViewControllerAnimated:YES];
}



@end
