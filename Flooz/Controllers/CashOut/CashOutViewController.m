//
//  CashOutViewController.m
//  Flooz
//
//  Created by jonathan on 2/13/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CashOutViewController.h"
#import "FLNewTransactionAmount.h"

#import "SecureCodeViewController.h"
#import "FLNewTransactionAmountInput.h"

#define PADDING_SIDE 20.0f

@interface CashOutViewController () {
	NSMutableDictionary *dictionary;
    
    FLTextFieldSignup *_amountInput;
    FLKeyboardView *inputView;
    
    UIButton *_confirmButton;
}

@end

@implementation CashOutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		self.title = NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil);
		dictionary = [NSMutableDictionary new];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat height = 15;
    
    {
        UILabel *text1 = [[UILabel alloc] initWithText:NSLocalizedString(@"FLOOZ_BALANCE", nil) textColor:[UIColor whiteColor] font:[UIFont customTitleLight:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        CGRectSetXY(text1.frame, CGRectGetWidth(_mainBody.frame) / 2 - CGRectGetWidth(text1.frame) / 2, height);
        
        [_mainBody addSubview:text1];
        
        height += CGRectGetHeight(text1.frame);
    }
    
    height += 15;
    
    {
        UILabel *text2 = [[UILabel alloc] initWithText:NSLocalizedString(@"GLOBAL_EURO", nil) textColor:[UIColor customBlue] font:[UIFont customContentLight:20] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        [_mainBody addSubview:text2];

        UILabel *text3 = [[UILabel alloc] initWithText:[NSString stringWithFormat:@"%@", [[[Flooz sharedInstance] currentUser].amount stringValue]] textColor:[UIColor customBlue] font:[UIFont customContentLight:35] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        CGFloat globalWidth = CGRectGetWidth(text2.frame) + CGRectGetWidth(text3.frame) + 3;
        
        CGRectSetXY(text2.frame, CGRectGetWidth(_mainBody.frame) / 2 - globalWidth / 2 + CGRectGetWidth(text3.frame) + 3, height);
        CGRectSetXY(text3.frame, CGRectGetWidth(_mainBody.frame) / 2 - globalWidth / 2, height);
        
        [_mainBody addSubview:text3];

        
        height += CGRectGetHeight(text3.frame);
    }
    
    height += 30;
    
    {
        _amountInput = [[FLTextFieldSignup alloc] initWithPlaceholder:@"Montant à retirer" for:dictionary key:@"amount" position:CGPointMake(PADDING_SIDE, height)];
        inputView = [FLKeyboardView new];
        [inputView setKeyboardDecimal];
        inputView.textField = _amountInput.textfield;
        _amountInput.textfield.inputView = inputView;
        [_mainBody addSubview:_amountInput];
    }
    
    {
        [self createConfirmButton];
        CGRectSetY(_confirmButton.frame, CGRectGetMaxY(_amountInput.frame) + 10.0f);
        [_confirmButton addTarget:self action:@selector(didValidTouch) forControlEvents:UIControlEventTouchUpInside];
        [_mainBody addSubview:_confirmButton];
    }
    
    {
        UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetHeight(_mainBody.frame) - 60.0f, CGRectGetWidth(_mainBody.frame) - PADDING_SIDE*2.0f, 60.0f)];
        firstTimeText.textColor = [UIColor customGrey];
        firstTimeText.font = [UIFont customTitleExtraLight:14];
        firstTimeText.numberOfLines = 0;
        firstTimeText.textAlignment = NSTextAlignmentCenter;
        firstTimeText.text = NSLocalizedString(@"CASH_OUT_MESSAGE", nil);
        [_mainBody addSubview:firstTimeText];
    }
}

- (void)createConfirmButton {
    _confirmButton = [[UIButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, 34)];
    
    [_confirmButton setTitle:NSLocalizedString(@"Confirm", nil) forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_confirmButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateDisabled];
    [_confirmButton setTitleColor:[UIColor customPlaceholder] forState:UIControlStateHighlighted];
    
    [_confirmButton setEnabled:YES];
    [_confirmButton setBackgroundColor:[UIColor customBackground]];
}

- (void)didValidTouch {
	[[self view] endEditing:YES];

	if ([[dictionary objectForKey:@"amount"] floatValue] <= 0) {
		return;
	}

	NSNumber *amount = [dictionary objectForKey:@"amount"];

//    [[Flooz sharedInstance] showLoadView];
//    [[Flooz sharedInstance] cashoutValidate:amount success:^(id result) {
	CompleteBlock completeBlock = ^{
		[[Flooz sharedInstance] showLoadView];
		[[Flooz sharedInstance] cashout:amount success: ^(id result) {
            [self dismissViewController];
		} failure:NULL];
	};

	SecureCodeViewController *controller = [SecureCodeViewController new];
	controller.completeBlock = completeBlock;
	[[self navigationController] pushViewController:controller animated:YES];
//    } failure:^(NSError *error) {

//    }];
}

@end
