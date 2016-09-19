//
//  FLPopupTrigger.m
//  Flooz
//
//  Created by Epitech on 9/29/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "FLPopupTrigger.h"

#define BUTTON_MARGE 15.
#define MARGE 20.
#define PADDING_TOP_BOTTOM 25.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 40.
#define ANIMATION_DELAY 0.4

@interface FLPopupTrigger () {
    NSMutableArray *actionsArray;
    
    BOOL closable;
    NSString *title;
    NSString *content;
    NSMutableArray *buttonsString;
    NSMutableArray *buttonsAction;
    
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIFont *titleFont;
    UIFont *contentFont;
    
    UIView *contentView;
    UIView *actionArea;
    
    void (^dismissBlock)(void);
}

@end

@implementation FLPopupTrigger

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        buttonsString = [NSMutableArray new];
        buttonsAction = [NSMutableArray new];
        
        title = data[@"title"];
        content = data[@"content"];
        
        if (data[@"close"])
            closable = [data[@"close"] boolValue];
        
        if (data[@"buttons"]) {
            for (NSDictionary *button in data[@"buttons"]) {
                if (button[@"title"]) {
                    [buttonsString addObject:button[@"title"]];
                    
                    if (button[@"triggers"])
                        [buttonsAction addObject:button[@"triggers"]];
                    else
                        [buttonsAction addObject:@[]];
                }
            }
        }
        
        if (![buttonsString count]) {
            [buttonsString addObject:NSLocalizedString(@"GLOBAL_OK", nil)];
            [buttonsAction addObject:@[]];
        }
        
        [self commmonInit];
    }
    return self;
}

- (id)initWithData:(NSDictionary*)data dismiss:(void (^)())block {
    self = [self initWithData:data];
    if (self) {
        dismissBlock = block;
    }
    return self;
}

- (void)commmonInit {
    
    titleFont = [UIFont customContentBold:22];
    contentFont = [UIFont customContentRegular:18];
    
    viewWidth = 250;
    viewHeight = PADDING_TOP_BOTTOM;
    NSDictionary *attributes;
    CGRect rect;
    
    CGFloat titleMaxWidth = viewWidth - 2 * PADDING_LEFT_RIGHT - 5;
    
    if (closable)
        titleMaxWidth -= 2 * PADDING_LEFT_RIGHT;
    
    if (title && ![title isBlank]) {
        attributes = @{NSFontAttributeName: titleFont};
        rect = [title boundingRectWithSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        
        viewHeight += rect.size.height + MARGE;
    }
    
    attributes = @{NSFontAttributeName: contentFont};
    rect = [content boundingRectWithSize:CGSizeMake(viewWidth - PADDING_LEFT_RIGHT - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
    
    viewHeight += rect.size.height + MARGE + BUTTON_HEIGHT + PADDING_TOP_BOTTOM;
    
    if ([buttonsString count] > 2)
        viewHeight +=  BUTTON_MARGE + BUTTON_HEIGHT;
    
    [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
}

- (void)viewDidLoad {
    CGFloat offsetY = PADDING_TOP_BOTTOM;
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    
    [contentView.layer setMasksToBounds:YES];
    [contentView.layer setCornerRadius:2];
    
    CGFloat titleMaxWidth = viewWidth - 2 * PADDING_LEFT_RIGHT - 5;
    CGFloat titleX = PADDING_LEFT_RIGHT;
    
    if (closable) {
        titleMaxWidth -= 2 * PADDING_LEFT_RIGHT;
        titleX += PADDING_LEFT_RIGHT;
    }
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(titleX, offsetY, titleMaxWidth, 0)];
    titleView.font = titleFont;
    titleView.textColor = [UIColor customBlue];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    
    titleView.text = title;
    [titleView setHeightToFit];
    
    [contentView addSubview:titleView];

    UIButton *closeButton = [UIButton newWithFrame:CGRectMake(viewWidth - 30, 5, 25, 25)];
    [closeButton setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [contentView addSubview:closeButton];
    
    if (!closable)
        closeButton.hidden = YES;
    
    if (!title || [title isBlank]) {
        [titleView setHidden:YES];
    } else {
        offsetY += CGRectGetHeight(titleView.frame) + MARGE;
    }
    
    UILabel *msgView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT / 2, offsetY, viewWidth - PADDING_LEFT_RIGHT - 5, 0)];
    msgView.font = contentFont;
    msgView.textColor = [UIColor customPlaceholder];
    msgView.textAlignment = NSTextAlignmentCenter;
    msgView.numberOfLines = 0;
    
    msgView.text = content;
    [msgView setHeightToFit];
    
    [contentView addSubview:msgView];
    
    offsetY += CGRectGetHeight(msgView.frame) + MARGE;
    
    CGFloat actionAreaHeight = 0;
    
    actionArea = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, viewWidth, 0)];
    
    if ([buttonsString count] == 1) {
        FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:buttonsString[0]];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:1];
        [actionArea addSubview:btn];
        
        actionAreaHeight = CGRectGetMaxY(btn.frame);
    } else {
        FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, viewWidth / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:buttonsString[0]];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:1];
        [actionArea addSubview:btn];
        
        FLActionButton *btn2 = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) + PADDING_LEFT_RIGHT + BUTTON_MARGE, actionAreaHeight, viewWidth / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:buttonsString[1]];
        [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setTag:2];
        [actionArea addSubview:btn2];
        
        actionAreaHeight = CGRectGetMaxY(btn.frame);
    }
    
    if ([buttonsString count] > 2) {
        actionAreaHeight += BUTTON_MARGE;
        
        if ([buttonsString count] == 3) {
            FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, viewWidth - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:buttonsString[2]];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:3];
            [actionArea addSubview:btn];
            
            actionAreaHeight = CGRectGetMaxY(btn.frame);
        } else {
            FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, viewWidth / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:buttonsString[2]];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:3];
            [actionArea addSubview:btn];
            
            FLActionButton *btn2 = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) + PADDING_LEFT_RIGHT + BUTTON_MARGE, actionAreaHeight, viewWidth / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:buttonsString[3]];
            [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn2 setTag:4];
            [actionArea addSubview:btn2];
            
            actionAreaHeight = CGRectGetMaxY(btn.frame);
        }
    }
    
    CGRectSetHeight(actionArea.frame, actionAreaHeight);
    
    [contentView addSubview:actionArea];
    
    [self.view addSubview:contentView];
}

- (void)buttonClick:(UIView *)sender {
    id data = buttonsAction[sender.tag - 1];
    
    [self dismiss:^{
        if ([data isKindOfClass:[NSArray class]]) {
            [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:data]];
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            FLTrigger *tmp = [[FLTrigger alloc] initWithJson:data];
            
            if (tmp) {
                [[FLTriggerManager sharedInstance] executeTrigger:tmp];
            }
        }
    }];
}

- (void)show {
    [self show:nil];
}

- (void)show:(dispatch_block_t)completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        _formSheet = [[MZFormSheetController alloc] initWithViewController:self];
        _formSheet.presentedFormSheetSize = self.preferredContentSize;
        _formSheet.transitionStyle = MZFormSheetTransitionStyleSlideFromTop;
        _formSheet.shadowRadius = 2.0;
        _formSheet.shadowOpacity = 0.3;
        _formSheet.shouldDismissOnBackgroundViewTap = NO;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
            if (completion)
                completion();
        }];
    });
}

- (void)dismiss:(void (^)())completion {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[appDelegate myTopViewController] mz_dismissFormSheetControllerAnimated:YES completionHandler: ^(MZFormSheetController *formSheetController) {
            _formSheet = nil;
            
            if (dismissBlock)
                dismissBlock();
            
            if (completion)
                completion();

        }];
    });
}

- (void)dismiss {
    [self dismiss:nil];
}

@end
