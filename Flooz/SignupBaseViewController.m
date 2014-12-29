//
//  SignupBaseViewController.m
//  Flooz
//
//  Created by Olivier on 12/29/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "SignupBaseViewController.h"

@implementation SignupBaseViewController

@synthesize userDic;
@synthesize firstItemY;
@synthesize ratioiPhones;

- (id)init {
    self = [super init];
    if (self) {
        self.userDic = [NSMutableDictionary new];
        self.ratioiPhones = 1.0f;
        if (PPScreenHeight() < 568) {
            self.ratioiPhones = 1.2f;
        }
        self.firstItemY = 25.0f / self.ratioiPhones;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, STATUSBAR_HEIGHT, PPScreenWidth(), 60.0f)];
    _headerView.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_headerView];
    
    {
        _headTitle = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(_headerView.frame), CGRectGetHeight(_headerView.frame))];
        _headTitle.font = [UIFont customTitleNav];
        _headTitle.textColor = [UIColor customBlue];
        _headTitle.numberOfLines = 1;
        _headTitle.textAlignment = NSTextAlignmentCenter;
        _headTitle.text = self.title;
        [_headerView addSubview:_headTitle];
    }
    
    {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(17.0f, 0.0f, 30.0f, CGRectGetHeight(_headerView.frame))];
        
        [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
        
        [backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:backButton];
    }
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, CGRectGetMaxY(_headerView.frame), PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_headerView.frame))];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_mainBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)displayChanges {

}

@end
