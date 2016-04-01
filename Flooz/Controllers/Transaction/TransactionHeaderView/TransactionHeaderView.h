//
//  TransactionHeaderView.h
//  Flooz
//
//  Created by Olive on 3/31/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TransactionHeaderViewDelegate

@end

@interface TransactionHeaderView : UIView

- (id)initWithTransaction:(FLTransaction *)transaction parentController:(UIViewController<TransactionHeaderViewDelegate>*)controller;
- (void)reloadView;
- (void)setTransaction:(FLTransaction *)transaction;
- (CGFloat)headerSize;

@end
