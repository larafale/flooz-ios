//
//  FLPreset.h
//  Flooz
//
//  Created by Olivier on 11/27/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLTransaction.h"

@interface FLPreset : NSObject

@property (nonatomic, retain) NSString *presetId;
@property (nonatomic, retain) NSString *collectName;
@property (nonatomic, retain) NSString *to;
@property (nonatomic, retain) NSString *toFullName;
@property (nonatomic, retain) NSNumber *amount;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *namePlaceholder;
@property (nonatomic, retain) NSString *why;
@property (nonatomic, retain) NSString *whyPlaceholder;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSDictionary *contact;
@property (nonatomic) TransactionType type;
@property (nonatomic) TransactionScope scope;
@property (nonatomic, retain) NSDictionary *payload;
@property (nonatomic) BOOL isParticipation;
@property (nonatomic) BOOL blockAmount;
@property (nonatomic) BOOL blockTo;
@property (nonatomic) BOOL blockBack;
@property (nonatomic) BOOL blockScope;
@property (nonatomic) BOOL blockWhy;
@property (nonatomic) BOOL blockBalance;
@property (nonatomic) BOOL focusAmount;
@property (nonatomic) BOOL focusWhy;
@property (nonatomic) BOOL isDemo;
@property (nonatomic) BOOL scopeDefined;
@property (nonatomic, retain) NSDictionary *popup;
@property (nonatomic, retain) NSArray *triggers;
@property (nonatomic, retain) NSArray *scopes;
@property (nonatomic, retain) NSDictionary *geo;

- (id)initWithJson:(NSDictionary *)json;

@end
