//
//  InviteViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-16.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"
#import <Social/Social.h>

@interface InviteViewController : BaseViewController<TTTAttributedLabelDelegate>

- (id)initWithUser:(NSDictionary *)_user;

@end
