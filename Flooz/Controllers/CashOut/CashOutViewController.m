//
//  CashOutViewController.m
//  Flooz
//
//  Created by olivier on 2/13/2014.
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
    
    FLActionButton *_confirmButton;
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
        
        UILabel *text3 = [[UILabel alloc] initWithText:[FLHelper formatedAmount:[Flooz sharedInstance].currentUser.amount withCurrency:NO withSymbol:NO]
                                             textColor:[UIColor customBlue] font:[UIFont customContentLight:35] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        CGFloat globalWidth = CGRectGetWidth(text2.frame) + CGRectGetWidth(text3.frame) + 3;
        
        CGRectSetXY(text2.frame, CGRectGetWidth(_mainBody.frame) / 2 - globalWidth / 2 + CGRectGetWidth(text3.frame) + 3, height);
        CGRectSetXY(text3.frame, CGRectGetWidth(_mainBody.frame) / 2 - globalWidth / 2, height);
        
        [_mainBody addSubview:text3];
        
        
        height += CGRectGetHeight(text3.frame);
    }
    
    height += 30;
    
    {
        _amountInput = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"CASHOUT_FIELD", nil) for:dictionary key:@"amount" position:CGPointMake(PADDING_SIDE, height)];
        [_amountInput addForNextClickTarget:self action:@selector(keyNext)];
        [_amountInput addForTextChangeTarget:self action:@selector(amountChange)];
//        [_amountInput setType:FLTextFieldTypeFloatNumber];
        
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
        UILabel *firstTimeText = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_confirmButton.frame) + PADDING_SIDE, CGRectGetWidth(_mainBody.frame) - PADDING_SIDE*2.0f, 60.0f)];
        firstTimeText.textColor = [UIColor customGrey];
        firstTimeText.font = [UIFont customTitleExtraLight:14];
        firstTimeText.numberOfLines = 0;
        firstTimeText.textAlignment = NSTextAlignmentCenter;
        firstTimeText.text = NSLocalizedString(@"CASH_OUT_MESSAGE", nil);
        [_mainBody addSubview:firstTimeText];
    }
}

- (void)keyNext {
    
}

- (void)amountChange {
    if (dictionary[@"amount"] && [dictionary[@"amount"] length]) {
        //        [_confirmButton setEnabled:YES];
        
        NSNumber *numberAmount = [NSNumber numberWithFloat:[dictionary[@"amount"] floatValue]];
        
        [_confirmButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"CASHOUT_BUTTON", nil), [[FLHelper formatedAmount:numberAmount withCurrency:NO withSymbol:NO] stringByAppendingString:@"€"]] forState:UIControlStateNormal];
    } else {
        //        [_confirmButton setEnabled:NO];
        [_confirmButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"CASHOUT_BUTTON", nil), @""] forState:UIControlStateNormal];
    }
}

- (void)createConfirmButton {
    _confirmButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, 34)];
    
    [_confirmButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"CASHOUT_BUTTON", nil), @""] forState:UIControlStateNormal];
    [_confirmButton setEnabled:YES];
}

- (void)didValidTouch {
    [[self view] endEditing:YES];
    
    //    if ([[dictionary objectForKey:@"amount"] floatValue] <= 0) {
    //        return;
    //    }
    
    NSNumber *amount = [dictionary objectForKey:@"amount"];
    
    if (!amount)
        amount = @0;
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashoutValidate:amount success:^(id result) {
//        [_amountInput setValid:YES];

        CompleteBlock completeBlock = ^{
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] cashout:amount success: ^(id result) {
                [self dismissViewController];
            } failure:NULL];
        };
        
        if ([SecureCodeViewController canUseTouchID])
            [SecureCodeViewController useToucheID:completeBlock passcodeCallback:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    SecureCodeViewController *controller = [SecureCodeViewController new];
                    controller.completeBlock = completeBlock;
                    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                        [[Flooz sharedInstance] hideLoadView];
                    }];
                });
            } cancelCallback:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[Flooz sharedInstance] hideLoadView];
                });
            }];
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                SecureCodeViewController *controller = [SecureCodeViewController new];
                controller.completeBlock = completeBlock;
                [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
                    [[Flooz sharedInstance] hideLoadView];
                }];
            });
        }
//
//        SecureCodeViewController *controller = [SecureCodeViewController new];
//        controller.completeBlock = completeBlock;
//        [[self navigationController] pushViewController:controller animated:YES];
    } failure:^(NSError *error) {
        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];

//        if (serializedData && serializedData[@"popup"] && serializedData[@"popup"][@"slug"] && [serializedData[@"popup"][@"slug"] isEqualToString:@"amount"]) {
//            [_amountInput setValid:NO];
//            [_amountInput becomeFirstResponder];
//        }
    }];
}

@end
