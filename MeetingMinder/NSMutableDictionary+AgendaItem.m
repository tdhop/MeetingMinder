//
//  NSDictionary+AgendaItem.m
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/18/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//


#import "NSMutableDictionary+AgendaItem.h"

@implementation NSMutableDictionary (AgendaItem)

// TITLE
- (void)setName:(NSString *)name {
    [self setObject:name forKey:@"NAME"];
}
- (NSString *) name {
    return [self objectForKey:@"NAME"];
}


// TIME
- (void)setTime:(NSUInteger)time {
    [self setObject:[NSNumber numberWithDouble:time] forKey:@"TIME"];
}
- (NSUInteger) time {
    return [[self objectForKey:@"TIME"] doubleValue];
}


// REMAINING
- (void)setRemaining:(NSUInteger)remaining {
    [self setObject:[NSNumber numberWithDouble:remaining] forKey:@"REMAINING"];
}
- (NSUInteger) remaining {
    return [[self objectForKey:@"REMAINING"] doubleValue];
}

@end
