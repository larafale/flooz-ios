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

@property NSUInteger commentsCount;
@property NSUInteger likesCount;
@property BOOL isCommented;
@property BOOL isLiked;
@property NSString *likeText;
@property SocialScope scope;

- (id)initWithJSON:(NSDictionary *)json;

@end
