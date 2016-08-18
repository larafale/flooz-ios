//
//  ShopListViewController.h
//  Flooz
//
//  Created by Olive on 16/08/16.
//  Copyright © 2016 Flooz. All rights reserved.
//

#import "BaseViewController.h"
#import "LocationSearchBar.h"

@interface ShopListViewController : BaseViewController<LocationSearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@end
