//
//  EventCell.m
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EventCell.h"

#define MARGE_TOP 14.
#define MARGE_BOTTOM 14.
#define MARGE_LEFT_RIGHT 15.

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
    CGFloat rightViewWidth = SCREEN_WIDTH - (2 * MARGE_LEFT_RIGHT);
    
    CGFloat current_height = MARGE_TOP;
    
    // Header
    current_height += 22;
    
    // Details
    current_height += 9;
    
    attributedText = [[NSAttributedString alloc]
                      initWithString:[event content]
                      attributes:@{NSFontAttributeName: [UIFont customContentLight:12]}];
    rect = [attributedText boundingRectWithSize:(CGSize){rightViewWidth, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    current_height += rect.size.height;
    
    // Attachment
//    current_height += 13 + 80;
    
    // Social
    current_height += 14 + 15;
    
    current_height += MARGE_BOTTOM;
    
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
    self.backgroundColor = [UIColor customBackground];
    
    [self createSlideView];
    [self createRightViews];
}

- (void)createSlideView{
    slideView = [[UIView alloc] initWithFrame:CGRectMakeSize(2, 0)];
    slideView.backgroundColor = [UIColor customYellow];
    [self.contentView addSubview:slideView];
}

- (void)createRightViews{
    rightView = [[UIView alloc] initWithFrame:CGRectMake(MARGE_LEFT_RIGHT, MARGE_TOP, CGRectGetWidth(self.frame) - (2 * MARGE_LEFT_RIGHT), 0)];
        
    [self.contentView addSubview:rightView];
    
    [self createHeaderView];
    [self createDetailView];
    [self createAttachmentView];
    [self createSocialView];
}

- (void)createHeaderView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 22)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), CGRectGetHeight(view.frame))];
    UILabel *status = [[UILabel alloc] initWithFrame:CGRectMakeSize(0, CGRectGetHeight(view.frame))];
    
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont customTitleBook:14];
    
    status.backgroundColor = [UIColor customBackgroundStatus];
    status.textAlignment = NSTextAlignmentCenter;
    status.layer.cornerRadius = 11.;
    status.font = [UIFont customTitleBook:10];
    
    [view addSubview:title];
    [view addSubview:status];
    [rightView addSubview:view];
    
    height = CGRectGetMaxY(view.frame);
}

- (void)createDetailView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, height + 9, CGRectGetWidth(rightView.frame), 0)];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMakeSize(CGRectGetWidth(rightView.frame), 0)];
    
    content.textColor = [UIColor whiteColor];
    content.font = [UIFont customContentLight:12];
    content.numberOfLines = 0;
    
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
    height = CGRectGetMaxY(view.frame);
}

#pragma mark - Prepare Views

- (void)prepareViews{
    height = 0;
    
    [self prepareSlideView];
    
    [self prepareHeaderView];
    [self prepareDetailView];
    [self prepareAttachmentView];
    [self prepareSocialView];
    
    rightView.frame = CGRectSetHeight(rightView.frame, height);
    
    height += MARGE_TOP + MARGE_BOTTOM;
    
    slideView.frame = CGRectSetHeight(slideView.frame, height);
    self.frame = CGRectSetHeight(self.frame, height);
}

- (void)prepareSlideView{
    if([[self event] status] == EventStatusWaiting){
        slideView.hidden = NO;
    }else{
        slideView.hidden = YES;
    }
}

- (void)prepareHeaderView{
    UIView *view = [[rightView subviews] objectAtIndex:0];
    UILabel *title = [[view subviews] objectAtIndex:0];
    UILabel *status = [[view subviews] objectAtIndex:1];
    
    title.text = [[[self event] title] uppercaseString];
    [title setWidthToFit];
    
    status.text = [[self event] statusText];
    status.frame = CGRectSetX(status.frame, CGRectGetMaxX(title.frame) + 10);
    [status setWidthToFit];
    status.frame = CGRectSetWidth(status.frame, CGRectGetWidth(status.frame) + 25);
    
    UIColor *textColor = [UIColor whiteColor];
    if([[self event] status] == EventStatusAccepted){
        textColor = [UIColor customGreen];
    }else if([[self event] status] == EventStatusRefused){
        textColor = [UIColor whiteColor];
    }else{
        textColor = [UIColor customYellow];
    }
    status.textColor = textColor;
    
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareDetailView{
    UIView *view = [[rightView subviews] objectAtIndex:1];
    UILabel *content = [[view subviews] objectAtIndex:0];
    
    content.text = [[self event] content];
    [content setHeightToFit];
    
    view.frame = CGRectSetHeight(view.frame, CGRectGetHeight(content.frame));
    height = CGRectGetMaxY(view.frame);
}

- (void)prepareAttachmentView{
//    UIImageView *view = [[rightView subviews] objectAtIndex:2];
//    [view setImage:[UIImage imageNamed:@"test_attachment"]];
    
//    view.frame = CGRectSetY(view.frame, height + 13);
//    view.frame = CGRectSetHeight(view.frame, 80);
    
//    height = CGRectGetMaxY(view.frame);
}

- (void)prepareSocialView{    
    FLSocialView *view = [[rightView subviews] objectAtIndex:3];
//    [view prepareView:_e];
    view.frame = CGRectSetY(view.frame, height + 14);
    height = CGRectGetMaxY(view.frame);
}

@end
