//
//  CashOutHistoryViewController.m
//  Flooz
//
//  Created by Olive on 02/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CashoutCell.h"
#import "CashOutHistoryViewController.h"

@interface CashOutHistoryViewController () {
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *backgroundEmptyView;

@end

@implementation CashOutHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"TITLE_CASHOUT_HISTORY", @"");
    
    self.backgroundEmptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithText:@"Aucun virement éffectué" textColor:[UIColor whiteColor] font:[UIFont customContentRegular:16] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    
    CGRectSetWidth(emptyLabel.frame, PPScreenWidth() - 40);
    CGRectSetXY(emptyLabel.frame, 20, 30);
    
    [emptyLabel setHeightToFit];
    
    [self.backgroundEmptyView addSubview:emptyLabel];
    [self.backgroundEmptyView setHidden:YES];
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    [self.tableView setTableFooterView:[UIView new]];
    
    [[Flooz sharedInstance] cashoutHistory:^(id result, NSString *nextPageUrl) {
        self.items = result;
        _nextPageUrl = nextPageUrl;
        
        if (self.items && self.items.count) {
            [self.backgroundEmptyView setHidden:YES];
            [self.tableView setHidden:NO];
            [self.tableView reloadData];
        } else {
            [self.backgroundEmptyView setHidden:NO];
            [self.tableView setHidden:YES];
        }
    } failure:^(NSError *error) {
        [self.backgroundEmptyView setHidden:NO];
        [self.tableView setHidden:YES];
    }];
    
    [_mainBody addSubview:self.backgroundEmptyView];
    [_mainBody addSubview:self.tableView];
}

- (void)openShop {
    for (FLHomeButton *homeButton in [[[Flooz sharedInstance] currentTexts] homeButtons]) {
        if ([homeButton.name isEqualToString:@"shop"]) {
            [[FLTriggerManager sharedInstance] executeTriggerList:homeButton.triggers];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.items.count) {
        if (_nextPageUrl && ![_nextPageUrl isBlank])
            return [self.items count] + 1;
        
        return self.items.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.items.count) {
        if (indexPath.row >= [self.items count])
            return [LoadingCell getHeight];
        
        return [CashoutCell getHeight];
    }
    
    return CGFLOAT_MIN;
}

- (UITableViewCell *)tableView:(FLTableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.items.count) {
        if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [self.items count] - 1) {
            [self loadNextPage];
        }
        
        if (indexPath.row == [self.items count])
            return [LoadingCell new];
        
        NSDictionary *item;
        CashoutCell *cell;
        
        item = [self.items objectAtIndex:indexPath.row];
        
        static NSString *cellIdentifier = @"CashoutHistoryCell";
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[CashoutCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        [cell setHistoryItem:item];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] cashoutHistory:_nextPageUrl success:^(id result, NSString *nextPageUrl) {
        [self.items addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

@end
