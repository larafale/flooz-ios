//
//  FLSwitchView.h
//  Flooz
//
//  Created by jonathan on 2014-04-02.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLSwitchViewDelegate.h"

@interface FLSwitchView : UIView{
    UILabel *_title;
}

@property (weak) id<FLSwitchViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame title:(NSString *)title;

@end
