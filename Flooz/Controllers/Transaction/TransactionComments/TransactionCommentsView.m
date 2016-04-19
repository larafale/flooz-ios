//
//  TransactionCommentsView.m
//  Flooz
//
//  Created by Olivier on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "TransactionCommentsView.h"
#define MARGIN_LEFT_RIGHT 10.

@implementation TransactionCommentsView {
    BOOL sendPressed;
    
    UIView *_sendView;
    NSMutableDictionary *commentDic;
}

- (id)initWithFrame:(CGRect)frame {
	CGRectSetHeight(frame, 0);
	self = [super initWithFrame:frame];
	if (self) {
		[self createSendCommentView];
	}
	return self;
}

- (void)createSendCommentView {
	_sendView = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, 0., CGRectGetWidth(self.frame) - MARGIN_LEFT_RIGHT*2, 30)];
    
    commentDic = [NSMutableDictionary new];
    _textCommentView = [[FLTextViewComment alloc] initWithPlaceholder:NSLocalizedString(@"SEND_COMMENT", nil) for:commentDic key:@"comment" frame:CGRectMake(0, 5., 100, 30)];
    [_textCommentView setDelegate:self];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 5., 0, 30)];

	[button setTitle:NSLocalizedString(@"GLOBAL_SEND", Nil) forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button addTarget:self action:@selector(didButtonClick) forControlEvents:UIControlEventTouchUpInside];
	button.titleLabel.font = [UIFont customTitleExtraLight:15];
	button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.tag = 12;
    
    [_sendView addSubview:_textCommentView];
	[_sendView addSubview:button];
	[self addSubview:_sendView];

    sendPressed = NO;

	// Redimensionne taille du bouton en fonction du text

	CGFloat width = [button widthToFit] + 10;
	CGRectSetWidth(button.frame, width);
	CGRectSetX(button.frame, CGRectGetWidth(_sendView.frame) - width);
    [_textCommentView setWidth:button.frame.origin.x - 10];
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction {
	self->_transaction = transaction;
	[self prepareViews];
}

#pragma mark -

- (void)prepareViews {
	height = 10;
    
    for (UIView *view in [self subviews]) {
        if (![view isEqual:_sendView]) {
            [view removeFromSuperview];
        }
    }
    
	for (FLComment *comment in[_transaction comments]) {
		UIView *commentView = [self createCommentView:comment];
		height = CGRectGetMaxY(commentView.frame);

		[self addSubview:commentView];
	}
    heightComments = height;
    [self prepareSendCommentView];
    
	CGRectSetHeight(self.frame, height);
}

- (void)prepareSendCommentView {
	CGRectSetY(_sendView.frame, height);
	height = CGRectGetMaxY(_sendView.frame) + 10.0f;
}

- (void)commentUserSelected:(UITapGestureRecognizer*)sender {
    FLUserView *tmp = (FLUserView *)sender.view;
    [appDelegate showUser:tmp.user inController:nil];
}

- (UIView *)createCommentView:(FLComment *)comment {
	CGFloat MIN_HEIGHT = 44;
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_LEFT_RIGHT, height, CGRectGetWidth(self.frame) - MARGIN_LEFT_RIGHT * 2., MIN_HEIGHT)];
    
    {
        FLUserView *avatar = [[FLUserView alloc] initWithFrame:CGRectMake(0, 0, 34, 34)];
        [avatar setImageFromUser:comment.user];
        [avatar setUserInteractionEnabled:true];
        CGRectSetY(avatar.frame, (CGRectGetHeight(view.frame) - CGRectGetHeight(avatar.frame)) / 2);
        
        [view addSubview:avatar];
        
        [avatar addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(commentUserSelected:)]];
    }
    
	{
		CGFloat MARGE_TOP_BOTTOM = 10.;
		CGFloat MARGE_LEFT = 34 + 10.;
		CGFloat WIDTH = CGRectGetWidth(view.frame) - MARGE_LEFT;

		UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 0, WIDTH, 0)];
		UILabel *dateView = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 0, WIDTH, 15)];

		content.font = [UIFont customContentLight:13];
		content.textColor = [UIColor whiteColor];
		content.numberOfLines = 0;
		content.text = comment.content;

		dateView.textColor = [UIColor customPlaceholder];
		dateView.font = [UIFont customContentLight:10];
		dateView.text = [NSString stringWithFormat:@"@%@ - %@", [[comment user] username], [FLHelper momentWithDate:[comment date]]];

		CGRectSetHeight(content.frame, [content heightToFit] + 3); // + 3 car quand emoticone ca passe pas


		CGFloat currentHeight = CGRectGetHeight(content.frame) + CGRectGetHeight(dateView.frame);

		if (currentHeight + MARGE_TOP_BOTTOM > CGRectGetHeight(view.frame)) {
			CGRectSetY(content.frame, MARGE_TOP_BOTTOM / 2.);
			CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));

			CGRectSetHeight(view.frame, currentHeight + MARGE_TOP_BOTTOM);
		}
		else {
			CGFloat y = (MIN_HEIGHT - currentHeight) / 2.;

			CGRectSetY(content.frame, y);
			CGRectSetY(dateView.frame, CGRectGetMaxY(content.frame));
		}

		[view addSubview:content];
		[view addSubview:dateView];
	}

	return view;
}

- (void)focusOnTextField {
    [_textCommentView becomeFirstResponder];
}

#pragma mark -

- (void)didButtonClick {
    [_textCommentView resignFirstResponder];

	if (!commentDic[@"comment"] || [commentDic[@"comment"] isBlank] || [commentDic[@"comment"] length] > 3000 || sendPressed) {
		return;
	}
	sendPressed = YES;

	NSDictionary *comment = @{
		@"floozId": [_transaction transactionId],
		@"comment": commentDic[@"comment"]
	};
    [commentDic setObject:@"" forKey:@"comment"];
    [_textCommentView reload];

	[[Flooz sharedInstance] showLoadView];
	[[Flooz sharedInstance] createComment:comment success: ^(id result) {
        [_transaction setJSON:result[@"item"]];

	    sendPressed = NO;
	    [_delegate reloadTransaction];
    } failure:^(NSError *error) {
        sendPressed = NO;
    }];
}

- (void)didChangeHeight:(CGFloat)h {
    [_sendView setHeight:h];
    
    CGRectSetHeight(self.frame, heightComments+h);
    
    UIButton *sendBtn = (UIButton*)[_sendView viewWithTag:12];
    CGRectSetY(sendBtn.frame, _textCommentView.frame.origin.y + _textCommentView.frame.size.height - sendBtn.frame.size.height);
    
    if (_delegateComment) {
        [_delegateComment didChangeHeight:heightComments+h];
    }
}

@end
