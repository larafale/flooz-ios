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
    __weak NSMutableDictionary *_dictionary;
    
    UILabel *_title;
    
    UIButton *buttonLeft;
    UIButton *buttonRight;
}

@property (weak) id<FLSelectAmountDelegate> delegate;

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary;

@end
