//
//  ParticipantCell.m
//  Flooz
//
//  Created by Olive on 3/23/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ParticipantCell.h"

#define PADDING_SIDE 10.0f

@implementation ParticipantCell {
    UILabel *_nameLabel;
    UILabel *_subLabel;
    UILabel *_amountLabel;
    
    UIImageView *_certifImageView;
    
    CGFloat widthLabel;
    CGFloat cellWidth;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellWidth = PPScreenWidth();
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeight {
    return 54;
}

- (void)setParticipant:(FLUser *)participant {
    self->_participant = participant;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    [self createAvatarView];
    [self createTextView];
    [self createSubTextView];
    [self createCertifView];
    [self createAmountView];
}

- (void)createAvatarView {
    _avatarView = [[FLUserView alloc] initWithFrame:CGRectMake(PADDING_SIDE, 8.0f, 38.0f, 38.0f)];
    [self.contentView addSubview:_avatarView];
}

- (void)createTextView {
    widthLabel = cellWidth - (CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE);
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarView.frame) + PADDING_SIDE, 17.0f, widthLabel, 15)];
    
    _nameLabel.font = [UIFont customContentBold:13];
    _nameLabel.textColor = [UIColor whiteColor];
    
    [self.contentView addSubview:_nameLabel];
}

- (void)createSubTextView {
    _subLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), 31, CGRectGetWidth(_nameLabel.frame), 15)];
    
    _subLabel.font = [UIFont customContentRegular:11];
    _subLabel.textColor = [UIColor customGreyPseudo];
    
    [self.contentView addSubview:_subLabel];
}

- (void)createCertifView {
    _certifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 16.5f, 15, 15)];
    [_certifImageView setImage:[UIImage imageNamed:@"certified"]];
    [_certifImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self.contentView addSubview:_certifImageView];
}

- (void)createAmountView {
    _amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(PPScreenWidth() - 100, [self.class getHeight] / 2 - 12.5, 60, 25)];
    _amountLabel.numberOfLines = 1;
    _amountLabel.font = [UIFont customContentBold:15];
    _amountLabel.textColor = [UIColor whiteColor];
    _amountLabel.adjustsFontSizeToFitWidth = YES;
    _amountLabel.minimumScaleFactor = 10. / _amountLabel.font.pointSize;
    _amountLabel.textAlignment = NSTextAlignmentRight;
    
    [self.contentView addSubview:_amountLabel];
}

#pragma mark - Prepare Views

- (void)prepareViews {
    
    if (_participant.isCactus) {
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [self prepareAvatarView];
    [self prepareNameView];
    [self preparePhoneView];
    [self prepareAmountView];
}

- (void)prepareAvatarView {
    [_avatarView setImageFromUser:_participant];
}

- (void)prepareNameView {
    _nameLabel.text = [[_participant fullname] uppercaseString];
    [_nameLabel setWidthToFit];
    
    if ([_participant isCertified]) {
        [_certifImageView setHidden:NO];
        CGRectSetX(_certifImageView.frame, CGRectGetMaxX(_nameLabel.frame) + 5);
    } else {
        [_certifImageView setHidden:YES];
    }
}

- (void)preparePhoneView {
    if (_participant.isCactus) {
        _subLabel.text = @"";
    } else {
        NSString *s = [@"@" stringByAppendingString : _participant.username];
        _subLabel.text = s;
    }
    
}

- (void)prepareAmountView {
    if (_participant.totalParticipation && ![_participant.totalParticipation isEqualToNumber:@0]) {
        _amountLabel.hidden = NO;
        _amountLabel.text = [FLHelper formatedAmount:_participant.totalParticipation withCurrency:YES withSymbol:NO];
    } else {
        _amountLabel.hidden = YES;
    }
}

@end
