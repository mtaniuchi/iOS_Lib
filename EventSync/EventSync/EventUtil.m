//
//  EventUtil.m
//  EventSync
//
//  Created by mtaniuchi on 13/07/03.

/*
 The MIT License (MIT)
 
 Copyright (c) <year> <copyright holders>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
*/

#import "EventUtil.h"

@implementation EventUtil
{
    EKEventStore *store;
    bool __enabled;
}
@synthesize calendarIsEnabled, reminderIsEnabled;

static EventUtil* instance = nil;

+ (EventUtil*)sharedInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}


#pragma mark initialize
- (bool)initializeEKEventStore:(EKEntityType)eventType
{
    if (!store) {
        store = [[EKEventStore alloc] init];
    }
    
    EKAuthorizationStatus authStatus = [EKEventStore
                                        authorizationStatusForEntityType:eventType];
    switch (authStatus) {
        case EKAuthorizationStatusAuthorized:
            __enabled = true;
            break;
        case EKAuthorizationStatusDenied:
            __enabled = false;
            break;
        case EKAuthorizationStatusRestricted:
            __enabled = false;
            break;
        case EKAuthorizationStatusNotDetermined:
        {
            dispatch_semaphore_t sema = dispatch_semaphore_create(0);
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
            dispatch_async(queue,
                           ^{
                               [store
                                requestAccessToEntityType:eventType
                                completion:^(BOOL granted, NSError *error)
                                {
                                    __enabled = granted;
                                    dispatch_semaphore_signal(sema);
                                }];
                           });
            dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        }
            break;
    }
    return __enabled;
}

- (void)initializeCalendar
{
    self.calendarIsEnabled = [self initializeEKEventStore:EKEntityTypeEvent];
    if (!self.calendarIsEnabled) {
        [self presentDeniedAlert];
    }
}

- (void)initializeReminder
{   
    self.reminderIsEnabled = [self initializeEKEventStore:EKEntityTypeReminder];
    if (!self.reminderIsEnabled) {
        [self presentDeniedAlert];
    }
}


#pragma mark getList
- (NSMutableArray*)getCalenderList
{
    NSArray *eventCalendars = [store calendarsForEntityType:EKEntityTypeEvent];
    
    return [[NSMutableArray alloc] initWithArray:eventCalendars];
}
- (NSMutableArray*)getReminderList
{
    NSArray *eventReminders = [store calendarsForEntityType:EKEntityTypeReminder];
    
    return [[NSMutableArray alloc] initWithArray:eventReminders];
}
- (void)presentDeniedAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"caution"
                                                    message:@"access limited"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

#pragma mark getEvents
- (NSMutableArray*)getCalenderEvents:(EKCalendar*)parent
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!parent) {
        return result;
    }
    
    // fetch all events
    NSArray *eventCalendars = [store calendarsForEntityType:EKEntityTypeEvent];
    
    // find parent
    for (EKCalendar *rem in eventCalendars) {
        if ([parent isEqual:rem]) {
            eventCalendars = [[NSArray alloc] initWithObjects:rem, nil];
            break;
        }
    }
    if ([eventCalendars count] == 0) { return result; }
    
//    NSCalendar *calendar = [NSCalendar currentCalendar];
//
//    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
//    oneDayAgoComponents.day = -1;
//    NSDate *oneDayAgo = [calendar dateByAddingComponents:oneDayAgoComponents
//                                                  toDate:[NSDate date]
//                                                 options:0];
//    
//    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
//    oneYearFromNowComponents.year = 1;
//    NSDate *oneYearFromNow = [calendar dateByAddingComponents:oneYearFromNowComponents
//                                                       toDate:[NSDate date]
//                                                      options:0];
//    
//    NSPredicate *predicate = [store predicateForEventsWithStartDate:oneDayAgo
//                                                     endDate:oneYearFromNow
//                                                   calendars:eventCalendars];

    // Get the appropriate calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the start date components
    NSDateComponents *oneDayAgoComponents = [[NSDateComponents alloc] init];
    oneDayAgoComponents.year = -1;
    NSDate *startDate = [calendar dateByAddingComponents:oneDayAgoComponents
                                                  toDate:[NSDate date]
                                                 options:0];
    
    // Create the end date components
    NSDateComponents *oneYearFromNowComponents = [[NSDateComponents alloc] init];
    oneYearFromNowComponents.year = 20;
    NSDate *endDate = [calendar dateByAddingComponents:oneYearFromNowComponents
                                                       toDate:[NSDate date]
                                                      options:0];
 
    
    
    NSPredicate *predicate = [store predicateForEventsWithStartDate:startDate
                                                            endDate:endDate
                                                          calendars:eventCalendars];

    NSArray *events = [store eventsMatchingPredicate:predicate];
    
    return [[NSMutableArray alloc] initWithArray:events];
}
- (NSArray*)getReminderEvents:(EKReminder*)parent
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    if (!parent) {
        return result;
    }
    
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	
    NSArray *eventCalendars = [store calendarsForEntityType:EKEntityTypeReminder];
    
    // find parent
    for (EKReminder *rem in eventCalendars) {
        if ([parent isEqual:rem]) {
            eventCalendars = [[NSArray alloc] initWithObjects:rem, nil];
            break;
        }
    }
    
    if ([eventCalendars count] == 0) { return result; }
    
    NSPredicate *predicate = [store predicateForRemindersInCalendars:eventCalendars];

	dispatch_async(queue,
                   ^{
                       // 検索条件に一致するイベントを全てフェッチ
                       [store fetchRemindersMatchingPredicate:predicate
                                                   completion:^(NSArray *reminders) {
                                                       for (EKReminder *rem in reminders) {
                                                           NSLog(@"%@" ,rem.calendarItemIdentifier);
                                                           [result addObject:rem];
                                                       }
                                                       dispatch_semaphore_signal(sema);
                                                   }];
                   });
	dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    return result;
}


@end
