//
//  HomeViewController.h
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TransactionCellDelegate.h"
#import "TransactionCell.h"
#import "FLScrollViewIndicator.h"

@interface HomeViewController : GlobalViewController <UITableViewDataSource, UITableViewDelegate, TransactionCellDelegate> {
	NSMutableArray *cells;
	FLScrollViewIndicator *scrollViewIndicator;
}

@end
