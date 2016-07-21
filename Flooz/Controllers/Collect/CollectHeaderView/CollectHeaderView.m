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
    
    UIView *headerView;
    UIView *contentView;
    
    UILabel *nameLabel;
    UILabel *descriptionTitleLabel;
    UILabel *descriptionLabel;
    UILabel *amountLabel;
    UILabel *amountSymbolLabel;
    UILabel *collectedLabel;
    FLImageView *attachmentView;
    UIView *addAttachmentView;
    UILabel *locationLabel;
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
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    headerView.backgroundColor = [UIColor customBackgroundHeader];
    headerView.layer.shadowOpacity = .3;
    headerView.layer.shadowOffset = CGSizeMake(0, 2);
    headerView.layer.shadowRadius = 1;
    headerView.clipsToBounds = NO;
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, PPScreenWidth() - 20, 0)];
    nameLabel.textColor = [UIColor customWhite];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.numberOfLines = 0;
    nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
    nameLabel.font = [UIFont customContentRegular:25];
    
    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(nameLabel.frame) + 15.0f, PPScreenWidth() - 20, 25)];
    amountLabel.font = [UIFont customContentBold:25];
    amountLabel.textColor = [UIColor customBlue];
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.numberOfLines = 1;
    
    amountSymbolLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"GLOBAL_EURO", nil) textColor:[UIColor customBlue] font:[UIFont customContentBold:15] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    collectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 13)];
    collectedLabel.numberOfLines = 1;
    collectedLabel.font = [UIFont customContentRegular:13];
    collectedLabel.textColor = [UIColor customBlue];
    collectedLabel.textAlignment = NSTextAlignmentCenter;
    collectedLabel.text = @"collecté(s)";
    
    [headerView addSubview:nameLabel];
    [headerView addSubview:amountLabel];
    [headerView addSubview:amountSymbolLabel];
    [headerView addSubview:collectedLabel];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headerView.frame), PPScreenWidth(), 0)];
    contentView.backgroundColor = [UIColor customBackground];
    
    attachmentView = [[FLImageView alloc] initWithFrame:CGRectMake(0.0f, 0, PPScreenWidth(), 80)];
    
    addAttachmentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, PPScreenWidth(), 100)];
    [addAttachmentView setBackgroundColor:[UIColor customBackground]];
    [addAttachmentView addTapGestureWithTarget:self action:@selector(didAddAttachmentClick)];
    addAttachmentView.layer.masksToBounds = YES;
    
    UIImageView *addBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(addAttachmentView.frame), CGRectGetHeight(addAttachmentView.frame))];
    addBack.contentMode = UIViewContentModeScaleAspectFill;
    [addBack setImage:[UIImage imageNamed:@"attachment-background"]];
    addBack.layer.masksToBounds = YES;
    
    [addAttachmentView addSubview:addBack];
    
    UILabel *addLabel = [[UILabel alloc] initWithText:@"Ajouter une image" textColor:[UIColor customBlue] font:[UIFont customContentBold:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    CGRectSetWidthHeight(addLabel.frame, [addLabel widthToFit] + 40, [addLabel heightToFit] + 30);
    CGRectSetXY(addLabel.frame, CGRectGetWidth(addAttachmentView.frame) / 2 - CGRectGetWidth(addLabel.frame) / 2, CGRectGetHeight(addAttachmentView.frame) / 2 - CGRectGetHeight(addLabel.frame) / 2);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGSize frameSize = addLabel.frame.size;
    
    CGRect shapeRect = CGRectMake(0.0f, 0.0f, frameSize.width, frameSize.height);
    [shapeLayer setBounds:shapeRect];
    [shapeLayer setPosition:CGPointMake( frameSize.width/2,frameSize.height/2)];
    
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    [shapeLayer setStrokeColor:[UIColor customBlue].CGColor];
    [shapeLayer setLineWidth:2.0f];
    [shapeLayer setLineJoin:kCALineJoinMiter];
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:10],
      [NSNumber numberWithInt:5],
      nil]];
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:shapeRect cornerRadius:3.0];
    [shapeLayer setPath:path.CGPath];
    
    [addLabel.layer addSublayer:shapeLayer];
    
    [addAttachmentView addSubview:addLabel];
    
    descriptionTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(attachmentView.frame) + 10, PPScreenWidth() - 20, 13)];
    descriptionTitleLabel.font = [UIFont customContentBold:11];
    descriptionTitleLabel.textColor = [UIColor customPlaceholder];
    descriptionTitleLabel.textAlignment = NSTextAlignmentLeft;
    descriptionTitleLabel.numberOfLines = 1;
    descriptionTitleLabel.text = [@"Description :" uppercaseString];
    
    descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(descriptionTitleLabel.frame), PPScreenWidth() - 20, 0)];
    descriptionLabel.font = [UIFont customContentRegular:15];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    descriptionLabel.numberOfLines = 0;
    descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    locationLabel = [UILabel newWithFrame:CGRectMake(7.0f, CGRectGetMaxY(descriptionLabel.frame), PPScreenWidth() - 20, 15.0f)];
    locationLabel.textColor = [UIColor customPlaceholder];
    locationLabel.numberOfLines = 1;
    locationLabel.textAlignment = NSTextAlignmentLeft;
    locationLabel.font = [UIFont customContentRegular:12];
    
    [contentView addSubview:attachmentView];
    [contentView addSubview:addAttachmentView];
    [contentView addSubview:descriptionTitleLabel];
    [contentView addSubview:descriptionLabel];
    [contentView addSubview:locationLabel];
    
    [self addSubview:contentView];
    [self addSubview:headerView];
    
    CGRectSetHeight(contentView.frame, CGRectGetMaxY(descriptionLabel.frame) + 20);
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (CGFloat)headerSize {
    return CGRectGetHeight(headerView.frame);
}

- (void)reloadView {
    
    nameLabel.text = _transaction.name;
    
    CGRectSetHeight(nameLabel.frame, [nameLabel heightToFit]);
    
    amountLabel.text = [FLHelper formatedAmount:_transaction.amount withCurrency:NO withSymbol:NO];
    [amountLabel setWidthToFit];
    
    CGRectSetXY(amountLabel.frame, CGRectGetWidth(headerView.frame) / 2 - CGRectGetWidth(amountLabel.frame) / 2, CGRectGetMaxY(nameLabel.frame) + 10);
    CGRectSetXY(amountSymbolLabel.frame, CGRectGetMaxX(amountLabel.frame) + 3, CGRectGetMaxY(nameLabel.frame) + 10);
    
    CGRectSetY(collectedLabel.frame, CGRectGetMaxY(amountLabel.frame));
    
    CGRectSetHeight(headerView.frame, CGRectGetMaxY(collectedLabel.frame) + 10);
    
    CGRectSetY(contentView.frame, CGRectGetMaxY(headerView.frame));
    
    if ([_transaction attachmentURL]) {
        [addAttachmentView setHidden:YES];
        CGFloat widthAttach = CGRectGetWidth(attachmentView.frame);
        CGFloat heightAttach = 250 / (500 / widthAttach);
        CGRectSetHeight(attachmentView.frame, heightAttach);
        
        [attachmentView setImageWithURL:[NSURL URLWithString:[_transaction attachmentURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]]];
        
        CGRectSetY(descriptionTitleLabel.frame, CGRectGetMaxY(attachmentView.frame) + 15);
    } else if ([_transaction.creator.userId isEqualToString:[Flooz sharedInstance].currentUser.userId] && _transaction.triggerImage) {
        CGRectSetHeight(attachmentView.frame, 0);
        
        [addAttachmentView setHidden:NO];
        
        CGRectSetY(descriptionTitleLabel.frame, CGRectGetMaxY(addAttachmentView.frame) + 15);
    } else {
        [addAttachmentView setHidden:YES];
        
        CGRectSetHeight(attachmentView.frame, 0);
        CGRectSetY(descriptionTitleLabel.frame, CGRectGetMaxY(attachmentView.frame) + 15);
    }
    
    CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(descriptionTitleLabel.frame) + 5);
    descriptionLabel.text = _transaction.content;
    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit] + 5);
    
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
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(descriptionLabel.frame) + 5);
        CGRectSetHeight(contentView.frame, CGRectGetMaxY(locationLabel.frame) + 15);
    } else {
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(descriptionLabel.frame) + 5.0f);
        [locationLabel setHidden:YES];
        CGRectSetHeight(contentView.frame, CGRectGetMaxY(descriptionLabel.frame) + 15);
    }
    
    CGRectSetHeight(self.frame, CGRectGetMaxY(contentView.frame));
}

- (void)didAddAttachmentClick {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:_transaction.triggerImage]];
}

- (void)setTransaction:(FLTransaction *)transaction {
    _transaction = transaction;
    [self reloadView];
}

@end
