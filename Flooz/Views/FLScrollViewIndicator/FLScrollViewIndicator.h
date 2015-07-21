//
//  FLScrollViewIndicator.h
//  Flooz
//
//  Created by olivier on 2014-04-03.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLScrollViewIndicator : UIView {
	UIView *containerView;
	JTImageLabel *label;
	SocialScope currentScope;
}

- (void)setTransaction:(FLTransaction *)transaction;

@end
