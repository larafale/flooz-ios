//
//  FLAccountUserView.m
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAccountUserView.h"

#import "FLContainerViewController.h"
#import "AppDelegate.h"
#import "TimelineViewController.h"

@implementation FLAccountUserView

- (id)init
{
    self = [super initWithFrame:CGRectMakeSize(SCREEN_WIDTH, 180)];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor colorWithIntegerRed:30. green:41. blue:52.];
    
    {
        userView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 81.) / 2., 12, 81, 81)];
        [self addSubview:userView];
    }
    
    {
        fullname = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userView.frame) + 12, CGRectGetWidth(self.frame), 17)];
        
        fullname.font = [UIFont customTitleExtraLight:21];
        fullname.textAlignment = NSTextAlignmentCenter;
        fullname.textColor = [UIColor whiteColor];
        
        [self addSubview:fullname];
    }
    
    {
        username = [[UILabel alloc] initWithFrame:CGRectMake(0, 118, CGRectGetWidth(self.frame), 30)];
        
        username.font = [UIFont customContentBold:11];
        username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor customBlue];
        
        [self addSubview:username];
    }
    
    {
        CGFloat WIDTH = SCREEN_WIDTH / 3.;
        CGFloat HEIGHT = 27.;
        CGFloat MARGE = 0; // (CGRectGetWidth(self.frame) - (3 * WIDTH)) / 2.;
        CGFloat Y = 150.;
        
        friends = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, Y, WIDTH, HEIGHT)];
        flooz = [[UILabel alloc] initWithFrame:CGRectMake(MARGE + WIDTH, Y, WIDTH, HEIGHT)];
        profilCompletion = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - MARGE - WIDTH, Y, WIDTH + MARGE, HEIGHT)];
                
        
        friends.textAlignment = flooz.textAlignment = profilCompletion.textAlignment = NSTextAlignmentCenter;

        [self addSubview:friends];
        [self addSubview:flooz];
        [self addSubview:profilCompletion];
        
        friendsTextStatic = [[NSAttributedString alloc]
                                     initWithString:NSLocalizedString(@"ACCOUNT_FRIENDS", nil)
                                     attributes:@{
                                                  NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                  NSFontAttributeName: [UIFont customContentRegular:12]
                                                  }];
        
        floozTextStatic = [[NSAttributedString alloc]
                                     initWithString:NSLocalizedString(@"ACCOUNT_TRANSACTIONS", nil)
                                     attributes:@{
                                                  NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                  NSFontAttributeName: [UIFont customContentRegular:12]
                                                  }];
        
        profilCompletionTextStatic = [[NSAttributedString alloc]
                                     initWithString:NSLocalizedString(@"ACCOUNT_EVENTS", nil)
                                     attributes:@{
                                                  NSForegroundColorAttributeName: [UIColor customPlaceholder],
                                                  NSFontAttributeName: [UIFont customContentRegular:12]
                                                  }];
    }
    
    {
        UIImageView *arrow = [UIImageView imageNamed:@"arrow-right"];
        CGRectSetXY(arrow.frame, CGRectGetWidth(self.frame) - 10, (CGRectGetHeight(self.frame) - arrow.image.size.height) / 2.);
        [self addSubview:arrow];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadFloozController)];
        gesture.numberOfTapsRequired = 1;
        flooz.userInteractionEnabled = YES;
        [flooz addGestureRecognizer:gesture];
    }
    
    {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadEventsController)];
        gesture.numberOfTapsRequired = 1;
        profilCompletion.userInteractionEnabled = YES;
        [profilCompletion addGestureRecognizer:gesture];
    }
}

- (void)reloadData
{
    user = [[Flooz sharedInstance] currentUser];
    
    fullname.text = [user.fullname uppercaseString];
    username.text = [@"@" stringByAppendingString:user.username];
    
    [userView setImageFromUser:user];
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[[user friendsCount] stringValue]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont customTitleExtraLight:14]
                                                        }];
        
        [text appendAttributedString:friendsTextStatic];
        friends.attributedText = text;
    }
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[[user transactionsCount] stringValue]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont customTitleExtraLight:14]
                                                        }];
        
        [text appendAttributedString:floozTextStatic];
        flooz.attributedText = text;
    }
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[[user eventsCount] stringValue]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont customTitleExtraLight:14]
                                                        }];
        
        [text appendAttributedString:profilCompletionTextStatic];
        profilCompletion.attributedText = text;
    }
}

- (void)addEditTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    gesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gesture];
}

- (void)addFriendsTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    gesture.numberOfTapsRequired = 1;
    friends.userInteractionEnabled = YES;
    [friends addGestureRecognizer:gesture];
}

- (void)loadFloozController
{
    FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
    TimelineViewController *timelineController = [[rootController viewControllers] objectAtIndex:1];
    [[timelineController filterView] selectFilter:2];
    
    [rootController.navbarView loadControllerWithIndex:1];
}

- (void)loadEventsController
{
    FLContainerViewController *rootController = (FLContainerViewController *)appDelegate.window.rootViewController;
    [rootController.navbarView loadControllerWithIndex:2];
}

@end
