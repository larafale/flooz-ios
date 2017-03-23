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

@interface FLNewFloozOptions : NSObject

@property (nonatomic) BOOL allowTo;
@property (nonatomic) BOOL allowPic;
@property (nonatomic) BOOL allowGif;
@property (nonatomic) BOOL allowGeo;
@property (nonatomic) BOOL allowWhy;
@property (nonatomic) BOOL allowScope;
@property (nonatomic) BOOL allowAmount;
@property (nonatomic) BOOL allowBalance;
@property (nonatomic) BOOL scopeDefined;
@property (nonatomic) TransactionType type;
@property (nonatomic, strong) FLScope *scope;
@property (nonatomic, strong) NSArray *scopes;

- (id)initWithJson:(NSDictionary *)json;
+ (id)default;
+ (id)defaultWithJson:(NSDictionary *)json;

@end

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
@property (nonatomic, strong) NSDictionary *payload;
@property (nonatomic) BOOL isParticipation;
@property (nonatomic) BOOL blockAmount;
@property (nonatomic) BOOL blockBack;
@property (nonatomic) BOOL focusAmount;
@property (nonatomic) BOOL focusWhy;
@property (nonatomic) BOOL isDemo;
@property (nonatomic, strong) NSDictionary *popup;
@property (nonatomic, strong) NSArray *triggers;
@property (nonatomic, strong) NSDictionary *geo;
@property (nonatomic, strong) FLNewFloozOptions *options;

- (id)initWithJson:(NSDictionary *)json;

@end
