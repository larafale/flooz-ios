//
//  FLReport.h
//  Flooz
//
//  Created by Olivier on 11/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLReport : NSObject

typedef enum e_FLReportType {
    ReportTransaction,
    ReportUser
} FLReportType;

@property (nonatomic) FLReportType reportType;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) NSString *resourceID;
@property (nonatomic, retain) NSString *content;

- (id)initWithType:(FLReportType)reportType id:(NSString *)objectID;

@end
