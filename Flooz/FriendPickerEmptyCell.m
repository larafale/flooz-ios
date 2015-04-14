//
//  UFriendPickerEmptyCell.m
//  Flooz
//
//  Created by Epitech on 2/24/15.
//  Copyright (c) 2015 Jonathan Tribouharet. All rights reserved.
//

#import "FriendPickerEmptyCell.h"

#define PADDING_SIDE 10.0f

@implementation FriendPickerEmptyCell {
    UILabel *_textLabel1;
    UILabel *_textLabel2;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight {
    return 54;
}

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self createTextView1];
    [self createTextView2];
}

- (void)createTextView1 {
    _textLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(0, [FriendPickerEmptyCell getHeight] / 2 - 20.0f , CGRectGetWidth(self.contentView.frame), 20.0f)];
    
    _textLabel1.font = [UIFont customContentBold:15];
    _textLabel1.textColor = [UIColor customPlaceholder];
    _textLabel1.text = NSLocalizedString(@"FRIEND_PICKER_EMPTY_CELL_1", nil);
    _textLabel1.textAlignment = NSTextAlignmentCenter;
    
    [self.contentView addSubview:_textLabel1];
}

- (void)createTextView2 {
    _textLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0, [FriendPickerEmptyCell getHeight] / 2 , CGRectGetWidth(self.contentView.frame), 20.0f)];
    
    _textLabel2.font = [UIFont customContentBold:15];
    _textLabel2.textColor = [UIColor customPlaceholder];
    _textLabel2.text = NSLocalizedString(@"FRIEND_PICKER_EMPTY_CELL_2", nil);
    _textLabel2.textAlignment = NSTextAlignmentCenter;

    [self.contentView addSubview:_textLabel2];
}

@end
