//
//  FriendPickerContactCell.h
//  Flooz
//
//  Created by Olivier on 2/11/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerContactCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) NSDictionary *contact;

- (void)setSelectedCheckView:(BOOL)selected;

@end
