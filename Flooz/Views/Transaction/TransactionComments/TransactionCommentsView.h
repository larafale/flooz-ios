//
//  TransactionCommentsView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionCommentsView : UIView<UITextFieldDelegate>{
    CGFloat height;
    __weak UITextField *_textField;
}

@property (strong, nonatomic) FLTransaction *transaction;

@end
