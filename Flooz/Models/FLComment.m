//
//  FLComment.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLComment.h"

@implementation FLComment

- (id)initWithJSON:(NSDictionary *)json
{
    self = [super init];
    if(self){
        [self setJSON:json];
    }
    return self;
}

- (void)setJSON:(NSDictionary *)json
{    
    _content = [json objectForKey:@"comment"];
    _user = [[FLUser alloc] initWithJSON:json];
}

@end
