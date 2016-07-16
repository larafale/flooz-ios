//
//  ImagePickerViewController.m
//  Flooz
//
//  Created by Olive on 16/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ImagePickerViewController.h"
#import "ImagePickerCollectionViewCell.h"
#import "FriendAddSearchBar.h"

@interface ImagePickerViewController() {
    UIBarButtonItem *refreshItem;
    
    FriendAddSearchBar *_searchBar;
    UICollectionView *collectionView;
    
    BOOL isSearching;
    NSString *searchString;
    
    NSArray *items;
}

@end

@implementation ImagePickerViewController

+ (id)newWithDelegate:(id<ImagePickerViewControllerDelegate>)delegate andType:(NSString *)type {
    return [[ImagePickerViewController alloc] initWithDelegate:delegate andType:type];
}

- (id)initWithDelegate:(id<ImagePickerViewControllerDelegate>)delegate andType:(NSString *)type {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = NSLocalizedString(@"NAV_USER_PICKER", @"");
    
    items = @[];
    searchString = @"";
    
    refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshSearch)];
    [refreshItem setTintColor:[UIColor customBlue]];
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, -45, PPScreenWidth() - 20, 40)];
    [_searchBar setDelegate:self];
    [_searchBar setHidden:YES];
    [_searchBar sizeToFit];
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    collectionView.backgroundColor = [UIColor clearColor];
    
    UICollectionViewFlowLayout *collectionLayout = [UICollectionViewFlowLayout new];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectionLayout.minimumLineSpacing = 5.0f;
    collectionLayout.minimumInteritemSpacing = 5.0f;
    collectionLayout.itemSize = CGSizeMake(PPScreenWidth() / 4 - 20, PPScreenWidth() / 4 - 20);
    
    collectionView.collectionViewLayout = collectionLayout;
    [collectionView registerClass:[ImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"imagePickerCell"];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:collectionView];
    
    self.navigationItem.rightBarButtonItem = refreshItem;
    
    [self showSearch];
    [self refreshSearch];
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
            CGRectSetY(collectionView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(collectionView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar becomeFirstResponder];
        }];
    } else {
        [_searchBar close];
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRectSetY(_searchBar.frame, -45);
            CGRectSetY(collectionView.frame, CGRectGetMaxY(_searchBar.frame) + 5);
            CGRectSetHeight(collectionView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame));
        } completion:^(BOOL finished) {
            [_searchBar setHidden:YES];
        }];
    }
}

- (void)refreshSearch {
    [[Flooz sharedInstance] imagesSearch:searchString type:self.type success:^(id result) {
        items = result;
        [collectionView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    [self refreshSearch];
}

#pragma mark - Collection View DataSource 

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)_collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePickerCollectionViewCell *cell = [_collectionView dequeueReusableCellWithReuseIdentifier:@"imagePickerCell" forIndexPath:indexPath];

    [cell setItem:items[indexPath.item]];
    
    return cell;
}

#pragma mark - Keyboard Management

- (void)adjustTableViewInsetTop:(CGFloat)topInset bottom:(CGFloat)bottomInset {
    collectionView.contentInset = UIEdgeInsetsMake(topInset,
                                              collectionView.contentInset.left,
                                              bottomInset,
                                              collectionView.contentInset.right);
    collectionView.scrollIndicatorInsets = collectionView.contentInset;
}

- (void)adjustTableViewInsetTop:(CGFloat)topInset {
    [self adjustTableViewInsetTop:topInset bottom:collectionView.contentInset.bottom];
}

- (void)adjustTableViewInsetBottom:(CGFloat)bottomInset {
    [self adjustTableViewInsetTop:collectionView.contentInset.top bottom:bottomInset];
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
    [self adjustTableViewInsetBottom:collectionView.frame.origin.y + collectionView.frame.size.height - kbRect.origin.y];
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
