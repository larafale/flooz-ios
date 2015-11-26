//
//  TransactionViewController.m
//  Flooz
//
//  Created by olivier on 2/5/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "TransactionViewController.h"
#import "SecureCodeViewController.h"

#import "FLTransactionDescriptionView.h"
#import "TransactionActionsView.h"
#import "TransactionUsersView.h"
#import "TransactionCommentsView.h"
#import "FLNewTransactionAmount.h"

#import "CreditCardViewController.h"

#import "UIView+FindFirstResponder.h"

#define PADDING_BOTTOM 10.0f

@interface TransactionViewController () {
    FLTransaction *_transaction;
    NSIndexPath *_indexPath;
    BOOL focusOnCommentTextField;
    BOOL animationFirstView;
    BOOL paymentFieldIsVisible;
    
    UIScrollView *_contentView;
    UIView *floozerView;
    UIView *_descriptionView;
    TransactionActionsView *actionsView;
    FLNewTransactionAmount *amountInput;
    FLTransactionDescriptionView *transactionDetailsView;
    TransactionCommentsView *commentsView;
    
    CGFloat height;
    CGFloat _heightKeyboard;
}

@end

@implementation TransactionViewController

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath {
    return [self initWithTransaction:transaction indexPath:indexPath withSize:CGSizeMake(PPScreenWidth() - 52.0f, PPScreenHeight())];
}

- (id)initWithTransaction:(FLTransaction *)transaction indexPath:(NSIndexPath *)indexPath withSize:(CGSize)size {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _transaction = transaction;
        _indexPath = indexPath;
        animationFirstView = YES;
        paymentFieldIsVisible = NO;
        focusOnCommentTextField = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    {
        [self createHeader];
        _contentView = [UIScrollView newWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
        [self.view addSubview:_contentView];
        
        [self createViews];
    }
    [self registerForKeyboardNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTransaction:) name:kNotificationRefreshTransaction object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [commentsView focusOnTextField];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)createViews {
    height = 10.0f;
    [self createFloozerExchangeView];
    [self createDescriptionView];
    CGRectSetY(actionsView.frame, CGRectGetMaxY(floozerView.frame) - CGRectGetHeight(actionsView.frame) / 2.0f);
    [_contentView addSubview:actionsView];
    [self createCommentsView];
    
    if (IS_IPHONE_4)
        height += 15;
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height + PADDING_BOTTOM);
    [_contentView setScrollEnabled:YES];
}

- (void)refreshTransaction:(NSNotification *)notification {
    [[Flooz sharedInstance] transactionWithId:_transaction.transactionId success: ^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self prepareViews];
    }];
}

- (void)prepareViews {
    height = 140.0f;
    CGFloat yStart = 0.0f;
    if ([_transaction haveAction] || (_transaction.isCollect && _transaction.collectCanParticipate)) {
        if (_transaction.isAcceptable || _transaction.isCancelable) {
            height += CGRectGetHeight(actionsView.frame) / 2.0f;
            yStart = 15.0f;
        }
    }
    
    [transactionDetailsView setTransaction:_transaction];
    CGFloat heightDesc = CGRectGetHeight(transactionDetailsView.frame) + yStart;
    CGRectSetHeight(_descriptionView.frame, heightDesc);
    height += heightDesc;
    
    CGRectSetY(commentsView.frame, height);
    commentsView.transaction = _transaction;
    
    height += CGRectGetHeight(commentsView.frame);
    
    if (IS_IPHONE_4)
        height += 15;
    
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), height + PADDING_BOTTOM);
    [_contentView setScrollEnabled:YES];
    
    [self didUpdateTransactionData];
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

- (void)createFloozerExchangeView {
    floozerView = [UIView newWithFrame:CGRectMake(0.0f, height, CGRectGetWidth(_contentView.frame), 160.0f)];
    [floozerView setBackgroundColor:[UIColor customBackgroundHeader]];
    [_contentView addSubview:floozerView];
    
    {
        CGFloat height1 = 0.0f;
        
        TransactionUsersView *view = [[TransactionUsersView alloc] initWithFrame:CGRectMake(0.0f, height1, CGRectGetWidth(floozerView.frame), 0)];
        view.transaction = _transaction;
        view.parentViewController = self;
        [floozerView addSubview:view];
        height1 = CGRectGetMaxY(view.frame);
        height += CGRectGetMaxY(view.frame);
        
        if ([_transaction haveAction] || (_transaction.isCollect && _transaction.collectCanParticipate)) {
            if (_transaction.isAcceptable || _transaction.isCancelable) {
                actionsView = [[TransactionActionsView alloc] initWithFrame:CGRectMake(20.0f, 0.0f, CGRectGetWidth(floozerView.frame) - 2 * 20.0f, 0)];
                actionsView.transaction = _transaction;
                actionsView.delegate = self;
                height1 += CGRectGetHeight(actionsView.frame) / 2.0f;
                height += CGRectGetHeight(actionsView.frame) / 2.0f;
            }
        }
        else {
            [actionsView setHidden:YES];
        }
        CGRectSetHeight(floozerView.frame, height1);
    }
}

- (void)createDescriptionView {
    _descriptionView = [UIView newWithFrame:CGRectMake(0.0f, height, CGRectGetWidth(_contentView.frame), 160.0f)];
    [_descriptionView setBackgroundColor:[UIColor customBackground]];
    [_contentView addSubview:_descriptionView];
    
    CGFloat yStart = 0.0f;
    if ([_transaction haveAction] || (_transaction.isCollect && _transaction.collectCanParticipate)) {
        if (_transaction.isAcceptable || _transaction.isCancelable) {
            yStart = 15.0f;
        }
    }
    
    {
        transactionDetailsView = [[FLTransactionDescriptionView alloc] initWithFrame:CGRectMake(0.0f, yStart, CGRectGetWidth(_descriptionView.frame), 100.0f) transaction:_transaction indexPath:_indexPath andAvatar:NO];
        transactionDetailsView.delegate = _delegateController;
        transactionDetailsView.parentController = self;
        [_descriptionView addSubview:transactionDetailsView];
        
        [transactionDetailsView setTransaction:_transaction];
        
        CGFloat heightDesc = CGRectGetHeight(transactionDetailsView.frame) + yStart;
        CGRectSetHeight(_descriptionView.frame, heightDesc);
        height += heightDesc;
    }
}

- (void)createCommentsView {
    commentsView = [[TransactionCommentsView alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(_contentView.frame), 0)];
    commentsView.transaction = _transaction;
    commentsView.delegate = self;
    commentsView.delegateComment = self;
    [_contentView addSubview:commentsView];
    
    height = CGRectGetMaxY(commentsView.frame);
}

#pragma mark - Actions

- (void)showReportMenu {
    [appDelegate showReportMenu:[[FLReport alloc] initWithType:ReportTransaction transac:_transaction]];
}

- (void)dismiss {
    [self.view endEditing:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self mz_dismissFormSheetControllerAnimated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        appDelegate.formSheet = nil;
    }];
}

- (void)reloadTransaction {
    for (UIView *view in[_contentView subviews]) {
        [view removeFromSuperview];
    }
    [self createViews];
    [self didUpdateTransactionData];
}

- (void)didUpdateTransactionData {
    if (_indexPath) {
        [_delegateController updateTransactionAtIndex:_indexPath transaction:_transaction];
    }
}

#pragma mark - Transaction Actions

- (void)acceptTransaction {
    static Boolean showAvalaible = YES;
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                             };
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateTransactionValidate:params success: ^(id result) {
        if (showAvalaible) {
            showAvalaible = NO;
            if ([result objectForKey:@"confirmationText"]) {
                FLPopup *popup = [[FLPopup alloc] initWithMessage:[result objectForKey:@"confirmationText"] accept: ^{
                    showAvalaible = YES;
                    [self didTransactionValidated];
                } refuse:^{
                    showAvalaible = YES;
                }];
                [popup show];
            }
            else {
                [self didTransactionValidated];
            }
        }
    } noCreditCard: ^{
        //        [self presentCreditCardController];
    }];
}

- (void)refuseTransaction {
    [[Flooz sharedInstance] showLoadView];
    
    NSDictionary *params = @{
                             @"id": [_transaction transactionId],
                             @"state": [FLTransaction transactionStatusToParams:TransactionStatusRefused]
                             };
    
    [[Flooz sharedInstance] updateTransaction:params success: ^(id result) {
        _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
        [self reloadTransaction];
    } failure:NULL];
}

- (void)didTransactionValidated {
    [[Flooz sharedInstance] showLoadView];
    CompleteBlock completeBlock = ^{
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSDictionary *params = @{
                                     @"id": [_transaction transactionId],
                                     @"state": [FLTransaction transactionStatusToParams:TransactionStatusAccepted]
                                     };
            
            [[Flooz sharedInstance] showLoadView];
            [[Flooz sharedInstance] updateTransaction:params success: ^(id result) {
                _transaction = [[FLTransaction alloc] initWithJSON:[result objectForKey:@"item"]];
                [self reloadTransaction];
            } failure:NULL];
        });
    };
    
    if ([SecureCodeViewController canUseTouchID])
        [SecureCodeViewController useToucheID:completeBlock passcodeCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                SecureCodeViewController *secureVC = [SecureCodeViewController new];
                secureVC.completeBlock = completeBlock;
                UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:secureVC];
                [[appDelegate myTopViewController] presentViewController:controller animated:YES completion:^{
                    [[Flooz sharedInstance] hideLoadView];
                }];
            });
        } cancelCallback:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [[Flooz sharedInstance] hideLoadView];
            });
        }];
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            SecureCodeViewController *secureVC = [SecureCodeViewController new];
            secureVC.completeBlock = completeBlock;
            UINavigationController *controller = [[UINavigationController alloc] initWithRootViewController:secureVC];
            [[appDelegate myTopViewController] presentViewController:controller animated:YES completion:^{
                [[Flooz sharedInstance] hideLoadView];
            }];
        });
    }
}

- (void)showPaymentField {
}

- (void)hidePaymentField {
}

- (void)didAmountValidTouch {
}

- (void)didAmountCancelTouch {
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    _heightKeyboard = keyboardHeight;
    UIView *firstResponder = [self.view findFirstResponder];
    if ([self viewIsChildOfTransactionComments:firstResponder]) {
        _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + PADDING_BOTTOM, 0);
        CGFloat y = _contentView.contentSize.height - (CGRectGetHeight(_contentView.frame) - keyboardHeight);
        [_contentView setContentOffset:CGPointMake(0, MAX(y, 0)) animated:YES];
    }
}

- (BOOL)viewIsChildOfTransactionComments:(UIView *)child {
    BOOL isChild = NO;
    if (child && [child superview]) {
        if ([[child superview] isKindOfClass:[TransactionCommentsView class]])
            return YES;
        else
            isChild = [self viewIsChildOfTransactionComments:[child superview]];
    }
    return isChild;
}

- (void)focusOnComment {
    focusOnCommentTextField = YES;
    [commentsView focusOnTextField];
}

- (void)keyboardWillDisappear {
    _contentView.contentInset = UIEdgeInsetsZero;
}

#pragma mark - Other

- (void)presentCreditCardController {
    CreditCardViewController *controller = [CreditCardViewController new];
    [self presentViewController:controller animated:YES completion:NULL];
}

- (void)didChangeHeight:(CGFloat)height {
    CGFloat maxY = CGRectGetMaxY(commentsView.frame);
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_contentView.frame), maxY + PADDING_BOTTOM);
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, _heightKeyboard + PADDING_BOTTOM, 0);
    CGFloat y = _contentView.contentSize.height - (CGRectGetHeight(_contentView.frame) - _heightKeyboard);
    [_contentView setContentOffset:CGPointMake(0, MAX(y, 0)) animated:YES];
}

@end
