//
//  CashOutViewController.m
//  Flooz
//
//  Created by Olivier on 2/13/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "CashOutViewController.h"
#import "CashOutHistoryViewController.h"

#import "SecureCodeViewController.h"

#define PADDING_SIDE 20.0f

@interface CashOutViewController () {
    UIBarButtonItem *historyItem;

    NSMutableDictionary *dictionary;
    
    FLTextField *_amountInput;
    
    FLActionButton *_confirmButton;
}

@end

@implementation CashOutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"ACCOUNT_BUTTON_CASH_OUT", nil);

    
    historyItem = [[UIBarButtonItem alloc] initWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"history"] scaledToSize:CGSizeMake(25, 25)] style:UIBarButtonItemStylePlain target:self action:@selector(openHistory)];
    [historyItem setTintColor:[UIColor customBlue]];

    self.navigationItem.rightBarButtonItem = historyItem;
    
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
        _amountInput = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"CASHOUT_FIELD", nil) for:dictionary key:@"amount" position:CGPointMake(PADDING_SIDE, height)];
        [_amountInput addForNextClickTarget:self action:@selector(keyNext)];
        [_amountInput addForTextChangeTarget:self action:@selector(amountChange)];
        [_amountInput setType:FLTextFieldTypeFloatNumber];
        
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

- (void)openHistory {
    [self.navigationController pushViewController:[CashOutHistoryViewController new] animated:YES];
}

- (void)amountChange {
    if (dictionary[@"amount"] && [dictionary[@"amount"] length]) {
        //        [_confirmButton setEnabled:YES];
        
        NSNumber *numberAmount = [NSNumber numberWithFloat:[[dictionary[@"amount"] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue]];
        
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

    NSNumber *amount = [dictionary objectForKey:@"amount"];
    
    if (!amount)
        amount = @0;
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] cashoutValidate:amount success:^(id result) {
    } failure:^(NSError *error) {
//        NSData *errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
//        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:nil];

//        if (serializedData && serializedData[@"popup"] && serializedData[@"popup"][@"slug"] && [serializedData[@"popup"][@"slug"] isEqualToString:@"amount"]) {
//            [_amountInput setValid:NO];
//            [_amountInput becomeFirstResponder];
//        }
    }];
}

@end
