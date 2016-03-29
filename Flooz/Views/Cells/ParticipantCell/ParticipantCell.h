//
//  ParticipantCell.h
//  Flooz
//
//  Created by Olive on 3/23/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticipantCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) FLUser *participant;
@property (strong, nonatomic) FLUserView *avatarView;

@end
