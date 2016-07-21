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
    
    UIView *backgroundView;
    UIView *emptyView;
    UIView *loadingView;
    
    UIBarButtonItem *refreshItem;
    
    FriendAddSearchBar *_searchBar;
    UICollectionView *collectionView;
    
    NSString *searchString;
    
    NSArray *items;
    NSArray *keywords;
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
    
    if ([self.type isEqualToString:@"gif"])
        keywords = [Flooz sharedInstance].currentTexts.suggestGif;
    else if ([self.type isEqualToString:@"web"])
        keywords = [Flooz sharedInstance].currentTexts.suggestWeb;
    
    UIImage *image = [[FLHelper imageWithImage:[UIImage imageNamed:@"refresh"] scaledToSize:CGSizeMake(22, 22)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMakeWithSize(image.size)];
    [button setTintColor:[UIColor customBlue]];
    [button setImage:image  forState:UIControlStateNormal];
    [button addTarget:self action:@selector(refreshSearch) forControlEvents:UIControlEventTouchUpInside];
    
    refreshItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    _searchBar = [[FriendAddSearchBar alloc] initWithFrame:CGRectMake(10, 5, PPScreenWidth() - 20, 40)];
    [_searchBar setDelegate:self];
    
    if ([self.type isEqualToString:@"gif"])
        _searchBar.searchBar.placeholder = @"Rechercher un GIF...";
    else if ([self.type isEqualToString:@"web"])
        _searchBar.searchBar.placeholder = @"Rechercher sur le web...";
    
    [_searchBar sizeToFit];
    
    UICollectionViewFlowLayout *collectionLayout = [UICollectionViewFlowLayout new];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    collectionLayout.minimumLineSpacing = 5.0f;
    collectionLayout.minimumInteritemSpacing = 5.0f;
    collectionLayout.itemSize = CGSizeMake((PPScreenWidth() - 20) / 3, (PPScreenWidth() - 20) / 3);
    
    collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(_searchBar.frame) + 5, PPScreenWidth() - 10, CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame) - 10) collectionViewLayout:collectionLayout];
    [collectionView setDelegate:self];
    [collectionView setDataSource:self];
    collectionView.bounces = YES;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [collectionView registerClass:[ImagePickerCollectionViewCell class] forCellWithReuseIdentifier:@"imagePickerCell"];
    
    backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 5, PPScreenWidth(), CGRectGetHeight(_mainBody.frame) - CGRectGetMaxY(_searchBar.frame) - 5)];
    [backgroundView addTapGestureWithTarget:_searchBar action:@selector(close)];
    
    UILabel *backTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 25)];
    backTitle.textColor = [UIColor whiteColor];
    backTitle.textAlignment = NSTextAlignmentCenter;
    backTitle.font = [UIFont customContentLight:20];
    backTitle.numberOfLines = 1;
    backTitle.text = @"Les plus utilisés";
    
    UIImageView *giphyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(backgroundView.frame) - 40, PPScreenWidth(), 20)];
    [giphyIcon setImage:[[UIImage imageNamed:@"giphy"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [giphyIcon setTintColor:[UIColor customPlaceholder]];
    [giphyIcon setContentMode:UIViewContentModeScaleAspectFit];
    
    giphyIcon.hidden = ![self.type isEqualToString:@"gif"];
    
    [backgroundView addSubview:backTitle];
    [backgroundView addSubview:giphyIcon];
    
    CGFloat tagHeight = (CGRectGetHeight(backgroundView.frame) - CGRectGetMaxY(backTitle.frame) - CGRectGetHeight(giphyIcon.frame) - 40) / keywords.count;
    CGFloat yOffset = CGRectGetMaxY(backTitle.frame) + 10;
    int i = 0;
    
    for (NSString *keyword in keywords) {
        UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(0, yOffset, PPScreenWidth(), tagHeight)];
        tag.tag = i + 20;
        tag.textColor = [UIColor customBlue];
        tag.textAlignment = NSTextAlignmentCenter;
        tag.font = [UIFont customContentRegular:16];
        tag.numberOfLines = 1;
        tag.text = keyword;
        [tag addTapGestureWithTarget:self action:@selector(didTagLabelClicked:)];
        
        CGRectSetWidth(tag.frame, [tag widthToFit] + 10);
        CGRectSetX(tag.frame, PPScreenWidth() / 2 - CGRectGetWidth(tag.frame) / 2);
        
        [backgroundView addSubview:tag];
        
        ++i;
        yOffset += tagHeight;
    }
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 5, PPScreenWidth(), 50)];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//    activityIndicatorView.color = [UIColor customBlue];
    [activityIndicatorView startAnimating];
    
    CGRectSetXY(activityIndicatorView.frame, PPScreenWidth() / 2 - CGRectGetWidth(activityIndicatorView.frame) / 2, 5);

    [loadingView addSubview:activityIndicatorView];

    emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_searchBar.frame) + 5, PPScreenWidth(), 50)];
    
    UILabel *emptyLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"GLOBAL_EMPTY_RESULT", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    CGRectSetXY(emptyLabel.frame, PPScreenWidth() / 2 - CGRectGetWidth(emptyLabel.frame) / 2, 10);
    
    [emptyView addSubview:emptyLabel];
    
    [_mainBody addSubview:_searchBar];
    [_mainBody addSubview:collectionView];
    [_mainBody addSubview:backgroundView];
    [_mainBody addSubview:loadingView];
    [_mainBody addSubview:emptyView];
    
    if ([self.type isEqualToString:@"web"])
        self.navigationItem.rightBarButtonItem = refreshItem;
    
    [self refreshSearch];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self registerForKeyboardNotifications];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)refreshSearch {
    items = @[];
    [collectionView reloadData];
    
    if (searchString && searchString.length > 3) {
        collectionView.hidden = YES;
        backgroundView.hidden = YES;
        loadingView.hidden = NO;
        emptyView.hidden = YES;
        
        [[Flooz sharedInstance] imagesSearch:searchString type:self.type success:^(id result) {
            items = result;
            [collectionView reloadData];
            
            if (items.count) {
                collectionView.hidden = NO;
                backgroundView.hidden = YES;
                loadingView.hidden = YES;
                emptyView.hidden = YES;
            } else {
                collectionView.hidden = YES;
                backgroundView.hidden = YES;
                loadingView.hidden = YES;
                emptyView.hidden = NO;
            }
            
        } failure:^(NSError *error) {
            
        }];
    } else {
        collectionView.hidden = YES;
        backgroundView.hidden = NO;
        loadingView.hidden = YES;
        emptyView.hidden = YES;
    }
}

- (void)didFilterChange:(NSString *)text {
    searchString = text;
    [self refreshSearch];
}

- (void)didTagLabelClicked:(UITapGestureRecognizer *)gesture {
    NSInteger tagId = gesture.view.tag - 20;
    
    NSString *tag = keywords[tagId];
    
    _searchBar.searchBar.text = tag;
    searchString = tag;
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
            NSArray<FLTrigger *> *successTriggers = [FLTriggerManager convertDataInList:self.triggerData[@"success"]];
            FLTrigger *successTrigger = successTriggers[0];
            
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
                [[FLTriggerManager sharedInstance] executeTriggerList:successTriggers];
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
