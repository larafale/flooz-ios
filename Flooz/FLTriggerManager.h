//
//  FLTriggerManager.h
//  Flooz
//
//  Created by Olive on 1/26/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLTriggerManager : NSObject

+ (FLTriggerManager *)sharedInstance;
+ (NSArray<FLTrigger *> *)convertDataInList:(NSArray<NSDictionary *> *)triggers;

- (void)executeTrigger:(FLTrigger *)trigger;
- (void)executeTriggerList:(NSArray<FLTrigger *> *)triggers;

@end
