//
//  FLTriggerManager.m
//  Flooz
//
//  Created by Olive on 1/26/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLTrigger.h"
#import "FLTriggerManager.h"
#import "GlobalViewController.h"
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
#import "TimelineViewController.h"

@interface FLTriggerManager ()

@property (nonatomic, strong) NSDictionary *binderActionFunction;
@property (nonatomic, strong) NSDictionary *binderKeyView;
@property (nonatomic, strong) NSDictionary *binderKeyType;

@property (nonatomic, strong) FLTrigger *smsTrigger;

@end

@implementation FLTriggerManager

+ (FLTriggerManager *)sharedInstance {
    static dispatch_once_t once;
    static FLTriggerManager *instance;
    dispatch_once(&once, ^{
        instance = self.new;
        [instance loadBinderActionFunction];
        [instance loadBinderKeyView];
        [instance loadBinderKeyType];
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
    if ([trigger.category isEqualToString:@"notifs"]) {
        [appDelegate askNotification];
        [self executeTriggerList:trigger.triggers];
    } else if ([trigger.category isEqualToString:@"fb"]) {
        [[Flooz sharedInstance] connectFacebook];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)callActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"http"]) {
        if (trigger.data && trigger.data[@"url"] && trigger.data[@"method"]) {
            if (trigger.data[@"external"] && [trigger.data[@"external"] boolValue]) {
                NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
                AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
                
                NSURLRequest *request;
                
                if (trigger.data[@"type"] && [trigger.data[@"type"] isEqualToString:@"urlencoded"]) {
                    NSError *error = nil;
                    request = [[AFHTTPRequestSerializer serializer] requestWithMethod:[trigger.data[@"method"] uppercaseString] URLString:trigger.data[@"url"] parameters:trigger.data[@"body"] error:&error];
                    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
                } else {
                    NSError *error = nil;
                    request = [[AFJSONRequestSerializer serializer] requestWithMethod:[trigger.data[@"method"] uppercaseString] URLString:trigger.data[@"url"] parameters:trigger.data[@"body"] error:&error];
                    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
                }
                
                if (trigger.data[@"lock"] && [trigger.data[@"lock"] boolValue])
                    [[Flooz sharedInstance] showLoadView];

                NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    [self executeTriggerList:trigger.triggers];
                    
                    [[Flooz sharedInstance] hideLoadView];

                    if (!error) {
                        if (trigger.data[@"success"]) {
                            [self executeTriggerList:[FLTriggerManager convertDataInList:trigger.data[@"success"]]];
                        }
                    } else {
                        if (trigger.data[@"failure"]) {
                            [self executeTriggerList:[FLTriggerManager convertDataInList:trigger.data[@"failure"]]];
                        }
                    }
                }];
                
                [dataTask resume];
            } else {
                if (trigger.data[@"lock"] && [trigger.data[@"lock"] boolValue])
                    [[Flooz sharedInstance] showLoadView];
                
                [[Flooz sharedInstance] requestPath:trigger.data[@"url"] method:[trigger.data[@"method"] uppercaseString] params:trigger.data[@"body"] success:^(id result) {
                    [self executeTriggerList:trigger.triggers];
                    if (trigger.data[@"success"]) {
                        [self executeTriggerList:[FLTriggerManager convertDataInList:trigger.data[@"success"]]];
                    }
                } failure:^(NSError *error) {
                    [self executeTriggerList:trigger.triggers];
                    if (trigger.data[@"failure"]) {
                        [self executeTriggerList:[FLTriggerManager convertDataInList:trigger.data[@"failure"]]];
                    }
                }];
            }
        }
    }
}

- (void)clearActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"code"]) {
        [SecureCodeViewController clearSecureCode];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)hideActionHandler:(FLTrigger *)trigger {
    if ([self isTriggerKeyView:trigger]) {
        Class controllerClass = [self.binderKeyView objectForKey:trigger.viewCaregory];
        UIViewController *topController = [appDelegate myTopViewController];
        
        if ([topController isKindOfClass:[FLTabBarController class]]) {
            UIViewController *tabController = [(FLTabBarController *)topController selectedViewController];
            
            if ([tabController isKindOfClass:[FLNavigationController class]]) {
                UIViewController *currentController = [(FLNavigationController *)tabController topViewController];
                
                if ([(FLNavigationController *)tabController viewControllers].count == 1)
                    return;
                
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
            UIViewController *currentController = [(FLNavigationController *)topController topViewController];
            
            if ([currentController isKindOfClass:controllerClass]) {
                [currentController dismissViewControllerAnimated:YES completion:^{
                    [self executeTriggerList:trigger.triggers];
                }];
            }
        } else if ([topController isKindOfClass:controllerClass]) {
            [topController dismissViewControllerAnimated:YES completion:^{
                [self executeTriggerList:trigger.triggers];
            }];
        }
    }
}

- (void)loginActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"auth"]) {
        if (trigger.data && trigger.data[@"token"]) {
            [[Flooz sharedInstance] loginWithToken:trigger.data[@"token"] success:^{
                [self executeTriggerList:trigger.triggers];
            } failure:^(NSError *error) {
                [self executeTriggerList:trigger.triggers];
            }];
        } else {
            [appDelegate goToAccountViewController];
            [self executeTriggerList:trigger.triggers];
        }
    }
}

- (void)logoutActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"auth"]) {
        [[Flooz sharedInstance] logout];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)openActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"web"]) {
        if (trigger.data && trigger.data[@"url"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:trigger.data[@"url"]]];
            [self executeTriggerList:trigger.triggers];
        }
    }
}

- (void)sendActionHandler:(FLTrigger *)trigger {
    if ([trigger.viewCaregory isEqualToString:@"image:flooz"]) {
        if (trigger.data && trigger.data[@"_id"]) {
            UIViewController *topViewController = [appDelegate myTopViewController];
            NewTransactionViewController *transacViewController;
            
            if ([topViewController isKindOfClass:[NewTransactionViewController class]]) {
                transacViewController = (NewTransactionViewController *) topViewController;
            } else if ([topViewController isKindOfClass:[FLNavigationController class]] && [[((FLNavigationController *)topViewController) topViewController] isKindOfClass:[NewTransactionViewController class]]) {
                transacViewController = (NewTransactionViewController *) [((FLNavigationController *)topViewController) topViewController];
            } else if ([topViewController isKindOfClass:[FLTabBarController class]]) {
                FLNavigationController *selectedNav = (FLNavigationController *) [((FLTabBarController *)topViewController) selectedViewController];
                if ([[selectedNav topViewController] isKindOfClass:[NewTransactionViewController class]])
                    transacViewController = (NewTransactionViewController *) [selectedNav topViewController];
            }
            
            if (transacViewController) {
                if (transacViewController.transaction[@"image"]) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[Flooz sharedInstance] uploadTransactionPic:trigger.data[@"_id"] image:transacViewController.transaction[@"image"] success:^(id result) {
                            [self executeTriggerList:trigger.triggers];
                        } failure:^(NSError *error) {
                            [self executeTriggerList:trigger.triggers];
                        }];
                    });
                }
            }
        }
    }
}

- (void)syncActionHandler:(FLTrigger *)trigger {
    if ([trigger.category isEqualToString:@"app"]) {
        if (trigger.data && trigger.data[@"url"]) {
            [appDelegate lockForUpdate:trigger.data[@"url"]];
            [self executeTriggerList:trigger.triggers];
        }
    } else if ([trigger.category isEqualToString:@"timeline"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
        [self executeTriggerList:trigger.triggers];
    } else if ([trigger.category isEqualToString:@"invitation"]) {
        [[Flooz sharedInstance] invitationText:^(id result) {
            [self executeTriggerList:trigger.triggers];
        } failure:^(NSError *error) {
            [self executeTriggerList:trigger.triggers];
        }];
    } else if ([trigger.category isEqualToString:@"flooz"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshTransaction object:nil];
        [self executeTriggerList:trigger.triggers];
    } else if ([trigger.category isEqualToString:@"profile"]) {
        [[Flooz sharedInstance] updateCurrentUserWithSuccess:^{
            [self executeTriggerList:trigger.triggers];
        }];
    } else if ([trigger.category isEqualToString:@"notifs"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newNotifications" object:nil];
        [self executeTriggerList:trigger.triggers];
    }
}

- (void)showActionHandler:(FLTrigger *)trigger {
    if ([trigger.viewCaregory isEqualToString:@"app:signup"]) {
        [appDelegate showSignupWithUser:trigger.data];
        [self executeTriggerList:trigger.triggers];
    } else if ([trigger.viewCaregory isEqualToString:@"app:popup"]) {
        if (trigger.data) {
            [[[FLPopupTrigger alloc] initWithData:trigger.data] show:^{
                [self executeTriggerList:trigger.triggers];
            }];
        }
    } else if ([trigger.viewCaregory isEqualToString:@"app:sms"]) {
        if (trigger.data && trigger.data[@"recipients"] && trigger.data[@"body"]) {
            if ([MFMessageComposeViewController canSendText]) {
                [[Flooz sharedInstance] showLoadView];
                MFMessageComposeViewController *message = [[MFMessageComposeViewController alloc] init];
                message.messageComposeDelegate = self;
                
                [message setRecipients:trigger.data[@"recipients"]];
                [message setBody:trigger.data[@"body"]];
                
                message.modalPresentationStyle = UIModalPresentationPageSheet;
                UIViewController *tmp = [appDelegate myTopViewController];
                
                self.smsTrigger = trigger;
                
                [tmp presentViewController:message animated:YES completion:^{
                    [[Flooz sharedInstance] hideLoadView];
                }];
            } else {
                if (trigger.data[@"failure"]) {
                    [self executeTriggerList:[FLTriggerManager convertDataInList:trigger.data[@"failure"]]];
                }
            }
        }
    } else if ([trigger.viewCaregory isEqualToString:@"auth:code"]) {
        [[Flooz sharedInstance] showLoadView];
        
        CompleteBlock completeBlock = ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Flooz sharedInstance] hideLoadView];
                
                [self executeTriggerList:trigger.triggers];
                
                if (trigger.data && trigger.data[@"success"]) {
                    
                    if ([trigger.data[@"success"] isKindOfClass:[NSArray class]]) {
                        [self executeTriggerList:[self.class convertDataInList:trigger.data[@"success"]]];
                    } else if ([trigger.data[@"success"] isKindOfClass:[NSDictionary class]]) {
                        FLTrigger *tmp = [[FLTrigger alloc] initWithJson:trigger.data[@"success"]];
                        
                        if (tmp) {
                            [self executeTrigger:tmp];
                        }
                    }
                }
            });
        };
        
        if ([SecureCodeViewController canUseTouchID])
            [SecureCodeViewController useToucheID:completeBlock passcodeCallback:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SecureCodeViewController *controller = [SecureCodeViewController new];
                    controller.completeBlock = completeBlock;
                    [[appDelegate myTopViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                        [[Flooz sharedInstance] hideLoadView];
                        [self executeTriggerList:trigger.triggers];
                    }];
                });
            } cancelCallback:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self executeTriggerList:trigger.triggers];
                    [[Flooz sharedInstance] hideLoadView];
                });
            }];
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SecureCodeViewController *controller = [SecureCodeViewController new];
                controller.completeBlock = completeBlock;
                [[appDelegate myTopViewController] presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                    [[Flooz sharedInstance] hideLoadView];
                    [self executeTriggerList:trigger.triggers];
                }];
            });
        }
    } else if ([trigger.viewCaregory isEqualToString:@"profile:user"]) {
        if ([trigger.data objectForKey:@"nick"]) {
            FLUser *user = [[FLUser alloc] initWithJSON:trigger.data];
            [appDelegate showUser:user inController:nil completion:^{
                [self executeTriggerList:trigger.triggers];
            }];
        } else if ([trigger.data objectForKey:@"_id"]) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] getUserProfile:[trigger.data objectForKey:@"_id"] success:^(FLUser *result) {
                if (result) {
                    [appDelegate showUser:result inController:nil completion:^{
                        [self executeTriggerList:trigger.triggers];
                    }];
                }
            } failure:nil];
        }
    } else if ([trigger.viewCaregory isEqualToString:@"timeline:flooz"]) {
        NSString *resourceID = trigger.data[@"_id"];
        
        if (resourceID) {
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] transactionWithId:resourceID success: ^(id result) {
                FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [appDelegate showTransaction:transaction inController:appDelegate.currentController withIndexPath:nil focusOnComment:NO completion:^{
                    [self executeTriggerList:trigger.triggers];
                }];
            }];
        }
        
    } else if ([self isTriggerKeyView:trigger]) {
        Class controllerClass = [self.binderKeyView objectForKey:trigger.viewCaregory];
        
        if ([self isTriggerKeyViewRoot:trigger]) {
            NSInteger rootId = [self isViewClassRoot:controllerClass];
            
            if (rootId >= 0) {
                FLTabBarController *tabBar = [appDelegate tabBarController];
                
                if (tabBar) {
                    [appDelegate dismissControllersAnimated:YES completion:^{
                        [tabBar setSelectedIndex:rootId];
                        UINavigationController *navigationController = [[tabBar viewControllers] objectAtIndex:rootId];
                        [navigationController popToRootViewControllerAnimated:YES];
                        [self executeTriggerList:trigger.triggers];
                    }];
                }
            } else {
                UIViewController *controller = [[controllerClass alloc] initWithTriggerData:trigger.data];
                
                FLNavigationController *navController = [[FLNavigationController alloc] initWithRootViewController:controller];
                
                UIViewController *tmp = [appDelegate myTopViewController];
                
                [tmp presentViewController:navController animated:YES completion:^{
                    [self executeTriggerList:trigger.triggers];
                }];
            }
        } else if ([self isTriggerKeyViewPush:trigger]) {
            UIViewController *tmp = [appDelegate myTopViewController];
            FLNavigationController *navController;
            
            if ([tmp isKindOfClass:[FLTabBarController class]]) {
                navController = [(FLTabBarController *)tmp selectedViewController];
            } else if ([tmp isKindOfClass:[FLNavigationController class]]) {
                navController = (FLNavigationController *)tmp;
            } else if ([tmp navigationController]) {
                navController = (FLNavigationController *)tmp.navigationController;
            }
            
            if (navController) {
                [navController pushViewController:[[controllerClass alloc] initWithTriggerData:trigger.data] animated:YES completion:^{
                    [self executeTriggerList:trigger.triggers];
                }];
            }
        } else if ([self isTriggerKeyViewModal:trigger]) {
            UIViewController *controller = [[controllerClass alloc] initWithTriggerData:trigger.data];
            
            FLNavigationController *navController = [[FLNavigationController alloc] initWithRootViewController:controller];
            
            UIViewController *tmp = [appDelegate myTopViewController];
            
            [tmp presentViewController:navController animated:YES completion:^{
                [self executeTriggerList:trigger.triggers];
            }];
        }
    }
}

- (void)loadBinderActionFunction {
    self.binderActionFunction = @{[NSNumber numberWithInteger:FLTriggerActionAsk]: NSStringFromSelector(@selector(askActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionCall]: NSStringFromSelector(@selector(callActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionClear]: NSStringFromSelector(@selector(clearActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionHide]: NSStringFromSelector(@selector(hideActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionLogin]: NSStringFromSelector(@selector(loginActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionLogout]: NSStringFromSelector(@selector(logoutActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionOpen]: NSStringFromSelector(@selector(openActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionSend]: NSStringFromSelector(@selector(sendActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionShow]: NSStringFromSelector(@selector(showActionHandler:)),
                                  [NSNumber numberWithInteger:FLTriggerActionSync]: NSStringFromSelector(@selector(syncActionHandler:))};
}

- (BOOL)isTriggerKeyView:(FLTrigger *)trigger {
    return (trigger && trigger.viewCaregory && [self.binderKeyView objectForKey:trigger.viewCaregory]);
}

- (BOOL)isTriggerKeyViewModal:(FLTrigger *)trigger {
    return (trigger && trigger.viewCaregory && [self.binderKeyType objectForKey:trigger.viewCaregory] && [[self.binderKeyType objectForKey:trigger.viewCaregory] isEqualToString:@"modal"]);
}

- (BOOL)isTriggerKeyViewPush:(FLTrigger *)trigger {
    return (trigger && trigger.viewCaregory && [self.binderKeyType objectForKey:trigger.viewCaregory] && [[self.binderKeyType objectForKey:trigger.viewCaregory] isEqualToString:@"push"]);
}

- (BOOL)isTriggerKeyViewRoot:(FLTrigger *)trigger {
    return (trigger && trigger.viewCaregory && [self.binderKeyType objectForKey:trigger.viewCaregory] && [[self.binderKeyType objectForKey:trigger.viewCaregory] isEqualToString:@"root"]);
}

- (NSInteger)isViewClassRoot:(Class)viewClass {
    FLTabBarController *tabBar = [appDelegate tabBarController];
    
    if (tabBar) {
        int i = 0;
        for (FLNavigationController *navController in tabBar.viewControllers) {
            if ([[[navController viewControllers] objectAtIndex:0] isKindOfClass:viewClass])
                return i;
            i++;
        }
    }
    
    return -1;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion: ^{
        if (self.smsTrigger) {
            if (result == MessageComposeResultSent) {
                if (self.smsTrigger.data[@"success"]) {
                    [self executeTriggerList:[FLTriggerManager convertDataInList:self.smsTrigger.data[@"successTriggers"]]];
                }
            }
            else if (result == MessageComposeResultCancelled) {
                if (self.smsTrigger.data[@"failure"]) {
                    [self executeTriggerList:[FLTriggerManager convertDataInList:self.smsTrigger.data[@"failureTriggers"]]];
                }
            }
            else if (result == MessageComposeResultFailed) {
                if (self.smsTrigger.data[@"failure"]) {
                    [self executeTriggerList:[FLTriggerManager convertDataInList:self.smsTrigger.data[@"failureTriggers"]]];
                }
            }
        }
    }];
}

- (void)loadBinderKeyView {
    self.binderKeyView = @{
                           @"app:cashout": [CashOutViewController class],
                           @"app:flooz": [NewTransactionViewController class],
                           @"app:promo": [DiscountCodeViewController class],
                           @"app:search": [SearchViewController class],
                           @"app:notifs": [NotificationsViewController class],
                           @"app:invitation": [ShareAppViewController class],
                           @"app:profile": [UserViewController class],
                           @"app:timeline": [TimelineViewController class],
                           @"auth:code": [SecureCodeViewController class],
                           @"card:3ds": [Secure3DViewController class],
                           @"card:card": [CreditCardViewController class],
                           @"code:set": [ValidateSecureCodeViewController class],
                           @"invitation:sms": [ShareSMSViewController class],
                           @"profile:user": [UserViewController class],
                           @"profile:edit": [EditProfileViewController class],
                           @"settings:iban": [SettingsBankViewController class],
                           @"settings:identity": [SettingsCoordsViewController class],
                           @"settings:notifs": [SettingsNotificationsViewController class],
                           @"settings:privacy": [SettingsPrivacyController class],
                           @"settings:documents": [SettingsDocumentsViewController class],
                           @"timeline:flooz": [TransactionViewController class],
                           @"web:web": [WebViewController class],
                           @"phone:validate": [ValidateSMSViewController class],
                           @"friend:pending": [FriendRequestViewController class]
                           };
}

- (void)loadBinderKeyType {
    self.binderKeyType = @{
                           @"app:cashout": @"modal",
                           @"app:flooz": @"modal",
                           @"app:promo": @"modal",
                           @"app:search": @"modal",
                           @"app:notifs": @"root",
                           @"app:invitation": @"root",
                           @"app:profile": @"root",
                           @"app:timeline": @"root",
                           @"auth:code": @"modal",
                           @"card:3ds": @"modal",
                           @"card:card": @"modal",
                           @"code:set":@"modal",
                           @"invitation:sms": @"modal",
                           @"profile:user": @"push",
                           @"profile:edit": @"modal",
                           @"settings:iban": @"modal",
                           @"settings:identity": @"modal",
                           @"settings:notifs": @"modal",
                           @"settings:privacy": @"modal",
                           @"settings:documents": @"modal",
                           @"timeline:flooz": @"push",
                           @"web:web": @"modal",
                           @"phone:validate": @"modal",
                           @"friend:pending": @"modal"
                           };
}

@end
