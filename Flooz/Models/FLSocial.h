//
//  FLSocial.h
//  Flooz
//
//  Created by Olivier on 1/24/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLTransaction.h"

@interface FLSocial : NSObject

@property (nonatomic) NSArray *likes;
@property (nonatomic) NSArray *comments;
@property (nonatomic) NSUInteger commentsCount;
@property (nonatomic) NSUInteger likesCount;
@property BOOL isCommented;
@property BOOL isLiked;
@property (strong, nonatomic) NSString *likeText;
@property (strong, nonatomic) NSString *commentText;
@property (nonatomic) TransactionScope scope;

- (id)initWithJSON:(NSDictionary *)json;

@end
