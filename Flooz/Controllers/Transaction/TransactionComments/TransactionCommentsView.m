//
//  TransactionCommentsView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionCommentsView.h"
#define MARGIN_LEFT_RIGHT 12.

@implementation TransactionCommentsView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 0);
    self = [super initWithFrame:frame];
    if (self) {
        [self createSendCommentView];
    }
    return self;
}

- (void)createSendCommentView
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), 45)];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame) - 20, 1)];
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 15, 0, 30)];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 0, 30)];
    
    separator.backgroundColor = [UIColor customSeparator:0.5];
    
    textField.delegate = self;
    textField.backgroundColor = [UIColor customBackground];
    textField.layer.cornerRadius = 15.;
    textField.font = [UIFont customContentLight:12];
    textField.textColor = [UIColor customPlaceholder];
    
    textField.attributedPlaceholder = [[NSAttributedString alloc]
                                          initWithString:NSLocalizedString(@"SEND_COMMENT", nil)
                                          attributes:@{
                                                       NSFontAttributeName: [UIFont customContentLight:14],
                                                       NSForegroundColorAttributeName: [UIColor customPlaceholder]
                                                       }];

    {
        UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 30)];
        textField.leftView = paddingView;
        textField.leftViewMode = UITextFieldViewModeAlways;
    }
    
    [button setTitle:NSLocalizedString(@"GLOBAL_SEND", Nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(didButtonClick) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont customTitleExtraLight:14];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
  
    [view addSubview:separator];
    [view addSubview:textField];
    [view addSubview:button];
    [self addSubview:view];
    
    _textField = textField;
    
    // Redimensionne taille du bouton en fonction du text
    
    CGFloat width = [button widthToFit] + 10;
    CGRectSetWidth(button.frame, width);
    CGRectSetX(button.frame, CGRectGetWidth(view.frame) - MARGIN_LEFT_RIGHT - width);
    CGRectSetWidth(textField.frame, button.frame.origin.x - 20);
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    height = 0;
    
    for(FLComment *comment in [_transaction comments]){
        UIView *commentView = [self createCommentView:comment];
        height = CGRectGetMaxY(commentView.frame);
        
        [self addSubview:commentView];
    }
    
    [self prepareSendCommentView];
    
    CGRectSetHeight(self.frame, height);
}

- (void)prepareSendCommentView
{
    UIView *view = [[self subviews] objectAtIndex:0];
    
    CGRectSetY(view.frame, height);
    height = CGRectGetMaxY(view.frame);
}

- (UIView *)createCommentView:(FLComment *)comment
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame), 50)];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(42, 0, 1, 0)];
    FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMake(25, 0, 34, 34)];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(70, 00, 210, 0)];
    
    separator.backgroundColor = [UIColor customSeparator];
    
    content.font = [UIFont customContentLight:12];
    content.textColor = [UIColor customPlaceholder];
    content.numberOfLines = 0;
    
    [avatar setImageFromUser:comment.user];
    
    content.text = comment.content;
    [content setHeightToFit];
    
    if(CGRectGetHeight(content.frame) > CGRectGetHeight(view.frame)){
        CGRectSetHeight(view.frame, CGRectGetHeight(content.frame));
    }
    else{
        CGRectSetHeight(content.frame, CGRectGetHeight(view.frame));
    }
    
    CGRectSetHeight(separator.frame, CGRectGetHeight(view.frame));
    CGRectSetY(avatar.frame, (CGRectGetHeight(view.frame) - CGRectGetHeight(avatar.frame)) / 2);
    
    [view addSubview:separator];
    [view addSubview:avatar];
    [view addSubview:content];
    
    return  view;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -

- (void)didButtonClick
{
    [_textField resignFirstResponder];
    
    NSDictionary *comment = @{
                              @"lineId": [_transaction transactionId],
                              @"comment": [_textField text]
                              };
    
    if([[_textField text] isBlank] || [[_textField text] length] > 140){
        return;
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createComment:comment success:^(id result) {
        [_textField setText:@""];
        
        FLComment *comment = [[FLComment alloc] initWithJSON:[result objectForKey:@"item"]];
        NSMutableArray *comments = [[_transaction comments] mutableCopy];
        [comments addObject:comment];
        _transaction.comments = comments;
        
        [_delegate reloadTransaction];
    } failure:NULL];
}

@end
