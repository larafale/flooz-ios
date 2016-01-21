//
//  TimelineDealCell.m
//  Flooz
//
//  Created by Olive on 1/21/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "TimelineDealCell.h"
#import "FLSocialButton.h"

#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT_RIGHT 10.

#define MIN_HEIGHT 60.0f

#define FONT_SIZE_LIKE 12

@interface TimelineDealCell () {
    CGFloat height;
    UIView *leftView;
    UIView *rightView;
    
    UILabel *titleLabel;
    UILabel *descriptionLabel;
    FLImageView *attachmentView;
    UILabel *amountLabel;
    
    FLUserView *avatarView;
    
    UIView *footerDescView;
    FLSocialButton *_likeButton;
    FLSocialButton *_commentButton;
    
    WYPopoverController *popoverController;
}

@end

@implementation TimelineDealCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDelegate:(id)delegate {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor customBackgroundHeader];
        _delegateController = delegate;
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForDeal:(FLTimelineDeal *)deal {
    NSAttributedString *attributedText = nil;
    CGRect rect = CGRectZero;
    
    CGFloat paddingSide = MARGE_LEFT_RIGHT;
    CGFloat rightViewWidth = PPScreenWidth() - (paddingSide * 2) - (MARGE_LEFT_RIGHT + 42.0f);
    CGFloat floozerLabelWidth = rightViewWidth;

    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    
    // Height for title
    if ([deal title] && ![[deal title] isBlank]) {
        attributedText = [[NSAttributedString alloc]
                          initWithString:[deal title]
                          attributes:@{ NSFontAttributeName: [UIFont customContentBold:15]}];
        rect = [attributedText boundingRectWithSize:(CGSize) {floozerLabelWidth, CGFLOAT_MAX }
                                            options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                            context:nil];
        current_height += rect.size.height + 3.0f;
    }
    
    // Height for description
    CGFloat heightContent = 10.0f;
    if ([deal content] && ![[deal content] isBlank]) {
        UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, rightViewWidth, 0.0f)];
        view.font = [UIFont customContentLight:14];
        view.text = [deal content];
        heightContent = [view heightToFit] + 3.0f + 4.0f;
    }
    current_height += heightContent;
    
    // Height for attachment
    if ([deal attachmentURL]) {
        CGFloat heightAttach = 250 / (500 / rightViewWidth);
        current_height += 10 + heightAttach;
    }

    current_height += 20.0f; // height of buttons and amount text
    current_height += MARGE_TOP_BOTTOM * 2.0; // add small marge at the bottom
    return current_height;
}

- (void)setDeal:(FLTimelineDeal *)deal {
    self->_deal = deal;
    [self prepareViews];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    self->_indexPath = indexPath;
}

#pragma mark - Create Views

- (void)createViews {
    height = 0;
    
    [self createLeftViews];
    [self createRightViews];
}

- (void)createLeftViews {
    [self createAvatarView];
    
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(avatarView.frame), CGRectGetHeight(self.frame) - MARGE_TOP_BOTTOM)];
    [self.contentView addSubview:leftView];
    
    [leftView addSubview:avatarView];
}

- (void)createAvatarView {
    avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 42, 42)];
    [avatarView setUserInteractionEnabled:YES];
    [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAvatarClick)]];
}

- (void)createRightViews {
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) + MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftView.frame) - MARGE_LEFT_RIGHT * 2.0f, CGRectGetHeight(self.frame) - MARGE_TOP_BOTTOM)];
    [self.contentView addSubview:rightView];
    
    [self createTitleLabel];
    height = CGRectGetMaxY(titleLabel.frame);
    [self createDescriptionLabel];
    height = CGRectGetMaxY(descriptionLabel.frame);
    [self createAttachmentView];
    height = CGRectGetMaxY(attachmentView.frame);
    [self createFooterView];
    height = CGRectGetMaxY(footerDescView.frame);
    CGRectSetHeight(rightView.frame, height);
}

- (void)createTitleLabel {
    titleLabel = [UILabel newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(rightView.frame), 20.0f)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont customContentRegular:14];
    titleLabel.numberOfLines = 0;
    
    [rightView addSubview:titleLabel];
}

- (void)createDescriptionLabel {
    descriptionLabel = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(titleLabel.frame), CGRectGetWidth(rightView.frame), 20.0f)];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.font = [UIFont customContentLight:14];
    descriptionLabel.numberOfLines = 0;
    
    [rightView addSubview:descriptionLabel];
}

- (void)createAttachmentView {
    attachmentView = [[FLImageView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(descriptionLabel.frame), CGRectGetWidth(rightView.frame), 80)];
    [rightView addSubview:attachmentView];
}

- (void)createFooterView {
    height += 10.0f;
    footerDescView = [UIView newWithFrame:CGRectMake(0.0f, height, CGRectGetWidth(rightView.frame), 20.0f)];
    [rightView addSubview:footerDescView];
    
    [self createLikeButton];
    [self createCommentButton];
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
    [_commentButton addTarget:self action:@selector(didCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [footerDescView addSubview:_commentButton];
    CGRectSetX(_commentButton.frame, CGRectGetMinX(_likeButton.frame) + 65.0f);
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
    [self prepareSocial];
    
    CGRectSetHeight(rightView.frame, CGRectGetMaxY(footerDescView.frame));
    CGRectSetHeight(self.contentView.frame, CGRectGetMaxY(rightView.frame) + MARGE_TOP_BOTTOM);
}

- (void)prepareAvatarView {
    FLUserView *view = [[leftView subviews] objectAtIndex:0];
    
    [view setImageFromURL:_deal.from.avatarURL];
}

- (void)prepareDetailView {
    CGFloat titleWidth = CGRectGetWidth(rightView.frame);
    
    
    CGRectSetWidth(titleLabel.frame, titleWidth);
    titleLabel.text = _deal.title;
    
    [titleLabel setHeightToFit];
    
    descriptionLabel.text = _deal.content;
    CGRectSetY(descriptionLabel.frame, CGRectGetMaxY(titleLabel.frame) + 5.0f);
    
    CGRectSetHeight(descriptionLabel.frame, [descriptionLabel heightToFit] + 5.0f);
    height = CGRectGetMaxY(descriptionLabel.frame);
}

- (void)prepareAttachmentView {
    if ([_deal attachmentURL]) {
        CGRectSetY(attachmentView.frame, height + 10.0f);
        CGFloat widthAttach = CGRectGetWidth(attachmentView.frame);
        CGFloat heightAttach = 250 / (500 / widthAttach);
        CGRectSetHeight(attachmentView.frame, heightAttach);
        
        [attachmentView setImageWithURL:[NSURL URLWithString:[_deal attachmentURL]] fullScreenURL:[NSURL URLWithString:[_deal attachmentURL]]];
        height = CGRectGetMaxY(attachmentView.frame);
    }
    else {
        CGRectSetY(attachmentView.frame, height);
        CGRectSetHeight(attachmentView.frame, 0);
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
    FLSocial *social = [_deal social];
    
    CGRectSetY(footerDescView.frame, height + 10.0f);
    [_likeButton setSelected:[social isLiked]];
    [_likeButton setText:[self castNumber:social.likesCount]];
    
    [_commentButton setSelected:[social isCommented]];
    [_commentButton setText:[self castNumber:social.commentsCount]];
}

- (void)prepareAmountLabel {
    amountLabel.text = [FLHelper formatedAmount:[_deal amount] withCurrency:YES];
    [amountLabel setWidthToFit];
    
    CGRectSetX(amountLabel.frame, CGRectGetWidth(footerDescView.frame) - CGRectGetWidth(amountLabel.frame));
}

#pragma mark - Event Handlers

- (void)didLikeButtonLongTouch {
    if (popoverController != nil && popoverController.isPopoverVisible)
        return;
    
    if (_deal.social.likesCount == 0)
        return;
    
    FLLikePopoverViewController *popoverViewController = [[FLLikePopoverViewController alloc] initWithSocial:_deal.social];
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
    [[_deal social] setIsLiked:![[_deal social] isLiked]];
    [_likeButton setSelected:[[_deal social] isLiked]];
    
    //    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
    //        [_transaction setJSON:result[@"item"]];
    //        [self prepareViews];
    //        [self didUpdateTransactionData];
    //    } failure:NULL];
}

- (void)didMoreButtonClick {
    
}

- (void)didUpdateTransactionData {
    if (_indexPath) {
        [_delegateController updateDealAtIndex:_indexPath deal:_deal];
    }
}

- (void)didCommentButtonClick {
    if (_indexPath) {
        [_delegateController commentDealAtIndex:_indexPath deal:_deal];
    }
}

- (void)didAvatarClick {
    [appDelegate showUser:[_deal from] inController:nil];
}

- (void)didUserClick:(FLUser *)user {
    if ([popoverController isPopoverVisible]) {
        [popoverController dismissPopoverAnimated:YES completion:^{
            [appDelegate showUser:user inController:nil];
        }];
    } else
        [appDelegate showUser:user inController:nil];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
