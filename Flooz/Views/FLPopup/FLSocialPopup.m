//
//  FLSocialPopup.m
//  Flooz
//
//  Created by Epitech on 11/27/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLSocialPopup.h"
#import "AppDelegate.h"
#import "FLBorderedActionButton.h"

#define MARGE 20.
#define SMALL_MARGE 10.
#define PADDING_TOP_BOTTOM 30.
#define PADDING_LEFT_RIGHT 30.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4

@implementation FLSocialPopup {
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    NSString *_title;
    
    UIFont *titleFont;
    
    UIView *contentView;
}

- (id)initWithTitle:(NSString *)title fb:(void (^)())fb twitter:(void (^)())twitter app:(void (^)())app;
{
    self = [super init];
    if (self) {
        fbBlock = fb;
        twitterBlock = twitter;
        appBlock = app;
        [self commmonInit:title];
        
    }
    return self;
}

- (void)commmonInit:(NSString *)title {
    _title = title;
    
    titleFont = [UIFont customContentBold:22];
    
    viewWidth = PPScreenWidth() - 2 * MARGE;
    viewHeight = PADDING_TOP_BOTTOM;
    
    NSDictionary *attributes = @{NSFontAttributeName: titleFont};
    CGRect rect = [_title boundingRectWithSize:CGSizeMake(viewWidth - 2 * PADDING_LEFT_RIGHT - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE + BUTTON_HEIGHT * 3 + SMALL_MARGE * 2 + PADDING_TOP_BOTTOM;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
}

- (void)viewDidLoad {
    CGFloat offsetY = PADDING_TOP_BOTTOM;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:2];

    UIButton *closeButton = [UIButton newWithFrame:CGRectMake(viewWidth - 30, 5, 25, 25)];
    [closeButton setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:closeButton];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, 0)];
    titleView.font = titleFont;
    titleView.textColor = [UIColor customBlue];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    
    titleView.text = _title;
    [titleView setHeightToFit];
    
    [contentView addSubview:titleView];
    
    offsetY += CGRectGetHeight(titleView.frame) + MARGE;
    
    FLBorderedActionButton *fbActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:NSLocalizedString(@"SOCIAL_SHARE_FACEBOOK", nil)];
    fbActionButton.layer.cornerRadius = 5;
    fbActionButton.titleLabel.font = [UIFont customContentBold:15];
    [fbActionButton setTitleColor:[UIColor customFacebookBlue] forState:UIControlStateNormal];
    [fbActionButton setImage:[UIImage imageNamed:@"share-facebook"] size:CGSizeMake(BUTTON_HEIGHT - 20, BUTTON_HEIGHT - 20)];
    [fbActionButton addTarget:self action:@selector(didFbTouch) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:fbActionButton];

    offsetY += CGRectGetHeight(fbActionButton.frame) + SMALL_MARGE;

    FLBorderedActionButton *twitterActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:NSLocalizedString(@"SOCIAL_SHARE_TWITTER", nil)];
    twitterActionButton.layer.cornerRadius = 5;
    twitterActionButton.titleLabel.font = [UIFont customContentBold:15];
    [twitterActionButton setTitleColor:[UIColor customTwitterBlue] forState:UIControlStateNormal];
    [twitterActionButton setImage:[UIImage imageNamed:@"share-twitter"] size:CGSizeMake(BUTTON_HEIGHT - 20, BUTTON_HEIGHT - 20)];
    [twitterActionButton addTarget:self action:@selector(didTwitterTouch) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:twitterActionButton];

    offsetY += CGRectGetHeight(fbActionButton.frame) + SMALL_MARGE;

    FLBorderedActionButton *appActionButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:NSLocalizedString(@"SOCIAL_SHARE_APP", nil)];
    appActionButton.layer.cornerRadius = 5;
    appActionButton.titleLabel.font = [UIFont customContentBold:15];
    [appActionButton setTitleColor:[UIColor customPink] forState:UIControlStateNormal];
    [appActionButton setImage:[UIImage imageNamed:@"like-heart"] size:CGSizeMake(BUTTON_HEIGHT - 20, BUTTON_HEIGHT - 20)];
    [appActionButton addTarget:self action:@selector(didAppTouch) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:appActionButton];

    
    [self.view addSubview:contentView];
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
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:nil];
    });
}

- (void)dismiss:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
            if (completion) {
                completion();
            }
        }];
    });
}

- (void)dismiss {
    [self dismiss:NULL];
}

- (void)didFbTouch {
    [self dismiss:fbBlock];
}

- (void)didTwitterTouch {
    [self dismiss:twitterBlock];
}

- (void)didAppTouch {
    [self dismiss:appBlock];
}

@end
