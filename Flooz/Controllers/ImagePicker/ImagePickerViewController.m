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
    
    if (!self.title || [self.title isBlank]) {
        if ([self.type isEqualToString:@"gif"])
            self.title = NSLocalizedString(@"NAV_GIF_PICKER", @"");
        else if ([self.type isEqualToString:@"web"])
            self.title = NSLocalizedString(@"NAV_IMAGE_PICKER", @"");
    }
    
    items = @[];
    searchString = @"";
    
    UIImage *image = [[FLHelper imageWithImage:[UIImage imageNamed:@"refresh"] scaledToSize:CGSizeMake(22, 22)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(image.size)];
    [button setTintColor:[UIColor customBlue]];
    [button setImage:image  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(refreshSearch) forControlEvents:UIControlEventTouchUpInside];
    
    refreshItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, -45, PPScreenWidth() - 20, 40)];
    [_searchBar setDelegate:self];
    
    if ([self.type isEqualToString:@"gif"])
        _searchBar.searchBar.placeholder = @"Rechercher un GIF...";
    else if ([self.type isEqualToString:@"web"])
        _searchBar.searchBar.placeholder = @"Rechercher sur le web...";
    
    [_searchBar setHidden:YES];
    [_searchBar sizeToFit];
    
    UICollectionViewFlowLayout *collectionLayout = [UICollectionViewFlowLayout new];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectionLayout.minimumLineSpacing = 5.0f;
    collectionLayout.minimumInteritemSpacing = 5.0f;
    collectionLayout.itemSize = CGSizeMake((PPScreenWidth() - 20) / 3, (PPScreenWidth() - 20) / 3);
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 0, PPScreenWidth() - 10, CGRectGetHeight(_mainBody.frame)) collectionViewLayout:collectionLayout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    collectionView.backgroundColor = [UIColor clearColor];
    
    [collectionView registerClass:[ImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"imagePickerCell"];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:collectionView];
    
    if ([self.type isEqualToString:@"web"])
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
    items = @[];
    [collectionView reloadData];
    
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (items.count >= indexPath.item) {
        NSDictionary *item = items[indexPath.item];
        
        if (self.triggerData) {
            FLTrigger *successTrigger = [[FLTrigger alloc] initWithJson:self.triggerData[@"success"][0]];
            
            NSMutableDictionary *data = [NSMutableDictionary new];
            
            data[@"imageUrl"] = item[@"url"];
            
            NSDictionary *baseDic;
            
            if (self.triggerData[@"in"]) {
                baseDic = successTrigger.data[self.triggerData[@"in"]];
                
                [data addEntriesFromDictionary:baseDic];
                
                NSMutableDictionary *newData = [successTrigger.data mutableCopy];
                
                newData[self.triggerData[@"in"]] = data;
                
                successTrigger.data = newData;
            } else {
                baseDic = successTrigger.data;
                [data addEntriesFromDictionary:baseDic];
                
                successTrigger.data = data;
            }
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[FLTriggerManager sharedInstance] executeTrigger:successTrigger];
            }];
        } else if (self.delegate) {
            [self.delegate image:item[@"url"] pickedFrom:self];
        }
    }
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_searchBar close];
}

- (void)keyboardDidDisappear:(NSNotification *)notification {
    [self adjustTableViewInsetBottom:0];
}

- (void)keyboardWillDisappear {
    
}

@end
