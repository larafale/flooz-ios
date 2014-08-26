//
//  TransactionCommentsView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"

@interface TransactionCommentsView : UIView<UITextFieldDelegate>{
    CGFloat height;
    __weak UITextField *_textField;
}

@property (weak, nonatomic) FLTransaction *transaction;
@property (weak, nonatomic) id<TransactionActionsViewDelegate> delegate;

- (void)focusOnTextField;

@end
