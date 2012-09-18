//
//  NSDictionary+AgendaItem.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/18/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (AgendaItem)

@property NSString *name;
@property NSUInteger time;
@property NSUInteger remaining;

@end
