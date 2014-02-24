//
//  EventCellDelegate.h
//  Flooz
//
//  Created by jonathan on 2/18/2014.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EventCellDelegate <NSObject>

- (void)didEventTouchAtIndex:(NSIndexPath *)indexPath event:(FLEvent *)event;
- (void)updateEventAtIndex:(NSIndexPath *)indexPath event:(FLEvent *)event;
- (FLTableView *)tableView;

@end
