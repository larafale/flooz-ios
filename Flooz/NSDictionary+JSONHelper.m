//
//  NSDictionary+JSONHelper.m
//  Flooz
//
//  Created by Olivier on 2/23/15.
//  Copyright (c) 2015 Olivier Mouren. All rights reserved.
//

#import "NSDictionary+JSONHelper.h"

@implementation NSDictionary (JSONHelper)

+ (NSDictionary*) newWithJSONString:(NSString*) jsonString {
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (!jsonError)
        return json;
    else
        return nil;
}

+ (NSDictionary*) newWithJSONData:(NSData*) jsonData {
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    if (!jsonError)
        return json;
    else
        return nil;
}

-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)    (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end

