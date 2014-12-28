//
//  MenuCell.h
//  Flooz
//
//  Created by Arnaud on 2014-09-22.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleMenu;
@property (strong, nonatomic) UIImageView *imageMenu;
@property (strong, nonatomic) UIImageView *indicatorMenu;
@property (weak, nonatomic) NSDictionary *menuDico;

+ (CGFloat)getHeight;
- (void)setMenu:(NSDictionary *)menuDic;

@end
