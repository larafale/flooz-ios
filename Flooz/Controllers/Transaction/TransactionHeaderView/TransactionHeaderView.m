//
//  TransactionHeaderView.m
//  Flooz
//
//  Created by Olive on 3/31/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "TransactionHeaderView.h"
#import "TransactionUsersView.h"

@interface TransactionHeaderView () {
    FLTransaction *_transaction;
    id<TransactionHeaderViewDelegate> _delegate;
    UIViewController *_parentController;
    
    UIView *headerView;
    UIView *contentView;
    
    TransactionUsersView *usersView;
    
    UILabel *floozerLabel;
    UILabel *descriptionLabel;
    UILabel *locationLabel;

    FLImageView *attachmentView;
}

@end

@implementation TransactionHeaderView

- (id)initWithTransaction:(FLTransaction *)transaction parentController:(UIViewController<TransactionHeaderViewDelegate>*)controller {
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
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    headerView.backgroundColor = [UIColor customBackgroundHeader];
    headerView.layer.shadowOpacity = .3;
    headerView.layer.shadowOffset = CGSizeMake(0, 2);
    headerView.layer.shadowRadius = 1;
    headerView.clipsToBounds = NO;
    
    usersView = [[TransactionUsersView alloc] initWithFrame:CGRectMake(0.0f, 10.0f, PPScreenWidth(), 0)];
    usersView.parentViewController = _parentController;
    [headerView addSubview:usersView];

    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), PPScreenWidth(), 0)];
    contentView.backgroundColor = [UIColor customBackground];
    
    attachmentView = [[FLImageView alloc] initWithFrame:CGRectMake(0.0f, 0, PPScreenWidth(), 80)];
    
    floozerLabel = [UILabel newWithFrame:CGRectMake(10, CGRectGetMaxY(attachmentView.frame) + 10, PPScreenWidth() - 20, 0)];
    floozerLabel.textColor = [UIColor whiteColor];
    floozerLabel.font = [UIFont customContentRegular:14];
    floozerLabel.numberOfLines = 0;

    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(locationLabel.frame) + 10, PPScreenWidth() - 20, 0)];
    descriptionLabel.font = [UIFont customContentRegular:15];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    locationLabel = [UILabel newWithFrame:CGRectMake(7.0f, CGRectGetMaxY(floozerLabel.frame), PPScreenWidth() - 20, 15.0f)];
    locationLabel.textColor = [UIColor customPlaceholder];
    locationLabel.numberOfLines = 1;
    locationLabel.font = [UIFont customContentRegular:12];
    
    [contentView addSubview:attachmentView];
    [contentView addSubview:floozerLabel];
    [contentView addSubview:descriptionLabel];
    [contentView addSubview:locationLabel];

    [self addSubview:contentView];
    [self addSubview:headerView];
    
    CGRectSetHeight(contentView.frame, CGRectGetMaxY(locationLabel.frame) + 20);
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (CGFloat)headerSize {
    return CGRectGetHeight(headerView.frame);
}

- (void)reloadView {
    if (![_transaction isParticipation]) {
        headerView.hidden = NO;
        usersView.transaction = _transaction;
        CGRectSetHeight(headerView.frame, CGRectGetMaxY(usersView.frame) + 10);
    } else {
        headerView.hidden = YES;
        CGRectSetHeight(headerView.frame, 0);
    }

    CGRectSetY(contentView.frame, CGRectGetMaxY(headerView.frame));
    
    if ([_transaction attachmentURL]) {
        CGFloat widthAttach = CGRectGetWidth(attachmentView.frame);
        CGFloat heightAttach = 250 / (500 / widthAttach);
        CGRectSetHeight(attachmentView.frame, heightAttach);
        
        [attachmentView setImageWithURL:[NSURL URLWithString:[_transaction attachmentURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]]];
    }
    else {
        CGRectSetHeight(attachmentView.frame, 0);
    }

    CGRectSetY(floozerLabel.frame, CGRectGetMaxY(attachmentView.frame) + 20);

    NSMutableAttributedString *attributedContent = [NSMutableAttributedString new];
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_transaction.text3d[0] attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont customContentBold:15] }];
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_transaction.text3d[1] attributes:@{ NSForegroundColorAttributeName: [UIColor customPlaceholder],  NSFontAttributeName: [UIFont customContentLight:15] }];
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:_transaction.text3d[2] attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont customContentBold:15] }];
        [attributedContent appendAttributedString:attributedText];
    }
    
    floozerLabel.attributedText = attributedContent;
    
    [floozerLabel setHeightToFit];
    
    if (_transaction.location) {
        [locationLabel setHidden:NO];
        CGRectSetHeight(locationLabel.frame, 15.0f);
        
        NSMutableAttributedString *attributedData = [NSMutableAttributedString new];
        
        UIImage *cbImage = [UIImage imageNamed:@"map"];
        CGSize newImgSize = CGSizeMake(13, 13);
        
        cbImage = [FLHelper imageWithImage:cbImage scaledToSize:newImgSize];
        cbImage = [FLHelper colorImage:cbImage color:[UIColor customPlaceholder]];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = cbImage;
        attachment.bounds = CGRectMake(0, -2, attachment.image.size.width, attachment.image.size.height);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        [attributedData appendAttributedString:attachmentString];
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:[NSString stringWithFormat:@" %@", _transaction.location]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                               NSFontAttributeName: [UIFont customContentRegular:12]
                                                               }];
            
            [attributedData appendAttributedString:attributedText];
        }
        
        locationLabel.attributedText = attributedData;
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(floozerLabel.frame) + 5);
        CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(locationLabel.frame) + 5);
    } else {
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(floozerLabel.frame) + 5.0f);
        [locationLabel setHidden:YES];
        CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(floozerLabel.frame) + 5);
    }
    
    descriptionLabel.text = _transaction.content;
    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit] + 4);
    
    CGRectSetHeight(contentView.frame, CGRectGetMaxY(descriptionLabel.frame));
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (void)setTransaction:(FLTransaction *)transaction {
    _transaction = transaction;
    [self reloadView];
}

@end
