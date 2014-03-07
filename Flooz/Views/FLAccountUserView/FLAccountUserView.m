//
//  FLAccountUserView.m
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLAccountUserView.h"

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
        userView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 97.) / 2., 6, 97, 96.5)];
        [userView setAlternativeStyle];
        [self addSubview:userView];
    }
    
    {
        fullname = [[UILabel alloc] initWithFrame:CGRectMake(0, 103, CGRectGetWidth(self.frame), 17)];
        
        fullname.font = [UIFont customTitleExtraLight:21];
        fullname.textAlignment = NSTextAlignmentCenter;
        fullname.textColor = [UIColor whiteColor];
        
        [self addSubview:fullname];
    }
    
    {
        username = [[UILabel alloc] initWithFrame:CGRectMake(0, 118, CGRectGetWidth(self.frame), 30)];
        
        username.font = [UIFont customContentRegular:10];
        username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor customBlueLight];
        
        [self addSubview:username];
    }
    
    {
        CGFloat WIDTH = 90.;
        CGFloat HEIGHT = 17.;
        CGFloat MARGE = (CGRectGetWidth(self.frame) - (3 * WIDTH)) / 2.;
        CGFloat Y = 150.;
        
        friends = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, Y, WIDTH, HEIGHT)];
        flooz = [[UILabel alloc] initWithFrame:CGRectMake(MARGE + WIDTH, Y, WIDTH, HEIGHT)];
        profilCompletion = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - MARGE - WIDTH, Y, WIDTH + MARGE, HEIGHT)];
                
        UIView *separator_1 = [[UIView alloc] initWithFrame:CGRectMake(MARGE + WIDTH, Y, 1, HEIGHT)];
        UIView *separator_2 = [[UIView alloc] initWithFrame:CGRectMake(MARGE + WIDTH + WIDTH, Y, 1, HEIGHT)];
        
        friends.textAlignment = flooz.textAlignment = profilCompletion.textAlignment = NSTextAlignmentCenter;
        
        separator_1.backgroundColor = separator_2.backgroundColor = [UIColor customSeparator];
        
        [self addSubview:friends];
        [self addSubview:flooz];
        [self addSubview:profilCompletion];
        
        [self addSubview:separator_1];
        [self addSubview:separator_2];
        
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
                                     initWithString:NSLocalizedString(@"ACCOUNT_PROFIL_COMPLETION", nil)
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
                                           initWithString:[user profileCompletion]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont customTitleExtraLight:14]
                                                        }];
        
        [text appendAttributedString:profilCompletionTextStatic];
        profilCompletion.attributedText = text;
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    gesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gesture];
}

@end
