//
//  FLPopup.m
//  Flooz
//
//  Created by Olivier on 23/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLPopup.h"

#import "AppDelegate.h"


#define MARGE 20.
#define PADDING_TOP_BOTTOM 30.
#define PADDING_LEFT_RIGHT 30.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4

@implementation FLPopup {
    NSString *_msg;
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIFont *msgFont;
    
    UIView *contentView;
}

- (id)initWithMessage:(NSString *)message accept:(void (^)())accept refuse:(void (^)())refuse;
{
    self = [super init];
    if (self) {
        acceptBlock = accept;
        refuseBlock = refuse;
        [self commmonInit:message];
        
    }
    return self;
}

- (void)commmonInit:(NSString *)message {
    _msg = message;
    
    msgFont = [UIFont customContentRegular:18];
    
    viewWidth = 250;
    viewHeight = PADDING_TOP_BOTTOM;
    
    NSDictionary *attributes = @{NSFontAttributeName: msgFont};
    CGRect rect = [_msg boundingRectWithSize:CGSizeMake(viewWidth - 2 * PADDING_LEFT_RIGHT, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE + BUTTON_HEIGHT + PADDING_TOP_BOTTOM;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
}

- (void)viewDidLoad {
    CGFloat offsetY = PADDING_TOP_BOTTOM;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:2];
    
    UILabel *msgView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, 0)];
    msgView.font = msgFont;
    msgView.textColor = [UIColor customPlaceholder];
    msgView.textAlignment = NSTextAlignmentCenter;
    msgView.numberOfLines = 0;
    
    msgView.text = _msg;
    
    [msgView setHeightToFit];
    
    [contentView addSubview:msgView];
    
    offsetY += CGRectGetHeight(msgView.frame) + MARGE;
    
    FLActionButton *refuseBtn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 - 5, BUTTON_HEIGHT) title:NSLocalizedString(@"GLOBAL_NO", nil)];
    [refuseBtn addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:refuseBtn];

    FLActionButton *acceptBtn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT + (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 + 5, offsetY, (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 - 5, BUTTON_HEIGHT) title:NSLocalizedString(@"GLOBAL_YES", nil)];
    [acceptBtn.titleLabel setFont:[UIFont customContentBold:20]];
    [acceptBtn addTarget:self action:@selector(didAcceptTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:acceptBtn];
    
    [self.view addSubview:contentView];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _formSheet = [[MZFormSheetController alloc] initWithViewController:self];
        _formSheet.presentedFormSheetSize = self.preferredContentSize;
        _formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        _formSheet.shadowRadius = 2.0;
        _formSheet.shadowOpacity = 0.3;
        _formSheet.shouldDismissOnBackgroundViewTap = NO;
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

- (void)didAcceptTouch {
    [self dismiss:acceptBlock];
}

- (void)didRefuseTouch {
    [self dismiss:refuseBlock];
}

@end
