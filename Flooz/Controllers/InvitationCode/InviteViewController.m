//
//  InviteViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-16.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "InviteViewController.h"
#import "FLPopupAskInviteCode.h"
#import "FLPopupEnterInviteCode.h"

@interface InviteViewController () {
	NSMutableDictionary *_userDic;
	UIView *_mainBody;

    UIImageView *_headerImage;
    
	UILabel *_textExplication;

    UIButton *_askCode;
    UIButton *_enterCode;
}

@end

@implementation InviteViewController

- (id)initWithUser:(NSDictionary *)user {
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		if (user) {
			_userDic = [user mutableCopy];
		}
		else {
			_userDic = [NSMutableDictionary new];
		}
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor customBackgroundHeader];


	[self prepareViews];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - prepare Views

- (void)prepareViews {
    CGFloat padding = 15.0f;
    CGFloat height = 0.0f;
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, STATUSBAR_HEIGHT, PPScreenWidth(), PPScreenHeight() - 60.0f)];
    [self.view addSubview:_mainBody];
    
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 2, 30, 60)];
        [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
        [_mainBody addSubview:backButton];
    }

    {
        _headerImage = [UIImageView imageNamed:@"code-envelope"];
        
        CGFloat scaleRatio = CGRectGetWidth(_headerImage.frame) / CGRectGetHeight(_headerImage.frame);
        
        CGRectSetWidthHeight(_headerImage.frame, CGRectGetWidth(_mainBody.frame) / 2, CGRectGetWidth(_mainBody.frame) / 2 * scaleRatio);
        CGRectSetXY(_headerImage.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(_headerImage.frame) / 2, 70);
        
        [_mainBody addSubview:_headerImage];
        height += CGRectGetMaxY(_headerImage.frame);
    }
    
    height += 30.0f;
    
    {
        _textExplication = [[UILabel alloc] initWithFrame:CGRectMake(padding, height, PPScreenWidth() - padding * 2.0f, CGRectGetHeight(_mainBody.frame) - height)];
        _textExplication.textColor = [UIColor customGrey];
        _textExplication.font = [UIFont customTitleExtraLight:18];
        if (IS_IPHONE4) {
            _textExplication.font = [UIFont customTitleExtraLight:17];
        }
        _textExplication.textAlignment = NSTextAlignmentCenter;
        _textExplication.numberOfLines = 0;
        
        if (_userDic[@"pendingInvitation"] && [_userDic[@"pendingInvitation"] boolValue])
            _textExplication.text = NSLocalizedString(@"INVITATION_CODE_WAITING_EXPLICATION", nil);
        else
            _textExplication.text = NSLocalizedString(@"INVITATION_CODE_EXPLICATION", nil);
        
        [_textExplication sizeToFit];
        
        [_mainBody addSubview:_textExplication];
    }
    
    {
        if (_userDic[@"pendingInvitation"] && [_userDic[@"pendingInvitation"] boolValue]) {
            _enterCode = [[UIButton alloc] initWithFrame:CGRectMake(1, CGRectGetHeight(self.view.frame) - 59, CGRectGetWidth(self.view.frame) - 2, 58)];
            [_enterCode setBackgroundColor:[UIColor customBlue]];
            [_enterCode addTarget:self action:@selector(showAccessPopup) forControlEvents:UIControlEventTouchUpInside];
            {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_enterCode.frame), CGRectGetHeight(_enterCode.frame))];
                titleLabel.text = NSLocalizedString(@"INVITATION_CODE_ACCESS_LONG", nil);
                titleLabel.font = [UIFont customTitleLight:16];
                titleLabel.numberOfLines = 2;
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [_enterCode addSubview:titleLabel];
            }

            [self.view addSubview:_enterCode];
        }
        else {
            _enterCode = [[UIButton alloc] initWithFrame:CGRectMake(1, CGRectGetHeight(self.view.frame) - 59, CGRectGetWidth(self.view.frame) / 2. - 1, 58)];
            [_enterCode setBackgroundColor:[UIColor customBlue]];
            [_enterCode addTarget:self action:@selector(showAccessPopup) forControlEvents:UIControlEventTouchUpInside];
            {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_enterCode.frame), CGRectGetHeight(_enterCode.frame))];
                titleLabel.text = NSLocalizedString(@"INVITATION_CODE_ACCESS", nil);
                titleLabel.font = [UIFont customTitleLight:16];
                titleLabel.numberOfLines = 2;
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [_enterCode addSubview:titleLabel];
            }
            
            [self.view addSubview:_enterCode];
            
            _askCode = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2., CGRectGetHeight(self.view.frame) - 59, CGRectGetWidth(self.view.frame) / 2. - 1, 58)];
            [_askCode setBackgroundColor:[UIColor customBlue]];
            [_askCode addTarget:self action:@selector(showAskPopup) forControlEvents:UIControlEventTouchUpInside];
            {
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_askCode.frame), CGRectGetHeight(_askCode.frame))];
                titleLabel.text = NSLocalizedString(@"INVITATION_CODE_ASK", nil);
                titleLabel.font = [UIFont customTitleLight:16];
                titleLabel.numberOfLines = 2;
                titleLabel.textColor = [UIColor whiteColor];
                titleLabel.textAlignment = NSTextAlignmentCenter;
                [_askCode addSubview:titleLabel];
            }
            [self.view addSubview:_askCode];
            
            UIView *separatorButtonBar = [UIView newWithFrame:CGRectMake(CGRectGetWidth(self.view.frame) / 2., CGRectGetHeight(self.view.frame) - 45, 1, 30)];
            [separatorButtonBar setBackgroundColor:[UIColor whiteColor]];
            
            [self.view addSubview:separatorButtonBar];
        }
    }
    
}

- (void)showAccessPopup {
    [[[FLPopupEnterInviteCode alloc] initWithUser:_userDic andCompletionBlock:^{
        [[Flooz sharedInstance] showLoadView];
        
        NSMutableDictionary *tmp = [_userDic mutableCopy];
        [tmp removeObjectForKey:@"pendingInvitation"];
        
        [[Flooz sharedInstance] verifyInvitationCode:tmp success:^(id result) {
            [self dismissViewController];
        } failure:nil];
    }] show];
}

- (void)showAskPopup {
    [[[FLPopupAskInviteCode alloc] initWithUser:_userDic andCompletionBlock:^{
        [[Flooz sharedInstance] showLoadView];
        [[Flooz sharedInstance] askInvitationCode:_userDic success:^(id result) {
            _userDic[@"pendingInvitation"] = @YES;
            [self.view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [self prepareViews];
        } failure:nil];
    }] show];
}

@end
