//
//  CreditCardViewController.h
//  Flooz
//
//  Created by Arnaud Lays on 10/03/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Stripe.h"
#import "CardIO.h"

@interface CreditCardViewController : BaseViewController<STPPaymentCardTextFieldDelegate, CardIOViewDelegate>

@property (nonatomic, retain) NSString *customLabel;
@property (nonatomic, retain) NSDictionary *floozData;

@end
