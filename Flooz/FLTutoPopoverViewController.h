//
//  FLTutoPopoverViewController.h
//  Flooz
//
//  Created by Olivier on 2/25/15.
//  Copyright (c) 2015 olivier Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTutoPopoverViewController : UIViewController

@property (nonatomic, retain) NSString *titleString;
@property (nonatomic, retain) NSString *msgString;
@property (nonatomic, retain) NSString *btnString;
@property (nonatomic, retain) NSNumber *stepNumber;
@property (nonatomic, retain) UILabel *popoverTitle;
@property (nonatomic, retain) UILabel *popoverMessage;
@property (nonatomic, retain) UILabel *popoverStep;
@property (nonatomic, retain) UIButton *popoverButton;

- (id)initWithTitle:(NSString*)title message:(NSString*)msg;
- (id)initWithTitle:(NSString*)title message:(NSString*)msg step:(NSNumber*)step;
- (id)initWithTitle:(NSString*)title message:(NSString*)msg button:(NSString*)buttonText action:(void (^)(FLTutoPopoverViewController* viewController))action;
- (id)initWithTitle:(NSString*)title message:(NSString*)msg step:(NSNumber*)step button:(NSString*)buttonText action:(void (^)(FLTutoPopoverViewController* viewController))action;

@end
