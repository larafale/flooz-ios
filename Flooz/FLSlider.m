//
//  FLSlider.m
//  Flooz
//
//  Created by Epitech on 3/31/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLSlider.h"
#import "FLSlide.h"

@implementation FLSlider

- (id)initWithJson:(NSDictionary*)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary*)json {
    NSArray *jsonSlides = json[@"slides"];
    
    self.slides = [NSMutableArray new];
    
    for (NSDictionary *jsonSlide in jsonSlides) {
        [self.slides addObject:[[FLSlide alloc] initWithJson:jsonSlide]];
    }
}

@end
