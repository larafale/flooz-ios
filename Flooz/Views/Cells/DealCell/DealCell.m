//
//  DealCell.m
//  Flooz
//
//  Created by Olive on 1/6/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "DealCell.h"

#define PIC_HEIGHT 70.0f

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface DealCell ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UILabel *expires;
@property (nonatomic, strong) UILabel *combinable;
@property (nonatomic, strong) UILabel *amount;
@property (nonatomic, strong) UIView *amountBack;

@property (nonatomic, weak) FLDeal *currentDeal;

@end

@implementation DealCell

+ (CGFloat)getHeight:(FLDeal *)deal {
    CGFloat height = 10.0f;
    
    if (deal.pic && deal.pic.length > 0)
        height += PIC_HEIGHT;
    
    height += 35.0f;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[deal desc] attributes:@{ NSFontAttributeName: [UIFont customContentRegular:14]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {PPScreenWidth() - 40.0f, CGFLOAT_MAX } options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    
    height += rect.size.height;
    
    height += 20.0f;
    
    return height;
}

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
    
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 10.0f, PPScreenWidth() - 20.0f, 10.0f)];
    [self.containerView setBackgroundColor:[UIColor customBackground]];
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 5;
    
    self.picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), PIC_HEIGHT)];
    self.picView.layer.masksToBounds = YES;
    [self.picView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.title = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:16] textAlignment:NSTextAlignmentLeft numberOfLines:1];
    CGRectSetXY(self.title.frame, 10.0f, CGRectGetMinY(self.picView.frame));
    CGRectSetWidth(self.title.frame, CGRectGetWidth(self.containerView.frame) - CGRectGetMinX(self.title.frame) - 100);
    CGRectSetHeight(self.title.frame, 20.0f);
    
    self.desc = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentRegular:14] textAlignment:NSTextAlignmentLeft numberOfLines:0];
    [self.desc setLineBreakMode:NSLineBreakByWordWrapping];
    CGRectSetXY(self.desc.frame, 10.0f, CGRectGetMaxY(self.title.frame));
    CGRectSetWidth(self.desc.frame, CGRectGetWidth(self.containerView.frame) - CGRectGetMinX(self.desc.frame) - 10.0f);
    
    UIBezierPath* amountBackPath = [UIBezierPath bezierPath];
    [amountBackPath moveToPoint:CGPointMake(0, 0)];
    [amountBackPath addLineToPoint:CGPointMake(90, 0)];
    [amountBackPath addLineToPoint:CGPointMake(90, 40)];
    [amountBackPath addLineToPoint:CGPointMake(0, 40)];
    [amountBackPath addLineToPoint:CGPointMake(15, 20)];
    [amountBackPath closePath];
    
    CAShapeLayer *triangleMaskLayer = [CAShapeLayer layer];
    [triangleMaskLayer setPath:amountBackPath.CGPath];
    
    self.amountBack = [[UIView alloc] initWithFrame:CGRectMake(PPScreenWidth() - 90, 20, 90, 40)];
    
    self.amountBack.backgroundColor = [UIColor customBlue];
    self.amountBack.layer.masksToBounds = NO;
    self.amountBack.layer.mask = triangleMaskLayer;
    
    self.amount = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:18] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    self.amount.minimumScaleFactor = 10./self.amount.font.pointSize;

    CGRectSetHeight(self.amount.frame, 20.0f);
    CGRectSetWidth(self.amount.frame, 55);
    CGRectSetXY(self.amount.frame, 25, 10);
    
    [self.amountBack addSubview:self.amount];

    [self.containerView addSubview:self.picView];
    [self.containerView addSubview:self.title];
    [self.containerView addSubview:self.desc];
    
    [self.contentView addSubview:self.containerView];
    [self.contentView addSubview:self.amountBack];
}

- (void)setDeal:(FLDeal *)deal {
    if (deal) {
        self.currentDeal = deal;
        
        [self prepareViews];
    }
}

- (void)prepareViews {
    if (self.currentDeal.pic && self.currentDeal.pic.length > 0) {
        [self.picView sd_setImageWithURL:[NSURL URLWithString:self.currentDeal.pic]];
        [self.picView setHidden:NO];
        CGRectSetHeight(self.picView.frame, PIC_HEIGHT);
    } else {
        [self.picView setHidden:YES];
        CGRectSetHeight(self.picView.frame, 0);
    }

    if (self.currentDeal.amountType == FLDealAmountTypeVariable)
        [self.amount setText:[NSString stringWithFormat:@"%d%%", self.currentDeal.amount.intValue]];
    else
        [self.amount setText:[FLHelper formatedAmount:self.currentDeal.amount withCurrency:YES withSymbol:NO]];
    
    [self.title setText:[self.currentDeal.title uppercaseString]];
    
    CGRectSetY(self.title.frame, CGRectGetMaxY(self.picView.frame) + 10.0f);
    
    [self.desc setText:self.currentDeal.desc];
    [self.desc setHeightToFit];
    
    CGRectSetY(self.desc.frame, CGRectGetMaxY(self.title.frame) + 5.0f);

    CGRectSetHeight(self.containerView.frame, CGRectGetMaxY(self.desc.frame) + 10.0f);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

@end
