//
//  ActivityCell.h
//  Flooz
//
//  Created by jonathan on 2/17/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell{
    CGFloat height;
    
    FLUserView *userView;
    UILabel *contentView;
    
    UIView *horizontalSeparator;
    UIView *verticalSeparator;
    
    UILabel *dateView;
}

+ (CGFloat)getHeightForActivity:(FLActivity *)activity;

@property (weak, nonatomic) FLActivity *activity;

@end
