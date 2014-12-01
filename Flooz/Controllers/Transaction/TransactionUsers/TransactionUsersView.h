//
//  TransactionUsersView.h
//  Flooz
//
//  Created by jonathan on 2/7/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TransactionUsersView : UIView {
	UIView *leftUserView;
	UIView *rightUserView;
}

@property (weak, nonatomic) FLTransaction *transaction;

@end
