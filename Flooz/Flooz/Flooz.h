//
//  Flooz.h
//  Flooz
//
//  Created by olivier on 12/30/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AFURLSessionManager.h>
#import <AFHTTPSessionManager.h>
#import <AddressBookUI/AddressBookUI.h>

#import "SIOSocket.h"

#import "FLFriendRequest.h"
#import "FLUser.h"
#import "FLTransaction.h"
#import "FLComment.h"
#import "FLCreditCard.h"
#import "FLActivity.h"
#import "FLTrigger.h"
#import "FLReport.h"
#import "FLTexts.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

static NSString *kNotificationFbConnect = @"kNotificationFbConnect";
static NSString *kNotificationConnectionError = @"kNotificationConnectionError";
static NSString *kNotificationRemoveWindowSubviews = @"kNotificationRemoveWindowSubviews";
static NSString *kNotificationCloseKeyboard = @"kNotificationCloseKeyboard";
static NSString *kNotificationReloadCurrentUser = @"kNotificationReloadCurrentUser";
static NSString *kNotificationRemoveFriend = @"kNotificationRemoveFriend";
static NSString *kNotificationAnswerAccessNotification = @"kNotificationAnswerAccessNotification";
static NSString *kNotificationRefreshTransaction = @"kNotificationRefreshTransaction";
static NSString *kNotificationReloadTimeline = @"kNotificationReloadTimeline";

static NSString *kSendContact = @"contactSended";

static NSString *kFilterData = @"filterData";
static NSString *kUserData = @"userData";
static NSString *kAllTimelineData = @"allTimelineData";
static NSString *kFriendTimelineData = @"friendTimelineData";
static NSString *kPrivateTimelineData = @"privateTimelineData";
static NSString *kTextData = @"textData";
static NSString *kInvitationData = @"invitationData";
static NSString *kNotificationsData = @"notifData";
static NSString *kBranchData = @"branchData";
static NSString *kLocationData = @"locationData";

@interface Flooz : NSObject<UIAlertViewDelegate> {
	AFHTTPSessionManager *manager;
	FLLoadView *loadView;
    
	NSArray *_activitiesCached;
}

@property (nonatomic, retain) FBSDKLoginManager *fbLoginManager;
@property (strong, nonatomic) FLInvitationTexts *invitationTexts;
@property (strong, nonatomic) FLTexts *currentTexts;
@property (strong, readonly) FLUser *currentUser;
@property (strong, nonatomic) NSString *facebook_token;
@property (strong, nonatomic) NSString *access_token;

@property (strong, nonatomic) NSNumber *notificationsCount;
@property (strong, nonatomic) NSArray *notifications;
@property (strong, nonatomic) SIOSocket *socketIO;
@property (nonatomic) Boolean socketConnected;
@property (nonatomic) NSUInteger timelinePageSize;

+ (Flooz *)sharedInstance;

- (BOOL)isConnectionAvailable;
- (void)showLoadView;
- (void)hideLoadView;
- (void) clearLocationData;

- (BOOL)autologin;
- (void)logout;
- (void)loginWithToken:(NSString *)token;

- (void)signupPassStep:(NSString *)step user:(NSMutableDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)signup:(NSDictionary *)user success:(void (^)(id result))block failure:(void (^)(NSError *error))failure;
- (void)askInvitationCode:(NSDictionary*)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)loginWithPseudoAndPassword:(NSDictionary *)user success:(void (^)(id result))success;
- (void)loginForSecureCode:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)passwordLost:(NSString *)email success:(void (^)(id result))success;
- (NSString *)clearPhoneNumber:(NSString*)phone;
- (void)reportContent:(FLReport *)report;
- (void)blockUser:(NSString *)userId;
- (void)checkSecureCodeForUser:(NSString*)secureCode success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)checkPhoneForUser:(NSString*)code success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (NSString *)formatBirthDate:(NSString *)birthdate;
- (void)cashoutValidate:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)sendDiscountCode:(NSDictionary *)code success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)loadCactusData:(NSString*)identifier success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updateCurrentUser;
- (void)updateCurrentUserWithSuccess:(void (^)())success;
- (void)updateCurrentUserAndAskResetCode:(id)result;

- (void)updateUser:(NSDictionary *)user success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)updatePassword:(NSDictionary *)password success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)uploadDocument:(NSData *)data field:(NSString *)field success:(void (^)())success failure:(void (^)(NSError *error))failure;

- (void)userTimeline:(NSString *)userId success:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure;
- (void)getPublicTimelineSuccess:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure;
- (void)timeline:(NSString *)scope state:(NSString *)state success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success failure:(void (^)(NSError *error))failure;
- (void)timelineNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl, TransactionScope scope))success;
- (void)transactionWithId:(NSString *)transactionId success:(void (^)(id result))success;
- (void)readTransactionWithId:(NSString *)transactionId success:(void (^)(id result))success;
- (void)readTransactionsSuccess:(void (^)(id result))success;
- (void)readFriendActivity:(void (^)(id result))success;
- (void)passwordForget:(NSString*)phone success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)activitiesWithSuccess:(void (^)(id result, NSString *nextPageUrl))success failure:(void (^)(NSError *error))failure;
- (void)activitiesNextPage:(NSString *)nextPageUrl success:(void (^)(id result, NSString *nextPageUrl))success;
- (NSArray *)activitiesCached;

- (void)placesFrom:(NSString *)ll success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)placesSearch:(NSString *)search from:(NSString *)ll success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)createTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success;
- (void)uploadTransactionPic:(NSString *)transId image:(NSData*)image success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)sendSignupSMS:(NSString *)phone;
- (void)confirmTransactionSMS:(NSString *)floozId validate:(Boolean)validate success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateTransactionValidate:(NSDictionary *)transaction success:(void (^)(id result))success;
- (void)updateTransaction:(NSDictionary *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)createComment:(NSDictionary *)comment success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)cashout:(NSNumber *)amount success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)cashoutValidate:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)updateNotification:(NSDictionary *)notification success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)removeCreditCard:(NSString *)creditCardId success:(void (^)(id result))success;
- (void)createCreditCard:(NSDictionary *)creditCard atSignup:(BOOL)signup success:(void (^)(id result))success;
- (void)abort3DSecure;
- (void)getUserProfile:(NSString *)userId success:(void (^)(FLUser *result))success failure:(void (^)(NSError *error))failure;

- (void)invitationFacebook:(NSString *)text success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)invitationText:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)textObjectFromApi:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)inviteWithPhone:(NSString *)phone;
- (void)invitationStrings:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)sendInvitationMetric:(NSString *)canal;
- (void)sendInvitationMetric:(NSString *)canal withTotal:(NSInteger)total;

- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success;
- (void)updateFriendRequest:(NSDictionary *)dictionary success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)friendsSuggestion:(void (^)(id result))success;
- (void)friendRemove:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)friendSearch:(NSString *)text forNewFlooz:(BOOL)newFlooz withPhones:(NSArray*)phones success:(void (^)(id result, NSString *searchString))success;
- (void)friendFollow:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)friendUnfollow:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)friendAdd:(NSString *)friendId success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)friendsRequest:(void (^)(id result))success;
//- (void)friendAcceptSuggestion:(NSString *)friendId canal:(NSString*)canal success:(void (^)())success;
//- (void)friendAcceptSuggestion:(NSString *)friendId canal:(NSString*)canal success:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)checkContactList:(NSArray *)phones success:(void (^)(NSArray *result))success;

- (void)createLikeOnTransaction:(FLTransaction *)transaction success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendSMSValidation;
- (void)sendEmailValidation;

- (void)connectFacebook;
- (void)disconnectFacebook;
- (void)didConnectFacebook;

- (void)handleTrigger:(FLTrigger*)trigger;
- (void)handleRequestTriggers:(NSDictionary*)responseObject;
- (void)displayPopupMessage:(id)responseObject;

- (void)startSocket;
- (void)closeSocket;
- (void)socketSendSessionEnd;

- (void)checkSignup:(NSDictionary *)userDic success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyPseudo:(NSString *)pseudo success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)verifyEmail:(NSString *)email success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;

- (void)sendContacts;
- (void)sendContactsAtSignup:(BOOL)signup WithParams:(NSDictionary *)params success:(void (^)(id result))success failure:(void (^)(NSError *error))failure;
- (void)getAdressBookContactList:(void (^)(NSMutableArray *arrayContactAdressBook))adressBook;
- (void)createContactList:(void (^)(NSMutableArray *arrayContactAdressBook, NSMutableArray *arrayContactFlooz))lists atSignup:(BOOL)signup;

- (NSUInteger)findIndexForUser:(FLUser *)newUser inArray:(NSArray *)array;
- (NSMutableArray *)createFriendsArrayFromResult:(NSDictionary *)result sorted:(BOOL)sorted;
- (NSMutableArray *)createActivityArrayFromResult:(NSDictionary *)result;
- (NSMutableArray *)createTransactionArrayFromResult:(NSDictionary *)result;

- (void)grantedAccessToContacts:(void (^)(BOOL granted))grant;

- (void)saveSettingsObject:(id)object withKey:(NSString *)key;

@end
