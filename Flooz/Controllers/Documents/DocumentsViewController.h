//
//  DocumentsViewController.h
//  Flooz
//
//  Created by jonathan on 2014-03-13.
//  Copyright (c) 2014 Jonathan Tribouharet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DocumentsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet FLTableView *tableView;

@end
