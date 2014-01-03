//
//  TimelineViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "TimelineViewController.h"

#import "TransactionCell.h"

@interface TimelineViewController ()

@end

@implementation TimelineViewController

NSArray *transactions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        transactions = [FLTransaction testTransactions];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor customBackgroundHeader];
[[UINavigationBar appearance] setTintColor:[UIColor customBackgroundHeader]];
    self.navigationController.navigationBar.backgroundColor = [UIColor customBackgroundHeader];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont customTitleExtraLight:28], NSFontAttributeName, [UIColor customBlue], UITextAttributeTextColor, nil];
    self.navigationController.navigationBar.translucent = NO;
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    
    self.title = @"Flooz";
    
    
    self.view.backgroundColor = [UIColor customBackground];
    
    UIImageView *shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    shadow.frame = CGRectMakeSetY(shadow.frame, self.view.frame.size.height - shadow.frame.size.height);
    [self.view addSubview:shadow];
    
    UIImageView *header_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_shadow"]];
    [self.view addSubview:header_shadow];
    
    UIImage *buttonImage = [UIImage imageNamed:@"button"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - buttonImage.size.width) / 2., self.view.frame.size.height - buttonImage.size.height - 20, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [self.view addSubview:button];
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [TransactionCell getEstimatedHeight];
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

@end
