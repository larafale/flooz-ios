//
//  ShopHistoryCell.m
//  Flooz
//
//  Created by Olive on 01/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ShopHistoryCell.h"

@interface ShopHistoryCell() {
    NSDictionary *currentHistoryItem;
    
    UILabel *nameLabel;
    UILabel *amountLabel;
    UILabel *dateLabel;
}

@end

@implementation ShopHistoryCell

+ (CGFloat)getHeight {
    return 60;
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
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, PPScreenWidth() / 2 - 10, 30)];
    nameLabel.numberOfLines = 1;
    nameLabel.font = [UIFont customContentRegular:16];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    
    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2, 10, PPScreenWidth() / 2 - 10, 20)];
    amountLabel.numberOfLines = 1;
    amountLabel.font = [UIFont customContentBold:16];
    amountLabel.textColor = [UIColor whiteColor];
    amountLabel.textAlignment = NSTextAlignmentRight;

    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2, 35, PPScreenWidth() / 2 - 10, 15)];
    dateLabel.numberOfLines = 1;
    dateLabel.font = [UIFont customContentRegular:12];
    dateLabel.textColor = [UIColor customPlaceholder];
    dateLabel.textAlignment = NSTextAlignmentRight;

    [self.contentView addSubview:nameLabel];
    [self.contentView addSubview:amountLabel];
    [self.contentView addSubview:dateLabel];
}

- (void)prepareViews {
    
    if ([currentHistoryItem[@"code"] isKindOfClass:[NSString class]]) {
        [nameLabel setText:currentHistoryItem[@"type"][@"name"]];
    } else if ([currentHistoryItem[@"code"] isKindOfClass:[NSArray class]]) {
        if ([currentHistoryItem[@"code"] count] > 1) {
            [nameLabel setText:[NSString stringWithFormat:@"%@ x %lui", currentHistoryItem[@"type"][@"name"], [currentHistoryItem[@"code"] count]]];
        } else {
            [nameLabel setText:currentHistoryItem[@"type"][@"name"]];
        }
    }
    
    [amountLabel setText:[FLHelper formatedAmount:currentHistoryItem[@"amount"] withCurrency:YES withSymbol:NO]];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    }
    
    [dateLabel setText:[FLHelper momentWithDate:[dateFormatter dateFromString:[currentHistoryItem objectForKey:@"cAt"]]]];
}

- (void)setShopHistoryItem:(NSDictionary *)item {
    currentHistoryItem = item;
    [self prepareViews];
}

@end
