//
//  EventParticipantCell.h
//  Flooz
//
//  Created by jonathan on 2/27/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventParticipantCell : UITableViewCell

+ (CGFloat)getHeight;
@property (weak, nonatomic) FLUser *user;

@end
