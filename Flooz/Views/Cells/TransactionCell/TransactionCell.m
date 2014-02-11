//
//  TransactionCell.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "TransactionCell.h"

#define MARGE_TOP 14.
#define MARGE_BOTTOM 14.
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
    
    CGFloat current_height = MARGE_TOP;
    
    // Details
    
    if([transaction text]){
        attributedText = [[NSAttributedString alloc]
                          initWithString:[transaction text]
                          attributes:@{NSFontAttributeName: [UIFont customContentRegular:13]}];
        rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        current_height += rect.size.height;
    }
    
    if([transaction why] && ![[transaction why] isBlank]){
        if([transaction text]){
            current_height += 4;
        }
        
        attributedText = [[NSAttributedString alloc]
                          initWithString:[transaction why]
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
    
    current_height += MARGE_BOTTOM;
    
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
    [self createValidViews];
    
    UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
    swipeGesture.delegate = self;
    [self addGestureRecognizer:swipeGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCellTouch)];
    tapGesture.delegate = self;
    [tapGesture requireGestureRecognizerToFail:swipeGesture];
    [self addGestureRecognizer:tapGesture];
}

- (void)createLeftViews{
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP, 50, 0)];
    
    [self.contentView addSubview:leftView];
    
    [self createAvatarView];
}

- (void)createSlideView{
    slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, 0)];
    slideView.backgroundColor = [UIColor customYellow];
    
    [self.contentView addSubview:slideView];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), MARGE_TOP, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftView.frame) - MARGE_LEFT_RIGHT, 0)];
    
    [self.contentView addSubview:rightView];
    
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
    [self createFooterView];
}

- (void)createValidViews{
    validView = [[UIView alloc] initWithFrame:CGRectMake(- CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    
    validView.backgroundColor = [UIColor customBackgroundHeader];
    
    [self.contentView addSubview:validView];
    
    JTImageLabel *text = [[JTImageLabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(validView.frame) - 30, CGRectGetHeight(validView.frame))];
    
    [text setImageOffset:CGPointMake(-10, 0)];
    text.textAlignment = NSTextAlignmentRight;
    
    [validView addSubview:text];
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
    content.font = [UIFont customContentLight:12];
    content.numberOfLines = 0;
    
    [view addSubview:text];
    [view addSubview:content];
    [rightView addSubview:view];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)createAttachmentView{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(rightView.frame), 0)];
    [rightView addSubview:view];
}

- (void)createSocialView{
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    [rightView addSubview:view];
}

- (void)createFooterView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 22)];
    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 0, CGRectGetHeight(view.frame))];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 8, 9, 5)];
        
    amount.textColor = [UIColor whiteColor];
    amount.textAlignment = NSTextAlignmentCenter;
    amount.font = [UIFont customContentRegular:12];
    
    [view addSubview:amount];
    [view addSubview:imageView];
    [rightView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    isSwipable = [_transaction isCancelable] || [_transaction isAcceptable];
        
    [self prepareAvatarView];
    [self prepareSlideView];
    
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareSocialView];
    [self prepareFooterView];
    
    leftView.frame = CGRectSetHeight(leftView.frame, height);
    rightView.frame = CGRectSetHeight(rightView.frame, height);
    
    height += MARGE_TOP + MARGE_BOTTOM;
    
    slideView.frame = CGRectSetHeight(slideView.frame, height);
    validView.frame = CGRectSetHeight(validView.frame, height);
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareAvatarView{
    FLUserView *view = [[leftView subviews] objectAtIndex:0];
    [view setImageFromURL:_transaction.avatarURL];
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
    
    text.text = [[self transaction] text];
    [text setHeightToFit];

    CGFloat offset = 0.;
    if([[self transaction] text] && [[self transaction] why]){
        offset = 4.;
    }
    
    content.text = [[self transaction] why];
    content.frame = CGRectSetY(content.frame, CGRectGetMaxY(text.frame) + offset);
    [content setHeightToFit];
    
    view.frame = CGRectSetY(view.frame, height);
    view.frame = CGRectSetHeight(view.frame, CGRectGetHeight(text.frame) + CGRectGetHeight(content.frame) + offset);
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    UIImageView *view = [[rightView subviews] objectAtIndex:1];
    
    if([_transaction attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_transaction attachmentThumbURL]]];
        
        view.frame = CGRectSetY(view.frame, height + 13);
        view.frame = CGRectSetHeight(view.frame, 80);
        height = CGRectGetMaxY(view.frame);
    }
    else{
        view.frame = CGRectSetHeight(view.frame, 0);
    }
}

- (void)prepareSocialView{
    FLSocialView *view = [[rightView subviews] objectAtIndex:2];
    [view prepareView:_transaction.social];
    view.frame = CGRectSetY(view.frame, height + 14);

    height = CGRectGetMaxY(view.frame);
}

- (void)prepareFooterView{
    UIView *view = [[rightView subviews] objectAtIndex:3];
    UILabel *amount = [[view subviews] objectAtIndex:0];
    UIImageView *imageView = [[view subviews] objectAtIndex:1];
    
    if(![_transaction isPrivate]){
        view.hidden = YES;
        return;
    }
    view.hidden = NO;
    
    amount.text = [FLHelper formatedAmount:[_transaction amount] withCurrency:NO];
    [amount setWidthToFit];
    
    imageView.frame = CGRectSetX(imageView.frame, CGRectGetMaxX(amount.frame) + 5);
    view.frame = CGRectSetWidth(view.frame, CGRectGetMaxX(imageView.frame) + 10);
    view.frame = CGRectSetX(view.frame, CGRectGetWidth(rightView.frame) - CGRectGetWidth(view.frame));
    
    NSString *image;
    
    switch ([[self transaction] status]) {
        case TransactionStatusAccepted:
            image = @"transaction-cell-status-accepted";
            break;
        case TransactionStatusPending:
            image = @"transaction-cell-status-pending";
            break;
        case TransactionStatusRefused:
        case TransactionStatusCanceled:
        case TransactionStatusExpired:
            image = @"transaction-cell-status-refused";
            break;
    }
    
    [imageView setImage:[UIImage imageNamed:image]];
    
    
    UIView *socialView = [[rightView subviews] objectAtIndex:2];
    view.frame = CGRectSetY(view.frame,  socialView.frame.origin.y - 4);
}

#pragma mark - Swipe

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
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
            [self completeTranslation];
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

- (void)completeTranslation
{
    totalTranslation.x = - totalTranslation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:totalTranslation.x];
    }];
}

- (void)updateValidView:(CGFloat)progress
{
    JTImageLabel *text = [[validView subviews] objectAtIndex:0];
    
    if(progress < 0.50){
        text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
        text.textColor = [UIColor whiteColor];
        [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
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
    
    text.center = CGPointMake(text.center.x, validView.center.y);
}

- (void)didCellTouch
{
    [_delegate didTransactionTouch:_transaction];
}

@end
