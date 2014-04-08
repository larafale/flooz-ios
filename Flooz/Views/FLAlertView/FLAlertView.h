//
//  FLAlertView.h
//  Flooz
//
//  Created by jonathan on 2014-03-25.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FLAlertViewStyle) {
    FLAlertViewStyleSuccess,
    FLAlertViewStyleError,
    FLAlertViewStyleInfo
};

@interface FLAlertView : UIView{
    UILabel *titleView;
    UILabel *contentView;
    UIImageView *iconView;
    
    NSTimer *timer;
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style;
- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style time:(NSNumber *)time;

@end
