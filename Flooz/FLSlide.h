//
//  FLSlide.h
//  Flooz
//
//  Created by Epitech on 3/31/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EAIntroView/EAIntroView.h>

@interface FLSlide : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *skipText;
@property (nonatomic, retain) NSString *imgURL;
@property (nonatomic, retain) EAIntroPage *page;

- (id)initWithJson:(NSDictionary*)json;
- (void)enableLastPageConfig:(EAIntroView*)intro;

@end
