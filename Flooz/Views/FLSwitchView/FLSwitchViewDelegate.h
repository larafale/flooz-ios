//
//  FLSwitchViewDelegate.h
//  Flooz
//
//  Created by jonathan on 2014-04-02.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FLSwitchViewDelegate <NSObject>

- (void)didSwitchViewSelected;
- (void)didSwitchViewUnselected;

@end
