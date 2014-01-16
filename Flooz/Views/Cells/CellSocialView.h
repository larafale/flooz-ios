//
//  CellSocialView.h
//  Flooz
//
//  Created by jonathan on 1/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CellSocialView : UIView{
    JTImageLabel *comment;
    JTImageLabel *like;
    UIView *separator;
}

- (void)prepareView;

@end
