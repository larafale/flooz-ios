//
//  FriendPickerSelectionCell.h
//  Flooz
//
//  Created by jonathan on 2/13/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerSelectionCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) NSString *selectionText;

@end
