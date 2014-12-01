//
//  CodePinView.h
//  Flooz
//
//  Created by Arnaud on 2014-09-18.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLKeyboardViewDelegate.h"

@protocol CodePinDelegate;

@interface CodePinView : UIView <FLKeyboardViewDelegate>

@property (weak, nonatomic) UIViewController <CodePinDelegate> *delegate;
@property (strong, nonatomic) NSString *digitON;
@property (strong, nonatomic) NSString *digitOFF;

- (id)initWithNumberOfDigit:(NSInteger)numberOfDigit andFrame:(CGRect)frame;
- (void)setPin:(NSString *)pin;
- (void)animationBadPin;
- (void)clean;

@end


@protocol CodePinDelegate <NSObject>

@required
- (void)pinEnd:(NSString *)pin;

@optional
- (void)pinChange:(BOOL)pinStarts;

@end
