//
//  ShopListViewController.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopListViewController.h"
#import "FriendAddSearchBar.h"
#import "ShopCardCell.h"
#import "ShopCategoryCell.h"
#import "UISearchBar+Subviews.h"
#import "ShopItemViewController.h"

@interface ShopListViewController() {
    UIBarButtonItem *searchItem;
    
    LocationSearchBar *_searchBar;
    FLTableView *tableView;
    
    BOOL isSearching;
    BOOL isLoadingSearch;
    BOOL searchLoaded;
    BOOL itemsLoaded;
    
    NSString *searchString;
    
    NSArray *items;
    NSArray *searchItems;
    
    CGFloat emptyCellHeight;
}

@end

@implementation ShopListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_USER_PICKER", @"");
    
    isSearching = NO;
    isLoadingSearch = NO;
    searchLoaded = NO;
    itemsLoaded = NO;
    
    searchItem = [[UIBarButtonItem alloc] initWithImage:[FLHelper imageWithImage:[UIImage imageNamed:@"search"] scaledToSize:CGSizeMake(20, 20)] style:UIBarButtonItemStylePlain target:self action:@selector(showSearch)];
    [searchItem setTintColor:[UIColor customBlue]];
    
    _searchBar = [[LocationSearchBar alloc] initWithFrame:CGRectMake(10, -45, PPScreenWidth() - 20, 40)];
    [_searchBar.searchBar retrieveTextField].attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Rechercher un produit..." attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [_searchBar setDelegate:self];
    [_searchBar setHidden:YES];
    [_searchBar sizeToFit];
    
    tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStylePlain];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    tableView.backgroundColor = [UIColor customBackgroundHeader];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:tableView];
    
    if (self.triggerData && self.triggerData[@"searchUrl"])
        self.navigationItem.rightBarButtonItem = searchItem;
    
    [self didFilterChange:@""];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)showSearch {
    if ([_searchBar isHidden]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [_searchBar setHidden:NO];
            CGRectSetY(_searchBar.frame, 5);
            CGRectSetY(tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar becomeFirstResponder];
        }];
    } else {
        [_searchBar close];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_searchBar.frame, -45);
            CGRectSetY(tableView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar setHidden:YES];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(FLTableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (isSearching) {
        if (searchItems.count)
            return searchItems.count;
        return 1;
    }
    
    if (items.count)
        return items.count;
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearching) {
        if (searchItems.count)
            return [ShopCell getHeight];
        else if (searchLoaded)
            return emptyCellHeight;
        return [LoadingCell getHeight];
    }
    
    if (items.count)
        return [ShopCell getHeight];
    else if (itemsLoaded)
        return emptyCellHeight;
    
    return [LoadingCell getHeight];
}

- (UITableViewCell *)tableView:(FLTableView *)tv itemCellForRowAtIndexPath:(NSIndexPath*)indexPath {
    
    FLShopItem *item;
    ShopCell *cell;
    
    if (isSearching)
        item = [searchItems objectAtIndex:indexPath.row];
    else
        item = [items objectAtIndex:indexPath.row];
    
    if (item.type == ShopItemTypeCategory) {
        static NSString *cellIdentifier = @"ShopCategoryCell";
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[ShopCategoryCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
    } else if (item.type == ShopItemTypeCard) {
        static NSString *cellIdentifier = @"ShopCardCell";
        cell = [tv dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[ShopCardCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
    }
    
    [cell setShopItem:item];
    
    return cell;
}

- (UITableViewCell *)tableView:(FLTableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (isSearching) {
        if (searchItems.count)
            return [self tableView:tv itemCellForRowAtIndexPath:indexPath];
        else if (searchLoaded)
            return [self generateEmptyplaceCell];
        return [LoadingCell new];
    }
    
    if (items.count)
        return [self tableView:tv itemCellForRowAtIndexPath:indexPath];
    else if (itemsLoaded)
        return [self generateEmptyplaceCell];
    
    return [LoadingCell new];
}

- (UITableViewCell *) generateEmptyplaceCell {
    static UITableViewCell *emptyCell;
    
    if (!emptyCell) {
        emptyCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), emptyCellHeight)];
        [emptyCell setBackgroundColor:[UIColor clearColor]];
        [emptyCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *text = [[UILabel alloc] initWithText:NSLocalizedString(@"GLOBAL_EMPTY_RESULT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        [text setWidthToFit];
        
        CGRectSetY(text.frame, emptyCellHeight / 2 - CGRectGetHeight(text.frame) / 2);
        CGRectSetX(text.frame, PPScreenWidth() / 2 - CGRectGetWidth(text.frame) / 2);
        
        [emptyCell addSubview:text];
    }
    
    return emptyCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLShopItem *selectedItem;
    
    if (isSearching) {
        if (searchItems.count)
            selectedItem = searchItems[indexPath.row];
        else
            return;
    }
    
    if (items.count)
        selectedItem = items[indexPath.row];
    else
        return;
    
    if (selectedItem && selectedItem.type == ShopItemTypeCategory && selectedItem.openTriggers) {
        [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:selectedItem.openTriggers]];
    } else if (selectedItem && selectedItem.type == ShopItemTypeCard) {
        [self.navigationController pushViewController:[[ShopItemViewController alloc] initWithItem:selectedItem] animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar close];
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    if (text.length < 3) {
        isSearching = NO;
        
        if (items.count) {
            [tableView reloadData];
        } else {
            [[Flooz sharedInstance] shopList:self.triggerData[@"loadUrl"] success:^(id result, NSString *nextPageUrl) {
                itemsLoaded = YES;
                items = result;
                [tableView reloadData];
            } failure:^(NSError *error) {
                [tableView reloadData];
            }];
        }
        return;
    }
    
    isSearching = YES;
    searchLoaded = NO;
    
    searchItems = @[];
    [tableView reloadData];
    
    [[Flooz sharedInstance] shopListSearch:self.triggerData[@"searchUrl"] search:searchString success:^(id result, NSString *nextPageUrl) {
        searchLoaded = YES;
        searchItems = result;
        [tableView reloadData];
    } failure:^(NSError *error) {
        [tableView reloadData];
    }];
}

#pragma mark - Keyboard Management

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    tableView.contentInset = UIEdgeInsetsMake(topInset,
                                              tableView.contentInset.left,
                                              bottomInset,
                                              tableView.contentInset.right);
    tableView.scrollIndicatorInsets = tableView.contentInset;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:tableView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:tableView.contentInset.top bottom:bottomInset];
}

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardDidDisappear:) name:UIKeyboardDidHideNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kbRect = [self.view convertRect:[[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:self.view.window];
    [self adjustTableViewInsetBottom:tableView.frame.origin.y + tableView.frame.size.height - kbRect.origin.y];
}

- (void)keyboardWillAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self adjustTableViewInsetBottom:0];
}

- (void)keyboardWillDisappear {
    
}

@end
