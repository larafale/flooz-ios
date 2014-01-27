//
//  FLNewTransactionBar.m
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLNewTransactionBar.h"

@implementation FLNewTransactionBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 37)];
    if (self) {
        self.backgroundColor = [UIColor customBackgroundHeader];
        
        [self createLocalizeButton];
        [self createImageButton];
        [self createFacebookButton];
        [self createSeparator];
        [self createPrivacyButton];
    }
    return self;
}

- (void)createLocalizeButton
{
    localizeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize"] forState:UIControlStateNormal];
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateSelected];
    [localizeButton setImage:[UIImage imageNamed:@"new-transaction-bar-localize-selected"] forState:UIControlStateHighlighted];
    
    [self addSubview:localizeButton];
}

- (void)createImageButton
{
    imageButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(localizeButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image"] forState:UIControlStateNormal];
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image-selected"] forState:UIControlStateSelected];
    [imageButton setImage:[UIImage imageNamed:@"new-transaction-bar-image-selected"] forState:UIControlStateHighlighted];
    
    [self addSubview:imageButton];
}

- (void)createFacebookButton
{
    facebookButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook"] forState:UIControlStateNormal];
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook-selected"] forState:UIControlStateSelected];
    [facebookButton setImage:[UIImage imageNamed:@"new-transaction-bar-facebook-selected"] forState:UIControlStateHighlighted];
    
    [self addSubview:facebookButton];
}

- (void)createSeparator
{
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame), 0, 1, CGRectGetHeight(self.frame))];
    
    separator.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:separator];
}

- (void)createPrivacyButton
{
    privacyButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(facebookButton.frame), 0, CGRectGetWidth(self.frame) / 4., CGRectGetHeight(self.frame))];
    
    [privacyButton setImage:[UIImage imageNamed:@"arrow-blue-down"] forState:UIControlStateNormal];
    
    privacyButton.imageEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    privacyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, [privacyButton imageForState:UIControlStateNormal].size.width);
    
    [privacyButton setTitle:@"Public" forState:UIControlStateNormal];
    [privacyButton setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
    privacyButton.titleLabel.font = [UIFont customContentRegular:12];
    
    [self addSubview:privacyButton];
}

@end
