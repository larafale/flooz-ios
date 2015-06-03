//
//  FriendPickerSelectionCell.h
//  Flooz
//
//  Created by olivier on 2/13/2014.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FriendPickerSelectionCell : UITableViewCell

+ (CGFloat)getHeight;

@property (weak, nonatomic) NSString *selectionText;

@end
