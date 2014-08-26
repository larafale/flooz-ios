//
//  CashOutViewController.m
//  Flooz
//
//  Created by jonathan on 2/13/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "CashOutViewController.h"
#import "FLNewTransactionAmount.h"

#import "SecureCodeViewController.h"

@interface CashOutViewController (){
    FLNewTransactionAmount *amountInput;
    NSMutableDictionary *dictionary;
}

@end

@implementation CashOutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_CASHOUT", nil);
        dictionary = [NSMutableDictionary new];
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor customBackground];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem createCheckButtonWithTarget:self action:@selector(didValidTouch)];
    
    CGFloat offset = 0;
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 70)];
        view.backgroundColor = [UIColor customBackgroundHeader];
        [self.view addSubview:view];
        
        {
            UIImageView *imageView = [UIImageView imageNamed:@"account-balance"];
            CGRectSetXY(imageView.frame, 25, 20);
            
            UILabel *text = [[UILabel alloc] initWithFrame:CGRectMake(69, 5, 200, 30)];
            text.text = NSLocalizedString(@"ACCOUNT_BALANCE", nil);
            text.font = [UIFont customContentRegular:10];
            text.textColor = [UIColor customBlueLight];
            
            UILabel *amount = [[UILabel alloc] initWithFrame:CGRectMake(69, 20, 200, 30)];
            
            amount.text = [FLHelper formatedAmount:[[[Flooz sharedInstance] currentUser] amount]];
            amount.font = [UIFont customTitleExtraLight:24];
            amount.textColor = [UIColor customBlue];
            
            [view addSubview:imageView];
            [view addSubview:text];
            [view addSubview:amount];
        }
        offset = CGRectGetMaxY(view.frame);
    }
    
    {
        amountInput = [[FLNewTransactionAmount alloc] initFor:dictionary key:@"amount"];
        CGRectSetY(amountInput.frame, offset);
        [self.view addSubview:amountInput];
    }
}

- (void)didValidTouch
{
    [[self view] endEditing:YES];
    
    if([[dictionary objectForKey:@"amount"] floatValue] <= 0){
        return;
    }
    
    NSNumber *amount = [dictionary objectForKey:@"amount"];
    
//    [[Flooz sharedInstance] showLoadView];
//    [[Flooz sharedInstance] cashoutValidate:amount success:^(id result) {
        CompleteBlock completeBlock = ^{
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] cashout:amount success:^(id result) {
                [self dismissViewControllerAnimated:YES completion:NULL];
            } failure:NULL];
        };
        
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = completeBlock;
        [[self navigationController] pushViewController:controller animated:YES];
//    } failure:^(NSError *error) {
    
//    }];
}

@end
