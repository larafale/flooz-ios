//
//  TransactionCell.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import "TransactionCell.h"

#import "CreditCardViewController.h"

#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT_RIGHT 10.
#define MIN_HEIGHT 100.0f

@implementation TransactionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDelegate:(id)delegate {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.backgroundColor = [UIColor customBackground];
		_delegateController = delegate;
		[self createViews];
	}
	return self;
}

+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction andWidth:(CGFloat)width {
	CGFloat heightCell = 0.0f;
	heightCell += [FLTransactionDescriptionView getHeightForTransaction:transaction avatarDisplay:YES andWidth:width]; //height of description
	heightCell += 5.0f;
	return heightCell;
}

- (void)setTransaction:(FLTransaction *)transaction {
	self->_transaction = transaction;
	[self prepareViews];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
	self->_indexPath = indexPath;
	[transactionDetailsView setIndexPath:indexPath];
}

#pragma mark - Create Views

- (void)createViews {
	height = 0;

	[self createDetailsView];
}

- (void)createDetailsView {
	transactionDetailsView = [[FLTransactionDescriptionView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), MIN_HEIGHT) transaction:_transaction indexPath:_indexPath andAvatar:YES];
	transactionDetailsView.delegate = _delegateController;
	[self.contentView addSubview:transactionDetailsView];
}

#pragma mark -

- (void)didCellTouch {
	NSIndexPath *indexPath = [[_delegateController tableView] indexPathForCell:self];
	[_delegateController didTransactionTouchAtIndex:indexPath transaction:_transaction];
}

#pragma mark - Prepare Views

- (void)prepareViews {
    [transactionDetailsView setTransaction:_transaction];
}

#pragma mark - Actions

- (void)didLikeButtonTouch {
	if (![[Flooz sharedInstance] currentUser]) {
		return;
	}
	[[_transaction social] setIsLiked:![[_transaction social] isLiked]];

	[[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
	    [[_transaction social] setLikeText:[result objectForKey:@"item"]];
	    NSInteger numberOfLike = [[_transaction social] likesCount];
	    if ([[_transaction social] isLiked]) {
	        numberOfLike += 1;
		}
	    else {
	        numberOfLike -= 1;
		}
	    [[_transaction social] setLikesCount:numberOfLike];
	    [transactionDetailsView setTransaction:_transaction];
	    [self prepareViews];
	} failure:NULL];
}

- (void)block {
    for (UIView *v in self.contentView.subviews) {
         [v setUserInteractionEnabled:NO];
    }
}

@end