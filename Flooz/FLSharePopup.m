//
//  FLSharePopup.m
//  Flooz
//
//  Created by Epitech on 8/17/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FLSharePopup.h"

#define MARGE 30.
#define PADDING_TOP_BOTTOM 30.
#define PADDING_LEFT_RIGHT 30.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4
#define TEXTVIEW_HEIGHT 100

@implementation FLSharePopup {
    NSString *_title;
    NSString *_placeholder;
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIFont *msgFont;
    
    FLTextView *textView;
    NSMutableDictionary *textData;
    
    UIView *contentView;
}

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder accept:(void (^)(NSString *))accept refuse:(void (^)())refuse;
{
    self = [super init];
    if (self) {
        acceptBlock = accept;
        refuseBlock = refuse;
        [self commmonInit:title placeholder:placeholder];
        
    }
    return self;
}

- (void)commmonInit:(NSString *)title placeholder:(NSString *)placeholder {
    textData = [NSMutableDictionary new];
    textData[@"share"] = @"";
    _title = title;
    _placeholder = placeholder;
    
    msgFont = [UIFont customContentRegular:18];
    
    viewWidth = PPScreenWidth() - (MARGE * 2);
    viewHeight = PADDING_TOP_BOTTOM;
    
    NSDictionary *attributes = @{NSFontAttributeName: msgFont};
    CGRect rect = [_title boundingRectWithSize:CGSizeMake(viewWidth - 2 * PADDING_LEFT_RIGHT, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE + TEXTVIEW_HEIGHT + BUTTON_HEIGHT + PADDING_TOP_BOTTOM;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
}

- (void)viewDidLoad {
    CGFloat offsetY = PADDING_TOP_BOTTOM;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:2];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, 0)];
    titleView.font = msgFont;
    titleView.textColor = [UIColor customPlaceholder];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    
    titleView.text = _title;
    
    [titleView setHeightToFit];
    
    [contentView addSubview:titleView];
    
    offsetY += CGRectGetHeight(titleView.frame) + MARGE / 2;
    
    textView = [[FLTextView alloc] initWithPlaceholder:_placeholder for:textData key:@"share" frame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, viewWidth - 2 * PADDING_LEFT_RIGHT, TEXTVIEW_HEIGHT)];
    [textView setBackgroundColor:[UIColor clearColor]];
    textView.layer.borderWidth = 0.5;
    textView.layer.borderColor = [UIColor customPlaceholder].CGColor;
    textView.layer.cornerRadius = 2;
    [textView.textView setTextColor:[UIColor blackColor]];
    [textView.textView setFont:[UIFont customContentRegular:15]];
    
    [contentView addSubview:textView];

    offsetY += CGRectGetHeight(textView.frame) + MARGE / 2;
    
    FLActionButton *refuseBtn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, offsetY, (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 - 5, BUTTON_HEIGHT) title:NSLocalizedString(@"GLOBAL_NO", nil)];
    [refuseBtn addTarget:self action:@selector(didRefuseTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:refuseBtn];
    
    FLActionButton *acceptBtn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT + (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 + 5, offsetY, (viewWidth - 2 * PADDING_LEFT_RIGHT) / 2 - 5, BUTTON_HEIGHT) title:NSLocalizedString(@"GLOBAL_SHARE", nil)];
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
        _formSheet.shouldDismissOnBackgroundViewTap = YES;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsCenterVertically;
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:nil];
    });
}

- (void)dismiss:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
            if (completion) {
                if (completion == acceptBlock) {
                    acceptBlock(textData[@"share"]);
                } else {
                    completion();
                }
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

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
