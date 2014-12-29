//
//  Flooz.h
//  Flooz
//
//  Created by jonathan on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFHTTPRequestOperationManager.h>
#import <AddressBookUI/AddressBookUI.h>

#import <SIOSocket/SIOSocket.h>

#import "FLFriendRequest.h"
#import "FLUser.h"
#import "FLTransaction.h"
#import "FLComment.h"
#import "FLCreditCard.h"
#import "FLActivity.h"
#import "FLTrigger.h"
#import "FLReport.h"

static NSString *kNotificationConnectionError = @"kNotificationConnectionError";
static NSString *kNotificationRemoveWindowSubviews = @"kNotificationRemoveWindowSubviews";
static NSString *kNotificationCloseKeyboard = @"kNotificationCloseKeyboard";
static NSString *kNotificationReloadCurrentUser = @"kNotificationReloadCurrentUser";
static NSString *kNotificationRemoveFriend = @"kNotificationRemoveFriend";
static NSString *kNotificationAnswerAccessNotification = @"kNotificationAnswerAccessNotification";
static NSString *kNotificationRefreshTransaction = @"kNotificationRefreshTransaction";
static NSString *kNotificationReloadTimeline = @"kNotificationReloadTimeline";

@interface Flooz : NSObject<UIAlertViewDelegate> {
	AFHTTPRequestOperationManager *manager;
	FLLoadView *loadView;
    
	NSArray *_activitiesCached;
}

@property (strong, readonly) FLUser *currentUser;
@property (strong, nonatomic) NSString *facebook_token;

@property (strong, nonatomic) NSNumber *notificationsCount;
@property (strong, nonatomic) NSArray *notifications;
@property (strong, nonatomic) NSString *access_token;
@property (strong, nonatomic) SIOSocket *socketIO;
@property (nonatomic) Boolean socketConnected;

+ (Flooz *)sharedInstance;

- (void)showLoadView;
- (void)hideLoadView;

- (BOOL)autologin;
- (void)logout;

- (void)signupPassStep:(NSString *)step user:(NSMutableDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)signup:(NSDictionary *)user success:(void (^)(id result))block failure:(void (^)(NSError *error))failure;
- (void)askInvitationCode:(NSDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)loginWithPseudoAndPassword:(NSDictionary *)user success:(void (^)(id result))success;
- (void)loginWithCodeForUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)loginWithPhone:(NSString *)phone;
- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)passwordLost:(NSString *)email success:(void (^)(id result))success;
- (NSString *)clearPhoneNumber:(NSString*)phone;
- (void)reportContent:(FLReport *)report;
- (void)blockUser:(NSString *)userId;
- (void)checkSecureCodeForUser:(NSString*)secureCode success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (NSString *)formatBirthDate:(NSString *)birthdate;

- (void)updateCurrentUser;
- (void)updateCurrentUserWithSuccess:(void (^)())success;

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)getPublicTimelineSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success;
- (void)readTransactionWithId:(NSString *)transactionId success:(void (^)(id result))success;
- (void)readTransactionsSuccess:(void (^)(id result))success;
- (void)readFriendActivity:(void (^)(id result))success;

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)activitiesNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (NSArray *)activitiesCached;

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success noCreditCard:(void (^)())noCreditCard;
- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success;
- (void)createCreditCard:(NSDictionary *)creditCard atSignup:(BOOL)signup success:(void (^)(id result))success;
- (void)abort3DSecure;

- (void)inviteWithPhone:(NSString *)phone;
- (void)invitationStrings:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success;
- (void)friendsSuggestion:(void (^)(id result))success;
- (void)friendRemove:(NSString *)friendId success:(void (^)())success;
- (void)friendAcceptSuggestion:(NSString *)friendId success:(void (^)())success;
- (void)friendSearch:(NSString *)text forNewFlooz:(BOOL)newFlooz success:(void (^)(id result))success;

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendSMSValidation;
- (void)sendEmailValidation;

- (void)connectFacebook;
- (void)getInfoFromFacebook;
- (void)getFacebookPhoto:(void (^)(id result))success;
- (void)disconnectFacebook;
- (void)didConnectFacebook;
- (void)facebokSearchFriends:(void (^)(id result))success;

- (void)handleTrigger:(FLTrigger*)trigger;
- (void)handleRequestTriggers:(NSDictionary*)responseObject;
- (void)displayPopupMessage:(id)responseObject;

- (void)startSocket;
- (void)closeSocket;
- (void)socketSendSessionEnd;

- (void)verifyInvitationCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)checkSignup:(NSDictionary *)userDic success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyPseudo:(NSString *)pseudo success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyEmail:(NSString *)email success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendContacts;
- (void)sendContactsAtSignup:(BOOL)signup WithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)getAdressBookContactList:(void (^)(NSMutableArray *arrayContactAdressBook))adressBook;
- (void)createContactList:(void (^)(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz))lists atSignup:(BOOL)signup;

- (NSUInteger)findIndexForUser:(FLUser *)newUser inArray:(NSArray *)array;
- (NSMutableArray *)createFriendsArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createActivityArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createTransactionArrayFromResult:(NSDictionary *)result;

- (void)grantedAccessToContacts:(void (^)(BOOL granted))grant;

- (void)saveSettingsObject:(id)object withKey:(NSString *)key;

@end
