//
//  AgendaContext.m
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/16/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import "AgendaContext.h"
#import "NSMutableDictionary+AgendaItem.h"




@interface AgendaContext ()

@property (strong, nonatomic) NSMutableArray *agenda; // local storage for loaded agenda
@property (strong, nonatomic) NSMutableDictionary *inFocusItem; // local storage for in-focus agenda item
@property NSUInteger myFocusIndex; // internal storage for agenda focus index
@property (strong, nonatomic) NSURL *storageURL;


@end

@implementation AgendaContext

#pragma mark - Getters & Setters

@synthesize agenda = _agenda;
@synthesize inFocusItem = _inFocusItem;
@synthesize storageURL = _storageURL;

// Get/Set inFocusName
- (void) setInFocusName: (NSString *) name {
    // [self.inFocusItem setObject:name forKey:AGENDA_NAME];
    self.inFocusItem.name = name;
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];    
}
- (NSString *) inFocusName {
    return [self.inFocusItem objectForKey:AGENDA_NAME];
}

// Get/Set inFocusTime
- (void) setInFocusTime:(NSTimeInterval)time {
    NSNumber *setTime = [NSNumber numberWithDouble:time];
    [self.inFocusItem setObject:setTime forKey:AGENDA_TIME];
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
}
- (NSTimeInterval) inFocusTime {
    return [[self.inFocusItem objectForKey:AGENDA_TIME] doubleValue];
}

// Get/Set inFocusRemaining
- (void) setInFocusRemaining:(NSTimeInterval)remaining {
    NSNumber *setRemaining = [NSNumber numberWithDouble:remaining];
    [self.inFocusItem setObject:setRemaining forKey:AGENDA_REMAINING];
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
}
- (NSTimeInterval) inFocusRemaining {
    return [[self.inFocusItem objectForKey:AGENDA_REMAINING] doubleValue];
}

// Note that I don't synthesize inFocusIndex because it has to be readonly from the perspective of other objects but needs to be read-write internally
- (NSUInteger) inFocusIndex {
    return self.myFocusIndex;
}

#pragma mark - Initialization

- (AgendaContext *) initWithURL: (NSURL *) storageURL {
    if([super init]) {
        self.storageURL = storageURL;
    }
    return self;
}

#pragma mark - Agenda Storage

// Load agenda from store
- (BOOL) loadAgenda {
    
    BOOL success; // return value
    
    if (self.storageURL == nil) {
        success = NO;
    } else {
        // Read in the stored agenda - or initialize an empty one if there is no stored agenda
        if ([[NSFileManager defaultManager] fileExistsAtPath:[self.storageURL path]]) {
            self.agenda = [NSMutableArray arrayWithContentsOfURL:self.storageURL];
        } else {
            NSLog(@"This is where I need to initialize an empty agenda array");
            self.agenda = [NSMutableArray arrayWithCapacity:5]; // Chose capacity of 5 somewhat randomly
        }
        
        // Unit test AgendaItem category
         
        success = YES;
    }
    return success;
}

// Store current agenda
- (BOOL) storeAgenda {
    
    BOOL success; // return value
    
    if (self.storageURL == nil) {
        success = NO;
    } else {
        [self.agenda writeToURL:self.storageURL atomically:YES];
        success = YES;
    }
    return success;
}

// Get current agenda count
- (NSUInteger) agendaCount {
    return [self.agenda count];
}

#pragma mark - Add/Delete Items

// Add new, blank item at end
- (BOOL) addItemAtEnd {
    // First, add an empty agenda item to the agenda array
    NSMutableDictionary *newAgendaItem = [NSMutableDictionary dictionaryWithCapacity:3];
    [newAgendaItem setObject:[NSNumber numberWithDouble:0] forKey:AGENDA_TIME];
    [newAgendaItem setObject:@"New Item" forKey:AGENDA_NAME];
    [newAgendaItem setObject:[NSNumber numberWithDouble:0] forKey:AGENDA_REMAINING];
    [self.agenda addObject:newAgendaItem];
    self.myFocusIndex = [self.agenda count] - 1;
    
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];

    
    return YES;
}

- (BOOL) deleteItemAtIndex:(NSUInteger)index {
    [self.agenda removeObjectAtIndex:index];
    
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
    
    return YES;
}

#pragma mark - Changing Focus

// Set context to next item in agenda
- (BOOL) goToNext {
    
    BOOL success; // return value
    
    if (self.agenda == nil) {
        // Agenda has not yet been loaded
        success = NO;
    } else if ([self.agenda count] == 0) {
        // Agenda has no items
        success = NO;
    } else if (self.myFocusIndex == [self.agenda count]-1) {
        success = NO; // Already at end of agenda, return failure
    } else {
        self.myFocusIndex++;
        self.inFocusItem = [self.agenda objectAtIndex:self.myFocusIndex];
        success = YES; // I was able to go to the next agenda item
    }
    return success;
}

// Set context to previous item in agenda
- (BOOL) goToPrevious {
    
    BOOL success; // return value
    
    if (self.agenda == nil) {
        // Agenda has not yet been loaded
        success = NO;
    } else if (self.myFocusIndex == 0) {
        success = NO; // Already at start of agenda, return failure
    } else {
        self.myFocusIndex--;
        self.inFocusItem = [self.agenda objectAtIndex:self.myFocusIndex];
        success = YES; // I was able to go to the previous agenda item
    }
    return success;

}

// Set context to first item in agenda
- (BOOL) goToFirst {
    
    BOOL success; // return value
    
    if (self.agenda == nil) {
        // Agenda has not yet been loaded
        success = NO;
    } else if ([self.agenda count] == 0) {
        // The agenda is empty
        success = NO;
    } else {
        self.myFocusIndex = 0; // Index of first item
        self.inFocusItem = [self.agenda objectAtIndex:self.myFocusIndex];
        success = YES; // I was able to go to the previous agenda item
    }
    return success;
}

// Set context to indexed item
- (BOOL) goToIndex: (NSUInteger) index {
    
    BOOL success; // return value
    
    // Note that I do not have to check for <0 because index is an unsigned integer
    if (self.agenda == nil) {
        // Agenda has not yet been loaded
        success = NO;
    } else if (index > [self.agenda count] + 1) {
        // Index is out of range
        success = NO;
    } else {
        self.myFocusIndex = index;
        self.inFocusItem = [self.agenda objectAtIndex:index];
        success = YES;
    }
    return success;
}

#pragma mark - Get Current Focus Info

// Provide column/row index path for in-focus agenda item
- (NSIndexPath *)inFocusIndexPath {
    
    // Manufacture an index path from self.myFocusIndex
    return [NSIndexPath indexPathForRow:self.myFocusIndex inSection:0];
}

#pragma mark - Edit Agenda Dictionary

// provide a dictionary with all elements of the agenda item at index
- (NSMutableDictionary *) agendaInfoForIndex: (NSUInteger) index {
    return [self.agenda objectAtIndex:index];
}

// provide a dictionary with all elements of the in-focus agenda item
- (NSMutableDictionary *) inFocusInfo {
    return self.inFocusItem;
}

// set/get the name of the agenda item at index
- (void) setName: (NSString *) name forIndex: (NSUInteger) index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    item.name = name;
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
}
- (NSString *) getNameForIndex: (NSUInteger)index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    return item.name;
}

// set/get the time of the agenda item at index
- (void) setTime: (NSTimeInterval) time forIndex: (NSUInteger) index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    item.time = time;
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
}
- (NSTimeInterval) getTimeForIndex: (NSUInteger)index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    return item.time;
}

// set/get the time of the agenda item at index
- (void) setRemaining: (NSTimeInterval) remaining forIndex: (NSUInteger) index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    item.remaining = remaining;
    // Now store the new agenda array
    [self.agenda writeToURL:self.storageURL atomically:YES];
}
- (NSTimeInterval) getRemainingForIndex: (NSUInteger)index {
    NSMutableDictionary *item = [self.agenda objectAtIndex:index];
    return item.remaining;
}

@end
