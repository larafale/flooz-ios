//
//  PlaceCell.m
//  Flooz
//
//  Created by Epitech on 11/2/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import "PlaceCell.h"

@interface PlaceCell () {
    UIImageView *icon;
    UILabel *title;
    UILabel *subtitle;
    
    UIButton *removeButton;
}

@end

@implementation PlaceCell

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
    
    CGFloat checkSize = 30;
    
    icon = [[UIImageView alloc] initWithFrame:CGRectMake(10, [self.class getHeight] / 2 - checkSize / 2, checkSize, checkSize)];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10, 5, PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 20), 20)];
    [title setNumberOfLines: 1];
    [title setTextColor:[UIColor whiteColor]];
    [title setFont:[UIFont customContentRegular:15]];
    
    subtitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(icon.frame) + 10, CGRectGetMaxY(title.frame), PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 20), 15)];
    [subtitle setNumberOfLines: 1];
    [subtitle setTextColor:[UIColor customPlaceholder]];
    [subtitle setFont:[UIFont customContentRegular:12]];
    
    CGFloat removeSize = 20;
    
    removeButton = [[UIButton alloc] initWithFrame:CGRectMake(PPScreenWidth() - removeSize - 10, [self.class getHeight] / 2 - removeSize / 2, removeSize, removeSize)];
    [removeButton setImage:[UIImage imageNamed:@"close-activities"] forState:UIControlStateNormal];
    [removeButton addTarget:self action:@selector(removeClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.contentView addSubview:icon];
    [self.contentView addSubview:title];
    [self.contentView addSubview:subtitle];
    [self.contentView addSubview:removeButton];
}

- (void)removeClicked {
    if (self.delegate)
        [self.delegate removeButtonClicked];
}

- (void)showRemoveButton {
    [removeButton setHidden:NO];
    
    CGRectSetWidth(title.frame, PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 30 + CGRectGetWidth(removeButton.frame)));
    CGRectSetWidth(subtitle.frame, PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 30 + CGRectGetWidth(removeButton.frame)));
}

- (void)hideRemoveButton {
    [removeButton setHidden:YES];
    
    CGRectSetWidth(title.frame, PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 20));
    CGRectSetWidth(subtitle.frame, PPScreenWidth() - (CGRectGetMaxX(icon.frame) + 20));
}

- (void)setPlace:(NSDictionary *)place {
    self->_place = place;
    
    if (place) {
        [self hideRemoveButton];
        [title setText:place[@"name"]];
        
        if (place[@"location"] && place[@"location"][@"distance"]) {
            float distance = [place[@"location"][@"distance"] floatValue];
            
            if (distance >= 1000) {
                [subtitle setText:[NSString stringWithFormat:@"%.1f km", distance/1000]];
            } else {
                [subtitle setText:[NSString stringWithFormat:@"%.0f m", distance]];
            }
            
            if (place[@"location"][@"city"]) {
                [subtitle setText:[NSString stringWithFormat:@"%@ - %@", subtitle.text, place[@"location"][@"city"]]];
            }
        } else
            [subtitle setText:@""];
        
        if (place[@"categories"] && [place[@"categories"] count]) {
            BOOL foundPrimary = NO;
            
            for (NSDictionary *category in place[@"categories"]) {
                if ([category[@"primary"] boolValue]) {
                    [icon setHidden:NO];
                    NSString *imgURL = [NSString stringWithFormat:@"%@64%@", category[@"icon"][@"prefix"], category[@"icon"][@"suffix"]];
                    [icon sd_setImageWithURL:[NSURL URLWithString:imgURL]];
                    foundPrimary = YES;
                    break;
                }
            }
            
            if (!foundPrimary) {
                NSDictionary *category = [place[@"categories"] objectAtIndex:0];
                [icon setHidden:NO];
                NSString *imgURL = [NSString stringWithFormat:@"%@64%@", category[@"icon"][@"prefix"], category[@"icon"][@"suffix"]];
                [icon sd_setImageWithURL:[NSURL URLWithString:imgURL]];
            }
        } else
            [icon setHidden:YES];
    }
    
}

@end
