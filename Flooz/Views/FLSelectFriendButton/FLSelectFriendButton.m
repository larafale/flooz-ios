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
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 36, 36)];
    //view.center = CGPointMake(30, CGRectGetHeight(self.frame) / 2);
    [self addSubview:view];
}

- (void)createButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    [button addTarget:self action:@selector(didButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    
    {
        fullnameView = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, CGRectGetWidth(button.frame) - 60, 11)];
        fullnameView.font = [UIFont customContentLight:14];
        fullnameView.textColor = [UIColor customPlaceholder];
        fullnameView.lineBreakMode = NSLineBreakByTruncatingTail;
        [fullnameView setText:NSLocalizedString(@"FIELD_TRANSACTION_SELECT_FRIEND", nil)];
        [button addSubview:fullnameView];
        
        usernameView = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(fullnameView.frame), 29, CGRectGetWidth(button.frame) - CGRectGetMinX(fullnameView.frame), 9)];
        usernameView.font = [UIFont customContentBold:11];
        usernameView.textColor = [UIColor customBlue];
        [button addSubview:usernameView];
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
        fullnameView.text = [[_dictionary objectForKey:@"toTitle"] uppercaseString];
        fullnameView.font = [UIFont customContentBold:13];
        fullnameView.textColor = [UIColor whiteColor];
        
        CGRectSetY(fullnameView.frame, 15.0);
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
    
    //usernameView.hidden = YES;
    if(_dictionary[@"toUsername"] && ![_dictionary[@"toUsername"] isBlank]){
        usernameView.hidden = NO;
        usernameView.text = [NSString stringWithFormat:@"@%@", _dictionary[@"toUsername"]];
    }
    else {
        if (_dictionary[@"to"]) {
            usernameView.hidden = NO;
            usernameView.text = _dictionary[@"to"];
        }
    }
}

- (void)didButtonTouch
{
    FriendPickerViewController *controller = [FriendPickerViewController new];
    [controller setDictionary:_dictionary];
    [_delegate presentViewController:controller animated:YES completion:NULL];
}

@end
