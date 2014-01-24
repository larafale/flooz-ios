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
    self = [super initWithFrame:CGRectMakeSize(SCREEN_WIDTH, 170)];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor customBackgroundHeader];
    
    {
        userView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - 97.) / 2., 13, 97, 96.5)];
        [self addSubview:userView];
    }
    
    {
        username = [[UILabel alloc] initWithFrame:CGRectMake(0, 116, CGRectGetWidth(self.frame), 17)];
        
        username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor whiteColor];
        
        [self addSubview:username];
    }
    
    {
        CGFloat WIDTH = 90.;
        CGFloat HEIGHT = 17.;
        CGFloat MARGE = (CGRectGetWidth(self.frame) - (3 * WIDTH)) / 2.;
        CGFloat Y = 140.;
        
        friends = [[UILabel alloc] initWithFrame:CGRectMake(MARGE, Y, WIDTH, HEIGHT)];
        flooz = [[UILabel alloc] initWithFrame:CGRectMake(MARGE + WIDTH, Y, WIDTH, HEIGHT)];
        profilCompletion = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - MARGE - WIDTH, Y, WIDTH, HEIGHT)];
        
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
                                                  NSForegroundColorAttributeName: [UIColor customBlueLight]
                                                  }];
        
        floozTextStatic = [[NSAttributedString alloc]
                                     initWithString:NSLocalizedString(@"ACCOUNT_TRANSACTIONS", nil)
                                     attributes:@{
                                                  NSForegroundColorAttributeName: [UIColor customBlueLight]
                                                  }];
        
        profilCompletionTextStatic = [[NSAttributedString alloc]
                                     initWithString:NSLocalizedString(@"ACCOUNT_PROFIL_COMPLETION", nil)
                                     attributes:@{
                                                  NSForegroundColorAttributeName: [UIColor customBlueLight]
                                                  }];
    }
}

- (void)reloadData
{
    user = [[Flooz sharedInstance] currentUser];
    
    username.text = user.username;
    [userView setImageFromURL:user.avatarURL];
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[[user friendsCount] stringValue]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]
                                                        }];
        
        [text appendAttributedString:friendsTextStatic];
        friends.attributedText = text;
    }
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[[user transactionsCount] stringValue]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]
                                                        }];
        
        [text appendAttributedString:floozTextStatic];
        flooz.attributedText = text;
    }
    
    {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc]
                                           initWithString:[user profileCompletion]
                                           attributes:@{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor]
                                                        }];
        
        [text appendAttributedString:profilCompletionTextStatic];
        profilCompletion.attributedText = text;
    }
}

@end
