//
//  FLCreditCardScanner.h
//  Flooz
//
//  Created by Olive on 13/05/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardIO.h"

@interface FLCreditCardScanner : UIViewController

@property (weak, nonatomic) id<CardIOViewDelegate> delegate;
@property (strong, nonatomic) MZFormSheetController *formSheet;
@property (strong, nonatomic) CardIOView *cardIOView;

- (id)initWithDelegate:(id<CardIOViewDelegate>)delegate;
- (void)show;
- (void)dismiss;

@end
