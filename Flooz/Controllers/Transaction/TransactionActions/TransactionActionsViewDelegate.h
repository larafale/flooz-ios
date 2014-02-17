//
//  TransactionActionsViewDelegate.h
//  Flooz
//
//  Created by jonathan on 2/14/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TransactionActionsViewDelegate <NSObject>

- (void)acceptTransaction;
- (void)refuseTransaction;
- (void)cancelTransaction;

@end
