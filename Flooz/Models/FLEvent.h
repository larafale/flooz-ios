//
//  FLEvent.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLEvent : NSObject

typedef NS_ENUM(NSInteger, EventStatus) {
    EventStatusAccepted,
    EventStatusRefused,
    EventStatusWaiting
};

@property (nonatomic) EventStatus status;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *attachment_url;

@property (strong, nonatomic) NSNumber *commentsCount;
@property (strong, nonatomic) NSNumber *likesCount;
@property (strong, nonatomic) NSNumber *isCommented;
@property (strong, nonatomic) NSNumber *isLiked;

- (NSString *)statusText;

+ (NSArray *)testData;

@end
