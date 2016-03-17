//
//  CollectViewController.m
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CollectViewController.h"
#import "YLProgressBar.h"
#import "CommentCell.h"

@interface CollectViewController () {
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    BOOL focusOnCommentTextField;
    CGFloat headerSize;
    
    CollectHeaderView *tableHeaderView;
    UIView *tableHeaderBackgroundView;
    UIImageView *attachmentView;
    YLProgressBar *attachmentProgressBar;
    FLUserView *avatarView;
    UILabel *starterName;
    
    UIView *toolbar;
    FLActionButton *participateButton;
    FLActionButton *closeButton;
    UIButton *shareButton;
    UIButton *commentButton;
}

@end

@implementation CollectViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        focusOnCommentTextField = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createHeader];
    [self createViews];
    
    [self prepareViews];
    
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTransaction:) name:kNotificationRefreshTransaction object:nil];
}

- (void)refreshTransaction:(NSNotification *)notification {
    [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success: ^(id result) {
        
    }];
}

#pragma mark - Views

- (void)createHeader {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[[UIImage imageNamed:@"cog"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 25, 25);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [btn setTintColor:[UIColor customBlue]];
    [btn addTarget:self action:@selector(showReportMenu) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *reportBarButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = reportBarButton;
    
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPTabBarHeight())];
        
        UIImageView *scopeImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        [scopeImage setTintColor:[UIColor whiteColor]];
        
        NSString *imageNamed = @"";
        if (_transaction.social.scope == SocialScopeFriend) {
            imageNamed = @"transaction-scope-friend";
        }
        else if (_transaction.social.scope == SocialScopePrivate) {
            imageNamed = @"transaction-scope-private";
        }
        else if (_transaction.social.scope == SocialScopePublic) {
            imageNamed = @"transaction-scope-public";
        }
        
        [scopeImage setImage:[[UIImage imageNamed:imageNamed] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        
        UILabel *headerMoment = [[UILabel alloc] initWithText:[FLHelper momentWithDate:[_transaction date]] textColor:[UIColor whiteColor] font:[UIFont customContentLight:12] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        
        CGFloat momentWidth = [headerMoment.text widthOfString:headerMoment.font];
        
        CGFloat headerWidth = momentWidth + CGRectGetWidth(scopeImage.frame) + 5;
        
        CGRectSetWidth(view.frame, headerWidth);
        
        [view addSubview:scopeImage];
        [view addSubview:headerMoment];
        
        CGRectSetX(headerMoment.frame, CGRectGetWidth(scopeImage.frame) + 5);
        CGRectSetHeight(headerMoment.frame, PPTabBarHeight());
        CGRectSetY(scopeImage.frame, PPTabBarHeight() / 2 - CGRectGetHeight(scopeImage.frame) / 2);
        
        self.navigationItem.titleView = view;
    }
}

- (void)createViews {
    _mainBody.backgroundColor = [UIColor customBackground];
    
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - PPToolBarHeight()) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    headerSize = 150.0f;
    if (_transaction.attachmentURL == nil || [_transaction.attachmentURL isBlank])
        headerSize = 50.0f;
    
    tableHeaderView = [[CollectHeaderView alloc] initWithCollect:_transaction parentController:self];
    
    tableHeaderBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), headerSize)];
    tableHeaderBackgroundView.backgroundColor = [UIColor customBackgroundHeader];
    
    attachmentView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableHeaderBackgroundView.frame), CGRectGetHeight(tableHeaderBackgroundView.frame))];
    attachmentView.contentMode = UIViewContentModeScaleAspectFill;
    
    attachmentProgressBar = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableHeaderBackgroundView.frame), CGRectGetHeight(tableHeaderBackgroundView.frame))];
    attachmentProgressBar.type = YLProgressBarTypeFlat;
    attachmentProgressBar.stripesOrientation = YLProgressBarStripesOrientationRight;
    attachmentProgressBar.stripesDirection   = YLProgressBarStripesDirectionRight;
    attachmentProgressBar.stripesAnimated = YES;
    attachmentProgressBar.stripesColor = [UIColor customBlue:0.70];
    attachmentProgressBar.stripesWidth = 30;
    attachmentProgressBar.stripesDelta = 15;
    attachmentProgressBar.stripesAnimationVelocity = 1.5;
    attachmentProgressBar.progressTintColor  = [UIColor customBackgroundHeader];
    attachmentProgressBar.behavior = YLProgressBarBehaviorWaiting;
    attachmentProgressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeNone;
    
    avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(tableHeaderBackgroundView.frame) - 40, 30, 30)];
    
    starterName = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarView.frame) + 5, CGRectGetMinY(avatarView.frame), PPScreenWidth() - CGRectGetMaxX(avatarView.frame) - 25, CGRectGetHeight(avatarView.frame))];
    starterName.font = [UIFont customContentRegular:17];
    starterName.textColor = [UIColor whiteColor];
    starterName.shadowColor = [UIColor customBackgroundHeader];
    starterName.shadowOffset = CGSizeMake(-0.1, -0.3);
    
    [tableHeaderBackgroundView addSubview:attachmentView];
    [tableHeaderBackgroundView addSubview:attachmentProgressBar];
    [tableHeaderBackgroundView addSubview:avatarView];
    [tableHeaderBackgroundView addSubview:starterName];
    
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    toolbar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(_mainBody.frame) - 50, PPScreenWidth(), 50)];
    toolbar.backgroundColor = [UIColor customBackgroundHeader];
    toolbar.layer.shadowColor = [UIColor blackColor].CGColor;
    toolbar.layer.shadowOpacity = .3;
    toolbar.layer.shadowOffset = CGSizeMake(0, -2);
    toolbar.layer.shadowRadius = 1;
    toolbar.clipsToBounds = NO;

    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:toolbar.bounds];

    toolbar.layer.shadowPath = shadowPath.CGPath;

    shareButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50 - 10)];
    [shareButton setImage:[[UIImage imageNamed:@"share-native"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tintColor = [UIColor whiteColor];
    shareButton.contentMode = UIViewContentModeScaleAspectFit;
    [toolbar addSubview:shareButton];
    
    participateButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_PARTICIPATE", nil)];
    participateButton.titleLabel.font = [UIFont customTitleLight:16];
    [participateButton addTarget:self action:@selector(participateButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:participateButton];

    closeButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_CLOSE", nil)];
    closeButton.titleLabel.font = [UIFont customTitleLight:16];
    [closeButton addTarget:self action:@selector(closeButtonClick) forControlEvents:UIControlEventTouchUpInside];
    closeButton.backgroundColor = [UIColor customRed];
    [toolbar addSubview:closeButton];

    [_mainBody addSubview:tableHeaderBackgroundView];
    [_mainBody addSubview:self.tableView];
    [_mainBody addSubview:toolbar];
}

- (void)prepareViews {
    if (_transaction.attachmentURL && ![_transaction.attachmentURL isBlank]) {
        attachmentProgressBar.hidden = NO;
        [attachmentProgressBar setProgress:1 animated:YES];
        attachmentView.hidden = YES;
        [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_transaction.attachmentURL] options:0 progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            attachmentProgressBar.hidden = YES;
            attachmentView.hidden = NO;
            attachmentView.image = image;
        }];
    } else {
        attachmentProgressBar.hidden = YES;
        attachmentView.hidden = YES;
    }
    
    [avatarView setUser:_transaction.starter];
    [starterName setText:_transaction.starter.fullname];
    
    if (_transaction.isAvailable && _transaction.isClosable) {
        participateButton.hidden = NO;
        closeButton.hidden = NO;
        
        CGRectSetWidth(participateButton.frame, (PPScreenWidth() - 120) / 2 - 5);
        CGRectSetX(closeButton.frame, PPScreenWidth() / 2 + 5);
        CGRectSetWidth(closeButton.frame, (PPScreenWidth() - 120) / 2 - 5);
        
        participateButton.titleLabel.font = [UIFont customTitleLight:16];
        closeButton.titleLabel.font = [UIFont customTitleLight:16];
    } else if (_transaction.isAvailable) {
        participateButton.hidden = NO;
        closeButton.hidden = YES;
        
        CGRectSetWidth(participateButton.frame, PPScreenWidth() - 120);
        CGRectSetX(closeButton.frame, 60);
        CGRectSetWidth(closeButton.frame, PPScreenWidth() - 120);
        participateButton.titleLabel.font = [UIFont customTitleLight:18];
    } else if (_transaction.isClosable) {
        participateButton.hidden = YES;
        closeButton.hidden = NO;
        
        CGRectSetWidth(participateButton.frame, PPScreenWidth() - 120);
        CGRectSetWidth(closeButton.frame, PPScreenWidth() - 120);
        closeButton.titleLabel.font = [UIFont customTitleLight:18];
    }
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    
    return _transaction.social.commentsCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return 50;
    
    return [CommentCell getHeight:_transaction.comments[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0)
        return CGFLOAT_MIN;
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor customBackground];
    
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString *cellIdentifier = @"CollectFromsCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor customBackgroundHeader];
            cell.textLabel.font = [UIFont customContentRegular:15];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }

        if (_transaction.participants && _transaction.participants.count) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            if (_transaction.participants.count == 1)
                cell.textLabel.text = @"1 Participant";
            else
                cell.textLabel.text = [NSString stringWithFormat:@"%lu Participants", (unsigned long)_transaction.participants.count];
        } else {
            cell.textLabel.text = @"0 Participant";
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        CGRectSetY(cell.textLabel.frame, [self tableView:tableView heightForRowAtIndexPath:indexPath] / 2 - CGRectGetHeight(cell.textLabel.frame) / 2);
        CGRectSetHeight(cell.frame, [self tableView:tableView heightForRowAtIndexPath:indexPath]);

        return cell;
    } else {
        static NSString *cellIdentifier = @"CollectFromsCell";
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (!cell) {
            cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        [cell loadWithComment:_transaction.comments[indexPath.row]];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGRect headerImageFrame = tableHeaderBackgroundView.frame;
    
    if (scrollOffset < 0) {
        // Adjust image proportionally
        headerImageFrame.size.height = headerSize - scrollOffset;
    } else {
        // We're scrolling up, return to normal behavior
        headerImageFrame.size.height = headerSize;
    }
    
    CGRectSetHeight(attachmentProgressBar.frame, headerImageFrame.size.height);
    CGRectSetHeight(attachmentView.frame, headerImageFrame.size.height);
    CGRectSetY(avatarView.frame, headerImageFrame.size.height - 40);
    CGRectSetY(starterName.frame, headerImageFrame.size.height - 40);
    tableHeaderBackgroundView.frame = headerImageFrame;
}

#pragma mark - Actions

- (void)commentButtonClick {
    
}

- (void)shareButtonClick {
    
}

- (void)closeButtonClick {
    
}

- (void)participateButtonClick {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:_transaction.json[@"triggers"]]];
}

- (void)showReportMenu {
    [appDelegate showReportMenu:[[FLReport alloc] initWithType:ReportTransaction transac:_transaction]];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
}

- (void)keyboardWillDisappear {
    //    _contentView.contentInset = UIEdgeInsetsZero;
}

@end
