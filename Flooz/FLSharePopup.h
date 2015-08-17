//
//  FLSharePopup.h
//  Flooz
//
//  Created by Epitech on 8/17/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MZFormSheetController.h"

@interface FLSharePopup : UIViewController {
    void (^acceptBlock)(NSString *);
    void (^refuseBlock)(void);
}

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (id)initWithTitle:(NSString *)title placeholder:(NSString *)placeholder accept:(void (^)(NSString *))accept refuse:(void (^)())refuse;
- (void)show;

@end
