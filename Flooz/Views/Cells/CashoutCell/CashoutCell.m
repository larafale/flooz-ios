//
//  CashoutCell.m
//  Flooz
//
//  Created by Olive on 02/09/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "CashoutCell.h"

@interface CashoutCell() {
    NSDictionary *currentHistoryItem;
    
    UILabel *amountLabel;
    UILabel *dateLabel;
}

@end

@implementation CashoutCell

+ (CGFloat)getHeight {
    return 50;
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
    
    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(PPScreenWidth() / 2, 10, PPScreenWidth() / 2 - 20, 30)];
    amountLabel.numberOfLines = 1;
    amountLabel.font = [UIFont customContentBold:15];
    amountLabel.textColor = [UIColor whiteColor];
    amountLabel.textAlignment = NSTextAlignmentRight;
    
    dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, PPScreenWidth() / 2 - 20, 30)];
    dateLabel.numberOfLines = 1;
    dateLabel.font = [UIFont customContentRegular:15];
    dateLabel.textColor = [UIColor customWhite];
    dateLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.contentView addSubview:amountLabel];
    [self.contentView addSubview:dateLabel];
}

- (void)prepareViews {
    
    [amountLabel setText:[FLHelper formatedAmount:currentHistoryItem[@"amount"] withCurrency:YES withSymbol:NO]];
    
    static NSDateFormatter *dateFormatter;
    if (!dateFormatter) {
        dateFormatter = [NSDateFormatter new];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    }
    
    [dateLabel setText:[FLHelper momentWithDate:[dateFormatter dateFromString:[currentHistoryItem objectForKey:@"cAt"]]]];
}

- (void)setHistoryItem:(NSDictionary *)item {
    currentHistoryItem = item;
    [self prepareViews];
}


@end
