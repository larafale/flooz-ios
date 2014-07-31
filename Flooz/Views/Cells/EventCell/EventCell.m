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
    CGFloat current_height = MARGE_TOP_BOTTOM;
    
    // Details
    current_height += 9 + 28 + 16;
    current_height += [EventAmountView getHeightForEvent:event];
    
    // Attachment
    if([event attachmentThumbURL]){
        current_height += 80 + 14;
    }
    
    // Social
    current_height += [FLSocialView getHeight:event.social];
    
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
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor]; // WARNING
    
    [self createRightViews];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP_BOTTOM, CGRectGetWidth(self.frame) - MARGE_LEFT_RIGHT - MARGE_LEFT_RIGHT, 0)];
    
    [self.contentView addSubview:rightView];
    
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
//    [self createScopeView];
}

- (void)createDetailView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height + 9, CGRectGetWidth(rightView.frame), 28 + 16 + 63)];
    
    {
        FLUserView *userView = [[FLUserView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [view addSubview:userView];
    }
    
    {
        UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(37, -2, CGRectGetWidth(view.frame) - 37, 14)];
        text.textColor = [UIColor whiteColor];
        text.font = [UIFont customContentRegular:13];
        
        [view addSubview:text];
    }
    
    {
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(37, 15, CGRectGetWidth(view.frame) - 37, 14)];
        
        content.textColor = [UIColor customPlaceholder];
        content.font = [UIFont customContentLight:12];
        
        [view addSubview:content];
    }
    
    {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMakeSize(6, 6)];
        CGRectSetY(dot.frame, 1.5);
        dot.backgroundColor = [UIColor customBlue];
        dot.layer.cornerRadius = CGRectGetHeight(dot.frame) / 2.;
        
        [view addSubview:dot];
    }
    
    {
        EventAmountView *amountView = [[EventAmountView alloc] initWithFrame:CGRectMake(0, 28 + 16, CGRectGetWidth(view.frame), 0)];
        [amountView hideBottomBar];
        [view addSubview:amountView];
    }
    
    {
        UIImageView *image = [UIImageView imageNamed:@"arrow-white-right"];
        CGRectSetXY(image.frame, CGRectGetWidth(rightView.frame), 5);
        [view addSubview:image];
    }
    
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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCellTouch)];
    tapGesture.delegate = self;
    [tapGesture requireGestureRecognizerToFail:[view gesture]];
    [self addGestureRecognizer:tapGesture];
}

- (void)createScopeView
{
    JTImageLabel *view = [[JTImageLabel alloc] initWithFrame:CGRectMake(0, 0, 0, 15)];
    
    view.textAlignment = NSTextAlignmentRight;
    view.textColor = [UIColor customPlaceholder];
    view.font = [UIFont customContentLight:11];
    
    [view setImageOffset:CGPointMake(-4, -1)];
    
    [rightView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareSocialView];
//    [self prepareScopeView];
    
    CGRectSetHeight(rightView.frame, height);
    
    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    CGRectSetHeight(self.frame, height);
}

- (void)prepareDetailView{
    UIView *view = [[rightView subviews] objectAtIndex:0];
    
    FLUserView *userView = [[view subviews] objectAtIndex:0];
    UILabel *text = [[view subviews] objectAtIndex:1];
    UILabel *content = [[view subviews] objectAtIndex:2];
    UIView *dot = [[view subviews] objectAtIndex:3];
    EventAmountView *amountView = [[view subviews] objectAtIndex:4];
    
    {
        NSMutableAttributedString *attributedContent = [NSMutableAttributedString new];
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:NSLocalizedString(@"EVENT_START_BY", nil)
                                                  attributes:nil];
            
            [attributedContent appendAttributedString:attributedText];
        }
        
        {
            NSAttributedString *attributedText = [[NSAttributedString alloc]
                                                  initWithString:[NSString stringWithFormat:@"@%@", [[_event creator] username]]
                                                  attributes:@{
                                                               NSFontAttributeName: [UIFont customContentRegular:12]
                                                               }];
            
            [attributedContent appendAttributedString:attributedText];
        }
        
        content.attributedText = attributedContent;
    }
    
    
    [userView setImageFromUser:[_event creator]];
    text.text = [_event title];
    amountView.event = _event;
    
//    dot.hidden = !_event.isNew;
    dot.hidden = YES;
    
    [text setWidthToFit];
    CGRectSetX(dot.frame, CGRectGetMaxX(text.frame) + 7);
    CGRectSetHeight(view.frame, CGRectGetMaxY(amountView.frame));
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
    FLImageView *view = [[rightView subviews] objectAtIndex:1];
    
    if([_event attachmentThumbURL]){
        CGRectSetY(view.frame, height);
        CGRectSetHeight(view.frame, 80);
        height = CGRectGetMaxY(view.frame) + 14;
        
        [view setImageWithURL:[NSURL URLWithString:[_event attachmentThumbURL]] fullScreenURL:[NSURL URLWithString:[_event attachmentURL]]];
    }
    else{
        CGRectSetHeight(view.frame, 0);
    }
}

- (void)prepareSocialView{
    FLSocialView *view = [[rightView subviews] objectAtIndex:2];
    [view prepareView:_event.social];
    
    CGRectSetY(view.frame, height);
    
    height = CGRectGetMaxY(view.frame); // pck comment prepareScopeView
}

- (void)prepareScopeView{
    JTImageLabel *view = [[rightView subviews] objectAtIndex:3];
    
    if([_event scope] == TransactionScopeFriend){
        [view setImage:[UIImage imageNamed:@"scope-friend"]];
        view.text = NSLocalizedString(@"EVENT_SCOPE_FRIEND", nil);
    }
    else{
        [view setImage:[UIImage imageNamed:@"scope-invite"]];
        view.text = NSLocalizedString(@"EVENT_SCOPE_PRIVATE", nil);
    }
    
    [view setWidthToFit];
    CGRectSetX(view.frame, CGRectGetWidth(rightView.frame) - CGRectGetWidth(view.frame));
    
    CGRectSetY(view.frame, height);
    height = CGRectGetMaxY(view.frame);
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
    [[_event social] setIsLiked:![[_event social] isLiked]];
    [[Flooz sharedInstance] createLikeOnEvent:_event success:^(id result) {
        [[_event social] setLikeText:[result objectForKey:@"item"]];

        FLSocialView *view = [[rightView subviews] objectAtIndex:2];
        [view prepareView:_event.social];
        
        NSIndexPath *indexPath = [[_delegate tableView] indexPathForCell:self];
        if(indexPath){
            [_delegate updateEventAtIndex:indexPath event:_event];
        }
    } failure:NULL];
}

@end
