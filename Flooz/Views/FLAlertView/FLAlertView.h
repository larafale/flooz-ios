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
    FLAlertViewStyleError
};

@interface FLAlertView : UIView{
    UILabel *titleView;
    UILabel *contentView;
    
    NSTimer *timer;
}

- (void)show:(NSString *)title content:(NSString *)content style:(FLAlertViewStyle)style;

@end
