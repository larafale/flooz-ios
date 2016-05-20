//
//  CashinCreditCardViewController.h
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "Stripe.h"
#import "CardIO.h"

@interface CashinCreditCardViewController : BaseViewController<STPPaymentCardTextFieldDelegate, CardIOViewDelegate>



@end
