//
//  ShopParamViewController.m
//  Flooz
//
//  Created by Olive on 18/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopParamViewController.h"
#import "FLShopSwitch.h"
#import "FLShopStepper.h"
#import "FLShopTextField.h"

#define BUTTON_HEIGHT 40.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_MARGE 15.

@interface ShopParamViewController () {
    CGFloat keyboardHeight;
}

@property (nonatomic) CGFloat contentheight;

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) NSMutableDictionary *params;
@property (nonatomic, strong) NSMutableArray *buttonsString;
@property (nonatomic, strong) NSMutableArray *buttonsAction;

@property (nonatomic, strong) UIView *actionArea;

@end

@implementation ShopParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
    self.buttonsString = [NSMutableArray new];
    self.buttonsAction = [NSMutableArray new];
    self.params = [NSMutableDictionary new];
    
    if (self.triggerData[@"buttons"]) {
        for (NSDictionary *button in self.triggerData[@"buttons"]) {
            if (button[@"title"]) {
                [self.buttonsString addObject:button[@"title"]];
                
                if (button[@"triggers"])
                    [self.buttonsAction addObject:button[@"triggers"]];
                else
                    [self.buttonsAction addObject:@[]];
            }
        }
    }
    
    if (![self.buttonsString count]) {
        [self.buttonsString addObject:NSLocalizedString(@"GLOBAL_OK", nil)];
        [self.buttonsAction addObject:@[]];
    }
    
    self.contentheight = 10;
    
    self.contentView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth(), CGRectGetHeight(_mainBody.frame))];
    self.contentView.bounces = NO;
    
    
    if (self.triggerData[@"header"]) {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.contentheight, PPScreenWidth() - 20, 0)];
        headerLabel.numberOfLines = 0;
        headerLabel.font = [UIFont customContentRegular:15];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.textAlignment = NSTextAlignmentCenter;
        headerLabel.text = self.triggerData[@"header"];
        
        [headerLabel setHeightToFit];
        
        [self.contentView addSubview:headerLabel];
        
        self.contentheight = CGRectGetMaxY(headerLabel.frame) + 10;
    }
    
    if (self.triggerData[@"fields"] && [self.triggerData[@"fields"] count]) {
        for (NSDictionary *field in self.triggerData[@"fields"]) {
            FLShopField *fieldView;
            
            if ([field[@"type"] isEqualToString:@"stepper"]) {
                fieldView = [[FLShopStepper alloc] initWithOptions:field dic:self.params];
            } else if ([field[@"type"] isEqualToString:@"switch"]) {
                fieldView = [[FLShopSwitch alloc] initWithOptions:field dic:self.params];
            } else if ([field[@"type"] rangeOfString:@"textfield"].location != NSNotFound) {
                fieldView = [[FLShopTextField alloc] initWithOptions:field dic:self.params];
            } else
                continue;
            
            CGRectSetY(fieldView.frame, self.contentheight);
            
            [self.contentView addSubview:fieldView];
            
            self.contentheight = CGRectGetMaxY(fieldView.frame);
        }
    }
    
    self.contentheight += 10;
    CGFloat actionAreaHeight = 0;
    
    self.actionArea = [[UIView alloc] initWithFrame:CGRectMake(0, self.contentheight, PPScreenWidth(), 0)];
    
    if ([self.buttonsString count] == 1) {
        FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(30, actionAreaHeight, PPScreenWidth() - 2 * 30, BUTTON_HEIGHT) title:self.buttonsString[0]];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:1];
        [self.actionArea addSubview:btn];
        
        actionAreaHeight = CGRectGetMaxY(btn.frame);
    } else {
        FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, PPScreenWidth() / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:self.buttonsString[0]];
        [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:1];
        [self.actionArea addSubview:btn];
        
        FLActionButton *btn2 = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) + PADDING_LEFT_RIGHT + BUTTON_MARGE, actionAreaHeight, PPScreenWidth() / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:self.buttonsString[1]];
        [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn2 setTag:2];
        [self.actionArea addSubview:btn2];
        
        actionAreaHeight = CGRectGetMaxY(btn.frame);
    }
    
    if ([self.buttonsString count] > 2) {
        actionAreaHeight += BUTTON_MARGE;
        
        if ([self.buttonsString count] == 3) {
            FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, PPScreenWidth() - 2 * PADDING_LEFT_RIGHT, BUTTON_HEIGHT) title:self.buttonsString[2]];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:3];
            [self.actionArea addSubview:btn];
            
            actionAreaHeight = CGRectGetMaxY(btn.frame);
        } else {
            FLActionButton *btn = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_LEFT_RIGHT, actionAreaHeight, PPScreenWidth() / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:self.buttonsString[2]];
            [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:3];
            [self.actionArea addSubview:btn];
            
            FLActionButton *btn2 = [[FLActionButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(btn.frame) + PADDING_LEFT_RIGHT + BUTTON_MARGE, actionAreaHeight, PPScreenWidth() / 2 - PADDING_LEFT_RIGHT - BUTTON_MARGE / 2, BUTTON_HEIGHT) title:self.buttonsString[3]];
            [btn2 addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn2 setTag:4];
            [self.actionArea addSubview:btn2];
            
            actionAreaHeight = CGRectGetMaxY(btn.frame);
        }
    }
    
    CGRectSetHeight(self.actionArea.frame, actionAreaHeight);
    
    self.contentheight = CGRectGetMaxY(self.actionArea.frame) + 20;
    
    [self.contentView addSubview:self.actionArea];
    [self.contentView setContentSize:CGSizeMake(PPScreenWidth(), self.contentheight)];
    
    [_mainBody addSubview:self.contentView];
}

- (void)buttonClick:(UIView *)sender {
    [self.view endEditing:YES];
    
    NSArray<FLTrigger *> *successTriggers = [FLTriggerManager convertDataInList:self.buttonsAction[sender.tag - 1]];
    FLTrigger *successTrigger = successTriggers[0];
    
    NSDictionary *baseDic;
    
    if (self.triggerData[@"in"]) {
        baseDic = successTrigger.data[self.triggerData[@"in"]];
        
        [self.params addEntriesFromDictionary:baseDic];
        
        NSMutableDictionary *newData = [successTrigger.data mutableCopy];
        
        newData[self.triggerData[@"in"]] = self.params;
        
        successTrigger.data = newData;
    } else {
        baseDic = successTrigger.data;
        [self.params addEntriesFromDictionary:baseDic];
        
        successTrigger.data = self.params;
    }
    
    [[FLTriggerManager sharedInstance] executeTriggerList:successTriggers];
}

#pragma mark - Keyboard Management

- (void)registerForKeyboardNotifications {
    [self registerNotification:@selector(keyboardDidAppear:) name:UIKeyboardWillShowNotification object:nil];
    [self registerNotification:@selector(keyboardWillDisappear) name:UIKeyboardWillHideNotification object:nil];
    [self registerNotification:@selector(keyboardFrameChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)keyboardDidAppear:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetHeight(self.contentView.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetMinY(self.contentView.frame));
}

- (void)keyboardFrameChanged:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    keyboardHeight = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRectSetHeight(self.contentView.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetMinY(self.contentView.frame));
}

- (void)keyboardWillDisappear {
    keyboardHeight = 0;
    
    CGRectSetHeight(self.contentView.frame, CGRectGetHeight(_mainBody.frame) - keyboardHeight - CGRectGetMinY(self.contentView.frame));
}

@end
