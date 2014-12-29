//
//  FLAlert.m
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLAlert.h"
#import "FLTrigger.h"

@implementation FLAlert

-(id)initWithJson:(NSDictionary *)json {
    self = [super init];
    if (self) {
        [self setJson:json];
    }
    return self;
}

- (void)setJson:(NSDictionary *)json {
    if (json) {
        self.delay = [NSNumber numberWithInteger:[json[@"delay"] integerValue]];
        self.duration = [NSNumber numberWithInteger:[json[@"time"] integerValue]];
        self.content = json[@"message"];
        self.title = json[@"title"];
        self.code = [NSNumber numberWithInteger:[json[@"code"] integerValue]];
        self.visible = [json[@"visible"] boolValue];
        self.type = [FLAlert alertTypeParamToEnum:json[@"type"]];
    
        self.triggers = [NSMutableArray new];
        NSArray *t = json[@"triggers"];
        for (NSDictionary *trigger in t) {
            [self.triggers addObject:[[FLTrigger alloc] initWithJson:trigger]];
        }

        if (!self.duration || [self.duration intValue] == 0)
            self.duration = @3;
    
        if (!self.delay)
            self.delay = @0;

        if (!self.title || [self.title isBlank])
            self.title = NSLocalizedString(@"GLOBAL_ERROR", nil);
    
        [self.content stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];

    }
    else
        self.visible = NO;
}

+(FLAlertType)alertTypeParamToEnum:(NSString*)param {
    if ([param isEqualToString:@"red"])
        return AlertTypeError;
    else if ([param isEqualToString:@"blue"])
        return AlertTypeWarning;
    else
        return AlertTypeSuccess;
}

@end
