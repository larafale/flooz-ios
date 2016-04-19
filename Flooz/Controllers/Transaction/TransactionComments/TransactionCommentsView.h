//
//  TransactionCommentsView.h
//  Flooz
//
//  Created by Olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionActionsViewDelegate.h"
#import "FLTextViewComment.h"

@interface TransactionCommentsView : UIView <FLViewDelegate> {
    CGFloat height;
    CGFloat heightComments;
    FLTextViewComment *_textCommentView;
}

@property (weak, nonatomic) FLTransaction *transaction;
@property (weak, nonatomic) id <TransactionActionsViewDelegate> delegate;
@property (weak, nonatomic) UIViewController <FLViewDelegate> *delegateComment;

- (void)focusOnTextField;

@end
