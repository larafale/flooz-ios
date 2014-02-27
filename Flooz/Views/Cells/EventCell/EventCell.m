//
//  EventCell.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventCell.h"

#define MARGE_TOP_BOTTOM 14.
#define MARGE_LEFT_RIGHT 25.

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForEvent:(FLEvent *)event{
    NSAttributedString *attributedText = nil;
    CGRect rect = CGRectZero;
    CGFloat rightViewWidth = SCREEN_WIDTH - MARGE_LEFT_RIGHT - MARGE_LEFT_RIGHT;
    
    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    
    if([event title] && ![[event title] isBlank]){
        attributedText = [[NSAttributedString alloc]
                          initWithString:[event title]
                          attributes:@{NSFontAttributeName: [UIFont customContentRegular:13]}];
        rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        current_height += rect.size.height;
    }
    
    if([event content] && ![[event content] isBlank]){
        if([event title] && ![[event title] isBlank]){
            current_height += 4;
        }
        
        attributedText = [[NSAttributedString alloc]
                          initWithString:[event content]
                          attributes:@{NSFontAttributeName: [UIFont customContentLight:12]}];
        rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                            context:nil];
        current_height += rect.size.height;
    }
    
    
    // Attachment
    if([event attachmentThumbURL]){
        current_height += 13 + 80;
    }
    
    // Social
    current_height += 14 + 15;
    
    current_height += MARGE_TOP_BOTTOM;
    
    return current_height;
}

- (void)setEvent:(FLEvent *)event{
    self->_event = event;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews{
    height = 0;
    isSwipable = NO;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor]; // WARNING
    
    [self createSlideView];
    [self createRightViews];
    [self createActionViews];
}

- (void)createSlideView{
    slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, 0)];
    slideView.backgroundColor = [UIColor customYellow];
    
    [self.contentView addSubview:slideView];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(self.frame) - MARGE_LEFT_RIGHT - MARGE_LEFT_RIGHT, 0)];
    
    [self.contentView addSubview:rightView];
    
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
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
        
        [actionView addSubview:text];
    }
    
    {
        FLSocialView *socialView = [[rightView subviews] objectAtIndex:2];
        
        UIPanGestureRecognizer *swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(respondToSwipe:)];
        swipeGesture.delegate = self;
        [swipeGesture requireGestureRecognizerToFail:[socialView gesture]];
        [self addGestureRecognizer:swipeGesture];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCellTouch)];
        tapGesture.delegate = self;
        [tapGesture requireGestureRecognizerToFail:swipeGesture];
        [self addGestureRecognizer:tapGesture];
    }
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
    [view addTargetForLike:self action:@selector(didLikeButtonTouch)];
    [rightView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
//    isSwipable = [_transaction isCancelable] || [_transaction isAcceptable];
    
    [self prepareSlideView];
    
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareSocialView];
    
    rightView.frame = CGRectSetHeight(rightView.frame, height);
    
    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    slideView.frame = CGRectSetHeight(slideView.frame, height);
    actionView.frame = CGRectSetHeight(actionView.frame, height);
    self.frame = CGRectSetHeight(self.frame, height);
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
    
    text.text = [_event title];
    [text setHeightToFit];
    
    CGFloat offset = 0.;
    if([_event title] && [_event content]){
        offset = 4.;
    }
    
    content.text = [_event content];
    content.frame = CGRectSetY(content.frame, CGRectGetMaxY(text.frame) + offset);
    [content setHeightToFit];
    
    view.frame = CGRectSetY(view.frame, height);
    view.frame = CGRectSetHeight(view.frame, CGRectGetHeight(text.frame) + CGRectGetHeight(content.frame) + offset);
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    UIImageView *view = [[rightView subviews] objectAtIndex:1];
    
    if([_event attachmentThumbURL]){
        [view setImageWithURL:[NSURL URLWithString:[_event attachmentThumbURL]]];
        
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
    [view prepareView:_event.social];
    view.frame = CGRectSetY(view.frame, height + 14);
    
    height = CGRectGetMaxY(view.frame);
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
    
    NSLog(@"EventCell: gesture invalid");
    
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
//    if(isSwipable && progress >= 0.50){
//        if([_event isCancelable]){
//            [self cancelTransaction];
//        }
//        else{
//            if(progress < 0.75){
//                [self acceptTransaction];
//            }
//            else{
//                [self refuseTransaction];
//            }
//        }
//    }
    
    totalTranslation.x = - totalTranslation.x;
    
    [UIView animateWithDuration:.3 animations:^{
        [self moveViews:totalTranslation.x];
    }];
}

- (void)updateValidView:(CGFloat)progress
{
    JTImageLabel *text = [[actionView subviews] objectAtIndex:0];
//    
//    if([_event isCancelable]){
//        if(progress < 0.50){
//            text.text = NSLocalizedString(@"TRANSACTION_ACTION_CANCEL", nil);
//            text.textColor = [UIColor whiteColor];
//            [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
//        }
//        else{
//            text.text = NSLocalizedString(@"TRANSACTION_ACTION_CANCEL", nil);
//            text.textColor = [UIColor customRed];
//            [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
//        }
//    }
//    else{
//        if(progress < 0.50){
//            text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
//            text.textColor = [UIColor whiteColor];
//            [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
//        }
//        else if(progress < 0.75){
//            text.text = NSLocalizedString(@"TRANSACTION_ACTION_ACCEPT", nil);
//            text.textColor = [UIColor customGreen];
//            [text setImage:[UIImage imageNamed:@"transaction-cell-check"]];
//        }
//        else{
//            text.text = NSLocalizedString(@"TRANSACTION_ACTION_REFUSE", nil);
//            text.textColor = [UIColor customRed];
//            [text setImage:[UIImage imageNamed:@"transaction-cell-cross"]];
//        }
//    }
    
    text.center = CGPointMake(text.center.x, actionView.center.y);
}

#pragma mark -

- (void)didCellTouch
{
    NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
    [_delegate didEventTouchAtIndex:indexPath event:_event];
}

#pragma mark - Actions

- (void)didLikeButtonTouch
{
    if([[_event social] isLiked]){
        return;
    }
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createLikeOnEvent:_event success:^(id result) {
        [[_event social] setIsLiked:YES];
        
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        if(indexPath){
            [_delegate updateEventAtIndex:indexPath event:_event];
        }
    } failure:NULL];
}

@end
