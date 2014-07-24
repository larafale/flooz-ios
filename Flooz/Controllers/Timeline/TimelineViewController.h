//
//  TimelineViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLFilterView.h"
#import "TransactionCellDelegate.h"
#import "FLScrollViewIndicator.h"
#import "FLContainerViewControllerDelegate.h"

@interface TimelineViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, TransactionCellDelegate>{
    NSMutableArray *transactions;
    
    NSMutableSet *rowsWithPaymentField;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    NSString *currentFilter;
    UIRefreshControl *refreshControl;
    
    NSMutableDictionary *transactionsCache;
    FLScrollViewIndicator *scrollViewIndicator;
    
    NSMutableArray *transactionsLoaded;
    
    NSMutableArray *cells;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;
@property (weak, nonatomic) IBOutlet FLFilterView *filterView;

@end
