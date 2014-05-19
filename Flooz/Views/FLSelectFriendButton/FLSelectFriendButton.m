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
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.titleLabel.font = [UIFont customContentLight:14];

    [button setTitle:NSLocalizedString(@"FIELD_TRANSACTION_SELECT_FRIEND", nil) forState:UIControlStateNormal];
    
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [button addTarget:self action:@selector(didButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    {
        usernameView = [[UILabel alloc] initWithFrame:CGRectMakeWithSize(button.frame.size)];
        [button addSubview:usernameView];
        
        usernameView.font = [UIFont customContentRegular:10];
        usernameView.textColor = [UIColor customBlue];
    }
    
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
        [button setTitle:[[_dictionary objectForKey:@"toTitle"] uppercaseString] forState:UIControlStateSelected];
        button.selected = YES;
    }
    else{
        button.selected = NO;
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
    
    if(_dictionary[@"toUsername"] && ![_dictionary[@"toUsername"] isBlank]){
        usernameView.hidden = NO;
        usernameView.text = [NSString stringWithFormat:@"@%@", _dictionary[@"toUsername"]];
        
        CGFloat width = CGRectGetWidth(button.titleLabel.frame);
        [button.titleLabel setWidthToFit];
        CGRectSetX(usernameView.frame, CGRectGetWidth(button.titleLabel.frame) + 5);
        CGRectSetWidth(button.titleLabel.frame, width);
    }
    else{
        usernameView.hidden = YES;
    }
}

- (void)didButtonTouch
{
    FriendPickerViewController *controller = [FriendPickerViewController new];
    [controller setDictionary:_dictionary];
    [_delegate presentViewController:controller animated:YES completion:NULL];
}

@end
