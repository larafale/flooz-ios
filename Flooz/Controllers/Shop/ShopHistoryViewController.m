//
//  ShopHistoryViewController.m
//  Flooz
//
//  Created by Olive on 01/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopHistoryCell.h"
#import "ShopHistoryViewController.h"
#import "FLAdvancedPopupTrigger.h"

@interface ShopHistoryViewController () {
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
}

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) UIView *backgroundEmptyView;

@end

@implementation ShopHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"TITLE_SHOP_HISTORY", @"");
    
    self.backgroundEmptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithText:@"Oops ! Vous n’avez pas d’achats actuellement.\n\nEn panne d’inspiration ?\nRendez-vous sur la boutique pour découvrir nos idées cadeaux !" textColor:[UIColor whiteColor] font:[UIFont customContentRegular:16] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    
    CGRectSetWidth(emptyLabel.frame, PPScreenWidth() - 40);
    CGRectSetXY(emptyLabel.frame, 20, 30);
    
    [emptyLabel setHeightToFit];
    
    FLBorderedActionButton *shopButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(75, CGRectGetMaxY(emptyLabel.frame) + 30, PPScreenWidth() - 150, 45) title:@"Go"];
    [shopButton addTarget:self action:@selector(openShop) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backgroundEmptyView addSubview:emptyLabel];
    [self.backgroundEmptyView addSubview:shopButton];
    [self.backgroundEmptyView setHidden:YES];
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    [self.tableView setTableFooterView:[UIView new]];
    
    [[Flooz sharedInstance] shopHistory:^(id result, NSString *nextPageUrl) {
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
        
        return [ShopHistoryCell getHeight];
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
        ShopHistoryCell *cell;
        
        item = [self.items objectAtIndex:indexPath.row];
        
        static NSString *cellIdentifier = @"ShopHistoryCell";
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[ShopHistoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        
        [cell setShopHistoryItem:item];
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == [self.items count])
        return;
    
    NSDictionary *item = [self.items objectAtIndex:indexPath.row];
    
    if ([item objectForKey:@"triggers"]) {
        if ([[item objectForKey:@"triggers"] isKindOfClass:[NSArray class]]) {
            [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:[item objectForKey:@"triggers"]]];
        } else if ([[item objectForKey:@"triggers"] isKindOfClass:[NSDictionary class]]) {
            [[FLTriggerManager sharedInstance] executeTrigger:[FLTrigger newWithJson:[item objectForKey:@"triggers"]]];
        }
    } else {
        NSString *contentString;
        
        if ([item[@"code"] isKindOfClass:[NSString class]]) {
            contentString = [NSString stringWithFormat:@"Votre code:\n\n\"%@\"", item[@"code"]];
        } else if ([item[@"code"] isKindOfClass:[NSArray class]]) {
            if ([item[@"code"] count] > 1) {
                contentString = @"Vos codes:\n\n";
                
                for (NSString *code in item[@"code"]) {
                    contentString = [NSString stringWithFormat:@"%@\n\n\"%@\"", contentString, code];
                }
            } else {
                contentString = [NSString stringWithFormat:@"Votre code:\n\n\"%@\"", item[@"code"][0]];
            }
        }
        
        NSDictionary *popupParams = @{@"title": item[@"type"][@"name"],@"subtitle": @" ", @"amount": item[@"amount"], @"content": contentString, @"close": @NO, @"buttons":@[@{@"title":@"Fermer", @"triggers":@[@{@"key":@"popup:advanced:hide", @"data":@{@"noAnim": @YES}}]}]};

        [[FLTriggerManager sharedInstance] executeTrigger:[FLTrigger newWithJson:@{@"key":@"popup:advanced:show", @"data": popupParams}]];
    }
}

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] shopList:_nextPageUrl success:^(id result, NSString *nextPageUrl) {
        [self.items addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [self.tableView reloadData];
    }];
}

@end
