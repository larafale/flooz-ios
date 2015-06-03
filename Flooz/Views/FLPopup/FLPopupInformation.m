//
//  FLPopupInformation.m
//  Flooz
//
//  Created by Arnaud on 2014-09-10.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "FLPopupInformation.h"
#import "FLActionButton.h"

#import "AppDelegate.h"

#define MARGE 20.
#define PADDING_TOP_BOTTOM 20.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.3

@implementation FLPopupInformation {
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    NSString *_title;
    NSAttributedString *_msg;
    NSString *_btn;
    
    UIFont *titleFont;
    UIFont *msgFont;
    
    UIView *contentView;
}

- (id)initWithTitle:(NSString *)title andMessage:(NSAttributedString *)message ok:(void (^)())ok {
    self = [super init];
    if (self) {
        okBlock = ok;
        [self commmonInit:title message:message button:NSLocalizedString(@"OK", nil)];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSAttributedString *)message button:(NSString*)btn ok:(void (^)())ok {
    self = [super init];
    if (self) {
        okBlock = ok;
        
        NSString *button = (btn && ![btn isBlank] ? btn : NSLocalizedString(@"OK", nil));
        
        [self commmonInit:title message:message button:button];
    }
    return self;
}

- (void)commmonInit:(NSString *)title message:(NSAttributedString *)message button:(NSString*)btn {
    _title = title;
    _msg = message;
    _btn = btn;
    
    titleFont = [UIFont customContentBold:22];
    msgFont = [UIFont customContentRegular:18];
    
    viewWidth = 250;
    viewHeight = PADDING_TOP_BOTTOM;
    
    NSDictionary *attributes = @{NSFontAttributeName: titleFont};
    CGRect rect = [_title boundingRectWithSize:CGSizeMake(viewWidth - 2 * PADDING_LEFT_RIGHT - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE;
    
    attributes = @{NSFontAttributeName: msgFont};
    rect = [_msg.string boundingRectWithSize:CGSizeMake(viewWidth - 2 * PADDING_LEFT_RIGHT - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE + BUTTON_HEIGHT + PADDING_TOP_BOTTOM;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
}

- (void)viewDidLoad {
    CGFloat offsetY = PADDING_TOP_BOTTOM;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:2];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, 0)];
    titleView.font = titleFont;
    titleView.textColor = [UIColor customBlue];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    
    titleView.text = _title;
    [titleView setHeightToFit];
    
    [contentView addSubview:titleView];
    
    offsetY += CGRectGetHeight(titleView.frame) + MARGE;
    
    UILabel *msgView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT - 5, 0)];
    msgView.font = msgFont;
    msgView.textColor = [UIColor customPlaceholder];
    msgView.textAlignment = NSTextAlignmentCenter;
    msgView.numberOfLines = 0;
    
    msgView.attributedText = _msg;
    [msgView setHeightToFit];
    
    [contentView addSubview:msgView];
    
    offsetY += CGRectGetHeight(msgView.frame) + MARGE;
    
    FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:_btn];
    [btn addTarget:self action:@selector(okTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:btn];
    
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

- (void)okTouch {
    [self dismiss:okBlock];
}

@end
