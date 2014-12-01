//
//  FLFilterView.h
//  Flooz
//
//  Created by jonathan on 1/19/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFilterView : UIView {
	UIView *contentView;
	NSMutableArray *buttonColors;
	NSMutableArray *filterViews;
	NSMutableArray *actions;

	NSInteger currentFilterIndex;
	NSInteger currentFilterColorIndex;
}

- (void)addFilter:(NSString *)image title:(NSString *)title target:(id)target action:(SEL)action;
- (void)addFilter:(NSString *)image title:(NSString *)title target:(id)target action:(SEL)action colors:(NSArray *)colors;

- (void)selectFilter:(NSUInteger)index;

@end
