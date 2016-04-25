//
//  FLActivity.h
//  Flooz
//
//  Created by Olive on 4/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLActivity : NSObject

@property (nonatomic, retain) NSString *icon;
@property (strong, nonatomic) NSString *content;

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSString *when;
@property (strong, nonatomic) NSString *dateText;

- (id)initWithJSON:(NSDictionary *)json;

@end
