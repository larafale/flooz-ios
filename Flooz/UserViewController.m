//
//  UserViewController.m
//  Flooz
//
//  Created by Flooz on 9/16/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FriendCell.h"
#import "FXBlurView.h"
#import "UserViewController.h"
#import "TransactionCell.h"

#define actionButtonHeight 30

#define headerFullHeight 105
#define avatarSize 70
#define avatarMarginTop 80

#define offset_HeaderStop 40.0 // At this offset the Header stops its transformations
#define offset_B_LabelHeader ((avatarMarginTop + avatarSize) - offset_HeaderStop - 20) // At this offset the Black label reaches the Header
#define distance_W_LabelHeader (offset_B_LabelHeader - offset_HeaderStop) // The distance between the bottom of the Header and the top of the White Label

@interface UserViewController () {
    FLUser *currentUser;
    FLUserView *avatarImage;
    UIView *header;
    UILabel *headerLabel;
    UIButton *headerBack;
    UIImageView *headerImageView;
    UIImageView *headerBlurImageView;
    UIImageView *blurredHeaderImageView;
    
    UIButton *settingsButton;
    FLActionButton *socialRemoveActionButton;
    FLBorderedActionButton *socialAddActionButton;
    FLBorderedActionButton *floozActionButton;
    UISegmentedControl *controlTab;
    
    UIView *headerCell;
    
    UILabel *fullnameLabel;
    UILabel *usernameLabel;
    UILabel *bioLabel;
    
    NSMutableArray *transactions;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    NSMutableSet *rowsWithPaymentField;
    NSMutableArray *cells;
    NSMutableArray *transactionsLoaded;
}

@end

@implementation UserViewController

- (id)initWithUser:(FLUser*)user {
    self = [super init];
    if (self) {
        currentUser = user;
        transactions = [NSMutableArray new];
        rowsWithPaymentField = [NSMutableSet new];
        nextPageIsLoading = NO;
        
        transactionsLoaded = [NSMutableArray new];
        cells = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat mainBodyHeight = PPScreenHeight();
    
    if (self.tabBarController)
        mainBodyHeight -= PPTabBarHeight();
    
    CGRectSetHeight(_mainBody.frame, mainBodyHeight);
    
    [self createHeaderCell];
    [self createHeader];
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame)) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    
    [_mainBody addSubview:header];
    [_mainBody addSubview:self.tableView];
    [_mainBody addSubview:headerBack];
    
    [self reloadData];
    
    [[Flooz sharedInstance] getUserProfile:currentUser.userId success:^(FLUser *result) {
        if (result)
            currentUser = result;
        [self reloadData];
    } failure:nil];
}

- (void)createHeader {
    header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), headerFullHeight)];
    
    // Header - Back
    headerBack = [[UIButton alloc] initWithFrame:CGRectMake(5, PPStatusBarHeight() + 5, 30, 30)];
    [headerBack setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
    [headerBack addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
    headerBack.layer.zPosition = 5;
    
    // Header - Label
    headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offset_HeaderStop + distance_W_LabelHeader + 12, PPScreenWidth(), PPTabBarHeight())];
    headerLabel.font = [UIFont customTitleLight:17];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.numberOfLines = 2;
    
    [header addSubview:headerLabel];
    
    // Header - Image
    headerImageView = [[UIImageView alloc] initWithFrame:header.bounds];
    headerImageView.image = [UIImage imageNamed:@"back-secure"];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [header insertSubview:headerImageView belowSubview:headerLabel];
    
    // Header - Blurred Image
    headerBlurImageView = [[UIImageView alloc] initWithFrame:header.bounds];
    headerBlurImageView.image =  [[UIImage imageNamed:@"back-secure"] blurredImageWithRadius:15 iterations:20 tintColor:[UIColor clearColor]];
    headerBlurImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerBlurImageView.alpha = 0.0;
    [header insertSubview:headerBlurImageView belowSubview:headerLabel];
    
    header.clipsToBounds = true;
}

- (void)createHeaderCell {
    
    headerCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    
    avatarImage = [[FLUserView alloc] initWithFrame:CGRectMake(10, avatarMarginTop, avatarSize, avatarSize)];
    
    socialRemoveActionButton = [[FLActionButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, actionButtonHeight, actionButtonHeight)];
    [socialRemoveActionButton setImage:[UIImage imageNamed:@"unfollow"] size:CGSizeMake(17, 17)];
    socialRemoveActionButton.layer.cornerRadius = 5;
    [socialRemoveActionButton centerImage];
    
    socialAddActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, PPScreenWidth() / 4, actionButtonHeight)];
    [socialAddActionButton setImage:[UIImage imageNamed:@"follow"] size:CGSizeMake(15, 15)];
    [socialAddActionButton.titleLabel setFont:[UIFont customContentBold:15]];
    
    floozActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, PPScreenWidth() / 4, actionButtonHeight) title:@"Floozer"];
    [floozActionButton.titleLabel setFont:[UIFont customContentBold:15]];
    
    settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, actionButtonHeight, actionButtonHeight)];
    [settingsButton setImage:[[UIImage imageNamed:@"cog"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingsButton setTintColor:[UIColor customPlaceholder]];
    [settingsButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    
    fullnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(avatarImage.frame) + 10, PPScreenWidth() / 2, 20)];
    fullnameLabel.font = [UIFont customContentBold:17];
    fullnameLabel.textColor = [UIColor whiteColor];
    
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(fullnameLabel.frame) + 5, PPScreenWidth() / 2, 18)];
    usernameLabel.font = [UIFont customContentBold:14];
    usernameLabel.textColor = [UIColor customGreyPseudo];
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(usernameLabel.frame) + 5, PPScreenWidth() - 20, 0)];
    bioLabel.font = [UIFont customContentRegular:12];
    bioLabel.textColor = [UIColor whiteColor];
    bioLabel.numberOfLines = 0;
    bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    controlTab = [[UISegmentedControl alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bioLabel.frame) + 10, CGRectGetWidth(self.view.frame) - 2 * 10, 30)];
    [controlTab setTintColor:[UIColor customBlue]];
    [controlTab addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [controlTab setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [controlTab setTitleTextAttributes:@{NSFontAttributeName:[UIFont customContentRegular:16]} forState:UIControlStateNormal];
    
    [controlTab setSelectedSegmentIndex:[FLTransaction transactionParamsToScope:[Flooz sharedInstance].currentUser.settings[@"def"][@"scope"]]];
    
    [headerCell addSubview:avatarImage];
    [headerCell addSubview:fullnameLabel];
    [headerCell addSubview:usernameLabel];
    [headerCell addSubview:socialRemoveActionButton];
    [headerCell addSubview:socialAddActionButton];
    [headerCell addSubview:floozActionButton];
    [headerCell addSubview:settingsButton];
    [headerCell addSubview:bioLabel];
    [headerCell addSubview:controlTab];
    
    CGRectSetHeight(headerCell.frame, CGRectGetMaxY(controlTab.frame) + 10);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)reloadData {
    [self reloadTableView];
    
    if (currentUser.email == nil)
        [self reloadMiniUser];
    else
        [self reloadUser];
}

- (void)reloadMiniUser {
    [headerLabel setText:[NSString stringWithFormat:@"%@\n@%@", currentUser.fullname, currentUser.username]];
    [avatarImage setImageFromUser:currentUser];
    
    [fullnameLabel setText:currentUser.fullname];
    [usernameLabel setText:[NSString stringWithFormat:@"@%@", currentUser.username]];
    
    [floozActionButton setHidden:YES];
    [socialAddActionButton setHidden:YES];
    [socialRemoveActionButton setHidden:YES];
    [settingsButton setHidden:YES];
    
    [controlTab insertSegmentWithTitle:@"Flooz" atIndex:0 animated:NO];
    
    if (currentUser.isStar)
        [controlTab insertSegmentWithTitle:NSLocalizedString(@"FOLLOWERS", nil) atIndex:1 animated:NO];
    else
        [controlTab insertSegmentWithTitle:NSLocalizedString(@"FRIENDS", nil) atIndex:1 animated:NO];
    
    [controlTab setSelectedSegmentIndex:0];
    
    [self.tableView reloadData];
}

- (void)reloadUser {
    if ([currentUser.userId isEqualToString:[Flooz sharedInstance].currentUser.userId]) {
        [floozActionButton setHidden:YES];
        [socialAddActionButton setHidden:YES];
        [socialRemoveActionButton setHidden:YES];
        [settingsButton setHidden:YES];
    } else {
        UIView *rightButton;
        
        if (currentUser.isFriend) {
            [socialAddActionButton setHidden:YES];
            [socialRemoveActionButton setHidden:NO];
            
            [socialRemoveActionButton centerImage];
            
            CGRectSetX(socialRemoveActionButton.frame, PPScreenWidth() - CGRectGetWidth(socialRemoveActionButton.frame) - 10);
            
            rightButton = socialRemoveActionButton;
        } else {
            [socialAddActionButton setHidden:NO];
            [socialRemoveActionButton setHidden:YES];
            
            if (currentUser.isStar)
                [socialAddActionButton setTitle:NSLocalizedString(@"FOLLOW", nil) forState:UIControlStateNormal];
            else
                [socialAddActionButton setTitle:NSLocalizedString(@"FRIEND_ADD", nil) forState:UIControlStateNormal];
            
            [socialAddActionButton centerImage:5];
            
            CGRectSetX(socialAddActionButton.frame, PPScreenWidth() - CGRectGetWidth(socialAddActionButton.frame) - 10);
            
            rightButton = socialAddActionButton;
        }
        
        [floozActionButton setHidden:NO];
        [settingsButton setHidden:NO];
        
        CGRectSetX(floozActionButton.frame, CGRectGetMinX(rightButton.frame) - CGRectGetWidth(floozActionButton.frame) - 10);
        CGRectSetX(settingsButton.frame, CGRectGetMinX(floozActionButton.frame) - CGRectGetWidth(settingsButton.frame) - 3);
    }
    
    [headerLabel setText:[NSString stringWithFormat:@"%@\n@%@", currentUser.fullname, currentUser.username]];
    [avatarImage setImageFromUser:currentUser];
    
    [fullnameLabel setText:currentUser.fullname];
    [usernameLabel setText:[NSString stringWithFormat:@"@%@", currentUser.username]];
    [bioLabel setText:currentUser.bio];
    
    [bioLabel setHeightToFit];
    
    CGRectSetY(controlTab.frame, CGRectGetMaxY(bioLabel.frame) + 10);
    CGRectSetHeight(headerCell.frame, CGRectGetMaxY(controlTab.frame) + 10);
    
    [self.tableView reloadData];
}

- (void)segmentedControlValueChanged:(UISegmentedControl*)sender {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (controlTab.selectedSegmentIndex == 0)
        return transactions.count;
    else
        return currentUser.friends.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (controlTab.selectedSegmentIndex == 0) {
        if (indexPath.row >= [transactions count]) {
            return [LoadingCell getHeight];
        }
        
        FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
        return [TransactionCell getHeightForTransaction:transaction andWidth:CGRectGetWidth(tableView.frame)];
        
    } else
        return [FriendCell getHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(headerCell.frame);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (controlTab.selectedSegmentIndex == 0) {
        static NSString *cellIdentifier = @"TransactionCell";
        TransactionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[TransactionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andDelegate:self];
        }
        
        FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
        
        [cell setTransaction:transaction];
        [cell setIndexPath:indexPath];
        
        if (_nextPageUrl && ![_nextPageUrl isBlank] && !nextPageIsLoading && indexPath.row == [transactions count] - 1) {
            [self loadNextPage];
        }
        
        return cell;
    } else {
        static NSString *cellIdentifier = @"FriendCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLUser *friend = [currentUser.friends objectAtIndex:indexPath.row];
        [cell setFriend:friend];
        [cell hideAddButton];
        return cell;
        
        if (indexPath.row == [transactions count]) {
            static LoadingCell *footerView;
            if (!footerView) {
                footerView = [LoadingCell new];
            }
            return footerView;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (controlTab.selectedSegmentIndex == 0) {
        if (transactions.count > indexPath.row) {
            FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
            [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
        }
    } else {
        FLUser *friend;
        
        friend = [currentUser.friends objectAtIndex:indexPath.row];
        
        if (friend) {
            [appDelegate showUser:friend inController:self];
        }
    }
}

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
}

- (void)updateTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    [rowsWithPaymentField removeObject:indexPath];
    [transactions replaceObjectAtIndex:indexPath.row withObject:transaction];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
}

- (void)commentTransactionAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:YES];
}

- (void)showPayementFieldAtIndex:(NSIndexPath *)indexPath {
    NSMutableSet *rowsToReload = [rowsWithPaymentField mutableCopy];
    
    [rowsWithPaymentField removeAllObjects];
    [rowsWithPaymentField addObject:indexPath];
    [rowsToReload addObject:indexPath];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:[rowsToReload allObjects] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (BOOL)transactionAlreadyLoaded:(FLTransaction *)transaction {
    if ([transactionsLoaded containsObject:[transaction transactionId]]) {
        return YES;
    }
    
    [transactionsLoaded addObject:[transaction transactionId]];
    
    return NO;
}

- (void)resetTransactionsLoaded {
    [transactionsLoaded removeAllObjects];
}

- (void)reloadTableView {
    [[Flooz sharedInstance] userTimeline:currentUser.userId success: ^(id result, NSString *nextPageUrl) {
        transactions = [result mutableCopy];
        _nextPageUrl = nextPageUrl;
        
        nextPageIsLoading = NO;
        
        [self didFilterChange];
    } failure:^(NSError *error) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    }];
}

- (void)didFilterChange {
    rowsWithPaymentField = [NSMutableSet new];
    [self.tableView reloadData];
}

- (void)loadNextPage {
    if (!_nextPageUrl || [_nextPageUrl isBlank]) {
        return;
    }
    
    nextPageIsLoading = YES;
    
    [[Flooz sharedInstance] timelineNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl) {
        [transactions addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self.tableView reloadData];
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    
    CGFloat offset = scroll.contentOffset.y;
    CATransform3D avatarTransform = CATransform3DIdentity;
    CATransform3D headerTransform = CATransform3DIdentity;
    
    if (offset < 0) {
        CGFloat headerScaleFactor = -(offset) / header.bounds.size.height;
        CGFloat headerSizevariation = ((header.bounds.size.height * (1.0 + headerScaleFactor)) - header.bounds.size.height)/2.0;
        
        headerTransform = CATransform3DTranslate(headerTransform, 0, headerSizevariation, 0);
        headerTransform = CATransform3DScale(headerTransform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0);
        
        header.layer.transform = headerTransform;
    } else {
        
        // Header -----------
        
        headerTransform = CATransform3DTranslate(headerTransform, 0,  MAX(-offset_HeaderStop, -offset), 0);
        
        //  ------------ Label
        
        CATransform3D labelTransform = CATransform3DMakeTranslation(0, MAX(-distance_W_LabelHeader, offset_B_LabelHeader - offset), 0);
        headerLabel.layer.transform = labelTransform;
        
        //  ------------ Blur
        
        headerBlurImageView.alpha =  MIN(1.0, (offset - offset_B_LabelHeader)/distance_W_LabelHeader);
        
        // Avatar -----------
        
        CGFloat avatarScaleFactor = (MIN(offset_HeaderStop, offset)) / avatarImage.bounds.size.height / 1.4; // Slow down the animation
        CGFloat avatarSizeVariation = ((avatarImage.bounds.size.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.size.height) / 2.0;
        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
        
        if (offset <= offset_HeaderStop) {
            if (avatarImage.layer.zPosition < header.layer.zPosition) {
                header.layer.zPosition = 0;
            }
        } else {
            if (avatarImage.layer.zPosition >= header.layer.zPosition) {
                header.layer.zPosition = 2;
            }
        }
    }
    
    header.layer.transform = headerTransform;
    avatarImage.layer.transform = avatarTransform;
}

@end
