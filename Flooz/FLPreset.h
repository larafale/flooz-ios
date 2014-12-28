//
//  FLPreset.h
//  Flooz
//
//  Created by Epitech on 11/27/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLPreset : NSObject

@property (nonatomic, retain) FLUser *to;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSString *why;
@property (nonatomic) TransactionType type;
@property (nonatomic, retain) NSDictionary *payload;
@property (nonatomic) BOOL blockAmount;
@property (nonatomic) BOOL blockTo;
@property (nonatomic) BOOL blockBack;
@property (nonatomic) BOOL blockWhy;
@property (nonatomic, retain) NSString *title;

- (id)initWithJson:(NSDictionary *)json;

@end
