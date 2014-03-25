//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "HomeViewController.h"

#import "LoginViewController.h"
#import "SignupViewController.h"
#import "TransactionCell.h"

@interface HomeViewController (){
    UIButton *login;
    UIButton *signup;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        transactions = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    _tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    login = [UIButton new];
    signup = [UIButton new];
    
    login.backgroundColor = [UIColor customBackgroundStatus];
    login.titleLabel.font = [UIFont customTitleLight:14];
    login.layer.opacity = 0.7;
    login.layer.cornerRadius = 2.;
    [login setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
    [login addTarget:self action:@selector(presentLoginController) forControlEvents:UIControlEventTouchUpInside];
    
    signup.backgroundColor = [UIColor customBlue];
    signup.titleLabel.font = login.titleLabel.font;
    signup.layer.opacity = login.layer.opacity;
    signup.layer.cornerRadius = login.layer.cornerRadius;
    [signup setTitle:NSLocalizedString(@"HOME_SIGNUP", nil) forState:UIControlStateNormal];
    [signup addTarget:self action:@selector(presentSignupController) forControlEvents:UIControlEventTouchUpInside];
    
    {
        UIImageView *shadow = [UIImageView imageNamed:@"tableview-shadow"];
        CGRectSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
        [self.view addSubview:shadow];
    }
    
    [self.view addSubview:login];
    [self.view addSubview:signup];
    
    [self didFilterPublicTouch];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    login.frame = CGRectMake(23, self.view.frame.size.height - 30 - 35, 134, 45);
    signup.frame = CGRectMake(CGRectGetMaxX(login.frame) + 6, login.frame.origin.y, login.frame.size.width, login.frame.size.height);
}

- (void)presentLoginController
{
    [self.navigationController pushViewController:[LoginViewController new] animated:YES];
}

- (void)presentSignupController
{
    [self.navigationController pushViewController:[SignupViewController new] animated:YES];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    return [TransactionCell getHeightForTransaction:transaction];
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TransactionCell";
    TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    [cell setTransaction:transaction];
    
    return cell;
}

- (void)didFilterPublicTouch
{
    [[Flooz sharedInstance] timeline:@"public" success:^(id result, NSString *nextPageUrl) {
        transactions = result;
        [_tableView reloadData];
    } failure:NULL];
}

@end
