//
//  ShareCell.h
//  Flooz
//
//  Created by Epitech on 10/8/15.
//  Copyright © 2015 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareCell : UITableViewCell

@property (nonatomic, retain) FLUser *user;

+ (CGFloat)getHeight;

@end
