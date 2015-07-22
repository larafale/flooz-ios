//
//  AccountCell.h
//  Flooz
//
//  Created by Epitech on 7/21/15.
//  Copyright © 2015 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountCell : UITableViewCell

@property (strong, nonatomic) UIImageView *indicator;
@property (strong, nonatomic) UILabel *badgeIcon;
@property (weak, nonatomic) NSDictionary *menuDico;

+ (CGFloat)getHeight;
- (void)setMenu:(NSDictionary *)menuDic;

@end
