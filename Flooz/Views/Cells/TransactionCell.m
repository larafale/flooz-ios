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
    
    attributedText = [[NSAttributedString alloc]
                                          initWithString:[transaction text]
                                          attributes:@{NSFontAttributeName: [UIFont customContentRegular:13]}];
    rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    current_height += rect.size.height;

    current_height += 4;
    
    attributedText = [[NSAttributedString alloc]
                      initWithString:[transaction content]
                      attributes:@{NSFontAttributeName: [UIFont customContentLight:12]}];
    rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    current_height += rect.size.height;

    // Attachment
    current_height += 13 + 80;
    
    // Social
    current_height += 14 + 15;
    
    current_height += MARGE_BOTTOM;
    
    return current_height;
}

+ (CGFloat)getEstimatedHeight{
    return 220;
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
    
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToPanGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
}

- (void)createLeftViews{
    leftView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP, 60, 0)];
    
    [self addSubview:leftView];
    
    [self createAvatarView];
}

- (void)createSlideView{
    slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, 0)];
    slideView.backgroundColor = [UIColor customYellow];
    [self addSubview:slideView];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame), MARGE_TOP, CGRectGetWidth(self.frame) - CGRectGetMaxX(leftView.frame) - MARGE_LEFT_RIGHT, 0)];
    
    [self addSubview:rightView];
    
    [self createHeaderView];
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
}

- (void)createAvatarView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(leftView.frame), 0)];
    
    UIImageView *filter = [UIImageView imageNamed:@"avatar_filter"];
    filter.frame = CGRectMakeSetXY(filter.frame, 0, 15);
    
    UIImageView *avatar = [[UIImageView alloc] initWithFrame:filter.frame];
    
    [view addSubview:avatar];
    [view addSubview:filter];
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
    CellSocialView *view = [[CellSocialView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 15)];
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
    
    leftView.frame = CGRectMakeSetHeight(leftView.frame, height);
    rightView.frame = CGRectMakeSetHeight(rightView.frame, height);
    
    height += MARGE_TOP + MARGE_BOTTOM;
    
    slideView.frame = CGRectMakeSetHeight(slideView.frame, height);
    self.frame = CGRectMakeSetHeight(self.frame, height);
}

- (void)prepareAvatarView{
    UIView *view = [[leftView subviews] objectAtIndex:0];
    UIImageView *avatar = [[view subviews] objectAtIndex:0];
    
    avatar.image = [UIImage imageNamed:@"test_user1"];
}

- (void)prepareSlideView{
    if([[self transaction] status] == TransactionStatusWaiting){
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
    [type setWidth];
    
    status.text = [[self transaction] statusText];
    status.frame = CGRectMakeSetX(status.frame, CGRectGetMaxX(type.frame) + 10);
    [status setWidth];
    status.frame = CGRectMakeSetWidth(status.frame, CGRectGetWidth(status.frame) + 25);
    
    amount.text = [[self transaction] amountText];
    amount.frame = CGRectMakeSetX(amount.frame, CGRectGetMaxX(status.frame));
    amount.frame = CGRectMakeSetWidth(amount.frame, CGRectGetWidth(view.frame) - CGRectGetMaxX(status.frame));
    
    UIColor *textColor = [UIColor whiteColor];
    if([[self transaction] status] == TransactionStatusAccepted){
        textColor = [UIColor customGreen];
    }else if([[self transaction] status] == TransactionStatusRefused){
        textColor = [UIColor whiteColor];
    }else{
        textColor = [UIColor customYellow];
    }
    status.textColor = textColor;
    amount.textColor = textColor;
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareDetailView{
    UIView *view = [[rightView subviews] objectAtIndex:1];
    UILabel *text = [[view subviews] objectAtIndex:0];
    UILabel *content = [[view subviews] objectAtIndex:1];
    
    text.text = [[self transaction] text];
    [text setHeight];
    
    content.text = [[self transaction] content];
    content.frame = CGRectMakeSetY(content.frame, CGRectGetMaxY(text.frame) + 4);
    [content setHeight];
    
    view.frame = CGRectMakeSetHeight(view.frame, CGRectGetHeight(text.frame) + CGRectGetHeight(content.frame) + 4);
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    UIImageView *view = [[rightView subviews] objectAtIndex:2];
    [view setImage:[UIImage imageNamed:@"test_attachment"]];
    
    view.frame = CGRectMakeSetY(view.frame, height + 13);
    view.frame = CGRectMakeSetHeight(view.frame, 80);
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareSocialView{
    CellSocialView *view = [[rightView subviews] objectAtIndex:3];
    [view prepareView];
    view.frame = CGRectMakeSetY(view.frame, height + 14);
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Swipe

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self];
    if(translation.x > 0.){
        return YES;
    }
    
    return NO;
}

- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:self];
    
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
            
            [self moveViews:diffTranslation];
            break;
        }
        case UIGestureRecognizerStateEnded:
            [self completeTranslation:translation];
            break;
        default:
            break;
    }
}

- (void)moveViews:(CGPoint)offset
{
    for(UIView *view in [self subviews]){
        view.frame = CGRectOffset(view.frame, offset.x, 0);
    }
}

- (void)completeTranslation:(CGPoint)translation
{
    translation.x = - translation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:translation];
    }];
}

@end
