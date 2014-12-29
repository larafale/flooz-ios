//
//  SignupBaseViewController.h
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SIGNUP_PADDING_SIDE 20.0f

@interface SignupBaseViewController : GlobalViewController {
    UILabel *_headTitle;
    UIView *_headerView;
    UIView *_mainBody;
}

@property (nonatomic, retain) NSMutableDictionary *userDic;
@property (nonatomic) CGFloat ratioiPhones;
@property (nonatomic) CGFloat firstItemY;

- (void)displayChanges;

@end
