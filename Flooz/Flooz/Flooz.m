//
//  Flooz.m
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "Flooz.h"

#import <AFURLRequestSerialization.h>
#import <AFURLResponseSerialization.h>
#import <AFHTTPRequestOperation.h>

#import "AppDelegate.h"

#import <Accounts/Accounts.h>
#import <UICKeyChainStore.h>
#import <AddressBook/AddressBook.h>

#import <Analytics/Analytics.h>

#import "FLAlert.h"

#import "AvatarMenu.h"
#import "CreditCardViewController.h"
#import "SettingsIdentityViewController.h"
#import "SettingsCoordsViewController.h"
#import "3DSecureViewController.h"
#import "SecureCodeViewController.h"

#define APP_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]

@implementation Flooz

+ (Flooz *)sharedInstance {
	static dispatch_once_t once;
	static id instance;
	dispatch_once(&once, ^{ instance = self.new; });
	return instance;
}

- (id)init {
	self = [super init];
	if (self) {
#ifdef FLOOZ_DEV_API
		manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://dev.flooz.me"]];
#else
		manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.flooz.me"]];
#endif

		manager.requestSerializer = [AFJSONRequestSerializer serializer];
		manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        
		loadView = [FLLoadView new];

		_notificationsCount = @0;
		_notifications = @[];
		_activitiesCached = @[];
        
        self.socketConnected = NO;
	}
	return self;
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

#pragma mark -

- (void)clearLogin {
    [SecureCodeViewController clearSecureCode];

    _currentUser = nil;
	_access_token = nil;
	_facebook_token = nil;
	_activitiesCached = @[];

	[UICKeyChainStore removeItemForKey:@"login-token"];
}

- (void)logout {
	if ([_currentUser deviceToken]) {
		[self requestPath:@"/logout" method:@"GET" params:@{ @"device":[_currentUser deviceToken] } success:nil failure:nil];
	}
	[self closeSocket];
    [self clearLogin];
	[appDelegate didDisconnected];
}

- (void)signup:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	id successBlock = ^(id result) {
		[self updateCurrentUserAndAskResetCode:result];

#ifndef FLOOZ_DEV_API
		[[SEGAnalytics sharedAnalytics] track:@"signup" properties:@{
		     @"userId": [[[Flooz sharedInstance] currentUser] userId]
		 }];
#endif
        
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoFlooz];
        [[Flooz sharedInstance] saveSettingsObject:@NO withKey:kKeyTutoTimeline];

		if (success) {
			success(result);
		}
	};

	NSMutableDictionary *_userDic = [user mutableCopy];
	[_userDic setObject:[self formatBirthDate:user[@"birthdate"]] forKey:@"birthdate"];

	[self requestPath:@"signup" method:@"POST" params:_userDic success:successBlock failure:failure];
}

- (NSString *)formatBirthDate:(NSString *)birthdate {
    NSArray *strings = [birthdate componentsSeparatedByString:@" / "];
    NSString *day = strings[0];
    NSString *month = strings[1];
    NSString *year = strings[2];
    return [NSString stringWithFormat:@"%@-%@-%@", year, month, day];
}

- (NSString *)formatBirthDateFromFacebook:(NSString *)birthdate {
    NSArray *strings = [birthdate componentsSeparatedByString:@"/"];
    NSString *day = strings[1];
    NSString *month = strings[0];
    NSString *year = strings[2];
    return [NSString stringWithFormat:@"%@ / %@ / %@", day, month, year];
}

- (void)askInvitationCode:(NSDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"invitations/ask" method:@"POST" params:user success:success failure:failure];
}

- (void)loginWithPseudoAndPassword:(NSDictionary *)user success:(void (^)(id result))success {
	id successBlock = ^(id result) {
		[self updateCurrentUserAndAskResetCode:result];
		if (success) {
			success(result);
		}
	};
    
    [self requestPath:@"/login/basic" method:@"POST" params:user success:successBlock failure:NULL];
}

- (void)loginWithCodeForUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"/login/basic" method:@"POST" params:user success: ^(id result) {
	    [self updateCurrentUserAfterConnect:result];
	    [appDelegate goToAccountViewController];
	    if (success) {
	        success(result);
		}
	} failure:failure];
}

- (void)checkSecureCodeForUser:(NSString*)secureCode success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    [self requestPath:@"/users/checkSecureCode" method:@"POST" params:@{@"secureCode":secureCode} success:success failure:failure];
}

- (NSString *)clearPhoneNumber:(NSString*)phone {
    NSString *formatedPhone = [[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]
                                stringByReplacingOccurrencesOfString:@"." withString:@""]
                               stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    if (![formatedPhone hasPrefix:@"+33"]) {
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"+33"];
    }
    
    return formatedPhone;
}

- (void)loginWithPhone:(NSString *)phone {
   	// Remove useless characters
    NSString *formatedPhone = [[[[phone stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]
                                stringByReplacingOccurrencesOfString:@"." withString:@""]
                               stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    // Replace +33 with 0
    if ([formatedPhone hasPrefix:@"+33"]) {
        formatedPhone = [formatedPhone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@"0"];
    }

    [self requestPath:@"/login/quick" method:@"GET" params:@{ @"q": formatedPhone } success:nil failure:nil];
}

- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	NSMutableDictionary *params = [user mutableCopy];
	params[@"codeReset"] = @1;

	[self requestPath:@"/login/basic" method:@"POST" params:params success:success failure:failure];
}

- (void)passwordLost:(NSString *)email success:(void (^)(id result))success {
	[self requestPath:@"password/lost" method:@"POST" params:@{ @"q": email } success:success failure:NULL];
}

- (void)reportContent:(FLReport *)report {
    [self requestPath:@"/reports" method:@"POST" params:@{@"type": report.type, @"resourceId": report.resourceID} success:nil failure:nil];
}

- (void)blockUser:(NSString *)userId {
    [self requestPath:[NSString stringWithFormat:@"/users/%@/block", userId] method:@"GET" params:nil success:nil failure:nil];
}

- (void)updateCurrentUser {
[self updateCurrentUserWithSuccess:^{}];
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

- (void)updateCurrentUserWithSuccess:(void (^)())success failure:(void (^)(NSError *error))failure {
	__block id successBlock = ^(id result) {
		_currentUser = [[FLUser alloc] initWithJSON:[result objectForKey:@"item"]];
		_facebook_token = result[@"item"][@"fb"][@"token"];

		[self checkDeviceToken];
        [self saveSettingsObject:[NSDate date] withKey:kKeyLastUpdate];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationReloadCurrentUser object:nil]];

		if (success) {
			success();
		}
	};

	[self requestPath:@"profile" method:@"GET" params:nil success:successBlock failure:failure];
}

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *_userDic = [user mutableCopy];
    if (user[@"birthdate"]) {
        [_userDic setObject:[self formatBirthDate:user[@"birthdate"]] forKey:@"birthdate"];
    }
    
	[self requestPath:@"profile" method:@"PUT" params:_userDic success: ^(id result) {
	    _currentUser = [[FLUser alloc] initWithJSON:result[@"item"]];

	    [self checkDeviceToken];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kNotificationReloadCurrentUser object:nil]];

	    [appDelegate setCanRefresh:YES];
	    if (success) {
	        success(result);
		}
	} failure:failure];
}

- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"password/change" method:@"POST" params:password success: ^(id result) {
	    [self checkDeviceToken];
	    [appDelegate setCanRefresh:YES];
	    if (success) {
	        success(result);
		}
	} failure:failure];
}

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure {
	id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(error);
		}
	};

    id successBlock = ^(id result) {
        [self updateCurrentUser];
        
        if (success)
            success();
    };
    
	[self requestPath:@"/profile/upload" method:@"POST" params:@{ @"field": field } success:successBlock failure:failureBlock constructingBodyWithBlock: ^(id <AFMultipartFormData> formData) {
	    [formData appendPartWithFileData:data name:field fileName:@"image.jpg" mimeType:@"image/jpg"];
	}];
}

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
    if ([appDelegate shouldRefreshWithKey:[NSString stringWithFormat:@"kLastUpdate%@", scope]]) {
        [self timeline:scope state:nil success:success failure:failure];
    }
    else {
        failure(nil);
    }
}

- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
	id successBlock = ^(id result) {
		NSMutableArray *transactions = [self createTransactionArrayFromResult:result];

		[_currentUser updateStatsPending:result];

        if (success) {
            [self saveSettingsObject:[NSDate date] withKey:[NSString stringWithFormat:@"kLastUpdate%@", scope]];
            success(transactions, result[@"next"]);
		}
	};

	NSDictionary *params = nil;
	if (state) {
		params = @{ @"scope": scope, @"state": state };
	}
	else {
		params = @{ @"scope": scope };
	}

	[self requestPath:@"flooz" method:@"GET" params:params success:successBlock failure:failure];
}

- (void)getPublicTimelineSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
	id successBlock = ^(id result) {
		NSMutableArray *transactions = [self createTransactionArrayFromResult:result];
		if (success) {
			success(transactions, result[@"next"]);
		}
	};

	NSDictionary *params = @{ @"scope": @"public" };
	[self requestPath:@"flooz" method:@"GET" params:params success:successBlock failure:failure];
}

- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success {
	id successBlock = ^(id result) {
		NSMutableArray *transactions = [self createTransactionArrayFromResult:result];

		if (success) {
			success(transactions, result[@"next"]);
		}
	};

	[self requestPath:nextPageUrl method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success {
	NSString *path = [NSString stringWithFormat:@"flooz/%@", transactionId];
	[self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readTransactionWithId:(NSString *)transactionId success:(void (^)(id result))success {
	NSString *path = [NSString stringWithFormat:@"/feed/read/%@", transactionId];
	[self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readTransactionsSuccess:(void (^)(id result))success {
    NSString *path = @"/feed/read";
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)readFriendActivity:(void (^)(id result))success {
    NSString *path = @"/feed/read/friend";
    [self requestPath:path method:@"GET" params:nil success:success failure:NULL];
}

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure {
	id successBlock = ^(id result) {
		NSMutableArray *activities = [self createActivityArrayFromResult:result];
		if (success) {
			_activitiesCached = activities;
			success(activities, result[@"next"]);
		}
	};

	[self requestPath:@"feeds" method:@"GET" params:nil success:successBlock failure:failure];
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
	return _activitiesCached;
}

- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
{
	NSMutableDictionary *tempTransaction = [transaction mutableCopy];
	[tempTransaction removeObjectForKey:@"image"];
	[tempTransaction removeObjectForKey:@"toImage"];
    [tempTransaction removeObjectForKey:@"preset"];
	tempTransaction[@"validate"] = @"true";
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempTransaction setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];

    [self requestPath:@"flooz" method:@"POST" params:tempTransaction success:success fullFailure:nil];
}

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	void (^failureBlock1)(NSError *error);

	failureBlock1 = ^(NSError *error) {
		if (failure) {
			failure(error);
		}
	};

	if (transaction[@"toImage"]) {
		NSData *image = transaction[@"toImage"];
		[transaction setValue:nil forKey:@"toImage"];

		failureBlock1 = ^(NSError *error) {
			[transaction setValue:image forKey:@"toImage"];
			if (failure) {
				failure(error);
			}
		};
	}

	if (transaction[@"image"]) {
		NSData *image = transaction[@"image"];
		[transaction setValue:nil forKey:@"image"];

		id failureBlock2 = ^(NSError *error) {
			[transaction setValue:image forKey:@"image"];

			failureBlock1(error);
		};

		[self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failureBlock2 constructingBodyWithBlock: ^(id < AFMultipartFormData > formData) {
		    [formData appendPartWithFileData:image name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
		}];
	}
	else {
		[self requestPath:@"flooz" method:@"POST" params:transaction success:success failure:failureBlock1];
	}
}

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
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

	id failure = ^(AFHTTPRequestOperation *operation, NSError *error) {
		if (operation && operation.responseObject && [operation.responseObject[@"item"][@"code"] intValue] == 107) {
			noCreditCard();
		}
	};

	NSString *path = [NSString stringWithFormat:@"flooz/%@", transaction[@"id"]];
	[self requestPath:path method:@"POST" params:tempTransaction success:successBlock fullFailure:failure];
}

- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	id successBlock = ^(id result) {
		[self updateCurrentUser];

		if (success) {
			success(result);
		}
	};

	NSString *path = [@"flooz/" stringByAppendingString : transaction[@"id"]];
	[self requestPath:path method:@"POST" params:transaction success:successBlock failure:failure];
}

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"comments" method:@"POST" params:comment success:success failure:failure];
}

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"cashout" method:@"POST" params:@{ @"amount": amount } success:success failure:failure];
}

- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    [tempDic setObject:@YES forKey:@"validate"];
    
    if ([SecureCodeViewController hasSecureCodeForCurrentUser])
        [tempDic setObject:[SecureCodeViewController secureCodeForCurrentUser] forKey:@"secureCode"];

	[self requestPath:@"cashout" method:@"POST" params:tempDic success:success failure:failure];
}

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"alerts" method:@"PUT" params:notification success:success failure:failure];
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

	NSString *path = @"cards";
	if (signup) {
		path = [path stringByAppendingString:@"?context=signup"];
	}
	[self requestPath:path method:@"POST" params:creditCard success:successBlock failure:nil];
}

- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success {
	NSString *path = [@"cards/" stringByAppendingString : creditCardId];
	[self requestPath:path method:@"DELETE" params:nil success:success failure:nil];
}

- (void)abort3DSecure {
    [self requestPath:@"3ds/abort" method:@"GET" params:nil success:nil failure:nil];
}

- (void)inviteWithPhone:(NSString *)phone {
	NSString *path = [@"invite/" stringByAppendingFormat : @"\%@", phone];
	[self requestPath:path method:@"GET" params:nil success:nil failure:nil];
}

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success {
	NSString *path = [@"friends/" stringByAppendingFormat : @"%@/%@", dictionary[@"id"], dictionary[@"action"]];
	[self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)friendsSuggestion:(void (^)(id result))success {
	id successBlock = ^(id result) {
		NSMutableArray *friends = [self createFriendsArrayFromResult:result];
		if (success) {
			success(friends);
		}
	};

	[self requestPath:@"/friends/suggestion" method:@"GET" params:nil success:successBlock failure:NULL];
}

- (void)friendRemove:(NSString *)friendId success:(void (^)())success {
	NSString *path = [@"/friends/" stringByAppendingFormat : @"%@/delete", friendId];
	[self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)friendAcceptSuggestion:(NSString *)friendId success:(void (^)())success {
	NSString *path = [@"/friends/request/" stringByAppendingString : friendId];
	[self requestPath:path method:@"GET" params:nil success:success failure:nil];
}

- (void)friendSearch:(NSString *)text forNewFlooz:(BOOL)newFlooz success:(void (^)(id result))success {
	id successBlock = ^(id result) {
		NSMutableArray *friends = [self createFriendsArrayFromResult:result];
		if (success) {
			success(friends);
		}
	};

	NSString *path = @"/friends/search";
	if (newFlooz) {
		path = [path stringByAppendingString:@"?context=newFlooz"];
	}
	[self requestPath:path method:@"GET" params:@{ @"q" : text } success:successBlock failure:nil];
}

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"likes" method:@"POST" params:@{ @"lineId": [transaction transactionId] } success:success failure:failure];
}

- (void)sendSMSValidation {
	[self requestPath:@"verify/phone" method:@"POST" params:nil success:nil failure:nil];
}

- (void)sendEmailValidation {
	[self requestPath:@"verify/email" method:@"POST" params:nil success:nil failure:nil];
}

#pragma mark -

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
		if (failure) {
			failure(error);
		}
	};
	[self requestPath:path method:method params:params success:success failure:failureBlock constructingBodyWithBlock:NULL];
}

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success fullFailure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))fullFailure {
	[self requestPath:path method:method params:params success:success failure:fullFailure constructingBodyWithBlock:NULL];
}

- (void)requestPath:(NSString *)path method:(NSString *)method params:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))constructingBodyWithBlock {

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

	id successBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
        if (operation.response.statusCode == 226) {
            [self handleRequestTriggers:responseObject];
        }
        else {
            [loadView hide];
        
            [self displayPopupMessage:responseObject];
            [self handleRequestTriggers:responseObject];

            if (success) {
                success(responseObject);
            }
        }
	};

	id failureBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
		[loadView hide];

		id statusCode = operation.responseObject[@"statusCode"];

		if (error.code == kCFURLErrorTimedOut ||
		         error.code == kCFURLErrorCannotConnectToHost ||
		         error.code == kCFURLErrorNotConnectedToInternet ||
		         error.code == kCFURLErrorNetworkConnectionLost
		         ) {
            [appDelegate displayMessage:@"Erreur de connexion" content:@"La connexion internet semble interrompue :(" style:FLAlertViewStyleError time:@5 delay:@0];
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationConnectionError object:nil];
		}
		else if (([statusCode intValue] == 401 || error.code == kCFURLErrorUserCancelledAuthentication) && _access_token && ![path isEqualToString:@"/login/basic"]) {
			[self displayPopupMessage:operation.responseObject];
            [self handleRequestTriggers:operation.responseObject];
        }
		else if (operation.responseObject) {
			[self displayPopupMessage:operation.responseObject];
            [self handleRequestTriggers:operation.responseObject];
        }
        
		if (failure) {
			failure(operation, error);
		}
	};

	if ([method isEqualToString:@"GET"]) {
		[manager GET:path parameters:params success:successBlock failure:failureBlock];
	}
	else if ([method isEqualToString:@"POST"] && constructingBodyWithBlock != NULL) {
		[manager POST:path parameters:params constructingBodyWithBlock:constructingBodyWithBlock success:successBlock failure:failureBlock];
	}
	else if ([method isEqualToString:@"POST"]) {
		[manager POST:path parameters:params success:successBlock failure:failureBlock];
	}
	else if ([method isEqualToString:@"PUT"]) {
		[manager PUT:path parameters:params success:successBlock failure:failureBlock];
	}
	else if ([method isEqualToString:@"DELETE"]) {
		[manager DELETE:path parameters:params success:successBlock failure:failureBlock];
	}
	else {
		[loadView hide];
	}
}

- (void)verifyInvitationCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	[self requestPath:@"/signup/check" method:@"POST" params:user success:success failure:failure];
}

#pragma mark -

- (void)updateCurrentUserAndAskResetCode:(id)result {
	_access_token = result[@"items"][0][@"token"];
	[UICKeyChainStore setString:_access_token forKey:@"login-token"];

	_currentUser = [[FLUser alloc] initWithJSON:result[@"items"][1]];
	_facebook_token = result[@"items"][1][@"fb"][@"token"];

	[appDelegate didConnected];

	[self checkDeviceToken];
}

- (void)updateCurrentUserAfterConnect:(id)result {
	_access_token = result[@"items"][0][@"token"];
	[UICKeyChainStore setString:_access_token forKey:@"login-token"];

	_currentUser = [[FLUser alloc] initWithJSON:result[@"items"][1]];
	_facebook_token = result[@"items"][1][@"fb"][@"token"];

	[appDelegate didConnected];
	[appDelegate goToAccountViewController];

	[self checkDeviceToken];
}

- (void)updateCurrentUserAfterConnectAndAskCode:(id)result {
	_access_token = result[@"items"][0][@"token"];
	[UICKeyChainStore setString:_access_token forKey:@"login-token"];

	_currentUser = [[FLUser alloc] initWithJSON:result[@"items"][1]];
	_facebook_token = result[@"items"][1][@"fb"][@"token"];

	[appDelegate didConnected];

	[self checkDeviceToken];
	[appDelegate askForSecureCodeWithUser:@{ @"login":_currentUser.username, @"hasSecureCode":@NO }];
}

- (BOOL)autologin {
	NSString *token = [UICKeyChainStore stringForKey:@"login-token"];

	if (!token || [token isBlank]) {
		return NO;
	}

	_access_token = token;
    
    [self requestPath:@"/login/basic" method:@"POST" params:nil success:^(id result) {
        [self updateCurrentUserAfterConnect:result];
	} failure: ^(NSError *error) {
	    [self logout];
	}];

	return YES;
}

#pragma mark - Facebook

- (void)getInfoFromFacebook {
	[[FBSession activeSession] closeAndClearTokenInformation];

	[FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email", @"user_birthday", @"user_friends", @"publish_actions"]
	                                   allowLoginUI:YES
	                              completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
	    _facebook_token = [[[FBSession activeSession] accessTokenData] accessToken];

	    [FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,devices,birthday" completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
	        [self hideLoadView];
	        if (!error) {
	            NSString *birthday = @"";
	            if (result[@"birthday"]) {
                    birthday = [self formatBirthDateFromFacebook:result[@"birthday"]];
				}
	            NSDictionary *user = @{
	                @"picId": [NSData new],
	                @"email": result[@"email"],
	                @"idFacebook": result[@"id"],
	                @"birthdate" : birthday,
	                @"fullName": result[@"name"],
	                @"avatarURL": [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=360&height=360", result[@"id"]],
	                @"fb": @{
	                    @"email": result[@"email"],
	                    @"id": result[@"id"],
	                    @"name": result[@"name"],
	                    @"lastName": result[@"last_name"],
	                    @"firstName": result[@"first_name"],
	                    @"token": _facebook_token
					}
				};

	            [appDelegate showSignupAfterFacebookWithUser:user];
			}
		}];
	}];
}

- (void)getFacebookPhoto:(void (^)(id result))success {
    [FBSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         [FBRequestConnection startWithGraphPath:@"/me?fields=id" completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 if (success) {
                     success(result);
                 }
             }
         }];
     }];
}

- (void)connectFacebook {
	[[FBSession activeSession] closeAndClearTokenInformation];

	[FBSession openActiveSessionWithReadPermissions:@[@"public_profile,email,user_friends,publish_actions"]
	                                   allowLoginUI:YES
	                              completionHandler:
	 ^(FBSession *session, FBSessionState state, NSError *error) {
	    [appDelegate facebookSessionStateChanged:session state:state error:error];
	}];
}

- (void)disconnectFacebook {
	_facebook_token = nil;
	[self updateUser:@{ @"fb": @{}
	 } success:nil failure:nil];
}

- (void)didConnectFacebook {
	_facebook_token = [[[FBSession activeSession] accessTokenData] accessToken];

	if (_currentUser) {
		[FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,devices" completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
		    [self hideLoadView];

		    if (!error) {
		        NSDictionary * user = @{
		            @"fb": @{
		                @"email": result[@"email"],
		                @"id": result[@"id"],
		                @"name": result[@"name"],
		                @"token": (_facebook_token ? _facebook_token : @"")
					}
				};

		        [self updateUser:user success:nil failure:nil];
			}
		    else {
		        // An error occurred, we need to handle the error
		        // See: https://developers.facebook.com/docs/ios/errors
			}
		}];
	}
	else {
		[self requestPath:@"/login/facebook" method:@"POST" params:@{ @"token": _facebook_token } success: ^(id result) {
		    [self updateCurrentUserAfterConnectAndAskCode:result];
		} failure: ^(NSError *error) {
		    [FBRequestConnection startWithGraphPath:@"/me?fields=id,email,first_name,last_name,name,devices" completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
		        [self hideLoadView];

		        if (!error) {
		            NSDictionary * user = @{
		                @"email": result[@"email"],
		                @"lastName": result[@"last_name"],
		                @"firstName": result[@"first_name"],
		                @"avatarURL": [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=360&height=360", result[@"id"]],
		                @"fb": @{
		                    @"email": result[@"email"],
		                    @"id": result[@"id"],
		                    @"name": result[@"name"],
		                    @"token": _facebook_token
						}
					};

		            [appDelegate showSignupAfterFacebookWithUser:user];
				}
		        else {
		            // An error occurred, we need to handle the error
		            // See: https://developers.facebook.com/docs/ios/errors
				}
			}];
		}];
	}
}

- (void)facebokSearchFriends:(void (^)(id result))success {
	[FBRequestConnection startWithGraphPath:@"/me/friends?fields=first_name,last_name,name,id,picture" completionHandler: ^(FBRequestConnection *connection, id result, NSError *error) {
	    [self hideLoadView];

	    if (!error) {
	        success(result[@"data"]);
		}
	    else {
//	        NSLog(@"facebokSearchFriends: %@", [error description]);
		}
	}];
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
        _currentUser.deviceToken = appDelegate.currentDeviceToken;
    } failure:nil];
}

#pragma mark - Triggers

- (void)handleTriggerTimelineReload:(NSDictionary *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadTimeline object:nil];
}

- (void)handleTriggerLineShow:(NSDictionary *)data {
    NSString *resourceID = data[@"_id"];
    
    if (resourceID) {
        [self showLoadView];
        [self transactionWithId:resourceID success: ^(id result) {
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [appDelegate showTransaction:transaction inController:appDelegate.currentController withIndexPath:nil focusOnComment:NO];
        }];
    }
}

- (void)handleTriggerAvatarShow:(NSDictionary *)data {
    [[AvatarMenu new] showAvatarMenu:[appDelegate currentController]];
}

- (void)handleTriggerProfileReload:(NSDictionary *)data {
    [self updateCurrentUser];
}

- (void)handleTriggerCardShow:(NSDictionary *)data {
    CreditCardViewController *controller = [CreditCardViewController new];
    controller.showCross = YES;
    [[appDelegate currentController] presentViewController:controller animated:YES completion:NULL];
}

- (void)handleTriggerFriendReload:(NSDictionary *)data {
    [self updateCurrentUser];
}

- (void)handleTriggerFriendShow:(NSDictionary *)data {
    [appDelegate showFriendsController];
}

- (void)handleTriggerProfileShow:(NSDictionary *)data {
    [appDelegate showEditProfil];
}

- (void)handleTriggerTransactionReload:(NSDictionary *)data {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshTransaction object:nil];
}

- (void)handleTriggerLoginShow:(NSDictionary *)data {
    [self clearLogin];
    NSMutableDictionary *user = [NSMutableDictionary new];
    
    if (data[@"nick"])
        user[@"login"] = data[@"nick"];
    
    if (data[@"secureCode"])
        user[@"hasSecureCode"] = data[@"secureCode"];

    [appDelegate askForSecureCodeWithUser:user];
}

- (void)handleTriggerSignupShow:(NSDictionary *)data {
    [appDelegate showSignupWithUser:data];
}

- (void)handleTriggerSignupCodeShow:(NSDictionary *)data {
    [appDelegate showRequestInvitationCodeWithUser:data];
}

- (void)handleTriggerLogout:(NSDictionary *)data {
    [self clearLogin];
    [self logout];
}

- (void)handleTriggerAppUpdate:(NSDictionary *)data {
    [appDelegate lockForUpdate:data[@"uri"]];
}

- (void)handleTriggerContactInfoShow:(NSDictionary *)data {
    SettingsCoordsViewController *controller = [SettingsCoordsViewController new];
    [[appDelegate currentController] presentViewController:controller animated:YES completion:NULL];
}

- (void)handleTriggerUserIdentityShow:(NSDictionary *)data {
    SettingsIdentityViewController *controller = [SettingsIdentityViewController new];
    [[appDelegate currentController] presentViewController:controller animated:YES completion:NULL];
}

- (void)handleTrigger3DSecureShow:(NSDictionary *)data {
    Secure3DViewController *controller = [Secure3DViewController createInstance];
    [controller setHtmlContent:data[@"html"]];
    [[appDelegate currentController] presentViewController:controller animated:YES completion:NULL];
}

- (void)handleTrigger3DSecureComplete:(NSDictionary *)data {
    Secure3DViewController *controller = [Secure3DViewController getInstance];
    [controller dismissViewControllerAnimated:YES completion:^{
        if (controller.isAtSignup)
            [appDelegate showSignupAfter3DSecureWithUser:data];
        [Secure3DViewController clearInstance];
    }];
}

- (void)handleTrigger3DSecureFail:(NSDictionary *)data {
    Secure3DViewController *controller = [Secure3DViewController getInstance];
    [controller dismissViewControllerAnimated:YES completion:^{
        [Secure3DViewController clearInstance];
    }];
}

- (void)handleTriggerResetPassword:(NSDictionary *)data {
    [appDelegate showResetPasswordWithUser:data];
}

- (void)handleTriggerClearSecureCode:(NSDictionary *)data {
    [SecureCodeViewController clearSecureCode];
}

- (void)handleTriggerCheckSecureCode:(NSDictionary *)data {
    [self checkSecureCodeForUser:[SecureCodeViewController secureCodeForCurrentUser] success:nil failure:^(NSError *error) {
        [SecureCodeViewController clearSecureCode];
    }];
}

- (void)handleTriggerPresetLine:(NSDictionary *)data {
    [appDelegate showPresetNewTransactionController:[[FLPreset alloc] initWithJson:data]];
}

- (void)handleTriggerReadFeed:(NSDictionary *)data {
    [self readTransactionWithId:data[@"_id"] success:nil];
}

- (void)handleTrigger:(FLTrigger*)trigger {
    NSDictionary *triggerFuncs =
        @{[NSNumber numberWithInt:TriggerReloadTimeline]: NSStringFromSelector(@selector(handleTriggerTimelineReload:)),
          [NSNumber numberWithInt:TriggerShowLine]: NSStringFromSelector(@selector(handleTriggerLineShow:)),
          [NSNumber numberWithInt:TriggerShowAvatar]: NSStringFromSelector(@selector(handleTriggerAvatarShow:)),
          [NSNumber numberWithInt:TriggerReloadProfile]: NSStringFromSelector(@selector(handleTriggerProfileReload:)),
          [NSNumber numberWithInt:TriggerShowCard]: NSStringFromSelector(@selector(handleTriggerCardShow:)),
          [NSNumber numberWithInt:TriggerShowFriend]: NSStringFromSelector(@selector(handleTriggerFriendShow:)),
          [NSNumber numberWithInt:TriggerShowProfile]: NSStringFromSelector(@selector(handleTriggerProfileShow:)),
          [NSNumber numberWithInt:TriggerReloadLine]: NSStringFromSelector(@selector(handleTriggerTransactionReload:)),
          [NSNumber numberWithInt:TriggerShowLogin]: NSStringFromSelector(@selector(handleTriggerLoginShow:)),
          [NSNumber numberWithInt:TriggerShowSignup]: NSStringFromSelector(@selector(handleTriggerSignupShow:)),
          [NSNumber numberWithInt:TriggerShowSignupCode]: NSStringFromSelector(@selector(handleTriggerSignupCodeShow:)),
          [NSNumber numberWithInt:TriggerLogout]: NSStringFromSelector(@selector(handleTriggerLogout:)),
          [NSNumber numberWithInt:TriggerAppUpdate]: NSStringFromSelector(@selector(handleTriggerAppUpdate:)),
          [NSNumber numberWithInt:TriggerShowContactInfo]: NSStringFromSelector(@selector(handleTriggerContactInfoShow:)),
          [NSNumber numberWithInt:TriggerShowUserIdentity]: NSStringFromSelector(@selector(handleTriggerUserIdentityShow:)),
          [NSNumber numberWithInt:TriggerShow3DSecure]: NSStringFromSelector(@selector(handleTrigger3DSecureShow:)),
          [NSNumber numberWithInt:TriggerComplete3DSecure]: NSStringFromSelector(@selector(handleTrigger3DSecureComplete:)),
          [NSNumber numberWithInt:TriggerResetPassword]: NSStringFromSelector(@selector(handleTriggerResetPassword:)),
          [NSNumber numberWithInt:TriggerFail3DSecure]: NSStringFromSelector(@selector(handleTrigger3DSecureFail:)),
          [NSNumber numberWithInt:TriggerSecureCodeClear]: NSStringFromSelector(@selector(handleTriggerClearSecureCode:)),
          [NSNumber numberWithInt:TriggerSecureCodeCheck]: NSStringFromSelector(@selector(handleTriggerCheckSecureCode:)),
          [NSNumber numberWithInt:TriggerPresetLine]: NSStringFromSelector(@selector(handleTriggerPresetLine:)),
          [NSNumber numberWithInt:TriggerReloadFriend]: NSStringFromSelector(@selector(handleTriggerFriendReload:)),
          [NSNumber numberWithInt:TriggerFeedRead]: NSStringFromSelector(@selector(handleTriggerReadFeed:))};
    
    if (trigger && [triggerFuncs objectForKey:[NSNumber numberWithInt:trigger.type]]) {
        if ([trigger.delay isEqualToNumber:@0])
            [self performSelector:NSSelectorFromString([triggerFuncs objectForKey:[NSNumber numberWithInt:trigger.type]]) withObject:trigger.data];
        else {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, [trigger.delay doubleValue] * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self performSelector:NSSelectorFromString([triggerFuncs objectForKey:[NSNumber numberWithInt:trigger.type]]) withObject:trigger.data];
            });
        }
    }
}

- (void)handleRequestTriggers:(NSDictionary*)responseObject {
    if (responseObject && responseObject[@"triggers"]) {
        NSArray *t = responseObject[@"triggers"];
        for (NSDictionary *triggerData in t) {
            FLTrigger *trigger = [[FLTrigger alloc] initWithJson:triggerData];
            [self handleTrigger:trigger];
        }
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
    
#ifdef FLOOZ_DEV_API
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
    [dic setValue:@YES forKey:@"validate"];
    [self requestPath:@"/signup" method:@"POST" params:dic success:success failure:failure];
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
			NSString *formatedPhone = [FLHelper formatedPhone:_phone];

			if (formatedPhone) {
				[contactsPhone addObject:formatedPhone];
			}
		}
	}

	NSDictionary *params = @{
		@"emails": contactsEmail,
		@"phones": contactsPhone
	};

	[self requestPath:@"/contacts/import" method:@"POST" params:params success:NULL failure:NULL];
}

- (void)sendContactsAtSignup:(BOOL)signup WithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure {
	NSString *path = @"/contacts/flooz";
	if (signup) {
		path = [path stringByAppendingString:@"?context=signup"];
	}
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
	    [self showLoadView];
	    [self sendContactsAtSignup:signup WithParams:@{ @"phones": arrayServer } success: ^(id result) {
	        NSMutableArray *arrayFlooz = [self createFriendsArrayFromResult:result];
	        NSMutableArray *arrayAB = [self removeFloozerFromArray:arrayFlooz inArray:arrayContacts];
	        if (lists) {
	            lists(arrayAB, arrayFlooz);
			}
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
- (NSMutableArray *)createFriendsArrayFromResult:(NSDictionary *)result {
	NSMutableArray *arrayFriends = [NSMutableArray new];
	NSArray *friends = result[@"items"];
	if (friends) {
		for (NSDictionary *json in friends) {
			FLUser *friend = [[FLUser alloc] initWithJSON:json];
			NSUInteger newIndex = [self findIndexForUser:friend inArray:arrayFriends];
			[arrayFriends insertObject:friend atIndex:newIndex];
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
			FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:json];
			[arrayTransactions addObject:transaction];
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
                UIAlertView* curr1=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
                [curr1 setTag:125];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [curr1 show];
                });
            }
            else
            {
                UIAlertView* curr2=[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CONTACT_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CONTACT_CONTENT", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
