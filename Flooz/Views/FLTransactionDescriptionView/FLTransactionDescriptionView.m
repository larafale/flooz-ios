//
//  FLTransactionDescriptionView.m
//  Flooz
//
//  Created by Arnaud on 2014-09-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLTransactionDescriptionView.h"
#import "FLSocialButton.h"

#define MARGE_TOP_BOTTOM 10.0f
#define MARGE_LEFT_RIGHT 10.0f

#define MIN_HEIGHT 60.0f

#define FONT_SIZE_LIKE 12

@implementation FLTransactionDescriptionView {
    BOOL stripTitle;
    
    CGFloat height;
    
    UIView *leftView;
    UIView *rightView;
    
    UILabel *floozerLabel;
    UILabel *whenLabel;
    UILabel *locationLabel;
    UILabel *likesLabel;
    UILabel *descriptionLabel;
    FLImageView *attachmentView;
    UILabel *amountLabel;
    
    FLUserView *avatarView;
    
    BOOL hasAvatar;
    
    UIView *footerDescView;
    FLSocialButton *_likeButton;
    FLSocialButton *_commentButton;
    FLSocialButton *_shareButton;
    FLSocialButton *_moreButton;
    
    CGFloat paddingSide;
    WYPopoverController *popoverController;
}
    
- (id)initWithFrame:(CGRect)frame andAvatar:(BOOL)avatar {
    self = [super initWithFrame:frame];
    if (self) {
        hasAvatar = avatar;
        [self createViews];
        stripTitle = NO;
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
    [self setTransaction:transaction hideTitle:NO];
}
    
- (void)setTransaction:(FLTransaction *)transaction hideTitle:(BOOL)hideTitle {
    self->_transaction = transaction;
    stripTitle = hideTitle;
    [self prepareViews];
}
    
- (void)setIndexPath:(NSIndexPath *)indexPath {
    self->_indexPath = indexPath;
}
    
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction avatarDisplay:(BOOL)withAvatar andWidth:(CGFloat)width {
    return [FLTransactionDescriptionView getHeightForTransaction:transaction avatarDisplay:withAvatar andWidth:width hideTitle:NO];
}
    
+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction avatarDisplay:(BOOL)withAvatar andWidth:(CGFloat)width hideTitle:(BOOL)hideTitle {
    NSAttributedString *attributedText = nil;
    CGRect rect = CGRectZero;
    
    CGFloat paddingSide = MARGE_LEFT_RIGHT;
    CGFloat rightViewWidth = width - (paddingSide * 2);
    CGFloat floozerLabelWidth = rightViewWidth;
    if (withAvatar) {
        rightViewWidth -= (MARGE_LEFT_RIGHT + 42.0f);
        floozerLabelWidth = rightViewWidth - [transaction.when widthOfString:[UIFont customContentRegular:13]] - MARGE_LEFT_RIGHT;
    }
    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    
    // Height for title
    if (hideTitle) {
        if ([transaction text3d][0] && ![[transaction text3d][0] isBlank]) {
            attributedText = [[NSAttributedString alloc]
                              initWithString:[transaction text3d][0]
                              attributes:@{ NSFontAttributeName: [UIFont customContentBold:15]}];
            rect = [attributedText boundingRectWithSize:(CGSize) {floozerLabelWidth, CGFLOAT_MAX }
                                                options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
            current_height += rect.size.height + 3.0f;
        }
    } else {
        if ([transaction title] && ![[transaction title] isBlank]) {
            attributedText = [[NSAttributedString alloc]
                              initWithString:[transaction title]
                              attributes:@{ NSFontAttributeName: [UIFont customContentBold:15]}];
            rect = [attributedText boundingRectWithSize:(CGSize) {floozerLabelWidth, CGFLOAT_MAX }
                                                options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                context:nil];
            current_height += rect.size.height + 3.0f;
        }
    }
    
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
        current_height += 10 + heightAttach;
    }
    
    if (transaction.location)
    current_height += 25.0f;
    
    if (!withAvatar && transaction.social.likesCount > 0)
    current_height += 18.0f;
    
    if ([FLTransactionDescriptionView isFooterViewVisisbleForTransaction:transaction])
    current_height += 20.0f; // height of buttons and amount text
    
    current_height += MARGE_TOP_BOTTOM; // add small marge at the bottom
    return current_height;
}
    
+ (BOOL)isFooterViewVisisbleForTransaction:(FLTransaction *)transaction {
    if (transaction.options.likeEnabled || transaction.options.commentEnabled) {
        return true;
    }
    
    if (transaction.amountText && transaction.amountText.length) {
        return true;
    }
    
    return false;
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
    [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAvatarClick)]];
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
    [self createLocationView];
    height = CGRectGetMaxY(locationLabel.frame);
    
    if (!hasAvatar) {
        [self createLikesView];
        height = CGRectGetMaxY(locationLabel.frame);
    }
    
    [self createAmountLabel];
    [self createFooterView];
    height = CGRectGetMaxY(footerDescView.frame);
    CGRectSetHeight(rightView.frame, height);
}
    
- (void)createFloozerLabel {
    floozerLabel = [UILabel newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rightView.frame), 20.0f)];
    floozerLabel.textColor = [UIColor whiteColor];
    floozerLabel.font = [UIFont customContentRegular:14];
    floozerLabel.numberOfLines = 0;
    
    [rightView addSubview:floozerLabel];
    
    whenLabel = [UILabel newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rightView.frame), 15.0f)];
    whenLabel.textColor = [UIColor customPlaceholder];
    whenLabel.font = [UIFont customContentRegular:13];
    whenLabel.numberOfLines = 1;
    
    [rightView addSubview:whenLabel];
}
    
- (void) createLocationView {
    locationLabel = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(floozerLabel.frame), CGRectGetWidth(rightView.frame), 15.0f)];
    locationLabel.textColor = [UIColor customPlaceholder];
    locationLabel.numberOfLines = 1;
    locationLabel.font = [UIFont customContentRegular:12];
    
    [rightView addSubview:locationLabel];
}
    
- (void) createLikesView {
    likesLabel = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(floozerLabel.frame), CGRectGetWidth(rightView.frame), 15.0f)];
    likesLabel.textColor = [UIColor customPlaceholder];
    likesLabel.numberOfLines = 1;
    likesLabel.font = [UIFont customContentRegular:12];
    [likesLabel setUserInteractionEnabled:YES];
    [likesLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeTextTouch)]];
    
    [rightView addSubview:likesLabel];
}
    
- (void)createDescriptionLabel {
    descriptionLabel = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(floozerLabel.frame), CGRectGetWidth(rightView.frame), 20.0f)];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont customContentLight:14];
    descriptionLabel.numberOfLines = 0;
    
    [rightView addSubview:descriptionLabel];
}
    
- (void)createAttachmentView {
    CGFloat widthAttach = CGRectGetWidth(rightView.frame);
    CGFloat heightAttach = 250 / (500 / widthAttach);
    
    attachmentView = [[FLImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(descriptionLabel.frame), CGRectGetWidth(rightView.frame), heightAttach)];
    [attachmentView setBackgroundColor:[UIColor customBackground]];
    [rightView addSubview:attachmentView];
}
    
- (void)createFooterView {
    height += 10.0f;
    footerDescView = [UIView newWithFrame:CGRectMake(0.0f, height, CGRectGetWidth(rightView.frame), 20.0f)];
    [rightView addSubview:footerDescView];
    
    [self createLikeButton];
    [self createCommentButton];
    //    [self createShareButton];
    //    [self createMoreButton];
    [self createAmountLabel];
}
    
- (void)createLikeButton {
    _likeButton = [[FLSocialButton alloc] initWithImageName:@"like-heart" color:[UIColor customSocialColor] selectedColor:[UIColor customPink] title:@"" height:CGRectGetHeight(footerDescView.frame)];
    [_likeButton addTarget:self action:@selector(didLikeButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [_likeButton addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeButtonLongTouch)]];
    [footerDescView addSubview:_likeButton];
}
    
- (void)createCommentButton {
    _commentButton = [[FLSocialButton alloc] initWithImageName:@"comment_bubble" color:[UIColor customSocialColor] selectedColor:[UIColor customBlue] title:@"" height:CGRectGetHeight(footerDescView.frame)];
    [_commentButton addTarget:self action:@selector(didWantToCommentTransactionData) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_commentButton];
    CGRectSetX(_commentButton.frame, CGRectGetMinX(_likeButton.frame) + 65.0f);
}
    
- (void)createShareButton {
    _shareButton = [[FLSocialButton alloc] initWithImageName:@"share" color:[UIColor customSocialColor] selectedColor:[UIColor customSocialColor] title:@"" height:CGRectGetHeight(footerDescView.frame)];
    [_shareButton addTarget:self action:@selector(didShareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_shareButton];
    CGRectSetX(_shareButton.frame, CGRectGetMinX(_commentButton.frame) + 65.0f);
}
    
- (void)createMoreButton {
    _moreButton = [[FLSocialButton alloc] initWithImageName:@"more" color:[UIColor customSocialColor] selectedColor:[UIColor customSocialColor] title:@"" height:CGRectGetHeight(footerDescView.frame)];
    [_moreButton addTarget:self action:@selector(didMoreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_moreButton];
    CGRectSetX(_moreButton.frame, CGRectGetMaxX(_shareButton.frame) + 12.0f);
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
    [self prepareLocationView];
    
    if (!hasAvatar)
    [self prepareLike];
    
    [self prepareSocial];
    
    if ([FLTransactionDescriptionView isFooterViewVisisbleForTransaction:self.transaction])
    CGRectSetHeight(rightView.frame, CGRectGetMaxY(footerDescView.frame));
    else
    CGRectSetHeight(rightView.frame, height);
    
    CGRectSetHeight(self.frame, CGRectGetMaxY(rightView.frame) + MARGE_TOP_BOTTOM);
}
    
- (void)prepareAvatarView {
    FLUserView *view = [[leftView subviews] objectAtIndex:0];
    
    [view setImageFromURL:_transaction.avatarURL];
}
    
- (void)prepareDetailView {
    CGFloat titleWidth = CGRectGetWidth(rightView.frame);
    
    if (hasAvatar) {
        [whenLabel setText:_transaction.when];
        [whenLabel setWidthToFit];
        
        CGRectSetX(whenLabel.frame, CGRectGetWidth(rightView.frame) - CGRectGetWidth(whenLabel.frame));
        titleWidth = titleWidth - CGRectGetWidth(whenLabel.frame) - MARGE_LEFT_RIGHT;
    }
    
    NSMutableAttributedString *attributedContent = [NSMutableAttributedString new];
    
    {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:(_transaction.text3d[0] != nil ? _transaction.text3d[0] : @"")
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont customContentBold:15]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSString *text = @"";
        
        if (!stripTitle) {
            text = (_transaction.text3d[1] != nil ? _transaction.text3d[1] : @"");
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:text
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                           NSFontAttributeName: [UIFont customContentLight:15]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    {
        NSString *text = @"";
        
        if (!stripTitle) {
            text = (_transaction.text3d[2] != nil ? _transaction.text3d[2] : @"");
        }
        
        NSAttributedString *attributedText = [[NSAttributedString alloc]
                                              initWithString:text
                                              attributes:@{
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont customContentBold:15]
                                                           }];
        
        [attributedContent appendAttributedString:attributedText];
    }
    
    CGRectSetWidth(floozerLabel.frame, titleWidth);
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
    
    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit] + offset);
    height = CGRectGetMaxY(descriptionLabel.frame);
}
    
- (void)prepareAttachmentView {
    if ([_transaction attachmentURL]) {
        CGRectSetY(attachmentView.frame, height + 10.0f);
        CGFloat widthAttach = CGRectGetWidth(attachmentView.frame);
        CGFloat heightAttach = 250 / (500 / widthAttach);
        CGRectSetHeight(attachmentView.frame, heightAttach);
        
        if ([_transaction attachmentType] == TransactionAttachmentImage)
        [attachmentView setMediaWithURL:[NSURL URLWithString:[_transaction attachmentURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]] mediaType:[_transaction attachmentType]];
        else if (([_transaction attachmentType] != TransactionAttachmentNone))
        [attachmentView setMediaWithURL:[NSURL URLWithString:[_transaction attachmentThumbURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]] mediaType:[_transaction attachmentType]];
        
        height = CGRectGetMaxY(attachmentView.frame);
    }
    else {
        CGRectSetY(attachmentView.frame, height);
        CGRectSetHeight(attachmentView.frame, 0);
    }
}
    
- (void)prepareLocationView {
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
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(attachmentView.frame) + 10);
        
        height = CGRectGetMaxY(locationLabel.frame);
    } else {
        CGRectSetY(locationLabel.frame, CGRectGetMaxY(attachmentView.frame) + 5.0f);
        [locationLabel setHidden:YES];
        CGRectSetHeight(locationLabel.frame, 0.0f);
    }
}
    
- (void)prepareLike {
    if (_transaction.social.likesCount > 0) {
        [likesLabel setHidden:NO];
        CGRectSetHeight(likesLabel.frame, 18.0f);
        
        NSMutableAttributedString *attributedData = [NSMutableAttributedString new];
        
        UIImage *cbImage = [UIImage imageNamed:@"like-heart"];
        CGSize newImgSize = CGSizeMake(14, 14);
        
        cbImage = [FLHelper imageWithImage:cbImage scaledToSize:newImgSize];
        cbImage = [FLHelper colorImage:cbImage color:[UIColor customPlaceholder]];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = cbImage;
        attachment.bounds = CGRectMake(0, -2.5, attachment.image.size.width, attachment.image.size.height);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        [attributedData appendAttributedString:attachmentString];
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:[NSString stringWithFormat:@" %@", _transaction.social.likeText]
                                                  attributes:@{
                                                               NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                               NSFontAttributeName: [UIFont customContentRegular:12]
                                                               }];
            
            [attributedData appendAttributedString:attributedText];
        }
        
        likesLabel.attributedText = attributedData;
        CGRectSetWidth(likesLabel.frame, [likesLabel widthToFit] + 15);
        CGRectSetY(likesLabel.frame, CGRectGetMaxY(locationLabel.frame));
        
        height = CGRectGetMaxY(likesLabel.frame);
    } else {
        CGRectSetY(likesLabel.frame, CGRectGetMaxY(locationLabel.frame));
        [likesLabel setHidden:YES];
        CGRectSetHeight(likesLabel.frame, 0.0f);
    }
}
    
- (NSString *)castNumber:(NSUInteger)number {
    if (!number) {
        return @"";
    }
    
    if ((int)number == 0) {
        return @"";
    }
    
    return [self abbreviateNumber:(int)number];
}
    
-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        abbrevNum = [NSString stringWithFormat:@"%02d", (int)number];
    }
    
    return abbrevNum;
}
    
- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if (c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}
    
- (void)prepareSocial {
    if ([FLTransactionDescriptionView isFooterViewVisisbleForTransaction:self.transaction]) {
        footerDescView.hidden = NO;
        FLSocial *social = [_transaction social];
        
        CGRectSetY(footerDescView.frame, height + 10.0f);
        
        if (self.transaction.options.likeEnabled && self.transaction.options.commentEnabled) {
            [_likeButton setHidden:NO];
            [_likeButton setSelected:[[_transaction social] isLiked]];
            [_likeButton setText:[self castNumber:social.likesCount]];
            
            [_commentButton setHidden:NO];
            [_commentButton setSelected:[[_transaction social] isCommented]];
            [_commentButton setText:[self castNumber:social.commentsCount]];
            CGRectSetX(_commentButton.frame, CGRectGetMinX(_likeButton.frame) + 65.0f);
        } else if (self.transaction.options.likeEnabled) {
            [_likeButton setHidden:NO];
            [_likeButton setSelected:[[_transaction social] isLiked]];
            [_likeButton setText:[self castNumber:social.likesCount]];
            
            [_commentButton setHidden:YES];
        } else if (self.transaction.options.commentEnabled) {
            [_likeButton setHidden:YES];
            
            [_commentButton setHidden:NO];
            [_commentButton setSelected:[[_transaction social] isCommented]];
            [_commentButton setText:[self castNumber:social.commentsCount]];
            
            CGRectSetX(_commentButton.frame, CGRectGetMinX(_likeButton.frame));
        } else {
            [_likeButton setHidden:YES];
            [_commentButton setHidden:YES];
        }
    } else {
        footerDescView.hidden = YES;
    }
}
    
- (void)prepareAmountLabel {
    amountLabel.text = [_transaction amountText]; // [FLHelper formatedAmount:[_transaction amount] withCurrency:YES];
    [amountLabel setWidthToFit];
    
    CGRectSetX(amountLabel.frame, CGRectGetWidth(footerDescView.frame) - CGRectGetWidth(amountLabel.frame));
}
    
- (void)didLikeTextTouch {
    if (popoverController != nil && popoverController.isPopoverVisible)
    return;
    
    if (_transaction.social.likesCount == 0)
    return;
    
    FLLikePopoverViewController *popoverViewController = [[FLLikePopoverViewController alloc] initWithSocial:_transaction.social];
    [popoverViewController setDelegate:self];
    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:popoverViewController];
    popoverController.delegate = self;
    popoverController.theme.dimsBackgroundViewsTintColor = NO;
    [popoverController presentPopoverFromRect:likesLabel.bounds inView:likesLabel permittedArrowDirections:WYPopoverArrowDirectionDown|WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
        
    }];
}
    
- (void)didLikeButtonLongTouch {
    if (popoverController != nil && popoverController.isPopoverVisible)
    return;
    
    if (_transaction.social.likesCount == 0)
    return;
    
    FLLikePopoverViewController *popoverViewController = [[FLLikePopoverViewController alloc] initWithSocial:_transaction.social];
    [popoverViewController setDelegate:self];
    
    popoverController = [[WYPopoverController alloc] initWithContentViewController:popoverViewController];
    popoverController.delegate = self;
    popoverController.theme.dimsBackgroundViewsTintColor = NO;
    [popoverController presentPopoverFromRect:_likeButton.bounds inView:_likeButton permittedArrowDirections:WYPopoverArrowDirectionDown|WYPopoverArrowDirectionUp animated:YES options:WYPopoverAnimationOptionFadeWithScale completion:^{
        
    }];
}
    
- (BOOL)popoverControllerShouldDismissPopover:(WYPopoverController *)controller
    {
        return YES;
    }
    
- (void)popoverController:(WYPopoverController *)popoverController willTranslatePopoverWithYOffset:(float *)value
    {
        *value = 0;
    }
    
- (void)didLikeButtonTouch {
    if (![[Flooz sharedInstance] currentUser]) {
        return;
    }
    [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
    [_likeButton setSelected:[[_transaction social] isLiked]];
    
    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
        [_transaction setJSON:result[@"item"]];
        [self prepareViews];
        [self didUpdateTransactionData];
    } failure:^(NSError *error) {
        [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
        [_likeButton setSelected:[[_transaction social] isLiked]];
    }];
}
    
- (void)didShareButtonClick {
    
}
    
- (void)didMoreButtonClick {
    
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
        [_parentController focusOnComment:@YES];
    }
    else {
        if (_indexPath) {
            [_delegate commentTransactionAtIndex:_indexPath transaction:_transaction];
        }
    }
}
    
- (void)didAvatarClick {
    [appDelegate showUser:[_transaction starter] inController:nil];
}
    
- (void)didUserClick:(FLUser *)user {
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES completion:^{
            [appDelegate showUser:user inController:nil];
        }];
    } else
    [appDelegate showUser:user inController:nil];
}
    
    @end
