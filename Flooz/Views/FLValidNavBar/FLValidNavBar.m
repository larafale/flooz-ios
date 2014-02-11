//
//  FLValidNavBar.m
//  Flooz
//
//  Created by jonathan on 1/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLValidNavBar.h"

#define STATUSBAR_HEIGHT 20.
#define NAVBAR_HEIGHT 44.
#define HEIGHT (STATUSBAR_HEIGHT + NAVBAR_HEIGHT)

@implementation FLValidNavBar

- (id)init
{
    self = [super initWithFrame:CGRectMakeSize(SCREEN_WIDTH, HEIGHT)];
    if (self){
        self.backgroundColor = [UIColor customBackgroundHeader];
        [self createViews];
    }
    return self;
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
