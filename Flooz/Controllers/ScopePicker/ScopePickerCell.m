//
//  ScopePickerCell.m
//  Flooz
//
//  Created by Olive on 18/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ScopePickerCell.h"

@interface ScopePickerCell () {
    UIImageView *imageView;
    UILabel *title;
    UILabel *subtitle;
}

@end

@implementation ScopePickerCell

+ (CGFloat) getHeight:(TransactionScope)scope pot:(Boolean)isPot {
    
    NSString *subLabel = [FLTransaction transactionScopeToSubtitle:scope forPot:isPot];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc]
                      initWithString:subLabel
                      attributes:@{ NSFontAttributeName: [UIFont customContentRegular:12]}];
    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {PPScreenWidth() - 100, CGFLOAT_MAX }
                                        options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                        context:nil];

    return 40 + (MAX(rect.size.height, 15));
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    
    imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, 30, 30)];
    [imageView setTintColor:[UIColor whiteColor]];
    [imageView setContentMode:UIViewContentModeCenter];

    title = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 5, PPScreenWidth() - 100, 20)];
    [title setFont:[UIFont customContentRegular:15]];
    [title setTextColor:[UIColor whiteColor]];

    subtitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 27, PPScreenWidth() - 100, 20)];
    [subtitle setFont:[UIFont customContentRegular:12]];
    [subtitle setTextColor:[UIColor customPlaceholder]];
    [subtitle setNumberOfLines:0];
    [subtitle setLineBreakMode:NSLineBreakByWordWrapping];
    
    [self.contentView addSubview:imageView];
    [self.contentView addSubview:title];
    [self.contentView addSubview:subtitle];
}

- (void) setScope:(TransactionScope)scope pot:(Boolean)isPot {
    [imageView setImage:[[FLHelper imageWithImage:[FLTransaction transactionScopeToImage:scope] scaledToSize:CGSizeMake(25, 25)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [title setText:[FLTransaction transactionScopeToText:scope]];
    [subtitle setText:[FLTransaction transactionScopeToSubtitle:scope forPot:isPot]];

    CGRectSetHeight(subtitle.frame, MAX([subtitle heightToFit], 15));
}

@end
