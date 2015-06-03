//
//  SettingsSecretViewController.m
//  Flooz
//
//  Created by Olivier on 5/4/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "SettingsSecretViewController.h"
#import "FLTextFieldSignup.h"
#import "IQActionSheetPickerView.h"
#import "SecureCodeViewController.h"
#import "ActionSheetPicker.h"

#define PADDING_SIDE 20.0f

@interface SettingsSecretViewController ()<IQActionSheetPickerViewDelegate> {
    
    NSMutableDictionary *_userSecret;
    
    UIView *infoView;
    UIView *editView;
    
    FLTextFieldSignup *_questionTextfield;
    FLTextFieldSignup *_question2Textfield;
    FLTextFieldSignup *_answerTextfield;
    
    FLActionButton *_saveButton;
    
    CGFloat height;
    
    BOOL question2Visible;
    
    NSUInteger selectedQuestion;
    NSMutableArray *questionList;
    
    BOOL access;
    BOOL firstAppear;
}


@end

@implementation SettingsSecretViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = NSLocalizedString(@"SETTINGS_SECRET", nil);
        
        questionList = [[[[Flooz sharedInstance] currentTexts] secretQuestions] mutableCopy];
        
        [questionList addObject:NSLocalizedString(@"CUSTOM_SECRET_QUESTION", nil)];
        firstAppear = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createEditView];
    [self createInfoView];
    
    if ([[Flooz sharedInstance] currentUser].settings[@"secret"] && [[Flooz sharedInstance] currentUser].settings[@"secret"][@"question"] && ![[[Flooz sharedInstance] currentUser].settings[@"secret"][@"question"] isBlank]) {
        [_mainBody addSubview:infoView];
    } else {
        access = NO;
        [[Flooz sharedInstance] showLoadView];
        SecureCodeViewController *controller = [SecureCodeViewController new];
        controller.completeBlock = ^{
            access = YES;
        };
        [_mainBody addSubview:editView];
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:^{
            [[Flooz sharedInstance] hideLoadView];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!firstAppear) {
        [[Flooz sharedInstance] showLoadView];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[Flooz sharedInstance] hideLoadView];
            if (![[Flooz sharedInstance] currentUser].settings[@"secret"] || ![[Flooz sharedInstance] currentUser].settings[@"secret"][@"question"] || [[[Flooz sharedInstance] currentUser].settings[@"secret"][@"question"] isBlank]) {
                if (!access)
                    [self dismissViewController];
            }
        });
    }
    firstAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)createInfoView {
    infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    
    UILabel *infoLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"SETTINGS_SECRET_INFOS", nil) textColor:[UIColor whiteColor] font:[UIFont customContentRegular:17] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetPosition(infoLabel.frame, CGRectGetWidth(infoView.frame) / 2 - CGRectGetWidth(infoLabel.frame) / 2, 20);
    
    [infoView addSubview:infoLabel];
    
    UILabel *infoQuestion = [[UILabel alloc] initWithText:[NSString stringWithFormat:@"\"%@\"", [[Flooz sharedInstance] currentUser].settings[@"secret"][@"question"]] textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:18] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetPosition(infoQuestion.frame, CGRectGetWidth(infoView.frame) / 2 - CGRectGetWidth(infoQuestion.frame) / 2, CGRectGetMaxY(infoLabel.frame) + 10);
    
    [infoView addSubview:infoQuestion];
    
    FLActionButton *editButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(infoQuestion.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"GLOBAL_EDIT", nil)];
    [editButton addTarget:self action:@selector(editInfos) forControlEvents:UIControlEventTouchUpInside];
    [infoView addSubview:editButton];
    
    UILabel *descLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"SETTINGS_SECRET_DESC", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:15]];
    [descLabel setTextAlignment:NSTextAlignmentCenter];
    [descLabel setAdjustsFontSizeToFitWidth:NO];
    [descLabel setNumberOfLines:0];
    CGRectSetWidth(descLabel.frame, CGRectGetWidth(infoView.frame) - 40);
    [descLabel sizeToFit];
    CGRectSetPosition(descLabel.frame, CGRectGetWidth(infoView.frame) / 2 - CGRectGetWidth(descLabel.frame) / 2, CGRectGetHeight(infoView.frame) - CGRectGetHeight(descLabel.frame) - 30);
    [infoView addSubview:descLabel];
}

- (void)createEditView {
    editView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_mainBody.frame), CGRectGetHeight(_mainBody.frame))];
    
    question2Visible = NO;
    
    _userSecret = [NSMutableDictionary new];
    
    _questionTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_SECRET_QUESTION" for:_userSecret key:@"question" position:CGPointMake(PADDING_SIDE, 0.0f)];
    [_questionTextfield addForNextClickTarget:self action:@selector(focusOnNextInfo)];
    [_questionTextfield addForTextChangeTarget:self action:@selector(canValidate:)];
    [_questionTextfield setEnable:NO];
    [_questionTextfield setUserInteractionEnabled:YES];
    [_questionTextfield addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPickerView)]];
    [editView addSubview:_questionTextfield];
    
    _question2Textfield = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_SECRET_QUESTION_OTHER" for:_userSecret key:@"question2" frame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_questionTextfield.frame) + 3.0f, SCREEN_WIDTH - (PADDING_SIDE * 2), 0.0f)];
    [_question2Textfield addForNextClickTarget:self action:@selector(focusOnNextInfo)];
    [_question2Textfield addForTextChangeTarget:self action:@selector(canValidate:)];
    [_question2Textfield setHidden:YES];
    CGRectSetHeight(_question2Textfield.frame, 0);
    [editView addSubview:_question2Textfield];
    
    _answerTextfield = [[FLTextFieldSignup alloc] initWithPlaceholder:@"FIELD_SECRET_ANSWER" for:_userSecret key:@"answer" position:CGPointMake(PADDING_SIDE, CGRectGetMaxY(_questionTextfield.frame) + 3.0f)];
    [_answerTextfield addForNextClickTarget:self action:@selector(focusOnNextInfo)];
    [_answerTextfield addForTextChangeTarget:self action:@selector(canValidate:)];
    [editView addSubview:_answerTextfield];
    
    _saveButton = [[FLActionButton alloc] initWithFrame:CGRectMake(PADDING_SIDE, CGRectGetMaxY(_answerTextfield.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight) title:NSLocalizedString(@"Save", nil)];
    [_saveButton setEnabled:NO];
    [_saveButton addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
    [editView addSubview:_saveButton];
    
    UILabel *descLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"SETTINGS_SECRET_DESC", nil) textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:15]];
    [descLabel setTextAlignment:NSTextAlignmentCenter];
    [descLabel setAdjustsFontSizeToFitWidth:NO];
    [descLabel setNumberOfLines:0];
    CGRectSetWidth(descLabel.frame, CGRectGetWidth(editView.frame) - 40);
    [descLabel sizeToFit];
    CGRectSetPosition(descLabel.frame, CGRectGetWidth(editView.frame) / 2 - CGRectGetWidth(descLabel.frame) / 2, CGRectGetHeight(editView.frame) - CGRectGetHeight(descLabel.frame) - 30);
    [editView addSubview:descLabel];
}

- (void)showPickerView {
    [self hideKeyboard];
//    
//    [ActionSheetStringPicker showPickerWithTitle:@"Select a Color" rows:questionList initialSelection:selectedQuestion
//                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//                                           NSString *title = selectedValue;
//                                           
//                                           if ([title isEqualToString:NSLocalizedString(@"CUSTOM_SECRET_QUESTION", nil)]) {
//                                               if (!question2Visible) {
//                                                   [_question2Textfield setHidden:NO];
//                                                   [UIView animateWithDuration:0.3 animations:^{
//                                                       _question2Textfield.frame = CGRectMake(CGRectGetMinX(_question2Textfield.frame), CGRectGetMinY(_question2Textfield.frame), CGRectGetWidth(_question2Textfield.frame), 40.0f);
//                                                       _answerTextfield.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_question2Textfield.frame) + 3.0f, SCREEN_WIDTH - (PADDING_SIDE * 2), 40.0f);
//                                                       _saveButton.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_answerTextfield.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight);
//                                                   } completion:^(BOOL finished){
//                                                       [_question2Textfield setEnable:YES];
//                                                       [_question2Textfield becomeFirstResponder];
//                                                       question2Visible = YES;
//                                                   }];
//                                               }
//                                           } else {
//                                               if (question2Visible) {
//                                                   [_question2Textfield setEnable:NO];
//                                                   [UIView animateWithDuration:0.3 animations:^{
//                                                       _question2Textfield.frame = CGRectMake(CGRectGetMinX(_question2Textfield.frame), CGRectGetMinY(_question2Textfield.frame), CGRectGetWidth(_question2Textfield.frame), 0.0f);
//                                                       _answerTextfield.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_questionTextfield.frame) + 3.0f, SCREEN_WIDTH - (PADDING_SIDE * 2), 40.0f);
//                                                       _saveButton.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_answerTextfield.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight);
//                                                   } completion:^(BOOL finished){
//                                                       question2Visible = NO;
//                                                       [_question2Textfield setHidden:YES];
//                                                   }];
//                                               }
//                                           }
//                                           
//                                           selectedQuestion = [questionList indexOfObjectIdenticalTo:title];
//                                           
//                                           [_userSecret setObject:title forKey:@"question"];
//                                           [_questionTextfield reloadTextField];
//                                           [self canValidate:nil];
//                                       } cancelBlock:^(ActionSheetStringPicker *picker) {
//                                           
//                                       } origin:self.view];
//    
        IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:NSLocalizedString(@"SETTINGS_SECRET", nil) delegate:self];
        [picker setBackgroundColor:[UIColor customBackgroundHeader]];
        [picker setTitlesForComponenets:@[questionList]];
        if (![_questionTextfield.textfield.text isBlank])
            [picker setSelectedTitles:@[questionList[selectedQuestion]]];
        [picker show];
}

- (void)editInfos {
    SecureCodeViewController *controller = [SecureCodeViewController new];
    controller.completeBlock = ^{
        [infoView removeFromSuperview];
        [_mainBody addSubview:editView];
    };
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:controller] animated:YES completion:nil];
}

- (void)focusOnNextInfo {
    if ([_question2Textfield isFirstResponder])
        [_answerTextfield becomeFirstResponder];
    else if ([_answerTextfield isFirstResponder]) {
        [self hideKeyboard];
    }
}

- (BOOL)canValidate:(FLTextFieldSignup *)textIcon {
    BOOL canValidate = YES;
    
    if (_userSecret[@"question"] && ![_userSecret[@"question"] isBlank]) {
        if ([_userSecret[@"question"] isEqualToString:NSLocalizedString(@"CUSTOM_SECRET_QUESTION", nil)]) {
            if (_userSecret[@"question2"] == nil || [_userSecret[@"question2"] isBlank])
                canValidate = NO;
        }
    } else
        canValidate = NO;
    
    if (_userSecret[@"answer"] == nil ||
        [_userSecret[@"answer"] isBlank])
        canValidate = NO;
    
    if (canValidate) {
        [_saveButton setEnabled:YES];
    }
    else {
        [_saveButton setEnabled:NO];
    }
    return canValidate;
}

- (void)saveChanges {
    if (![self canValidate:nil]) {
        return;
    }
    
    [[self view] endEditing:YES];
    
    NSMutableDictionary *userDic = [NSMutableDictionary new];
    
    userDic[@"settings"] = @{@"secret":@{@"question":([_userSecret[@"question"] isEqualToString:NSLocalizedString(@"CUSTOM_SECRET_QUESTION", nil)] ? _userSecret[@"question2"] : _userSecret[@"question"]), @"answer":_userSecret[@"answer"]}};
    
    [[Flooz sharedInstance] showLoadView];
    [[Flooz sharedInstance] updateUser:userDic success: ^(id result) {
        [self dismissViewController];
    } failure:NULL];
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    if (titles && [titles count] == 1) {
        NSString *title = titles[0];
        
        if ([title isEqualToString:NSLocalizedString(@"CUSTOM_SECRET_QUESTION", nil)]) {
            if (!question2Visible) {
                [_question2Textfield setHidden:NO];
                [UIView animateWithDuration:0.3 animations:^{
                    _question2Textfield.frame = CGRectMake(CGRectGetMinX(_question2Textfield.frame), CGRectGetMinY(_question2Textfield.frame), CGRectGetWidth(_question2Textfield.frame), 40.0f);
                    _answerTextfield.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_question2Textfield.frame) + 3.0f, SCREEN_WIDTH - (PADDING_SIDE * 2), 40.0f);
                    _saveButton.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_answerTextfield.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight);
                } completion:^(BOOL finished){
                    [_question2Textfield setEnable:YES];
                    [_question2Textfield becomeFirstResponder];
                    question2Visible = YES;
                }];
            }
        } else {
            if (question2Visible) {
                [_question2Textfield setEnable:NO];
                [UIView animateWithDuration:0.3 animations:^{
                    _question2Textfield.frame = CGRectMake(CGRectGetMinX(_question2Textfield.frame), CGRectGetMinY(_question2Textfield.frame), CGRectGetWidth(_question2Textfield.frame), 0.0f);
                    _answerTextfield.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_questionTextfield.frame) + 3.0f, SCREEN_WIDTH - (PADDING_SIDE * 2), 40.0f);
                    _saveButton.frame = CGRectMake(PADDING_SIDE, CGRectGetMaxY(_answerTextfield.frame) + 40, PPScreenWidth() - PADDING_SIDE * 2, FLActionButtonDefaultHeight);
                } completion:^(BOOL finished){
                    question2Visible = NO;
                    [_question2Textfield setHidden:YES];
                }];
            }
        }
        
        selectedQuestion = [questionList indexOfObjectIdenticalTo:title];
        
        [_userSecret setObject:title forKey:@"question"];
        [_questionTextfield reloadTextField];
        [self canValidate:nil];
    }
}

@end
