//
//  FLSelectFriendButton.m
//  Flooz
//
//  Created by jonathan on 2/6/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FLSelectFriendButton.h"
#import "FriendPickerViewController.h"

@implementation FLSelectFriendButton

- (id)initWithFrame:(CGRect)frame dictionary:(NSMutableDictionary *)dictionary
{
    CGRectSetWidthHeight(frame, SCREEN_WIDTH, 50);
    self = [super initWithFrame:frame];
    if (self) {
        _dictionary = dictionary;
        
        [self createImage];
        [self createButton];
        [self createBottomBar];
        
        [self reloadData];
    }
    return self;
}

- (void)createImage
{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMakeSize(30, 30)];
    view.center = CGPointMake(30, CGRectGetHeight(self.frame) / 2);
    [self addSubview:view];
}

- (void)createButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(65, 0, CGRectGetWidth(self.frame) - 65, CGRectGetHeight(self.frame))];
    
    [button setTitleColor:[UIColor customPlaceholder] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont customContentLight:14];

    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [button addTarget:self action:@selector(didButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:button];
}

- (void)createBottomBar
{
    UIView *bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 1, CGRectGetWidth(self.frame), 1)];
    bottomBar.backgroundColor = [UIColor customSeparator];
    
    [self addSubview:bottomBar];
}

#pragma mark -

- (void)reloadData
{
    FLUserView *userView = [[self subviews] objectAtIndex:0];
    UIButton *button = [[self subviews] objectAtIndex:1];
    
    if([_dictionary objectForKey:@"toTitle"] && ![[_dictionary objectForKey:@"toTitle"] isBlank]){
        [button setTitle:[_dictionary objectForKey:@"toTitle"] forState:UIControlStateNormal];
    }
    else{
        [button setTitle:NSLocalizedString(@"FIELD_TRANSACTION_SELECT_FRIEND", nil) forState:UIControlStateNormal];
    }
    
    if([_dictionary objectForKey:@"toImage"]){
        [userView setImageFromData:[_dictionary objectForKey:@"toImage"]];
    }
    else if([_dictionary objectForKey:@"toImageUrl"]){
         [userView setImageFromURL:[_dictionary objectForKey:@"toImageUrl"]];
    }
    else{
        [userView setImageFromData:nil];
    }
}

- (void)didButtonTouch
{
    FriendPickerViewController *controller = [FriendPickerViewController new];
    [controller setDictionary:_dictionary];
    [_delegate presentViewController:controller animated:YES completion:NULL];
}

@end
