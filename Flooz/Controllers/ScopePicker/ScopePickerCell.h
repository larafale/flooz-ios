//
//  ScopePickerCell.h
//  Flooz
//
//  Created by Olive on 18/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLScope.h"

@interface ScopePickerCell : UITableViewCell

+ (CGFloat) getHeight:(FLScope *)scope pot:(Boolean)isPot;

- (void) setScope:(FLScope *)scope pot:(Boolean)isPot;

@end
