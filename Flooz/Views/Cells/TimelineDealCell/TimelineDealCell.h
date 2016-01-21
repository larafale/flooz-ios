//
//  TimelineDealCell.h
//  Flooz
//
//  Created by Olive on 1/21/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLSocial.h"
#import "TimelineDealCellDelegate.h"
#import "WYPopoverController.h"
#import "FLLikePopoverViewController.h"

@interface TimelineDealCell : UITableViewCell<WYPopoverControllerDelegate, FLLikePopoverViewControllerDelegate>

@property (strong, nonatomic) id <TimelineDealCellDelegate> delegateController;
@property (strong, nonatomic) FLTimelineDeal *deal;
@property (strong, nonatomic) NSIndexPath *indexPath;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andDelegate:(id)delegate;

+ (CGFloat)getHeightForDeal:(FLTimelineDeal *)deal;

@end
