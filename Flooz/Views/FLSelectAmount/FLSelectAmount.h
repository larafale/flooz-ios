//
//  FLSelectAmount.h
//  Flooz
//
//  Created by jonathan on 2/5/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLSelectAmountDelegate.h"

@interface FLSelectAmount : UIView {
	UILabel *_title;
	UISwitch *switchView;

	// Pour detecter si on slide et revient sur la position original
	BOOL switchCurrentValue;
}

@property (weak) id <FLSelectAmountDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)setSwitch:(BOOL)value;

@end
