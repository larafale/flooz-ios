//
//  FLInvitationTexts.h
//  Flooz
//
//  Created by Epitech on 7/27/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLInvitationTexts : NSObject

@property (nonatomic, retain) NSString *shareCode;
@property (nonatomic, retain) NSString *shareTitle;
@property (nonatomic, retain) NSString *shareHeader;
@property (nonatomic, retain) NSString *shareSms;
@property (nonatomic, retain) NSString *shareTwitter;
@property (nonatomic, retain) NSDictionary *shareMail;
@property (nonatomic, retain) NSDictionary *shareFb;
@property (nonatomic, retain) NSArray *shareText;
@property (nonatomic, retain) NSDictionary *json;

- (id)initWithJSON:(NSDictionary *)json;

@end
