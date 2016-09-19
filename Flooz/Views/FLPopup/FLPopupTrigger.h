//
//  FLPopupTrigger.h
//  Flooz
//
//  Created by Epitech on 9/29/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPopupTrigger : UIViewController

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (id)initWithData:(NSDictionary*)data;
- (id)initWithData:(NSDictionary*)data dismiss:(void (^)())block;

- (void)show;
- (void)show:(dispatch_block_t)completion;

- (void)dismiss:(void (^)())completion;
- (void)dismiss;

@end
