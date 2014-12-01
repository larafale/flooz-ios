//
//  FLPaymentField.h
//  Flooz
//
//  Created by jonathan on 1/27/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FLPaymentFieldDelegate.h"

@interface FLPaymentField : UIView {
	__weak NSMutableDictionary *_dictionary;
	NSString *_dictionaryKey;

	UIButton *leftButton;
	UIButton *rightButton;

	UILabel *leftText;
	UILabel *rightText;
	UILabel *amount;
}

@property (weak, nonatomic) id <FLPaymentFieldDelegate> delegate;

- (id)initWithFrame:(CGRect)frame for:(NSMutableDictionary *)dictionary key:(NSString *)dictionaryKey;
- (void)setStyleLight;
- (void)reloadUser;

+ (CGFloat)height;

- (void)didWalletTouch;
- (void)didCardTouch;

@end
