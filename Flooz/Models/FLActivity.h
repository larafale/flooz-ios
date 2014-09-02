//
//  FLActivity.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLActivity : NSObject

@property (strong, nonatomic) FLUser *user;
@property (strong, nonatomic) NSString *content;
@property (nonatomic) BOOL isRead;

@property (strong, nonatomic) NSString *eventId;
@property (strong, nonatomic) NSString *transactionId;
@property (nonatomic) BOOL isFriend;
@property (nonatomic) BOOL isForCompleteProfil;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSString *dateText;

- (id)initWithJSON:(NSDictionary *)json;

@end
