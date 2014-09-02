//
//  FLSocial.h
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLSocial : NSObject

typedef NS_ENUM(NSInteger, SocialScope) {
    SocialScopeNone, // Pour desactiver pour les cagnottes
    SocialScopePublic,
    SocialScopeFriend,
    SocialScopePrivate
};

@property (nonatomic) NSUInteger commentsCount;
@property (nonatomic) NSUInteger likesCount;
@property BOOL isCommented;
@property BOOL isLiked;
@property (strong, nonatomic) NSString *likeText;
@property (nonatomic) SocialScope scope;

- (id)initWithJSON:(NSDictionary *)json;

@end
