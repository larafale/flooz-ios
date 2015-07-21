//
//  BaseViewController.m
//  Flooz
//
//  Created by Arnaud on 2014-10-01.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.showBack = NO;
        self.showCross = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    _headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0, PPScreenWidth(), 60.0f)];
    _headerView.backgroundColor = [UIColor customBackgroundHeader];
//    [self.view addSubview:_headerView];
    
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
        
        if ([self navigationController]) {
            if ([[[self navigationController] viewControllers] count] > 1 || self.showBack) {
                [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
            }
            else if (self.showCross) {
                [backButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
            }
        }
        else if (self.showBack) {
            [backButton setImage:[UIImage imageNamed:@"navbar-back"] forState:UIControlStateNormal];
        }
        else if (self.showCross) {
            [backButton setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
        }
        
        [backButton addTarget:self action:@selector(dismissViewController) forControlEvents:UIControlEventTouchUpInside];
        [_headerView addSubview:backButton];
    }
    
    _mainBody = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, PPScreenWidth(), PPScreenHeight() - CGRectGetMaxY(_headerView.frame))];
    _mainBody.backgroundColor = [UIColor customBackgroundHeader];
    [self.view addSubview:_mainBody];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setTitle:(NSString *)title {
    [super setTitle:title];
    _headTitle.text = self.title;
}

@end
