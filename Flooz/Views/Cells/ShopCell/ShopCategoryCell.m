//
//  ShopCategoryCell.m
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopCategoryCell.h"
#import "FXBlurView.h"

@interface ShopCategoryCell()

@property (nonatomic, weak) FLShopItem *currentItem;
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UILabel *name;

@end

@implementation ShopCategoryCell

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
    
    self.name = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:24] textAlignment:NSTextAlignmentCenter numberOfLines:0];
    self.name.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.name.layer.shadowOpacity = 1.0;
    self.name.layer.shadowRadius = 0.0;
    self.name.layer.shadowColor = [UIColor blackColor].CGColor;
    self.name.layer.shadowOffset = CGSizeMake(0.0, -1.0);
    
    [self.content addSubview:self.image];
    [self.content addSubview:self.name];
    
    [self.contentView addSubview:self.content];
}

- (void)prepareViews {
    [self.image setHidden:YES];
    
    [self.image sd_setImageWithURL:[NSURL URLWithString:self.currentItem.pic] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!error && image) {
            [self.image setImage:[image blurredImageWithRadius:7 iterations:5 tintColor:[UIColor clearColor]]];
            [self.image setHidden:NO];
        }
    }];
    
    [self.name setText:self.currentItem.name];
    [self.name sizeToFit];
    
    CGRectSetXY(self.name.frame, CGRectGetWidth(self.content.frame) / 2 - CGRectGetWidth(self.name.frame) / 2, CGRectGetHeight(self.content.frame) / 2 - CGRectGetHeight(self.name.frame) / 2);
}

- (void)setShopItem:(FLShopItem *)item {
    self.currentItem = item;
    [self prepareViews];
}

@end
