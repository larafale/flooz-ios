//
//  FriendSearchButton.m
//  Flooz
//
//  Created by jonathan on 3/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendSearchButton.h"

@implementation FriendSearchButton

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createViews];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    CGRectSetHeight(frame, 45);
    self = [super initWithFrame:frame];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews{
    self.backgroundColor = [UIColor customBackground];
    
    [self createSearchBar];
    [self createSeparator];
    
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTouch)]];
}

- (void)createSearchBar{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(14, 8, CGRectGetWidth(self.frame) - 14 - 14, 30)];
    
    view.backgroundColor = [UIColor customBackgroundHeader];
    view.layer.cornerRadius = 15;
    
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, CGRectGetWidth(view.frame) - 30, CGRectGetHeight(view.frame))];
        
        label.font = [UIFont customContentLight:12];
        label.text = NSLocalizedString(@"FRIENDS_SEARCH_FRIENDS", nil);
        label.textColor = [UIColor customPlaceholder];
        
        [view addSubview:label];
    }
    
    [self addSubview:view];
}

- (void)createSeparator{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    
    view.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:view];
}

#pragma mark -

- (void)didTouch{
    [_delegate presentFriendAddController];
}

@end
