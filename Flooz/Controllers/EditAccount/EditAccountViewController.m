//
//  EditAccountViewController.m
//  Flooz
//
//  Created by jonathan on 1/24/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "EditAccountViewController.h"

@interface EditAccountViewController ()

@end

@implementation EditAccountViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"NAV_EDIT_ACCOUNT", nil);
    }
    return self;
}

@end
