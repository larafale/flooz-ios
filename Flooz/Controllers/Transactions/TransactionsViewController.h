//
//  TransactionsViewController.h
//  Flooz
//
//  Created by jonathan on 2014-03-12.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"
#import "TransactionCellDelegate.h"

@interface TransactionsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, TransactionCellDelegate>{
    NSMutableArray *transactions;
    UIButton *crossButton;
    
    NSMutableSet *rowsWithPaymentField;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;
@property (weak, nonatomic) IBOutlet FLFilterView *filterView;

@end
