//
//  FLSlider.h
//  Flooz
//
//  Created by Olivier on 3/31/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLSlider : NSObject

@property (nonatomic, retain) NSMutableArray *slides;

- (id)initWithJson:(NSDictionary*)json;

@end
