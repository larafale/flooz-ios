//
//  CollectHeaderView.m
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CollectHeaderView.h"

@interface CollectHeaderView () {
    FLTransaction *_transaction;
    id<CollectHeaderViewDelegate> _delegate;
    UIViewController *_parentController;
    
    UIView *blankView;
    UIView *contentView;
    
    UILabel *nameLabel;
    TTTAttributedLabel *descriptionLabel;
    UILabel *amountLabel;
}

@end

@implementation CollectHeaderView

- (id)initWithCollect:(FLTransaction *)transaction parentController:(UIViewController<CollectHeaderViewDelegate>*)controller {
    self = [super initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 150)];
    if (self) {
        _transaction = transaction;
        _delegate = controller;
        _parentController = controller;
        [self createViews];
        [self reloadView];
    }
    return self;
}

- (void)createViews {
    blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(blankView.frame), PPScreenWidth(), 0)];
    contentView.backgroundColor = [UIColor customBackground];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, PPScreenWidth() - 20, 0)];
    nameLabel.textColor = [UIColor customBlue];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.font = [UIFont customTitleExtraLight:30];
    
    descriptionLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLabel.frame) + 10.0f, PPScreenWidth() - 20, 0)];
    descriptionLabel.font = [UIFont customContentRegular:17];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;

    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(descriptionLabel.frame) + 10.0f, PPScreenWidth() - 20, 30)];
    amountLabel.font = [UIFont customContentBold:25];
    amountLabel.textColor = [UIColor customBlue];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.numberOfLines = 1;
    
    [contentView addSubview:nameLabel];
    [contentView addSubview:descriptionLabel];
    [contentView addSubview:amountLabel];
    
    [self addSubview:blankView];
    [self addSubview:contentView];
    
    CGRectSetHeight(contentView.frame, CGRectGetMaxY(amountLabel.frame) + 10);
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (void)reloadView {
    
    if (_transaction.attachmentURL == nil || [_transaction.attachmentURL isBlank])
        CGRectSetHeight(blankView.frame, 50);
    else
        CGRectSetHeight(blankView.frame, 150);
    
    nameLabel.text = _transaction.name;
    
    CGRectSetHeight(nameLabel.frame, [nameLabel heightToFit]);

    CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(nameLabel.frame) + 10.0f);
    
    descriptionLabel.text = _transaction.content;

    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit]);
    
    CGRectSetY(amountLabel.frame, CGRectGetMaxY(descriptionLabel.frame) + 10.0f);

    amountLabel.text = _transaction.amountText;
    
    CGRectSetY(contentView.frame, CGRectGetMaxY(blankView.frame));
    
    CGRectSetHeight(contentView.frame, CGRectGetMaxY(amountLabel.frame) + 10);
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (void)setTransaction:(FLTransaction *)transaction {
    _transaction = transaction;
    [self reloadView];
}


@end
