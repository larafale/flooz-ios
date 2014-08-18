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
        _avatarContact = [[FLUserView alloc] initWithFrame:CGRectMake(10, 5, 40, 40)];
        [self.contentView addSubview:_avatarContact];
        
        _firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarContact.frame) + 10, 0, 100, 50)];
        [self.contentView addSubview:_firstNameLabel];
        _firstNameLabel.textColor = [UIColor whiteColor];
        _firstNameLabel.font = [UIFont customContentRegular:14];
        
        _lastNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_firstNameLabel.frame), 0, 100, 50)];
        [self.contentView addSubview:_lastNameLabel];
        _lastNameLabel.textColor = [UIColor whiteColor];
        _lastNameLabel.font = [UIFont customContentRegular:14];
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

- (void) setCellWithFirstName :(NSString *)firstName lastName:(NSString *)lastName andDataImage:(NSData *)dataImage {
    if (!firstName) {
        firstName = @"";
    }
    
    [_firstNameLabel setText:firstName];
    
    CGSize expectedLabelSize = [firstName sizeWithAttributes:
                                @{NSFontAttributeName: _firstNameLabel.font}];
    CGRectSetWidth(_firstNameLabel.frame, expectedLabelSize.width);
    CGRectSetX(_lastNameLabel.frame, CGRectGetMaxX(_firstNameLabel.frame));
    
    if (!lastName) {
        lastName = @"";
    }
    
    NSString *last = [NSString stringWithFormat:@" %@", lastName];
    [_lastNameLabel setText:last];
    CGSize expectedLabelS = [last sizeWithAttributes:
                             @{NSFontAttributeName: _lastNameLabel.font}];
    CGRectSetWidth(_lastNameLabel.frame, expectedLabelS.width);
    
    [_avatarContact setImageFromData:dataImage];
}



@end
