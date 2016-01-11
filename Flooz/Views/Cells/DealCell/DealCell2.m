//
//  DealCell2.m
//  Flooz
//
//  Created by Olive on 1/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "DealCell2.h"

#define PIC_HEIGHT 100.0f
#define MARGIN 10.0f
#define TITLE_HEIGHT 18.0f
#define LABEL_HEIGHT 50.0f
#define LABEL_WIDTH 50.0f

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface DealCell2()

@property (nonatomic, strong) UIImageView *picView;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *desc;
@property (nonatomic, strong) UILabel *expires;
@property (nonatomic, strong) UILabel *combinable;
@property (nonatomic, strong) UILabel *amount;
@property (nonatomic, strong) UIView *amountBack;

@property (nonatomic, weak) FLDeal *currentDeal;

@end

@implementation DealCell2

+ (CGFloat)getHeight:(FLDeal *)deal {
    return PIC_HEIGHT;
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
    self.contentView.layer.masksToBounds = YES;
    
    self.rightSwipeSettings.transition = MGSwipeTransitionClipCenter;
    self.rightExpansion.fillOnTrigger = YES;
    self.rightExpansion.threshold = 1.0f;
    self.rightExpansion.buttonIndex = 0;
    
    self.picView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, PPScreenWidth() / 100 * 35.0f, PIC_HEIGHT)];
    self.picView.layer.masksToBounds = YES;
    [self.picView setContentMode:UIViewContentModeScaleAspectFill];
    
    self.title = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:15] textAlignment:NSTextAlignmentRight numberOfLines:1];
    CGRectSetXY(self.title.frame, CGRectGetMaxX(self.picView.frame) + MARGIN, MARGIN);
    CGRectSetWidth(self.title.frame, PPScreenWidth() - CGRectGetMinX(self.title.frame) - MARGIN);
    CGRectSetHeight(self.title.frame, TITLE_HEIGHT);
    
    self.desc = [[UILabel alloc] initWithText:@"" textColor:[UIColor customPlaceholder] font:[UIFont customContentRegular:13] textAlignment:NSTextAlignmentRight numberOfLines:0];
    [self.desc setLineBreakMode:NSLineBreakByTruncatingTail];
    self.desc.minimumScaleFactor = 8./self.amount.font.pointSize;
    self.desc.adjustsFontSizeToFitWidth = NO;
    CGRectSetXY(self.desc.frame, CGRectGetMaxX(self.picView.frame) + MARGIN + LABEL_WIDTH / 2, CGRectGetMaxY(self.title.frame) + MARGIN / 2);
    CGRectSetWidth(self.desc.frame, PPScreenWidth() - CGRectGetMinX(self.title.frame) - MARGIN - LABEL_WIDTH / 2);
    CGRectSetHeight(self.desc.frame, PIC_HEIGHT - MARGIN * 3 - TITLE_HEIGHT * 2);

    self.amountBack = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.picView.frame) - (LABEL_WIDTH / 2), PIC_HEIGHT / 2 - LABEL_HEIGHT / 2, LABEL_WIDTH, LABEL_HEIGHT)];
    self.amountBack.backgroundColor = [UIColor customBlue];
    self.amountBack.layer.masksToBounds = NO;
    self.amountBack.layer.cornerRadius = LABEL_WIDTH / 2;
    //
    self.amount = [[UILabel alloc] initWithText:@"" textColor:[UIColor whiteColor] font:[UIFont customContentBold:18] textAlignment:NSTextAlignmentCenter numberOfLines:1];
    self.amount.minimumScaleFactor = 10./self.amount.font.pointSize;
    self.amount.adjustsFontSizeToFitWidth = YES;
    
    CGRectSetHeight(self.amount.frame, TITLE_HEIGHT);
    CGRectSetWidth(self.amount.frame, LABEL_WIDTH - (MARGIN * 2));
    CGRectSetXY(self.amount.frame, LABEL_WIDTH / 2 - CGRectGetWidth(self.amount.frame) / 2 , LABEL_HEIGHT / 2 - TITLE_HEIGHT / 2);
    
    [self.amountBack addSubview:self.amount];
    
    [self.contentView addSubview:self.picView];
    [self.contentView addSubview:self.title];
    [self.contentView addSubview:self.desc];
    [self.contentView addSubview:self.amountBack];
}

- (void)setDeal:(FLDeal *)deal {
    if (deal) {
        self.currentDeal = deal;
        
        [self prepareViews];
    }
}

- (void)prepareViews {
    [self.picView sd_setImageWithURL:[NSURL URLWithString:self.currentDeal.pic]];
    
    if (self.currentDeal.amountType == FLDealAmountTypeVariable)
        [self.amount setText:[NSString stringWithFormat:@"%d%%", self.currentDeal.amount.intValue]];
    else
        [self.amount setText:[FLHelper formatedAmount:self.currentDeal.amount withCurrency:YES withSymbol:NO]];
    
    [self.title setText:[self.currentDeal.title uppercaseString]];
    
    [self.desc setText:self.currentDeal.desc];
    
    CGRectSetY(self.desc.frame, CGRectGetMaxY(self.title.frame) + MARGIN / 2);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    if ([self isSelected]) {
        self.contentView.backgroundColor = [UIColor customBlue];
        self.amountBack.backgroundColor = [UIColor whiteColor];
        self.amount.textColor = [UIColor customBlue];
        self.desc.textColor = [UIColor customBackgroundHeader];
        self.contentView.layer.borderWidth = 1.5;
        self.contentView.layer.borderColor = [UIColor customBlue].CGColor;
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.amountBack.backgroundColor = [UIColor customBlue];
        self.amount.textColor = [UIColor whiteColor];
        self.desc.textColor = [UIColor customPlaceholder];
        self.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

@end
