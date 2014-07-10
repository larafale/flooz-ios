//
//  ScanPayDelegate.h
//  ScanPaySDK
//
//  Copyright (c) 2013 Scanpay. All rights reserved.
//
#ifndef ScanPaySDK_ScanPayDelegate_h
#define ScanPaySDK_ScanPayDelegate_h

@class ScanPayViewController;
@class SPCreditCard;

/*!
 @class SPScanDelegate
 @discussion This delegate is used for retrieving the scan result
 */
@protocol ScanPayDelegate <NSObject>

@required

/*!
 @method scanViewController:didScanCard:
 @discussion This method is called when the scan have successfully retrieve all the informations of the credit card
 @param scanViewController A pointer to the object that managed the action
 @param card The credit card informations
 */
- (void)scanPayViewController:(ScanPayViewController *)scanPayViewController didScanCard:(SPCreditCard *)card;

/*!
 @method scanCancelledByUser:
 @discussion This method is called when the user cancel scanpay
 @param paymentViewController A pointer to the object that managed the action
 */
- (void)scanCancelledByUser:(ScanPayViewController *)scanPayViewController;

/*!
 @method scanViewController:failedToScan:
 @discussion This method is called whenever an error occurred during the scan
 @param scanViewController A pointer to the object that managed the action
 @param error The error description of scan
 */
- (void)scanPayViewController:(ScanPayViewController *)scanPayViewController failedToScanWithError:(NSError *)error;

@optional

/*!
 @method scanPayViewControllerShouldShowConfirmationView:
 @discussion This method should be implemented if you want to skip the recognition view
 @return display or not the confirmation view
 @param scanViewController A pointer to the object that managed the action
 */
- (BOOL)scanPayViewControllerShouldShowConfirmationView:(ScanPayViewController *)scanPayViewController;

/*!
 @method scanPayViewControllerShouldHideManualEntryButton:
 @discussion This method should be implemented if you want to hide the manual entry button
 @return display or not the manual entry button
 @param scanViewController A pointer to the object that managed the action
 */
- (BOOL)scanPayViewControllerShouldShowManualEntryButton:(ScanPayViewController *)scanPayViewController;

@end

#endif