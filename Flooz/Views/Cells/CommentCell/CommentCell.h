//
//  CommentCell.h
//  Flooz
//
//  Created by Olive on 3/15/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

+ (CGFloat)getHeight:(FLComment *)comment;

- (void)loadWithComment:(FLComment *)comment;

@end
