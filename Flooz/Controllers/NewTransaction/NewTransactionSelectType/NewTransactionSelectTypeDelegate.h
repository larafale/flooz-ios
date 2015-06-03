//
//  NewTransactionSelectTypeDelegate.h
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NewTransactionSelectTypeDelegate <NSObject>

- (void)didTypePaymentelected;
- (void)didTypeCollectSelected;

@end
