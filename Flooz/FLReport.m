//
//  FLReport.m
//  Flooz
//
//  Created by Olivier on 11/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
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

- (id)initWithType:(FLReportType)reportType transac:(FLTransaction *)transac  {
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
        
        self.resourceID = [transac.transactionId copy];
        self.transaction = transac;
        self.content = @"";
    }
    return self;
}


@end
