//
//  secureCodeLoginViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-08-22.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import "FLKeyboardView.h"

@interface secureCodeLoginViewController : UIViewController <SecureCodeFieldDelegate>

- (id)initWithUser:(NSDictionary *)_user;

@end
