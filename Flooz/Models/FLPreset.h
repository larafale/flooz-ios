//
//  FLPreset.h
//  Flooz
//
//  Created by Olivier on 11/27/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLTransaction.h"
#import "FLScope.h"

@interface FLPreset : NSObject

@property (nonatomic, strong) NSString *presetId;
@property (nonatomic, strong) NSString *collectName;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, strong) NSString *toFullName;
@property (nonatomic, strong) NSNumber *amount;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *namePlaceholder;
@property (nonatomic, strong) NSString *why;
@property (nonatomic, strong) NSString *whyPlaceholder;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *contact;
@property (nonatomic) TransactionType type;
@property (nonatomic, strong) FLScope *scope;
@property (nonatomic, strong) NSDictionary *payload;
@property (nonatomic) BOOL isParticipation;
@property (nonatomic) BOOL blockAmount;
@property (nonatomic) BOOL blockTo;
@property (nonatomic) BOOL blockBack;
@property (nonatomic) BOOL blockPic;
@property (nonatomic) BOOL blockGif;
@property (nonatomic) BOOL blockGeo;
@property (nonatomic) BOOL blockScope;
@property (nonatomic) BOOL blockWhy;
@property (nonatomic) BOOL blockBalance;
@property (nonatomic) BOOL focusAmount;
@property (nonatomic) BOOL focusWhy;
@property (nonatomic) BOOL isDemo;
@property (nonatomic) BOOL scopeDefined;
@property (nonatomic, strong) NSDictionary *popup;
@property (nonatomic, strong) NSArray *triggers;
@property (nonatomic, strong) NSArray *scopes;
@property (nonatomic, strong) NSDictionary *geo;

- (id)initWithJson:(NSDictionary *)json;

@end
