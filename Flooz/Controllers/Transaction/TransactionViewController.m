//
//  CollectViewController.m
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "TransactionViewController.h"
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
#import "TransactionLikeViewController.h"

@interface TransactionViewController () {
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    BOOL focusOnCommentTextField;
    CGFloat headerSize;
    
    TransactionHeaderView *tableHeaderView;
    
    UIView *navHeaderView;
    UIView *toolbar;
    FLActionButton *acceptButton;
    FLActionButton *declineButton;
    FLTextViewComment *commentTextField;
    UIButton *shareButton;
    UIButton *closeCommentButton;
    UIButton *sendCommentButton;
    UIButton *commentButton;
    NSMutableDictionary *commentData;
    
    UILabel *likeLabel;
    UILabel *commentLabel;
    FLSocialButton *likeToolbarButton;
    FLSocialButton *commentToolbarButton;
    FLSocialButton *shareToolbarButton;
    FLSocialButton *moreToolbarButton;
    
    UIView *scopeHelper;
    UILabel *scopeHelperLabel;
    
    CGFloat keyboardHeight;
    BOOL isCommenting;
    BOOL sendPressed;
    
    UIView *socialToolbar;
    UIView *socialSeparator;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTransaction:) name:kNotificationRefreshTransaction object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
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
    isCommenting = YES;
    [self prepareViews];
    [commentTextField becomeFirstResponder];
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

- (void)refreshTransaction:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    
    if (userInfo && userInfo[@"_id"] && [userInfo[@"_id"] isEqualToString:_transaction.transactionId]) {
        if (userInfo[@"flooz"]) {
            _transaction = [[FLTransaction alloc] initWithJSON:userInfo[@"flooz"]];
            [self reloadTransaction];
            
            if (userInfo[@"commentId"]) {
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_transaction.social.commentsCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } else {
            [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success:^(id result) {
                _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [self reloadTransaction];
                
                if (userInfo[@"commentId"]) {
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_transaction.social.commentsCount - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }];
        }
    }
}

#pragma mark - Views

- (void)createHeader {
    UIImage *scopeImage = _transaction.social.scope.image;

    if (scopeImage) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:[scopeImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0, 0, 20, 20);
        [btn setTintColor:[UIColor customWhite]];
        [btn addTarget:self action:@selector(showScopeHelper) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *scopeButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItem = scopeButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    if (!navHeaderView) {
        navHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), PPTabBarHeight())];
        
        NSString *headerString = [FLHelper momentWithDate:[_transaction date]];
        
        UILabel *headerMoment = [[UILabel alloc] initWithText:headerString textColor:[UIColor whiteColor] font:[UIFont customContentLight:12] textAlignment:NSTextAlignmentLeft numberOfLines:1];
        headerMoment.tag = 42;
        
        CGFloat headerWidth = CGRectGetWidth(headerMoment.frame);
        
        CGRectSetWidth(navHeaderView.frame, headerWidth);
        
        CGFloat midHeight = PPTabBarHeight() / 2;
        
        CGRectSetXY(headerMoment.frame, 0, midHeight - CGRectGetHeight(headerMoment.frame) / 2 - 2);
        
        [navHeaderView addSubview:headerMoment];
        self.navigationItem.titleView = navHeaderView;
    } else {
        NSString *headerString = [FLHelper momentWithDate:[_transaction date]];

        UILabel *headerMoment = [navHeaderView viewWithTag:42];
        headerMoment.text = headerString;
        
        CGFloat headerWidth = CGRectGetWidth(headerMoment.frame);
        
        CGRectSetWidth(navHeaderView.frame, headerWidth);
        
        CGFloat midHeight = PPTabBarHeight() / 2;
        
        CGRectSetXY(headerMoment.frame, 0, midHeight - CGRectGetHeight(headerMoment.frame) / 2 - 2);
    }
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
    [closeCommentButton setImage:[[FLHelper imageWithImage:[UIImage imageNamed:@"navbar-cross"] scaledToSize:CGSizeMake(20, 20)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [closeCommentButton addTarget:self action:@selector(didCloseCommentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    closeCommentButton.tintColor = [UIColor whiteColor];
    closeCommentButton.contentMode = UIViewContentModeCenter;
    [toolbar addSubview:closeCommentButton];
    
    acceptButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_ACCEPT", nil)];
    acceptButton.titleLabel.font = [UIFont customTitleLight:16];
    [acceptButton addTarget:self action:@selector(acceptButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:acceptButton];
    
    declineButton = [[FLActionButton alloc] initWithFrame:CGRectMake(60, 5, PPScreenWidth() - 120, 50 - 10) title:NSLocalizedString(@"MENU_DECLINE", nil)];
    declineButton.titleLabel.font = [UIFont customTitleLight:16];
    [declineButton addTarget:self action:@selector(declineButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [declineButton setBackgroundColor:[UIColor customRed] forState:UIControlStateNormal];
    [declineButton setBackgroundColor:[UIColor customRed:0.5] forState:UIControlStateHighlighted];
    [toolbar addSubview:declineButton];
    
    commentTextField = [[FLTextViewComment alloc] initWithPlaceholder:NSLocalizedString(@"SEND_COMMENT", nil) for:commentData key:@"comment" frame:CGRectMake(60, 10, PPScreenWidth() - 120, 30)];
    [commentTextField setDelegate:self];
    [commentTextField addTextFocusTarget:self action:@selector(focusOnComment:)];
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
    
    [self createSocialLabels];

    [self createLikeButton];
    [self createCommentButton];
    [self createShareButton];
    [self createMoreButton];
}

- (void) createSocialLabels {
    likeLabel = [UILabel newWithFrame:CGRectMake(10.0f, 7.5, PPScreenWidth() - 20, 15.0f)];
    likeLabel.textColor = [UIColor customPlaceholder];
    likeLabel.numberOfLines = 1;
    likeLabel.textAlignment = NSTextAlignmentLeft;
    likeLabel.font = [UIFont customContentRegular:12];
    likeLabel.userInteractionEnabled = YES;
    [likeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didLikeLabelClicked)]];
    
    commentLabel = [UILabel newWithFrame:CGRectMake(10.0f, 7.5, PPScreenWidth() - 20, 15.0f)];
    commentLabel.textColor = [UIColor customPlaceholder];
    commentLabel.numberOfLines = 1;
    commentLabel.textAlignment = NSTextAlignmentLeft;
    commentLabel.font = [UIFont customContentRegular:12];
    
    socialSeparator = [[UIView alloc] initWithFrame:CGRectMake(5, CGRectGetMaxY(likeLabel.frame) + 7.5, PPScreenWidth() - 10, 0.8f)];
    [socialSeparator setBackgroundColor:[UIColor colorWithHexString:@"#2f3a45"]];
    socialSeparator.layer.masksToBounds = YES;
    socialSeparator.layer.cornerRadius = 0.4;
    
    [socialToolbar addSubview:likeLabel];
    [socialToolbar addSubview:commentLabel];
    [socialToolbar addSubview:socialSeparator];
}

- (void)createLikeButton {
    likeToolbarButton = [[FLSocialButton alloc] initWithImageName:@"like-heart" color:[UIColor customSocialColor] selectedColor:[UIColor customPink] title:@"" height:25];
    [likeToolbarButton addTarget:self action:@selector(didLikeButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:likeToolbarButton];
    CGRectSetX(likeToolbarButton.frame, 10.0f);
    CGRectSetY(likeToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5);
}

- (void)createCommentButton {
    commentToolbarButton = [[FLSocialButton alloc] initWithImageName:@"comment_bubble" color:[UIColor customSocialColor] selectedColor:[UIColor customBlue] title:@"" height:25];
    [commentToolbarButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:commentToolbarButton];
    CGRectSetX(commentToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 3));
    CGRectSetY(commentToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5);
}

- (void)createShareButton {
    shareToolbarButton = [[FLSocialButton alloc] initWithImageName:@"share" color:[UIColor customSocialColor] selectedColor:[UIColor customSocialColor] title:@"" height:25];
    [shareToolbarButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:shareToolbarButton];
    CGRectSetX(shareToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 3) * 2);
    CGRectSetY(shareToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5);
}

- (void)createMoreButton {
    moreToolbarButton = [[FLSocialButton alloc] initWithImageName:@"more" color:[UIColor customSocialColor] selectedColor:[UIColor customSocialColor] title:@"" height:25];
    [moreToolbarButton addTarget:self action:@selector(showReportMenu) forControlEvents:UIControlEventTouchUpInside];
    [socialToolbar addSubview:moreToolbarButton];
    CGRectSetX(moreToolbarButton.frame, CGRectGetWidth(socialToolbar.frame) - CGRectGetWidth(moreToolbarButton.frame) - 10.0f);
    CGRectSetY(moreToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5);
}

- (void)prepareViews {
    [self createHeader];
    
    if (isCommenting && _transaction.options.commentEnabled) {
        commentTextField.hidden = NO;
        acceptButton.hidden = YES;
        declineButton.hidden = YES;
        closeCommentButton.hidden = NO;
        sendCommentButton.hidden = NO;
        commentButton.hidden = YES;
        shareButton.hidden = YES;
        
        CGFloat height = CGRectGetHeight(commentTextField.frame);
        
        if (height >= 30) {
            CGRectSetHeight(toolbar.frame, height + 20);
            CGRectSetY(sendCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
            CGRectSetY(closeCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
            CGRectSetY(shareButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
            
            CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
            CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
        }
    } else {
        CGRectSetHeight(toolbar.frame, 50);
        CGRectSetY(sendCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(closeCommentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(shareButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(acceptButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(declineButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        CGRectSetY(commentButton.frame, CGRectGetHeight(toolbar.frame) / 2 - CGRectGetHeight(sendCommentButton.frame) / 2);
        
        CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
        CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
        
        if (_transaction.isAcceptable && _transaction.isCancelable) {
            acceptButton.hidden = NO;
            declineButton.hidden = NO;
            commentTextField.hidden = YES;
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            
            CGRectSetWidth(acceptButton.frame, (PPScreenWidth() - 120) / 2 - 5);
            CGRectSetX(declineButton.frame, PPScreenWidth() / 2 + 5);
            CGRectSetWidth(declineButton.frame, (PPScreenWidth() - 120) / 2 - 5);
            
            acceptButton.titleLabel.font = [UIFont customTitleLight:16];
            declineButton.titleLabel.font = [UIFont customTitleLight:16];
        
            shareButton.hidden = !_transaction.options.shareEnabled;
            commentButton.hidden = !_transaction.options.commentEnabled;
        } else if (_transaction.isAcceptable) {
            acceptButton.hidden = NO;
            declineButton.hidden = YES;
            commentTextField.hidden = YES;
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            
            CGRectSetWidth(acceptButton.frame, PPScreenWidth() - 120);
            CGRectSetX(declineButton.frame, 60);
            CGRectSetWidth(declineButton.frame, PPScreenWidth() - 120);
            acceptButton.titleLabel.font = [UIFont customTitleLight:20];
            shareButton.hidden = !_transaction.options.shareEnabled;
            commentButton.hidden = !_transaction.options.commentEnabled;
        } else if (_transaction.isCancelable) {
            acceptButton.hidden = YES;
            declineButton.hidden = NO;
            commentTextField.hidden = YES;
            
            CGRectSetWidth(acceptButton.frame, PPScreenWidth() - 120);
            CGRectSetWidth(declineButton.frame, PPScreenWidth() - 120);
            declineButton.titleLabel.font = [UIFont customTitleLight:20];
            closeCommentButton.hidden = YES;
            sendCommentButton.hidden = YES;
            shareButton.hidden = !_transaction.options.shareEnabled;
            commentButton.hidden = !_transaction.options.commentEnabled;
        } else {
            if (keyboardHeight) {
                closeCommentButton.hidden = NO;
                shareButton.hidden = YES;
            } else {
                closeCommentButton.hidden = YES;
                shareButton.hidden = NO;
            }
            
            if (!_transaction.options.commentEnabled) {
                toolbar.hidden = YES;
            } else {
                toolbar.hidden = NO;
                commentTextField.hidden = NO;
                acceptButton.hidden = YES;
                declineButton.hidden = YES;
                sendCommentButton.hidden = NO;
                commentButton.hidden = YES;
                
                shareButton.hidden = !_transaction.options.shareEnabled;
                
                commentTextField.userInteractionEnabled = _transaction.options.commentEnabled;
                sendCommentButton.enabled = _transaction.options.commentEnabled;
            }
        }
    }
    
    FLSocial *social = [_transaction social];
    
    
    NSString *likeString = @" J'AIME";
    NSString *commentString = @" COMMENTAIRE";
    NSString *commentsString = @" COMMENTAIRES";
    
    if (social.likesCount > 0 && _transaction.options.likeEnabled && social.commentsCount > 0 && _transaction.options.commentEnabled) {
        likeLabel.hidden = NO;
        commentLabel.hidden = NO;
        socialSeparator.hidden = NO;
        
        CGRectSetX(likeLabel.frame, 10.0f);
        
        NSMutableAttributedString *likeAttrString = [[NSMutableAttributedString alloc] initWithString:[FLHelper castNumber:social.likesCount] attributes:@{NSFontAttributeName: [UIFont customContentBold:13], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        [likeAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:likeString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        
        likeLabel.attributedText = likeAttrString;
        
        [likeLabel setWidthToFit];
        
        CGRectSetX(commentLabel.frame, CGRectGetMaxX(likeLabel.frame) + 15);
        
        NSMutableAttributedString *commentAttrString = [[NSMutableAttributedString alloc] initWithString:[FLHelper castNumber:social.commentsCount] attributes:@{NSFontAttributeName: [UIFont customContentBold:13], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        if (social.commentsCount > 1)
            [commentAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:commentsString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        else
            [commentAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:commentString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        
        commentLabel.attributedText = commentAttrString;
        
        [commentLabel setWidthToFit];
        
        CGRectSetY(likeToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(commentToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(shareToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(moreToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        
        CGRectSetHeight(socialToolbar.frame, CGRectGetMaxY(likeToolbarButton.frame) + 5.5);
        
    } else if (social.likesCount > 0 && _transaction.options.likeEnabled) {
        likeLabel.hidden = NO;
        commentLabel.hidden = YES;
        socialSeparator.hidden = NO;
        
        CGRectSetX(likeLabel.frame, 10.0f);
        
        NSMutableAttributedString *likeAttrString = [[NSMutableAttributedString alloc] initWithString:[FLHelper castNumber:social.likesCount] attributes:@{NSFontAttributeName: [UIFont customContentBold:13], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        [likeAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:likeString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        
        likeLabel.attributedText = likeAttrString;
        
        [likeLabel setWidthToFit];
        
        CGRectSetY(likeToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(commentToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(shareToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(moreToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        
        CGRectSetHeight(socialToolbar.frame, CGRectGetMaxY(likeToolbarButton.frame) + 5.5);
        
    } else if (social.commentsCount > 0 && _transaction.options.commentEnabled) {
        likeLabel.hidden = YES;
        commentLabel.hidden = NO;
        socialSeparator.hidden = NO;
        
        CGRectSetX(commentLabel.frame, 10.0f);
        
        NSMutableAttributedString *commentAttrString = [[NSMutableAttributedString alloc] initWithString:[FLHelper castNumber:social.commentsCount] attributes:@{NSFontAttributeName: [UIFont customContentBold:13], NSForegroundColorAttributeName: [UIColor whiteColor]}];
        
        if (_transaction.social.commentsCount > 1)
            [commentAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:commentsString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        else
            [commentAttrString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:commentString attributes:@{NSFontAttributeName: [UIFont customContentRegular:12], NSForegroundColorAttributeName: [UIColor customPlaceholder]}]];
        
        commentLabel.attributedText = commentAttrString;
        
        [commentLabel setWidthToFit];
        
        CGRectSetY(likeToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(commentToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(shareToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        CGRectSetY(moreToolbarButton.frame, CGRectGetMaxY(socialSeparator.frame) + 5.5);
        
        CGRectSetHeight(socialToolbar.frame, CGRectGetMaxY(likeToolbarButton.frame) + 5.5);
    } else {
        likeLabel.hidden = YES;
        commentLabel.hidden = YES;
        socialSeparator.hidden = YES;
        
        CGRectSetY(likeToolbarButton.frame, 5.5);
        CGRectSetY(commentToolbarButton.frame, 5.5);
        CGRectSetY(shareToolbarButton.frame, 5.5);
        CGRectSetY(moreToolbarButton.frame, 5.5);
        
        CGRectSetHeight(socialToolbar.frame, CGRectGetMaxY(likeToolbarButton.frame) + 5.5);
    }
    
    
    [likeToolbarButton setSelected:[social isLiked]];
    [commentToolbarButton setSelected:[social isCommented]];

    if (_transaction.options.likeEnabled && _transaction.options.commentEnabled && _transaction.options.shareEnabled) {
        likeToolbarButton.hidden = false;
        commentToolbarButton.hidden = false;
        shareToolbarButton.hidden = false;
        
        CGRectSetX(likeToolbarButton.frame, 10.0f);
        CGRectSetX(commentToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 3));
        CGRectSetX(shareToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 3) * 2);
    } else if (_transaction.options.likeEnabled && _transaction.options.commentEnabled) {
        likeToolbarButton.hidden = false;
        commentToolbarButton.hidden = false;
        shareToolbarButton.hidden = true;
        
        CGRectSetX(likeToolbarButton.frame, 10.0f);
        CGRectSetX(commentToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 2));
    } else if (_transaction.options.likeEnabled && _transaction.options.shareEnabled) {
        likeToolbarButton.hidden = false;
        commentToolbarButton.hidden = true;
        shareToolbarButton.hidden = false;
        
        CGRectSetX(likeToolbarButton.frame, 10.0f);
        CGRectSetX(shareToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 2));
    } else if (_transaction.options.shareEnabled && _transaction.options.commentEnabled) {
        likeToolbarButton.hidden = true;
        commentToolbarButton.hidden = false;
        shareToolbarButton.hidden = false;
        
        CGRectSetX(commentToolbarButton.frame, 10.0f);
        CGRectSetX(shareToolbarButton.frame, ((CGRectGetWidth(socialToolbar.frame) - 20) / 2));
    } else if (_transaction.options.likeEnabled) {
        likeToolbarButton.hidden = false;
        commentToolbarButton.hidden = true;
        shareToolbarButton.hidden = true;
        
        CGRectSetX(likeToolbarButton.frame, 10.0f);
    } else if (_transaction.options.commentEnabled) {
        likeToolbarButton.hidden = true;
        commentToolbarButton.hidden = false;
        shareToolbarButton.hidden = true;
        
        CGRectSetX(commentToolbarButton.frame, 10.0f);
    } else if (_transaction.options.shareEnabled) {
        likeToolbarButton.hidden = true;
        commentToolbarButton.hidden = true;
        shareToolbarButton.hidden = false;
        
        CGRectSetX(shareToolbarButton.frame, 10.0f);
    } else {
        likeToolbarButton.hidden = true;
        commentToolbarButton.hidden = true;
        shareToolbarButton.hidden = true;
    }
    
    [tableHeaderView setTransaction:_transaction];
    self.tableView.tableHeaderView = tableHeaderView;

    [self.tableView reloadData];
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

- (void)focusOnComment:(NSNumber *)focus {
    if ([focus boolValue]) {
        focusOnCommentTextField = YES;
        [self focusComment];
    }
}

- (void)didLikeButtonTouch {
    if ([[_transaction social] isLiked])
        [[_transaction social] setLikesCount:[_transaction social].likesCount - 1];
    else
        [[_transaction social] setLikesCount:[_transaction social].likesCount + 1];
    
    [[_transaction social] setIsLiked:![[_transaction social] isLiked]];
    [self reloadTransaction];
    
    [[Flooz sharedInstance] createLikeOnTransaction:_transaction success: ^(id result) {
        [_transaction setJSON:result[@"item"]];
        [self reloadTransaction];
    } failure:^(NSError *error) {
        [[_transaction social] setIsLiked:![[_transaction social] isLiked]];

        if ([[_transaction social] isLiked])
            [[_transaction social] setLikesCount:[_transaction social].likesCount + 1];
        else
            [[_transaction social] setLikesCount:[_transaction social].likesCount - 1];
        
        [self reloadTransaction];
    }];
}

- (void)showReportMenu {
    [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:_transaction.triggerOptions]];
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
    NSURL *url = [NSURL URLWithString:_transaction.link];
    
    ARChromeActivity *chromeActivity = [ARChromeActivity new];
    TUSafariActivity *safariActivity = [TUSafariActivity new];
    FLCopyLinkActivity *copyActivity = [FLCopyLinkActivity new];
    
    UIActivityViewController *shareController = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:@[chromeActivity, safariActivity, copyActivity]];
    
    [shareController setExcludedActivityTypes:@[UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeAirDrop]];
    
    [self.navigationController presentViewController:shareController animated:YES completion:nil];
}

- (void)didLikeLabelClicked {
    [self.navigationController pushViewController:[[TransactionLikeViewController alloc] initWithTransaction:_transaction] animated:YES];
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
    scopeHelperLabel.text = _transaction.social.scope.desc;
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
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
    
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if (bottomOffset.y < 0)
        [self.tableView setContentOffset:CGPointZero animated:YES];
    else
        [self.tableView setContentOffset:bottomOffset animated:YES];
}

- (void)keyboardFrameChanged:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
    
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if (bottomOffset.y < 0)
        [self.tableView setContentOffset:CGPointZero animated:YES];
    else
        [self.tableView setContentOffset:bottomOffset animated:YES];
}

- (void)keyboardWillDisappear {
    keyboardHeight = 0;
    
    CGRectSetY(toolbar.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetHeight(toolbar.frame));
    CGRectSetHeight(self.tableView.frame, CGRectGetHeight(_mainBody.frame) - CGRectGetHeight(toolbar.frame) - keyboardHeight);
    
    CGPoint bottomOffset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
    if (bottomOffset.y < 0)
        [self.tableView setContentOffset:CGPointZero animated:YES];
    else
        [self.tableView setContentOffset:bottomOffset animated:YES];
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
