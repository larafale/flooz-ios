//
//  CollectHeaderView.h
//  Flooz
//
//  Created by Olive on 3/8/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CollectHeaderViewDelegate



@end

@interface CollectHeaderView : UIView

- (id)initWithCollect:(FLTransaction *)transaction parentController:(UIViewController<CollectHeaderViewDelegate>*)controller;
- (void)reloadView;
- (void)setTransaction:(FLTransaction *)transaction;

@end
