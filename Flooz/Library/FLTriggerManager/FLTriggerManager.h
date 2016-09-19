//
//  FLTriggerManager.h
//  Flooz
//
//  Created by Olive on 1/26/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface FLTriggerManager : NSObject<MFMessageComposeViewControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+ (FLTriggerManager *)sharedInstance;
+ (NSArray<FLTrigger *> *)convertDataInList:(NSArray<NSDictionary *> *)triggers;

- (void)executeTrigger:(FLTrigger *)trigger;
- (void)executeTriggerList:(NSArray<FLTrigger *> *)triggers;

@end
