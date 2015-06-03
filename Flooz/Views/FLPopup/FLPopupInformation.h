//
//  FLPopupInformation.h
//  Flooz
//
//  Created by Arnaud on 2014-09-10.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupInformation : UIViewController {
	void (^okBlock)(void);
}

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (id)initWithTitle:(NSString *)title andMessage:(NSAttributedString *)message ok:(void (^)())ok;
- (id)initWithTitle:(NSString *)title message:(NSAttributedString *)message button:(NSString*)btn ok:(void (^)())ok;
- (void)show;

@end
