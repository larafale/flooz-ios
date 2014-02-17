//
//  FriendPickerSelectionCell.m
//  Flooz
//
//  Created by jonathan on 2/13/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerSelectionCell.h"

#define MARGE_LEFT 26

@implementation FriendPickerSelectionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
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

- (void)setSelectionText:(NSString *)selectionText
{
    self->_selectionText = selectionText;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews
{
    self.backgroundColor = [UIColor customBackgroundHeader];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self createTextView];
    [self createSelectionView];
}

- (void)createTextView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 12, CGRectGetWidth(self.frame) - MARGE_LEFT, 16)];
    
    view.font = [UIFont customContentLight:12];
    view.textColor = [UIColor customPlaceholder];
    
    view.text = NSLocalizedString(@"FRIEND_PCIKER_SELECTION_CELL", nil);
    
    [self.contentView addSubview:view];
}

- (void)createSelectionView
{
    UILabel *view = [[UILabel alloc] initWithFrame:CGRectMake(MARGE_LEFT, 28, CGRectGetWidth(self.frame) - MARGE_LEFT, 16)];
    
    view.font = [UIFont customContentLight:12];
    view.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:view];
}

#pragma mark - Prepare Views

- (void)prepareViews
{
    [self prepareSelectionView];
}

- (void)prepareSelectionView
{
    UILabel *view = [[self.contentView subviews] objectAtIndex:1];
    view.text =_selectionText;
}

@end
