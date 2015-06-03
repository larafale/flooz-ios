//
//  NewTransactionSelectTypeView.h
//  Flooz
//
//  Created by olivier on 2014-03-17.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "NewTransactionSelectTypeDelegate.h"

@interface NewTransactionSelectTypeView : UIView {
	__weak NSMutableDictionary *_dictionary;

	UIButton *buttonLeft;
	UIButton *buttonRight;
}

@property (weak) id <NewTransactionSelectTypeDelegate> delegate;

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary;

@end
