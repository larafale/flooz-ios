//
//  TransactionActionsViewDelegate.h
//  Flooz
//
//  Created by olivier on 2/14/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransactionActionsViewDelegate <NSObject>

- (void)reloadTransaction;

- (void)acceptTransaction;
- (void)refuseTransaction;

- (void)showPaymentField;
- (void)hidePaymentField;

@end
