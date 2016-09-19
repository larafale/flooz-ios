//
//  FLAlert.h
//  Flooz
//
//  Created by Olivier on 10/21/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLAlert : NSObject

typedef enum e_FLAlertType {
    AlertTypeSuccess,
    AlertTypeWarning,
    AlertTypeError
} FLAlertType;

@property (nonatomic) FLAlertType type;
@property (nonatomic, strong) NSNumber *delay;
@property (nonatomic, strong) NSNumber *duration;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *code;
@property (nonatomic) Boolean visible;
@property (nonatomic) NSMutableArray *triggers;

-(id) initWithJson:(NSDictionary *)json;

+(FLAlertType)alertTypeParamToEnum:(NSString*)param;

@end
