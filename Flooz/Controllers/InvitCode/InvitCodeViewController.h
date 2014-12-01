//
//  InvitCodeViewController.h
//  Flooz
//
//  Created by Jonathan on 18/07/14.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvitCodeViewController : GlobalViewController

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentCodeLabel;

@end
