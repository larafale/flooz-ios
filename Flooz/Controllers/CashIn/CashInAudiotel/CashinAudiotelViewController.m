//
//  CashinAudiotelViewController.m
//  Flooz
//
//  Created by Olive on 4/14/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "FLBorderedActionButton.h"
#import "CashinAudiotelViewController.h"
#import "AudiotelCodePopup.h"

@interface CashinAudiotelViewController () {
    NSMutableDictionary *dictionary;
    
    UILabel *h1;
    UIImageView *numberView;
    UILabel *numberHint;
    
    FLBorderedActionButton *useCodeButton;
    AudiotelCodePopup *codePopup;
}

@end

@implementation CashinAudiotelViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    dictionary = [NSMutableDictionary new];
    
    if (!self.title || [self.title isBlank])
        self.title = @"Créditer mon compte";

    h1 = [[UILabel alloc] initWithText:@"Pour obtenir un code, appelez le :" textColor:[UIColor whiteColor] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(h1.frame, 10, 20);
    CGRectSetWidth(h1.frame, PPScreenWidth() - 20);
    [h1 setHeightToFit];
    
    numberView = [[UIImageView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(h1.frame) + 20, PPScreenWidth() - 40, 60)];
    [numberView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(callButtonClick)]];
    [numberView setUserInteractionEnabled:YES];
    [numberView setContentMode:UIViewContentModeScaleAspectFit];
    
    [numberView sd_setImageWithURL:[NSURL URLWithString:@"http://www.flooz.me/img/audiotel/num3e.png"]];
    
    numberHint = [[UILabel alloc] initWithText:@"Code valable 48h" textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:13] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    CGRectSetXY(numberHint.frame, 10, CGRectGetMaxY(numberView.frame) + 10);
    CGRectSetWidth(numberHint.frame, PPScreenWidth() - 20);
    [numberHint setHeightToFit];
    
    useCodeButton = [[FLBorderedActionButton alloc] initWithFrame:CGRectMake(40, CGRectGetHeight(_mainBody.frame) - 60, PPScreenWidth() - 80, 40) title:@"Utiliser un code"];
    [useCodeButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];

    [_mainBody addSubview:h1];
    [_mainBody addSubview:numberView];
    [_mainBody addSubview:numberHint];
    [_mainBody addSubview:useCodeButton];
}

- (void)callButtonClick {
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[[[Flooz sharedInstance] currentTexts] audiotelNumber]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

- (void)sendButtonClick {
    codePopup = [AudiotelCodePopup new];
    
    [codePopup show];
    
//    [[Flooz sharedInstance] showLoadView];
//    [[Flooz sharedInstance] cashinValidate:dictionary success:nil failure:nil];
}

@end
