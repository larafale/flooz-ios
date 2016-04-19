//
//  FLSlide.m
//  Flooz
//
//  Created by Olivier on 3/31/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "FLSlide.h"
#import "UIImageView+AFNetworking.h"

@interface FLSlide () {
    EAIntroView* introView;
}

@end

@implementation FLSlide

- (id)initWithJson:(NSDictionary*)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary*)json {
    self.text = json[@"text"];
    self.imgURL = json[@"image"];
    self.skipText = json[@"skip"];
}


@end
