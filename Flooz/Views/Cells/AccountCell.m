//
//  AccountCell.m
//  Flooz
//
//  Created by Flooz on 7/21/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createIndicator];
        [self createBadge];
        [self createTitle];
        [self createIndicator];
    }
    return self;
}

+ (CGFloat)getHeight {
    return 40.0f;
}

- (void)createTitle {
    self.textLabel.textColor = [UIColor customPlaceholder];
    self.textLabel.font = [UIFont customTitleLight:16];
    [self.textLabel setBackgroundColor:[UIColor clearColor]];
}

- (void)createIndicator {
    self.indicator = [UIImageView imageNamed:@"arrow-right-accessory"];
    self.indicator.image = [self.indicator.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.indicator.tintColor = [UIColor customPlaceholder];
    CGRectSetWidthHeight(self.indicator.frame, 20, 20);
    self.accessoryView = self.indicator;
}

- (void)createBadge {
    self.badgeIcon = [[UILabel alloc] initWithText:@"" textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:15]];
    self.badgeIcon.layer.masksToBounds = YES;
    self.badgeIcon.layer.cornerRadius = 10.0f;
    self.badgeIcon.textAlignment = NSTextAlignmentCenter;
    self.badgeIcon.backgroundColor = [UIColor customBlue];
    self.badgeIcon.textColor = [UIColor whiteColor];
    self.badgeIcon.font = [UIFont customContentRegular:12];
    
    CGRectSetHeight(self.badgeIcon.frame, 20);

    [self.contentView addSubview:self.badgeIcon];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        [self setBackgroundColor:[UIColor customBackground]];
        self.indicator.tintColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.badgeIcon.textColor = [UIColor whiteColor];
        self.badgeIcon.backgroundColor = [UIColor customBlue];
    }
    else {
        [self setBackgroundColor:[UIColor customBackgroundHeader]];
        self.indicator.tintColor = [UIColor customPlaceholder];
        self.textLabel.textColor = [UIColor customPlaceholder];
        self.badgeIcon.textColor = [UIColor whiteColor];
        self.badgeIcon.backgroundColor = [UIColor customBlue];
    }
}

#pragma mark - Set

- (void)setMenu:(NSDictionary *)menuDic {
    _menuDico = menuDic;
    [self prepareViews];
}

#pragma mark - Prepare Views

- (void)prepareViews {
    [self setBackgroundColor:[UIColor customBackground]];
    
    [self prepareTitleView];
    [self prepareBadge];
}

- (void)prepareTitleView {
    NSString *title = _menuDico[@"title"];
    [self.textLabel setText:title];
}

- (void)prepareBadge {
    NSNumber *notif = _menuDico[@"notif"];
    
    if (notif && [notif intValue] > 0) {
        [self.badgeIcon setText:[notif stringValue]];
        [self.badgeIcon setHidden:NO];
        float width = [self.badgeIcon.text widthOfString:self.badgeIcon.font];
        width += 10;
        CGRectSetHeight(self.badgeIcon.frame, 20);
        CGRectSetWidth(self.badgeIcon.frame, MAX(width, 20));
        CGRectSetXY(self.badgeIcon.frame, PPScreenWidth() - width - 50, [AccountCell getHeight] / 2 - CGRectGetHeight(self.badgeIcon.frame) / 2);
    } else {
        [self.badgeIcon setHidden:YES];
    }
}

@end
