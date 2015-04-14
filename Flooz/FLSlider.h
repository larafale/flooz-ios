//
//  FLSlider.h
//  Flooz
//
//  Created by Epitech on 3/31/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLSlider : NSObject

@property (nonatomic, retain) NSMutableArray *slides;

- (id)initWithJson:(NSDictionary*)json;

@end
