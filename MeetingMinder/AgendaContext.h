//
//  AgendaContext.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/16/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Agenda Dictionary Keys
// Define keys for agenda items
#define AGENDA_NAME @"Agenda Name"
#define AGENDA_TIME @"Agenda Time"
#define AGENDA_REMAINING @"Agenda Remaining"

@interface AgendaContext : NSObject

// PROPERTIES

@property (nonatomic)NSUInteger inFocusIndex; // Current in-focus index
@property (strong, nonatomic)NSString *inFocusName; // In-focus item name
@property NSTimeInterval inFocusTime; // Time in seconds
@property NSTimeInterval inFocusRemaining; // Remaining time in seconds

// METHODS

- (AgendaContext *) initWithURL: (NSURL *) storageURL; // start up the AgendaContext object

- (BOOL) loadAgenda; // Load agenda from store
- (BOOL) storeAgenda; // Store current agenda
- (NSUInteger) agendaCount; // Get current agenda count
- (BOOL) goToNext; // Set context to next item in agenda
- (BOOL) goToPrevious; // Set context to previous item in agenda
- (BOOL) goToFirst; // Set context to first item in agenda
- (BOOL) goToIndex: (NSUInteger) index; // Set context to indexed item
- (BOOL) addItemAtEnd; // Adds a new, blank item at the end of the agenda
- (BOOL) deleteItemAtIndex: (NSUInteger) index; // remove item at index

- (NSIndexPath *)inFocusIndexPath; // Provide column/row index path for in-focus agenda item

- (NSMutableDictionary *) agendaInfoForIndex: (NSUInteger) index; // provide a dictionary with all elements of the agenda item at index

- (NSMutableDictionary *) inFocusInfo; // provide a dictionary with all elements of the current agenda item

// set/get the name of the agenda item at index
- (void) setName: (NSString *) name forIndex: (NSUInteger) index;
- (NSString *) getNameForIndex: (NSUInteger)index;

// set/get the time of the agenda item at index
- (void) setTime: (NSTimeInterval) time forIndex: (NSUInteger) index;
- (NSTimeInterval) getTimeForIndex: (NSUInteger)index;

// set/get the time of the agenda item at index
- (void) setRemaining: (NSTimeInterval) remaining forIndex: (NSUInteger) index;
- (NSTimeInterval) getRemainingForIndex: (NSUInteger)index;

@end
