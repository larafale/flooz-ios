//
//  FLTransactionDescriptionView.m
//  Flooz
//
//  Created by Arnaud on 2014-09-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTransactionDescriptionView.h"
#import "FLSocialButton.h"
#import "FLLikePopoverViewController.h"

#define MARGE_TOP_BOTTOM 10.0f
#define MARGE_LEFT_RIGHT 10.0f

#define MIN_HEIGHT 60.0f

#define FONT_SIZE_LIKE 12

@implementation FLTransactionDescriptionView {
    CGFloat height;
    
    UIView *leftView;
    UIView *rightView;
    
    UILabel *floozerLabel;
    UILabel *descriptionLabel;
    FLImageView *attachmentView;
    UILabel *amountLabel;
    
    FLUserView *avatarView;
    
    FLActionButton *commentText;
    FLActionButton *likeText;
    
    BOOL hasAvatar;
    
    UIView *footerDescView;
    FLSocialButton *_likeButton;
    FLSocialButton *_commentButton;
    
    CGFloat paddingSide;
    WYPopoverController *popoverController;
}

- (id)initWithFrame:(CGRect)frame andAvatar:(BOOL)avatar {
    self = [super initWithFrame:frame];
    if (self) {
        hasAvatar = avatar;
        [self createViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame transaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath andAvatar:(BOOL)avatar {
    self = [super initWithFrame:frame];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        hasAvatar = avatar;
        paddingSide = MARGE_LEFT_RIGHT;
        if (!hasAvatar) {
            paddingSide = MARGE_LEFT_RIGHT;
        }
        [self createViews];
    }
    return self;
}

- (void)setTransaction:(FLTransaction *)transaction {
    self->_transaction = transaction;
    [self prepareViews];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    self->_indexPath = indexPath;
}

+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction avatarDisplay:(BOOL)withAvatar andWidth:(CGFloat)width {
    NSAttributedString *attributedText = nil;
    CGRect rect = CGRectZero;
    
    CGFloat paddingSide = MARGE_LEFT_RIGHT;
    CGFloat rightViewWidth = width - (paddingSide * 2);
    if (withAvatar) {
        rightViewWidth -= (MARGE_LEFT_RIGHT + 42.0f);
    }
    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    
    // Height for title
    if ([transaction title] && ![[transaction title] isBlank]) {
        attributedText = [[NSAttributedString alloc]
                          initWithString:[transaction title]
                          attributes:@{ NSFontAttributeName: [UIFont customContentBold:14] }];
        rect = [attributedText boundingRectWithSize:(CGSize) {rightViewWidth, CGFLOAT_MAX }
                                            options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
        current_height += rect.size.height + 3.0f;
    }
    
    current_height += 4.0f;
    
    // Height for description
    CGFloat heightContent = 10.0f;
    if ([transaction content] && ![[transaction content] isBlank]) {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rightViewWidth, 0.0f)];
        view.font = [UIFont customContentLight:14];
        view.text = [transaction content];
        heightContent = [view heightToFit] + 3.0f + 4.0f;
    }
    current_height += heightContent;
    
    // Height for attachment
    if ([transaction attachmentURL]) {
        CGFloat heightAttach = 250 / (500 / rightViewWidth);
        current_height += 6 + heightAttach;
    }
    current_height += 10.0f;
    
    //Height for comment and like text
    FLSocial *social = [transaction social];
    if (social.commentsCount == 0 && (!social.likeText || [social.likeText isBlank])) {
        current_height += 0.0f;
    }
    else {
        CGFloat x = 0.0f;
        if (social.commentsCount > 0) {
            x = 40.0f;
        }
        JTImageLabel *likeText = [[JTImageLabel alloc] initWithFrame:CGRectMake(x, 0.0f, rightViewWidth - x, 12.0f)];
        [likeText setImage:[UIImage imageNamed:@"like-heart"]];
        [likeText setImageOffset:CGPointMake(-2.5, -1)];
        likeText.font = [UIFont customContentRegular:FONT_SIZE_LIKE];
        CGFloat heightLike = 12.0f;
        if ([likeText heightToFit] > heightLike) {
            //			heightLike = [likeText heightToFit];
        }
        current_height += heightLike + 10.0f;
    }
    current_height += 22.5f; // height of buttons and amount text
    current_height += MARGE_TOP_BOTTOM; // add small marge at the bottom
    return current_height;
}

#pragma mark - create views

- (void)createViews {
    height = 0;
    
    if (hasAvatar) {
        [self createLeftViews];
    }
    [self createRightViews];
}

- (void)createLeftViews {
    [self createAvatarView];
    
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(avatarView.frame), CGRectGetHeight(self.frame) - MARGE_TOP_BOTTOM)];
    [self addSubview:leftView];
    
    [leftView addSubview:avatarView];
}

- (void)createAvatarView {
    avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 42, 42)];
    [avatarView setUserInteractionEnabled:YES];
    [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAvatarTouch)]];
}

- (void)createRightViews {
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) + paddingSide, MARGE_TOP_BOTTOM, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftView.frame) - paddingSide * 2.0f, CGRectGetHeight(self.frame) - MARGE_TOP_BOTTOM)];
    [self addSubview:rightView];
    
    [self createFloozerLabel];
    height = CGRectGetMaxY(floozerLabel.frame);
    [self createDescriptionLabel];
    height = CGRectGetMaxY(descriptionLabel.frame);
    [self createAttachmentView];
    height = CGRectGetMaxY(attachmentView.frame);
    [self createAmountLabel];
    height = CGRectGetMaxY(amountLabel.frame);
    
    if (hasAvatar) {
        height = CGRectGetMaxY(amountLabel.frame);
    }
    [self createSocialView];
    height = CGRectGetMaxY(likeText.frame);
    [self createFooterView];
    height = CGRectGetMaxY(footerDescView.frame);
    CGRectSetHeight(rightView.frame, height);
    //    CGRectSetHeight(self.frame, height);
}

- (void)createFloozerLabel {
    floozerLabel = [UILabel newWithFrame:CGRectMake(0.0f, 3.0f, CGRectGetWidth(rightView.frame), 20.0f)];
    floozerLabel.textColor = [UIColor whiteColor];
    floozerLabel.font = [UIFont customContentRegular:14];
    floozerLabel.numberOfLines = 0;
    
    [rightView addSubview:floozerLabel];
}

- (void)createDescriptionLabel {
    descriptionLabel = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(floozerLabel.frame), CGRectGetWidth(rightView.frame), 20.0f)];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont customContentLight:14];
    descriptionLabel.numberOfLines = 0;
    
    [rightView addSubview:descriptionLabel];
}

- (void)createAttachmentView {
    attachmentView = [[FLImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(descriptionLabel.frame), CGRectGetWidth(rightView.frame), 80)];
    [rightView addSubview:attachmentView];
}

- (void)createSocialView {
    commentText = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentText.frame), CGRectGetMaxY(attachmentView.frame), CGRectGetWidth(rightView.frame), 12.0f)];
    [rightView addSubview:commentText];
    [commentText.titleLabel setTextAlignment:NSTextAlignmentRight];
    commentText.titleLabel.font = [UIFont customContentRegular:FONT_SIZE_LIKE];
    [commentText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [commentText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
    [commentText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
    
    [commentText setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [commentText setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [commentText setBackgroundColor:[UIColor clearColor] forState:UIControlStateDisabled];
    
    [commentText setImage:[UIImage imageNamed:@"social-comment"] size:CGSizeMake(13.0, 12.0)];
    CGRectSetX(commentText.imageView.frame, 0);

    
    likeText = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(commentText.frame), CGRectGetMaxY(attachmentView.frame), CGRectGetWidth(rightView.frame), 12.0f)];
    [likeText addTarget:self action:@selector(didLikeTextTouch) forControlEvents:UIControlEventTouchUpInside];
    [rightView addSubview:likeText];
    [likeText.titleLabel setTextAlignment:NSTextAlignmentRight];
    likeText.titleLabel.font = [UIFont customContentRegular:FONT_SIZE_LIKE];
    [likeText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    [likeText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
    [likeText setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
    
    [likeText setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
    [likeText setBackgroundColor:[UIColor clearColor] forState:UIControlStateHighlighted];
    [likeText setBackgroundColor:[UIColor clearColor] forState:UIControlStateDisabled];
    
    [likeText setImage:[UIImage imageNamed:@"like-heart"] size:CGSizeMake(13.0, 12.0)];
    CGRectSetX(likeText.imageView.frame, 0);
}

- (void)createFooterView {
    height += 10.0f;
    footerDescView = [UIView newWithFrame:CGRectMake(0.0f, height, CGRectGetWidth(rightView.frame), 22.5f)];
    [rightView addSubview:footerDescView];
    
    [self createLikeButton];
    [self createCommentButton];
    [self createAmountLabel];
}

- (void)createLikeButton {
    _likeButton = [[FLSocialButton alloc] initWithImageName:@"like_heart_disable" imageSelected:@"like_heart_enable" title:@"J'aime" andHeight:CGRectGetHeight(footerDescView.frame)];
    [_likeButton addTarget:self action:@selector(didLikeButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_likeButton];
}

- (void)createCommentButton {
    _commentButton = [[FLSocialButton alloc] initWithImageName:@"comment_bubble" imageSelected:@"comment_bubble" title:@"Commenter" andHeight:CGRectGetHeight(footerDescView.frame)];
    [_commentButton addTarget:self action:@selector(didWantToCommentTransactionData) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_commentButton];
    CGRectSetX(_commentButton.frame, CGRectGetMaxX(_likeButton.frame) + 3.0f);
}

- (void)createAmountLabel {
    amountLabel = [UILabel newWithFrame:CGRectMake(CGRectGetWidth(footerDescView.frame) - 80.0f, 0.0f, 80.0f, CGRectGetHeight(footerDescView.frame))];
    amountLabel.textColor = [UIColor whiteColor];
    amountLabel.textAlignment = NSTextAlignmentRight;
    amountLabel.font = [UIFont customContentRegular:13];
    
    [footerDescView addSubview:amountLabel];
}

#pragma mark - Prepare Views

- (void)prepareViews {
    height = 0;
    
    [self prepareAvatarView];
    
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareAmountLabel];
    [self prepareLikeView];
    [self prepareSocial];
    
    CGRectSetHeight(rightView.frame, CGRectGetMaxY(footerDescView.frame));
    CGRectSetHeight(self.frame, CGRectGetMaxY(rightView.frame) + MARGE_TOP_BOTTOM);
}

- (void)prepareAvatarView {
    FLUserView *view = [[leftView subviews] objectAtIndex:0];
    
    if ([_delegate transactionAlreadyLoaded:_transaction]) {
        [view setImageFromURL:_transaction.avatarURL];
    }
    else {
        [view setImageFromURLAnimate:_transaction.avatarURL];
    }
}

- (void)prepareDetailView {
    NSMutableAttributedString *attributedContent = [NSMutableAttributedString new];
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:_transaction.text3d[0]
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont customContentBold:14]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:_transaction.text3d[1]
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                           NSFontAttributeName: [UIFont customContentLight:14]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:_transaction.text3d[2]
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont customContentBold:14]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    floozerLabel.attributedText = attributedContent;
    [floozerLabel setHeightToFit];
    
    CGFloat offset = 4.;
    if ([[self transaction] title] &&
        [[self transaction] content]
        && ![[[self transaction] title] isBlank]
        && ![[[self transaction] content] isBlank]) {
        offset = 4.;
    }
    
    
    descriptionLabel.text = [[self transaction] content];
    CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(floozerLabel.frame) + offset);
    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit] + 3); // + 3 car quand emoticone ca passe pas
    height = CGRectGetMaxY(descriptionLabel.frame) + offset;
}

- (void)prepareAttachmentView {
    if ([_transaction attachmentURL]) {
        CGRectSetY(attachmentView.frame, height + 10.0f);
        CGFloat widthAttach = CGRectGetWidth(attachmentView.frame);
        CGFloat heightAttach = 250 / (500 / widthAttach);
        CGRectSetHeight(attachmentView.frame, heightAttach);
        
        [attachmentView setImageWithURL:[NSURL URLWithString:[_transaction attachmentURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]]];
    }
    else {
        CGRectSetY(attachmentView.frame, height);
        CGRectSetHeight(attachmentView.frame, 0);
    }
    height = CGRectGetMaxY(attachmentView.frame);
}

- (void)prepareLikeView {
    CGRectSetY(commentText.frame, CGRectGetMaxY(attachmentView.frame) + 12.0f);
    CGRectSetY(likeText.frame, CGRectGetMaxY(attachmentView.frame) + 12.0f);
    
    FLSocial *social = [_transaction social];
    
    {
        if (social.commentsCount == 0) {
            commentText.hidden = YES;
            [commentText setTitle:@"" forState:UIControlStateNormal];
            CGRectSetX(likeText.frame, 0.0f);
            CGRectSetWidth(likeText.frame, CGRectGetWidth(rightView.frame));
        }
        else {
            NSString *nbComments = [self castNumber:social.commentsCount];
            commentText.hidden = NO;
            [commentText setTitle:nbComments forState:UIControlStateNormal];
            
            CGFloat labelSize = [nbComments widthOfString:[UIFont customContentRegular:FONT_SIZE_LIKE]];
            CGRectSetWidth(commentText.frame, labelSize + 12 * 3);
            
            CGRectSetX(likeText.frame, CGRectGetWidth(commentText.frame));
            CGRectSetWidth(likeText.frame, CGRectGetWidth(rightView.frame) - CGRectGetWidth(commentText.frame));
        }
    }
    
    {
        if (!social.likeText || [social.likeText isBlank]) {
            likeText.hidden = YES;
            [likeText setTitle:@"" forState:UIControlStateNormal];
        }
        else {
            likeText.hidden = NO;
            [likeText setTitle:social.likeText forState:UIControlStateNormal];
            
            CGFloat labelSize = [social.likeText widthOfString:[UIFont customContentRegular:FONT_SIZE_LIKE]];
            CGRectSetWidth(likeText.frame, labelSize + 12 * 3);
        }
        
        CGFloat heightLike = 12.0f;
        if ([likeText heightToFit] > heightLike) {
            //			heightLike = [likeText heightToFit];
        }
        CGRectSetHeight(likeText.frame, heightLike);
        height = CGRectGetMaxY(likeText.frame);
    }
    
    if (social.commentsCount == 0 && (!social.likeText || [social.likeText isBlank])) {
        height = CGRectGetMaxY(attachmentView.frame);
    }
}

- (NSString *)castNumber:(NSUInteger)number {
    if (!number) {
        return @"";
    }
    
    NSString *cast = @"%02d";
    if ((int)number == 0) {
        return @"";
    }
    return [NSString stringWithFormat:cast, number];
}

- (void)prepareSocial {
    CGRectSetY(footerDescView.frame, height + 10.0f);
    [_likeButton setSelected:[[_transaction social] isLiked]];
    
    if (![[Flooz sharedInstance] currentUser]) {
        return;
    }
}

- (void)prepareAmountLabel {
    amountLabel.text = [_transaction amountText]; // [FLHelper formatedAmount:[_transaction amount] withCurrency:YES];
    [amountLabel setWidthToFit];
    
    CGRectSetX(amountLabel.frame, CGRectGetWidth(footerDescView.frame) - CGRectGetWidth(amountLabel.frame));
}

- (void)didLikeTextTouch {
    FLLikePopoverViewController *popoverViewController = [[FLLikePopoverViewController alloc] initWithTransaction:_transaction];
    popoverViewController.modalInPopover = NO;

    popoverController = [[WYPopoverController alloc] initWithContentViewController:popoverViewController];
    popoverController.delegate = self;
    
    [popoverController presentPopoverFromRect:likeText.bounds inView:likeText permittedArrowDirections:WYPopoverArrowDirectionDown|WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:nil];
}

- (void)didAvatarTouch {
    if (_indexPath) {
        [_delegate didTransactionUserTouchAtIndex:_indexPath transaction:_transaction];
    }
}

- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
{
    return YES;
}

- (void)didLikeButtonTouch {
    if (![[Flooz sharedInstance] currentUser]) {
        return;
    }
    [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
    [_likeButton setSelected:[[_transaction social] isLiked]];
    
    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
        [[_transaction social] setLikeText:[result objectForKey:@"item"]];
        NSInteger numberOfLike = [[_transaction social] likesCount];
        NSMutableArray *tmpLikes = [[_transaction social].likes mutableCopy];
        if ([[_transaction social] isLiked]) {
            numberOfLike += 1;
            if (numberOfLike == 1)
                tmpLikes = [NSMutableArray new];
            
            FLUser *currentUser = [Flooz sharedInstance].currentUser;
            [tmpLikes addObject:@{@"_id": currentUser.userId, @"nick": currentUser.username, @"userId": currentUser.userId}];
        }
        else {
            numberOfLike -= 1;
            
            for (NSDictionary *likeUser in tmpLikes) {
                if ([likeUser[@"nick"] isEqualToString:[Flooz sharedInstance].currentUser.username]) {
                    [tmpLikes removeObject:likeUser];
                    break;
                }
            }
        }
        [[_transaction social] setLikes:tmpLikes];
        [[_transaction social] setLikesCount:numberOfLike];
        [self prepareViews];
        [self didUpdateTransactionData];
    } failure:NULL];
}

- (void)didUpdateTransactionData {
    
    if (_parentController) {
        [_parentController reloadTransaction];
    }
    else {
        if (_indexPath) {
            [_delegate updateTransactionAtIndex:_indexPath transaction:_transaction];
        }
    }
}

- (void)didWantToCommentTransactionData {
    if (_parentController) {
        [_parentController focusOnComment];
    }
    else {
        if (_indexPath) {
            [_delegate commentTransactionAtIndex:_indexPath transaction:_transaction];
        }
    }
}

@end
