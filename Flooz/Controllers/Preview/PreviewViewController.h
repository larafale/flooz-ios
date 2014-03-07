//
//  PreviewViewController.h
//  Flooz
//
//  Created by jonathan on 1/15/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PreviewNavBar.h"

@interface PreviewViewController : UIViewController<PreviewNavBarDelegate>

@property (weak, nonatomic) IBOutlet PreviewNavBar *previewNavBar;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end
