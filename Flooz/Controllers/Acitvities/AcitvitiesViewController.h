//
//  AcitvitiesViewController.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcitvitiesViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>{
    NSMutableArray *activities;
    
    UIRefreshControl *refreshControl;
    UIView *tableViewShadow;
    BOOL isLoaded;
    
    UITapGestureRecognizer *closeGesture;
    UILabel *tableHeaderView;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
