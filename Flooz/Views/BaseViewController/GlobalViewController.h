//
//  GlobalViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalViewController : UIViewController

@property (nonatomic) Boolean hideNavShadow;
@property (nonatomic, strong) NSDictionary *triggerData;

- (id)initWithTriggerData:(NSDictionary *)data;

- (void)dismissViewController;
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view;

@end
