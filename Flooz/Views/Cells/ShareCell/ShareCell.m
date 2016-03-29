//
//  ShareCell.m
//  Flooz
//
//  Created by Epitech on 10/8/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "ShareCell.h"

@interface ShareCell () {
    UIImageView *checkBox;
    UIActivityIndicatorView *loadingIndicator;
    UILabel *floozerLabel;
    UILabel *nameLabel;
    UILabel *usernameLabel;
}

@end

@implementation ShareCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
        
    }
    return self;
}

+ (CGFloat)getHeight {
    return 45;
}

- (void)createViews {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGFloat checkSize = 25;
    
    checkBox = [[UIImageView alloc] initWithFrame:CGRectMake(10, [self.class getHeight] / 2 - checkSize / 2, checkSize, checkSize)];
    [checkBox setContentMode:UIViewContentModeScaleAspectFit];
    [checkBox setHidden:YES];
    [checkBox setImage:[UIImage imageNamed:@"checkmark-off"]];

    loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingIndicator.center = checkBox.center;
    [loadingIndicator setHidden:YES];
    
    floozerLabel = [[UILabel alloc] initWithText:NSLocalizedString(@"USER_ALREADY_FLOOZER", nil) textColor:[UIColor customBlue] font:[UIFont customTitleExtraLight:13] textAlignment:NSTextAlignmentRight numberOfLines:1];
    [floozerLabel sizeToFit];
    CGRectSetX(floozerLabel.frame, PPScreenWidth() - CGRectGetWidth(floozerLabel.frame) - 20);
    CGRectSetY(floozerLabel.frame, [self.class getHeight] / 2 - CGRectGetHeight(floozerLabel.frame) / 2);
    [floozerLabel setHidden:YES];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkBox.frame) + 10, 10, PPScreenWidth() - CGRectGetWidth(checkBox.frame) - 45 - CGRectGetWidth(floozerLabel.frame), 15)];
    [nameLabel setTextColor:[UIColor whiteColor]];
    [nameLabel setNumberOfLines:1];
    [nameLabel setFont:[UIFont customContentRegular:14]];

    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkBox.frame) + 10, CGRectGetMaxY(nameLabel.frame), PPScreenWidth() - CGRectGetWidth(checkBox.frame) - 45 - CGRectGetWidth(floozerLabel.frame), 15)];
    [usernameLabel setTextColor:[UIColor customGreyPseudo]];
    [usernameLabel setNumberOfLines:1];
    [usernameLabel setFont:[UIFont customContentRegular:12]];

    [self.contentView addSubview:checkBox];
    [self.contentView addSubview:loadingIndicator];
    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:usernameLabel];
    [self.contentView addSubview:floozerLabel];
}

- (void)setUser:(FLUser *)user {
    self->_user = user;
    
    [nameLabel setText:self.user.fullname];
    
    if (user.userKind == FloozUser) {
        [usernameLabel setText:[NSString stringWithFormat:@"@%@", self.user.username]];
    } else {
        [usernameLabel setText:self.user.phone];
    }
    
    [checkBox setHidden:YES];
    [loadingIndicator setHidden:YES];
    [floozerLabel setHidden:YES];
    
    if (self.user.isIdentified) {
        [checkBox setHidden:NO];
        if (self.user.isFloozer) {
            [checkBox setImage:[[UIImage imageNamed:@"checkmark-off"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [checkBox setTintColor:[UIColor customBackground]];
            [floozerLabel setHidden:NO];
            [self setUserInteractionEnabled:NO];
        } else {
            [self setUserInteractionEnabled:YES];
        }
    } else {
        [loadingIndicator setHidden:NO];
        [loadingIndicator startAnimating];
        [self setUserInteractionEnabled:NO];
    }
}

- (void)setOn {
    if (self.user.isIdentified && !self.user.isFloozer)
        [checkBox setImage:[UIImage imageNamed:@"checkmark-on"]];
}

- (void)setOff {
    if (self.user.isIdentified && !self.user.isFloozer)
        [checkBox setImage:[UIImage imageNamed:@"checkmark-off"]];
}

@end
