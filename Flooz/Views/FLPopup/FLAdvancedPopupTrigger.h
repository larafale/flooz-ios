//
//  FLAdvancedPopupTrigger.h
//  Flooz
//
//  Created by Olive on 28/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAdvancedPopupTrigger : UIViewController

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (id)initWithData:(NSDictionary*)data;
- (id)initWithData:(NSDictionary*)data dismiss:(void (^)())block;

- (void)show;
- (void)show:(dispatch_block_t)completion;

- (void)dismiss:(void (^)())completion;
- (void)dismiss;

@end
