//
//  FLSelectAmount.h
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLSelectAmountDelegate.h"

@interface FLSelectAmount : UIView{
    UILabel *_title;
    UISwitch *switchView;
}

@property (weak) id<FLSelectAmountDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setSwitch:(BOOL)value;

@end
