//
//  FLValidNavBar.m
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLValidNavBar.h"

#define HEIGHT (STATUSBAR_HEIGHT + NAVBAR_HEIGHT)

@implementation FLValidNavBar

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(!self){
        return nil;
    }
    
    [self commonInit];
    
    return self;
}

- (void)commonInit
{
    self.frame = CGRectMakeSize(SCREEN_WIDTH, HEIGHT);
    self.backgroundColor = [UIColor customBackgroundHeader];
    [self createViews];
}

- (void)createViews
{
    cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, STATUSBAR_HEIGHT, SCREEN_WIDTH / 2., NAVBAR_HEIGHT)];
    valid = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2., STATUSBAR_HEIGHT, SCREEN_WIDTH / 2., NAVBAR_HEIGHT)];
    
    [cancel setImage:[UIImage imageNamed:@"navbar-cross"] forState:UIControlStateNormal];
    [valid setImage:[UIImage imageNamed:@"navbar-check"] forState:UIControlStateNormal];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2., STATUSBAR_HEIGHT + ((NAVBAR_HEIGHT - 15) / 2.), 1, 15)];
    separator.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:cancel];
    [self addSubview:valid];
    [self addSubview:separator];
    
    
    {
        UIView *borderView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), 1)];
        borderView.backgroundColor = [UIColor colorWithRed:0. green:0. blue:0. alpha:.2];
        [self addSubview:borderView];
        
        self.layer.shadowOffset = CGSizeMake(0, 3.5);
        self.layer.shadowOpacity = .2;
        self.layer.shadowRadius = 1;
    }
}

- (void)cancelAddTarget:(id)target action:(SEL)action
{
    [cancel addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)validAddTarget:(id)target action:(SEL)action
{
    [valid addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

@end
