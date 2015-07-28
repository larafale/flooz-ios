//
//  TimelineDelegate.h
//  Flooz
//
//  Created by Arnaud on 2014-09-25.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	TimelineFilterNone = -1,
	TimelineFilterFriend = 0,
	TimelineFilterPublic,
	TimelineFilterPrivate
} TimelineFilter;

@protocol TimelineDelegate <NSObject>

- (void)reloadTableView;

@end
