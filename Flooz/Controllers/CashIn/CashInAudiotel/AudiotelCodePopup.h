//
//  AudiotelCodePopup.h
//  Flooz
//
//  Created by Olive on 4/18/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudiotelCodePopup : UIViewController

@property (strong, nonatomic) MZFormSheetController *formSheet;

- (void)show;
- (void)dismiss;

@end
