//
//  ShopCardCell.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopCardCell.h"

@interface ShopCardCell()

@property (nonatomic, weak) FLShopItem *currentItem;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIView *infosLabel;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *amount;

@end

@implementation ShopCardCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    self.contentView.layer.masksToBounds = YES;
    
    self.content = [[UIView alloc] initWithFrame:CGRectMake(MARGIN_H, MARGIN_V, PPScreenWidth() - 2 * MARGIN_H, [ShopCell getHeight] - 2 * MARGIN_V)];
    self.content.layer.masksToBounds = YES;
    self.content.layer.cornerRadius = 3.5f;
    self.content.backgroundColor = [UIColor customBackground];
    
    self.image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.content.frame), CGRectGetHeight(self.content.frame))];
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    
    self.infosLabel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    self.infosLabel.backgroundColor = [UIColor customBlue];
    
    self.name = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentRegular:19] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    self.name.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.amount = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:19] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    
    [self.infosLabel addSubview:self.name];
    [self.infosLabel addSubview:self.amount];
    
    [self.content addSubview:self.image];
    
    [self.contentView addSubview:self.content];
    [self.contentView addSubview:self.infosLabel];
}

- (void)prepareViews {
    [self.image setHidden:YES];
    
    [self.image sd_setImageWithURL:[NSURL URLWithString:self.currentItem.pic] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!error && image) {
            [self.image setHidden:NO];
        }
    }];
    
    CGRect labelFrame = CGRectMake(0, 0, 0, 0);
    
    [self.name setText:self.currentItem.name];
    [self.name sizeToFit];
    
    CGRectSetWidth(labelFrame, CGRectGetWidth(self.name.frame) + 50);
    CGRectSetHeight(labelFrame, CGRectGetHeight(self.name.frame) + 20);
    
    CGRectSetXY(self.name.frame, CGRectGetWidth(labelFrame) - CGRectGetWidth(self.name.frame) - 15, 10);
    
    if (self.currentItem.value && ![self.currentItem.value isBlank]) {
        [self.amount setText:self.currentItem.value];
        [self.amount sizeToFit];
        
        CGRectSetHeight(labelFrame, CGRectGetHeight(labelFrame) + CGRectGetHeight(self.name.frame) + 5);
        CGRectSetXY(self.amount.frame, CGRectGetWidth(labelFrame) - CGRectGetWidth(self.amount.frame) - 15, CGRectGetMaxY(self.name.frame) + 5);
    }
    
    UIBezierPath* labelBackPath = [UIBezierPath bezierPath];
    [labelBackPath moveToPoint:CGPointMake(0, 0)];
    [labelBackPath addLineToPoint:CGPointMake(CGRectGetWidth(labelFrame), 0)];
    [labelBackPath addLineToPoint:CGPointMake(CGRectGetWidth(labelFrame), CGRectGetHeight(labelFrame))];
    [labelBackPath addLineToPoint:CGPointMake(0, CGRectGetHeight(labelFrame))];
    [labelBackPath addLineToPoint:CGPointMake(CGRectGetHeight(labelFrame) / 2 - 5, CGRectGetHeight(labelFrame) / 2)];
    [labelBackPath closePath];
    
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:labelBackPath.CGPath];
    
    CGRectSetXY(labelFrame, PPScreenWidth() - CGRectGetWidth(labelFrame) - MARGIN_H / 2, CGRectGetMaxY(self.content.frame) / 2 + 15);
    
    self.infosLabel.frame = labelFrame;
    self.infosLabel.layer.masksToBounds = NO;
    self.infosLabel.layer.mask = triangleMaskLayer;
}

- (void)setShopItem:(FLShopItem *)item {
    self.currentItem = item;
    [self prepareViews];
}

@end
