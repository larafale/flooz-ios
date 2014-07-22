//
//  TransactionCell.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionCell.h"

#import "CreditCardViewController.h"

#define MARGE_TOP_BOTTOM 14.
#define MARGE_LEFT_RIGHT 10.

@implementation TransactionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForTransaction:(FLTransaction *)transaction{
    NSAttributedString *attributedText = nil;
    CGRect rect = CGRectZero;
    CGFloat rightViewWidth = SCREEN_WIDTH - 60 - MARGE_LEFT_RIGHT;
    
    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    
    if([transaction title] && ![[transaction title] isBlank]){
        attributedText = [[NSAttributedString alloc]
                          initWithString:[transaction title]
                          attributes:@{NSFontAttributeName: [UIFont customContentRegular:13]}];
        rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        current_height += rect.size.height;
    }
    
    current_height += 4;
    
    if([transaction content] && ![[transaction content] isBlank]){
//        if([transaction title] && ![[transaction title] isBlank]){
//            current_height += 4;
//        }
    
        attributedText = [[NSAttributedString alloc]
                          initWithString:[transaction content]
                          attributes:@{NSFontAttributeName: [UIFont customContentLight:12]}];
        rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        current_height += rect.size.height;
    }

    
    // Attachment
    if([transaction attachmentThumbURL]){
        current_height += 13 + 80;
    }
    
    // Social, Footer
    current_height += 14 + 15;
    
    current_height += MARGE_TOP_BOTTOM;
    
    return current_height;
}

- (void)setTransaction:(FLTransaction *)transaction{
    self->_transaction = transaction;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    height = 0;
    isSwipable = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor]; // WARNING
    
    [self createLeftViews];
    [self createSlideView];
    [self createRightViews];
    [self createActionViews];
}

- (void)createLeftViews{
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, 50, 0)];
    
    [self.contentView addSubview:leftView];
    
    [self createAvatarView];
}

- (void)createSlideView{
    slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, 0)];
    slideView.backgroundColor = [UIColor customYellow];
    
    [self.contentView addSubview:slideView];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), MARGE_TOP_BOTTOM, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftView.frame) - MARGE_LEFT_RIGHT, 0)];
    
    [self.contentView addSubview:rightView];
    
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
    [self createFooterView];
    [self createPaymentFieldView];
}

- (void)createActionViews{
    {
        actionView = [[UIView alloc] initWithFrame:CGRectMake(- CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        
        actionView.backgroundColor = [UIColor customBackgroundHeader];
        
        [self.contentView addSubview:actionView];
    }

    {
        JTImageLabel *text = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(actionView.frame) - 30, CGRectGetHeight(actionView.frame))];
        
        [text setImageOffset:CGPointMake(-10, 0)];
        text.textAlignment = NSTextAlignmentRight;
        text.font = [UIFont customTitleExtraLight:14];
        
        [actionView addSubview:text];
    }

    {
        FLSocialView *socialView = [[rightView subviews] objectAtIndex:2];
        
        // Plus de swipe sur les flooz
//        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
//        swipeGesture.delegate = self;
//        [swipeGesture requireGestureRecognizerToFail:[socialView gesture]];
//        [self.contentView addGestureRecognizer:swipeGesture];
//        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCellTouch)];
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:[socialView gesture]];
//        [tapGesture requireGestureRecognizerToFail:swipeGesture];
        [self.contentView addGestureRecognizer:tapGesture];
    }
}

- (void)createAvatarView{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(0, 0, 42, 42)];
    [leftView addSubview:view];
}

- (void)createDetailView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height + 9, CGRectGetWidth(rightView.frame), 0)];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    
    text.textColor = [UIColor whiteColor];
    text.font = [UIFont customContentRegular:13];
    text.numberOfLines = 0;
    
    content.textColor = [UIColor customPlaceholder];
    content.font = [UIFont customContentLight:13];
    content.numberOfLines = 0;
    
    [view addSubview:text];
    [view addSubview:content];
    [rightView addSubview:view];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)createAttachmentView{
    FLImageView *view = [[FLImageView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(rightView.frame), 0)];
    [rightView addSubview:view];
}

- (void)createSocialView{
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    [view addTargetForLike:self action:@selector(didLikeButtonTouch)];
    [rightView addSubview:view];
}

- (void)createFooterView{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 22)];
    
    view.textColor = [UIColor whiteColor];
    view.textAlignment = NSTextAlignmentCenter;
    view.font = [UIFont customContentRegular:12];
    
    [rightView addSubview:view];
}

- (void)createPaymentFieldView{
    paymentField = [[FLPaymentField alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(self.frame), 0) for:nil key:nil];
    
    paymentField.delegate = self;
    
    [self.contentView addSubview:paymentField];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    isSwipable = NO; //[_transaction isAcceptable];
    
    [self hidePaymentField];
    
    [self prepareAvatarView];
    [self prepareSlideView];
    
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareFooterView];
    [self prepareSocialView];
    
    CGRectSetHeight(leftView.frame, height);
    CGRectSetHeight(rightView.frame, height);
    
    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    CGRectSetHeight(slideView.frame, height);
    CGRectSetHeight(actionView.frame, height);
    CGRectSetHeight(self.frame, height);
}

- (void)prepareAvatarView{
    FLUserView *view = [[leftView subviews] objectAtIndex:0];
    
    if([_delegate transactionAlreadyLoaded:_transaction]){
        [view setImageFromURL:_transaction.avatarURL];
    }
    else{
        [view setImageFromURLAnimate:_transaction.avatarURL];
    }
}

- (void)prepareSlideView{
    if(isSwipable){
        slideView.hidden = NO;
    }else{
        slideView.hidden = YES;
    }
}

- (void)prepareDetailView{
    UIView *view = [[rightView subviews] objectAtIndex:0];

    UILabel *text = [[view subviews] objectAtIndex:0];
    UILabel *content = [[view subviews] objectAtIndex:1];
    
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
    
//    text.text = [[self transaction] title];
    text.attributedText = attributedContent;
    [text setHeightToFit];

    CGFloat offset = 4.;
//    if([[self transaction] title] &&
//       [[self transaction] content]
//       && ![[[self transaction] title] isBlank]
//       && ![[[self transaction] content] isBlank]){
//        offset = 4.;
//    }
    
    
    content.text = [[self transaction] content];
    CGRectSetY(content.frame, CGRectGetMaxY(text.frame) + offset);
    [content setHeightToFit];
    
    CGRectSetY(view.frame, height);
    CGRectSetHeight(view.frame, CGRectGetHeight(text.frame) + CGRectGetHeight(content.frame) + offset);
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    FLImageView *view = [[rightView subviews] objectAtIndex:1];
    
    if([_transaction attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_transaction attachmentThumbURL]] fullScreenURL:[NSURL URLWithString:[_transaction attachmentURL]]];
        
        CGRectSetY(view.frame, height + 13);
        CGRectSetHeight(view.frame, 80);
        height = CGRectGetMaxY(view.frame);
    }
    else{
        CGRectSetHeight(view.frame, 0);
    }
}

- (void)prepareSocialView{
    FLSocialView *view = [[rightView subviews] objectAtIndex:2];
    [view prepareView:_transaction.social];
    CGRectSetY(view.frame, height + 14);

    height = CGRectGetMaxY(view.frame);
}

- (void)prepareFooterView{
    UILabel *view = [[rightView subviews] objectAtIndex:3];
    
//    if(![_transaction isPrivate]){
//        view.hidden = YES;
//        return;
//    }
//    view.hidden = NO;
    
    view.text = [FLHelper formatedAmount:[_transaction amount] withCurrency:YES];
    [view setWidthToFit];
    
    CGRectSetXY(view.frame, CGRectGetWidth(rightView.frame) - CGRectGetWidth(view.frame), height + 9.5);
}

#pragma mark - Swipe

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if(!paymentField.hidden){
        return NO;
    }
    
    if([gestureRecognizer class] == [UIPanGestureRecognizer class]){
        UIPanGestureRecognizer *gesture = (UIPanGestureRecognizer *)gestureRecognizer;
        
        CGPoint translation = [gesture translationInView:self];
        if(isSwipable && translation.x > 0.){
            return YES;
        }
    }
    else if([gestureRecognizer class] == [UITapGestureRecognizer class]){
        return YES;
    }
    
    NSLog(@"TransactionCell: gesture invalid");

    return NO;
}

- (void)respondToSwipe:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    CGFloat progress = fabs(translation.x / CGRectGetWidth(self.frame));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
            totalTranslation = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:{
            if(translation.x < 0.){
                return;
            }
            
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
            totalTranslation.x += diffTranslation.x;
            
            [self moveViews:diffTranslation.x];
            [self updateValidView:progress];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self completeTranslation:progress];
            break;
        default:
            break;
    }
}

- (void)moveViews:(CGFloat)offsetX
{
    for(UIView *view in self.contentView.subviews){
        view.frame = CGRectOffset(view.frame, offsetX, 0);
    }
}

- (void)completeTranslation:(CGFloat)progress
{
    if(isSwipable && progress >= 0.50){
        if([_transaction isCancelable]){
            [self cancelTransaction];
        }
        else{
            if(progress < 0.75){
                if(
                   [_transaction type] == TransactionTypePayment &&
                   [[[_transaction to] userId] isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]
                   ){
                    [self acceptTransaction];
                }
                else{
                    [self didAcceptWithPaymentField];
                }
            }
            else{
                [self refuseTransaction];
            }
        }
    }
    
    totalTranslation.x = - totalTranslation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:totalTranslation.x];
    }];
}

- (void)updateValidView:(CGFloat)progress
{
    JTImageLabel *text = [[actionView subviews] objectAtIndex:0];
    
    if([_transaction isCancelable]){
        if(progress < 0.50){
            text.text = NSLocalizedString(@"TRANSACTION_ACTION_CANCEL", nil);
            text.textColor = [UIColor whiteColor];
            [text setImage:[UIImage imageNamed:@"transaction-cell-cross-white"]];
        }
        else{
            text.text = NSLocalizedString(@"TRANSACTION_ACTION_CANCEL", nil);
            text.textColor = [UIColor customRed];
            [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
        }
    }
    else{
        if(progress < 0.50){
            text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
            text.textColor = [UIColor whiteColor];
            [text setImage:[UIImage imageNamed:@"transaction-cell-check-white"]];
        }
        else if(progress < 0.75){
            text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
            text.textColor = [UIColor customGreen];
            [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
        }
        else{
            text.text = NSLocalizedString(@"TRANSACTION_ACTION_REFUSE", nil);
            text.textColor = [UIColor customRed];
            [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
        }
    }
    
    text.center = CGPointMake(text.center.x, actionView.center.y);
}

#pragma mark -

- (void)didCellTouch
{
    NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
    [_delegate didTransactionTouchAtIndex:indexPath transaction:_transaction];
}

#pragma mark - PaymentFieldDelegate

- (void)didWalletSelected{
    [self acceptTransaction:TransactionPaymentMethodWallet];
}

- (void)didCreditCardSelected{
    [self acceptTransaction:TransactionPaymentMethodCreditCard];
}

- (void)presentCreditCardController
{
    CreditCardViewController *controller = [CreditCardViewController new];
    
    [_delegate presentViewController:[[FLNavigationController alloc] initWithRootViewController:controller] animated:YES completion:NULL];
}

#pragma mark - Actions

- (void)didAcceptWithPaymentField
{
    [self showPaymentField];
    
    NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
    if(indexPath){
        [_delegate showPayementFieldAtIndex:indexPath];
    }
}

- (void)didLikeButtonTouch
{
    if([[_transaction social] isLiked] || ![[Flooz sharedInstance] currentUser]){
        return;
    }

    [[_transaction social] setIsLiked:YES];

    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success:^(id result) {
        [[_transaction social] setLikeText:[result objectForKey:@"item"]];
        [[_transaction social] setLikesCount:[[_transaction social] likesCount] + 1];
        FLSocialView *view = [[rightView subviews] objectAtIndex:2];
        [view prepareView:_transaction.social];
        
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        if(indexPath){
            [_delegate updateTransactionAtIndex:indexPath transaction:_transaction];
        }
    } failure:NULL];
}

- (void)cancelTransaction
{    
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusCanceled]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        
        if(indexPath){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [_delegate updateTransactionAtIndex:indexPath transaction:transaction];
        }
    } failure:NULL];
}

- (void)acceptTransaction
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        
        if(indexPath){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [_delegate updateTransactionAtIndex:indexPath transaction:transaction];
        }
    } failure:NULL];
}

- (void)acceptTransaction:(TransactionPaymentMethod)paymentMethod
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted],
                             @"source": [FLTransaction transactionPaymentMethodToParams:paymentMethod]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        
        if(indexPath){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [_delegate updateTransactionAtIndex:indexPath transaction:transaction];
        }
    } failure:NULL];
}

- (void)refuseTransaction
{
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusRefused]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success:^(id result) {
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        
        if(indexPath){
            FLTransaction *transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
            [_delegate updateTransactionAtIndex:indexPath transaction:transaction];
        }
    } failure:NULL];
}

- (void)showPaymentField{
    for(UIView *subview in self.contentView.subviews){
        subview.hidden = YES;
    }
    [paymentField reloadUser];
    paymentField.hidden = NO;
}

- (void)hidePaymentField{
    for(UIView *subview in self.contentView.subviews){
        subview.hidden = NO;
    }
    paymentField.hidden = YES;
}

@end
