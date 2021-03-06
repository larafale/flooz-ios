//
//  DiscountCodeViewController.m
//  Flooz
//
//  Created by Flooz on 7/30/15.
//  Copyright © 2015 Flooz. All rights reserved.
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
    [super viewDidLoad];
    
    if (!self.title || [self.title isBlank])
        self.title = [Flooz sharedInstance].currentTexts.menu[@"promo"][@"title"];
    
    _data = [NSMutableDictionary new];
    _contentView = [UIScrollView newWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    [_mainBody addSubview:_contentView];
    
    {
        NSString *placeholderString = [Flooz sharedInstance].currentTexts.menu[@"promo"][@"placeholder"];
        
        if (self.triggerData && self.triggerData[@"placeholder"] && ![self.triggerData[@"placeholder"] isBlank])
            placeholderString = self.triggerData[@"placeholder"];

        _sponsor = [[FLTextFieldSignup alloc] initWithPlaceholder:placeholderString for:_data key:@"code" position:CGPointMake(PADDING_SIDE, PADDING_SIDE)];
        [_sponsor addForTextChangeTarget:self action:@selector(canValidate:)];
        [_contentView addSubview:_sponsor];
    }
    
    {
        [self createSaveButton];
        CGRectSetY(_saveButton.frame, CGRectGetMaxY(_sponsor.frame) + 10.0f);
        [_saveButton addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_saveButton];
        
        NSString *infosString = [Flooz sharedInstance].currentTexts.menu[@"promo"][@"info"];
        
        if (self.triggerData && self.triggerData[@"info"] && ![self.triggerData[@"info"] isBlank])
            infosString = self.triggerData[@"info"];
        
        UILabel *infos = [[UILabel alloc] initWithText:infosString textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
        [infos setLineBreakMode:NSLineBreakByWordWrapping];
        
        CGRectSetWidth(infos.frame, CGRectGetWidth(_contentView.frame) - PADDING_SIDE * 2);
        [infos sizeToFit];
        CGRectSetXY(infos.frame, CGRectGetWidth(_contentView.frame) / 2 - CGRectGetWidth(infos.frame) / 2, CGRectGetMaxY(_saveButton.frame) + PADDING_SIDE);
        [_contentView addSubview:infos];
        
    }
    _contentView.contentSize = CGSizeMake(CGRectGetWidth(_mainBody.frame), CGRectGetMaxY(_saveButton.frame));
    
    [self addTapGestureForDismissKeyboard];
}

- (void)createSaveButton {
    NSString *buttonString = NSLocalizedString(@"GLOBAL_SAVE", nil);
    
    if (self.triggerData && self.triggerData[@"button"] && ![self.triggerData[@"button"] isBlank])
        buttonString = self.triggerData[@"button"];
    
    _saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, 0, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:buttonString];
    
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
