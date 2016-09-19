//
//  FLMultiLineSegmentedControl.h
//  Flooz
//
//  Created by Epitech on 9/25/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface FLMultiLineSegmentedControl : UISegmentedControl

- (void)setMultilineTitle:(NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment;

+ (NSAttributedString *)itemTitleWithText:(NSString*)text andStat:(NSUInteger)data;
- (void)updateMultilineTitle:(NSAttributedString *)title forSegmentAtIndex:(NSUInteger)segment;

@end