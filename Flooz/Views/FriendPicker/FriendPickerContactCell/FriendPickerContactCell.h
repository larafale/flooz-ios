//
//  FriendPickerContactCell.h
//  Flooz
//
//  Created by jonathan on 2/11/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerContactCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) NSDictionary *contact;

@end
