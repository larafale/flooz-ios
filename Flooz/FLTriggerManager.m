//
//  FLTriggerManager.m
//  Flooz
//
//  Created by Olive on 1/26/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLTrigger.h"
#import "FLTriggerManager.h"
#import "SecureCodeViewController.h"
#import "CreditCardViewController.h"
#import "SettingsDocumentsViewController.h"
#import "SettingsCoordsViewController.h"
#import "3DSecureViewController.h"
#import "SecureCodeViewController.h"
#import "ShareAppViewController.h"
#import "FLPopupInformation.h"
#import "SettingsBankViewController.h"
#import "FLTabBarController.h"
#import "FLPopupTrigger.h"
#import "ShareSMSViewController.h"
#import "ValidateSMSViewController.h"
#import "EditProfileViewController.h"
#import "ValidateSecureCodeViewController.h"
#import "NewTransactionViewController.h"
#import "NotificationsViewController.h"
#import "AddressBookController.h"
#import "CashOutViewController.h"
#import "FriendRequestViewController.h"
#import "SettingsNotificationsViewController.h"
#import "SettingsPrivacyController.h"
#import "DiscountCodeViewController.h"
#import "ScannerViewController.h"
#import "SearchViewController.h"
#import "UserViewController.h"
#import "AccountViewController.h"
#import "TransactionViewController.h"


@interface FLTriggerManager ()

@property (nonatomic, strong) NSDictionary *binderActionFunction;
@property (nonatomic, strong) NSDictionary *binderKeyView;

@end

@implementation FLTriggerManager

+ (FLTriggerManager *)sharedInstance {
    static dispatch_once_t once;
    static FLTriggerManager *instance;
    dispatch_once(&once, ^{
        instance = self.new;
        [instance loadBinderActionFunction];
        [instance loadBinderKeyView];
    });
    return instance;
}

+ (NSArray<FLTrigger *> *)convertDataInList:(NSArray<NSDictionary *> *)triggers {
    NSMutableArray<FLTrigger *> *ret = [NSMutableArray new];
    
    for (NSDictionary *trigger in triggers) {
        FLTrigger *t = [FLTrigger newWithJson:trigger];
        if (t) {
            [ret addObject:t];
        }
    }
    
    return ret;
}

- (void)executeTriggerList:(NSArray<FLTrigger *> *)triggers {
    if (triggers) {
        for (FLTrigger *trigger in triggers) {
            if (trigger)
                [self executeTrigger:trigger];
        }
    }
}

- (void)executeTrigger:(FLTrigger *)trigger {
    if (trigger && [self.binderActionFunction objectForKey:[NSNumber numberWithInt:trigger.action]]) {
        if ([trigger.delay isEqualToNumber:@0])
            [self performSelector:NSSelectorFromString([self.binderActionFunction objectForKey:[NSNumber numberWithInt:trigger.action]]) withObject:trigger];
        else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [trigger.delay doubleValue] * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:NSSelectorFromString([self.binderActionFunction objectForKey:[NSNumber numberWithInt:trigger.action]]) withObject:trigger];
            });
        }
    }
}

- (void)askActionHandler:(FLTrigger *)trigger {
    if ([trigger.key isEqualToString:@"notification"]) {
        [appDelegate askNotification];
        
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)checkActionHandler:(FLTrigger *)trigger {
    if ([trigger.key isEqualToString:@"secureCode"]) {
        [[Flooz sharedInstance] checkSecureCodeForUser:[SecureCodeViewController secureCodeForCurrentUser] success:^(id result) {
            [self executeTriggerList:trigger.triggers];
        } failure:^(NSError *error) {
            [SecureCodeViewController clearSecureCode];
            [self executeTriggerList:trigger.triggers];
        }];
    }
}

- (void)clearActionHandler:(FLTrigger *)trigger {
    if ([trigger.key isEqualToString:@"secureCode"]) {
        [SecureCodeViewController clearSecureCode];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)hideActionHandler:(FLTrigger *)trigger {
    if ([self isTriggerKeyView:trigger]) {
        Class controllerClass = [self.binderKeyView objectForKey:trigger.key];
        UIViewController *topController = [appDelegate myTopViewController];
        
        if ([topController isKindOfClass:[FLTabBarController class]]) {
            UIViewController *tabController = [(FLTabBarController *)topController selectedViewController];
            
            if ([tabController isKindOfClass:[FLNavigationController class]]) {
                UIViewController *currentController = [(FLNavigationController *)topController topViewController];
                
                if ([currentController isKindOfClass:controllerClass]) {
                    [currentController dismissViewControllerAnimated:YES completion:^{
                        [self executeTriggerList:trigger.triggers];
                    }];
                }
            } else if ([tabController isKindOfClass:controllerClass]) {
                [tabController dismissViewControllerAnimated:YES completion:^{
                    [self executeTriggerList:trigger.triggers];
                }];
            }
        } else if ([topController isKindOfClass:[FLNavigationController class]]) {
            
        } else if ([topController isKindOfClass:controllerClass]) {
            [topController dismissViewControllerAnimated:YES completion:^{
                [self executeTriggerList:trigger.triggers];
            }];
        }
    }
}

- (void)inActionHandler:(FLTrigger *)trigger {
    if ([trigger.key isEqualToString:@"log"]) {
        if (trigger.data && trigger.data[@"token"]) {
            [[Flooz sharedInstance] loginWithToken:trigger.data[@"token"] success:^{
                [self executeTriggerList:trigger.triggers];
            } failure:^(NSError *error) {
                [self executeTriggerList:trigger.triggers];
            }];
        } else {
            [appDelegate goToAccountViewController];
        }
    } else if ([trigger.key isEqualToString:@"request"]) {
        if (trigger.data && trigger.data[@"url"] && trigger.data[@"method"]) {
            [[Flooz sharedInstance] requestPath:trigger.data[@"url"] method:trigger.data[@"method"] params:trigger.data[@"body"] success:^(id result) {
                [self executeTriggerList:trigger.triggers];
            } failure:^(NSError *error) {
                [self executeTriggerList:trigger.triggers];
            }];
        }
    } else if ([trigger.key isEqualToString:@"fb"]) {
        [[Flooz sharedInstance] connectFacebook];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)loadActionHandler:(FLTrigger *)trigger {
    if ([trigger.key isEqualToString:@"timeline"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
        [self executeTriggerList:trigger.triggers];

    } else if ([trigger.key isEqualToString:@"invitation"]) {
        [[Flooz sharedInstance] invitationText:^(id result) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadShareTexts object:nil];
            [self executeTriggerList:trigger.triggers];
        } failure:^(NSError *error) {
            [self executeTriggerList:trigger.triggers];
        }];
    } else if ([trigger.key isEqualToString:@"line"]) {
        
    } else if ([trigger.key isEqualToString:@"profile"]) {
        
    } else if ([trigger.key isEqualToString:@"notification"]) {
        
    }
}

- (void)outActionHandler:(FLTrigger *)trigger {
    
}

- (void)sendActionHandler:(FLTrigger *)trigger {
    
}

- (void)setActionHandler:(FLTrigger *)trigger {
    
}

- (void)showActionHandler:(FLTrigger *)trigger {
    
}

- (void)loadBinderActionFunction {
    self.binderActionFunction = @{[NSNumber numberWithInteger:FLTriggerActionAsk]: NSStringFromSelector(@selector(askActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionCheck]: NSStringFromSelector(@selector(checkActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionClear]: NSStringFromSelector(@selector(clearActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionHide]: NSStringFromSelector(@selector(hideActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionIn]: NSStringFromSelector(@selector(inActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionLoad]: NSStringFromSelector(@selector(loadActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionOut]: NSStringFromSelector(@selector(outActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionSend]: NSStringFromSelector(@selector(sendActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionSet]: NSStringFromSelector(@selector(setActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionShow]: NSStringFromSelector(@selector(showActionHandler:))};
}

- (BOOL)isTriggerKeyView:(FLTrigger *)trigger {
    return (trigger && trigger.key && [self.binderKeyView objectForKey:trigger.key]);
}

- (void)loadBinderKeyView {
    self.binderKeyView = @{@"3dSecure": [Secure3DViewController class],
                           @"aBook": [AddressBookController class],
                           @"card": [CreditCardViewController class],
                           @"cashout": [CashOutViewController class],
                           @"documents": [SettingsDocumentsViewController class],
                           @"editProfile": [EditProfileViewController class],
                           @"flooz": [NewTransactionViewController class],
                           @"friendRequest": [FriendRequestViewController class],
                           @"iban": [SettingsBankViewController class],
                           @"identity": [SettingsCoordsViewController class],
                           @"invitationSMS": [ShareSMSViewController class],
                           @"notifSettings": [SettingsNotificationsViewController class],
                           @"phoneValidate": [ValidateSMSViewController class],
                           @"privacy": [SettingsPrivacyController class],
                           @"promo": [DiscountCodeViewController class],
                           @"scanner": [ScannerViewController class],
                           @"search": [SearchViewController class],
                           @"user": [UserViewController class],
                           @"invitation": [ShareAppViewController class],
                           @"profile": [AccountViewController class],
                           @"notification": [NotificationsViewController class],
                           @"secureCode": [SecureCodeViewController class],
                           @"line": [TransactionViewController class],
                           @"web": [WebViewController class]
                           };
}

@end
