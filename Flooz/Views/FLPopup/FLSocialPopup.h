//
//  FLSocialPopup.h
//  Flooz
//
//  Created by Epitech on 11/27/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"

@interface FLSocialPopup : UIViewController {
    void (^fbBlock)(void);
    void (^twitterBlock)(void);
    void (^appBlock)(void);
}

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (id)initWithTitle:(NSString *)title fb:(void (^)())fb twitter:(void (^)())twitter app:(void (^)())app;
- (void)show;

@end
