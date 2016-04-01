//
//  CollectViewController.m
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "TransactionViewController.h"
#import "YLProgressBar.h"
#import "CommentCell.h"
#import "FXBlurView.h"
#import "TUSafariActivity.h"
#import "ARChromeActivity.h"
#import "FLCopyLinkActivity.h"
#import "CollectParticipantViewController.h"
#import "CollectParticipationViewController.h"
#import "ShareLinkViewController.h"
#import "FLTextViewComment.h"
#import "FLSocialButton.h"
#import "TransactionHeaderView.h"

@interface TransactionViewController () {
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    BOOL focusOnCommentTextField;
    CGFloat headerSize;
    
    TransactionHeaderView *tableHeaderView;
    
    UIView *toolbar;
    FLActionButton *acceptButton;
    FLActionButton *declineButton;
    FLTextViewComment *commentTextField;
    UIButton *shareButton;
    UIButton *closeCommentButton;
    UIButton *sendCommentButton;
    UIButton *commentButton;
    NSMutableDictionary *commentData;
    FLSocialButton *likeToolbarButton;
    FLSocialButton *commentToolbarButton;
    FLSocialButton *moreToolbarButton;
    
    UIView *scopeHelper;
    UILabel *scopeHelperLabel;

    CGFloat keyboardHeight;
    BOOL isCommenting;
    BOOL sendPressed;
    
    UIView *socialToolbar;
}

@end

@implementation TransactionViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        focusOnCommentTextField = NO;
        commentData = [NSMutableDictionary new];
    }
    return self;
}

- (NSString *)currentId {
    return _transaction.transactionId;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sendPressed = NO;
    
    [self createHeader];
    [self createViews];
    
    [self prepareViews];
    
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTransaction) name:kNotificationRefreshTransaction object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTransaction) name:kNotificationReloadTimeline object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (focusOnCommentTextField) {
        [self focusComment];
    }
    
    if (_tableView.contentOffset.y < [tableHeaderView headerSize])
        [(FLNavigationController*)self.navigationController hideShadow];
}

- (void)focusComment {
    if (_transaction.actions.count) {
        isCommenting = YES;
        [self prepareViews];
        [commentTextField becomeFirstResponder];
    } else {
        [commentTextField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    focusOnCommentTextField = NO;
}

- (void)refreshTransaction {
    [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success:^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    }];
}

#pragma mark - Views

- (void)createHeader {
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
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[[UIImage imageNamed:imageNamed] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 20, 20);
    [btn setTintColor:[UIColor customWhite]];
    [btn addTarget:self action:@selector(showScopeHelper) forControlEvents:UIControlEventTouchUpInside];

    UIBarButtonItem *scopeButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItem = scopeButton;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPTabBarHeight())];
    
    NSString *headerString;
    
    if (_transaction.amountText && _transaction.amountText.length) {
        headerString = [NSString stringWithFormat:@"%@ ⋅ %@", _transaction.amountText, [FLHelper momentWithDate:[_transaction date]]];
    } else
        headerString = [FLHelper momentWithDate:[_transaction date]];
    
    UILabel *headerMoment = [[UILabel alloc] initWithText:headerString textColor:[UIColor whiteColor] font:[UIFont customContentLight:12] textAlignment:NSTextAlignmentLeft numberOfLines:1];
    
    CGFloat headerWidth = CGRectGetWidth(headerMoment.frame);
    
    CGRectSetWidth(view.frame, headerWidth);
    
    CGFloat midHeight = PPTabBarHeight() / 2;
    
    CGRectSetXY(headerMoment.frame, 0, midHeight - CGRectGetHeight(headerMoment.frame) / 2 - 2);
    
    [view addSubview:headerMoment];
    
    self.navigationItem.titleView = view;
}

- (void)createViews {
    self.tableView = [[FLTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame) - 50) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    [self.tableView setSeparatorColor:[UIColor customBackground]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    tableHeaderView = [[TransactionHeaderView alloc] initWithTransaction:_transaction parentController:self];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), 1.0)];
//    separator.backgroundColor = [UIColor customBackground];
    
    self.tableView.tableHeaderView = tableHeaderView;
    self.tableView.tableFooterView = separator;
    
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
    
    closeCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 50, 50 - 10)];
    [closeCommentButton setImage:[[UIImage imageNamed:@"navbar-cross"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeCommentButton addTarget:self action:@selector(didCloseCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    closeCommentButton.tintColor = [UIColor whiteColor];
    closeCommentButton.contentMode = UIViewContentModeScaleAspectFit;
    [toolbar addSubview:closeCommentButton];
    
    acceptButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_PARTICIPATE", nil)];
    acceptButton.titleLabel.font = [UIFont customTitleLight:16];
    [acceptButton addTarget:self action:@selector(acceptButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:acceptButton];
    
    declineButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_CLOSE", nil)];
    declineButton.titleLabel.font = [UIFont customTitleLight:16];
    [declineButton addTarget:self action:@selector(declineButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [declineButton setBackgroundColor:[UIColor customRed] forState:UIControlStateNormal];
    [declineButton setBackgroundColor:[UIColor customRed:0.5] forState:UIControlStateHighlighted];
    [toolbar addSubview:declineButton];
    
    commentTextField = [[FLTextViewComment alloc] initWithPlaceholder:NSLocalizedString(@"SEND_COMMENT", nil) for:commentData key:@"comment" frame:CGRectMake(60, 10, PPScreenWidth() - 120, 30)];
    [commentTextField setDelegate:self];
    [toolbar addSubview:commentTextField];
    
    commentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(toolbar.frame) - 55, 5, 50, 50 - 10)];
    [commentButton setImage:[[FLHelper imageWithImage:[UIImage imageNamed:@"speech_bubble"] scaledToSize:CGSizeMake(32, 32)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    commentButton.tintColor = [UIColor whiteColor];
    commentButton.contentMode = UIViewContentModeScaleAspectFit;
    [toolbar addSubview:commentButton];
    
    sendCommentButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(toolbar.frame) - 55, 5, 50, 50 - 10)];
    [sendCommentButton setTitle:NSLocalizedString(@"GLOBAL_SEND", nil) forState:UIControlStateNormal];
    [sendCommentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendCommentButton addTarget:self action:@selector(didSendCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    sendCommentButton.titleLabel.font = [UIFont customTitleExtraLight:13];
    sendCommentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [toolbar addSubview:sendCommentButton];
    
    scopeHelper = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20)];
    scopeHelper.layer.masksToBounds = YES;
    scopeHelper.layer.cornerRadius = 4;
    scopeHelper.backgroundColor = [UIColor customBlue];
    scopeHelper.userInteractionEnabled = NO;
    
    scopeHelperLabel = [UILabel newWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentLight:15] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    [scopeHelper addSubview:scopeHelperLabel];

    [_mainBody addSubview:self.tableView];
    [_mainBody addSubview:toolbar];
    [_mainBody addSubview:scopeHelper];

    [self createSocialToolbar];
}

- (void)createSocialToolbar {
    socialToolbar = [UIView newWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), 40.0f)];
    socialToolbar.backgroundColor = [UIColor customBackground];
    
    [self createLikeButton];
    [self createCommentButton];
    [self createMoreButton];
}

- (void)createLikeButton {
    likeToolbarButton = [[FLSocialButton alloc] initWithImageName:@"like-heart" color:[UIColor customSocialColor] selectedColor:[UIColor customPink] title:@"" height:CGRectGetHeight(socialToolbar.frame) - 15];
    [likeToolbarButton addTarget:self action:@selector(didLikeButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:likeToolbarButton];
    CGRectSetX(likeToolbarButton.frame, 10.0f);
    CGRectSetY(likeToolbarButton.frame, 9.0);
}

- (void)createCommentButton {
    commentToolbarButton = [[FLSocialButton alloc] initWithImageName:@"comment_bubble" color:[UIColor customSocialColor] selectedColor:[UIColor customBlue] title:@"" height:CGRectGetHeight(socialToolbar.frame) - 15];
    [commentToolbarButton addTarget:self action:@selector(focusComment) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:commentToolbarButton];
    CGRectSetX(commentToolbarButton.frame, CGRectGetMinX(likeToolbarButton.frame) + 65.0f);
    CGRectSetY(commentToolbarButton.frame, 9.0);
}

- (void)createMoreButton {
    moreToolbarButton = [[FLSocialButton alloc] initWithImageName:@"more" color:[UIColor customSocialColor] selectedColor:[UIColor customSocialColor] title:@"" height:CGRectGetHeight(socialToolbar.frame) - 15];
    [moreToolbarButton addTarget:self action:@selector(showReportMenu) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:moreToolbarButton];
    CGRectSetX(moreToolbarButton.frame, CGRectGetWidth(socialToolbar.frame) - CGRectGetWidth(moreToolbarButton.frame) - 10.0f);
    CGRectSetY(moreToolbarButton.frame, 9.0);
}

- (void)prepareViews {
    [self createHeader];
    
    if (isCommenting) {
        commentTextField.hidden = NO;
        acceptButton.hidden = YES;
        declineButton.hidden = YES;
        closeCommentButton.hidden = NO;
        sendCommentButton.hidden = NO;
        commentButton.hidden = YES;
        shareButton.hidden = YES;
    } else {
        if (_transaction.isAcceptable && _transaction.isCancelable) {
            acceptButton.hidden = NO;
            declineButton.hidden = NO;
            commentTextField.hidden = YES;
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            commentButton.hidden = NO;
            
            CGRectSetWidth(acceptButton.frame, (PPScreenWidth() - 120) / 2 - 5);
            CGRectSetX(declineButton.frame, PPScreenWidth() / 2 + 5);
            CGRectSetWidth(declineButton.frame, (PPScreenWidth() - 120) / 2 - 5);
            
            acceptButton.titleLabel.font = [UIFont customTitleLight:16];
            declineButton.titleLabel.font = [UIFont customTitleLight:16];
            shareButton.hidden = NO;
        } else if (_transaction.isAcceptable) {
            acceptButton.hidden = NO;
            declineButton.hidden = YES;
            commentTextField.hidden = YES;
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            commentButton.hidden = NO;
            
            CGRectSetWidth(acceptButton.frame, PPScreenWidth() - 120);
            CGRectSetX(declineButton.frame, 60);
            CGRectSetWidth(declineButton.frame, PPScreenWidth() - 120);
            acceptButton.titleLabel.font = [UIFont customTitleLight:20];
            shareButton.hidden = NO;
        } else if (_transaction.isCancelable) {
            acceptButton.hidden = YES;
            declineButton.hidden = NO;
            commentTextField.hidden = YES;
            
            CGRectSetWidth(acceptButton.frame, PPScreenWidth() - 120);
            CGRectSetWidth(declineButton.frame, PPScreenWidth() - 120);
            declineButton.titleLabel.font = [UIFont customTitleLight:20];
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            commentButton.hidden = NO;
            shareButton.hidden = NO;
        } else {
            if (keyboardHeight) {
                closeCommentButton.hidden = NO;
                shareButton.hidden = YES;
            } else {
                closeCommentButton.hidden = YES;
                shareButton.hidden = NO;
            }

            commentTextField.hidden = NO;
            acceptButton.hidden = YES;
            declineButton.hidden = YES;
            sendCommentButton.hidden = NO;
            commentButton.hidden = YES;
        }
    }
    
    FLSocial *social = [_transaction social];
    
    [likeToolbarButton setSelected:[[_transaction social] isLiked]];
    [likeToolbarButton setText:[self castNumber:social.likesCount]];
    
    [commentToolbarButton setSelected:[[_transaction social] isCommented]];
    [commentToolbarButton setText:[self castNumber:social.commentsCount]];
    
    [tableHeaderView setTransaction:_transaction];
    [self.tableView reloadData];
}

#pragma marks - number formatter

- (NSString *)castNumber:(NSUInteger)number {
    if (!number) {
        return @"";
    }
    
    if ((int)number == 0) {
        return @"";
    }
    
    return [self abbreviateNumber:(int)number];
}

-(NSString *)abbreviateNumber:(int)num {
    
    NSString *abbrevNum;
    float number = (float)num;
    
    //Prevent numbers smaller than 1000 to return NULL
    if (num >= 1000) {
        NSArray *abbrev = @[@"K", @"M", @"B"];
        
        for (int i = (int)abbrev.count - 1; i >= 0; i--) {
            
            // Convert array index to "1000", "1000000", etc
            int size = pow(10,(i+1)*3);
            
            if(size <= number) {
                // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
                number = number/size;
                NSString *numberString = [self floatToString:number];
                
                // Add the letter for the abbreviation
                abbrevNum = [NSString stringWithFormat:@"%@%@", numberString, [abbrev objectAtIndex:i]];
            }
            
        }
    } else {
        abbrevNum = [NSString stringWithFormat:@"%02d", (int)number];
    }
    
    return abbrevNum;
}

- (NSString *) floatToString:(float) val {
    NSString *ret = [NSString stringWithFormat:@"%.1f", val];
    unichar c = [ret characterAtIndex:[ret length] - 1];
    
    while (c == 48) { // 0
        ret = [ret substringToIndex:[ret length] - 1];
        c = [ret characterAtIndex:[ret length] - 1];
        
        //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
        if (c == 46) { // .
            ret = [ret substringToIndex:[ret length] - 1];
        }
    }
    
    return ret;
}

#pragma marks - tableview delegate / datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _transaction.social.commentsCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [CommentCell getHeight:_transaction.comments[indexPath.row]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(socialToolbar.frame);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return socialToolbar;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CommentCell";
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[CommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    [cell loadWithComment:_transaction.comments[indexPath.row]];
    
    return cell;
}

- (void)createParticipantVignetteViewForCell:(UITableViewCell *)cell {
    UIView *tmp = [cell.contentView viewWithTag:42];
    
    if (tmp)
        [tmp removeFromSuperview];
    
    UIView *view  = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(cell.textLabel.frame), 10, PPScreenWidth() - CGRectGetMaxX(cell.textLabel.frame) - 40, 30)];
    
    int nbSubView = (int)CGRectGetWidth(view.frame) % 27;
    
    if (nbSubView > _transaction.participants.count)
        nbSubView = (int)_transaction.participants.count;
    
    CGFloat xOffSet = CGRectGetWidth(view.frame) - 30;
    
    for (int i = nbSubView - 1; i >= 0; i--) {
        FLUser *participant = _transaction.participants[i];
        FLUserView *userView = [[FLUserView alloc] initWithFrame:CGRectMake(xOffSet, 0, 30, 30)];
        userView.isRound = YES;
        [userView setImageFromUser:participant];
        userView.avatar.layer.cornerRadius = 15;
        userView.layer.cornerRadius = 15;
        userView.layer.shadowColor = [UIColor blackColor].CGColor;
        userView.layer.shadowOpacity = .3;
        userView.layer.shadowOffset = CGSizeMake(1.5, -0.5);
        userView.layer.shadowRadius = 1;
        [view addSubview:userView];
        xOffSet -= 27;
    }
    
    [view setTag:42];
    [cell.contentView addSubview:view];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_tableView.contentOffset.y < [tableHeaderView headerSize])
        [(FLNavigationController*)self.navigationController hideShadow];
    else
        [(FLNavigationController*)self.navigationController showShadow];
}

#pragma mark - Actions

- (void)focusOnComment {
    focusOnCommentTextField = YES;
    [self focusComment];
}

- (void)didLikeButtonTouch {
    if ([[_transaction social] isLiked])
        [[_transaction social] setLikesCount:[_transaction social].likesCount - 1];
    else
        [[_transaction social] setLikesCount:[_transaction social].likesCount + 1];
    
    [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
    [self prepareViews];
    
    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
        [_transaction setJSON:result[@"item"]];
        [self prepareViews];
    } failure:NULL];
}

- (void)showReportMenu {
    [appDelegate showReportMenu:[[FLReport alloc] initWithType:ReportTransaction transac:_transaction]];
}

- (void)didCloseCommentButtonClick {
    isCommenting = NO;
    [commentTextField resignFirstResponder];
    [self prepareViews];
}

- (void)didSendCommentButtonClick {
    [commentTextField resignFirstResponder];
    
    if (!commentData[@"comment"] || [commentData[@"comment"] isBlank] || [commentData[@"comment"] length] > 3000 || sendPressed) {
        return;
    }
    sendPressed = YES;
    
    NSDictionary *comment = @{
                              @"floozId": [_transaction transactionId],
                              @"comment": commentData[@"comment"]
                              };
    
    [commentData setObject:@"" forKey:@"comment"];
    [commentTextField reload];
    [commentTextField setHeight:30];

    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] createComment:comment success: ^(id result) {
        isCommenting = NO;
        sendPressed = NO;
        [_transaction setJSON:result[@"item"]];
        
        [self reloadTransaction];
        
        if (self.tableView.contentSize.height >= self.tableView.bounds.size.height) {
            CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
            [self.tableView setContentOffset:bottomOffset animated:YES];
        }
    } failure:^(NSError *error) {
        sendPressed = NO;
    }];
    
}

- (void)commentButtonClick {
    isCommenting = YES;
    [commentTextField becomeFirstResponder];
    [self prepareViews];
}

- (void)shareButtonClick {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.flooz.me/flooz/%@", _transaction.transactionId]];
    
    ARChromeActivity *chromeActivity = [ARChromeActivity new];
    TUSafariActivity *safariActivity = [TUSafariActivity new];
    FLCopyLinkActivity *copyActivity = [FLCopyLinkActivity new];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[chromeActivity, safariActivity, copyActivity]];
    
    [shareController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
        
    }];
    
    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:^{
        
    }];
}

- (void)declineButtonClick {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:_transaction.actions[@"decline"]]];
    
}

- (void)acceptButtonClick {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:_transaction.actions[@"accept"]]];
}

- (void)reloadTransaction {
    [self prepareViews];
    [self didUpdateTransactionData];
}

- (void)didUpdateTransactionData {
    if (_indexPath) {
        [_delegateController updateTransactionAtIndex:_indexPath transaction:_transaction];
    }
}

- (void)showScopeHelper {
    NSString *text;
    
    if (_transaction.social.scope == SocialScopeFriend) {
        text = @"Flooz visible par vos amis";
    }
    else if (_transaction.social.scope == SocialScopePrivate) {
        text = @"Flooz privé";
    }
    else if (_transaction.social.scope == SocialScopePublic) {
        text = @"Flooz public";
    }
    
    scopeHelperLabel.text = text;
    [scopeHelperLabel sizeToFit];
    
    [UIView animateWithDuration:0.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        scopeHelper.alpha = 0.0f;
        CGRectSetSize(scopeHelper.frame, CGSizeMake(CGRectGetWidth(scopeHelperLabel.frame) + 10, CGRectGetHeight(scopeHelperLabel.frame) + 10));
        CGRectSetXY(scopeHelperLabel.frame, 5, 5);
        CGRectSetXY(scopeHelper.frame, PPScreenWidth() - CGRectGetWidth(scopeHelper.frame) - 10, 0);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 delay:0.05 options:UIViewAnimationOptionCurveEaseIn animations:^{
            scopeHelper.alpha = 1.0f;
        } completion:^(BOOL finished) {
            if (finished) {
                [UIView animateWithDuration:0.3 delay:2.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    scopeHelper.alpha = 0.0f;
                } completion:^(BOOL finished) {
                }];
            }
        }];
    }];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    [self registerNotification:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
}

- (void)keyboardFrameChanged:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
}

- (void)keyboardWillDisappear {
    keyboardHeight = 0;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
}

- (void)didChangeHeight:(CGFloat)height {
    if (height >= 30) {
        CGRectSetHeight(toolbar.frame, height + 20);
        CGRectSetY(sendCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(closeCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(shareButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        
        CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
        CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
    }
}

@end
