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
    
    if([_transaction comments] && [[_transaction comments] count] > 0){
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(self.frame) - 20, 1)];
        separator.backgroundColor = [UIColor customSeparator:0.5];
        [self addSubview:separator];
    }
    
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
    CGFloat MIN_HEIGHT = 50;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame), MIN_HEIGHT)];
    
    {
        CGFloat MARGE_TOP_BOTTOM = 10.;
        CGFloat MARGE_LEFT = 70;
        CGFloat WIDTH = 210;
        
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 0, WIDTH, 0)];
        UILabel *dateView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 0, WIDTH, 15)];
        
        content.font = [UIFont customContentLight:12];
        content.textColor = [UIColor whiteColor];
        content.numberOfLines = 0;
        content.text = comment.content;
        
        dateView.textColor = [UIColor customPlaceholder];
        dateView.font = [UIFont customContentLight:9];
        dateView.text = [NSString stringWithFormat:@"@%@ - %@", [[comment user] username], [comment dateText]];
        
        CGRectSetHeight(content.frame, [content heightToFit] + 3); // + 3 car quand emoicone ca passe pas
        
        
        CGFloat currentHeight = CGRectGetHeight(content.frame) + CGRectGetHeight(dateView.frame);
        
        if(currentHeight + MARGE_TOP_BOTTOM > CGRectGetHeight(view.frame)){
            
            CGRectSetY(content.frame, MARGE_TOP_BOTTOM / 2.);
            CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));
            
            CGRectSetHeight(view.frame, currentHeight + MARGE_TOP_BOTTOM);
        }
        else{
            
            CGFloat y = (MIN_HEIGHT - currentHeight) / 2.;
            
            CGRectSetY(content.frame, y);
            CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));
        }
        
        [view addSubview:content];
        [view addSubview:dateView];
    }
    
    {
        FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMake(25, 0, 34, 34)];
        [avatar setImageFromUser:comment.user];
        CGRectSetY(avatar.frame, (CGRectGetHeight(view.frame) - CGRectGetHeight(avatar.frame)) / 2);
        [view addSubview:avatar];
    }
    
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
    
    if([[_textField text] isBlank] || [[_textField text] length] > 140){
        return;
    }
    
    NSDictionary *comment = @{
                              @"lineId": [_transaction transactionId],
                              @"comment": [_textField text]
                              };
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createComment:comment success:^(id result) {
        [_textField setText:@""];
        
        FLComment *comment = [[FLComment alloc] initWithJSON:result[@"item"]];
        NSMutableArray *comments = [[_transaction comments] mutableCopy];
        [comments addObject:comment];
        _transaction.comments = comments;
        _transaction.social.commentsCount = [comments count];
        _transaction.social.isCommented = YES;
        
        [_delegate reloadTransaction];
    } failure:NULL];
}

@end
