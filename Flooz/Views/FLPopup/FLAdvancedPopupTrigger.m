//
//  FLAdvancedPopupTrigger.m
//  Flooz
//
//  Created by Olive on 28/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLAdvancedPopupTrigger.h"

#define BUTTON_MARGE 15.
#define MARGE 20.
#define PADDING_TOP_BOTTOM 25.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 40.
#define PIC_HEIGHT 65.
#define ANIMATION_DELAY 0.4

@interface FLAdvancedPopupTrigger () {
    NSMutableArray *actionsArray;
    
    BOOL closable;
    NSString *title;
    NSString *subtitle;
    NSNumber *amount;
    NSString *content;
    NSString *coverUrl;
    NSString *picUrl;
    NSMutableArray *buttonsString;
    NSMutableArray *buttonsAction;
    
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIFont *titleFont;
    UIFont *subtitleFont;
    UIFont *contentFont;
    UIFont *amountFont;
    
    UIView *contentView;
    UIView *actionArea;
    
    void (^dismissBlock)(void);
}

@end

@implementation FLAdvancedPopupTrigger

- (id)initWithData:(NSDictionary*)data {
    self = [super init];
    if (self) {
        NSLog(@"TRIGGER DATA: %@", data);
        
        buttonsString = [NSMutableArray new];
        buttonsAction = [NSMutableArray new];
        
        title = data[@"title"];
        subtitle = data[@"subtitle"];
        amount = data[@"amount"];
        content = data[@"content"];
        coverUrl = data[@"cover"];
        picUrl = data[@"pic"];
        
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
    
    titleFont = [UIFont customContentBold:20];
    subtitleFont = [UIFont customContentRegular:18];
    contentFont = [UIFont customContentRegular:18];
    amountFont = [UIFont customContentBold:27];
    
    viewWidth = 300;
    viewHeight = PADDING_TOP_BOTTOM;
    NSDictionary *attributes;
    CGRect rect;
    
    CGFloat titleMaxWidth = viewWidth - 2 * PADDING_LEFT_RIGHT - 5;
    
    if (closable)
        titleMaxWidth -= 2 * PADDING_LEFT_RIGHT;
    
    if (title && ![title isBlank]) {
        attributes = @{NSFontAttributeName: titleFont};
        rect = [title boundingRectWithSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        
        viewHeight += rect.size.height + MARGE / 2;
    }
    
    if (subtitle && ![subtitle isBlank]) {
        attributes = @{NSFontAttributeName: titleFont};
        rect = [title boundingRectWithSize:CGSizeMake(titleMaxWidth, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        
        viewHeight += rect.size.height + MARGE;
    }
    
    if (picUrl && ![picUrl isBlank])
        viewHeight += PIC_HEIGHT + MARGE;
    
    if (amount) {
        attributes = @{NSFontAttributeName: amountFont};
        rect = [[FLHelper formatedAmount:amount withCurrency:YES withSymbol:NO] boundingRectWithSize:CGSizeMake(viewWidth - PADDING_LEFT_RIGHT - 5, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:attributes context:nil];
        
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
    [contentView.layer setCornerRadius:3];
    
    CGFloat titleMaxWidth = viewWidth - 2 * PADDING_LEFT_RIGHT - 5;
    CGFloat titleX = PADDING_LEFT_RIGHT;
    
    if (closable) {
        titleMaxWidth -= 2 * PADDING_LEFT_RIGHT;
        titleX += PADDING_LEFT_RIGHT;
    }
    
    UIButton *closeButton = [UIButton newWithFrame:CGRectMake(viewWidth - 30, 5, 25, 25)];
    [closeButton setImage:[UIImage imageNamed:@"image-close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(titleX, offsetY, titleMaxWidth, 0)];
    titleView.font = titleFont;
    titleView.textColor = [UIColor whiteColor];
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.numberOfLines = 0;
    
    titleView.layer.shadowOpacity = 1.0;
    titleView.layer.shadowRadius = 0.0;
    titleView.layer.shadowColor = [UIColor blackColor].CGColor;
    titleView.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    
    titleView.text = title;
    [titleView setHeightToFit];
    
    if (!closable)
        closeButton.hidden = YES;
    
    if (!title || [title isBlank]) {
        [titleView setHidden:YES];
    } else {
        offsetY += CGRectGetHeight(titleView.frame) + MARGE / 2;
    }
    
    UILabel *subtitleView = [[UILabel alloc] initWithFrame:CGRectMake(titleX, offsetY, titleMaxWidth, 0)];
    subtitleView.font = subtitleFont;
    subtitleView.textColor = [UIColor whiteColor];
    subtitleView.textAlignment = NSTextAlignmentCenter;
    subtitleView.numberOfLines = 0;
    
    subtitleView.layer.shadowOpacity = 1.0;
    subtitleView.layer.shadowRadius = 0.0;
    subtitleView.layer.shadowColor = [UIColor blackColor].CGColor;
    subtitleView.layer.shadowOffset = CGSizeMake(0.0, -0.7);

    subtitleView.text = subtitle;
    [subtitleView setHeightToFit];
    
    if (!subtitle || [subtitle isBlank]) {
        [subtitleView setHidden:YES];
    } else {
        offsetY += CGRectGetHeight(subtitleView.frame) + MARGE;
    }
    
    UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, offsetY)];
    [coverView setContentMode:UIViewContentModeScaleAspectFill];
    
    if (coverUrl && ![coverUrl isBlank]) {
        [coverView sd_setImageWithURL:[NSURL URLWithString:coverUrl] placeholderImage:[UIImage imageNamed:@"default-cover"] options:SDWebImageRefreshCached];
    } else {
        [coverView setImage:[UIImage imageNamed:@"default-cover"]];
    }
    
    coverView.layer.masksToBounds = YES;

    [contentView addSubview:coverView];
    
    [contentView addSubview:closeButton];
    [contentView addSubview:titleView];
    [contentView addSubview:subtitleView];
    
    if (picUrl && ![picUrl isBlank]) {
        FLUserView *avatarImage = [[FLUserView alloc] initWithFrame:CGRectMake(viewWidth / 2 - PIC_HEIGHT / 2, offsetY, PIC_HEIGHT, PIC_HEIGHT)];
        
        [avatarImage setImageFromURL:picUrl];
        
        [contentView addSubview:avatarImage];
        
        CGRectSetHeight(coverView.frame, offsetY + PIC_HEIGHT / 2);
        
        offsetY += PIC_HEIGHT + MARGE;
    } else {
        offsetY += MARGE;
    }
    
    if (amount) {
        UILabel *amountView = [[UILabel alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT / 2, offsetY, viewWidth - PADDING_LEFT_RIGHT - 5, 0)];
        amountView.font = amountFont;
        amountView.textColor = [UIColor customBlue];
        amountView.textAlignment = NSTextAlignmentCenter;
        amountView.numberOfLines = 0;
        
        amountView.text = [FLHelper formatedAmount:amount withCurrency:YES withSymbol:NO];
        [amountView setHeightToFit];
        
        [contentView addSubview:amountView];
        
        offsetY += CGRectGetHeight(amountView.frame) + MARGE;
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
        FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT * 2, actionAreaHeight, viewWidth - 4 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:buttonsString[0]];
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
            FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT * 2, actionAreaHeight, viewWidth - 4 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:buttonsString[2]];
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
    
//    [self dismiss:^{
        if ([data isKindOfClass:[NSArray class]]) {
            [[FLTriggerManager sharedInstance] executeTriggerList:[FLTriggerManager convertDataInList:data]];
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            FLTrigger *tmp = [[FLTrigger alloc] initWithJson:data];
            
            if (tmp) {
                [[FLTriggerManager sharedInstance] executeTrigger:tmp];
            }
        }
//    }];
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
