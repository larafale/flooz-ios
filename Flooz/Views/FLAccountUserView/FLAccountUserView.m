//
//  FLAccountUserView.m
//  Flooz
//
//  Created by Olivier on 1/23/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLAccountUserView.h"
#import "FLPopupInformation.h"

@implementation FLAccountUserView {
	UILabel *_numberFlooz;
	UILabel *_numberFriends;
	UILabel *_percentComplete;

	UIButton *_wallet;
    UIImage *shadowImage;
}

- (id)initWithShadow:(UIImage *)shadow {
	self = [super initWithFrame:CGRectMakeSize(PPScreenWidth(), 225.0f)];
	if (self) {
        shadowImage = shadow;
        [self setBackgroundColor:[UIColor customBackgroundHeader]];
		[self commonInit];
		[self reloadData];
	}
	return self;
}

- (void)commonInit {

//	{
//		username = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 20)];
//
//		username.font = [UIFont customContentLight:15];
//		username.textAlignment = NSTextAlignmentCenter;
//        username.textColor = [UIColor whiteColor];
//
//		[self addSubview:username];
//	}

    {
        CGFloat size = 50.0;
        userView = [[FLUserView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - size / 2, 10, size, size)];
        [userView setUserInteractionEnabled:YES];
        [self addSubview:userView];
    }

	{
		_wallet = [UIButton newWithFrame:CGRectMake(0, CGRectGetMaxY(userView.frame) + 10, PPScreenWidth(), 35.0f)];

//		[_wallet.layer setBorderWidth:1.0f];
//		[_wallet.layer setBorderColor:[UIColor whiteColor].CGColor];
		[_wallet.layer setCornerRadius:4.0f];
        [_wallet setBackgroundColor:[UIColor customBackground]];

		_wallet.titleLabel.font = [UIFont customTitleExtraLight:18];
		_wallet.titleLabel.textAlignment = NSTextAlignmentCenter;
		_wallet.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 0.0f, 2.0f, 0.0f);
        
        [_wallet addTarget:self action:@selector(showWalletMessage) forControlEvents:UIControlEventTouchUpInside];

		[self addSubview:_wallet];
	}
    
    CGRectSetHeight(self.frame, CGRectGetMaxY(_wallet.frame) - CGRectGetHeight(_wallet.frame) / 2);

    self.layer.shadowOpacity = .3;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowRadius = 1;
    self.clipsToBounds = NO;
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
	[_wallet setTitle:[NSString stringWithFormat:@"Solde %@", [FLHelper formatedAmount:user.amount withSymbol:NO]] forState:UIControlStateNormal];
    
    CGRectSetWidth(_wallet.frame, [_wallet.titleLabel.text widthOfString:_wallet.titleLabel.font] + 30);
    CGRectSetX(_wallet.frame, PPScreenWidth() / 2 - CGRectGetWidth(_wallet.frame) / 2);
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
