//
//  Flooz.m
//  Flooz
//
//  Created by olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "Flooz.h"

#import <AFURLRequestSerialization.h>
#import <AFURLResponseSerialization.h>
#import <GBDeviceInfo/GBDeviceInfo.h>

#import "AppDelegate.h"

#import <Accounts/Accounts.h>
#import <UICKeyChainStore.h>
#import <AddressBook/AddressBook.h>

#import "FLAlert.h"

#import "AvatarMenu.h"
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
#import "DeviceUID.h"

#import "FLReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

@implementation Flooz

@synthesize timelinePageSize;

+ (Flooz *)sharedInstance {
    static dispatch_once_t once;
    static Flooz *instance;
    dispatch_once(&once, ^{ instance = self.new; instance.timelinePageSize = 20; });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        
#ifdef FLOOZ_DEV_LOCAL
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@", [appDelegate localIp]]]];
#elif FLOOZ_DEV_API
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.flooz.me"]];
#else
        manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.flooz.me"]];
#endif
        
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [manager.requestSerializer setTimeoutInterval:10];
        [manager setResponseSerializer:[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers]];
        
        loadView = [FLLoadView new];
        
        _notificationsCount = @0;
        _notifications = @[];
        _activitiesCached = @[];
        
        self.socketConnected = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDeviceToken) name:kNotificationAnswerAccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUserData) name:kNotificationReloadCurrentUser object:nil];
        
        self.fbLoginManager = [[FBSDKLoginManager alloc] init];
    }
    return self;
}

- (BOOL)isProd {
    return [manager.baseURL.absoluteString rangeOfString:@"https://api.flooz.me"].location != NSNotFound;
}

- (BOOL)isDev {
    return [manager.baseURL.absoluteString rangeOfString:@"http://dev.flooz.me"].location != NSNotFound;
}

- (BOOL)isLocal {
    return [manager.baseURL.absoluteString rangeOfString:@"http://dev.flooz.me"].location == NSNotFound && [manager.baseURL.absoluteString rangeOfString:@"https://api.flooz.me"].location == NSNotFound;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showLoadView {
    [loadView show];
}

- (void)hideLoadView {
    [loadView hide];
}

- (BOOL)isConnectionAvailable {
    FLReachability *reachability = [FLReachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

#pragma mark - Save Data

- (void) loadUserData {
    NSString *userData = [UICKeyChainStore stringForKey:kUserData];
    if (userData) {
        NSDictionary *userJson = [NSDictionary newWithJSONString:userData];
        if (userJson) {
            _currentUser = [[FLUser alloc] initWithJSON:userJson];
            _currentUser.isComplete = YES;
            [self updateFbToken:userJson[@"fb"][@"token"] andUser:userJson[@"fb"][@"id"]];
            
            [self checkDeviceToken];
        }
    }
}

- (void) loadInvitationData {
    NSString *invitationData = [UICKeyChainStore stringForKey:kInvitationData];
    if (invitationData) {
        NSDictionary *textJson = [NSDictionary newWithJSONString:invitationData];
        if (textJson) {
            _invitationTexts = [[FLInvitationTexts alloc] initWithJSON:textJson];
        }
    }
}

- (void) loadTextData {
    NSString *textData = [UICKeyChainStore stringForKey:kTextData];
    if (textData) {
        NSDictionary *textJson = [NSDictionary newWithJSONString:textData];
        if (textJson) {
            _currentTexts = [[FLTexts alloc] initWithJSON:textJson];
        }
    }
}

- (NSArray *) loadTimelineData:(TransactionScope)scope {
    NSString *dataKey;
    
    switch (scope) {
        case TransactionScopeAll:
            dataKey = kAllTimelineData;
            break;
        case TransactionScopePrivate:
            dataKey = kPrivateTimelineData;
            break;
        case TransactionScopeFriend:
            dataKey = kFriendTimelineData;
            break;
    }
    
    NSString *timelineData = [UICKeyChainStore stringForKey:dataKey];
    if (timelineData) {
        NSArray *timelineJson = [NSArray newWithJSONString:timelineData];
        if (timelineJson) {
            return [self createTransactionArrayFromSaveData:timelineJson];
        }
    }
    return nil;
}

- (NSArray *) loadNotificationData {
    NSString *notificationData = [UICKeyChainStore stringForKey:kNotificationsData];
    if (notificationData) {
        NSArray *notificationJson = [NSArray newWithJSONString:notificationData];
        if (notificationJson) {
            return [self createActivityArrayFromSaveData:notificationJson];
        }
    }
    return nil;
}

- (NSArray *) loadLocationData {
    NSString *locationData = [UICKeyChainStore stringForKey:kLocationData];
    if (locationData) {
        NSArray *places = [NSArray newWithJSONString:locationData];
        if (places) {
            return places;
        }
    }
    return nil;
}

- (void) saveUserData {
    [UICKeyChainStore setString:[self.currentUser.json jsonStringWithPrettyPrint:NO] forKey:kUserData];
}

- (void) saveInvitationData {
    [UICKeyChainStore setString:[self.invitationTexts.json jsonStringWithPrettyPrint:NO] forKey:kInvitationData];
}

- (void) saveTextData {
    [UICKeyChainStore setString:[self.currentTexts.json jsonStringWithPrettyPrint:NO] forKey:kTextData];
}

- (void) saveNotificationData:(NSArray *)notifs {
    [UICKeyChainStore setString:[notifs jsonStringWithPrettyPrint:NO] forKey:kNotificationsData];
}

- (void) saveTimeline:(NSArray*)timeline forScope:(TransactionScope)scope {
    if (timeline) {
        NSString *dataKey;
        
        switch (scope) {
            case TransactionScopeAll:
                dataKey = kAllTimelineData;
                break;
            case TransactionScopePrivate:
                dataKey = kPrivateTimelineData;
                break;
            case TransactionScopeFriend:
                dataKey = kFriendTimelineData;
                break;
        }
        
        [UICKeyChainStore setString:[timeline jsonStringWithPrettyPrint:NO] forKey:dataKey];
    }
}

- (void) saveLocationData:(NSArray*)places {
    [UICKeyChainStore setString:[places jsonStringWithPrettyPrint:NO] forKey:kLocationData];
}

- (void) clearSaveData {
    [UICKeyChainStore removeItemForKey:kUserData];
    [UICKeyChainStore removeItemForKey:kAllTimelineData];
    [UICKeyChainStore removeItemForKey:kPrivateTimelineData];
    [UICKeyChainStore removeItemForKey:kFriendTimelineData];
    [UICKeyChainStore removeItemForKey:kTextData];
    [UICKeyChainStore removeItemForKey:kNotificationsData];
    [UICKeyChainStore removeItemForKey:kFilterData];
    [UICKeyChainStore removeItemForKey:kLocationData];
}

- (void) clearLocationData {
    [UICKeyChainStore removeItemForKey:kLocationData];
}

#pragma mark -

- (void)clearLogin {
    [SecureCodeViewController clearSecureCode];
    
    _currentUser = nil;
    _access_token = nil;
    _facebook_token = nil;
    _activitiesCached = @[];
    
    [self clearSaveData];
    
    [UICKeyChainStore removeItemForKey:@"login-token"];
}

- (void)logout {
    if (_currentUser) {
        if ([_currentUser deviceToken]) {
            [self requestPath:@"/users/logout" method:@"GET" params:@{ @"device":[_currentUser deviceToken] } success:^(id result) {
                [manager.operationQueue cancelAllOperations];
                
                [self closeSocket];
                [self clearLogin];
                [appDelegate didDisconnected];
                
            } failure:^(NSError *error) {
                [manager.operationQueue cancelAllOperations];
                
                [self closeSocket];
                [self clearLogin];
                [appDelegate didDisconnected];
                
            }];
        } else {
            [manager.operationQueue cancelAllOperations];
            
            [self closeSocket];
            [self clearLogin];
            [appDelegate didDisconnected];
        }
    } else {
        [appDelegate didDisconnected];
    }
}

- (void)signupPassStep:(NSString *)step user:(NSMutableDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSString *path = [NSString stringWithFormat:@"/signup/%@", step];
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:path method:@"POST" params:user success:success failure:failure];
}

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoFlooz];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelineFriends];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelinePublic];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimelinePrivate];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoWelcome];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kSendContact];
        
        [self updateCurrentUserAndAskResetCode:result];
        
        if (success) {
            success(result);
        }
    };
    
    NSMutableDictionary *_userDic = [user mutableCopy];
    [_userDic setObject:[self formatBirthDate:user[@"birthdate"]] forKey:@"birthdate"];
    
    NSString *path = @"/signup";
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:@"/signup" method:@"POST" params:_userDic success:successBlock failure:failure];
}

- (NSString *)formatBirthDate:(NSString *)birthdate {
    if ([birthdate isBlank])
        return @"";
    
    NSArray *strings;
    
    if ([birthdate rangeOfString:@" "].location != NSNotFound)
        strings = [birthdate componentsSeparatedByString:@" / "];
    else
        strings = [birthdate componentsSeparatedByString:@"/"];
    
    if (strings.count == 3) {
        NSString *day = strings[0];
        NSString *month = strings[1];
        NSString *year = strings[2];
        return [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
    }
    return @"";
}

- (NSString *)formatBirthDateFromFacebook:(NSString *)birthdate {
    NSArray *strings = [birthdate componentsSeparatedByString:@"/"];
    NSString *day = strings[1];
    NSString *month = strings[0];
    NSString *year = strings[2];
    return [NSString stringWithFormat:@"%@ / %@ / %@", day, month, year];
}

- (void)askInvitationCode:(NSDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/invitations/ask" method:@"POST" params:user success:success failure:failure];
}

- (void)loginWithPseudoAndPassword:(NSDictionary *)user success:(void (^)(id result))success {
    id successBlock = ^(id result) {
        [self updateCurrentUserAndAskResetCode:result];
        
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoFlooz];
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelineFriends];
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelinePublic];
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoTimelinePrivate];
        [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kKeyTutoWelcome];
        
        if (success) {
            success(result);
        }
    };
    
    NSString *path = @"/users/login";
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:path method:@"POST" params:user success:successBlock failure:NULL];
}

- (void)checkSecureCodeForUser:(NSString*)secureCode success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/utils/asserts" method:@"POST" params:@{@"field": @"secureCode", @"value": secureCode} success:success failure:failure];
}

- (void)checkPhoneForUser:(NSString*)code success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/utils/asserts" method:@"POST" params:@{@"field": @"phone", @"value": code} success:success failure:failure];
}

- (NSString *)clearPhoneNumber:(NSString*)phone {
    return [FLHelper formatedPhone:phone];
}

- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *params = [user mutableCopy];
    params[@"codeReset"] = @YES;
    
    NSString *path = @"/users/login";
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:path method:@"POST" params:params success:success failure:failure];
}

- (void)passwordForget:(NSString*)login success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    if (login == nil)
        login = @"";
    
    [self requestPath:@"/users/password/lost" method:@"POST" params:@{ @"email": login } success:success failure:failure];
}

- (void)passwordLost:(NSString *)email success:(void (^)(id result))success {
    if (email == nil)
        email = @"";
    
    [self requestPath:@"password/lost" method:@"POST" params:@{ @"q": email } success:success failure:NULL];
}

- (void)reportContent:(FLReport *)report {
    [self requestPath:@"/reports" method:@"POST" params:@{@"type": report.type, @"resourceId": report.resourceID, @"message": @""} success:nil failure:nil];
}

- (void)blockUser:(NSString *)userId {
    [self requestPath:[NSString stringWithFormat:@"/users/%@/block", userId] method:@"GET" params:nil success:nil failure:nil];
}

- (void)updateCurrentUser {
    [self updateCurrentUserWithSuccess:^{}];
}

- (void)loadCactusData:(NSString*)identifier success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/users/cactus/%@", identifier] method:@"GET" params:nil success:success failure:failure];
}

- (void)getUserProfile:(NSString *)userId success:(void (^)(FLUser *result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/social/profile/%@", userId] method:@"GET" params:nil success:^(id result) {
        FLUser *user = [[FLUser alloc] initWithJSON:result[@"item"]];
        if (success)
            success(user);
    } failure:failure];
}

- (void)updateCurrentUserWithSuccess:(void (^)())success {
    if ([appDelegate shouldRefreshWithKey:kKeyLastUpdate]) {
        [self updateCurrentUserWithSuccess:success failure:nil];
    }
    else {
        if (success) {
            success();
        }
    }
}

- (void)checkContactList:(NSArray *)phones success:(void (^)(NSArray *result))success {
    [self requestPath:@"/utils/exists" method:@"POST" params:@{@"field":@"phones", @"value":phones} success:^(id result) {
        if (success)
            success(result[@"items"]);
    } failure:nil];
}

- (void)updateCurrentUserWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
    if ([appDelegate shouldRefreshWithKey:kKeyLastUpdate]) {
        __block id successBlock = ^(id result) {
            _currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];            _currentUser.isComplete = YES;
            _currentUser.isComplete = YES;
            
            [self updateFbToken:result[@"item"][@"fb"][@"token"] andUser:result[@"item"][@"fb"][@"id"]];
            
            [self checkDeviceToken];
            [self saveSettingsObject:[NSDate date] withKey:kKeyLastUpdate];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationReloadCurrentUser object:nil]];
            
            if (success) {
                success();
            }
        };
        
        NSString *path = @"/users/profile";
        
        [self requestPath:path method:@"GET" params:nil success:successBlock failure:failure];
    } else {
        if (success) {
            success();
        }
    }
}

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *_userDic = [user mutableCopy];
    if (user[@"birthdate"]) {
        [_userDic setObject:[self formatBirthDate:user[@"birthdate"]] forKey:@"birthdate"];
    }
    
    [self requestPath:@"/users/profile" method:@"PUT" params:_userDic success: ^(id result) {
        _currentUser = [[FLUser alloc] initWithJSON:result[@"item"]];
        _currentUser.isComplete = YES;
        
        [self checkDeviceToken];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationReloadCurrentUser object:nil]];
        
        [appDelegate setCanRefresh:YES];
        if (success) {
            success(result);
        }
    } failure:failure];
}

- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/users/password/change" method:@"POST" params:password success: ^(id result) {
        [self checkDeviceToken];
        [appDelegate setCanRefresh:YES];
        if (success) {
            success(result);
        }
    } failure:failure];
}

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure {
    id failureBlock = ^(NSURLSessionTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    
    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if (success)
            success();
    };
    
    [self requestPath:@"/users/profile/upload" method:@"POST" params:@{ @"field": field } success:successBlock failure:failureBlock constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:field fileName:@"image.jpg" mimeType:@"image/jpg"];
    }];
}

- (void)sendDiscountCode:(NSDictionary *)code success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/users/promo" method:@"POST" params:code success:success failure:failure];
}

- (void)invitationText:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    if (self.invitationTexts == nil) {
        [self loadInvitationData];
        if (self.invitationTexts && success)
            success(self.invitationTexts);
    } else if (success)
        success(self.invitationTexts);
    
    id successBlock = ^(id result) {
        self.invitationTexts = [[FLInvitationTexts alloc] initWithJSON:result[@"item"]];
        [self saveInvitationData];
        
        if (success) {
            success(self.invitationTexts);
        }
    
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadShareTexts object:nil];
    };
    
    id failureBlock = ^(NSError *error) {
        if (![self connectionStatusFromError:error]) {
            [self loadInvitationData];
            if (self.invitationTexts && success)
                success(self.invitationTexts);
            else if (failure)
                failure(error);
        } else if (failure) {
            failure(error);
        }
    };
    
    [self requestPath:@"/invitations/text" method:@"GET" params:nil success:successBlock failure:failureBlock];
}

- (void)invitationTextForce:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        self.invitationTexts = [[FLInvitationTexts alloc] initWithJSON:result[@"item"]];
        [self saveInvitationData];
        
        if (success) {
            success(self.invitationTexts);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadShareTexts object:nil];
    };
    
    id failureBlock = ^(NSError *error) {
        if (![self connectionStatusFromError:error]) {
            [self loadInvitationData];
            if (self.invitationTexts && success)
                success(self.invitationTexts);
            else if (failure)
                failure(error);
        } else if (failure) {
            failure(error);
        }
    };
    
    [self requestPath:@"/invitations/text" method:@"GET" params:nil success:successBlock failure:failureBlock];
}

- (void)invitationFacebook:(NSString *)text success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/invitations/facebook" method:@"POST" params:@{@"message":text} success:success failure:failure];
}

- (void)textObjectFromApi:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    if (self.currentTexts == nil) {
        [self loadTextData];
        if (self.currentTexts && success)
            success(self.currentTexts);
    } else if (success)
        success(self.currentTexts);
    
    id successBlock = ^(id result) {
        self.currentTexts = [[FLTexts alloc] initWithJSON:result[@"item"]];
        [self saveTextData];
        
        if (success) {
            success(self.currentTexts);
        }
    };
    
    id failureBlock = ^(NSError *error) {
        if (![self connectionStatusFromError:error]) {
            [self loadTextData];
            if (self.currentTexts && success)
                success(self.currentTexts);
            else if (failure)
                failure(error);
        } else if (failure) {
            failure(error);
        }
    };
    
    [self requestPath:@"/utils/texts" method:@"GET" params:nil success:successBlock failure:failureBlock];
}

- (void)userTimeline:(NSString *)userId success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        
        if (success) {
            success(transactions, result[@"next"]);
        }
    };
    
    [self requestPath:[NSString stringWithFormat:@"/users/%@/flooz", userId] method:@"GET" params:nil success:successBlock failure:failure];
}

- (void)collectTimeline:(NSString *)collectId success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        
        if (success) {
            success(transactions, result[@"next"]);
        }
    };
    
    [self requestPath:@"/flooz" method:@"GET" params:@{@"potId": collectId} success:successBlock failure:failure];
}

- (void)collectTimelineNextPage:(NSString *)nextPageUrl collectId:(NSString *)collectId success:(void (^)(id result, NSString *nextPageUrl))success {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        
        if (success) {
            success(transactions, result[@"next"]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:@{@"potId": collectId} success:successBlock failure:NULL];
}

- (void)collectInvite:(NSString *)collectId invitations:(NSArray *)invitations success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/pots/%@/invite", collectId] method:@"POST" params:@{@"invitations":invitations} success:success failure:failure];
}

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure {
    [self timeline:scope state:nil success:success failure:failure];
}

- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        
        self.timelinePageSize = [transactions count];
        
        [self saveTimeline:result[@"items"] forScope:[FLTransaction transactionParamsToScope:scope]];
        if (success) {
            [self saveSettingsObject:[NSDate date] withKey:[NSString stringWithFormat:@"kLastUpdate%@", scope]];
            success(transactions, result[@"next"], [FLTransaction transactionParamsToScope:result[@"scope"]]);
        }
    };
    
    id failureBlock = ^(NSError *error) {
        if (![self connectionStatusFromError:error]) {
            NSArray *transactions = [self loadTimelineData:[FLTransaction transactionParamsToScope:scope]];
            if (transactions && success) {
                self.timelinePageSize = [transactions count];
                success(transactions, nil, [FLTransaction transactionParamsToScope:scope]);
            } else if (failure)
                failure(error);
        } else if (failure) {
            failure(error);
        }
    };
    
    NSDictionary *params = nil;
    if (state) {
        params = @{ @"scope": scope, @"state": state };
    }
    else {
        params = @{ @"scope": scope };
    }
    
//    NSArray *transactions = [self loadTimelineData:[FLTransaction transactionParamsToScope:scope]];
//    if (transactions && success) {
//        self.timelinePageSize = [transactions count];
//        success(transactions, nil, [FLTransaction transactionParamsToScope:scope]);
//    }
    
    [self requestPath:@"/flooz" method:@"GET" params:params success:successBlock failure:failureBlock];
}

- (void)getPublicTimelineSuccess:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        if (success) {
            success(transactions, result[@"next"], [FLTransaction transactionParamsToScope:result[@"scope"]]);
        }
    };
    
    NSDictionary *params = @{ @"scope": @"public" };
    [self requestPath:@"/flooz" method:@"GET" params:params success:successBlock failure:failure];
}

- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success {
    id successBlock = ^(id result) {
        NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
        
        if (success) {
            success(transactions, result[@"next"], [FLTransaction transactionParamsToScope:result[@"scope"]]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success {
    NSString *path = [NSString stringWithFormat:@"/flooz/%@", transactionId];
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readTransactionWithId:(NSString *)transactionId success:(void (^)(id result))success {
    NSString *path = [NSString stringWithFormat:@"/feeds/read/%@", transactionId];
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readTransactionsSuccess:(void (^)(id result))success {
    NSString *path = @"/feeds/read/all";
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readFriendActivity:(void (^)(id result))success {
    NSString *path = @"/feeds/read/friend";
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        NSMutableArray *activities = [self createActivityArrayFromResult:result];
        _activitiesCached = activities;
        [self saveNotificationData:result[@"items"]];
        
        if (success) {
            success(activities, result[@"next"]);
        }
    };
    
    id failureBlock = ^(NSError *error) {
        if (![self connectionStatusFromError:error]) {
            NSArray *activities = [self loadNotificationData];
            _activitiesCached = activities;
            if (activities && success)
                success(activities, nil);
            else if (failure)
                failure(error);
        } else if (failure) {
            failure(error);
        }
    };
    
    [self requestPath:@"/feeds" method:@"GET" params:nil success:successBlock failure:failureBlock];
}

- (void)activitiesNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success {
    id successBlock = ^(id result) {
        NSMutableArray *activities = [self createActivityArrayFromResult:result];
        if (success) {
            success(activities, result[@"next"]);
        }
    };
    
    [self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (NSArray *)activitiesCached {
    if ([_activitiesCached count] == 0)
        _activitiesCached = [self loadNotificationData];
    
    if (_activitiesCached == nil)
        return @[];
    
    return _activitiesCached;
}

- (void)placesFrom:(NSString *)ll success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSArray *cachedPlaces = [self loadLocationData];
    
    if (cachedPlaces) {
        if (success)
            success(cachedPlaces);
    } else {
        [self requestPath:@"/geo/search" method:@"GET" params:@{@"ll": ll} success:^(id result) {
            NSArray *items = result[@"items"];
            
            [self saveLocationData:items];
            
            if (success)
                success(items);
        } failure:failure];
    }
}

- (void)placesSearch:(NSString *)search from:(NSString *)ll success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/geo/suggest" method:@"GET" params:@{@"ll": ll, @"q": search} success:^(id result) {
        NSArray *items = result[@"items"];
        
        if (success)
            success(items);
    } failure:failure];
}

- (void)createCollectValidate:(NSDictionary *)transaction success:(void (^)(id result))success {
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    
    if (tempTransaction[@"image"]) {
        [tempTransaction removeObjectForKey:@"image"];
        [tempTransaction setObject:@YES forKey:@"hasImage"];
    }
    
    [tempTransaction removeObjectForKey:@"toImage"];
    [tempTransaction removeObjectForKey:@"preset"];
    
    tempTransaction[@"validate"] = @"true";
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:@"/pots" method:@"POST" params:tempTransaction success:success fullFailure:nil];
}

- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success {
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    
    if (tempTransaction[@"image"]) {
        [tempTransaction removeObjectForKey:@"image"];
        [tempTransaction setObject:@YES forKey:@"hasImage"];
    }
    
    [tempTransaction removeObjectForKey:@"toImage"];
    [tempTransaction removeObjectForKey:@"preset"];
    
    tempTransaction[@"validate"] = @"true";
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:@"/flooz" method:@"POST" params:tempTransaction success:success fullFailure:nil];
}

- (void)createParticipationValidate:(NSDictionary *)transaction success:(void (^)(id result))success {
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    
    if (tempTransaction[@"image"]) {
        [tempTransaction removeObjectForKey:@"image"];
        [tempTransaction setObject:@YES forKey:@"hasImage"];
    }
    
    [tempTransaction removeObjectForKey:@"toImage"];
    [tempTransaction removeObjectForKey:@"preset"];
    
    tempTransaction[@"validate"] = @"true";
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:[NSString stringWithFormat:@"/pots/%@/participate", transaction[@"potId"]] method:@"POST" params:tempTransaction success:success fullFailure:nil];
}

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    void (^failureBlock1)(NSError *error);
    void (^successBlock1)(id result);
    
    NSMutableDictionary *dic = [transaction mutableCopy];;
    
    failureBlock1 = ^(NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    
    if (dic[@"toImage"])
        [dic removeObjectForKey:@"toImage"];
    
    if (dic[@"image"]) {
        [dic removeObjectForKey:@"image"];
        [dic setObject:@YES forKey:@"hasImage"];
    }
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [dic setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];

    successBlock1 = ^(id result) {
        if (success) {
            success(result);
        }
    };
    
    [self requestPath:@"/flooz" method:@"POST" params:dic success:successBlock1 failure:failureBlock1];
}

- (void)confirmTransactionSMS:(NSString *)floozId validate:(Boolean)validate success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/flooz/%@/status", floozId] method:@"POST" params:@{@"validate":(validate ? @YES : @NO)} success:success failure:failure];
}

- (void)uploadTransactionPic:(NSString *)transId image:(NSData*)image success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    id failureBlock = ^(NSURLSessionTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    
    [self requestPath:[NSString stringWithFormat:@"/flooz/%@/pic", transId] method:@"POST" params:nil success:success failure:failureBlock constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
        [formData appendPartWithFileData:image name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
    }];
}

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success;
{
    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if (success) {
            success(result);
        }
    };
    
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    tempTransaction[@"validate"] = @"true";
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    NSString *path = [NSString stringWithFormat:@"/flooz/%@", transaction[@"id"]];
    [self requestPath:path method:@"POST" params:tempTransaction success:successBlock fullFailure:nil];
}

- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if (success) {
            success(result);
        }
    };
    
    NSMutableDictionary *tempTransaction = [transaction mutableCopy];
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    NSString *path = [@"/flooz/" stringByAppendingString : transaction[@"id"]];
    [self requestPath:path method:@"POST" params:tempTransaction success:successBlock failure:failure];
}

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/social/comments/%@", comment[@"floozId"]] method:@"POST" params:comment success:success failure:failure];
}

- (void)cashoutValidate:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    [tempDic setObject:@YES forKey:@"validate"];
    [tempDic setObject:amount forKey:@"amount"];
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempDic setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:@"/cashouts" method:@"POST" params:tempDic success:success failure:failure];
}

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    [tempDic setObject:amount forKey:@"amount"];
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempDic setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:@"/cashouts" method:@"POST" params:tempDic success:success failure:failure];
}

- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    [tempDic setObject:@YES forKey:@"validate"];
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempDic setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];
    
    [self requestPath:@"/cashouts" method:@"POST" params:tempDic success:success failure:failure];
}

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/users/alerts" method:@"PUT" params:notification success:success failure:failure];
}

- (void)createCreditCard:(NSDictionary *)creditCard atSignup:(BOOL)signup success:(void (^)(id result))success {
    id successBlock = ^(id result) {
        if (success) {
            Secure3DViewController *secureView = [Secure3DViewController getInstance];
            if (secureView)
                [secureView setIsAtSignup:signup];
            
            [_currentUser setCreditCard:[[FLCreditCard alloc] initWithJSON:result[@"item"]]];
            success(result);
        }
    };
    
    NSString *path = @"/cards";
    if (signup) {
        path = [path stringByAppendingString:@"?context=signup"];
    }
    [self requestPath:path method:@"POST" params:creditCard success:successBlock failure:nil];
}

- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success {
    NSString *path = [@"/cards/" stringByAppendingString : creditCardId];
    [self requestPath:path method:@"DELETE" params:nil success:success failure:nil];
}

- (void)abort3DSecure {
    [self requestPath:@"/psp/3ds/abort" method:@"GET" params:nil success:nil failure:nil];
}

- (void)inviteWithPhone:(NSString *)phone {
    NSString *path = [@"/invitations/" stringByAppendingFormat : @"\%@", phone];
    [self requestPath:path method:@"GET" params:nil success:nil failure:nil];
}

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success {
    [self updateFriendRequest:dictionary success:success failure:nil];
}

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSString *path = [@"/social/" stringByAppendingFormat : @"%@/%@", dictionary[@"id"], dictionary[@"action"]];
    [self requestPath:path method:@"POST" params:nil success:success failure:nil];
}

- (void)friendsSuggestion:(void (^)(id result))success {
    id successBlock = ^(id result) {
        NSMutableArray *friends = [self createFriendsArrayFromResult:result sorted:NO];
        if (success) {
            success(friends);
        }
    };
    
    [self requestPath:@"/social/suggests" method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)friendsRequest:(void (^)(id result))success {
    id successBlock = ^(id result) {
        NSMutableArray *friends = [self createFriendsArrayFromResult:result sorted:YES];
        if (success) {
            success(friends);
        }
    };
    
    [self requestPath:@"/social/pendings" method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)friendFollow:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSString *path = [@"/social/" stringByAppendingFormat : @"%@/follow", friendId];
    [self requestPath:path method:@"POST" params:nil success:success failure:failure];
}

- (void)friendUnfollow:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSString *path = [@"/social/" stringByAppendingFormat : @"%@/unfollow", friendId];
    [self requestPath:path method:@"POST" params:nil success:success failure:failure];
}

- (void)friendRemove:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSString *path = [@"/social/" stringByAppendingFormat : @"%@/delete", friendId];
    [self requestPath:path method:@"POST" params:nil success:success failure:failure];
}

- (void)friendAdd:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure {
    NSString *path = [@"/social/" stringByAppendingFormat : @"%@/request", friendId];
    [self requestPath:path method:@"POST" params:nil success:success failure:failure];
}

- (void)friendSearch:(NSString *)text forNewFlooz:(BOOL)newFlooz withPhones:(NSArray*)phones success:(void (^)(id result, NSString *searchString))success {
    id successBlock = ^(id result) {
        NSMutableArray *friends = [self createFriendsArrayFromSearchResult:result];
        if (success) {
            success(friends, result[@"q"]);
        }
    };
    
    NSString *path = @"/social/search";
    if (newFlooz) {
        path = [path stringByAppendingString:@"?context=newFlooz"];
    }
    [self requestPath:path method:@"GET" params:@{ @"q" : text, @"phones" : phones } success:successBlock failure:nil];
}

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:[NSString stringWithFormat:@"/social/likes/%@", transaction.transactionId] method:@"POST" params:@{ @"floozId": [transaction transactionId] } success:success failure:failure];
}

- (void)sendSMSValidation {
    [self requestPath:@"/tokens/generate/phone" method:@"POST" params:nil success:nil failure:nil];
}

- (void)sendEmailValidation {
    [self requestPath:@"/tokens/generate/email" method:@"POST" params:nil success:nil failure:nil];
}

- (void)invitationStrings:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/invitations/texts" method:@"GET" params:nil success:success failure:failure];
}

- (void)sendInvitationMetric:(NSString *)canal {
    [self requestPath:@"/invitations/callback" method:@"GET" params:@{@"canal" : canal} success:nil failure:nil];
}

- (void)sendInvitationMetric:(NSString *)canal withTotal:(NSInteger)total {
    [self requestPath:@"/invitations/callback" method:@"GET" params:@{@"canal": canal, @"count":[NSNumber numberWithInteger:total]} success:nil failure:nil];
}

#pragma mark -

- (BOOL)connectionStatusFromError:(NSError *)error {
    if (error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorCannotConnectToHost || error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost)
        return NO;
    return YES;
}

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    id failureBlock = ^(NSURLSessionTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    };
    [self requestPath:path method:method params:params success:success failure:failureBlock constructingBodyWithBlock:NULL];
}

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success fullFailure:(void (^)(NSURLSessionTask *task, NSError *error))fullFailure {
    [self requestPath:path method:method params:params success:success failure:fullFailure constructingBodyWithBlock:NULL];
}

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSURLSessionTask *task, NSError *error))failure constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBodyWithBlock {
    
#ifdef FLOOZ_DEV_API
    NSLog(@"%@ request: %@ - %@", method, path, params);
#endif
    
    if (_access_token) {
        if ([path rangeOfString:@"?"].location == NSNotFound) {
            path = [path stringByAppendingFormat:@"?token=%@", _access_token];
        }
        else if ([path rangeOfString:@"token="].location == NSNotFound) { // Dans le cas des next url ou le token est deja forni
            path = [path stringByAppendingFormat:@"&token=%@", _access_token];
        }
    }
    
    if ([path rangeOfString:@"?"].location == NSNotFound) {
        path = [path stringByAppendingString:@"?via=ios"];
    }
    else {
        path = [path stringByAppendingString:@"&via=ios"];
    }
    
    // Pour le nextUrl
    if ([path rangeOfString:@"&version="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&version=%@", APP_VERSION]];
    }
    
    id successBlock = ^(NSURLSessionTask *task, id responseObject) {
        if (((NSHTTPURLResponse*)task.response).statusCode == 226) {
            [self handleRequestTriggers:responseObject];
        }
        else {
            [self hideLoadView];
            
            if (success) {
                success(responseObject);
            }
            
            [self displayPopupMessage:responseObject];
            [self handleRequestTriggers:responseObject];
        }
    };
    
    id failureBlock = ^(NSURLSessionDataTask *task, NSError *error) {
        [self hideLoadView];
        
        NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        
        if ((error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorCannotConnectToHost || error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost
             ) && ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"])) {
            [appDelegate displayMessage:@"Erreur de connexion" content:@"La connexion internet semble interrompue :(" style:FLAlertViewStyleError time:@5 delay:@0];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionError object:nil];
        }
        else if ((statusCode == 401 || error.code == kCFURLErrorUserCancelledAuthentication) && _access_token && ![path isEqualToString:@"/users/login"] && errorData) {
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
            
            if (serializedData) {
                [self displayPopupMessage:serializedData];
                [self handleRequestTriggers:serializedData];
            }
        }
        else if (errorData) {
            NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];

            if (serializedData) {
                [self displayPopupMessage:serializedData];
                [self handleRequestTriggers:serializedData];
            }
        }
        
        if (failure) {
            failure(task, error);
        }
    };
    
    if ([[method uppercaseString] isEqualToString:@"GET"]) {
        [manager GET:path parameters:params progress:nil success:successBlock failure:failureBlock];
    }
    else if ([[method uppercaseString] isEqualToString:@"POST"] && constructingBodyWithBlock != NULL) {
        NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[[NSURL URLWithString:path relativeToURL:manager.baseURL] absoluteString] parameters:params constructingBodyWithBlock:constructingBodyWithBlock error:nil];
        
        [request setTimeoutInterval:60];
        
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            if (error) {
                [self hideLoadView];
                
                NSInteger statusCode = ((NSHTTPURLResponse*)response).statusCode;
                NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                
                if ((error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorCannotConnectToHost || error.code == kCFURLErrorNotConnectedToInternet || error.code == kCFURLErrorNetworkConnectionLost
                     ) && ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"] || [method isEqualToString:@"DELETE"])) {
                    [appDelegate displayMessage:@"Erreur de connexion" content:@"La connexion internet semble interrompue :(" style:FLAlertViewStyleError time:@5 delay:@0];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionError object:nil];
                }
                else if ((statusCode == 401 || error.code == kCFURLErrorUserCancelledAuthentication) && _access_token && ![path isEqualToString:@"/users/login"] && errorData) {
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    
                    if (serializedData) {
                        [self displayPopupMessage:serializedData];
                        [self handleRequestTriggers:serializedData];
                    }
                }
                else if (errorData) {
                    NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
                    
                    if (serializedData) {
                        [self displayPopupMessage:serializedData];
                        [self handleRequestTriggers:serializedData];
                    }
                }
                
                if (failure) {
                    failure(nil, error);
                }
            } else {
                if (((NSHTTPURLResponse*)response).statusCode == 226) {
                    [self handleRequestTriggers:responseObject];
                }
                else {
                    [self hideLoadView];
                    
                    if (success) {
                        success(responseObject);
                    }
                    
                    [self displayPopupMessage:responseObject];
                    [self handleRequestTriggers:responseObject];
                }
            }
        }];
        
        [uploadTask resume];
    }
    else if ([[method uppercaseString] isEqualToString:@"POST"]) {
        [manager POST:path parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {} success:successBlock failure:failureBlock];
    }
    else if ([[method uppercaseString] isEqualToString:@"PUT"]) {
        [manager PUT:path parameters:params success:successBlock failure:failureBlock];
    }
    else if ([[method uppercaseString] isEqualToString:@"DELETE"]) {
        [manager DELETE:path parameters:params success:successBlock failure:failureBlock];
    }
    else {
        [self hideLoadView];
    }
}

- (void)sendSignupSMS:(NSString *)phone {
    [self requestPath:@"/utils/smstoken" method:@"POST" params:@{@"phone": phone} success:nil failure:nil];
}

#pragma mark -

- (void)updateCurrentUserAndAskResetCode:(id)result {
    _access_token = result[@"items"][0][@"token"];
    [UICKeyChainStore setString:_access_token forKey:@"login-token"];
    
    _currentUser = [[FLUser alloc] initWithJSON:result[@"items"][1]];
    _currentUser.isComplete = YES;
    
    [self updateFbToken:result[@"items"][1][@"fb"][@"token"] andUser:result[@"items"][1][@"fb"][@"id"]];
    
    [appDelegate didConnected];
    
    [self updateCurrentUser];
}

- (void)updateCurrentUserAfterConnect:(id)result {
    _access_token = result[@"items"][0][@"token"];
    [UICKeyChainStore setString:_access_token forKey:@"login-token"];
    
    _currentUser = [[FLUser alloc] initWithJSON:result[@"items"][1]];
    _currentUser.isComplete = YES;
    
    [self updateFbToken:result[@"items"][1][@"fb"][@"token"] andUser:result[@"items"][1][@"fb"][@"id"]];
    
    [appDelegate didConnected];
    [appDelegate goToAccountViewController];
    
    [self updateCurrentUser];
}

- (BOOL)autologin {
    NSString *token = [UICKeyChainStore stringForKey:@"login-token"];
    
    if (!token || [token isBlank]) {
        return NO;
    }
    
    _access_token = token;
    
    NSString *path = @"/users/login";
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:path method:@"POST" params:nil success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
    } failure: ^(NSError *error) {
        if ([self connectionStatusFromError:error] && error.code != 426)
            [self logout];
        else if (error.code != 426) {
            [self loadUserData];
            if (!self.currentUser)
                [self logout];
            else {
                [appDelegate didConnected];
                [appDelegate goToAccountViewController];
            }
        }
    }];
    
    return YES;
}
- (void)loginWithToken:(NSString *)token {
    [self loginWithToken:token success:nil failure:nil];
}

- (void)loginWithToken:(NSString *)token success:(void (^)())success failure:(void (^)(NSError *error))failure {
    
    if (!token || [token isBlank]) {
        if (failure)
            failure(nil);
        
        return;
    }
    
    [UICKeyChainStore setString:token forKey:@"login-token"];
    _access_token = token;
    
    NSString *path = @"/users/login";
    
    if ([GBDeviceInfo deviceInfo]) {
        if ([path rangeOfString:@"?os="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
        }
        
        if ([path rangeOfString:@"&mo="].location == NSNotFound) {
            path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
        }
    }
    
    if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
        path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
    }
    
    [self requestPath:path method:@"POST" params:nil success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
        if (success)
            success();
    } failure: ^(NSError *error) {
        if ([self connectionStatusFromError:error] && error.code != 426)
            [self logout];
        else if (error.code != 426) {
            [self loadUserData];
            if (!self.currentUser)
                [self logout];
            else {
                [appDelegate didConnected];
                [appDelegate goToAccountViewController];
                
                if (success)
                    success();
                
                return;
            }
        }
        if (failure)
            failure(error);
    }];
    
}

#pragma mark - Facebook

- (void)updateFbToken:(NSString *)token andUser:(NSString *)userId {
    _facebook_token = token;
    
    if (_facebook_token && (![FBSDKAccessToken currentAccessToken] || ![[[FBSDKAccessToken currentAccessToken] tokenString] isEqualToString:_facebook_token])) {
        [FBSDKAccessToken setCurrentAccessToken:[[FBSDKAccessToken alloc] initWithTokenString:_facebook_token permissions:@[@"public_profile",@"email",@"user_friends"] declinedPermissions:nil appID:@"152779318256915" userID:userId expirationDate:nil refreshDate:nil]];
    }
}

- (void)connectFacebook {
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    [self.fbLoginManager logInWithReadPermissions:@[@"public_profile",@"email",@"user_friends"] fromViewController:[appDelegate myTopViewController] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            [[Flooz sharedInstance] hideLoadView];
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
            [appDelegate displayMessage:nil content:[error description] style:FLAlertViewStyleError time:nil delay:nil];
        } else if (result.isCancelled) {
            [[Flooz sharedInstance] hideLoadView];
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
        } else {
            [[Flooz sharedInstance] didConnectFacebook];
        }
    }];
}

- (void)disconnectFacebook {
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    _facebook_token = nil;
    [self updateUser:@{ @"fb": @NO } success:nil failure:nil];
}

- (void)didConnectFacebook {
    _facebook_token = [[FBSDKAccessToken currentAccessToken] tokenString];
    
    if (_currentUser) {
        NSMutableDictionary *fbData = [NSMutableDictionary new];
        [fbData setObject:_facebook_token forKey:@"token"];
        
        NSDictionary * user = @{ @"fb": fbData };
        
        [self updateUser:user success:nil failure:nil];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationFbConnect object:nil]];
    }
    else {
        [self showLoadView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            
            NSString *path = @"/users/facebook";
            
            if ([GBDeviceInfo deviceInfo]) {
                if ([path rangeOfString:@"?os="].location == NSNotFound) {
                    path = [path stringByAppendingString:[NSString stringWithFormat:@"?os=%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]];
                }
                
                if ([path rangeOfString:@"&mo="].location == NSNotFound) {
                    path = [path stringByAppendingString:[NSString stringWithFormat:@"&mo=%@", [[GBDeviceInfo deviceInfo].modelString stringByReplacingOccurrencesOfString:@" " withString:@""]]];
                }
            }
            
            if ([path rangeOfString:@"&uuid="].location == NSNotFound) {
                path = [path stringByAppendingString:[NSString stringWithFormat:@"&uuid=%@", [DeviceUID uid]]];
            }
            
            [self requestPath:path method:@"POST" params:@{ @"accessToken": _facebook_token } success: ^(id result) {
                [self updateCurrentUserAfterConnect:result];
            } failure: ^(NSError *error) {
                
            }];
        });
    }
}

- (void)checkDeviceToken {
    if (!_currentUser || !appDelegate.currentDeviceToken) {
        return;
    }
    if ([_currentUser deviceToken]) {
        if ([_currentUser.deviceToken isEqualToString:appDelegate.currentDeviceToken]) {
            return;
        }
    }
    
    [self updateUser:@{ @"device": appDelegate.currentDeviceToken } success: ^(id result) {
        
    } failure:nil];
}

#pragma mark - Triggers

- (void)handleRequestTriggers:(NSDictionary*)responseObject {
    if (responseObject && responseObject[@"triggers"]) {
        if ([responseObject[@"triggers"] isKindOfClass:[NSArray class]])
            [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:responseObject[@"triggers"]]];
        else if ([responseObject[@"triggers"] isKindOfClass:[NSDictionary class]])
            [[FLTriggerManager sharedInstance] executeTrigger:[[FLTrigger alloc] initWithJson:responseObject[@"triggers"]]];
    }
}

#pragma mark - Popup

- (void)displayPopupMessage:(id)responseObject {
    if (responseObject && responseObject[@"popup"] && [responseObject objectForKey:@"popup"] != [NSNull null]) {
        [appDelegate displayMessage:[[FLAlert alloc] initWithJson:responseObject[@"popup"]]];
    }
}

#pragma mark - WebSocket

- (void)startSocket {
    
    if (self.socketConnected)
        return;
    
    self.socketConnected = YES;
    
    NSString *url;
    
#ifdef FLOOZ_DEV_LOCAL
    url = [NSString stringWithFormat:@"http://%@", [appDelegate localIp]];
#elif FLOOZ_DEV_API
    url = @"http://dev.flooz.me:80";
#else
    url = @"https://api.flooz.me:443";
#endif
    
    [SIOSocket socketWithHost:url reconnectAutomatically:YES attemptLimit:10 withDelay:1 maximumDelay:5 timeout:20 response:^(SIOSocket *socket) {
        self.socketIO = socket;
        
        __weak typeof(self) weakSelf = self;
        
        self.socketIO.onConnect = ^()
        {
            [weakSelf socketIODidConnect:weakSelf.socketIO];
        };
        
        self.socketIO.onDisconnect = ^()
        {
            [weakSelf socketIODidDisconnect:weakSelf.socketIO disconnectedWithError:nil];
        };
        
        self.socketIO.onError = ^(NSDictionary *errorInfo)
        {
            [weakSelf socketIODidDisconnect:weakSelf.socketIO disconnectedWithError:errorInfo];
        };
        
        self.socketIO.onReconnectionError = ^(NSDictionary *errorInfo)
        {
            [weakSelf socketIODidDisconnect:weakSelf.socketIO disconnectedWithError:errorInfo];
        };
        
        [self.socketIO on:@"event" callback:^(SIOParameterArray *args) {
            [self displayPopupMessage:[args firstObject]];
            [self handleRequestTriggers:[args firstObject]];
        }];
        
        [self.socketIO on:@"feed" callback:^(SIOParameterArray *args) {
            NSNumber *count = [args firstObject][@"total"];
            
            [UIApplication sharedApplication].applicationIconBadgeNumber = [count intValue];
            [self setNotificationsCount:count];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newNotifications" object:nil];
            
            [self handleRequestTriggers:[args firstObject]];
        }];
    }];
}

- (void)closeSocket {
    [self socketSendSessionEnd];
    [self.socketIO close];
    self.socketIO = nil;
    self.socketConnected = NO;
}

- (void)socketIODidConnect:(SIOSocket *)socket {
    self.socketConnected = YES;
    if (self.socketIO && _access_token && _currentUser) {
        [self.socketIO emit:@"session start" args:@[@{@"token": _access_token, @"nick": [_currentUser username]}]];
    }
}

- (void)socketIODidDisconnect:(SIOSocket *)socket disconnectedWithError:(NSDictionary *)error {
    self.socketConnected = NO;
}

- (void)socketSendSessionEnd {
    if (self.socketIO && _access_token && self.socketConnected) {
        [self.socketIO emit:@"session end" args:@[@{ @"token": _access_token, @"nick": [_currentUser username]}]];
    }
}

#pragma mark - signup

- (void)checkSignup:(NSDictionary *)userDic success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *dic = [userDic mutableCopy];
    [dic setObject:[self formatBirthDate:userDic[@"birthdate"]] forKey:@"birthdate"];
    if (userDic[@"picId"]) {
        [dic setValue:@YES forKey:@"hasImage"];
    }
    else {
        [dic setValue:@NO forKey:@"hasImage"];
    }
    [dic removeObjectForKey:@"picId"];
    [self signupPassStep:@"infos" user:dic success:success failure:failure];
}

- (void)verifyPseudo:(NSString *)pseudo success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/signup/check" method:@"POST" params:@{ @"nick": pseudo } success:success failure:failure];
}

- (void)verifyEmail:(NSString *)email success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/signup/check" method:@"POST" params:@{ @"email": email } success:success failure:failure];
}

#pragma mark - Contacts

- (void)sendContacts {
    [self requestAddressBookPermission];
}

- (void)requestAddressBookPermission {
    [self grantedAccessToContacts: ^(BOOL granted) {
        if (granted) {
            [self didAddressBookPermissionGranted];
        }
        else {
            DISPLAY_ERROR(FLContactAccessDenyError);
        }
    }];
}

- (void)didAddressBookPermissionGranted {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *contactsEmail = [NSMutableArray new];
    NSMutableArray *contactsPhone = [NSMutableArray new];
    
    for (int i = 0; i < nPeople; ++i) {
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople, i);
        
        ABMultiValueRef emailList = ABRecordCopyValue(ref, kABPersonEmailProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(emailList); ++i) {
            NSString *_email = (__bridge NSString *)ABMultiValueCopyValueAtIndex(emailList, i);
            
            [contactsEmail addObject:_email];
        }
        
        
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(ref, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); ++i) {
            NSString *_phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            if ([FLHelper isValidPhoneNumber:_phone]) {
                NSString *formatedPhone = [FLHelper formatedPhone:_phone];
                
                if (formatedPhone) {
                    [contactsPhone addObject:formatedPhone];
                }
            }
        }
        
        if (emailList)
            CFRelease(emailList);
        
        if (phoneNumbers)
            CFRelease(phoneNumbers);
    }
    
    CFRelease(allPeople);
    CFRelease(addressBook);
}

- (void)sendContactsAtSignup:(BOOL)signup WithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSString *path = @"/users/contacts";
    
    [self requestPath:path method:@"POST" params:params success:success failure:failure];
}

#pragma mark - contact adress book

- (void)getAdressBookContactList:(void (^)(NSMutableArray *arrayContactAdressBook))adressBook {
    [self getContactList: ^(NSMutableArray *arrayContacts, NSMutableArray *arrayServer) {
        NSMutableArray *array = [[self sortedArray:arrayContacts withKey:@"name" ascending:YES] mutableCopy];
        if (adressBook) {
            adressBook(array);
        }
    }];
}

- (void)createContactList:(void (^)(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz))lists atSignup:(BOOL)signup {
    [self getContactList: ^(NSMutableArray *arrayContacts, NSMutableArray *arrayServer) {
        arrayContacts = [[self sortedArray:arrayContacts withKey:@"name" ascending:YES] mutableCopy];
        [self sendContactsAtSignup:signup WithParams:@{ @"phones": arrayServer } success: ^(id result) {
            NSMutableArray *arrayFlooz = [self createFriendsArrayFromResult:result sorted:YES];
            NSMutableArray *arrayAB = [self removeFloozerFromArray:arrayFlooz inArray:arrayContacts];
            if (lists) {
                lists(arrayAB, arrayFlooz);
            }
            [[Flooz sharedInstance] saveSettingsObject:@YES withKey:kSendContact];
        } failure: ^(NSError *error) {
            if (lists) {
                lists(arrayContacts, nil);
            }
        }];
    }];
}

- (NSMutableArray *)removeFloozerFromArray:(NSArray *)arrayFloozer inArray:(NSMutableArray *)arrayAll {
    if (arrayFloozer.count) {
        NSMutableIndexSet *indexList = [[NSMutableIndexSet alloc] init];
        NSMutableArray *arrayIndex = [NSMutableArray new];
        //[_tableView beginUpdates];
        for (FLUser *contact in arrayFloozer) {
            int index = [self findUser:contact inArray:arrayAll];
            if (index != -1) {
                [indexList addIndex:index];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
                [arrayIndex addObject:indexPath];
            }
        }
        [arrayAll removeObjectsAtIndexes:indexList];
    }
    return arrayAll;
}

- (int)findUser:(FLUser *)contact inArray:(NSArray *)array {
    int i = 0;
    for (NSDictionary *infoContact in array) {
        for (NSString *phone in infoContact[@"phones"]) {
            if ([phone isEqualToString:contact.phone]) {
                return i;
            }
        }
        i++;
    }
    return -1;
}

- (NSArray *)sortedArray:(NSArray *)array withKey:(NSString *)key ascending:(BOOL)ascending {
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key
                                                 ascending:ascending];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return [array sortedArrayUsingDescriptors:sortDescriptors];
}

- (void)getContactList:(void (^)(NSMutableArray *arrayContacts, NSMutableArray *arrayServer))lists {
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    NSMutableArray *arrayPhonesAskServer = [NSMutableArray new];
    NSMutableArray *contactInfoArray = [NSMutableArray new];
    for (int i = 0; i < nPeople; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        
        NSString *firstNameObject = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastNameObject = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        NSData *imageData = (__bridge_transfer NSData *)ABPersonCopyImageDataWithFormat(person, kABPersonImageFormatThumbnail);
        
        NSString *phonesString = @"";
        NSMutableArray *contactsPhone = [NSMutableArray new];
        ABMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(phoneNumbers); ++i) {
            NSString *phone = (__bridge_transfer NSString *)ABMultiValueCopyValueAtIndex(phoneNumbers, i);
            NSString *_formatedPhone = [FLHelper formatedPhone:phone];
            if (_formatedPhone) {
                [contactsPhone addObject:_formatedPhone];
                [arrayPhonesAskServer addObject:_formatedPhone];
                
                phonesString = [phonesString stringByAppendingString:_formatedPhone];
                phonesString = [phonesString stringByAppendingString:@", "];
            }
        }
        if (phonesString.length > 2) {
            phonesString = [phonesString substringToIndex:phonesString.length - 2];
        }
        NSString *name = nil;
        if (!firstNameObject) {
            name = lastNameObject;
        }
        else if (!lastNameObject) {
            name = firstNameObject;
        }
        else {
            name = [firstNameObject stringByAppendingFormat:@" %@", lastNameObject];
        }
        
        if (contactsPhone.count && (firstNameObject || lastNameObject)) {
            for (NSString *phoneNumber in contactsPhone) {
                NSMutableDictionary *personDic = [NSMutableDictionary new];
                [personDic setObject:contactsPhone forKey:@"phones"];
                
                if (firstNameObject) {
                    [personDic setObject:[firstNameObject uppercaseString] forKey:@"firstname"];
                }
                if (lastNameObject) {
                    [personDic setObject:[lastNameObject uppercaseString] forKey:@"lastname"];
                }
                [personDic setValue:name forKey:@"name"];
                if (imageData) {
                    [personDic setObject:imageData forKey:@"image"];
                }
                
                [personDic setObject:phoneNumber forKey:@"phone"];
                [personDic setValue:[NSNumber numberWithBool:NO] forKey:@"selected"];
                [contactInfoArray addObject:personDic];
            }
        }
    }
    if (lists) {
        lists(contactInfoArray, arrayPhonesAskServer);
    }
}

#pragma mark - array from result dictionnary
- (NSMutableArray *)createFriendsArrayFromSearchResult:(NSDictionary *)result {
    NSMutableArray *arrayFriends = [NSMutableArray new];
    NSArray *friends = result[@"items"];
    if (friends) {
        for (NSDictionary *json in friends) {
            FLUser *friend = [[FLUser alloc] initWithJSON:json];
            [arrayFriends addObject:friend];
        }
    }
    return arrayFriends;
}

- (NSMutableArray *)createFriendsArrayFromResult:(NSDictionary *)result sorted:(BOOL)sorted {
    NSMutableArray *arrayFriends = [NSMutableArray new];
    NSArray *friends = result[@"items"];
    if (friends) {
        for (NSDictionary *json in friends) {
            FLUser *friend = [[FLUser alloc] initWithJSON:json];
            if (sorted) {
                NSUInteger newIndex = [self findIndexForUser:friend inArray:arrayFriends];
                [arrayFriends insertObject:friend atIndex:newIndex];
            } else
                [arrayFriends addObject:friend];
        }
    }
    return arrayFriends;
}

- (NSUInteger)findIndexForUser:(FLUser *)newUser inArray:(NSArray *)array {
    NSComparator comparator = ^NSComparisonResult (NSDictionary *obj1, NSDictionary *obj2) {
        NSString *username1;
        NSString *username2;
        if ([obj1 isKindOfClass:[FLUser class]]) {
            username1 = [(FLUser *)obj1 fullname];
        }
        else {
            username1 = obj1[@"name"];
        }
        if ([obj2 isKindOfClass:[FLUser class]]) {
            username2 = [(FLUser *)obj2 fullname];
        }
        else {
            username2 = obj2[@"name"];
        }
        return [username1 compare:username2];
    };
    NSUInteger newIndex = [array indexOfObject:newUser
                                 inSortedRange:(NSRange) {0, [array count] }
                                       options:NSBinarySearchingInsertionIndex
                               usingComparator:comparator];
    return newIndex;
}

- (NSMutableArray *)createActivityArrayFromResult:(NSDictionary *)result {
    NSMutableArray *arrayActivities = [NSMutableArray new];
    NSArray *activities = result[@"items"];
    if (activities) {
        for (NSDictionary *json in activities) {
            FLActivity *activity = [[FLActivity alloc] initWithJSON:json];
            if (activity)
                [arrayActivities addObject:activity];
        }
    }
    return arrayActivities;
}

- (NSMutableArray *)createActivityArrayFromSaveData:(NSArray *)result {
    NSMutableArray *arrayActivities = [NSMutableArray new];
    NSArray *activities = result;
    if (activities) {
        for (NSDictionary *json in activities) {
            FLActivity *activity = [[FLActivity alloc] initWithJSON:json];
            if (activity)
                [arrayActivities addObject:activity];
        }
    }
    return arrayActivities;
}

- (NSMutableArray *)createTransactionArrayFromResult:(NSDictionary *)result {
    NSMutableArray *arrayTransactions = [NSMutableArray new];
    NSArray *transactions = result[@"items"];
    if (transactions) {
        for (NSDictionary *json in transactions) {
//            if (json && json[@"deal"] && [json[@"deal"] boolValue]) {
//                FLTimelineDeal *deal = [[FLTimelineDeal alloc] initWithJSON:json];
//                [arrayTransactions addObject:deal];
//            } else {
                FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
                [arrayTransactions addObject:transaction];
//            }
        }
    }
    return arrayTransactions;
}

- (NSMutableArray *)createTransactionArrayFromSaveData:(NSArray *)result {
    NSMutableArray *arrayTransactions = [NSMutableArray new];
    NSArray *transactions = result;
    if (transactions) {
        for (NSDictionary *json in transactions) {
//            if (json && json[@"deal"] && [json[@"deal"] boolValue]) {
//                continue;
//                
//                FLTimelineDeal *deal = [[FLTimelineDeal alloc] initWithJSON:json];
//                [arrayTransactions addObject:deal];
//            } else {
                FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
                [arrayTransactions addObject:transaction];
//            }
        }
    }
    return arrayTransactions;
}

- (void)grantedAccessToContacts:(void (^)(BOOL granted))grant {
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(nil, nil);
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // If the app is authorized to access the first time then add the contact
                grant(YES);
            }
            else {
                // Show an alert here if user denies access telling that the contact cannot be added because you didn't allow it to access the contacts
                grant(NO);
            }
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // If the user user has earlier provided the access, then add the contact
        grant(YES);
    }
    else {
        // If the user user has NOT earlier provided the access, create an alert to tell the user to go to Settings app and allow access
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:kKeyAccessContacts]) {
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
            {
                UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
                [curr1 setTag:125];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [curr1 show];
                });
            }
            else
            {
                UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:nil, nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [curr2 show];
                });
            }
            
            [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:kKeyAccessContacts];
        }
        
        grant(NO);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 125 && buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark -
- (void)saveSettingsObject:(id)object withKey:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
