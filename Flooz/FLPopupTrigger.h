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

- (void)show;

@end
