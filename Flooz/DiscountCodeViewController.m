//
//  DiscountCodeViewController.m
//  Flooz
//
//  Created by Epitech on 7/30/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "DiscountCodeViewController.h"

#define PADDING_SIDE 20.0f

@interface DiscountCodeViewController () {
    UIScrollView *_contentView;
    
    FLTextFieldSignup *_sponsor;
    
    FLActionButton *_saveButton;
    NSMutableDictionary *_data;
}


@end

@implementation DiscountCodeViewController

- (void)viewDidLoad {
    self.title = [Flooz sharedInstance].currentTexts.menu[@"title"];
    [super viewDidLoad];
    
    _contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    {
        _sponsor = [[FLTextFieldSignup alloc] initWithPlaceholder:[Flooz sharedInstance].currentTexts.menu[@"placeholder"] for:_data key:@"code" position:CGPointMake(PADDING_SIDE, PADDING_SIDE)];
        [_sponsor addForTextChangeTarget:self action:@selector(canValidate:)];
        [_contentView addSubview:_sponsor];
    }
    
    {
        [self createSaveButton];
        CGRectSetY(_saveButton.frame, CGRectGetMaxY(_sponsor.frame) + 10.0f);
        [_saveButton addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_saveButton];
    }
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_saveButton.frame));
    
    [self addTapGestureForDismissKeyboard];
}

- (void)createSaveButton {
    _saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"Save", nil)];
    
    [_saveButton setEnabled:YES];
}

- (BOOL)canValidate:(FLTextFieldSignup *)textIcon {
    BOOL canValidate = YES;
    
    return canValidate;
}

- (void)saveChanges {
    [[self view] endEditing:YES];
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] sendDiscountCode:_data success:nil failure:nil];
}

- (void)addTapGestureForDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    tapGesture.cancelsTouchesInView = NO;
    [_mainBody addGestureRecognizer:tapGesture];
    [_contentView addGestureRecognizer:tapGesture];
    [self registerForKeyboardNotifications];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardDidShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGFloat keyboardHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    _contentView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 30, 0);
}

- (void)keyboardWillDisappear {
    _contentView.contentInset = UIEdgeInsetsZero;
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
