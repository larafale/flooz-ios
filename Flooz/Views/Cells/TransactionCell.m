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
#define MARGE_LEFT_RIGHT 15.

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
    
    // Header
    current_height += 22;
    
    // Details
    current_height += 9;
    
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
    
    // Social
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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackground];
    
    [self createLeftViews];
    [self createSlideView];
    [self createRightViews];
    [self createValidViews];
    
    gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
}

- (void)createLeftViews{
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP, 60, 0)];
    
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
    
    [self createHeaderView];
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
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
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(0, 15, 37.5, 37.5)];
    [leftView addSubview:view];
}

- (void)createHeaderView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 22)];
    UILabel *type = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), CGRectGetHeight(view.frame))];
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(view.frame))];
    UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), CGRectGetHeight(view.frame))];
    
    type.textColor = [UIColor whiteColor];
    type.font = [UIFont customTitleBook:14];
    
    status.backgroundColor = [UIColor customBackgroundStatus];
    status.textAlignment = NSTextAlignmentCenter;
    status.layer.cornerRadius = 11.;
    status.font = [UIFont customTitleBook:10];
    
    amount.textColor = [UIColor customGreen];
    amount.textAlignment = NSTextAlignmentRight;
    amount.font = [UIFont customContentRegular:12];
    
    [view addSubview:amount];
    [view addSubview:type];
    [view addSubview:status];
    [rightView addSubview:view];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)createDetailView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height + 9, CGRectGetWidth(rightView.frame), 0)];
    UILabel *text = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    
    text.textColor = [UIColor whiteColor];
    text.font = [UIFont customContentRegular:13];
    text.numberOfLines = 0;
    
    content.textColor = [UIColor whiteColor];
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
    FLSocialView *view = [[FLSocialView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 15)];
    [rightView addSubview:view];
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareAvatarView];
    [self prepareSlideView];
    
    [self prepareHeaderView];
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareSocialView];
    
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
    if([[self transaction] status] == TransactionStatusPending){
        slideView.hidden = NO;
    }else{
        slideView.hidden = YES;
    }
}

- (void)prepareHeaderView{
    UIView *view = [[rightView subviews] objectAtIndex:0];
    UILabel *type = [[view subviews] objectAtIndex:1];
    UILabel *status = [[view subviews] objectAtIndex:2];
    UILabel *amount = [[view subviews] objectAtIndex:0];
    
    type.text = [[self transaction] typeText];
    [type setWidthToFit];
    
    status.text = [[self transaction] statusText];
    status.frame = CGRectSetX(status.frame, CGRectGetMaxX(type.frame) + 10);
    [status setWidthToFit];
    status.frame = CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 25);
    
    amount.text = [FLHelper formatedAmount:[[self transaction] amount]];
    amount.frame = CGRectSetX(amount.frame, CGRectGetMaxX(status.frame));
    amount.frame = CGRectSetWidth(amount.frame, CGRectGetWidth(view.frame) - CGRectGetMaxX(status.frame));
    
    UIColor *textColor = [UIColor whiteColor];
    
    switch ([[self transaction] status]) {
        case TransactionStatusAccepted:
            textColor = [UIColor customGreen];
            break;
        case TransactionStatusPending:
            textColor = [UIColor customYellow];
            break;
        case TransactionStatusRefused:
        case TransactionStatusCanceled:
        case TransactionStatusExpired:
            textColor = [UIColor whiteColor];
            break;
    }
    
    status.textColor = textColor;
    amount.textColor = textColor;
    
    amount.hidden = (amount.text == nil);
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareDetailView{
    UIView *view = [[rightView subviews] objectAtIndex:1];

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
    
    view.frame = CGRectSetHeight(view.frame, CGRectGetHeight(text.frame) + CGRectGetHeight(content.frame) + offset);
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    UIImageView *view = [[rightView subviews] objectAtIndex:2];
    
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
    FLSocialView *view = [[rightView subviews] objectAtIndex:3];
    [view prepareView:_transaction.social];
    view.frame = CGRectSetY(view.frame, height + 14);
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Swipe

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    // WARNING
    if([gestureRecognizer class] != [UIPanGestureRecognizer class]){
        NSLog(@"class respond to swipe invalid");
        return NO;
    }
    
    if(_transaction.status != TransactionStatusPending){
        return NO;
    }
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    if(translation.x > 0.){
        return YES;
    }
    
    return NO;
}

- (void)respondToSwipe:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    CGFloat progress = fabs(translation.x / CGRectGetWidth(self.frame));
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            lastTranslation = CGPointZero;
            break;
        case UIGestureRecognizerStateChanged:{
            if(translation.x < 0.){
                return;
            }
            
            CGPoint diffTranslation = translation;
            diffTranslation.x -= lastTranslation.x;
            lastTranslation = translation;
            
            [self moveViews:diffTranslation.x];
            [self updateValidView:progress];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self completeTranslation:translation];
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

- (void)completeTranslation:(CGPoint)translation
{
    translation.x = - translation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:translation.x];
    }];
}

- (void)updateValidView:(CGFloat)progress
{
    JTImageLabel *text = [[validView subviews] objectAtIndex:0];
    
    if(progress < 0.33){
        text.text = NSLocalizedString(@"TRANSACTION_CELL_ACCEPT", nil);
        text.textColor = [UIColor whiteColor];
        [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
    }
    else if(progress < 0.66){
        text.text = NSLocalizedString(@"TRANSACTION_CELL_ACCEPT", nil);
        text.textColor = [UIColor customGreen];
        [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
    }
    else{
        text.text = NSLocalizedString(@"TRANSACTION_CELL_REFUSE", nil);
        text.textColor = [UIColor customRed];
        [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
    }
    
    text.center = CGPointMake(text.center.x, validView.center.y);
}

@end
