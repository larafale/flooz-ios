//
//  AddressBookFormController.m
//  Flooz
//
//  Created by Olive on 1/22/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "AddressBookFormController.h"
#import "FLTextField.h"

#define MARGE 15.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4

@interface AddressBookFormController () {
    CGFloat viewHeight;
    CGFloat viewWidth;

    NSMutableDictionary *data;
    
    FLTextField *countryTextfield;
}

@end

@implementation AddressBookFormController

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    viewWidth = PPScreenWidth() - MARGE * 5;
    viewHeight = 70 + MARGE + 20 + MARGE + 35 * 5 + MARGE + BUTTON_HEIGHT + MARGE;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
    
    data = [NSMutableDictionary new];
}

- (void)viewDidLoad {
    
    UIView *badgeBack = [[UIView alloc] initWithFrame:CGRectMake(viewWidth / 2 - 30, 0, 60, 60)];
    [badgeBack setBackgroundColor:[UIColor whiteColor]];
    [badgeBack.layer setMasksToBounds:YES];
    [badgeBack.layer setCornerRadius:CGRectGetWidth(badgeBack.frame) / 2];
    
    UIImageView *badge = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 50, 50)];
    [badge setBackgroundColor:[UIColor customBlue]];
    [badge setImage:[[FLHelper imageWithImage:[UIImage imageNamed:@"menu-home"] scaledToSize:CGSizeMake(40, 40)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [badge setTintColor:[UIColor whiteColor]];
    [badge setContentMode:UIViewContentModeCenter];
    [badge.layer setMasksToBounds:YES];
    [badge.layer setCornerRadius:CGRectGetWidth(badge.frame) / 2];
    
    [badgeBack addSubview:badge];
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(badgeBack.frame) / 2, viewWidth, viewHeight - CGRectGetHeight(badgeBack.frame) / 2)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:5];
    
    UILabel *title = [[UILabel alloc] initWithText:NSLocalizedString(@"ADDRESS_ADD_TITLE", nil) textColor:[UIColor customBlue] font:[UIFont customContentBold:18] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    [title setWidthToFit];
    
    CGRectSetXY(title.frame, viewWidth / 2 - CGRectGetWidth(title.frame) / 2, CGRectGetHeight(badgeBack.frame) / 2 + MARGE / 2);
    
    FLTextField *nameTextfield = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"ADDRESS_ADD_OWNER", nil) for:data key:@"name" frame:CGRectMake(MARGE, CGRectGetMaxY(title.frame) + MARGE, viewWidth - MARGE * 2, 35.0f)];
    [nameTextfield setType:FLTextFieldTypeText];
    [nameTextfield setLineNormalColor:[UIColor customPlaceholder]];
    [nameTextfield setTextColor:[UIColor blackColor]];
    [nameTextfield setFont:[UIFont customContentLight:15]];

    FLTextField *streetTextfield = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"ADDRESS_ADD_STREET", nil) for:data key:@"street" frame:CGRectMake(MARGE, CGRectGetMaxY(nameTextfield.frame) + MARGE / 2, viewWidth - MARGE * 2, 35.0f)];
    [streetTextfield setType:FLTextFieldTypeText];
    [streetTextfield setLineNormalColor:[UIColor customPlaceholder]];
    [streetTextfield setTextColor:[UIColor blackColor]];
    [streetTextfield setFont:[UIFont customContentLight:15]];


    FLTextField *zipTextfield = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"ADDRESS_ADD_ZIP", nil) for:data key:@"zip" frame:CGRectMake(MARGE, CGRectGetMaxY(streetTextfield.frame) + MARGE / 2, viewWidth - MARGE * 2, 35.0f)];
    [zipTextfield setType:FLTextFieldTypeText];
    [zipTextfield setLineNormalColor:[UIColor customPlaceholder]];
    [zipTextfield setTextColor:[UIColor blackColor]];
    [zipTextfield setFont:[UIFont customContentLight:15]];
    [zipTextfield setType:FLTextFieldTypeNumber];
    [zipTextfield setMaxLenght:5];

    FLTextField *cityTextfield = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"ADDRESS_ADD_CITY", nil) for:data key:@"city" frame:CGRectMake(MARGE, CGRectGetMaxY(zipTextfield.frame) + MARGE / 2, viewWidth - MARGE * 2, 35.0f)];
    [cityTextfield setType:FLTextFieldTypeText];
    [cityTextfield setLineNormalColor:[UIColor customPlaceholder]];
    [cityTextfield setTextColor:[UIColor blackColor]];
    [cityTextfield setFont:[UIFont customContentLight:15]];

    countryTextfield = [[FLTextField alloc] initWithPlaceholder:NSLocalizedString(@"ADDRESS_ADD_COUNTRY", nil) for:data key:@"country" frame:CGRectMake(MARGE, CGRectGetMaxY(cityTextfield.frame) + MARGE / 2, viewWidth - MARGE * 2, 35.0f)];
    [countryTextfield setType:FLTextFieldTypeText];
    [countryTextfield setLineNormalColor:[UIColor customPlaceholder]];
    [countryTextfield setTextColor:[UIColor blackColor]];
    [countryTextfield setFont:[UIFont customContentLight:15]];

    FLCountryPicker *countryPicker = [FLCountryPicker new];
    countryPicker.showsSelectionIndicator = YES;
    countryPicker.delegate = self;
    countryPicker.hidePhoneHint = YES;
    
    countryTextfield.inputView = countryPicker;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    toolBar.translucent = NO;
    toolBar.barTintColor=[UIColor customBackgroundHeader];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:countryTextfield action:@selector(resignFirstResponder)];
    [doneButton setTintColor:[UIColor customBlue]];
    
    [toolBar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], doneButton, nil]];
    countryTextfield.inputAccessoryView = toolBar;
    
    [nameTextfield addForNextClickTarget:streetTextfield action:@selector(becomeFirstResponder)];
    [streetTextfield addForNextClickTarget:zipTextfield action:@selector(becomeFirstResponder)];
    [zipTextfield addForNextClickTarget:cityTextfield action:@selector(becomeFirstResponder)];
    [cityTextfield addForNextClickTarget:countryTextfield action:@selector(becomeFirstResponder)];
    [countryTextfield addForNextClickTarget:countryTextfield action:@selector(resignFirstResponder)];
    
    [contentView addSubview:title];
    [contentView addSubview:nameTextfield];
    [contentView addSubview:streetTextfield];
    [contentView addSubview:zipTextfield];
    [contentView addSubview:cityTextfield];
    [contentView addSubview:countryTextfield];
    
    [self.view addSubview:contentView];
    [self.view addSubview:badgeBack];
}

- (void)countryPicker:(FLCountryPicker *)picker didSelectCountry:(FLCountry *)country {
    data[@"country"] = country.name;
    
    [countryTextfield reloadTextField];
}

@end
