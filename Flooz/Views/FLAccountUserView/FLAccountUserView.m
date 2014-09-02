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
        CGFloat size = 90;
        
        userView = [[FLUserView alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - size) / 2., 15, size, size)];
        [self addSubview:userView];
    }
    
    {
        fullname = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userView.frame) + 16, CGRectGetWidth(self.frame), 17)];
        
        fullname.font = [UIFont customTitleExtraLight:21];
        fullname.textAlignment = NSTextAlignmentCenter;
        fullname.textColor = [UIColor whiteColor];
        
        [self addSubview:fullname];
    }
    
    {
        username = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(fullname.frame) + 2, CGRectGetWidth(self.frame), 30)];
        
        username.font = [UIFont customContentBold:14];
        username.textAlignment = NSTextAlignmentCenter;
        username.textColor = [UIColor customBlue];
        
        [self addSubview:username];
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
    if (user.username) {
        username.text = [@"@" stringByAppendingString:user.username];
    }
    [userView setImageFromUser:user];
}

- (void)addEditTarget:(id)target action:(SEL)action
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    gesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:gesture];
}

@end
