//
//  FLScrollViewIndicator.h
//  Flooz
//
//  Created by jonathan on 2014-04-03.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLScrollViewIndicator : UIView{
    UIView *conainterView;
    JTImageLabel *label;
    SocialScope currentScope;
}

- (void)setTransaction:(FLTransaction *)transaction;

@end
