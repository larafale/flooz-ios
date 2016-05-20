//
//  FLCreditCardScanner.m
//  Flooz
//
//  Created by Olive on 13/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLCreditCardScanner.h"

@implementation FLCreditCardScanner{
    CGFloat viewHeight;
    CGFloat viewWidth;
    
    UIImageView *closeButton;
    
    UIView *contentView;
}

- (id)initWithDelegate:(id<CardIOViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        viewWidth = PPScreenWidth();
        viewHeight = PPScreenHeight();
        
        [self setPreferredContentSize:CGSizeMake(viewWidth, viewHeight)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    
    self.cardIOView = [[CardIOView alloc] initWithFrame:CGRectMake(0, 125, viewWidth, viewHeight - 250)];
    self.cardIOView.delegate = self.delegate;
    self.cardIOView.hideCardIOLogo = YES;
    self.cardIOView.guideColor = [UIColor customBlue];
    self.cardIOView.allowFreelyRotatingCardGuide = NO;
    self.cardIOView.scanExpiry = YES;
    self.cardIOView.layer.cornerRadius = 5.0f;
    self.cardIOView.layer.masksToBounds = YES;
    
    closeButton = [[UIImageView alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2 - 20, viewHeight - 80, 40, 40)];
    [closeButton setImage:[UIImage imageNamed:@"close-activities"]];
    [closeButton setUserInteractionEnabled:YES];
    [closeButton addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    
    [contentView addSubview:self.cardIOView];
    [contentView addSubview:closeButton];
    
    [self.view addSubview:contentView];
    
}


- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        _formSheet = [[MZFormSheetController alloc] initWithViewController:self];
        _formSheet.presentedFormSheetSize = self.preferredContentSize;
        _formSheet.transitionStyle = MZFormSheetTransitionStyleBounce;
        _formSheet.shadowRadius = 2.0;
        _formSheet.shadowOpacity = 0.3;
        _formSheet.shouldDismissOnBackgroundViewTap = YES;
        _formSheet.shouldCenterVertically = YES;
        _formSheet.movementWhenKeyboardAppears = MZFormSheetWhenKeyboardAppearsDoNothing;

        [[MZFormSheetController sharedBackgroundWindow] setBackgroundColor:[UIColor customBackgroundHeader:0.6]];
        
        [[appDelegate myTopViewController] mz_presentFormSheetController:_formSheet animated:YES completionHandler:nil];
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
