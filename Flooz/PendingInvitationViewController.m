//
//  PendingInvitationViewController.m
//  Flooz
//
//  Created by Olivier on 12/28/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "PendingInvitationViewController.h"

@interface PendingInvitationViewController () {
    UIImageView *_headerImage;
    
    UILabel *_textExplication;
}

@end

@implementation PendingInvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat padding = 15.0f;
    CGFloat height = padding * 2;
    
    {
        _headerImage = [UIImageView imageNamed:@"code-envelope"];
        
        CGFloat scaleRatio = CGRectGetWidth(_headerImage.frame) / CGRectGetHeight(_headerImage.frame);
        
        CGRectSetWidthHeight(_headerImage.frame, CGRectGetWidth(_mainBody.frame) / 2, CGRectGetWidth(_mainBody.frame) / 2 * scaleRatio);
        CGRectSetXY(_headerImage.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(_headerImage.frame) / 2, height);
        
        [_mainBody addSubview:_headerImage];
        height += CGRectGetHeight(_headerImage.frame);
    }
    
    height += padding;
    
    {
        _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, 200)];
        _textExplication.textColor = [UIColor customGrey];
        _textExplication.font = [UIFont customTitleExtraLight:18];
        _textExplication.textAlignment = NSTextAlignmentCenter;
        _textExplication.numberOfLines = 0;
        _textExplication.text = NSLocalizedString(@"INVITATION_CODE_WAITING_EXPLICATION", nil);
        
        [_mainBody addSubview:_textExplication];
    }
    
}

@end
