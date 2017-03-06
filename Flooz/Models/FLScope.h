//
//  FLScope.h
//  Flooz
//
//  Created by Olive on 28/02/2017.
//  Copyright © 2017 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLScope : NSObject

typedef NS_ENUM (NSInteger, FLScopeKey) {
    FLScopePublic,
    FLScopeFriend,
    FLScopePrivate,
    FLScopeAll,
    FLScopeNone
};

@property (nonatomic, retain) NSDictionary *json;

@property (nonatomic) FLScopeKey key;
@property (strong, nonatomic) NSString *keyString;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *imageName;

- (id)initWithJSON:(NSDictionary *)json;

+ (FLScope *)defaultScope:(FLScopeKey)scopeKey;
+ (NSArray<FLScope *> *)defaultScopeList;

+ (FLScope *)scopeFromKey:(NSString*)scopeKey;
+ (FLScope *)scopeFromID:(NSNumber*)scopeID;
+ (FLScope *)scopeFromObject:(id)object;
+ (FLScope *)scopeFromJSON:(NSDictionary *)json;

@end
