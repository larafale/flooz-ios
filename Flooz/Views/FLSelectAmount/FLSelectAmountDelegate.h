//
//  FLSelectAmountDelegate.h
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLSelectAmountDelegate <NSObject>

- (void)didAmountFixSelected;
- (void)didAmountFreeSelected;

@end
