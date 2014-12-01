//
//  SPCreditCard.h
//  ScanPaySDK
//
//  Copyright (c) 2013 Scanpay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum eSPCardType {
    VISA,
    MASTERCARD,
    AMERICAN_EXPRESS,
    UNKNOWN_CARD
} SPCardType;

@interface SPCreditCard : NSObject

/*!
 @property type The type of the credit card such as Visa, MasterCard or Amex
 */
@property (nonatomic) SPCardType type;

/*!
 @property number A string representing the credit card numbers
 */
@property (nonatomic, strong) NSString * number;

/*!
 @property date The expiration date month
 */
@property (nonatomic, strong) NSString * month;

/*!
 @property date The expiration date year
 */
@property (nonatomic, strong) NSString * year;

/*!
 @property pictogram The set of numbers on the back of the card
 */

@property (nonatomic, strong) NSString * cvc;

/*!
 @method initWithNumber:
 @discussion This method inits a credit card with the numbers specified in parameters
 @param number A string containing the card number
 @result Returns the SPCreditCard object. You're responsible for releasing it
 */
- (id)initWithNumber:(NSString *)number;

/*!
 @method getHiddenNumbersString
 @discussion This method returns a string representing the secure card numbers. Only 4 digits are shown at the end of the representation
 @result Returns a string representing the secure card number
 */
- (NSString *)getHiddenNumbersString;

/*!
 @method hasValidNumbers
 @discussion This method is checking the card validity by checking its numbers
 @result Returns a BOOL value representing the card validity
 */
- (BOOL)hasValidNumbers;

/*!
 @method prepareCardNumberForDisplay:
 @discussion This method format an SPCreditCard on displayed text
 @param aCreditCard A creditcard that you need format
 @result Return bankcard number format
 */
- (NSString *)prepareCardNumberForDisplay;

@end
