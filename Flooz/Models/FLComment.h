//
//  FLComment.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLComment : NSObject

@property (strong, nonatomic) FLUser *user;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSString *dateText;

- (id)initWithJSON:(NSDictionary *)json;

@end
