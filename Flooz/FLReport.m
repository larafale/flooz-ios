//
//  FLReport.m
//  Flooz
//
//  Created by Epitech on 11/21/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLReport.h"

@implementation FLReport

- (id)initWithType:(FLReportType)reportType id:(NSString *)objectID {
    self = [super init];
    if (self) {
        
        self.reportType = reportType;
        
        switch (reportType) {
            case ReportTransaction:
                self.type = @"line";
                break;
            case ReportUser:
                self.type = @"user";
                break;
            default:
                break;
        }
        
        self.resourceID = [objectID copy];
        self.content = @"";
    }
    return self;
}

@end
