//
//  FLAccountUserView.m
//  Flooz
//
//  Created by olivier on 1/23/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLAccountUserView.h"
#import "FLPopupInformation.h"

@implementation FLAccountUserView {
	UILabel *_numberFlooz;
	UILabel *_numberFriends;
	UILabel *_percentComplete;

	UIButton *_wallet;
	CGFloat _widthAvalaible;
}


- (id)initWithWidth:(CGFloat)width {
	self = [super initWithFrame:CGRectMakeSize(PPScreenWidth(), 225.0f)];
	if (self) {
		_widthAvalaible = width;
		[self commonInit];
		[self reloadData];
	}
	return self;
}

- (void)commonInit {
	{
		CGFloat size = 70.0;
        userView = [[FLUserView alloc] initWithFrame:CGRectMake((_widthAvalaible - size) / 2., 30.0f, size, size)];
        [userView setUserInteractionEnabled:YES];
		[self addSubview:userView];
	}

	{
		fullname = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userView.frame) + 5.0f, _widthAvalaible, 17)];

		fullname.font = [UIFont customTitleExtraLight:18];
		fullname.textAlignment = NSTextAlignmentCenter;
        fullname.textColor = [UIColor whiteColor];
        [fullname setUserInteractionEnabled:YES];

		[self addSubview:fullname];
	}

	{
		username = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(fullname.frame), _widthAvalaible, 20)];

		username.font = [UIFont customContentLight:13];
		username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor whiteColor];
        [username setUserInteractionEnabled:YES];

		[self addSubview:username];
	}

    // Masqué pour le lancement
//	CGFloat xView = 0.0f;
//	CGFloat width = _widthAvalaible / 3.0f;
//	CGFloat height = 30.0f;
//	{
//		_numberFlooz = [self prepareInfoWithTitle:@"Flooz" xStart:xView width:width height:height];
//
//		xView += _widthAvalaible / 3.0f;
//		_numberFriends = [self prepareInfoWithTitle:@"Amis" xStart:xView width:width height:height];
//
//		xView += _widthAvalaible / 3.0f;
//		_percentComplete = [self prepareInfoWithTitle:@"Complet" xStart:xView width:width height:height];
//	}

	{
		CGFloat size = 90.0f;
		_wallet = [UIButton newWithFrame:CGRectMake((_widthAvalaible - size) / 2.0f, CGRectGetMaxY(username.frame) + 15.0f, size, 30.0f)];

		[_wallet.layer setBorderWidth:1.0f];
		[_wallet.layer setBorderColor:[UIColor whiteColor].CGColor];
		[_wallet.layer setCornerRadius:4.0f];

		_wallet.titleLabel.font = [UIFont customTitleLight:15];
		_wallet.titleLabel.textAlignment = NSTextAlignmentCenter;
		_wallet.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 2.0f, 0.0f);
        
        [_wallet addTarget:self action:@selector(showWalletMessage) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_wallet];
	}
}

- (void)showWalletMessage {
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
}

- (UILabel *)prepareInfoWithTitle:(NSString *)title xStart:(CGFloat)xView width:(CGFloat)width height:(CGFloat)height {
	UIView *vFlooz = [UIView newWithFrame:CGRectMake(xView, CGRectGetMaxY(username.frame) + 10.0f, width, height)];
	[self addSubview:vFlooz];

	UILabel *topLabel = [UILabel newWithFrame:CGRectMake(0.0f, 0.0f, width, height / 2.0f)];
	[topLabel setTextColor:[UIColor whiteColor]];
	[topLabel setFont:[UIFont customTitleBook:12]];
	[topLabel setTextAlignment:NSTextAlignmentCenter];
	[topLabel setText:@"0"];
	[vFlooz addSubview:topLabel];

	UILabel *label = [UILabel newWithFrame:CGRectMake(0.0f, CGRectGetMaxY(topLabel.frame), width, height / 2.0f)];
	[label setTextColor:[UIColor whiteColor]];
	[label setFont:[UIFont customTitleLight:15]];
	[label setTextAlignment:NSTextAlignmentCenter];
	[label setText:title];
	[vFlooz addSubview:label];

	return topLabel;
}

- (void)reloadData {
	user = [[Flooz sharedInstance] currentUser];

	fullname.text = [user.fullname uppercaseString];
	if (user.username) {
		username.text = [@"@" stringByAppendingString : user.username];
	}
	[userView setImageFromUser:user];

	[_numberFlooz setText:[user.transactionsCount stringValue]];
	[_numberFriends setText:[user.friendsCount stringValue]];
	[_percentComplete setText:user.profileCompletion];
	[_wallet setTitle:[FLHelper formatedAmount:user.amount withSymbol:NO] forState:UIControlStateNormal];
}

- (void)reloadAvatarWithImageData:(NSData *)imageData {
    [userView setImageFromData:imageData];
}

- (void)addEditTarget:(id)target action:(SEL)action {
	UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
	gesture.numberOfTapsRequired = 1;
    [userView addGestureRecognizer:gesture];
}

@end
