//
//  BaseViewController.h
//  Flooz
//
//  Created by Arnaud on 2014-10-01.
//  Copyright (c) 2014 Flooz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface BaseViewController : GlobalViewController {
    UILabel *_headTitle;
    UIView *_headerView;
    UIView *_mainBody;
}

@property (nonatomic) BOOL showBack;
@property (nonatomic) BOOL showCross;

@end
