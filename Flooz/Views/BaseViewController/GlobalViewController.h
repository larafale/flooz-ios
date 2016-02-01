//
//  GlobalViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GlobalViewController : UIViewController

- (id)initWithTriggerData:(NSDictionary *)triggerData;

- (void)dismissViewController;
- (UIImageView *)findHairlineImageViewUnder:(UIView *)view;

@end
