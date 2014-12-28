//
//  ClipboardPopoverViewController.m
//  Flooz
//
//  Created by Epitech on 12/23/14.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import "ClipboardPopoverViewController.h"

@implementation ClipboardPopoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.button setTitle:NSLocalizedString(@"SHARE_CLIPBOARD", nil) forState:UIControlStateNormal];
    [self.button setFrame:CGRectMake(0, 0, 120, 35)];
    
    [self.view addSubview:self.button];
}

@end
