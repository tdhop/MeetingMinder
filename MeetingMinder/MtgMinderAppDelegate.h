//
//  MtgMinderAppDelegate.h
//  MeetingMinder
//
//  Created by Tim Hopmann on 9/2/12.
//  Copyright (c) 2012 Tim Hopmann. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WARNING_ALERT_NAME @"Early Warning"
#define WARNING_ALERT_BODY @"Agenda item has reached early warning time"
#define EXPIRE_ALERT_NAME @"Agenda Item Expired"
#define EXPIRE_ALERT_BODY @"Current agenda item has run out of time"

@interface MtgMinderAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UILocalNotification *earlyNotification;
@property (strong, nonatomic) NSDate *earlyWarningDate;
@property (strong, nonatomic) UILocalNotification *expiredNotification;
@property (strong, nonatomic) NSDate *expireDate;

@property (strong, nonatomic) UIWindow *window;

@end
