//
//  FLPopupAskInviteCode.m
//  Flooz
//
//  Created by Epitech on 11/4/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLPopupAskInviteCode.h"
#import "AppDelegate.h"

#define MARGE 30.
#define PADDING_TOP_BOTTOM 20.
#define PADDING_LEFT_RIGHT 20.
#define BUTTON_HEIGHT 50.
#define ANIMATION_DELAY 0.4

@interface FLPopupAskInviteCode () {
    FLTextFieldSignup *_name;
    FLTextFieldSignup *_email;
    
    UIButton    *_sendButton;
    
    NSMutableDictionary *_userDic;
    
    void (^returnBlock)();
}

@end

@implementation FLPopupAskInviteCode

- (id)initWithUser:(NSMutableDictionary *)user andCompletionBlock:(void (^)())completionBlock
{
    CGRect frame = CGRectMake(MARGE, 150, SCREEN_WIDTH - 2 * MARGE, 0);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
        
        returnBlock = completionBlock;
        
        _userDic = user;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRemoveWindowSubviews) name:kNotificationRemoveWindowSubviews object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)createViews {
    [FLHelper addMotionEffect:self];
    
    CGFloat height = 15;
    
    {
        self.backgroundColor = [UIColor customBlue];
        self.layer.borderWidth = 1.;
        self.layer.borderColor = [UIColor customSeparator].CGColor;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(-1, -1);
        self.layer.shadowOpacity = .5;
    }
    
    {
        UIImageView *view = [UIImageView imageNamed:@"white-logo"];
        view.contentMode = UIViewContentModeScaleAspectFit;
        
        CGRectSetHeight(view.frame, 40);
        CGRectSetXY(view.frame, (CGRectGetWidth(self.frame) - CGRectGetWidth(view.frame)) / 2., height);
        
        [self addSubview:view];
        
        height += CGRectGetHeight(view.frame);
    }
    
    height += 10;
    
    {
        _name = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_FULLNAME", nil) for:_userDic key:@"name" frame:CGRectMake(10, height, CGRectGetWidth(self.frame) - 20, 20)];
        _name.bottomBar.backgroundColor = [UIColor whiteColor];
        _name.textfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIELD_FULLNAME", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        _name.textfield.tintColor = [UIColor whiteColor];
        [_name addForNextClickTarget:self action:@selector(nextName)];
        
        [self addSubview:_name];
        height += CGRectGetHeight(_name.frame);
    }
    
    height += 5;
    
    {
        _email = [[FLTextFieldSignup alloc] initWithPlaceholder:NSLocalizedString(@"FIELD_EMAIL", nil) for:_userDic key:@"email" frame:CGRectMake(10, height, CGRectGetWidth(self.frame) - 20, 20)];
        _email.bottomBar.backgroundColor = [UIColor whiteColor];
        _email.textfield.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"FIELD_EMAIL", nil) attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
        _email.textfield.tintColor = [UIColor whiteColor];
        [_email addForNextClickTarget:self action:@selector(nextEmail)];
        
        [self addSubview:_email];
        height += CGRectGetHeight(_email.frame);
    }
    
    height += PADDING_TOP_BOTTOM;
    
    {
        UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, height, CGRectGetWidth(self.frame), BUTTON_HEIGHT)];
        
        [view setTitleColor:[UIColor customBlue] forState:UIControlStateNormal];
        [view setBackgroundColor:[UIColor whiteColor]];
        view.titleLabel.font = [UIFont customContentRegular:17];
        
        [view setTitle:NSLocalizedString(@"INVITATION_CODE_ASK", nil) forState:UIControlStateNormal];
        [view addTarget:self action:@selector(didAskCode) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:view];
    }
    
    height += BUTTON_HEIGHT;
    
    CGRectSetHeight(self.frame, height);
    self.center = appDelegate.window.center;
    if (IS_IPHONE4)
        CGRectSetY(self.frame, 30);
    else
        CGRectSetY(self.frame, 70);
}

- (void)nextName {
    [_email becomeFirstResponder];
}

- (void)nextEmail {
    [_name becomeFirstResponder];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        background = [[UIView alloc] initWithFrame:CGRectMakeWithSize(appDelegate.window.frame.size)];
        background.backgroundColor = [UIColor customBackground:.6];
        
        UITapGestureRecognizer *tap = [UITapGestureRecognizer new];
        [tap addTarget:self action:@selector(dismiss)];
        [background addGestureRecognizer:tap];
        
        CGAffineTransform tr = CGAffineTransformScale(self.transform, 1.1, 1.1);
        self.transform = CGAffineTransformScale(self.transform, 0, 0);
        
        background.layer.opacity = 0;
        
        [appDelegate.topWindow addSubview:background];
        [appDelegate.topWindow addSubview:self];
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             background.layer.opacity = 1;
                         }];
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             self.transform = tr;
                         } completion: ^(BOOL finished) {
                             [UIView animateWithDuration:.1
                                              animations: ^{
                                                  self.transform = CGAffineTransformIdentity;
                                              }];
                             [_name becomeFirstResponder];
                         }];
    });
}

- (void)dismiss {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             background.layer.opacity = 0;
                         }
         
                         completion: ^(BOOL finished) {
                             [background removeFromSuperview];
                         }];
        
        [UIView animateWithDuration:ANIMATION_DELAY
                         animations: ^{
                             self.transform = CGAffineTransformScale(self.transform, 0, 0);
                         }
                         completion: ^(BOOL finished) {
                             [self removeFromSuperview];
                         }];
    });
}

- (void)didAskCode {
    _userDic[@"name"] = _name.textfield.text;
    _userDic[@"email"] = _email.textfield.text;
    
    [self dismiss];
    if (returnBlock)
        returnBlock();
}

- (void)didReceiveRemoveWindowSubviews {
    [background removeFromSuperview];
    [self removeFromSuperview];
}

@end
