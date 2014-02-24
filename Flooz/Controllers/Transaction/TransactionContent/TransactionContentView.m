//
//  TransactionContentView.m
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionContentView.h"

#import "FLSocialView.h"

#define MARGE_TOP 28.
#define MARGE_BOTTOM 10.
#define MARGE_LEFT_RIGHT 25.

@implementation TransactionContentView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectSetHeight(frame, 0);
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
    [self createDateView];
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
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 80)];
    [self addSubview:view];
}

- (void)createDateView
{
    JTImageLabel *view = [[JTImageLabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - MARGE_LEFT_RIGHT - 100, 0, 100, 15)];
    
    view.textAlignment = NSTextAlignmentRight;
    view.textColor = [UIColor whiteColor];
    view.font = [UIFont customContentLight:11];
    
    [view setImage:[UIImage imageNamed:@"transaction-content-clock"]];
    [view setImageOffset:CGPointMake(- 4, 0)];
    
    [self addSubview:view];
}

- (void)createSocialView
{
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, 0, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
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
    [self prepareDateView];
    [self prepareSocialView];

    height += MARGE_BOTTOM;

    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareTextView
{
    UILabel *view = [[self subviews] objectAtIndex:0];
    view.frame = CGRectSetY(view.frame, height);
    
    view.text = [[self transaction] title];
    [view setHeightToFit];
        
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareContentView
{
    UILabel *view = [[self subviews] objectAtIndex:1];
    view.frame = CGRectSetY(view.frame, height);
    
    view.text = [[self transaction] content];
    [view setHeightToFit];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView
{
    UIImageView *view = [[self subviews] objectAtIndex:2];
    view.frame = CGRectSetY(view.frame, height + 10);
    
    if([_transaction attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_transaction attachmentThumbURL]]];
        height = CGRectGetMaxY(view.frame);
    }
}

- (void)prepareDateView
{
    JTImageLabel *view = [[self subviews] objectAtIndex:3];
    view.frame = CGRectSetY(view.frame, height + 8);
        
    view.text = [FLHelper formatedDate:[[self transaction] date]];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareSocialView
{
    FLSocialView *view = [[self subviews] objectAtIndex:4];
    view.frame = CGRectSetY(view.frame, height + 8);
    
    [view prepareView:_transaction.social];
    
    height = CGRectGetMaxY(view.frame);
}

@end
