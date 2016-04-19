//
//  AudiotelCodePopup.m
//  Flooz
//
//  Created by Olive on 4/18/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "AudiotelCodePopup.h"

#define BUTTON_MARGE 15.
#define MARGE 20.
#define PADDING_TOP_BOTTOM 20.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4

@interface AudiotelCodePopup() {
    NSMutableDictionary *dictionary;

    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIView *contentView;
    
    FLTextField *codeField;
    FLActionButton *useButton;
}

@end

@implementation AudiotelCodePopup

- (id)init {
    self = [super init];
    if (self) {
        viewWidth = 250;
        viewHeight = 160;

        [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
    }
    return self;
}

- (void)viewDidLoad {
    
    dictionary = [NSMutableDictionary new];

    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, viewWidth, 25)];
    titleView.font = [UIFont customContentBold:22];
    titleView.textColor = [UIColor customBlue];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 1;
    titleView.text = @"Audiotel";
    
    [contentView addSubview:titleView];

    UIButton *closeButton = [UIButton newWithFrame:CGRectMake(viewWidth - 30, 5, 25, 25)];
    [closeButton setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:closeButton];

    codeField = [[FLTextField alloc] initWithPlaceholder:@"Votre code" for:dictionary key:@"audiotelCode" frame:CGRectMake(PADDING_LEFT_RIGHT, CGRectGetMaxY(titleView.frame) + 5, viewWidth - 2 * PADDING_LEFT_RIGHT, 40)];
    [contentView addSubview:codeField];
    codeField.textAlignment = NSTextAlignmentCenter;

    useButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, CGRectGetMaxY(codeField.frame) + 10, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:@"Utiliser"];
    [useButton addTarget:self action:@selector(didUseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:useButton];

    [self.view addSubview:contentView];
}

- (void)didUseButtonClick {
    
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _formSheet = [[MZFormSheetController alloc] initWithViewController:self];
        _formSheet.presentedFormSheetSize = self.preferredContentSize;
        _formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        _formSheet.shadowRadius = 2.0;
        _formSheet.shadowOpacity = 0.3;
        _formSheet.shouldDismissOnBackgroundViewTap = YES;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {

        }];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
        }];
    });
}


@end
