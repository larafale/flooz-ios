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
#import "FLMultiLineSegmentedControl.h"
#import "EditProfileViewController.h"
#import "AccountViewController.h"
#import "FLPopupInformation.h"
#import "UIButton+Badge.h"

#define actionButtonHeight 30
#define actionButtonMargin 10

#define headerFullHeight 130
#define avatarSize 70
#define avatarMarginTop 100

#define offset_HeaderStop 65.0 // At this offset the Header stops its transformations
#define offset_B_LabelHeader ((avatarMarginTop + avatarSize) - offset_HeaderStop + 8) // At this offset the Black label reaches the Header
#define distance_W_LabelHeader (offset_B_LabelHeader - offset_HeaderStop) // The distance between the bottom of the Header and the top of the White Label

@interface UserViewController () {
    FLUserView *avatarImage;
    UIView *header;
    UILabel *headerLabel;
    UIButton *headerBack;
    UIImageView *headerImageView;
    UIImageView *headerBlurImageView;
    UIImageView *blurredHeaderImageView;
    
    UIButton *settingsButton;
    
    FLActionButton *unfriendPendingActionButton;
    FLActionButton *unfriendMiniActionButton;
    
    FLBorderedActionButton *friendActionButton;
    FLBorderedActionButton *friendRequestActionButton;
    
    FLBorderedActionButton *editProfileActionButton;
    
    BOOL transacLoaded;
    BOOL completeProfileLoaded;
    
    FLMultiLineSegmentedControl *controlTab;
    
    UIView *headerCell;
    
    UILabel *fullnameLabel;
    UILabel *usernameLabel;
    UILabel *bioLabel;
    UILabel *locationLabel;
    UILabel *websiteLabel;
    UIImageView *certfifiedIcon;
    
    NSMutableArray *transactions;
    
    NSString *_nextPageUrl;
    BOOL nextPageIsLoading;
    
    NSMutableSet *rowsWithPaymentField;
    NSMutableArray *cells;
    NSMutableArray *transactionsLoaded;
    
    CGFloat emptyCellHeight;
}

@end

@implementation UserViewController

@synthesize currentUser;

- (id)initWithUser:(FLUser*)user {
    self = [super init];
    if (self) {
        currentUser = user;
        transactions = [NSMutableArray new];
        rowsWithPaymentField = [NSMutableSet new];
        nextPageIsLoading = NO;
        transacLoaded = NO;
        completeProfileLoaded = NO;
        
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
    
    if (self.navigationController.viewControllers.count > 1)
        [_mainBody addSubview:headerBack];
    
    emptyCellHeight = CGRectGetHeight(self.tableView.frame) - CGRectGetHeight(headerCell.frame);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self reloadData];
    [self refreshData];
    [self registerNotification:@selector(refreshData) name:kNotificationReloadCurrentUser object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) refreshData {
    [[Flooz sharedInstance] getUserProfile:currentUser.userId success:^(FLUser *result) {
        if (result) {
            currentUser = result;
            currentUser.isComplete = YES;
        }
        [self reloadData];
    } failure:nil];
}

- (void)createHeader {
    header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), headerFullHeight)];
    [header setUserInteractionEnabled:YES];
    [header addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didHeaderClick)]];
    
    // Header - Back
    headerBack = [[UIButton alloc] initWithFrame:CGRectMake(0, PPStatusBarHeight() + 5, 30, 30)];
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
    headerImageView.image = [UIImage imageNamed:@"default-cover"];
    headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [headerImageView setUserInteractionEnabled:YES];
    //    [headerImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCoverClick:)]];
    
    [header insertSubview:headerImageView belowSubview:headerLabel];
    
    // Header - Blurred Image
    headerBlurImageView = [[UIImageView alloc] initWithFrame:header.bounds];
    headerBlurImageView.image =  [[UIImage imageNamed:@"default-cover"] blurredImageWithRadius:20 iterations:20 tintColor:[UIColor clearColor]];
    headerBlurImageView.contentMode = UIViewContentModeScaleAspectFill;
    headerBlurImageView.alpha = 0.0;
    [headerBlurImageView setUserInteractionEnabled:YES];
    //    [headerBlurImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didCoverClick:)]];
    
    [header insertSubview:headerBlurImageView belowSubview:headerLabel];
    
    header.clipsToBounds = true;
}

- (void)createHeaderCell {
    
    headerCell = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 0)];
    [headerCell setUserInteractionEnabled:YES];
    
    avatarImage = [[FLUserView alloc] initWithFrame:CGRectMake(10, avatarMarginTop, avatarSize, avatarSize)];
    [avatarImage setUserInteractionEnabled:YES];
    [avatarImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didAvatarClick)]];
    
    unfriendMiniActionButton = [FLSocialHelper createMiniUnfriendButton:self action:@selector(didUnFriendButtonClick:) position:CGPointMake(0, headerFullHeight + 10)];
    unfriendPendingActionButton = [FLSocialHelper createRequestPendingButton:self action:@selector(didFriendPendingButtonClick:) position:CGPointMake(0, headerFullHeight + 10)];
    
    friendActionButton = [FLSocialHelper createFullFriendButton:self action:@selector(didFriendButtonClick:) position:CGPointMake(0, headerFullHeight + 10)];
    friendRequestActionButton = [FLSocialHelper createFriendRequestButton:self action:@selector(didFriendRequestButtonClick:) position:CGPointMake(0, headerFullHeight + 10)];
    
    editProfileActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, 0, actionButtonHeight) title:NSLocalizedString(@"SETTINGS_PROFILE", nil)];
    editProfileActionButton.layer.cornerRadius = 5;
    [editProfileActionButton.titleLabel setFont:[UIFont customContentBold:15]];
    editProfileActionButton.badgeBGColor = [UIColor customBlue];
    editProfileActionButton.badgeFont = [UIFont customContentRegular:12];
    editProfileActionButton.badgeTextColor = [UIColor whiteColor];
    editProfileActionButton.shouldHideBadgeAtZero = YES;
    editProfileActionButton.shouldAnimateBadge = YES;
    CGFloat textWidth = [editProfileActionButton.titleLabel.text widthOfString:editProfileActionButton.titleLabel.font];
    CGRectSetWidth(editProfileActionButton.frame, textWidth + (2 * actionButtonMargin));
    [editProfileActionButton addTarget:self action:@selector(didSettingsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, headerFullHeight + 10, actionButtonHeight, actionButtonHeight)];
    [settingsButton setImage:[[UIImage imageNamed:@"cog"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [settingsButton setTintColor:[UIColor customPlaceholder]];
    [settingsButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [settingsButton addTarget:self action:@selector(showMenuForUser) forControlEvents:UIControlEventTouchUpInside];
    
    fullnameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(avatarImage.frame) + 10, PPScreenWidth() / 2, 20)];
    fullnameLabel.font = [UIFont customContentBold:18];
    fullnameLabel.textColor = [UIColor whiteColor];
    
    certfifiedIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(avatarImage.frame) + 11, 18, 18)];
    [certfifiedIcon setImage:[UIImage imageNamed:@"certified"]];
    [certfifiedIcon setContentMode:UIViewContentModeScaleAspectFit];
    
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(fullnameLabel.frame) + 3, PPScreenWidth() / 2, 15)];
    usernameLabel.font = [UIFont customContentBold:13];
    usernameLabel.textColor = [UIColor customGreyPseudo];
    
    bioLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(usernameLabel.frame) + 10, PPScreenWidth() - 20, 0)];
    bioLabel.font = [UIFont customContentRegular:15];
    bioLabel.textColor = [UIColor whiteColor];
    bioLabel.numberOfLines = 0;
    bioLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    locationLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bioLabel.frame) + 10, PPScreenWidth() - 20, 0)];
    locationLabel.numberOfLines = 1;
    
    websiteLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(bioLabel.frame) + 10, PPScreenWidth() - 20, 0)];
    websiteLabel.numberOfLines = 1;
    websiteLabel.userInteractionEnabled = YES;
    [websiteLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didWebsiteCLick)]];
    
    controlTab = [[FLMultiLineSegmentedControl alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(websiteLabel.frame) + 15, CGRectGetWidth(self.view.frame) - 2 * 10, 35)];
    [controlTab setTintColor:[UIColor customBlue]];
    [controlTab addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [controlTab setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [controlTab setTitleTextAttributes:@{NSFontAttributeName:[UIFont customContentRegular:14]} forState:UIControlStateNormal];
    
    [controlTab setMultilineTitle:[FLMultiLineSegmentedControl itemTitleWithText:@"Flooz" andStat:0] forSegmentAtIndex:0];
    [controlTab setMultilineTitle:[FLMultiLineSegmentedControl itemTitleWithText:NSLocalizedString(@"FRIEND", nil) andStat:0] forSegmentAtIndex:1];
    
    [controlTab setSelectedSegmentIndex:0];
    
    [headerCell addSubview:avatarImage];
    [headerCell addSubview:fullnameLabel];
    [headerCell addSubview:certfifiedIcon];
    [headerCell addSubview:usernameLabel];
    [headerCell addSubview:unfriendPendingActionButton];
    [headerCell addSubview:unfriendMiniActionButton];
    [headerCell addSubview:friendActionButton];
    [headerCell addSubview:friendRequestActionButton];
    [headerCell addSubview:editProfileActionButton];
    [headerCell addSubview:settingsButton];
    [headerCell addSubview:bioLabel];
    [headerCell addSubview:locationLabel];
    [headerCell addSubview:bioLabel];
    [headerCell addSubview:websiteLabel];
    [headerCell addSubview:controlTab];
    
    CGRectSetHeight(headerCell.frame, CGRectGetMaxY(controlTab.frame) + 10);
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadData {
    [self reloadTableView];
    
    if (!currentUser.isComplete)
        [self reloadMiniUser];
    else
        [self reloadUser];
}

- (void)reloadMiniUser {
    [headerLabel setText:[NSString stringWithFormat:@"%@\n@%@", currentUser.fullname, currentUser.username]];
    [avatarImage setImageFromUser:currentUser];
    
    [fullnameLabel setText:currentUser.fullname];
    [usernameLabel setText:[NSString stringWithFormat:@"@%@", currentUser.username]];
    
    [fullnameLabel setWidthToFit];
    [usernameLabel setWidthToFit];
    
    [editProfileActionButton setHidden:YES];
    [unfriendPendingActionButton setHidden:YES];
    [unfriendMiniActionButton setHidden:YES];
    [friendActionButton setHidden:YES];
    [friendRequestActionButton setHidden:YES];
    [settingsButton setHidden:YES];
    
    if (currentUser.isCertified) {
        [certfifiedIcon setHidden:NO];
        CGRectSetX(certfifiedIcon.frame, CGRectGetMaxX(fullnameLabel.frame) + 5);
    } else
        [certfifiedIcon setHidden:YES];
    
    [self.tableView reloadData];
}

- (void)reloadUser {
    completeProfileLoaded = YES;
    
    [editProfileActionButton setHidden:YES];
    [unfriendPendingActionButton setHidden:YES];
    [unfriendMiniActionButton setHidden:YES];
    [friendActionButton setHidden:YES];
    [friendRequestActionButton setHidden:YES];
    [settingsButton setHidden:YES];
    
    UIView *rightButton = nil;
    
    if (currentUser.actions) {
        CGFloat rightMargin = 10;
        
        if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound) {
            rightButton = friendActionButton;
        } else if ([currentUser.actions indexOfObject:@"friend:request"] != NSNotFound) {
            rightButton = friendRequestActionButton;
        } else if ([currentUser.actions indexOfObject:@"friend:pending"] != NSNotFound) {
            rightButton = unfriendPendingActionButton;
        } else if ([currentUser.actions indexOfObject:@"friend:remove"] != NSNotFound) {
            rightButton = unfriendMiniActionButton;
        } else if ([currentUser.actions indexOfObject:@"self"] != NSNotFound) {
            rightMargin = 15;
            int accountNotifs = 0;
            
            accountNotifs += [currentUser.metrics[@"accountMissing"] intValue];

            editProfileActionButton.badgeValue = [@(accountNotifs) stringValue];
            
            rightButton = editProfileActionButton;
        }
        
        if (rightButton) {
            [rightButton setHidden:NO];
            CGRectSetX(rightButton.frame, PPScreenWidth() - CGRectGetWidth(rightButton.frame) - rightMargin);
        }
        
        if ([currentUser.actions indexOfObject:@"settings"] != NSNotFound) {
            [settingsButton setHidden:NO];
            if (rightButton)
                CGRectSetX(settingsButton.frame, CGRectGetMinX(rightButton.frame) - CGRectGetWidth(settingsButton.frame) - 5);
            else
                CGRectSetX(settingsButton.frame, PPScreenWidth() - CGRectGetWidth(settingsButton.frame) - 15);
        }
    }
    
    [headerLabel setText:[NSString stringWithFormat:@"%@\n@%@", currentUser.fullname, currentUser.username]];
    
    if (currentUser.coverURL) {
        [headerImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.coverURL] placeholderImage:[UIImage imageNamed:@"default-cover"]];
        [headerBlurImageView sd_setImageWithURL:[NSURL URLWithString:currentUser.coverURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [headerBlurImageView setImage:[image blurredImageWithRadius:15 iterations:20 tintColor:[UIColor clearColor]]];
        }];
    }
    
    [avatarImage setImageFromUser:currentUser];
    
    [fullnameLabel setText:currentUser.fullname];
    [usernameLabel setText:[NSString stringWithFormat:@"@%@", currentUser.username]];
    
    [fullnameLabel setWidthToFit];
    [usernameLabel setWidthToFit];
    
    if (currentUser.isCertified) {
        [certfifiedIcon setHidden:NO];
        CGRectSetX(certfifiedIcon.frame, CGRectGetMaxX(fullnameLabel.frame) + 5);
    } else {
        [certfifiedIcon setHidden:YES];
    }
    
    [controlTab updateMultilineTitle:[FLMultiLineSegmentedControl itemTitleWithText:@"Flooz" andStat:currentUser.publicStats.nbFlooz] forSegmentAtIndex:0];
    
    if (currentUser.friends.count < 2)
        [controlTab updateMultilineTitle:[FLMultiLineSegmentedControl itemTitleWithText:NSLocalizedString(@"FRIEND", nil) andStat:currentUser.publicStats.nbFriends] forSegmentAtIndex:1];
    else
        [controlTab updateMultilineTitle:[FLMultiLineSegmentedControl itemTitleWithText:NSLocalizedString(@"FRIENDS", nil) andStat:currentUser.publicStats.nbFriends] forSegmentAtIndex:1];
    
    [bioLabel setText:currentUser.bio];
    CGRectSetHeight(bioLabel.frame, [bioLabel heightToFit] + 5);
    
    CGRectSetY(locationLabel.frame, CGRectGetMaxY(bioLabel.frame) + 10);
    CGRectSetY(websiteLabel.frame, CGRectGetMaxY(bioLabel.frame) + 10);
    
    CGFloat nextX = 0;
    
    if (currentUser.location && ![currentUser.location isBlank]) {
        locationLabel.hidden = NO;
        CGRectSetHeight(locationLabel.frame, 20);
        
        UIImage *image = [UIImage imageNamed:@"map"];
        CGSize newImgSize = CGSizeMake(16, 16);
        
        image = [FLHelper imageWithImage:image scaledToSize:newImgSize];
        image = [FLHelper colorImage:image color:[UIColor whiteColor]];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, -4, attachment.image.size.width, attachment.image.size.height);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] init];
        [string appendAttributedString:attachmentString];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", currentUser.location] attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont customContentRegular:14]}]];
        
        locationLabel.attributedText = string;
        
        nextX = [[NSString stringWithFormat:@" %@", currentUser.location] widthOfString:[UIFont customContentRegular:14]] + 20;
    } else {
        CGRectSetHeight(locationLabel.frame, 20);
        locationLabel.hidden = YES;
    }
    
    if (currentUser.website && ![currentUser.website isBlank]) {
        websiteLabel.hidden = NO;
        CGRectSetHeight(websiteLabel.frame, 20);
        CGRectSetY(controlTab.frame, CGRectGetMaxY(websiteLabel.frame) + 10);
        CGRectSetX(websiteLabel.frame, CGRectGetMinX(locationLabel.frame) + nextX + 10);
        CGRectSetWidth(websiteLabel.frame, PPScreenWidth() - CGRectGetMinX(websiteLabel.frame) - 10);
        
        UIImage *image = [UIImage imageNamed:@"link"];
        CGSize newImgSize = CGSizeMake(16, 16);
        
        image = [FLHelper imageWithImage:image scaledToSize:newImgSize];
        image = [FLHelper colorImage:image color:[UIColor whiteColor]];
        
        NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
        attachment.image = image;
        attachment.bounds = CGRectMake(0, -4, attachment.image.size.width, attachment.image.size.height);
        
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
        
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
        [string appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", currentUser.website] attributes:@{NSForegroundColorAttributeName: [UIColor customBlue], NSFontAttributeName: [UIFont customContentRegular:14]}]];
        
        websiteLabel.attributedText = string;
    } else {
        websiteLabel.hidden = YES;
        CGRectSetHeight(websiteLabel.frame, 0);
        
        if (currentUser.location && ![currentUser.location isBlank]) {
            CGRectSetY(controlTab.frame, CGRectGetMaxY(locationLabel.frame) + 10);
        } else {
            CGRectSetY(controlTab.frame, CGRectGetMaxY(bioLabel.frame) + 10);
        }
    }
    
    CGRectSetHeight(headerCell.frame, CGRectGetMaxY(controlTab.frame) + 10);
    
    [self.tableView reloadData];
}

#pragma marks - button handlers

- (void) didBalanceButtonClick {
    UIImage *cbImage = [UIImage imageNamed:@"picto-cb"];
    CGSize newImgSize = CGSizeMake(20, 14);
    
    UIGraphicsBeginImageContextWithOptions(newImgSize, NO, 0.0);
    [cbImage drawInRect:CGRectMake(0, 0, newImgSize.width, newImgSize.height)];
    cbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = cbImage;
    
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_1", nil)];
    [string appendAttributedString:attachmentString];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"WALLET_INFOS_CONTENT_2", nil)]];
    
    [[[FLPopupInformation alloc] initWithTitle:NSLocalizedString(@"WALLET_INFOS_TITLE", nil) andMessage:string ok:nil] show];
}

- (void) didSettingsButtonClick {
    [self.navigationController pushViewController:[AccountViewController new] animated:YES];
}

- (void) didWebsiteCLick {
    if (currentUser.website && ![currentUser.website isBlank]) {
        NSString *urlString = [currentUser.website copy];
        
        if ([urlString rangeOfString:@"http://"].location == NSNotFound && [urlString rangeOfString:@"https://"].location == NSNotFound)
            urlString = [NSString stringWithFormat:@"http://%@", urlString];
        
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void) didEditProfileButtonClick {
    [self.navigationController pushViewController:[EditProfileViewController new] animated:YES];
}

- (void) didHeaderClick {
    [_tableView setContentOffset:CGPointZero animated:YES];
}

- (void) didAvatarClick {
    if (currentUser.avatarURL) {
        if (currentUser.avatarLargeURL)
            [appDelegate showAvatarView:avatarImage withUrl:[NSURL URLWithString:currentUser.avatarLargeURL]];
        else
            [appDelegate showAvatarView:avatarImage withUrl:[NSURL URLWithString:currentUser.avatarURL]];
    } else if ([currentUser.actions indexOfObject:@"self"] != NSNotFound) {
        [self showMenuPhoto];
    }
}

- (void) didCoverClick:(id)sender {
    if (currentUser.coverURL) {
        if (currentUser.coverLargeURL)
            [appDelegate showAvatarView:avatarImage withUrl:[NSURL URLWithString:currentUser.coverLargeURL]];
        else
            [appDelegate showAvatarView:avatarImage withUrl:[NSURL URLWithString:currentUser.coverURL]];
    } else if ([currentUser.actions indexOfObject:@"self"] != NSNotFound) {
        
    }
}

- (void) didUnFriendButtonClick:(id)sender {
    [self showUnfriendMenu];
}

- (void) didFriendButtonClick:(id)sender {
    [[Flooz sharedInstance] friendAdd:currentUser.userId success:^{
    } failure:^(NSError *error) {
        if ([currentUser.actions indexOfObject:@"friend:pending"] != NSNotFound)
            [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:pending"] withObject:@"friend:add"];
        [self reloadData];
    }];
    if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
        [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:pending"];
    [self reloadData];
}

- (void) didFriendRequestButtonClick:(id)sender {
    [self showRequestMenu];
}

- (void) didFriendPendingButtonClick:(id)sender {
    [self showPendingMenu];
}


#pragma marks - segmented control handler

- (void)segmentedControlValueChanged:(UISegmentedControl*)sender {
    [self.tableView reloadData];
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (controlTab.selectedSegmentIndex == 0) {
        if (transacLoaded) {
            if (_nextPageUrl && ![_nextPageUrl isBlank]) {
                return [transactions count] + 1;
            } else if ([transactions count])
                return [transactions count];
            else
                return 1;
        } else
            return 1;
    } else if (!completeProfileLoaded)
        return 1;
    else {
        if (currentUser.friends.count)
            return currentUser.friends.count;
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (controlTab.selectedSegmentIndex == 0) {
        if (transacLoaded) {
            if ([transactions count]) {
                if (indexPath.row >= [transactions count]) {
                    return [LoadingCell getHeight];
                }
                
                FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
                return [TransactionCell getHeightForTransaction:transaction andWidth:CGRectGetWidth(tableView.frame)];
            } else {
                return emptyCellHeight;
            }
        } else
            return [LoadingCell getHeight];
    } else if (!completeProfileLoaded)
        return [LoadingCell getHeight];
    else {
        if (currentUser.friends.count)
            return [FriendCell getHeight];
        else
            return emptyCellHeight;
    }
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
        if (transacLoaded) {
            if (transactions.count) {
                if (indexPath.row == [transactions count]) {
                    static LoadingCell *footerView;
                    if (!footerView) {
                        footerView = [LoadingCell new];
                    }
                    return footerView;
                }
                
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
                return [self generateEmptyTimelineCell];
            }
        } else {
            return [LoadingCell new];
        }
    } else if (!completeProfileLoaded) {
        return [LoadingCell new];
    } else {
        if (controlTab.selectedSegmentIndex == 1 && currentUser.friends.count == 0)
            return [self generateEmptyFriendsCell];
        
        static NSString *cellIdentifier = @"FriendCell";
        FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[FriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        FLUser *friend = [currentUser.friends objectAtIndex:indexPath.row];
        
        [cell setFriend:friend];
        [cell hideAddButton];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (controlTab.selectedSegmentIndex == 0) {
        if (transacLoaded) {
            if (transactions.count > indexPath.row) {
                FLTransaction *transaction = [transactions objectAtIndex:indexPath.row];
                [appDelegate showTransaction:transaction inController:self withIndexPath:indexPath focusOnComment:NO];
            }
        }
    } else if (completeProfileLoaded) {
        FLUser *friend;
        
        if (controlTab.selectedSegmentIndex == 1 && currentUser.friends.count)
            friend = [currentUser.friends objectAtIndex:indexPath.row];
        
        if (friend) {
            [appDelegate showUser:friend inController:self];
        }
    }
}

- (void)didTransactionTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
}

- (void)didTransactionUserTouchAtIndex:(NSIndexPath *)indexPath transaction:(FLTransaction *)transaction {
    if (![transaction.starter.userId isEqualToString:currentUser.userId])
        [appDelegate showUser:transaction.starter inController:self];
    else
        [self shakeView];
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
    if (currentUser && (!transactions || !transactions.count)) {
        [[Flooz sharedInstance] userTimeline:currentUser.userId success: ^(id result, NSString *nextPageUrl) {
            transactions = [result mutableCopy];
            _nextPageUrl = nextPageUrl;
            
            nextPageIsLoading = NO;
            transacLoaded = YES;
            [self didFilterChange];
        } failure:^(NSError *error) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }];
    }
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
    
    [[Flooz sharedInstance] timelineNextPage:_nextPageUrl success: ^(id result, NSString *nextPageUrl, TransactionScope scope) {
        [transactions addObjectsFromArray:result];
        _nextPageUrl = nextPageUrl;
        nextPageIsLoading = NO;
        [self.tableView reloadData];
    }];
}

- (UITableViewCell *) generateEmptyTimelineCell {
    static UITableViewCell *emptyCell;
    
    if (!emptyCell) {
        emptyCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), emptyCellHeight)];
        [emptyCell setBackgroundColor:[UIColor clearColor]];
        [emptyCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *text = [[UILabel alloc] initWithText:NSLocalizedString(@"EMPTY_TIMELINE", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        [text setWidthToFit];
        
        CGRectSetY(text.frame, emptyCellHeight / 2 - CGRectGetHeight(text.frame) / 2);
        CGRectSetX(text.frame, PPScreenWidth() / 2 - CGRectGetWidth(text.frame) / 2);
        
        [emptyCell addSubview:text];
    }
    
    return emptyCell;
}

- (UITableViewCell *) generateEmptyFriendsCell {
    static UITableViewCell *emptyCell;
    
    if (!emptyCell) {
        emptyCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), emptyCellHeight)];
        [emptyCell setBackgroundColor:[UIColor clearColor]];
        [emptyCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        UILabel *text = [[UILabel alloc] initWithText:NSLocalizedString(@"EMPTY_FRIENDS", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentBold:17] textAlignment:NSTextAlignmentCenter numberOfLines:1];
        
        [text setWidthToFit];
        
        CGRectSetY(text.frame, emptyCellHeight / 2 - CGRectGetHeight(text.frame) / 2);
        CGRectSetX(text.frame, PPScreenWidth() / 2 - CGRectGetWidth(text.frame) / 2);
        
        [emptyCell addSubview:text];
    }
    
    return emptyCell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scroll {
    
    CGFloat offset = scroll.contentOffset.y;
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
        
        //        CGFloat avatarScaleFactor = (MIN(offset_HeaderStop, offset)) / avatarImage.bounds.size.height / 1.8; // Slow down the animation
        //        CGFloat avatarSizeVariation = ((avatarImage.bounds.size.height * (1.0 + avatarScaleFactor)) - avatarImage.bounds.size.height) / 2.0;
        //        avatarTransform = CATransform3DTranslate(avatarTransform, 0, avatarSizeVariation, 0);
        //        avatarTransform = CATransform3DScale(avatarTransform, 1.0 - avatarScaleFactor, 1.0 - avatarScaleFactor, 0);
        
        if (offset <= offset_HeaderStop) {
            if (avatarImage.layer.zPosition < header.layer.zPosition) {
                header.layer.zPosition = 0;
                
                [_mainBody sendSubviewToBack:header];
            }
        } else {
            if (avatarImage.layer.zPosition >= header.layer.zPosition) {
                header.layer.zPosition = 2;
                
                [_mainBody sendSubviewToBack:self.tableView];
            }
        }
    }
    
    header.layer.transform = headerTransform;
}

#pragma marks - unfollow menu

- (void)showUnfriendMenu {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createUnfriendActionSheet];
    else
        [self createUnfriendAlertController];
}

- (void)createUnfriendAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:currentUser.fullname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UNFRIEND", nil) style:UIAlertActionStyleDestructive handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
            
        } failure:^(NSError *error) {
            if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:remove"];
            [self reloadData];
        }];
        if ([currentUser.actions indexOfObject:@"friend:remove"] != NSNotFound)
            [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:remove"] withObject:@"friend:add"];
        [self reloadData];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createUnfriendActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"UNFOLLOW", nil)];
    [actionSheet setDestructiveButtonIndex:index];
    
    index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:2];
    
    [actionSheet showInView:appDelegate.window];
}

#pragma marks - request menu

- (void)showRequestMenu {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createRequestActionSheet];
    else
        [self createRequestAlertController];
}

- (void)createRequestAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:currentUser.fullname message:NSLocalizedString(@"FRIENDS_FRIENDS_REQUEST_MESSAGE", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"accept" } success:nil failure:^(NSError *error) {
            if ([currentUser.actions indexOfObject:@"unfriend"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:remove"] withObject:@"friend:request"];
            [self reloadData];
        }];
        if ([currentUser.actions indexOfObject:@"friend:request"] != NSNotFound)
            [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:request"] withObject:@"friend:remove"];
        [self reloadData];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil) style:UIAlertActionStyleDestructive handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"decline" } success: ^{
            
        } failure:^(NSError *error) {
            if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:request"];
            [self reloadData];
        }];
        if ([currentUser.actions indexOfObject:@"friend:request"] != NSNotFound)
            [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:request"] withObject:@"friend:add"];
        [self reloadData];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createRequestActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_ACCEPT", nil)];
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"FRIEND_REQUEST_REFUSE", nil)];
    
    [actionSheet setDestructiveButtonIndex:index];
    
    index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:3];
    
    [actionSheet showInView:appDelegate.window];
}

#pragma marks - pending menu

- (void)showPendingMenu {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createPendingActionSheet];
    else
        [self createPendingAlertController];
}

- (void)createPendingAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:currentUser.fullname message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"UNREQUEST", nil) style:UIAlertActionStyleDestructive handler: ^(UIAlertAction *action) {
        [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
        } failure:^(NSError *error) {
            if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:pending"];
            [self reloadData];
            
        }];
        if ([currentUser.actions indexOfObject:@"friend:pending"] != NSNotFound)
            [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:pending"] withObject:@"friend:add"];
        [self reloadData];
    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createPendingActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"UNFOLLOW", nil)];
    [actionSheet setDestructiveButtonIndex:index];
    
    index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:4];
    
    [actionSheet showInView:appDelegate.window];
}

#pragma mark - avatar

- (void)showMenuPhoto {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)) {
        [self createAvatarActionSheet];
    }
    else {
        [self createAvatarAlertController];
    }
}

- (void)createAvatarAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentPhoto];
        }]];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self presentLibrary];
        }]];
    }
    //    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
    //        [self getPhotoFromFacebook];
    //    }]];
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createAvatarActionSheet {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil, nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == YES) {
        [menus addObject:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)];
    }
    //    [menus addObject:NSLocalizedString(@"SIGNUP_PHOTO_FACEBOOK", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:5];
    [actionSheet showInView:self.view];
}

#pragma marks - user menu

- (void)showMenuForUser {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending))
        [self createActionSheet];
    else
        [self createAlertController];
}

- (void)createAlertController {
    UIAlertController *newAlert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([currentUser.actions indexOfObject:@"flooz"] != NSNotFound) {
        [newAlert addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:NSLocalizedString(@"MENU_NEW_FLOOZ", nil), currentUser.username] style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [appDelegate showNewTransactionController:currentUser transactionType:TransactionTypePayment];
        }]];
    }
    
    if ([currentUser.actions indexOfObject:@"report"] != NSNotFound) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_REPORT_USER", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self showReportView:[[FLReport alloc] initWithType:ReportUser id:currentUser.userId]];
        }]];
    }
    
    if ([currentUser.actions indexOfObject:@"block"] != NSNotFound) {
        [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"MENU_BLOCK_USER", nil) style:UIAlertActionStyleDefault handler: ^(UIAlertAction *action) {
            [self showBlockView];
        }]];
    }
    
    [newAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil) style:UIAlertActionStyleCancel handler:NULL]];
    
    [self presentViewController:newAlert animated:YES completion:nil];
}

- (void)createActionSheet {
    UIActionSheet *actionSheet = actionSheet = [[UIActionSheet alloc] initWithTitle:currentUser.fullname delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:NSLocalizedString(@"MENU_NEW_FLOOZ", nil), currentUser.username], nil];
    NSMutableArray *menus = [NSMutableArray new];
    
    [menus addObject:NSLocalizedString(@"MENU_BLOCK_USER", nil)];
    
    [menus addObject:NSLocalizedString(@"MENU_REPORT_USER", nil)];
    
    for (NSString *menu in menus) {
        [actionSheet addButtonWithTitle:menu];
    }
    
    NSUInteger index = [actionSheet addButtonWithTitle:NSLocalizedString(@"GLOBAL_CANCEL", nil)];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet setTag:1];
    
    [actionSheet showInView:appDelegate.window];
}

#pragma marks - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:[NSString stringWithFormat:NSLocalizedString(@"MENU_NEW_FLOOZ", nil), currentUser.username]]) {
            [appDelegate showNewTransactionController:currentUser transactionType:TransactionTypePayment];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_BLOCK_USER", nil)]) {
            [self showBlockView];
        }
        else if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"MENU_REPORT_USER", nil)]) {
            [self showReportView:[[FLReport alloc] initWithType:ReportUser id:currentUser.userId]];
        }
    } else if (actionSheet.tag == 2) {
        if (buttonIndex == 0) {
            [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
            } failure:^(NSError *error) {
                if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                    [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:remove"];
                [self reloadData];
            }];
            if ([currentUser.actions indexOfObject:@"friend:remove"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:remove"] withObject:@"friend:add"];
            [self reloadData];
        }
    } else if (actionSheet.tag == 3) {
        if (buttonIndex == 0) {
            [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"accept" } success:nil failure:^(NSError *error) {
                if ([currentUser.actions indexOfObject:@"friend:remove"] != NSNotFound)
                    [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:remove"] withObject:@"friend:request"];
                [self reloadData];
            }];
            if ([currentUser.actions indexOfObject:@"friend:request"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:request"] withObject:@"friend:remove"];
            [self reloadData];
        } else if (buttonIndex == 1) {
            [[Flooz sharedInstance] updateFriendRequest:@{ @"id": currentUser.userId, @"action": @"decline" } success: ^{
            } failure:^(NSError *error) {
                if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                    [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:request"];
                [self reloadData];
                
            }];
            if ([currentUser.actions indexOfObject:@"friend:request"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:request"] withObject:@"friend:add"];
            [self reloadData];
        }
    } else if (actionSheet.tag == 4) {
        if (buttonIndex == 0) {
            [[Flooz sharedInstance] friendRemove:currentUser.userId success:^{
            } failure:^(NSError *error) {
                if ([currentUser.actions indexOfObject:@"friend:add"] != NSNotFound)
                    [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:add"] withObject:@"friend:pending"];
                [self reloadData];
                
            }];
            if ([currentUser.actions indexOfObject:@"friend:pending"] != NSNotFound)
                [currentUser.actions replaceObjectAtIndex:[currentUser.actions indexOfObject:@"friend:pending"] withObject:@"friend:add"];
            [self reloadData];
        }
    } else if (actionSheet.tag == 5) {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_CAPTURE_BUTTON", nil)]) {
            [self presentPhoto];
        }
        else if ([buttonTitle isEqualToString:NSLocalizedString(@"SIGNUP_ALBUM_BUTTON", nil)]) {
            [self presentLibrary];
        }
    }
}

#pragma marks - alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 10) {
        if (buttonIndex == 1) {
            [[Flooz sharedInstance] reportContent:[[FLReport alloc] initWithType:ReportUser id:currentUser.userId]];
        }
    }
    else if (alertView.tag == 11) {
        if (buttonIndex == 1) {
            [[Flooz sharedInstance] blockUser:currentUser.userId];
        }
    }
}

- (void)showReportView:(FLReport *)report {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_REPORT", nil) message:(report.reportType == ReportUser ? NSLocalizedString(@"MENU_REPORT_USER_CONTENT", nil) : NSLocalizedString(@"MENU_REPORT_LINE_CONTENT", nil)) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
    alertView.tag = 10;
    [alertView show];
}

- (void)showBlockView {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"MENU_BLOCK_USER", nil) message:NSLocalizedString(@"MENU_BLOCK_USER_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_NO", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_YES", nil), nil];
    alertView.tag = 11;
    [alertView show];
}

- (void)shakeView {
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.values = @[
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(-4., 0., 0.)],
                    [NSValue valueWithCATransform3D:CATransform3DMakeTranslation(4., 0., 0.)]
                    ];
    anim.autoreverses = YES;
    anim.repeatCount = 2.;
    anim.delegate = self;
    anim.duration = 0.1;
    [self.view.layer addAnimation:anim forKey:nil];
}

- (void)presentPhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusAuthorized) {
        UIImagePickerController *cameraUI = [UIImagePickerController new];
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
        cameraUI.delegate = self;
        cameraUI.allowsEditing = YES;
        [self presentViewController:cameraUI animated:YES completion: ^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }];
    } else if (authStatus == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted){
                UIImagePickerController *cameraUI = [UIImagePickerController new];
                cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
                cameraUI.delegate = self;
                cameraUI.allowsEditing = YES;
                [self presentViewController:cameraUI animated:YES completion: ^{
                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                }];
            } else {
                
            }
        }];
    } else {
        UIAlertView* curr = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ERROR_ACCESS_CAMERA_TITLE", nil) message:NSLocalizedString(@"ERROR_ACCESS_CAMERA_CONTENT", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"GLOBAL_OK", nil) otherButtonTitles:NSLocalizedString(@"GLOBAL_SETTINGS", nil), nil];
        [curr setTag:125];
        dispatch_async(dispatch_get_main_queue(), ^{
            [curr show];
        });
    }
}

- (void)presentLibrary {
    UIImagePickerController *cameraUI = [UIImagePickerController new];
    cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    cameraUI.delegate = self;
    cameraUI.allowsEditing = YES;
    [self presentViewController:cameraUI animated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }];
}

- (UIImage *)resizeImage:(UIImage *)image {
    CGRect rect = CGRectMake(0.0, 0.0, 640.0, 640.0);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    
    UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizedImage;
    
    if (editedImage)
        resizedImage = [editedImage resize:CGSizeMake(640, 0)];
    else
        resizedImage = [originalImage resize:CGSizeMake(640, 0)];
    
    NSData *imageData = UIImageJPEGRepresentation(resizedImage, 0.7);
    
    [self sendData:imageData];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendData:(NSData *)imageData {
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] uploadDocument:imageData field:@"picId" success:^{
        [avatarImage setImageFromData:imageData];
        [[Flooz sharedInstance] updateCurrentUser];
    } failure:^(NSError *error) {
        
    }];
}

@end
