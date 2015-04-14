//
//  NSDictionary+JSONHelper.h
//  Flooz
//
//  Created by Epitech on 2/23/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (JSONHelper)

+ (NSDictionary*) newWithJSONString:(NSString*) jsonString;
+ (NSDictionary*) newWithJSONData:(NSData*) jsonData;

- (NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint;

@end
