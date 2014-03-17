//
//  NewTransactionSelectTypeDelegate.h
//  Flooz
//
//  Created by jonathan on 2014-03-17.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewTransactionSelectTypeDelegate <NSObject>

- (void)didTypePaymentelected;
- (void)didTypeCollectSelected;

@end
