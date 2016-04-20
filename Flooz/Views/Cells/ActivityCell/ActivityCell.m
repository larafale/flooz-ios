//
//  ActivityCell.m
//  Flooz
//
//  Created by Olive on 4/20/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "ActivityCell.h"

#define MIN_HEIGHT 60
#define MARGE_TOP_BOTTOM 10.
#define MARGE_LEFT 10.
#define MARGE_RIGHT 10.
#define CONTENT_X 80.
#define DATE_VIEW_HEIGHT 15.

@implementation ActivityCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createViews];
    }
    return self;
}

+ (CGFloat)getHeightForActivity:(FLActivity *)activity {
    CGFloat height = 0;
//    
//    NSAttributedString *attributedText = [[NSAttributedString alloc]
//                                          initWithString:[notification content]
//                                          attributes:@{ NSFontAttributeName: [UIFont customContentRegular:13] }];
//    CGRect rect = [attributedText boundingRectWithSize:(CGSize) {widthCell - CONTENT_X - MARGE_RIGHT, CGFLOAT_MAX }
//                                               options:NSStringDrawingUsesLineFragmentOrigin
//                                               context:nil];
//    height += rect.size.height + 3; // +3 pour les emojis
//    
//    // Date
//    height += DATE_VIEW_HEIGHT;
//    
//    height += MARGE_TOP_BOTTOM + MARGE_TOP_BOTTOM;
    
    return MAX(MIN_HEIGHT, height);
}

- (void)setActivity:(FLActivity *)activity {
    self->_activity = activity;
    [self prepareViews];
}

#pragma mark - Create Views

- (void)createViews {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor customBackgroundHeader];
    
}


#pragma mark - Prepare Views

- (void)prepareViews {
    
}

@end
