//
//  FLSlide.h
//  Flooz
//
//  Created by Olivier on 3/31/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EAIntroView/EAIntroView.h>

@interface FLSlide : NSObject

@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *skipText;
@property (nonatomic, retain) NSString *imgURL;

- (id)initWithJson:(NSDictionary*)json;

@end
