//
//  FLNewTransactionAmountDelegate.h
//  Flooz
//
//  Created by Olivier on 2/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLNewTransactionAmountDelegate <NSObject>

- (void)didAmountValidTouch;
- (void)didAmountCancelTouch;

@end
