//
//  TransactionContentView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionContentView : UIView{
    CGFloat height;
}

@property (weak, nonatomic) FLTransaction *transaction;

@end
