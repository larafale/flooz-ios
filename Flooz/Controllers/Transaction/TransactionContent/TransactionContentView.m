//
//  TransactionContentView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionContentView.h"

#import "FLSocialView.h"

#define MARGE_TOP 10.
#define MARGE_BOTTOM 10.
#define MARGE_LEFT_RIGHT 25.

@implementation TransactionContentView

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 0);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews
{
    [self createTextView];
    [self createContentView];
    [self createAttachmentView];
    [self createSocialView];
}

- (void)createTextView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];

    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customContentRegular:13];
    view.numberOfLines = 0;
    
    [self addSubview:view];
}

- (void)createContentView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
    
    view.textColor = [UIColor customPlaceholder];
    view.font = [UIFont customContentLight:12];
    view.numberOfLines = 0;
    
    [self addSubview:view];
}

- (void)createAttachmentView
{
    FLImageView *view = [[FLImageView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 80)];
    [self addSubview:view];
}

- (void)createSocialView
{
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
    [view addTargetForLike:self action:@selector(didLikeButtonTouch)];
    [self addSubview:view];
}

#pragma mark -

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
    [self prepareViews];
}

#pragma mark -

- (void)prepareViews
{
    height = MARGE_TOP;

    [self prepareTextView];
    [self prepareContentView];
    [self prepareAttachmentView];
    [self prepareSocialView];

    height += MARGE_BOTTOM;

    CGRectSetHeight(self.frame, height);
}

- (void)prepareTextView
{
    UILabel *view = [[self subviews] objectAtIndex:0];
    CGRectSetY(view.frame, height);
    
//    if(![_transaction isPrivate]){
        NSMutableAttributedString *attributedContent = [NSMutableAttributedString new];
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:_transaction.text3d[0]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont customContentBold:13]
                                                               }];
            
            [attributedContent appendAttributedString:attributedText];
        }
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:_transaction.text3d[1]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: [UIColor customBlue]
                                                               }];
            
            [attributedContent appendAttributedString:attributedText];
        }
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:_transaction.text3d[2]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: [UIColor whiteColor],
                                                               NSFontAttributeName: [UIFont customContentBold:13]
                                                               }];
            
            [attributedContent appendAttributedString:attributedText];
        }
                
//        view.text = [_transaction title];
        view.attributedText = attributedContent;
        [view setHeightToFit];
        
        height = CGRectGetMaxY(view.frame);
//    }
}

- (void)prepareContentView
{
    UILabel *view = [[self subviews] objectAtIndex:1];
    CGRectSetY(view.frame, height + 5);
    
    view.text = [_transaction content];
    [view setHeightToFit];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView
{
    FLImageView *view = [[self subviews] objectAtIndex:2];
    CGRectSetY(view.frame, height + 10);
    
    if([_transaction attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_transaction attachmentThumbURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]]];
        height = CGRectGetMaxY(view.frame);
    }
}

- (void)prepareSocialView
{
    FLSocialView *view = [[self subviews] objectAtIndex:3];
    CGRectSetY(view.frame, height + 8);
    
    [view prepareView:_transaction.social];
    
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Social action

- (void)didLikeButtonTouch
{
    [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success:^(id result) {
        [[_transaction social] setLikeText:[result objectForKey:@"item"]];
        
        FLSocialView *view = [[self subviews] objectAtIndex:3];
        [view prepareView:_transaction.social];
        
        [_target performSelector:_action];
    } failure:NULL];
}

- (void)addTargetForLike:(id)target action:(SEL)action
{
    _target = target;
    _action = action;
}

@end
