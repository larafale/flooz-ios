//
//  HomeViewController.m
//  Flooz
//
//  Created by jonathan on 12/26/2013.
//  Copyright (c) 2013 Jonathan Tribouharet. All rights reserved.
//

#import "HomeViewController.h"

#import "LoginViewController.h"
#import "SignupViewController.h"

#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"

@interface HomeViewController (){
    MPMoviePlayerController *player;
    UIButton *login;
    UIButton *signup;
    
    UIScrollView *scrollView;
    UIPageControl *pageControl;
    
    UIImageView *logo;
}

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor customBackgroundHeader];
    
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"home-background" ofType:@"mp4" inDirectory:@"Video"];
        
        player = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:path]];

        player.controlStyle = MPMovieControlStyleNone;
        player.scalingMode = MPMovieScalingModeAspectFill;
        player.repeatMode = MPMovieRepeatModeOne;
        
        [self.view addSubview:player.view];
    }
    
    {
        logo = [UIImageView imageNamed:@"home-logo"];
        CGRectSetXY(logo.frame, (SCREEN_WIDTH - logo.image.size.width) / 2., 100);
        [self.view addSubview:logo];
    }
    
    {
        scrollView = [UIScrollView new];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsVerticalScrollIndicator = NO;
        
        [self.view addSubview:scrollView];
    }
    
    {
        pageControl = [UIPageControl new];
        pageControl.numberOfPages = 3;
        [self.view addSubview:pageControl];
        
        for(int i = 0; i < pageControl.numberOfPages; ++i){
            [self prepapreTextForScrollView:i];
        }
    }
    
    {
        login = [UIButton new];
        
        login.backgroundColor = [UIColor customBackgroundStatus];
        login.titleLabel.font = [UIFont customTitleLight:14];
        login.layer.opacity = 0.7;
        login.layer.cornerRadius = 2.;
        [login setTitle:NSLocalizedString(@"HOME_LOGIN", nil) forState:UIControlStateNormal];
        [login addTarget:self action:@selector(presentLoginController) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:login];
        
    }
    
    {
        signup = [UIButton new];
        
        signup.backgroundColor = [UIColor customBlue];
        signup.titleLabel.font = login.titleLabel.font;
        signup.layer.opacity = login.layer.opacity;
        signup.layer.cornerRadius = login.layer.cornerRadius;
        [signup setTitle:NSLocalizedString(@"HOME_SIGNUP", nil) forState:UIControlStateNormal];
        [signup addTarget:self action:@selector(presentSignupController) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:signup];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    login.frame = CGRectMake(23, CGRectGetHeight(self.view.frame) - 30 - 35, 134, 45);
    signup.frame = CGRectMake(CGRectGetMaxX(login.frame) + 6, login.frame.origin.y, login.frame.size.width, login.frame.size.height);
    
    pageControl.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 120, SCREEN_WIDTH, 45);
    
    scrollView.frame = self.view.frame;
    scrollView.contentSize = CGSizeMake(CGRectGetWidth(scrollView.frame) * pageControl.numberOfPages, CGRectGetHeight(scrollView.frame));
    
    player.view.frame = self.view.frame;
    
    [player play];
}

- (void)presentLoginController
{
    [self.navigationController pushViewController:[LoginViewController new] animated:YES];
}

- (void)presentSignupController
{
    [self.navigationController pushViewController:[SignupViewController new] animated:YES];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [player play];
}

#pragma mark - UIScrollView Delegate

- (void)prepapreTextForScrollView:(NSInteger)index
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(index * SCREEN_WIDTH, SCREEN_HEIGHT - 250, SCREEN_WIDTH, 0)];
    
    CGFloat MARGE = 15;
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake((index * SCREEN_WIDTH) + MARGE, 0, SCREEN_WIDTH - MARGE - MARGE, 0)];
    
    {
        title.font = [UIFont customTitleBook:28];
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        
        title.text = NSLocalizedString(([NSString stringWithFormat:@"HOME_SLIDE_%ld_TITLE", index + 1]), nil);
        
        [title setHeightToFit];
    }
    
    {
        content.font = [UIFont customContentRegular:17];
        content.textColor = [UIColor whiteColor];
        content.numberOfLines = 0;
        content.textAlignment = NSTextAlignmentCenter;
        
        content.text = NSLocalizedString(([NSString stringWithFormat:@"HOME_SLIDE_%ld_CONTENT", index + 1]), nil);
        
        [content setHeightToFit];
        CGRectSetY(content.frame, CGRectGetMaxY(title.frame) + 10);
    }
    
    [scrollView addSubview:title];
    [scrollView addSubview:content];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
}

@end
