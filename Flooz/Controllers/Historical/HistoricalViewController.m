//
//  HistoricalViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-08-27.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "HistoricalViewController.h"

#import "FLTransaction.h"

@interface HistoricalViewController (){
    NSArray *transactions;
}

@end

@implementation HistoricalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithArrayTransaction:(NSArray *)array {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"Historical", nil);
        transactions = array;
        
        transactions = [array sortedArrayUsingComparator: ^NSComparisonResult(FLTransaction *c1, FLTransaction *c2)
        {
            NSDate *d1 = c1.date;
            NSDate *d2 = c2.date;
            
            return ![d1 compare:d2];
        }];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - TableView

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [transactions count];
}

- (CGFloat)tableView:(FLTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (UITableViewCell *)tableView:(FLTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor customBackground];
        cell.textLabel.font = [UIFont customTitleExtraLight:14];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
    
    NSString *transString;
    
    if ([[transaction from].userId isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
        //cell.textLabel.textColor = [UIColor customRed];
        transString = [NSString stringWithFormat:@"(%@) %@ à %@",[FLHelper formatedDate:[transaction date]], [FLHelper formatedAmount:transaction.amount], transaction.to.username];
        cell.imageView.image = [UIImage imageNamed:@"balance-minus"];
    }
    else if ([[transaction to].userId isEqualToString:[[[Flooz sharedInstance] currentUser] userId]]) {
        //cell.textLabel.textColor = [UIColor customGreen];
        transString = [NSString stringWithFormat:@"(%@) %@ de %@",[FLHelper formatedDate:[transaction date]], [FLHelper formatedAmount:transaction.amount], transaction.from.username];
        cell.imageView.image = [UIImage imageNamed:@"balance-plus"];
    }
    
    cell.textLabel.text = transString;
    
    return cell;
}

@end
