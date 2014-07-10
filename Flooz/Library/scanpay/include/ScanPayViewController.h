#import <UIKit/UIKit.h>

#import "ScanPayDelegate.h"
#import "SPCreditCard.h"

/**
 This class permit you to start the ScanPay API
 */
@interface ScanPayViewController : UINavigationController

typedef void (^SucceededBlock)(SPCreditCard * creditcard);
typedef void (^CanceledBlock)();

/**
 This method init the ScanPayViewController
 @param aToken You need an API token in order to use the ScanPaySDK, you get one on https://scanpay.it
 @param shouldUseConfirmationView Put YES if you want use the ScanPay credit card information view
 @param shouldUseManualEntry Put YES if you want show the manual entry button
 @return Return the ScanPayViewController
 */
- (id)initWithToken:(NSString *)aToken useConfirmationView:(BOOL)shouldUseConfirmationView
     useManualEntry:(BOOL)shouldUseManualEntry;

/**
 This method start the SDK, a viewController with a scanner view will be presented
 @param scanSucceeded This is a block that will be called when a scan succeeded
 @param scanCanceled This is a block that will be called the scan be canceled by the user
 */
- (void)startScannerWithViewController:(UIViewController *)aCurrentViewController
              success:(SucceededBlock)scanSucceeded
                cancel:(CanceledBlock)scanCanceled;

/**
 This method allows you to change the color of the sight. Default will be [UIColor WhiteColor]
 @param sightColor The UIColor representing the desired color for the sight
 */
@property (nonatomic, strong) UIColor *sightColor;

/* Old delegate methods */

/*!
 @property delegate Delegate used for retrieve the result of scan
 */
@property (nonatomic, weak) id<ScanPayDelegate> scanDelegate;

/*!
 @method initForScanWithDelegate:
 @discussion Method that initialize directy the scan with a delegate
 @param aDelegate The delegate class
 @param appToken The token we gave you for your app
 */
- (id)initWithDelegate:(id<ScanPayDelegate>)aDelegate appToken:(NSString *)yourAppToken;

@end
