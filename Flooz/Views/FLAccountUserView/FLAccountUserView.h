//
//  FLAccountUserView.h
//  Flooz
//
//  Created by jonathan on 1/23/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAccountUserView : UIView{
    __weak FLUser *user;
    
    FLUserView *userView;
    UILabel *username;
    UILabel *friends;
    UILabel *flooz;
    UILabel *profilCompletion;
    
    NSAttributedString *friendsTextStatic;
    NSAttributedString *floozTextStatic;
    NSAttributedString *profilCompletionTextStatic;
}

- (void)reloadData;

@end
