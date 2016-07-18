//
//  ScopePickerCell.h
//  Flooz
//
//  Created by Olive on 18/07/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScopePickerCell : UITableViewCell

+ (CGFloat) getHeight:(TransactionScope)scope pot:(Boolean)isPot;

- (void) setScope:(TransactionScope)scope pot:(Boolean)isPot;

@end
