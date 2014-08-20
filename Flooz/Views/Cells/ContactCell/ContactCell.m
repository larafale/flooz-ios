//
//  ContactCell.m
//  Flooz
//
//  Created by Arnaud on 2014-08-18.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "ContactCell.h"

@implementation ContactCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _avatarContact = [[FLUserView alloc] initWithFrame:CGRectMake(15, 5, 40, 40)];
        [self.contentView addSubview:_avatarContact];
        
        _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarContact.frame) + 20, 5, 100, 30)];
        [self.contentView addSubview:_firstNameLabel];
        _firstNameLabel.textColor = [UIColor whiteColor];
        _firstNameLabel.font = [UIFont customContentRegular:14];
        
        _lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_firstNameLabel.frame), 5, 100, 30)];
        [self.contentView addSubview:_lastNameLabel];
        _lastNameLabel.textColor = [UIColor whiteColor];
        _lastNameLabel.font = [UIFont customContentRegular:14];
        
        _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_firstNameLabel.frame), 25.0f, 200, 20)];
        [self.contentView addSubview:_subLabel];
        _subLabel.textColor = [UIColor lightGrayColor];
        _subLabel.font = [UIFont customContentRegular:12];
        
        UIImage *imageB = [UIImage imageNamed:@"Signup_Box_Plus"];
        _addFriendButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-52, 0, 50, 50)];
        [_addFriendButton setImage:imageB forState:UIControlStateNormal];
        [_addFriendButton setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [_addFriendButton setHidden:YES];
        [self.contentView addSubview:_addFriendButton];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - Set

- (void) setCellWithFirstName :(NSString *)firstName lastName:(NSString *)lastName subText:(NSString *)subText andDataImage:(NSData *)dataImage {
    if (!firstName) {
        firstName = @"";
    }
    
    [_firstNameLabel setText:[firstName uppercaseString]];
    
    CGSize expectedLabelSize = [[firstName uppercaseString] sizeWithAttributes:
                                @{NSFontAttributeName: _firstNameLabel.font}];
    CGRectSetWidth(_firstNameLabel.frame, expectedLabelSize.width);
    CGRectSetX(_lastNameLabel.frame, CGRectGetMaxX(_firstNameLabel.frame));
    
    if (!lastName) {
        lastName = @"";
    }
    
    NSString *last = [NSString stringWithFormat:@" %@", [lastName uppercaseString]];
    [_lastNameLabel setText:last];
    CGSize expectedLabelS = [last sizeWithAttributes:
                             @{NSFontAttributeName: _lastNameLabel.font}];
    CGRectSetWidth(_lastNameLabel.frame, expectedLabelS.width);
    
    [_avatarContact setImageFromData:dataImage];
    
    if (subText.length) {
        [_subLabel setText:subText];
        
        CGSize expectedLabelS = [subText sizeWithAttributes:
                                 @{NSFontAttributeName: _subLabel.font}];
        CGRectSetWidth(_subLabel.frame, expectedLabelS.width);
    }
}

- (void) setCellWithCompleteName:(NSString *)complete subText:(NSString *)subText andImageUrl:(NSString *)imageUrl {
    if (!complete) {
        complete = @"";
    }
    
    [_firstNameLabel setText:[complete uppercaseString]];
    CGSize expectedLabelSize = [[complete uppercaseString] sizeWithAttributes:
                                @{NSFontAttributeName: _firstNameLabel.font}];
    CGRectSetWidth(_firstNameLabel.frame, expectedLabelSize.width);
    CGRectSetX(_lastNameLabel.frame, CGRectGetMaxX(_firstNameLabel.frame));
    
    [_lastNameLabel setText:@""];
    
    [_avatarContact setImageFromURL:imageUrl];
    
    if (subText.length) {
        NSString *sub = [@"@" stringByAppendingString:subText];
        [_subLabel setText:sub];
        CGSize expectedLabelS = [sub sizeWithAttributes:
                                 @{NSFontAttributeName: _subLabel.font}];
        CGRectSetWidth(_subLabel.frame, expectedLabelS.width);
    }
    
    [_addFriendButton setHidden:NO];
}



@end
