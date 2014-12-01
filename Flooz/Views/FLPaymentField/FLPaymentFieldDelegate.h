//
//  FLPaymentFieldDelegate.h
//  Flooz
//
//  Created by jonathan on 2/21/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLPaymentFieldDelegate <NSObject>

- (void)didWalletSelected;
- (void)didCreditCardSelected;
- (void)presentCreditCardController;

@end
