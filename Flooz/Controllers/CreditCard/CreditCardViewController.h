//
//  CreditCardViewController.h
//  Flooz
//
//  Created by jonathan on 2/20/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ScanPayViewController.h"

@interface CreditCardViewController : UIViewController<ScanPayDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *contentView;

@end
