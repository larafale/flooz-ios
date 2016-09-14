//
//  ShareLinkViewController.h
//  Flooz
//
//  Created by Olive on 3/21/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "FriendAddSearchBarDelegate.h"
#import "THContactPickerView.h"

@interface ShareLinkViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, FriendAddSearchBarDelegate, THContactPickerDelegate>

- (id)initWithCollectId:(NSString *)collectId;

@end
