//
//  FriendPickerContactCell.m
//  Flooz
//
//  Created by jonathan on 2/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerContactCell.h"

@implementation FriendPickerContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight
{
    return 54;
}

- (void)setContact:(NSDictionary *)contact
{
    self->_contact = contact;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews
{
    self.backgroundColor = [UIColor customBackground];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self createAvatarView];
    [self createNameView];
    [self createPhoneView];
    [self createCheckView];
}

- (void)createAvatarView
{
    FLUserView *view = [[FLUserView alloc] initWithFrame:CGRectMake(15, 8, 38, 38)];
    [self.contentView addSubview:view];
}

- (void)createNameView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 17, CGRectGetWidth(self.frame) - 75, 11)];
    
    view.font = [UIFont customContentBold:13];
    view.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:view];
}

- (void)createPhoneView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(75, 31, CGRectGetWidth(self.frame) - 75, 9)];
    
    view.font = [UIFont customContentBold:11];
    view.textColor = [UIColor customPlaceholder];
    
    [self.contentView addSubview:view];
}

- (void)createCheckView
{
    UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.frame) - 30, CGRectGetHeight(self.contentView.frame) / 2., 15, 10)];
    [self.contentView addSubview:view];
    
    view.image = [UIImage imageNamed:@"navbar-check"];
}

#pragma mark - Prepare Views

- (void)prepareViews
{
    [self prepareAvatarView];
    [self prepareNameView];
    [self preparePhoneView];
}

- (void)prepareAvatarView
{
    FLUserView *view = [[self.contentView subviews] objectAtIndex:0];
    
    if([_contact objectForKey:@"image"]){
        [view setImageFromData:[_contact objectForKey:@"image"]];
    }
    else if([_contact objectForKey:@"image_url"]){
        [view setImageFromURL:[_contact objectForKey:@"image_url"]];
    }
    else{
        [view setImageFromData:nil];
    }
}

- (void)prepareNameView
{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    
    view.text = [[_contact objectForKey:@"name"] uppercaseString];
}

- (void)preparePhoneView
{
    UILabel *view = [[self.contentView subviews] objectAtIndex:2];
    
    if([_contact objectForKey:@"phone"]){
        view.text = [_contact objectForKey:@"phone"];
    }
    else if([_contact objectForKey:@"email"]){
        view.text = [_contact objectForKey:@"email"];
    }
    else{
        view.text = @"";
    }
    CGSize expectedLabelS = [view.text sizeWithAttributes:
                             @{NSFontAttributeName: view.font}];
    CGRectSetHeight(view.frame, expectedLabelS.height);
}

- (void)setSelectedCheckView:(BOOL)selected
{
    [super setSelected:selected];
    
    UIImageView *checkView = [[self.contentView subviews] objectAtIndex:3];
    checkView.hidden = !selected;
}

@end
